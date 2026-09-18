/**
 * Captura d'àudio per al laboratori de veu en temps real.
 *
 * Envia blocs de 1024 mostres (64 ms a 16 kHz) cap al fil principal, amb el
 * nivell del senyal mesurat ací mateix: el mesurador de la pàgina ha de llegir
 * el senyal cru del micròfon, abans de resamplar.
 */
class Pcm16Capture extends AudioWorkletProcessor {
  constructor() {
    super();
    this.buffer = new Float32Array(1024);
    this.length = 0;
    this.sumSquares = 0;
    this.peak = 0;
  }

  process(inputs) {
    const channel = inputs[0] && inputs[0][0];
    if (!channel) return true;

    let offset = 0;
    while (offset < channel.length) {
      const room = this.buffer.length - this.length;
      const take = Math.min(room, channel.length - offset);
      this.buffer.set(channel.subarray(offset, offset + take), this.length);

      for (let index = offset; index < offset + take; index += 1) {
        const value = channel[index];
        this.sumSquares += value * value;
        const magnitude = value < 0 ? -value : value;
        if (magnitude > this.peak) this.peak = magnitude;
      }

      this.length += take;
      offset += take;

      if (this.length === this.buffer.length) {
        // Cal copiar: el worklet reutilitza el mateix buffer entre crides.
        // El nivell es mesura ací, sobre el senyal cru del micròfon (abans de
        // resamplar), perquè és el que explica una transcripció dolenta.
        this.port.postMessage({
          samples: this.buffer.slice(),
          rms: Math.sqrt(this.sumSquares / this.length),
          peak: this.peak,
        });
        this.length = 0;
        this.sumSquares = 0;
        this.peak = 0;
      }
    }
    return true;
  }
}

registerProcessor('pcm16-capture', Pcm16Capture);