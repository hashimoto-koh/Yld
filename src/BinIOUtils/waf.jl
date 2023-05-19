import Mmap

#################################
# info
# to
# from
#################################

InfoUtils.info(::Val{:waf}, file::AbstractString) = waf_info(fname)

to(::Val{:waf}, m::AbstractArray, file::AbstractString; outtype=nothing) =
    towaf(m, file; outtype)

from(::Val{:waf}, file::AbstractString;
     mmap=true, ro=false, outtype=nothing, slice=nothing) =
    fromwaf(file; mmap, ro, outtype, slice)


include("waf/head.jl")

include("waf/waf_info.jl")

include("waf/towaf.jl")

include("waf/fromwaf.jl")

include("waf/loadwaf.jl")
export loadwaf

include("waf/linktowaf.jl")
