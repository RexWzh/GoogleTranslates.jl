#! /usr/bin/env julia18
# author: RexWzh
# date: 2022-01-11
# description: translate markdown using Google Translate
# usage: julia translate.jl -s <source path> -t <target path> -p <temp path> -e <excel file> -c <code file> -r <translated excel file> -d <debug mode>

# using Pkg; Pkg.add("GoogleTranslates"); Pkg.add("ArgParse")
using GoogleTranslates
using ArgParse

# parse arguments
s = ArgParseSettings()
@add_arg_table! s begin
    "--source", "-s"
        arg_type = String
        help = "source path"
    "--target", "-t"
        arg_type = String
        help = "target path"
    "--temp", "-p"
        arg_type = String
        help = "temp path"
        default = (@__DIR__) * "/tempfile"
    "--excel", "-e"
        arg_type = String
        help = "excel file that should be translated"
    "--code", "-c"
        arg_type = String
        help = "store codes(```) in a file"
    "--exceltr", "-r"
        arg_type = String
        help = "translated excel file"
    "--debug", "-d"
        help = "debug mode"
        action = :store_true
end
args = parse_args(ARGS, s)
if isnothing(args["excel"])
    args["excel"] = joinpath(args["temp"], "temp.xlsx")
end
if isnothing(args["code"])
    args["code"] = joinpath(args["temp"], "temp.txt")
end
if isnothing(args["exceltr"])
    args["exceltr"] = joinpath(args["temp"], "temp_tr.xlsx")
end
if isnothing(args["target"])
    filename = splitdir(args["source"])[end]
    args["target"] = joinpath(splitdir(args["source"])[1:end-1]..., filename * "_tr")
end

#= Arg debug
for (key, val) in args
    println(key, " => ", val)
end
exit()
=#

# translate markdown files
mkpath.([args["target"], args["temp"]])
translatepath = args["source"]
translatepath_tr = args["target"]
tmpfilepath = args["temp"]
files = filter!(endswith(".md"), readdir(translatepath))
filein = joinpath.(translatepath, files)
fileout = joinpath.(translatepath_tr, files)
excel = args["excel"]
code = args["code"]
exceltr = joinpath(tmpfilepath, "temp_tr.xlsx")

mds2temp(filein, excel=excel, code=code)

println("Please translate the excel file:\n\t$excel\n\nlink: https://translate.google.com/?sl=auto&tl=en&op=docs\n")
println("Then place the translated file here:\n\t$exceltr\n")

if args["debug"]
    println("Debug mode: treat the source file as translated.\n")
    cp(excel, exceltr, force=true)
else
    println("Press Enter to continue after placing the file.")
    readline() # wait for translation
end

println(temp2mixmds(fileout, excel, exceltr;code=code))