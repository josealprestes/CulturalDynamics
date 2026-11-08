using .CoreTypes

"""
    interactive_app(config::ModelConfig)

Launch an interactive Makie application for exploring the simulation.

Features:
- Play/Pause/Step buttons
- Speed slider
- Live grid visualization
- Real-time metrics panel

# Arguments
- `config`: Model configuration

# Returns
- Makie Figure with interactive controls
"""
function interactive_app(config::ModelConfig)
    # Build model
    model = build_model(config)
    
    # Create figure
    fig = Figure(resolution=(1200, 800))
    
    # Grid panel
    ax_grid = Axis(fig[1, 1], title="Compliance Grid")
    
    # Metrics panel
    ax_metrics = Axis(fig[1, 2], title="Metrics", xlabel="Step", ylabel="Value")
    
    # Controls
    btn_play = Button(fig[2, 1], label="Play")
    btn_step = Button(fig[2, 2], label="Step")
    btn_reset = Button(fig[2, 3], label="Reset")
    speed_slider = Slider(fig[2, 4], range=1:100, startvalue=10, label="Speed")
    
    # State
    is_running = Observable(false)
    steps_done = Observable(0)
    
    # Initial plot
    config_obs = Observable(config)
    model_obs = Observable(model)
    
    # Update grid function
    function update_grid!()
        m = model_obs[]
        cfg = abmproperties(m)[:config]
        meta = abmproperties(m)[:metadata]
        w, h = cfg.grid_size
        
        color_matrix = zeros(RGBf, h, w)
        for agent in allagents(m)
            x, y = agent.pos
            r, g, b = features_to_color(agent.features, cfg.Q)
            color_matrix[y, x] = RGBf(r, g, b)
        end
        
        if !isnothing(meta.barrier_grid)
            for y in 1:h, x in 1:w
                if !meta.barrier_grid[y, x]
                    color_matrix[y, x] = RGBf(0.1, 0.1, 0.1)
                end
            end
        end
        
        image!(ax_grid, color_matrix)
    end
    
    # Update metrics function
    function update_metrics!()
        m = model_obs[]
        meta = abmproperties(m)[:metadata]
        
        if !isempty(meta.history)
            steps = [h[:step] for h in meta.history]
            compliance = [h[:compliance_rate] for h in meta.history]
            lines!(ax_metrics, steps, compliance, color=:blue)
        end
    end
    
    # Initial update
    update_grid!()
    
    # Button callbacks
    on(btn_play.clicks) do _
        is_running[] = !is_running[]
        if is_running[]
            btn_play.label = "Pause"
        else
            btn_play.label = "Play"
        end
    end
    
    on(btn_step.clicks) do _
        m = model_obs[]
        step!(m)
        steps_done[] += 1
        update_grid!()
        update_metrics!()
    end
    
    on(btn_reset.clicks) do _
        model_obs[] = build_model(config_obs[])
        steps_done[] = 0
        empty!(ax_grid)
        empty!(ax_metrics)
        update_grid!()
    end
    
    return fig
end
