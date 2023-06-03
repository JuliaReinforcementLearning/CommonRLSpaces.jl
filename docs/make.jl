using CommonRLSpaces
using Random
using Documenter

DocMeta.setdocmeta!(CommonRLSpaces, :DocTestSetup, :(using CommonRLSpaces); recursive=true)

makedocs(;
    modules=[CommonRLSpaces],
    authors="Jun Tian <tianjun.cpp@gmail.com> and contributors",
    repo="https://github.com/JuliaReinforcementLearning/CommonRLSpaces.jl/blob/{commit}{path}#{line}",
    sitename="CommonRLSpaces.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://github.com/JuliaReinforcementLearning/CommonRLSpaces.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "array.md",
        "extensions.md"
    ],
)

deploydocs(;
    repo="https://github.com/JuliaReinforcementLearning/CommonRLSpaces.jl",
    devbranch="main",
)
