###############################
# addaxis
###############################

"""
    addaxis(m::AbstractArray, a::Integer...)
    addaxis(m::AbstractArray, a::Tuple)

Add newaxes into an array

# Examples
```jldoctest
julia> zeros(3,4,5) | addaxis(m, 2, 4) | size
(3, 1, 4, 1, 5)

julia> zeros(3,4,5) | addaxis(m, (2, -2)) | size
(3, 1, 4, 1, 5)

julia> zeros(3,4,5) | addaxis(2, -2) | size
(3, 1, 4, 1, 5)
```
"""
addaxis(m::AbstractArray, a::Integer...) =
    reshape(m,
            let
                l = ndims(m) + length(a)
                a = Set(x >= 0 ? x : l+1+x for x in a)
                any(x <= 0 || x > l for x in a) && error("invalid axis indices!")
                n = zeros(Int64, ndims(m) + length(a))
                for i in a
                    n[i] = 1
                end
                k = 1
                for i in size(m)
                    while n[k] != 0; k += 1; end
                    n[k] = i;
                end
                tuple(n...)
            end)

addaxis(m::AbstractArray, a::Tuple) = addaxis(m, a...)
