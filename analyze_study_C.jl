using CSV, DataFrames, Statistics

df = CSV.read("results/study_C_sweep.csv", DataFrame)

g = groupby(df, [:F, :Q, :sweep_epsilon])
agg = combine(g,
    :final_n_regions => mean => :mean_regions,
    :final_n_regions => std => :sd_regions,
    :final_largest_share => mean => :mean_share,
    :final_largest_share => std => :sd_share,
    :final_compliance_rate => mean => :mean_compliance,
    :final_mean_region_size => mean => :mean_size,
)

CSV.write("results/study_C_agg.csv", agg)
println("Agg -> results/study_C_agg.csv")
show(agg, allrows=true, allcols=true)
println()

ge = groupby(df, :sweep_epsilon)
agge = combine(ge,
    :final_n_regions => mean => :mean_regions,
    :final_n_regions => std => :sd_regions,
    :final_largest_share => mean => :mean_share,
    :final_compliance_rate => mean => :mean_compliance,
)
println("Por ε:")
show(agge, allrows=true)
println()

gf = groupby(df, [:F])
aggf = combine(gf, :final_n_regions => mean => :mean_regions, :final_n_regions => std => :sd_regions, :final_largest_share => mean => :mean_share)
println("Por F:")
show(aggf, allrows=true)
println()

gq = groupby(df, [:Q])
aggq = combine(gq, :final_n_regions => mean => :mean_regions, :final_n_regions => std => :sd_regions)
println("Por Q:")
show(aggq, allrows=true)
println()

# Quick compliance summary
println("Compliance geral (Q alto -> Q^F grande -> compliance ~0):")
show(combine(groupby(df, [:Q]), :final_compliance_rate => mean => :mean_comp), allrows=true)
