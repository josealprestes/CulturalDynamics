using CSV, DataFrames, Statistics, HypothesisTests, Distributions
# Uso: julia --project=. stats_study_C_jl.jl  (precisa results/study_C_sweep.csv)
# F1: KW por fator + post-hoc pairwise Mann-Whitney com correção Bonferroni,
#     Spearman com p-valor (aprox. t) e tabela por célula com IC95.
df = CSV.read("results/study_C_sweep.csv", DataFrame)
qcol = :Q in propertynames(df) ? :Q : (:sweep_Q in propertynames(df) ? :sweep_Q : :Q)
epscol = :sweep_epsilon in propertynames(df) ? :sweep_epsilon : :epsilon
fcol = :F in propertynames(df) ? :F : (:sweep_F in propertynames(df) ? :sweep_F : :F)
ncol = :final_n_regions in propertynames(df) ? :final_n_regions : :final_n_regions

# Spearman com correção de empates (midranks + Pearson nos ranks) —
# necessária aqui porque ε tem só 3 valores distintos (empates massivos).
# Confere com scipy.stats.spearmanr.
function midranks(x)
    xs = collect(Float64, x)
    n = length(xs)
    order = sortperm(xs)
    r = zeros(Float64, n)
    i = 1
    while i <= n
        j = i
        while j < n && xs[order[j+1]] == xs[order[i]]
            j += 1
        end
        avg = (i + j) / 2
        for k in i:j
            r[order[k]] = avg
        end
        i = j + 1
    end
    return r
end

function spearman_r(x, y)
    rx, ry = midranks(x), midranks(y)
    mx, my = mean(rx), mean(ry)
    dx, dy = rx .- mx, ry .- my
    den = sqrt(sum(dx .^ 2) * sum(dy .^ 2))
    return den == 0 ? NaN : sum(dx .* dy) / den
end

function spearman_p(r, n)
    n <= 2 && return NaN
    abs(r) >= 1.0 && return 0.0
    t = r * sqrt((n - 2) / (1 - r^2))
    return 2 * ccdf(TDist(n - 2), abs(t))
end

function ci95(v)
    n = length(v)
    n < 2 && return (mean(v), 0.0)
    h = quantile(Normal(), 0.975) * std(v) / sqrt(n)
    return (mean(v), h)
end

for col in [fcol, qcol, epscol]
    groups = [collect(g[!, ncol]) for (_, g) in pairs(groupby(df, col))]
    length(groups) < 2 && continue
    t = KruskalWallisTest(groups...)
    println("KW $col: H=$(round(t.H, digits=2)) p=$(pvalue(t)) groups=$(length.(groups))")
    # Post-hoc: Mann-Whitney par a par com Bonferroni
    keys_sorted = sort(unique(df[!, col]))
    npairs = length(keys_sorted) * (length(keys_sorted) - 1) ÷ 2
    for i in 1:length(keys_sorted), j in (i+1):length(keys_sorted)
        a = df[df[!, col] .== keys_sorted[i], ncol]
        b = df[df[!, col] .== keys_sorted[j], ncol]
        u = MannWhitneyUTest(collect(a), collect(b))
        p_adj = min(1.0, pvalue(u) * npairs)
        println("  MW $(keys_sorted[i]) vs $(keys_sorted[j]): p=$(round(pvalue(u), sigdigits=3)) p_bonf=$(round(p_adj, sigdigits=3))")
    end
end
for F in sort(unique(df[!, fcol]))
    sub = filter(r -> r[fcol] == F, df)
    r = spearman_r(sub[!, epscol], sub[!, ncol])
    println("Spearman F=$F eps vs regions: r=$(round(r, digits=3)) p=$(round(spearman_p(r, nrow(sub)), sigdigits=3)) n=$(nrow(sub))")
end

# Tabela por célula com IC95
cell = combine(groupby(df, [fcol, qcol, epscol]),
    ncol => mean => :mean_regions, ncol => std => :sd_regions, nrow => :n)
cell.half95 = [ci95(df[(df[!, fcol] .== r[fcol]) .& (df[!, qcol] .== r[qcol]) .& (df[!, epscol] .== r[epscol]), ncol])[2] for r in eachrow(cell)]
sort!(cell, [fcol, qcol, epscol])
println(cell)
CSV.write("results/study_C_agg.csv", cell)
println("Agregado com IC95 -> results/study_C_agg.csv ($(nrow(cell)) células)")
