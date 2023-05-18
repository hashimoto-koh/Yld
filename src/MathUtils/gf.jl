import ImageFiltering: imfilter
import ImageFiltering: Kernel.gaussian

gf(m::AbstractArray, l) = imfilter(m, gaussian(l))
