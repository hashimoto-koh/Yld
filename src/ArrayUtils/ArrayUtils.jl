module ArrayUtils

include("axv.jl")
export axv

include("idxmacro.jl")
export @lx, @lv, @rx, @rv, @idx, @idv

include("operator.jl")
export ⊕, ⊗

include("rshp.jl")
export rshp, rrshp, lrshp

end
