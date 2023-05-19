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
        (;tp, dim, shape, offset) = readhead(f)
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
    toBool(mmap) ?
        fromwaf_mmap(fname; ro, forcename) :
        fromwaf_nomap(fname; outtype, slice, forcename)

