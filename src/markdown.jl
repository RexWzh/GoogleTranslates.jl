"""
    splitMDtext(text::AbstractString)

Split a markdown text into a list of text blocks and a list of code blocks.
"""
function splitMDtext(text::AbstractString)
    lines = split(text, '\n')
    txts, codes = String[], String[]
    
    incode = false
    for line in lines
        line = "\n" * line
        if startswith(line, r"\s*```")
            incode = !incode
            if incode # start a new code block
                push!(codes, line)
                push!(txts, "`C`") # mark the code block
            else
                codes[end] *= line
            end
        elseif incode
            codes[end] *= line
        elseif line!="\n" # skip empty lines
            push!(txts, line)
        end
    end
    incode && throw(ArgumentError("Some code blocks are not closed"))
    return txts, codes
end

"""
    mds2temp( filesin::AbstractVector{<:AbstractString}
            , excel::AbstractString="temp.xlsx"
            , code::AbstractString="temp.txt")

Convert markdown files to tow files: `excel` and `code`.

Here `excel` is the part we need to translate, and `code` stores the code blocks.
"""
function mds2temp( filesin::AbstractVector{<:AbstractString}
                 ; excel::AbstractString="temp.xlsx"
                 , code::AbstractString="temp.txt")
    all(endswith(".md"), filesin) || throw(ArgumentError("Only markdown files are allowed"))
    alltxts = Vector{Vector{String}}(undef, length(filesin))
    open(code, "w") do io
        for (i, file) in enumerate(filesin)
            alltxts[i], codes = splitMDtext(read(file, String))
            println.(Ref(io), codes)
        end
    end
    matsize = maximum(length, alltxts)
    txtmat = fill("", matsize, length(filesin)) # should not use `Matrix{String}(undef,...)` here!!
    for (i, txts) in enumerate(alltxts)
        txtmat[1:length(txts), i] = txts # each column is a file
    end
    write_xlsx(excel, txtmat)
    return "output files: $excel, $code"
end
mds2temp( filein::AbstractString
        ; excel::AbstractString="temp.xlsx"
        , code::AbstractString="temp.txt") = mds2temp([filein]; excel=excel, code=code)


"""
    getcodes(txt::AbstractString)

Get the code blocks from `txt`.
"""
getcodes(txt::AbstractString) = [m.match for m in eachmatch(r"```\w*[\s\S]*?```", txt)]

"""
    temp2mds( files::AbstractVector{<:AbstractString}
            , code::AbstractString="temp.txt"
            , excel::AbstractString="temp.xlsx")

Recover markdown files from temp files.
"""
function temp2mds( excel::AbstractString
                 , code::AbstractString
                 , filesout::AbstractVector{<:AbstractString})
    all(endswith(".md"), filesout) || throw(ArgumentError("Only markdown files are allowed"))
    codes = getcodes(read(code, String))
    txtmat = read_xlsx(excel)
    startind = 1
    for (i, file) in enumerate(filesout)
        open(file, "w") do io
            txts = @view(txtmat[:, i])
            codeinds = txts .== "`C`"
            stopind = startind + sum(codeinds) - 1
            txts[codeinds] .= @view codes[startind:stopind]
            println.(Ref(io), txts, '\n')
            startind = stopind + 1
        end
    end
    return "output files: $(join(filesout, ", "))"
end
temp2mds( excel::AbstractString
        , code::AbstractString
        , fileout::AbstractString) = temp2mds(excel, code, [fileout])


function temp2mixmds( filesout::AbstractVector{<:AbstractString}
                    , excelraw::AbstractString
                    , exceltr::AbstractString
                    ; code::AbstractString="temp.txt")
    all(endswith(".md"), filesout) || throw(ArgumentError("Only markdown files are allowed"))
    codes = getcodes(read(code, String))
    codeind = 1
    txtmat, txtmattr = read_xlsx(excelraw), read_xlsx(exceltr)
    for (i, file) in enumerate(filesout) # enumerate over each file
        open(file, "w") do io
            for (txt, txttr) in @views zip(txtmat[:, i], txtmattr[:, i])
                if txt == "`C`"
                    println(io, codes[codeind], '\n')
                    codeind += 1
                else
                    println(io, txt, '\n')
                    println(io, strip(txttr), '\n')
                end
            end
        end
    end
    return "output files:\n$(join(filesout, "\n"))"
end
temp2mixmds( file::AbstractString
           , excelraw::AbstractString
           , exceltr::AbstractString
           ; code::AbstractString="temp.txt") = temp2mixmds([file], excelraw, exceltr; code=code)