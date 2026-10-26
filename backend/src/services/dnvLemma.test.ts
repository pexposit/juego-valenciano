import { describe, expect, it } from 'vitest';
import { formesDelLema } from '../../mcp/ErrorDetector/dnvClient.js';

describe('formesDelLema', () => {
  it('llig el lema i les variants admeses («reconéixer (o reconèixer)»)', () => {
    expect(formesDelLema('reconéixer (o reconèixer) [rekonéjʃeɾ] ui-button')).toEqual({ lema: 'reconéixer', variants: ['reconèixer'] });
  });

  it('lleva la fonètica, el número d\'homògraf i el botó', () => {
    expect(formesDelLema('perquè1 [peɾké] ui-button')).toEqual({ lema: 'perquè', variants: [] });
  });

  it('ignora les terminacions de flexió i admet diverses variants', () => {
    expect(formesDelLema('bonic, -a [bonik]')).toEqual({ lema: 'bonic', variants: [] });
    expect(formesDelLema('xicotet (o menut, petit) [x]').variants).toEqual(['menut', 'petit']);
  });
});
