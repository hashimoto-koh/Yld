module ArrayUtils

include("axv.jl")
export axv

include("xav.jl")
export xav

include("idxmacro.jl")
export @lx, @lv, @rx, @rv, @idx, @idv

include("operator.jl")
export ⊕, ⊗, ×

include("rshp.jl")
export rshp, rrshp, lrshp

include("uary.jl")
export uary

include("vary.jl")
export vary

include("newaxis.jl")
export newaxis

include("addaxis.jl")
export addaxis

include("like.jl")
export  fill_like, zeros_like, ones_like, empty_like

end
