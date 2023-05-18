const tp = Base.typeof
const prl = Base.println
const len = Base.length
const adj = Base.adjoint
const trs = Base.transpose
const agl = Base.angle
const dsp = Base.display
const ary = Base.collect
const shape = Base.size
const oneto = Base.OneTo

dir(x) = fieldnames(typeof(x))


struct astp{T} <: Function end
astp{T}(m::AbstractArray{T}) where T = m
astp{T}(m::AbstractArray{U,N}) where {T, U, N} = convert(Array{T,N}, m)
astp{T}(x::T) where T = x
astp{T}(x::U) where {T,U} = convert(T, x);
asf4(x) = astp{Float32}(x)
asf8(x) = astp{Float64}(x)

astype(m::AbstractArray, t::Type) = astp{t}(m)
astype(x, t::Type) = astp{t}(x)
astype(x, y) = astype(x, eltype(y))
astype(x, m::AbstractArray) = astype(x, eltype(m))
astype(T::Type) = x -> astype(x, T)
astype(x) = T -> astype(x, T)

dtype(itr) = eltype(itr)
dtype(itr::Base.Generator) = Base.return_types(itr.f, (dtype(itr.iter),))[1]
