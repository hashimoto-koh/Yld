#################################
# mean
#################################

import Statistics: mean

#################################
# wmean
#################################

wmean(m::AbstractArray; dims=nothing) =
begin
    isnothing(dims) && (return mean(m))
    isa(dims, Integer) && (return wmean(m; dims=(dims,)))
    Base.dropdims(mean(m; dims); dims)
end

#################################
# lpadint
#################################
"""
    lpadint(x::Integer, d::Integer)

Return a string with d-digits number padding with 0.

# Examples
```
julia> lpadint(13,4) == "0013"
true

```
"""
lpadint(x::Integer, d::Integer) = lpad(string(x), d, "0")

#################################
# square, cube
#################################

square(x)= x * x
cube(x) = x * x * x

#################################
# norm
#################################

norm(v, p=2) = begin
    p == 2 && (return sqrt(sum(square.(v))))
    p == 1 && (return sum(abs.(v)))
    p == 0 && (return count(!=(0), v))
    p == Inf && (return maximum(abs.(v)))
    sum(abx(x)^p for x ∈ v)^(1/p)
end
