module LoopUtils

include("torng.jl")
export to_rng

include("loop.jl")
export loop_range, loop_ranges, to_rng
export  loop,  coop,  ploop,  pcoop
export sloop, scoop, psloop, pscoop
export tloop, tcoop, ptloop, ptcoop
export uloop, ucoop, puloop, pucoop

include("colgen.jl")
export fgen, colgen, mtx

include("fary.jl")
export fary, tfary

include("operator.jl")
export ⊞
export ⩅, ⋓, ⩐, ⩏, ⊔, ⩣, ⩢, ⩖, ⩒

include("prgrsbar.jl")
export prgrsbar, pgbar

end
