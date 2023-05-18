#################################
# fromwaf_mmap
#################################

fromwaf_mmap(fname; ro=false, forcename=false) = loadwaf(fname; ro, forcename)

#################################
# fromwaf_nommap
#################################

fromwaf_nomap(fname; outtype=nothing, slice=nothing, forcename=false) = begin
    if isa(slice, Integer)
        m = fromwaf(fname; outtype, forcename, slice=slice:slice)
        return dropdims(m; dims=ndims(m))
    end

    open(_force_ext(fname, "waf", forcename)) do f
        tp = typeidx_type(read(f, UInt16))
        dim = read(f, UInt16)
        shape = reverse([read(f, UInt32) for i ∈ 1:dim]) | Tuple
        nbyte = sizeof(tp)
        offset = 2 + 2 + 4dim
        (offset % nbyte != 0) && skip(f, nbyte - offset % nbyte)

        if isnothing(slice)
            array_from_fstream(f, shape...; intype=tp, outtype=outtype)
        else
            skip(f, sizeof(tp) * reduce((*), shape[1:end-1], init=1) * (slice.start - 1))
            array_from_fstream(f, shape[1:end-1]..., length(slice);
                               intype=tp, outtype=outtype)
        end
    end
end

#################################
# fromwaf
#################################

"""
    fromwaf(fname; mmap=true, ro=false, outtype=nothing, slice=nothing, forcename=false)

    load an array from waf file
    return: an array from a waf file
"""
fromwaf(fname; mmap=true, ro=false, outtype=nothing, slice=nothing, forcename=false) =
begin
    if toBool(mmap)
        fromwaf_mmap(fname; ro, forcename)
    else
        fromwaf_nomap(fname; outtype, slice, forcename)
    end
end

