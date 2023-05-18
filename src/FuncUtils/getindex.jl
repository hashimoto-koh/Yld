###############################
# function index
###############################
#=
f[a, b, c, d=xx, e=yyy](p,q,r) = f(p,q,r,a,b,c; d=xx, e=yyy)
(b,c) | -f[](a) = f(a,b,c)
(b,c) | -f[](a)[d] = f(a,b,c,d)
=#

Base.getindex(f::Function, a...; ka...) = (b...; kb...) -> f(b..., a...; ka..., kb...)
Base.getindex(f::Function) = (a...; ka...) -> ((b...; kb...) -> f(a..., b...; ka..., kb...))
