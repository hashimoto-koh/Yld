import EllipsisNotation

Base.reshape(m::AbstractArray, ::EllipsisNotation.Ellipsis, i::Integer...) =
    rrshp(m, reverse(i)...)

Base.reshape(m::AbstractArray, i::Vararg{Union{Integer,EllipsisNotation.Ellipsis}}) =
    lrshp(m, i...)

rshp(m::AbstractArray, i...) = Base.reshape(m, i...)

lrshp(i::Vararg{Union{Integer,EllipsisNotation.Ellipsis, Colon}}) =
    m -> lrshp(m, i...)

rrshp(i::Vararg{Union{Integer,EllipsisNotation.Ellipsis, Colon}}) =
    m -> rrshp(m, i...)

lrshp(m::AbstractArray, i::Vararg{Union{Integer,Colon}}) = reshape(m, i...)

rrshp(m::AbstractArray, i::Vararg{Union{Integer,Colon}}) = reshape(m, reverse(i)...)

lrshp(m::AbstractArray, i::Vararg{Union{Integer,EllipsisNotation.Ellipsis}}) =
begin
    count(==(..), i) != 1 && error("invalid use of ..")

    i[end] == (..) && return (lrshp(m, i[1:end-1]...))

    elp = findfirst(==(..), i)
    i1, i2 = i[1:elp-1], i[elp+1:end]
    n1, n2 = (*)(i1...), (*)(i2...)
    p1 = findfirst(==(n1), accumulate(*, size(m)))
    p2 = findfirst(==(n2), accumulate(*, reverse(size(m))))

    ((isnothing(p1) || isnothing(p2))
     ? reshape(m, i1..., :, i2...)
     : reshape(m, i1..., size(m)[p1+1:ndims(m)-p2]..., i2...))
end

rrshp(m::AbstractArray, i::Vararg{Union{Integer,EllipsisNotation.Ellipsis}}) =
begin
    count(==(..), i) != 1 && error("invalid use of ..")

    i[end] == (..) && return (rrshp(m, i[1:end-1]...))

    elp = findfirst(==(..), i)
    i2, i1 = reverse(i[1:elp-1]), reverse(i[elp+1:end])
    n1, n2 = (*)(i1...), (*)(i2...)
    p1 = findfirst(==(n1), accumulate(*, size(m)))
    p2 = findfirst(==(n2), accumulate(*, reverse(size(m))))

    ((isnothing(p1) || isnothing(p2))
     ? reshape(m, i1..., :, i2...)
     : reshape(m, i1..., size(m)[p1+1:ndims(m)-p2]..., i2...))
end

lrshp(m::AbstractArray, ::EllipsisNotation.Ellipsis, i::Vararg{Integer}) =
    rrshp(m, reverse(i[2:end])...)

rrshp(m::AbstractArray, ::EllipsisNotation.Ellipsis, i::Vararg{Integer}) =
    lrshp(m, reverse(i[2:end])...)

lrshp(m::AbstractArray, i::Vararg{Integer}) =
begin
    p = findfirst(==((*)(i...)), accumulate(*, size(m)))
    (isnothing(p)
     ? reshape(m, i..., :)
     : reshape(m, i..., size(m)[p+1:end]...))
end

rrshp(m::AbstractArray, i::Vararg{Integer}) =
begin
    p = findfirst(==((*)(i...)), accumulate(*, reverse(size(m))))
    (isnothing(p)
     ? reshape(m, :, reverse(i)...)
     : reshape(m, size(m)[1:ndims(m)-p]..., reverse(i)...))
end

