import Mmap

#################################
# info
# to
# from
#################################

InfoUtils.info(::Val{:waf}, file::AbstractString; ka...) = waf_info(fname)

to(::Val{:waf}, m::AbstractArray, file::AbstractString; ka...) = towaf(m, file; ka...)

from(::Val{:waf}, file::AbstractString; ka...) = fromwaf(file; ka...)


include("waf/waf_info.jl")

include("waf/towaf.jl")

include("waf/fromwaf.jl")

include("waf/loadwaf.jl")

include("waf/linktowaf.jl")
