module MathUtils

include("basicfunc.jl")
export mean, wmean
export mean0
export lpadint, square, cube, norm

include("gf.jl")
export gf

include("mf.jl")
export mf

include("mfl.jl")
export mfl

include("log0.jl")
export log0

end
