using .CoreTypes

"""
    dashboard(config::ModelConfig)

Launch a web-based interactive dashboard for the simulation using WGLMakie.

Features:
- Live grid visualization in browser
- Play/Pause/Step controls
- Parameter sliders
- Real-time metrics panel

# Arguments
- `config`: Model configuration

# Returns
- Makie Figure with interactive controls (renders in browser via WGLMakie)
"""
function dashboard(config::ModelConfig)
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
    
    # Parameter sliders
    f_slider = Slider(fig[3, 1], range=1:20, startvalue=config.F, label="F (dimensions)")
    q_slider = Slider(fig[3, 2], range=2:20, startvalue=config.Q, label="Q (levels)")
    epsilon_slider = Slider(fig[3, 3], range=0.0:0.05:1.0, startvalue=config.bounded_confidence_threshold, label="ε (threshold)")
    
    # State
    is_running = Observable(false)
    current_config = Observable(config)
    current_model = Observable(model)
    
    # Update grid function
    function update_grid!()
        m = current_model[]
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
        m = current_model[]
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
        m = current_model[]
        step!(m)
        update_grid!()
        update_metrics!()
    end
    
    on(btn_reset.clicks) do _
        current_model[] = build_model(current_config[])
        empty!(ax_grid)
        empty!(ax_metrics)
        update_grid!()
    end
    
    # Parameter slider callbacks
    on(f_slider.value) do val
        current_config[] = @set current_config[].F = Int(val)
        current_model[] = build_model(current_config[])
        empty!(ax_grid)
        empty!(ax_metrics)
        update_grid!()
    end
    
    on(q_slider.value) do val
        current_config[] = @set current_config[].Q = Int(val)
        current_model[] = build_model(current_config[])
        empty!(ax_grid)
        empty!(ax_metrics)
        update_grid!()
    end
    
    on(epsilon_slider.value) do val
        current_config[] = @set current_config[].bounded_confidence_threshold = val
    end
    
    return fig
end
