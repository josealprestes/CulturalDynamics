using Documenter
using CulturalDynamics

makedocs(
    sitename = "CulturalDynamics",
    modules = [CulturalDynamics],
    format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
    ),
    pages = [
        "Home" => "index.md",
        "Manual" => [
            "Getting Started" => "manual/getting_started.md",
            "Model Description" => "manual/model.md",
            "Extensions" => "manual/extensions.md",
            "Experiments" => "manual/experiments.md",
            "Para Gestores e Juristas" => "manual/managers.md",
        ],
        "API Reference" => "api.md",
        "Examples" => "examples.md",
    ],
)

deploydocs(
    repo = "github.com/josealprestes/CulturalDynamics.git",
)
