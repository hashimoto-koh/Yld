module LoopUtils

include("loop.jl")
export loop_range, loop_ranges, to_rng
export  loop,  coop,  ploop,  pcoop
export sloop, scoop, psloop, pscoop
export tloop, tcoop, ptloop, ptcoop
export uloop, ucoop, puloop, pucoop

include("colgen.jl")
export fgen, colgen, mtx

include("operator.jl")
export ⊞
export ⩅, ⋓, ⩐, ⩏, ⊔, ⩣, ⩢, ⩖, ⩒

end
