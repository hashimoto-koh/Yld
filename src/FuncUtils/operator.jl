#################################
# functionize
#################################

Base.:|>(x, f) = functionize(f)(x)

Base.:|(x, f) = functionize(f)(x)

Base.:/(f, g) = functionize(g) ∘ functionize(f)

Base.:~(f) = functionalize(f)
Base.:-(f) = a -> functionalize(f)(a...)
Base.:+(f) = a -> functionalize(f).(a)
