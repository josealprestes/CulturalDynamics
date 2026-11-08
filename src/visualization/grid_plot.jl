using .CoreTypes

"""
    plot_grid(model)

Render the compliance grid as a colored heatmap using GLMakie.

# Arguments
- `model`: The ABM model

# Returns
- Makie Figure with the grid visualization
"""
function plot_grid(model)
    config = abmproperties(model)[:config]
    meta = abmproperties(model)[:metadata]
    w, h = config.grid_size
    
    # Build color matrix
    color_matrix = zeros(RGBf, h, w)
    
    for agent in allagents(model)
        x, y = agent.pos
        r, g, b = features_to_color(agent.features, config.Q)
        color_matrix[y, x] = RGBf(r, g, b)
    end
    
    # Mark barriers as dark gray
    if !isnothing(meta.barrier_grid)
        for y in 1:h, x in 1:w
            if !meta.barrier_grid[y, x]
                color_matrix[y, x] = RGBf(0.1, 0.1, 0.1)
            end
        end
    end
    
    # Create figure
    fig = Figure(resolution=(800, 800))
    ax = Axis(fig[1, 1], title="Compliance Grid", xlabel="X", ylabel="Y")
    
    image!(ax, color_matrix)
    
    return fig
end
