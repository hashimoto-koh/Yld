#################################
# Base.:/(p1::AbstractString, p2::AbstractString)
#################################

Base.:/(p1::AbstractString, p2::AbstractString) =
begin
    !isempty(p1) && p1[end] == '/' && (return p1[1:end-1] / p2)
    !isempty(p2) && p2[begin] == '/' && (return p1 / p2[begin+1:end])
    isempty(p1) ?
        (isempty(p2) ? "./" : p2) :
        Base.Filesystem.expanduser(p1) * p2
end

#################################
# Base.:%(p1::AbstractString, p2::AbstractString)
#################################

Base.:%(p1::AbstractString, p2::AbstractString) = glob(p1, isempty(p2) ? nothing : p2)

###############################
# glob
###############################

import Glob

"""
    glob(dir="./", pat=nothing)

Return a list of files in dir with patttern 'pat'

# Examples
```
julia> glob("/home/jov/", "*top")
1-element Vector{String}:
 "/home/jov/Desktop"

julia> glob("/home/jov/jupyter", "*ipynb")
3-element Vector{String}:
 "/home/jov/@home/jupyter/Untitled-1.ipynb"
 "/home/jov/@home/jupyter/Untitled.ipynb"
 "/home/jov/@home/jupyter/Untitled1.ipynb"
```
"""
glob(dir="./", pat=nothing) = Glob.glob(isnothing(pat) ? "*" : pat, Base.Filesystem.expanduser(dir))

"""
    glob"XXX"

# Examples
```
julia> glob"/Users/koh/Desktop" == glob("/Users/koh/Desktop")
true
```
"""
macro glob_str(s)
    return esc(:(wlib.glob($s)))
end
