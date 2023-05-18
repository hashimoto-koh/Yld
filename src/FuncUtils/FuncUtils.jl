module FuncUtils

include("functionize.jl")

include("operator.jl")
export infix_func, dot

include("pipetags.jl")
export wt, wm

include("primaryfuncs.jl")
export cstf, idf

include("getindex.jl")

include("funcaliases.jl")
export tp, prl, len, adj, trs, agl, dsp, ary, shape, oneto
export dir
export astp, asf4, asf8, astype
export dtype

include("exe.jl")
export exe

end
