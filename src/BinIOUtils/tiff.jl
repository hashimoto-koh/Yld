import TiffImages
import Images: Gray

import ..ArrayUtils: vary
using ..LoopUtils

from(::Val{:tif}, file::AbstractString; prgrs=false, slice=nothing) = fromtif(file; prgrs, slice)

to(::Val{:tif}, m::AbstractMatrix, file::AbstractString; otype=nothing) = totif(m, file; otype)

#################################
# fromtif
#################################

tifdattoary(tifdat::AbstractMatrix{Gray{T}}) where T =
    permutedims(convert(Matrix{T}, tifdat), [2,1])

tifdattoary(tifdat::AbstractArray{Gray{T}, 3}) where T =
    permutedims(convert(Array{T,3}, tifdat), [2,1,3])

tiftoary(tif) = tifdattoary(tif.data)

_loadtif(fname, mmap::Bool, prgrs::Bool) = TiffImages.load(fname; mmap, verbose=prgrs)

loadtif(fname; mmap=false, prgrs=false) = _loadtif(fname, toBool(mmap), toBool(prgrs))

_fromtif(fname, prgrs::Bool, ::Nothing) = loadtif(fname; prgrs) |> tiftoary

_fromtif(fname, ::Bool, slice::Integer) = loadtif(fname; mmap=true)[:,:,slice > 0 ? slice : end+(slice+1)] |> tifdattoary

_fromtif(fname, prgrs::Bool, slice) =
begin
    tif = loadtif(fname; mmap=true);
    m = (prgrs ? (⩐) : (⋓))(slice, (i -> tidattoary(tif[:,:,i])))
    m |> vary
end

fromtif(fname; prgrs=false, slice=nothing) = _fromtif(fname, toBool(prgrs), slice)

#################################
# totif
#################################

_arytotif(m::AbstractMatrix{T}, ::Nothing) where T<:Real =
    TiffImages.DenseTaggedImage(convert(Matrix{Gray{T}}, m'))

_arytotif(m::AbstractArray{T,3}, ::Nothing) where T<:Real =
    TiffImages.DenseTaggedImage(convert(Array{Gray{T}, 3}, permutedims(m, [2,1,3])))

_arytotif(m::AbstractMatrix{T}, otype::DataType) where T<:Real =
    TiffImages.DenseTaggedImage(convert(Matrix{Gray{otype}}, m'))

_arytotif(m::AbstractArray{T,3}, otype::DataType) where T<:Real =
    TiffImages.DenseTaggedImage(convert(Array{Gray{otype}, 3}, permutedims(m, [2,1,3])))

arytotif(m; otype=nothing) = _arytotif(m, otype)

savetif(img, fname) = TiffImages.save(fname, img)

totif(m, fname; otype=nothing) = savetif(arytotif(m; otype), fname)
