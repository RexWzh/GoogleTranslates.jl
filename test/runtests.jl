using GoogleTranslates
using Test

# Test for Excel tools
@testset "Excel: read and write" begin
    # vector
    txt = ["hello", "world"]
    write_xlsx("test.xlsx", txt)
    @test read_xlsx("test.xlsx")[:] == txt
    mat = ["hello" "world"; "foo" "bar"]
    write_xlsx("test.xlsx", mat)
    @test read_xlsx("test.xlsx") == mat
end


# Test for markdown tools
@testset "split markdown" begin
    txt = raw"""## Rust builds

The Rust toolchain provided by BinaryBuilder can be requested by adding `:rust` to the `compilers` keyword argument to [`build_tarballs`](@ref): `compilers=[:c, :rust]`.  Rust-based packages can usually be built with `cargo`:

```sh
cargo build --release
```

The Rust toolchain provided by BinaryBuilder automatically selects the appropriate target and number of parallel jobs to be used.  Note, however, that you may have to manually install the product in the `${prefix}`.  Read the installation instructions of the package in case they recommend a different build procedure.

Example of packages using Rust:"""
    txts, codes = splitMDtext(txt)
    @test length(txts) == 5 && length(codes) == 1
    @test !any(isempty, txts)
    @test_throws ArgumentError splitMDtext(txt * "\n```")
end

@testset "Export temp files from markdown" begin
    file = (@__DIR__) * "/testcases/builder_index.md"
    mds2temp(file)
    txt = read(file, String)
    @test isfile("temp.xlsx") && isfile("temp.txt")
    @test length(getcodes(read("temp.txt", String))) == count("```", txt) ÷ 2
end

@testset "Recover markdown from temp files" begin
    filein = (@__DIR__) * "/testcases/builder_index.md"
    fileout = (@__DIR__) * "/testcases/temp_builder_index.md"
    txts, codes = splitMDtext(read(filein, String))
    mds2temp(filein)
    temp2mds("temp.xlsx", "temp.txt", fileout)
    newtxts, newcodes = splitMDtext(read(fileout, String))
    # note that `filein` and `fileout` are not necessarily the same
    @test txts == newtxts && codes == newcodes
end

@testset "Mix raw version and translated version" begin
    filein = (@__DIR__) * "/testcases/builder_index.md"
    exceltr = (@__DIR__) * "/testcases/builder_index_tr.xlsx"
    fileout = (@__DIR__) * "/temp_builder_index_mixed.md"
    excelout = (@__DIR__) * "/temp_builder_index.xlsx"
    
    # generate temp files
    mds2temp(filein, excel=excelout) # generate temp files
    # translate
    run(`cp $excelout $exceltr`) # pretend that we have translated the excel file
    # mix raw version and translated version
    temp2mixmds(fileout, excelout, exceltr)
end