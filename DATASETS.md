# DATASETS.md — dicionário dos 27 CSVs de resultados

> Todo CSV em `results/` (gitignore; publicar via Zenodo, ver `.zenodo.json`)
> é regenerável do gitHEAD pelos comandos abaixo. Seeds documentadas por arquivo.
> NOTA DE REPRODUTIBILIDADE: os scripts escrevem seeds explícitas e os CSVs
> canônicos são bit-idênticos ao re-rodar (verificado serial==threaded no
> Study C). Estudos diferentes podem reutilizar faixas de seed porque cada
> estudo usa configuração distinta (grade/F/Q/mecanismos) — a unicidade
> vem do par (config, seed), não da seed isolada. O guia de reprodução
> (Apêndice A) regenera o corpus exato; NÃO alterar seeds sem regenerar
> todos os CSVs e o checker.
> Verificação mecânica: `py -3 verificação número-a-CSV (privada)` (74 verificações
> executadas com corpus completo e schemas íntegros, EXIT 0; arquivos
> ausentes ou schemas obsoletos são reportados como FAIL explícito com
> lista MISSING, nunca traceback).
> Corpus de 27 arquivos em `results/*.csv` (26 linhas abaixo; a linha
> B2_multiseed+B2_topup cobre 2 arquivos);
> `benchmark/results/{scaling,castellano}.csv` contam à parte.
>
> Arquivos auxiliares fora do corpus machine-checked (demo/plot, sem checks):
> `results/demo_batch.csv` (exemplo do README), `results/study_C2_sweep.csv`
> (fase em ε, `plot_study_C2_D.py`).

| CSV | Script / comando | Conteúdo (linhas) |
|---|---|---|
| `study_C_sweep.csv` | `JULIA_NUM_THREADS=4 julia --project=. run_study_C_threaded.jl` | sweep F×Q×ε, 540 (seeds 2..31) |
| `study_C_agg.csv` | `julia --project=. stats_study_C_jl.jl` | agregado 18 células + IC95 |
| `study_C_timeseries.csv` | `julia --project=. run_study_C_timeseries.jl 30` | n_regions(t), 4500 (F5Q3, 30 reps) |
| `study_D_sweep.csv` | `julia --project=. run_study_D_ablation.jl` | ablação 6 conds × 8 |
| `vroom_control.csv` | `julia --project=. run_vroom_control.jl` | uniforme {0.25,0.4,0.6} vs Vroom, 60 |
| `klemm_spot.csv` | `julia --project=. run_klemm_spot.jl` | r ∈ {0,1e-4,1e-3} até absorção/cap |
| `rl_heldout.csv` | `julia --project=. run_rl_heldout.jl` | política vs nunca/sempre, 10 seeds held-out |
| `redteam_round2.csv` | `JULIA_NUM_THREADS=4 julia --project=. run_redteam_round2.jl` | MED-6, contágio, decomp, 128 |
| `redteam_round3.csv` | `JULIA_NUM_THREADS=4 julia --project=. run_redteam_round3.jl` | MED-6 fino, contágio n=60, decomp p2, 171 |
| `redteam_round4.csv` | `JULIA_NUM_THREADS=4 julia --project=. run_redteam_round4.jl` | top-up MED-6, Vroom+mon, 84 |
| `redteam_round5.csv` | `JULIA_NUM_THREADS=4 julia --project=. run_redteam_round5.jl` | treino vs monitoring, sanction on/off, 24 |
| `B2_multiseed.csv` + `B2_topup.csv` | `run_B2_multiseed.jl`, `run_B2_topup.jl` | Julia fastest/randomly, seeds 42..101 |
| `B2_mesa.csv` | `for s in 42..101: MESA_SEED=$s python3 benchmark/mesa_axelrod.py`, agregando as 60 saídas de 1 linha | Mesa 60 (canônico 1.2.1; shim 1.x/3.x) |
| `calibration_V2.csv` | `julia --project=. run_calibrate_V2.jl` | 16 trials fadiga |
| `scale_fitband.csv` | `julia --project=. run_scale_fitband.jl` | recalibração 31²/61² (15² em calibration_V2) |
| `scale31_topup.csv` | `julia --project=. run_scale31_topup.jl` | 31² seeds 9021..9060, n=40 (rep 21..60; soma aos 10 de `scale_transfer.csv` → 50 p/ 31²) |
| `scale_transfer.csv` | `julia --project=. run_scale_transfer.jl` | 31²/61² seeds 9001..9010 por grade (rep 1..10; 20 linhas) |
| `sensitivity_F4_n_regions.csv` | `julia --project=. run_sensitivity_F4.jl` | Sobol η² sobre n_regions (64) |
| `sensitivity_F4_partial_compliance.csv` | `julia --project=. run_sensitivity_F4.jl` | Sobol η² sobre aderência (64) |
| `ablation_nonsocial.csv` | `julia --project=. run_ablation_nonsocial.jl` | calibração sem difusão |
| `ablation_structure.csv` | `julia --project=. run_ablation_structure.jl` | social vs não-social × 10, 15² F3Q3 (R1 estrutural; erratum 2026-10-14: médias 29.0/210.8, p=0.0002 mantido) | estrutura 7× |
| `validation_V3.csv` | `julia --project=. run_validate_V3.jl` | P4 curva + P5 papéis |
| `validation_V3b.csv` | `julia --project=. run_validate_V3b.jl` | P5 corrigido (acoplamento) |
| `P5_round2.csv` | `JULIA_NUM_THREADS=4 julia --project=. run_P5_round2.jl` | P5c n=100 + P5d estrutural |
| `robustness.csv` | `julia --project=. run_robustness.jl` | 3 treinos + 3 calibrações |
| `enforcement_sweep.csv` | `julia --project=. run_enforcement_sweep.jl` | monitoring {0,0.02,0.1} × 8 |

> `benchmark/results/{scaling,castellano}.csv` (à parte do corpus 27):
> `benchmark/scaling_lean.jl` → ms/step × N + spots;
> `benchmark/castellano.jl` → Q 2..20 × 10.

Figuras: `results/figures/*.png` (plot_*.py); cópias vendored em `results/figures/`.
Ambiente: Julia 1.12.7 (corpus; suíte atual 268/268, também verde em 1.10.8),
Python 3.12 + scipy/pandas/matplotlib, Mesa 1.2.1.
