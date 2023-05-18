module MathUtils

include("basicfunc.jl")
export mean, wmean
export mean0
export lpadint, square, cube, norm

include("gf.jl")
export gf

include("mf.jl")
export mf

end
