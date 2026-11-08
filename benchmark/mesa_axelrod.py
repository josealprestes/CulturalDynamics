"""
Mesa (shim 1.x/3.x) — Axelrod cultural dissemination com bounded confidence (B2).
Resultados canônicos gerados com Mesa 1.2.1 (`RandomActivation`, API clássica);
o shim detecta a versão e usa `Agent(unique_id, model)` (1.x) ou
`Agent(model)` (3.x). Ver BENCHMARKS.md §B2.

Replica F=5 Q=3 ε=0.3 31×31 300 passos seed=42 do CulturalDynamics.jl
para comparação Julia×Python (ms/step e n_regions). Ver BENCHMARKS.md B2.

Requer: pip install mesa numpy
Uso: python benchmark/mesa_axelrod.py
Saída: benchmark/results/mesa_axelrod.csv + stdout com métricas.
NOTA B2 (n=60/braço): o script escreve UMA linha por rodada (1 seed).
Para o corpus, rode `for s in 42..101` com MESA_SEED=$s e AGREGUE as
60 linhas em results/B2_mesa.csv (cols side,scheduler,seed,n_regions,
largest,largest_share) — o checker espera 60 linhas Mesa + 120 Julia.
Sem Mesa instalado, o script gera placeholder de 1 linha (não-corpus).
"""
import random
import time
import csv
import os

try:
    from mesa import Agent, Model
    from mesa.space import SingleGrid
    from mesa.time import RandomActivation
    MESA_AVAILABLE = True
except ImportError:
    MESA_AVAILABLE = False

F, Q, EPSILON = 5, 3, 0.3
W, H = 31, 31
MAX_STEPS = 300
SEED = int(os.environ.get("MESA_SEED", "42"))

def count_regions_mesa(model):
    parent = {}
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(a, b):
        ra, rb = find(a), find(b)
        if ra != rb:
            parent[rb] = ra
    agents = list(model.schedule.agents)
    for a in agents:
        parent[a.unique_id] = a.unique_id
    for a in agents:
        for nb in model.grid.get_neighbors(a.pos, moore=False, include_center=False):
            if isinstance(nb, ComplianceAgent) and a.features == nb.features:
                union(a.unique_id, nb.unique_id)
    roots = {}
    for a in agents:
        r = find(a.unique_id)
        roots[r] = roots.get(r, 0) + 1
    sizes = sorted(roots.values(), reverse=True)
    return len(sizes), sizes[0] if sizes else 0, sizes[0]/len(sizes) if sizes else 0

if MESA_AVAILABLE:
    import mesa as _mesa_mod
    _MESA_MAJOR = int(str(getattr(_mesa_mod, "__version__", "0")).split(".")[0])

    class ComplianceAgent(Agent):
        _uid_counter = 0
        def __init__(self, model, features):
            if _MESA_MAJOR >= 3:
                super().__init__(model)
            else:  # Mesa 1.x: Agent(unique_id, model)
                ComplianceAgent._uid_counter += 1
                super().__init__(ComplianceAgent._uid_counter, model)
            self.features = features[:]
        def step(self):
            neighbors = self.model.grid.get_neighbors(self.pos, moore=False, include_center=False)
            neighbors = [n for n in neighbors if isinstance(n, ComplianceAgent)]
            if not neighbors:
                return
            partner = self.random.choice(neighbors)
            overlap = sum(1 for i in range(F) if self.features[i] == partner.features[i])
            similarity = overlap / F
            if similarity < EPSILON:
                return
            if self.random.random() > similarity:
                return
            diff = [i for i in range(F) if self.features[i] != partner.features[i]]
            if not diff:
                return
            idx = self.random.choice(diff)
            self.features[idx] = partner.features[idx]

    class AxelrodModel(Model):
        def __init__(self, w=W, h=H, seed=SEED):
            super().__init__(seed=seed)
            self.grid = SingleGrid(w, h, torus=False)
            self.schedule = RandomActivation(self)
            if _MESA_MAJOR >= 3:
                cells = [(pos) for _, pos in self.grid.coord_iter()]
            else:  # Mesa 1.x coord_iter yields (contents, x, y)
                cells = [((x, y)) for _, x, y in self.grid.coord_iter()]
            for pos in cells:
                feats = [self.random.randint(0, Q-1) for _ in range(F)]
                a = ComplianceAgent(self, feats)
                self.grid.place_agent(a, pos)
                self.schedule.add(a)
        def step(self):
            self.schedule.step()

if __name__ == "__main__":
    if not MESA_AVAILABLE:
        print("Mesa não instalado. Instale com: pip install mesa")
        print("Gerando placeholder benchmark/results/mesa_axelrod.csv")
        os.makedirs("benchmark/results", exist_ok=True)
        with open("benchmark/results/mesa_axelrod.csv", "w", newline="") as f:
            w = csv.writer(f)
            w.writerow(["F","Q","epsilon","W","H","steps","seed","note"])
            w.writerow([F,Q,EPSILON,W,H,MAX_STEPS,SEED,"mesa_not_installed"])
        raise SystemExit(0)

    random.seed(SEED)
    model = AxelrodModel(W, H, seed=SEED)
    t0 = time.perf_counter()
    for _ in range(MAX_STEPS):
        model.step()
    elapsed = time.perf_counter() - t0
    ms_per_step = elapsed / MAX_STEPS * 1000
    n_regions, largest, share = count_regions_mesa(model)
    print(f"Mesa {W}x{H} F={F} Q={Q} eps={EPSILON} {MAX_STEPS} passos")
    print(f"  {ms_per_step:.2f} ms/step, {1000/ms_per_step:.0f} steps/sec")
    print(f"  n_regions={n_regions} largest={largest} share={share:.3f}")
    os.makedirs("benchmark/results", exist_ok=True)
    with open("benchmark/results/mesa_axelrod.csv", "w", newline="") as f:
        w = csv.writer(f)
        w.writerow(["F","Q","epsilon","W","H","steps","seed","ms_per_step","n_regions","largest","share"])
        w.writerow([F,Q,EPSILON,W,H,MAX_STEPS,SEED,f"{ms_per_step:.2f}",n_regions,largest,f"{share:.4f}"])
    print("CSV: benchmark/results/mesa_axelrod.csv")
