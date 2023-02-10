# GoogleTranslates

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://RexWzh.github.io/GoogleTranslates.jl/dev/)
[![Build Status](https://github.com/RexWzh/GoogleTranslates.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/RexWzh/GoogleTranslates.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/RexWzh/GoogleTranslates.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/RexWzh/GoogleTranslates.jl)

Translate markdown files using excel files and [Google Translate](https://translate.google.com/?sl=auto&tl=en&op=docs).

## Uasge

Install the package:

```julia
using Pkg
Pkg.add(url="https://github.com/RexWzh/GoogleTranslates.jl")
```

Use the script:

```julia
# CD to the directory of the repo
julia test/scripts/translate.jl -s <source path>\
                                -t <target path>\
                                -p <temp path>\
                                -e <excel file>\
                                -c <code file>\
                                -r <translated excel file>
```

## Quick demo
```bash
mkdir -p testpath
cd testpath
git clone https://github.com/JuliaPackaging/BinaryBuilder.jl.git
# copy the script `<repo>/test/scripts/translate.jl` to the current directory
mixedpath="BinaryBuilder.jl/docs/src_mix" # output directory
temppath="temppath" # directory of temp files
julia translate.jl -s BinaryBuilder.jl/docs/src -t $mixedpath -p $temppath
```

Translate the excel `temp.xlsx` via [Google translation](https://translate.google.com/?sl=auto&tl=en&op=docs) and Message
```bash
Please translate the excel file:
        temppath/temp.xlsx

link: https://translate.google.com/?sl=auto&tl=en&op=docs

Then place the translated file here:
        temppath/temp_tr.xlsx

Press Enter to continue after placing the file.
```

After placing the translated excel, press Enter to continue.

```bash
output files:
BinaryBuilder.jl/docs/src_mix/FAQ.md
BinaryBuilder.jl/docs/src_mix/build_tips.md
BinaryBuilder.jl/docs/src_mix/building.md
BinaryBuilder.jl/docs/src_mix/environment_variables.md
BinaryBuilder.jl/docs/src_mix/index.md
BinaryBuilder.jl/docs/src_mix/jll.md
BinaryBuilder.jl/docs/src_mix/reference.md
BinaryBuilder.jl/docs/src_mix/rootfs.md
BinaryBuilder.jl/docs/src_mix/tricksy_gotchas.md
BinaryBuilder.jl/docs/src_mix/troubleshooting.md
```

File changes:
- `tree . -L 2`
    ```bash
    .
    ├── BinaryBuilder.jl
    │   ├── LICENSE.md
    ... ...
    │   ├── docs
    │   ├── src
    │   └── test
    ├── temppath
    │   ├── temp.txt
    │   ├── temp.xlsx
    │   └── temp_tr.xlsx
    └── translate.jl
    ```
- `tree BinaryBuilder.jl/docs/` 
    ```bash
    BinaryBuilder.jl/docs
    ├── Project.toml
    ├── make.jl
    ├── src
    │   ├── FAQ.md
    │   ├── build_tips.md
    │   ├── building.md
    │   ├── environment_variables.md
    │   ├── index.md
    │   ├── jll.md
    │   ├── reference.md
    │   ├── rootfs.md
    │   ├── tricksy_gotchas.md
    │   └── troubleshooting.md
    └── src_mix
        ├── FAQ.md
        ├── build_tips.md
        ├── building.md
        ├── environment_variables.md
        ├── index.md
        ├── jll.md
        ├── reference.md
        ├── rootfs.md
        ├── tricksy_gotchas.md
        └── troubleshooting.md
    ```

The mixed markdown files are like
```md
# FAQ -- source

# 常见问题 -- translated

## How do I use a JLL package?

## 如何使用 JLL 包？
```