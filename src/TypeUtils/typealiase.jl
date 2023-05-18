###############################
# type aliases
###############################

const C2, C4, C8 = ComplexF16, ComplexF32, ComplexF64
const F2, F4, F8 = Float16, Float32, Float64
const I1, I2, I4, I8 = Int8, Int16, Int32, Int64
const U1, U2, U4, U8 = UInt8, UInt16, UInt32, UInt64
const VC2, VC4, VC8 = Vector{C2}, Vector{C4}, Vector{C8}
const VF2, VF4, VF8 = Vector{F2}, Vector{F4}, Vector{F8}
const VI1, VI2, VI4, VI8 = Vector{I1}, Vector{I2}, Vector{I4}, Vector{I8}
const VU1, VU2, VU4, VU8 = Vector{U1}, Vector{U2}, Vector{U4}, Vector{U8}
const MC2, MC4, MC8 = Matrix{C2}, Matrix{C4}, Matrix{C8}
const MF2, MF4, MF8 = Matrix{F2}, Matrix{F4}, Matrix{F8}
const MI1, MI2, MI4, MI8 = Matrix{I1}, Matrix{I2}, Matrix{I4}, Matrix{I8}
const MU1, MU2, MU4, MU8 = Matrix{U1}, Matrix{U2}, Matrix{U4}, Matrix{U8}
A3{T} = Array{T,3}
A4{T} = Array{T,4}
A5{T} = Array{T,5}
const AC2, AC4, AC8 = Array{C2}, Array{C4}, Array{C8}
const AF2, AF4, AF8 = Array{F2}, Array{F4}, Array{F8}
const AI1, AI2, AI4, AI8 = Array{I1}, Array{I2}, Array{I4}, Array{I8}
const AU1, AU2, AU4, AU8 = Array{U1}, Array{U2}, Array{U4}, Array{U8}

const VC = AbstractVector{T} where T <: Complex
const VF = AbstractVector{T} where T <: AbstractFloat
const VI = AbstractVector{T} where T <: Integer
const VU = AbstractVector{T} where T <: Unsigned
const MC = AbstractMatrix{T} where T <: Complex
const MF = AbstractMatrix{T} where T <: AbstractFloat
const MI = AbstractMatrix{T} where T <: Integer
const MU = AbstractMatrix{T} where T <: Unsigned
const AC = AbstractArray{T} where T <: Complex
const AF = AbstractArray{T} where T <: AbstractFloat
const AI = AbstractArray{T} where T <: Integer
const AU = AbstractArray{T} where T <: Unsigned

import OffsetArrays

const OAry = OffsetArrays.OffsetArray
const ORng = OffsetArrays.IdOffsetRange

import StaticArrays

const SVec, SMat, SAry = StaticArrays.SVector, StaticArrays.SMatrix, StaticArrays.SArray
const MVec, MMat, MAry = StaticArrays.MVector, StaticArrays.MMatrix, StaticArrays.MArray
