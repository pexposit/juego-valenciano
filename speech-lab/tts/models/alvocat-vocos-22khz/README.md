---
license: cc
datasets:
- projecte-aina/festcat_trimmed_denoised
- projecte-aina/openslr-slr69-ca-trimmed-denoised
- projecte-aina/LaFrescat
tags:
- vocoder
- vocos
- tts
---

# 🥑 alVoCat

<!-- Provide a quick summary of what the model is/does. -->
🥑 alVoCat is a vocoder for Catalan TTS, based on Vocos architecture. It is highly performant and
high quality, works together with [🍵 Matxa](https://huggingface.co/BSC-LT/matcha-tts-cat-multiaccent) 
and you can find our fork [here](https://github.com/langtech-bsc/vocos/tree/matcha) and a demo [here](https://huggingface.co/spaces/BSC-LT/matchatts-vocos-onnx-ca).

## Model Details

### Model Description

<!-- Provide a longer summary of what this model is. -->

**Vocos** is a fast neural vocoder designed to synthesize audio waveforms from acoustic features.
Unlike other typical GAN-based vocoders, Vocos does not model audio samples in the time domain.
Instead, it generates spectral coefficients, facilitating rapid audio reconstruction through
inverse Fourier transform.

This version of **Vocos** uses 80-bin mel spectrograms as acoustic features which are widespread
in the TTS domain since the introduction of [hifi-gan](https://github.com/jik876/hifi-gan/blob/master/meldataset.py)
The goal of this model is to provide an alternative to hifi-gan that is faster and compatible with the 
acoustic output of several TTS models. This version is tailored for the Catalan language,
as it was trained only on Catalan speech datasets.

We are grateful with the authors for open sourcing the code allowing us to modify and train this version.

## Intended Uses and limitations

<!-- Address questions around how the model is intended to be used, including the foreseeable users of the model and those affected by the model. -->
The model is aimed to serve as a vocoder to synthesize audio waveforms from mel spectrograms. Is trained to generate speech and if is used in other audio
domain is possible that the model won't produce high quality samples. 

## How to Get Started with the Model

Use the code below to get started with the model.

### Installation

To use Vocos only in inference mode, install it using:

```bash
pip install git+https://github.com/langtech-bsc/vocos.git@matcha
```

### Reconstruct audio from mel-spectrogram

```python
import torch

from vocos import Vocos

vocos = Vocos.from_pretrained("projecte-aina/alvocat-vocos-22khz")

mel = torch.randn(1, 80, 256)  # B, C, T
audio = vocos.decode(mel)
```

### Copy-synthesis from a file:

```python
import torchaudio

y, sr = torchaudio.load(YOUR_AUDIO_FILE)
if y.size(0) > 1:  # mix to mono
    y = y.mean(dim=0, keepdim=True)
y = torchaudio.functional.resample(y, orig_freq=sr, new_freq=22050)
y_hat = vocos(y)
```

### Onnx 

We also release an onnx version of the model, you can check in colab:

<a target="_blank" href="https://colab.research.google.com/github/langtech-bsc/vocos/blob/matcha/notebooks/vocos_22khz_onnx_inference.ipynb">
  <img src="https://colab.research.google.com/assets/colab-badge.svg" alt="Open In Colab"/>
</a>

## Training Details

### Training Data

<!-- This should link to a Dataset Card, perhaps with a short stub of information on what the training data is all about as well as documentation related to data pre-processing or additional filtering. -->

The model was trained on 3 Catalan speech datasets

| Dataset             | Language | Hours   |
|---------------------|----------|---------|
| Festcat             | ca       | 22      |
| OpenSLR69           | ca       | 5       |
| LaFrescat           | ca       | 3.5     |



### Training Procedure

<!-- This relates heavily to the Technical Specifications. Content here should link to that section when it is relevant to the training procedure. -->
The model was trained for 1.5M steps and 1.3k epochs with a batch size of 16 for stability. We used a Cosine scheduler with an initial learning rate of 5e-4. 
We also modified the mel spectrogram loss to use 128 bins and fmax of 11025 instead of the same input mel spectrogram.


#### Training Hyperparameters


* initial_learning_rate: 5e-4
* scheduler: cosine without warmup or restarts
* mel_loss_coeff: 45
* mrd_loss_coeff: 0.1
* batch_size: 16
* num_samples: 16384

## Evaluation

<!-- This section describes the evaluation protocols and provides the results. -->

Evaluation was done using the metrics on the [original repo](https://github.com/gemelo-ai/vocos), after ~ 1000 epochs we achieve:

* val_loss: 3.57
* f1_score: 0.95
* mel_loss: 0.22
* periodicity_loss: 0.113
* pesq_score: 3.31
* pitch_loss: 31.61
* utmos_score: 3.33


## Citation

<!-- If there is a paper or blog post introducing the model, the APA and Bibtex information for that should go in this section. -->

If this code contributes to your research, please cite the work:

```
@article{siuzdak2023vocos,
  title={Vocos: Closing the gap between time-domain and Fourier-based neural vocoders for high-quality audio synthesis},
  author={Siuzdak, Hubert},
  journal={arXiv preprint arXiv:2306.00814},
  year={2023}
}
```

## Additional information

### Author
The Language Technologies Unit from Barcelona Supercomputing Center.

### Contact
For further information, please send an email to <langtech@bsc.es>.

### Copyright
Copyright(c) 2024 by Language Technologies Unit, Barcelona Supercomputing Center.

### License
[Creative Commons Attribution Non-commercial 4.0](https://www.creativecommons.org/licenses/by-nc/4.0/)

These models are free to use for non-commercial and research purposes. Commercial use is only possible through licensing by
the voice artists. For further information, contact <langtech@bsc.es> and <lafrescaproduccions@gmail.com>. 

### Funding

This work has been promoted and financed by the Generalitat de Catalunya through the [Aina project](https://projecteaina.cat/).

Part of the training of the model was possible thanks to the compute time given by Galician Supercomputing Center CESGA
([Centro de Supercomputación de Galicia](https://www.cesga.es/))