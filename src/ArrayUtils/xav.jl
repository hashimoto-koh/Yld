"""
    xaview(a::AbstractArray, i::Tuple{Vararg{<:Integer}})
    xaview(a::AbstractArray, i::AbstractRange) views(a,Tuple(i))
    xaview(a::AbstractArray, i::Integer...) views(a,i)

an array of views on the axes which are the rest of the specified axies
"""
xav(a::AbstractArray, i::Tuple{Vararg{<:Integer}}) =
    axv(a, tuple(sort(collect(Base.setdiff(Set(Base.OneTo(ndims(a))), Set(i))))...))

xav(a::AbstractArray, i::AbstractRange) = xav(a, Tuple(i))

xav(a::AbstractArray, i::Integer...) = xav(a, i)

xav(i::Union{Tuple{Vararg{<:Integer}}, AbstractRange}) = a -> xav(a, i)

xav(i::Integer...) = a -> xav(a, i)
