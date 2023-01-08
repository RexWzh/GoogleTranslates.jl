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
    mds2temp( files::AbstractVector{<:AbstractString}
            , excel::AbstractString="temp.xlsx"
            , info::AbstractString="temp.txt")

Convert markdown files to temp files.
"""
function mds2temp( files::AbstractVector{<:AbstractString}
                 , excel::AbstractString="temp.xlsx"
                 , info::AbstractString="temp.txt")
    alltxts = Vector{Vector{String}}(undef, length(files))
    infoio = open(info, "w")
    for (i, file) in enumerate(files)
        alltxts[i], codes = splitMDtext(read(file, String))
        println.(Ref(infoio), codes)
    end
    close(infoio)
    matsize = maximum(length, alltxts)
    txtmat = fill("", matsize, length(files))
    for (i, txts) in enumerate(alltxts)
        txtmat[1:length(txts), i] = txts
    end
    write_xlsx(excel, txtmat)
    return "output files: $excel, $info"
end
mds2temp(file::AbstractString) = mds2temp([file])

"""
    getcodes(txt::AbstractString)

Get the code blocks from `txt`.
"""
getcodes(txt::AbstractString) = split(strip(txt), "\n\n")