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
    write(f,
          type_typeidx(T),
          UInt16(length(shape)),
          UInt32.(reverse(shape))...)
    offset = 2 + 2 + 4 * length(shape)
    nbyte = sizeof(T)
    (offset % nbyte != 0) && [write(f, '0') for _ in 1:(nbyte-offset%nbyte)]

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

    tp = typeidx_type(read(f, UInt16))
    dim = Int(read(f, UInt16))
    shape = reverse(Tuple(Int(read(f, UInt32)) for i ∈ 1:dim))
    offset = let
        o = 2 + 2 + 4dim
        nbyte = sizeof(tp)
        (o % nbyte == 0) ? 0 : nbyte - o % nbyte
    end
    skip(f, offset)
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

