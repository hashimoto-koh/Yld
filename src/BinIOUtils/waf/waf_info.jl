#################################
# waf_info
#################################

"""
    waf_info(fname; forcename=false)

    provides information about the waf file
    return: an namedTuple (;eltype, ndims, size, offset)
"""
waf_info(fname; forcename=false) =
    open(_force_ext(fname, "waf", forcename), "r") do f
        (;tp, dim, shape, offset) = readhead(f)
        (;eltype=tp, ndims=dim, size=shape, offset)
    end
