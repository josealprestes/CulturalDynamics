using HTTP
using JSON3
using Agents
using Random

include("CulturalDynamics.jl")
using .CulturalDynamics

const HTML_CONTENT = read(joinpath(@__DIR__, "..", "web", "index.html"), String)

# ---------------------------------------------------------------------------
# Contrato de entrada do /simulate.
#
# A demo (web/index.html) manda no máximo: grade 10..80, F 1..15, Q 2..10,
# 50..2000 passos, epsilon 0..1 e mutation 0..0.15. Os limites abaixo cobrem
# esse uso com folga e barram o que o processo não tem como atender: uma grade
# 100000² pedida num POST de 100 bytes derrubava o servidor por memória, e
# `step!(model, n)` rodava o n que o cliente mandasse.
const MAX_BODY_BYTES = 4096
const LIMITS = (
    grid_size = (5, 101),      # 101² = 10_201 agentes por simulação
    F = (1, 15),               # slider da demo vai até 15
    Q = (2, 10),               # Q=1 divide por zero em partial_compliance
    steps = (1, 2000),         # slider da demo vai até 2000
    epsilon = (0.0, 1.0),
    mutation = (0.0, 1.0),
)

"""
    validate_params(p) -> Vector{String}

Lista de violações do contrato de `/simulate` (vazia = entrada aceita).
Nomeia o campo e a faixa: isso é contrato público da API, não detalhe interno.
"""
function validate_params(p)::Vector{String}
    bad = String[]
    for k in (:grid_size, :F, :Q, :steps)
        lo, hi = getfield(LIMITS, k)
        if !haskey(p, k)
            push!(bad, "$(k): campo obrigatório")
            continue
        end
        v = p[k]
        if !(v isa Integer) || v < lo || v > hi
            push!(bad, "$(k): inteiro entre $(lo) e $(hi)")
        end
    end
    for k in (:epsilon, :mutation)
        lo, hi = getfield(LIMITS, k)
        if haskey(p, k)
            v = p[k]
            if !(v isa Real) || !(lo <= v <= hi)
                push!(bad, "$(k): número entre $(lo) e $(hi)")
            end
        end
    end
    return bad
end

function error_response(status::Int, msg::String; fields=nothing)
    payload = fields === nothing ? Dict("error" => msg) :
                                  Dict("error" => msg, "fields" => fields)
    return HTTP.Response(status, ["Content-Type" => "application/json"],
                         body=JSON3.write(payload))
end

function handle_index(req::HTTP.Request)
    return HTTP.Response(200, ["Content-Type" => "text/html; charset=utf-8"], body=HTML_CONTENT)
end

function handle_simulate(req::HTTP.Request)
    body = String(req.body)
    if sizeof(body) > MAX_BODY_BYTES
        return error_response(413, "corpo da requisição acima de $(MAX_BODY_BYTES) bytes")
    end

    params = try
        JSON3.read(body)
    catch
        return error_response(400, "corpo não é JSON válido")
    end
    if !(params isa JSON3.Object)
        return error_response(400, "corpo JSON precisa ser um objeto")
    end

    bad = validate_params(params)
    if !isempty(bad)
        return error_response(400, "parâmetros fora do contrato"; fields=bad)
    end

    n = Int(params.grid_size)
    epsilon = haskey(params, :epsilon) ? Float64(params.epsilon) : 0.0
    mutation = haskey(params, :mutation) ? Float64(params.mutation) : 0.0

    try
        config = ModelConfig(
            grid_size = (n, n),
            F = Int(params.F),
            Q = Int(params.Q),
            bounded_confidence_threshold = epsilon,
            mutation = mutation > 0 ? PoissonMutation() : NoMutation(),
            mutation_rate = mutation,
            seed_culture = true,
            seed = rand(1:1_000_000),
        )

        model = build_model(config)
        step!(model, Int(params.steps))

        region_data = count_regions(model)

        agents_list = collect(allagents(model))
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
        # O detalhe fica no log do servidor. O cliente recebe mensagem genérica:
        # tipo e campo da exceção Julia não são informação que a API deva expor.
        println("ERROR in simulate: ", sprint(showerror, e))
        return error_response(500, "erro interno na simulação")
    end
end

function start_server(port::Int=8080, host::AbstractString=get(ENV, "CD_HOST", "127.0.0.1"))
    router = HTTP.Router()
    HTTP.register!(router, "GET", "/", handle_index)
    HTTP.register!(router, "POST", "/simulate", handle_simulate)

    if host == "127.0.0.1" || host == "localhost" || host == "::1"
        println("Servidor rodando em http://$(host):$(port) (só loopback)")
    else
        println("Servidor rodando em http://$(host):$(port)")
        println("AVISO: escutando em $(host) SEM autenticação — qualquer cliente que " *
                "alcance a porta dispara simulações neste processo.")
    end
    HTTP.serve(router, host, port)
end

# Porta via CLI (`julia --project=. src/web_server.jl 18081`) ou ENV PORT;
# padrão 8080. Útil quando a 8080 já está ocupada.
# Interface via CLI (segundo argumento) ou ENV CD_HOST; padrão **127.0.0.1**
# (loopback). Para servir a demo para outra máquina, é opt-in explícito:
# `CD_HOST=0.0.0.0 julia --project=. src/web_server.jl`.
port = if length(ARGS) >= 1
    parse(Int, ARGS[1])
elseif haskey(ENV, "PORT")
    parse(Int, ENV["PORT"])
else
    8080
end
host = length(ARGS) >= 2 ? ARGS[2] : get(ENV, "CD_HOST", "127.0.0.1")
start_server(port, host)
