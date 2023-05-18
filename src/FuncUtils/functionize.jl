@inline functionize(f::Function) = f

@inline functionize(s::Symbol) = o -> Base.getproperty(o, s)

@inline functionize(s::Union{Tuple, AbstractArray, Base.Generator, Base.ValueIterator}) =
    (a...; ka...) -> map(f->functionize(f)(a...; ka...), s)

