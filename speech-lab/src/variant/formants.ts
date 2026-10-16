/**
 * Formants F1/F2 per LPC a les vocals que ha localitzat l'API.
 *
 * Port de `formants.py` del prototip, operació per operació, perquè les
 * mesures coincidisquen amb les del model entrenat: tros de 25 ms, delmat a
 * 10 kHz per interpolació lineal (`np.interp` sobre `np.linspace`),
 * preèmfasi 0,97, finestra de Hamming de numpy, autocorrelació,
 * Levinson-Durbin d'ordre 12 i arrels del polinomi com a valors propis de la
 * matriu companya (el que fa `np.roots`). Es queda amb els pols de freqüència
 * > 150 Hz i amplada de banda < 500 Hz, i fa la mediana de tres trossos
 * (−10, 0, +10 ms) al voltant de l'instant demanat.
 */

/** Paràmetres LPC del model (els de `model.json` → `constants.lpc`). */
export const LPC = {
  resampleHz: 10_000,
  order: 12,
  halfFrameS: 0.0125,
  offsetsS: [-0.01, 0.0, 0.01],
  preemph: 0.97,
  f1Range: [200, 1200] as const,
  minFreq: 150,
  maxBandwidth: 500,
};

/** Recursió de Levinson-Durbin, idèntica a `levinson` (incloent-hi l'eixida si l'error es fa ≤ 0). */
export function levinson(r: ArrayLike<number>, order: number): Float64Array {
  const a = new Float64Array(order + 1);
  a[0] = 1;
  let e = r[0];
  for (let i = 1; i <= order; i += 1) {
    let dot = 0;
    for (let m = 1; m < i; m += 1) dot += a[m] * r[i - m];
    const acc = r[i] + dot;
    const k = -acc / e;
    const old = a.slice(0, i);
    for (let m = 1; m <= i; m += 1) a[m] = a[m] + k * old[i - m];
    e *= 1 - k * k;
    if (e <= 0) break;
  }
  return a;
}

/* ── Arrels d'un polinomi (np.roots) ─────────────────────────────────────── */

/**
 * Valors propis d'una matriu de Hessenberg superior (algorisme QR de doble
 * desplaçament de Francis, `hqr` de Numerical Recipes). Com LAPACK, torna
 * les arrels reals amb part imaginària exactament 0 i les complexes en
 * parelles conjugades, cosa que importa per al filtre `imag > 0`.
 */
function hqr(a: number[][]): { re: number[]; im: number[] } | null {
  const n = a.length;
  const wr = new Array<number>(n).fill(0);
  const wi = new Array<number>(n).fill(0);
  let anorm = 0;
  for (let i = 0; i < n; i += 1) {
    for (let j = Math.max(i - 1, 0); j < n; j += 1) anorm += Math.abs(a[i][j]);
  }
  let nn = n - 1;
  let t = 0;
  let p = 0;
  let q = 0;
  let r = 0;
  let s = 0;
  let w = 0;
  let x = 0;
  let y = 0;
  let z = 0;
  while (nn >= 0) {
    let its = 0;
    let l: number;
    do {
      for (l = nn; l >= 1; l -= 1) {
        s = Math.abs(a[l - 1][l - 1]) + Math.abs(a[l][l]);
        if (s === 0) s = anorm;
        if (Math.abs(a[l][l - 1]) + s === s) {
          a[l][l - 1] = 0;
          break;
        }
      }
      x = a[nn][nn];
      if (l === nn) {
        wr[nn] = x + t;
        wi[nn] = 0;
        nn -= 1;
      } else {
        y = a[nn - 1][nn - 1];
        w = a[nn][nn - 1] * a[nn - 1][nn];
        if (l === nn - 1) {
          p = 0.5 * (y - x);
          q = p * p + w;
          z = Math.sqrt(Math.abs(q));
          x += t;
          if (q >= 0) {
            z = p + (p >= 0 ? Math.abs(z) : -Math.abs(z));
            wr[nn - 1] = wr[nn] = x + z;
            if (z) wr[nn] = x - w / z;
            wi[nn - 1] = wi[nn] = 0;
          } else {
            wr[nn - 1] = wr[nn] = x + p;
            wi[nn - 1] = -(wi[nn] = z);
          }
          nn -= 2;
        } else {
          if (its === 60) return null;
          if (its === 10 || its === 20) {
            t += x;
            for (let i = 0; i <= nn; i += 1) a[i][i] -= x;
            s = Math.abs(a[nn][nn - 1]) + Math.abs(a[nn - 1][nn - 2]);
            y = x = 0.75 * s;
            w = -0.4375 * s * s;
          }
          its += 1;
          let m: number;
          for (m = nn - 2; m >= l; m -= 1) {
            z = a[m][m];
            r = x - z;
            s = y - z;
            p = (r * s - w) / a[m + 1][m] + a[m][m + 1];
            q = a[m + 1][m + 1] - z - r - s;
            r = a[m + 2][m + 1];
            s = Math.abs(p) + Math.abs(q) + Math.abs(r);
            p /= s;
            q /= s;
            r /= s;
            if (m === l) break;
            const u = Math.abs(a[m][m - 1]) * (Math.abs(q) + Math.abs(r));
            const v = Math.abs(p) * (Math.abs(a[m - 1][m - 1]) + Math.abs(z) + Math.abs(a[m + 1][m + 1]));
            if (u + v === v) break;
          }
          for (let i = m + 2; i <= nn; i += 1) {
            a[i][i - 2] = 0;
            if (i !== m + 2) a[i][i - 3] = 0;
          }
          for (let k = m; k <= nn - 1; k += 1) {
            if (k !== m) {
              p = a[k][k - 1];
              q = a[k + 1][k - 1];
              r = 0;
              if (k !== nn - 1) r = a[k + 2][k - 1];
              if ((x = Math.abs(p) + Math.abs(q) + Math.abs(r)) !== 0) {
                p /= x;
                q /= x;
                r /= x;
              }
            }
            const sq = Math.sqrt(p * p + q * q + r * r);
            s = p >= 0 ? sq : -sq;
            if (s !== 0) {
              if (k === m) {
                if (l !== m) a[k][k - 1] = -a[k][k - 1];
              } else {
                a[k][k - 1] = -s * x;
              }
              p += s;
              x = p / s;
              y = q / s;
              z = r / s;
              q /= p;
              r /= p;
              for (let j = k; j <= nn; j += 1) {
                p = a[k][j] + q * a[k + 1][j];
                if (k !== nn - 1) {
                  p += r * a[k + 2][j];
                  a[k + 2][j] -= p * z;
                }
                a[k + 1][j] -= p * y;
                a[k][j] -= p * x;
              }
              const mmin = nn < k + 3 ? nn : k + 3;
              for (let i = l; i <= mmin; i += 1) {
                p = x * a[i][k] + y * a[i][k + 1];
                if (k !== nn - 1) {
                  p += z * a[i][k + 2];
                  a[i][k + 2] -= p * r;
                }
                a[i][k + 1] -= p * q;
                a[i][k] -= p;
              }
            }
          }
        }
      }
    } while (l < nn - 1);
  }
  return { re: wr, im: wi };
}

/** Equilibrat de la matriu (`balanc` de Numerical Recipes, base 2), com fa LAPACK abans de buscar valors propis. */
function balance(a: number[][]): void {
  const RADIX = 2;
  const sqrdx = RADIX * RADIX;
  const n = a.length;
  let done = false;
  while (!done) {
    done = true;
    for (let i = 0; i < n; i += 1) {
      let r = 0;
      let c = 0;
      for (let j = 0; j < n; j += 1) {
        if (j !== i) {
          c += Math.abs(a[j][i]);
          r += Math.abs(a[i][j]);
        }
      }
      if (c !== 0 && r !== 0) {
        let g = r / RADIX;
        let f = 1;
        const s = c + r;
        while (c < g) {
          f *= RADIX;
          c *= sqrdx;
        }
        g = r * RADIX;
        while (c > g) {
          f /= RADIX;
          c /= sqrdx;
        }
        if ((c + r) / f < 0.95 * s) {
          done = false;
          g = 1 / f;
          for (let j = 0; j < n; j += 1) a[i][j] *= g;
          for (let j = 0; j < n; j += 1) a[j][i] *= f;
        }
      }
    }
  }
}

/** Arrels complexes d'un polinomi (coeficients de grau alt a baix), com `np.roots`. */
export function polyRoots(coefficients: ArrayLike<number>): { re: number; im: number }[] {
  const c = Array.from(coefficients);
  let first = c.findIndex((v) => v !== 0);
  if (first < 0) return [];
  let last = c.length - 1;
  while (c[last] === 0) last -= 1;
  const trailingZeros = c.length - 1 - last;
  const p = c.slice(first, last + 1);
  first = 0;
  const roots: { re: number; im: number }[] = [];
  const n = p.length - 1;
  if (n >= 1) {
    // Matriu companya: primera fila −p[1:]/p[0] i uns a la subdiagonal.
    const m: number[][] = Array.from({ length: n }, () => new Array<number>(n).fill(0));
    for (let j = 0; j < n; j += 1) m[0][j] = -p[j + 1] / p[0];
    for (let i = 1; i < n; i += 1) m[i][i - 1] = 1;
    balance(m);
    const eig = hqr(m);
    if (eig) eig.re.forEach((re, i) => roots.push({ re, im: eig.im[i] }));
  }
  for (let i = 0; i < trailingZeros; i += 1) roots.push({ re: 0, im: 0 });
  return roots;
}

/* ── Formants ────────────────────────────────────────────────────────────── */

/** `np.hamming(M)`, amb la mateixa fórmula que numpy. */
function hamming(size: number): Float64Array {
  const w = new Float64Array(size);
  if (size === 1) {
    w[0] = 1;
    return w;
  }
  for (let i = 0; i < size; i += 1) {
    const n = 1 - size + 2 * i;
    w[i] = 0.54 + 0.46 * Math.cos(Math.PI * n / (size - 1));
  }
  return w;
}

/** `formants(frame, sr, order)`: fins a tres formants (Hz) o null si n'hi ha menys de dos. */
export function frameFormants(frame: ArrayLike<number>, sampleRate: number, order = LPC.order): number[] | null {
  const len = frame.length;
  if (len === 0) return null;
  const win = hamming(len);
  const x = new Float64Array(len);
  x[0] = frame[0] * win[0];
  for (let i = 1; i < len; i += 1) x[i] = (frame[i] - LPC.preemph * frame[i - 1]) * win[i];
  // Autocorrelació en els retards 0..order (np.correlate 'full' retallat).
  const r = new Float64Array(order + 1);
  for (let k = 0; k <= order; k += 1) {
    let acc = 0;
    for (let n = 0; n + k < len; n += 1) acc += x[n + k] * x[n];
    r[k] = acc;
  }
  if (r[0] <= 1e-10) return null;
  const a = levinson(r, order);
  const out: number[] = [];
  for (const z of polyRoots(a)) {
    if (!(z.im > 0)) continue;
    const f = Math.atan2(z.im, z.re) * sampleRate / (2 * Math.PI);
    const bw = -Math.log(Math.hypot(z.re, z.im)) * sampleRate / Math.PI;
    if (f > LPC.minFreq && bw < LPC.maxBandwidth) out.push(f);
  }
  out.sort((p, q) => p - q);
  return out.length >= 2 ? out.slice(0, 3) : null;
}

/** Delmat per interpolació lineal: `np.interp(np.linspace(0, n-1, n10), np.arange(n), fr)`. */
function resampleLinear(frame: ArrayLike<number>, sampleRate: number, targetHz: number): Float64Array {
  const len = frame.length;
  const n10 = Math.trunc(len * targetHz / sampleRate);
  const out = new Float64Array(n10);
  if (n10 === 0) return out;
  const step = n10 > 1 ? (len - 1) / (n10 - 1) : 0;
  for (let i = 0; i < n10; i += 1) {
    const x = i === n10 - 1 && n10 > 1 ? len - 1 : i * step;
    const j = Math.floor(x);
    if (j >= len - 1) out[i] = frame[len - 1];
    else if (x === j) out[i] = frame[j];
    else out[i] = (frame[j + 1] - frame[j]) * (x - j) + frame[j];
  }
  return out;
}

/** Mediana com `np.median` (mitjana dels dos centrals si n'hi ha un nombre parell). */
export function median(values: readonly number[]): number {
  const s = [...values].sort((p, q) => p - q);
  const mid = s.length >> 1;
  return s.length % 2 ? s[mid] : (s[mid - 1] + s[mid]) / 2;
}

/**
 * `measure(x, sr, t)`: mediana de [F1, F2] en tres trossos de 25 ms al voltant
 * de `t` (segons). Null si cap tros no dona un F1 entre 200 i 1200 Hz.
 */
export function measureFormants(samples: ArrayLike<number>, sampleRate: number, t: number): [number, number] | null {
  const vals: number[][] = [];
  const h = Math.trunc(LPC.halfFrameS * sampleRate);
  for (const dt of LPC.offsetsS) {
    const c = Math.trunc((t + dt) * sampleRate);
    if (c - h < 0 || c + h > samples.length) continue;
    const frame = Array.prototype.slice.call(samples, c - h, c + h) as number[];
    const fm = frameFormants(resampleLinear(frame, sampleRate, LPC.resampleHz), LPC.resampleHz, LPC.order);
    if (fm && fm[0] > LPC.f1Range[0] && fm[0] < LPC.f1Range[1]) vals.push(fm.slice(0, 2));
  }
  if (vals.length === 0) return null;
  return [median(vals.map((v) => v[0])), median(vals.map((v) => v[1]))];
}
