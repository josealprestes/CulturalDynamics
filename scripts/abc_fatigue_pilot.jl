# ABC pilot for fatigue_rate (F9): rejection sampling on public hand-hygiene
# moments (decline 0.085, level 0.415), mirroring run_calibrate_V2.jl protocol
# (15^2 F3Q3 eps0.3 300 steps) at pilot scale. NOT corpus: posterior is a
# methods pilot for the paper's band claim (0.003-0.006), never a paper number.
# Usage: julia --project=. scripts/abc_fatigue_pilot.jl
# Output: results/abc_fatigue_pilot.csv (gitignored) + posterior summary.
using CulturalDynamics
using Random: Xoshiro
using Statistics: mean, quantile
using CSV, DataFrames

function draw_moments(fr, seed)
    cfg = ModelConfig(grid_size=(15, 15), F=3, Q=3, seed_culture=true,
                      seed=seed, bounded_confidence_threshold=0.3,
                      max_steps=300, recording_interval=300,
                      fatigue_rate=fr)
    m = evaluate_moments(cfg)
    return m[:decline], m[:final_partial]
end

rng = Xoshiro(20261013)
prior_lo, prior_hi = 0.0005, 0.008
target = (decline=0.085, final=0.415)
CEIL = 0.012  # acceptance RMSE (pilot counterpart of the 0.05 ceiling)

accepted = Float64[]
losses = Float64[]
for i in 1:40
    fr = prior_lo + (prior_hi - prior_lo) * rand(rng)
    ds = Float64[]
    fs = Float64[]
    for r in 1:2
        d, f = draw_moments(fr, 10_000 + 100i + r)
        push!(ds, d)
        push!(fs, f)
    end
    loss = sqrt(((mean(ds) - target.decline)^2 + (mean(fs) - target.final)^2) / 2)
    push!(losses, loss)
    loss <= CEIL && push!(accepted, fr)
end
mkpath("results")
CSV.write("results/abc_fatigue_pilot.csv",
          DataFrame(fatigue_rate=accepted))
println("ABC pilot: 40 draws x 2 reps (15^2, 300 steps)")
println("  accepted=$(length(accepted))/40  min_loss=$(round(minimum(losses), digits=4))")
if !isempty(accepted)
    println("  posterior median=$(round(quantile(accepted, 0.5), digits=5)) " *
            "95%CI=[$(round(quantile(accepted, 0.025), digits=5)), " *
            "$(round(quantile(accepted, 0.975), digits=5))]")
    println("  paper band 0.003-0.006 inside CI: " *
            string(quantile(accepted, 0.025) <= 0.006 && 0.003 <= quantile(accepted, 0.975)))
else
    println("  no draws accepted: widen CEIL or prior (pilot result, reported as-is)")
end
