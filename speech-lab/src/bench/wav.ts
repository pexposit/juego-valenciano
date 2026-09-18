/**
 * Lector mínim de WAV PCM16 mono per als àudios de prova del laboratori.
 * No cal cap llibreria: només recórrer els blocs RIFF.
 */

export type Pcm16Wav = {
  sampleRate: number
  channels: number
  bitsPerSample: number
  data: Buffer
}

export function readPcm16Wav(file: Buffer): Pcm16Wav {
  if (
    file.length < 44
    || file.toString('ascii', 0, 4) !== 'RIFF'
    || file.toString('ascii', 8, 12) !== 'WAVE'
  ) {
    throw new Error('El fitxer no és un WAV vàlid');
  }

  let offset = 12;
  let sampleRate = 0;
  let channels = 0;
  let bitsPerSample = 0;
  let data: Buffer | null = null;

  while (offset + 8 <= file.length) {
    const id = file.toString('ascii', offset, offset + 4);
    const size = file.readUInt32LE(offset + 4);
    const body = offset + 8;

    if (id === 'fmt ' && body + 16 <= file.length) {
      channels = file.readUInt16LE(body + 2);
      sampleRate = file.readUInt32LE(body + 4);
      bitsPerSample = file.readUInt16LE(body + 14);
    } else if (id === 'data') {
      data = file.subarray(body, Math.min(body + size, file.length));
    }

    // Els blocs WAV s'alineen a 2 bytes.
    offset = body + size + (size % 2);
  }

  if (!data) throw new Error('El WAV no té cap bloc de dades');
  if (channels !== 1 || bitsPerSample !== 16) {
    throw new Error(
      `Vosk necessita WAV mono PCM16 i este té ${channels} canal(s) i ${bitsPerSample} bits.`
      + ' Convertix-lo amb: bash speech-lab/scripts/convert-samples.sh',
    );
  }

  return { sampleRate, channels, bitsPerSample, data };
}
