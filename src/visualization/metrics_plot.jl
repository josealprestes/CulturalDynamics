using .CoreTypes

"""
    plot_metrics(history::Vector{Dict{Symbol,Any}})

Plot metrics time series from simulation history.

# Arguments
- `history`: Vector of metric dictionaries from model.metadata.history

# Returns
- Makie Figure with time-series plots
"""
function plot_metrics(history::Vector{Dict{Symbol,Any}})
    isempty(history) && return Figure()
    
    # Extract data
    steps = [h[:step] for h in history]
    compliance = [h[:compliance_rate] for h in history]
    n_regions = [h[:n_regions] for h in history]
    motivation = [h[:mean_motivation] for h in history]
    
    # Create figure with 3 subplots
    fig = Figure(resolution=(1200, 800))
    
    # Compliance rate
    ax1 = Axis(fig[1, 1], title="Compliance Rate", xlabel="Step", ylabel="Rate")
    lines!(ax1, steps, compliance, color=:blue)
    
    # Number of regions
    ax2 = Axis(fig[1, 2], title="Number of Regions", xlabel="Step", ylabel="Regions")
    lines!(ax2, steps, n_regions, color=:red)
    
    # Mean motivation
    ax3 = Axis(fig[2, 1], title="Mean Motivation", xlabel="Step", ylabel="Motivation")
    lines!(ax3, steps, motivation, color=:green)
    
    return fig
end
