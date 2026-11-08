using HTTP
using JSON3
using Agents
using Random

include("CulturalDynamics.jl")
using .CulturalDynamics

const HTML_CONTENT = read(joinpath(@__DIR__, "..", "web", "index.html"), String)

function handle_index(req::HTTP.Request)
    return HTTP.Response(200, ["Content-Type" => "text/html; charset=utf-8"], body=HTML_CONTENT)
end

function handle_simulate(req::HTTP.Request)
    try
        params = JSON3.read(String(req.body))
        
        config = ModelConfig(
            grid_size = (params.grid_size, params.grid_size),
            F = params.F,
            Q = params.Q,
            bounded_confidence_threshold = params.epsilon,
            mutation = params.mutation > 0 ? PoissonMutation() : NoMutation(),
            mutation_rate = params.mutation,
            seed_culture = true,
            seed = rand(1:1_000_000),
        )
        
        model = build_model(config)
        step!(model, params.steps)
        
        region_data = count_regions(model)
        
        agents_list = collect(allagents(model))
        n = params.grid_size
        grid = zeros(Int, n, n)
        for agent in agents_list
            x, y = agent.pos
            grid[y, x] = agent.features[1]
        end
        # JS drawGrid espera matriz aninhada grid[row][col];
        # Matrix serializaria chapada via JSON3.
        grid_nested = [[grid[i, j] for j in 1:n] for i in 1:n]
        
        result = Dict(
            "agents" => length(agents_list),
            "compliance" => compliance_rate(model),
            "partial" => partial_compliance(model),
            "regions" => region_data[:n_regions],
            "largest_region" => region_data[:largest_region],
            "largest_share" => region_data[:largest_share],
            "grid" => grid_nested,
        )
        
        return HTTP.Response(200, ["Content-Type" => "application/json"], body=JSON3.write(result))
    catch e
        println("ERROR in simulate: ", e)
        return HTTP.Response(500, body=string(e))
    end
end

function start_server(port=8080)
    router = HTTP.Router()
    HTTP.register!(router, "GET", "/", handle_index)
    HTTP.register!(router, "POST", "/simulate", handle_simulate)

    println("Servidor rodando em http://localhost:$port")
    HTTP.serve(router, "0.0.0.0", port)
end

# Porta via CLI (`julia --project=. src/web_server.jl 18081`) ou ENV PORT;
# padrão 8080. Útil quando a 8080 já está ocupada.
port = if length(ARGS) >= 1
    parse(Int, ARGS[1])
elseif haskey(ENV, "PORT")
    parse(Int, ENV["PORT"])
else
    8080
end
start_server(port)
