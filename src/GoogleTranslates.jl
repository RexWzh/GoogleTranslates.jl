module GoogleTranslates

using XLSX
export
    # Excel tools
    write_xlsx, read_xlsx,
    # markdown tools
    splitMDtext, mds2temp, getcodes,
    temp2mds, temp2mds_mixed

# Excel tools
include("xlsx.jl")

# markdown tools
include("markdown.jl")

end
