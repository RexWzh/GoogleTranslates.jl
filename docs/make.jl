# using GoogleTranslates
using Documenter

# DocMeta.setdocmeta!(GoogleTranslates, :DocTestSetup, :(using GoogleTranslates); recursive=true)

makedocs(;
    # modules=[GoogleTranslates],
    authors="rex <1073853456@qq.com> and contributors",
    repo="https://github.com/RexWzh/GoogleTranslates.jl/blob/{commit}{path}#{line}",
    sitename="GoogleTranslates.jl",
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/RexWzh/GoogleTranslates.jl",
    devurl = "dev",
    devbranch="dev",
    versions = ["stable" => "v^", "dev" => "dev"]
)
