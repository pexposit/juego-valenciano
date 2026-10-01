#!/usr/bin/env python3
"""Fine-tune de Matxa multiaccent amb la veu del narrador (voz-dataset/matxa/).

Parteix dels pesos de `matxa-tts-cat-multiaccent` (epoch 629) i entrena el
locutor 6 (lluc, valencià, home) amb els clips del narrador: no cal tocar
l'arquitectura i l'embedding de partida ja és d'una veu valenciana masculina.
Es fa servir el mateix optimitzador que el fine-tune de BSC (Adam, lr 1e-4) i
el trainer per defecte de Matcha (16-mixed, gradient clip 5).

Cada `--cada` èpoques guarda un checkpoint i sintetitza les frases de
`sintetitza-matxa.py` al costat, per a escoltar com evoluciona sense fer res:

  tts/runs/<nom>/checkpoints/epoch=0100.ckpt
  tts/runs/<nom>/mostres/epoch=0100/frase_01_spk6.wav ...
  tts/runs/<nom>/tb/                     (tensorboard --logdir tts/runs)

  .venv-voz/bin/python scripts/finetune-matxa.py --nom narrador-v1
  .venv-voz/bin/python scripts/finetune-matxa.py --nom narrador-v1 --reprendre   # continua
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import matxa_entorn as mx  # noqa: E402  (abans de qualsevol import de matcha)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--nom", required=True, help="nom de l'execució (carpeta en tts/runs/)")
    ap.add_argument("--dades", type=Path, default=mx.LAB / "voz-dataset" / "matxa")
    ap.add_argument("--epoques", type=int, default=300)
    ap.add_argument("--cada", type=int, default=50, help="èpoques entre checkpoints i mostres")
    ap.add_argument("--batch", type=int, default=8, help="16 no cap en 6 GB (clips de fins a 12 s)")
    ap.add_argument("--lr", type=float, default=1e-4)
    ap.add_argument("--reprendre", action="store_true", help="continua des de l'últim checkpoint")
    args = ap.parse_args()

    import functools

    import lightning as L
    import torch
    from lightning.pytorch.callbacks import Callback, LearningRateMonitor, ModelCheckpoint
    from lightning.pytorch.loggers import TensorBoardLogger
    from matcha.data.text_mel_datamodule import TextMelDataModule

    sintetitza = __import__("sintetitza-matxa")  # mateixes frases i escriptura de WAV

    run = mx.TTS / "runs" / args.nom
    ckpt_dir = run / "checkpoints"
    ultim = ckpt_dir / "last.ckpt"
    if args.reprendre and not ultim.exists():
        sys.exit(f"no hi ha {ultim} per a reprendre")
    if not args.reprendre and ckpt_dir.exists() and any(ckpt_dir.iterdir()):
        sys.exit(f"{run} ja té checkpoints: tria un altre --nom o passa --reprendre")

    L.seed_everything(1234)
    model = mx.carrega_model(mx.CKPT_BASE, "cpu").train()
    model.hparams.optimizer = functools.partial(torch.optim.Adam, lr=args.lr, weight_decay=0.0)
    stats = {k: float(v) for k, v in (("mel_mean", model.mel_mean), ("mel_std", model.mel_std))}

    dm = TextMelDataModule(
        name="narrador", train_filelist_path=str(args.dades / "train.txt"),
        valid_filelist_path=str(args.dades / "val.txt"), batch_size=args.batch, num_workers=4,
        pin_memory=True, cleaners=["basic_cleaners"], add_blank=True, n_spks=model.n_spks,
        n_fft=1024, n_feats=80, sample_rate=22050, hop_length=256, win_length=1024, f_min=0,
        f_max=8000,
        # Les estadístiques del checkpoint, no les del dataset nou: el model
        # normalitza els mels amb estos valors i han de coincidir amb la preentrena.
        data_statistics=stats, seed=1234,
    )

    class Mostres(Callback):
        """Sintetitza les frases de prova cada `--cada` èpoques, amb el mateix número que el checkpoint."""

        def __init__(self) -> None:
            self.voc = None

        def on_train_epoch_end(self, trainer, pl_module) -> None:  # noqa: ANN001
            ep = trainer.current_epoch  # ModelCheckpoint guarda quan (ep + 1) % cada == 0
            if (ep + 1) % args.cada and ep + 1 != trainer.max_epochs:
                return
            if self.voc is None:
                self.voc = mx.carrega_vocoder(pl_module.device)
            dir_ep = run / "mostres" / f"epoch={ep:04d}"
            dir_ep.mkdir(parents=True, exist_ok=True)
            pl_module.eval()
            for i, text in enumerate(sintetitza.FRASES, 1):
                ona = mx.sintetitza(pl_module, self.voc, text, mx.SPK_LLUC, pl_module.device)
                sintetitza.escriu(dir_ep / f"frase_{i:02d}_spk{mx.SPK_LLUC}.wav", ona.float())
            pl_module.train()

    trainer = L.Trainer(
        accelerator="gpu", devices=1, precision="16-mixed", gradient_clip_val=5.0,
        max_epochs=args.epoques, check_val_every_n_epoch=10, log_every_n_steps=10,
        default_root_dir=str(run), logger=TensorBoardLogger(str(run), name="tb"),
        callbacks=[
            ModelCheckpoint(dirpath=str(ckpt_dir), filename="epoch={epoch:04d}",
                            auto_insert_metric_name=False, every_n_epochs=args.cada,
                            save_top_k=-1, save_last=True, save_on_train_epoch_end=True),
            LearningRateMonitor(logging_interval="step"),
            Mostres(),
        ],
    )
    trainer.fit(model, datamodule=dm, ckpt_path=str(ultim) if args.reprendre else None)


if __name__ == "__main__":
    main()
