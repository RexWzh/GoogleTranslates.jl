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
