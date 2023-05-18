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
