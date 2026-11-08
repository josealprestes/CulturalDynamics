# Example 05: RL Training (F4 — Q-learning tabular)
#
# O gestor (agente RL) escolhe a intensidade de treinamento a cada bloco de
# passos para maximizar aderência menos custo. Cópia lateral conserva
# aderência média (F2.5), então a política ótima é um shutoff por custo:
# treinar forte longe do teto, desligar perto dele.
#
# Uso: julia --project=. examples/05_rl_training.jl  (~2-4 min)

using CulturalDynamics

# Configuração: org pequena, sem intervenção inicial
config = ModelConfig(
    grid_size = (11, 11),
    F = 3,
    Q = 3,
    seed_culture = true,
    seed = 1,
    max_steps = 150,
)

# Sem treino: aderência fica ~0.5 (conservação)
baseline = single_run(config)
println("Baseline sem intervenção:")
println("  partial_compliance = $(round(baseline[:summary][:final_partial_compliance], digits=3))")

# Com treino RL (Q-learning tabular, 6 estados × 3 intensidades)
println("\nTreinando gestor RL (25 episódios)...")
rl = train_rl(config; n_episodes=25)

println("\nPolítica aprendida (ação por estado 1..6):")
println("  estados: 1=(ader baixa,frag) 2=(ader baixa,consol) 3=(ader média,frag)")
println("           4=(ader média,consol) 5=(ader alta,frag) 6=(ader alta,consol)")
println("  ações:   1=sem treino 2=leve(0.005) 3=forte(0.02)")
println("  policy = $(rl[:policy])")
println("\nAderência final: $(round(rl[:final_partial], digits=3)) " *
        "(vs ~0.5 sem treino) — recompensa média/ep: $(round(rl[:mean_reward], digits=3))")
println("\nLeitura executiva: treinar forte no início paga; perto do teto,")
println("o custo supera o ganho e o gestor ótimo desliga o treino.")
