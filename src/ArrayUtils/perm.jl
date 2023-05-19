###############################
# perm
###############################

"""
    perm(m::AbstractArray, i::Union{Tuple, AbstractVector})
    perm(m::AbstractArray, i::Integer...)

permutedims

```
julia> m = (1:120) |> reshape[2,3,4,5];

julia> perm(m, 4,3,2,1) |> size
(5, 4, 3, 2)
```
"""
perm(m::AbstractArray, dims::Union{Tuple, AbstractVector}) = permutedims(m, dims)

perm(m::AbstractArray, dim::Integer...) = perm(m, (dim1,dims...))

#################################
# permary
#################################

"""
    permary(m::AbstractArray, i::Union{Tuple, AbstractVector})
    permary(m::AbstractArray, i::Integer...)

PermutedDimsArray

```
julia> m = (1:120) |> reshape[2,3,4,5];

julia> permary(m, 4,3,2,1) |> size
(5, 4, 3, 2)
```
"""
permary(m::AbstractArray, dims::Union{Tuple, AbstractVector}) = PermutedDimsArray(m, dims)

permary(m::AbstractArray, dim::Integer...) = permary(m, (dim,dims...))
