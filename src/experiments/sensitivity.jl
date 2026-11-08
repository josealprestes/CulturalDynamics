using .CoreTypes
using QuasiMonteCarlo
using Statistics: var, mean, quantile

"""
    sensitivity_analysis(base_config::ModelConfig; param_ranges, n_samples=1024, target=:n_regions)

Sobol quasi-Monte Carlo screening: sample `n_samples` parameter vectors,
run one simulation each, and estimate first-order influence (η² via 3-bin
between/total variance) per parameter.

- `target=:n_regions` → outcome `final_n_regions` (fragmentation)
- `target=:partial_compliance` → outcome `final_partial_compliance` (adherence)

η² here is a coarse screen (ranks levers, not precise Sobol indices).
"""
function sensitivity_analysis(
    base_config::ModelConfig;
    param_ranges::Dict{Symbol, Tuple{Float64, Float64}} = Dict(
        :F => (5.0, 15.0),
        :Q => (3.0, 10.0),
        :bounded_confidence_threshold => (0.0, 1.0),
        :mutation_rate => (0.0, 0.1),
    ),
    n_samples::Int = 1024,
    # F4: :n_regions (fragmentação) ou :partial_compliance (aderência)
    target::Symbol = :n_regions,
)
    param_names = collect(keys(param_ranges))
    lbs = [param_ranges[k][1] for k in param_names]
    ubs = [param_ranges[k][2] for k in param_names]
    target_key = target == :partial_compliance ? :final_partial_compliance : :final_n_regions
    prob = QuasiMonteCarlo.sample(n_samples, lbs, ubs, SobolSample())
    results = Dict{Symbol,Any}[]
    ys = Float64[]
    for i in 1:n_samples
        config = base_config
        for (j, pname) in enumerate(param_names)
            val = prob[j, i]
            if pname == :F
                config = @set config.F = round(Int, val)
            elseif pname == :Q
                config = @set config.Q = round(Int, val)
            elseif pname == :bounded_confidence_threshold
                config = @set config.bounded_confidence_threshold = val
            elseif pname == :mutation_rate
                config = @set config.mutation_rate = val
                # Taxa só atua com estratégia de mutação (F4 fix: sem isso
                # o parâmetro seria inerte e o η², artefato de aliasing)
                config = @set config.mutation = val > 0 ? PoissonMutation() : NoMutation()
            end
        end
        r = single_run(config)
        push!(results, r)
        push!(ys, Float64(r[:summary][target_key]))
    end
    eta2 = Dict{Symbol,Any}()
    total_var = var(ys)
    for (j, pname) in enumerate(param_names)
        xs = prob[j, :]
        # 3 bins para quota
        qs = quantile(xs, [0.33, 0.66])
        g1 = ys[xs .<= qs[1]]; g2 = ys[(xs .> qs[1]) .& (xs .<= qs[2])]; g3 = ys[xs .> qs[2]]
        between = var([mean(g1), mean(g2), mean(g3)]) * 3
        eta2[pname] = total_var > 0 ? clamp(between / total_var, 0.0, 1.0) : 0.0
    end
    return Dict{Symbol,Any}(:param_names=>param_names, :n_samples=>n_samples, :results=>results, :eta2=>eta2, :target=>target)
end
