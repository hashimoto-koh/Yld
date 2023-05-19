###############################
# arg
###############################

struct _Args{A,KA} <: Function
    a::A
    ka::KA
end
@inline (a::_Args)(f) = functionize(f)(a.a...; a.ka...)

@inline arg(a...; ka...) = _Args(a, ka)
