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

## Example

Create a markdown file `test.md`:

```bash
mkdir sourcepath
echo "# Hello World\nThis is a test.\n\`\`\`julia\nprintln(123)\n\`\`\`" > sourcepath/test.md
```

Translate the markdown files:

```bash
# use -d to skip translation
julia test/scripts/translate.jl -s sourcepath -t mixedpath -p temppath
cat mixedpath/test.md
```


