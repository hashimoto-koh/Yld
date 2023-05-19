#################################
# loadwaf
#################################

"""
    loadwaf(fname, T, shape; init=nothing, forcename=false)

    create & load waf file
    args:
        fname: filename [String]
        T: data type
        shape: size of array [Tuple or Intger(for 1-dim)]
        init: value or function
    return: an array
"""
loadwaf(fname::AbstractString, T::DataType, shape::Tuple; init=nothing, forcename=false) =
begin
    # open file
    f = open(_force_ext(fname, "waf", forcename), "w+")

    # write header
    writehead(f, T, shape)
    # create mmap
    m = Mmap.mmap(f, Array{T,length(shape)}, Int.(shape))

    # close file
    close(f)

    # init
    if !isnothing(init)
        if isa(init, Function)
            init(m)
        else
            m .= init
        end
    end

    m
end

loadwaf(fname::AbstractString, T::DataType, shape::Integer; init=nothing, forcename=false) =
    loadwaf(fname, T, (shape,); init, forcename)

loadwaf(initfunc::Function,
        fname::AbstractString,
        T::DataType,
        shape::Union{Tuple, Integer};
        forcename=false) =
    loadwaf(fname, T, shape; init=initfunc, forcename)

"""
    loadwaf(fname; ro=false, forcename=false)

    load an existing waf file
    args:
        fname: filename (String)
        ro: read only (default) or writable
    return: an array
"""
loadwaf(fname::AbstractString; init=nothing, ro=false, forcename=false) = begin
    f = open(_force_ext(fname, "waf", forcename),
             toBool(ro) ? "r" : "r+")

    (;tp, dim, shape, offset) = readhead(f)
    m = Mmap.mmap(f, Array{tp, dim}, shape)
    close(f)

    if !isnothing(init)
        if isa(init, Function)
            init(m)
        else
            m .= init
        end
    end

    m
end

loadwaf(initfunc::Function, fname::AbstractString; ro=false, forcename=false) =
    loadwaf(fname; ro, forcename, init=initfunc)

