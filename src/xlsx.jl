"""
    write_xlsx(filename::AbstractString, vector::AbstractVector)

Write the vector to the first column of an Excel file.
"""
function write_xlsx(filename::AbstractString, vector::AbstractVector)
    XLSX.openxlsx(filename, mode="w") do xf
        sheet = xf[1]
        n = length(vector)
        sheet["A1:A$n"] = reshape(vector, n, 1)
    end
end

"""
    write_xlsx(filename::AbstractString, mat::AbstractMatrix)

Write the matrix to an Excel file.
"""
function write_xlsx(filename::AbstractString, mat::AbstractMatrix)
    XLSX.openxlsx(filename, mode="w") do xf
        m, n = size(mat)
        sheet = xf[1]
        sheet["A1:$(excel_colname(n))$m"] = mat
    end
end

"""
    excel_colind(k::Int)

Convert the column index to a column name.
"""
function excel_colname(k::Int)
    k ≤ 2 ^ 14 || throw(ArgumentError("column index $k is too large"))
    (k -= 1) ≤ 25 && return 'A' + k
    (k -= 26) ≤ 26 ^ 2 - 1 && return ('A' + k ÷ 26) * ('A' + k % 26)
    join('A' + i for i in reverse!(digits(k - 26 ^ 2, base = 26, pad=3)))
end

"""
    read_xlsx(filename::AbstractString)

Read the first sheet of the Excel file into a matrix of strings.
"""
read_xlsx(filename::AbstractString) = @views string.(XLSX.readxlsx(filename)[1][:])