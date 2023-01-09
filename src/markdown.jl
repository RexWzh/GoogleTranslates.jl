"""
    splitMDtext(text::AbstractString)

Split a markdown text into a list of markdown blocks.
"""
function splitMDtext(text::AbstractString)
    lines = split(text, '\n')
    txts, codes = String[], String[]
    
    incode = false
    for line in lines
        if startswith(line, r"\s*```")
            incode = !incode
            if incode # start a new code block
                push!(codes, "\n" * line)
                push!(txts, "`C`") # mark the code block
            else
                codes[end] *= "\n" * line
            end
        elseif incode
            codes[end] *= "\n" * line
        elseif !isempty(line) # skip empty lines
            push!(txts, line)
        end
    end
    incode && throw(ArgumentError("Some code blocks are not closed"))
    return txts, codes
end

"""
    mds2temp( filesin::AbstractVector{<:AbstractString}
            , excel::AbstractString="temp.xlsx"
            , info::AbstractString="temp.txt")

Convert markdown files to temp files.
"""
function mds2temp( filesin::AbstractVector{<:AbstractString}
                 ; excel::AbstractString="temp.xlsx"
                 , info::AbstractString="temp.txt")
    all(endswith(".md"), filesin) || throw(ArgumentError("Only markdown files are allowed"))
    alltxts = Vector{Vector{String}}(undef, length(filesin))
    infoio = open(info, "w")
    for (i, file) in enumerate(filesin)
        alltxts[i], codes = splitMDtext(read(file, String))
        println.(Ref(infoio), codes)
    end
    close(infoio)
    matsize = maximum(length, alltxts)
    txtmat = fill("", matsize, length(filesin))
    for (i, txts) in enumerate(alltxts)
        txtmat[1:length(txts), i] = txts
    end
    write_xlsx(excel, txtmat)
    return "output files: $excel, $info"
end
mds2temp( filein::AbstractString
        ; excel::AbstractString="temp.xlsx"
        , info::AbstractString="temp.txt") = mds2temp([filein]; excel=excel, info=info)


"""
    getcodes(txt::AbstractString)

Get the code blocks from `txt`.
"""
getcodes(txt::AbstractString) = split(strip(txt), "\n\n")

"""
    temp2mds( files::AbstractVector{<:AbstractString}
            , info::AbstractString="temp.txt"
            , excel::AbstractString="temp.xlsx")

Recover markdown files from temp files.
"""
function temp2mds( excel::AbstractString
                 , info::AbstractString
                 , filesout::AbstractVector{<:AbstractString})
    all(endswith(".md"), filesout) || throw(ArgumentError("Only markdown files are allowed"))
    codes = getcodes(read(info, String))
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
        , info::AbstractString
        , fileout::AbstractString) = temp2mds(excel, info, [fileout])


function temp2mixmds( filesout::AbstractVector{<:AbstractString}
                    , excelraw::AbstractString
                    , exceltr::AbstractString
                    ; info::AbstractString)
    all(endswith(".md"), filesout) || throw(ArgumentError("Only markdown files are allowed"))
    codes = getcodes(read(info, String))
    txtmat, txtmattr = read_xlsx(excelraw), read_xlsx(exceltr)
    for (i, file) in enumerate(filesout)
        open(file, "w") do io
            for (txt, txttr) in @views zip(txtmat[:, i], txtmattr[:, i])
                if txt == "`C`"
                    println(io, codes, '\n')
                else
                    println(io, txt, '\n')
                    println(io, strip(txttr), '\n')
                end
            end
        end
    end
    return "output files: $(join(filesout, ", "))"
end
temp2mixmds( file::AbstractString
           , excelraw::AbstractString
           , exceltr::AbstractString
           ; info::AbstractString="temp.txt") = temp2mixmds([file], excelraw, exceltr; info=info)