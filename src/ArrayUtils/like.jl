fill_like(m::AbstractArray, x) = Base.fill(x, size(m))
zeros_like(m::AbstractArray) = zeros(eltype(m), size(m))
ones_like(m::AbstractArray) = ones(eltype(m), size(m))
empty_like(m::AbstractArray) = Array{eltype(m), ndims(m)}(undef, size(m))
