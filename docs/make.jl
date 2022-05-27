using CommonRLSpaces
using Documenter

DocMeta.setdocmeta!(CommonRLSpaces, :DocTestSetup, :(using CommonRLSpaces); recursive=true)

makedocs(;
    modules=[CommonRLSpaces],
    authors="Jun Tian <tianjun.cpp@gmail.com> and contributors",
    repo="https://github.com/Jun Tian/CommonRLSpaces.jl/blob/{commit}{path}#{line}",
    sitename="CommonRLSpaces.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Jun Tian.github.io/CommonRLSpaces.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Jun Tian/CommonRLSpaces.jl",
    devbranch="main",
)
