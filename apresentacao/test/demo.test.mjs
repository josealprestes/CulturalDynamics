import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import vm from 'node:vm';
import { fileURLToPath } from 'node:url';

const htmlPath = fileURLToPath(new URL('../axelrod.html', import.meta.url));
const html = fs.readFileSync(htmlPath, 'utf8');
const script = html.match(/<script>([\s\S]*?)<\/script>/)?.[1];
if (!script) throw new Error('axelrod.html: script inline não encontrado');

const PRESETS = [...html.matchAll(/onclick="preset\(([^)]*)\)"/g)]
  .map((m) => m[1].split(',').map(Number));
assert.equal(PRESETS.length, 4, 'axelrod.html deve ter 4 presets');

function mulberry32(a) {
  return function () {
    a |= 0;
    a = (a + 0x6d2b79f5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

function boot(seed = 20261106) {
  const elements = new Map();
  const raf = [];

  function el(id) {
    if (!elements.has(id)) {
      const canvas = {
        fillStyle: '',
        fillRect() {},
      };
      elements.set(id, {
        id,
        textContent: '',
        innerHTML: '',
        value: '',
        width: 465,
        height: 465,
        style: {},
        classList: { add() {}, remove() {} },
        getContext() { return canvas; },
        _canvas: canvas,
      });
    }
    return elements.get(id);
  }

  const math = Object.create(Math);
  math.random = mulberry32(seed);
  const context = {
    console,
    Math: math,
    document: {
      getElementById: el,
      querySelectorAll: () => [],
    },
    requestAnimationFrame(cb) {
      raf.push(cb);
      return raf.length;
    },
  };
  vm.createContext(context);
  vm.runInContext(script, context);

  return {
    context,
    el,
    raf,
    get: (expr) => vm.runInContext(expr, context),
    run: (code) => vm.runInContext(code, context),
    pump(n) {
      for (let i = 0; i < n; i++) {
        const cb = raf.shift();
        if (!cb) break;
        cb();
      }
    },
  };
}

test('boot: reset inicial não lança e desenha métricas', () => {
  const h = boot();
  assert.equal(h.get('step'), 0);
  assert.equal(h.get('running'), false);
  assert.equal(h.el('sStep').textContent, '0');
  assert.match(h.el('sAdh').textContent, /%$/);
  assert.ok(Number(h.el('sReg').textContent) >= 1);
});

test('overlap: idênticos=1, disjuntos=0, parcial=(F-1)/F', () => {
  const h = boot();
  h.run('A.fill(1)');
  assert.equal(h.run('overlap(0,1)'), 1);
  h.run('A[0]=2');
  assert.equal(h.run('overlap(0,1)'), (h.get('P').F - 1) / h.get('P').F);
  h.run('A.fill(1); for (let f=0; f<P.F; f++) A[f]=2');
  assert.equal(h.run('overlap(0,1)'), 0);
});

test('regions: uniforme=1, duas metades=2', () => {
  const h = boot();
  h.run('A.fill(1)');
  assert.equal(h.run('regions().nreg'), 1);
  h.run(`
    for (let y=0; y<P.N; y++)
      for (let x=0; x<P.N; x++)
        for (let f=0; f<P.F; f++)
          A[(y*P.N+x)*P.F+f] = y < P.N/2 ? 1 : 2;
  `);
  assert.equal(h.run('regions().nreg'), 2);
});

test('adherence: tudo 1=0, tudo Q=1', () => {
  const h = boot();
  h.run('A.fill(1)');
  assert.equal(h.run('adherence()'), 0);
  h.run('A.fill(P.Q)');
  assert.equal(h.run('adherence()'), 1);
});

test('drawGrid: valor 1 é vermelho e valor Q é verde (regressão de cor)', () => {
  const h = boot();
  h.run('A.fill(1)');
  h.run('drawGrid()');
  assert.equal(h.el('cv')._canvas.fillStyle, 'rgb(229,95,95)');
  h.run('A.fill(P.Q)');
  h.run('drawGrid()');
  assert.equal(h.el('cv')._canvas.fillStyle, 'rgb(95,229,50)');
});

test('narrate/drawMetrics: os 4 presets não lançam (regressão N indefinido)', () => {
  for (const [F, Q, eps] of PRESETS) {
    const h = boot();
    h.run(`preset(${F},${Q},${eps})`);
    assert.doesNotThrow(() => h.run('drawMetrics(false)'), `${F}Q${Q} e${eps}`);
  }
});

test('narrate: ε0.6 explica o regime quase congelado', () => {
  const h = boot();
  h.run('preset(10,10,0.6)');
  h.run('step = 1');
  h.run('drawMetrics(true)');
  assert.match(h.el('narrator').innerHTML, /cópias raríssimas/);
});

test('smoke: cada preset avança e reagenda o loop', () => {
  for (const [F, Q, eps] of PRESETS) {
    const h = boot();
    h.run(`preset(${F},${Q},${eps})`);
    h.run('toggle()');
    h.pump(30);
    const step = h.get('step');
    const nreg = h.run('regions().nreg');
    assert.equal(h.get('running'), true, `${F}Q${Q} e${eps}: parou sozinho`);
    assert.ok(step > 0, `${F}Q${Q} e${eps}: step não avançou (${step})`);
    assert.ok(nreg >= 1 && nreg <= h.get('P').N ** 2, `${F}Q${Q} e${eps}: nreg inválido`);
    assert.ok(h.raf.length > 0, `${F}Q${Q} e${eps}: loop não reagendou`);
  }
});

test('pausar: step congela e loop não reagenda trabalho novo', () => {
  const h = boot();
  h.run('preset(5,3,0.3); toggle()');
  h.pump(5);
  const step = h.get('step');
  h.run('toggle()');
  assert.equal(h.get('running'), false);
  h.pump(10);
  assert.equal(h.get('step'), step);
});

test('preset -> reset -> play: reinicia e volta a avançar', () => {
  const h = boot();
  h.run('preset(10,10,0.3)');
  h.run('reset()');
  assert.equal(h.get('step'), 0);
  h.run('toggle()');
  h.pump(15);
  assert.ok(h.get('step') > 0);
  assert.equal(h.get('running'), true);
});

test('advance: retorna cópias e incrementa step', () => {
  const h = boot();
  h.run('preset(5,3,0.3)');
  const copies = h.run('advance(1000)');
  assert.ok(copies > 0);
  assert.equal(h.get('step'), copies);
});
