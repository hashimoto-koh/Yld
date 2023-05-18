#################################
# towaf
#################################

"""
    towaf(a::AbstractArray, fname::AbstractString; outtype=nothing, forcename=false)

    save an array to waf file
"""
towaf(a::AbstractArray, fname::AbstractString; outtype=nothing, forcename=false) =
begin
    loadwaf(fname, isnothing(outtype) ? eltype(a) : outtype, size(a); forcename) do m
        m[ntuple(_->(:), ndims(a))...] = a
    end
    nothing
end
    # open(_force_ext(fname, "waf", forcename), "w") do f
    #     otype = isnothing(outtype) ? eltype(a) : outtype
    #     write(f,
    #           type_typeidx(otype),
    #           UInt16(ndims(a)),
    #           UInt32.(reverse(size(a)))...)
    #     offset = 2 + 2 + 4 * ndims(a)
    #     nbyte = sizeof(otype)
    #     (offset % nbyte != 0) && [write(f, '0') for _ in 1:(nbyte-offset%nbyte)]
    #     array_to_fstream(a, f; outtype=otype)
    # end
