using GoogleTranslates
using Documenter

DocMeta.setdocmeta!(GoogleTranslates, :DocTestSetup, :(using GoogleTranslates); recursive=true)

makedocs(;
    modules=[GoogleTranslates],
    authors="rex <1073853456@qq.com> and contributors",
    repo="https://github.com/RexWzh/GoogleTranslates.jl/blob/{commit}{path}#{line}",
    sitename="GoogleTranslates.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://RexWzh.github.io/GoogleTranslates.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/RexWzh/GoogleTranslates.jl",
    devbranch="main",
)
