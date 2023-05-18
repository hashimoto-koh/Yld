#################################
# helper
#################################

_correct_dim(i::Integer, n::Integer) =
begin
    # -1 => n, -2 => n-1, 0 => n+1 => 1
    i < 1 && (return _correct_dim(i+n+1, n))
    # n+1 => 1, n+2 => 2
    i > n && (return _correct_dim(i-n, n))
    Int(i)
end

###############################
# axv
###############################

"""
    axv(a::AbstractArray, i::Tuple{Vararg{<:Integer}})
    axv(a::AbstractArray, i::AbstractRange) views(a,Tuple(i))
    axv(a::AbstractArray, i::Integer...) views(a,i)

an array of views on the specified axes
"""
#=
axv(a::AbstractArray, i::Integer) = begin
    (i > 0) && (return eachslice(m; dims=i))
    (i == 0) && (return vec(a))
    return axv(a; dims=ndims(a)+1+i)
end
=#

"""
    axv(a::AbstractArray, i::Integer)
    axv(a::AbstractArray, i::Tuple)
    axv(a::AbstractArray, i::Integer...)
    axv(a::AbstractArray, i::AbstractRange)

an array of views on the specified axes
# Examples
```
julia-repl
julia> [1 2; 3 4; 5 6] |> axview[-1]
2-element Vector{SubArray{Int64, 1, Matrix{Int64}, Tuple{Base.Slice{Base.OneTo{Int64}}, Int64}, true}}:
 [1, 3, 5]
 [2, 4, 6]
 ```
 """
axv(a::AbstractArray, i::Integer) = eachslice(a; dims=_correct_dim(i, ndims(a)))

axv(a::AbstractArray, i::Tuple{Vararg{<:Integer}}) =
begin
    ii = _correct_dim.(i, ndims(a))
    t0 = Vector{Union{Colon, Int}}(fill(:, ndims(a)))
    I = [ii...]
    [(t = t0[:]; t[I] = [j...]; view(a,t...))
        for j in Iterators.product(Tuple(Base.OneTo(size(a,x)) for x in ii)...)]
end

axv(a::AbstractArray, i::AbstractRange) = axv(a, Tuple(i))

axv(a::AbstractArray, i::Integer...) = axview(a, i)

axv(i::Union{Integer, Tuple{Vararg{<:Integer}}, AbstractRange}) = a -> axv(a, i)

axv(i::Integer...) = a -> axv(a, i)
