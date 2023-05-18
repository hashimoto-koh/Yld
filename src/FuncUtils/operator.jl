#################################
# functionize
#################################

Base.:|>(x, f::Symbol) = x |> functionize(f)

Base.:|>(x, f::Union{Tuple, AbstractArray, Base.Generator, Base.ValueIterator}) = x |> functionize(f)

Base.:|(x, f) = functionize(f)(x)

Base.:/(f, g) = functionize(g) ∘ functionize(f)

Base.:~(f) = functionalize(f)

Base.:-(f) = a -> functionalize(f)(a...)

Base.:+(f) = a -> functionalize(f).(a)

###############################
# infix_func
###############################

struct infix_func{T} <: Function
    f::T
 end
(f::infix_func)(a...; ka...) = f.f(a...; ka...)
Base.:|>(a, f::infix_func) = infix_func(b -> f.f(a,b))
Base.:|>(f::infix_func, fnc) = f.f(fnc)
Base.:|(a, f::infix_func) = infix_func(b -> f.f(a,b))
Base.:|(f::infix_func, fnc) = f.f(fnc)

# ((1:10), (2:2:20)) |dot(.+)|  (1,2) == (2:11, 4:2:22)
dot(f) = infix_func((x,y) -> f.(x,y))
