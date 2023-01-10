using GoogleTranslates
using Test

testpath = (@__DIR__) * "/testcases/"

# Test for Excel tools
@testset "Excel: read and write" begin
    # vector
    txt = ["hello", "world"]
    write_xlsx("$testpath/test.xlsx", txt)
    @test read_xlsx("$testpath/test.xlsx")[:] == txt
    # matrix
    mat = ["hello" "world"; "foo" "bar"]
    write_xlsx("$testpath/test.xlsx", mat)
    @test read_xlsx("$testpath/test.xlsx") == mat
end


# Test for markdown tools
@testset "split markdown" begin
    txt = raw"""## Rust builds

The Rust toolchain provided by BinaryBuilder can be requested by adding `:rust` to the `compilers` keyword argument to [`build_tarballs`](@ref): `compilers=[:c, :rust]`.  Rust-based packages can usually be built with `cargo`:

```sh
cargo build --release
```

The Rust toolchain provided by BinaryBuilder automatically selects the appropriate target and number of parallel jobs to be used.  Note, however, that you may have to manually install the product in the `${prefix}`.  Read the installation instructions of the package in case they recommend a different build procedure.

Example of packages using Rust:

```sh
cargo build --release
```
"""
    txts, codes = splitMDtext(txt)
    @test length(txts) == 6 && length(codes) == 2
    @test !any(isempty, txts)
    @test_throws ArgumentError splitMDtext(txt * "\n```")
end

@testset "Export temp files from markdown" begin
    file = "$testpath/builder_index.md"
    # single file
    mds2temp(file, excel="$testpath/temp.xlsx", code="$testpath/temp.txt")
    txt = read(file, String)
    @test isfile("$testpath/temp.xlsx") && isfile("$testpath/temp.txt")
    @test length(getcodes(read("$testpath/temp.txt", String))) == count("```", txt) ÷ 2

    # multiple files
    files = [file, file, file]
    mds2temp(files, excel="$testpath/temp.xlsx", code="$testpath/temp.txt")
    @test isfile("$testpath/temp.xlsx") && isfile("$testpath/temp.txt")
end

@testset "Recover markdown from temp files" begin
    filein = "$testpath/builder_index.md"
    fileout = "$testpath/temp_builder_index.md"
    txts, codes = splitMDtext(read(filein, String))
    mds2temp(filein; excel="$testpath/temp.xlsx", code="$testpath/temp.txt")
    temp2mds("$testpath/temp.xlsx", "$testpath/temp.txt", fileout)
    newtxts, newcodes = splitMDtext(read(fileout, String))
    # note that `filein` and `fileout` are not necessarily the same
    @test txts == newtxts && codes == newcodes
end

@testset "Mix raw version and translated version" begin
    filein = "$testpath/builder_index.md"
    excel = "$testpath/temp.xlsx"
    exceltr = "$testpath/builder_index_tr.xlsx"
    fileout = "$testpath/temp_builder_index_mixed.md"
    excel = "$testpath/temp_builder_index.xlsx"
    code = "$testpath/temp_builder_index.txt"
    
    # generate temp files
    mds2temp(filein, excel=excel, code=code) # generate temp files
    # translate
    run(`cp $excel $exceltr`) # pretend that we have translated the excel file
    # mix raw version and translated version
    temp2mixmds(fileout, excel, exceltr;code=code)
    @test true

    # test multiple files
    filein2 = "$testpath/builder_index2.md"
    fileout2 = "$testpath/temp_builder_index2_mixed.md"
    run(`cp $filein $filein2`)
    mds2temp([filein, filein2], excel=excel, code=code)
    run(`cp $excel $exceltr`)
    temp2mixmds([fileout, fileout2], excel, exceltr;code=code)
    @test true
end

@testset "Demo -- translate files in a path" begin
    # prepare files
    translatepath = "$testpath/source"
    translatepath_tr = "$testpath/translated"
    tmpfilepath = "$testpath/temp"
    file1 = "$testpath/builder_index.md"
    file2 = "$testpath/builder_index2.md"

    mkpath.([translatepath_tr, translatepath, tmpfilepath])
    run(`cp $file1 $translatepath`)
    run(`cp $file2 $translatepath`)
    
    # translate
    files = readdir(translatepath)
    filein = joinpath.(translatepath, files)
    fileout = joinpath.(translatepath_tr, files)
    excel = joinpath(tmpfilepath, "temp.xlsx")
    code = joinpath(tmpfilepath, "temp.txt")
    exceltr = joinpath(tmpfilepath, "temp_tr.xlsx")

    @test length(files) == 2
    mds2temp(filein, excel=excel, code=code)
    ## translate the excel file
    run(`cp $excel $exceltr`) # pretend that we have translated the excel file
    temp2mixmds(fileout, excel, exceltr;code=code)
end