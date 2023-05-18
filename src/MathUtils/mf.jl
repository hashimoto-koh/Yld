import ImageFiltering.MapWindow: mapwindow
import ImageFiltering: median!

import ..ArrayUtils: xav, vary
import ..LoopUtils: ⩏

mf(m::AbstractMatrix, l) = mapwindow(median!, m, l)

mf(m::AbstractMatrix, l::Integer...) = mf(m, l)

mf(m::AbstractMatrix, l::Integer) = mf(m, repeat([l], ndims(m)))

mf(m::AbstractArray, l...) = xav(m, (1,2)) ⩏ (x -> mf(x, l...)) |> vary
