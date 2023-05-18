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
        eltype = typeidx_type(read(f, UInt16))
        ndims = Int(read(f, UInt16))
        size = reverse([Int(read(f, UInt32)) for i ∈ 1:ndims])
        offset = 2 + 2 + 4ndims
        nbyte = sizeof(eltype)
        offset = (offset % nbyte == 0) ? offset : nbyte * (offset ÷ nbyte + 1)
        (; eltype, ndims, size, offset)
    end
