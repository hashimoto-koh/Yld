log0(x::Real) = (x > 0) ? log(x) : log(one(x))

log0(x::AbstractArray{<:Real}) = log0.(x)

log0(x::Real, y::Real) =
    (x > 0 && y > 0) ?
    log(x) - log(y) :
    log(one(Base.promote_typeof(x, y)))

log0(x::AbstractArray, y::AbstractArray) =
begin
    i = (x .> 0) .&& (y .> 0)
    m = zeros(Float32, size(x))
    m[i] = log.(x[i] ./ y[i])
    m
end
