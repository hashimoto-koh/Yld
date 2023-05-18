import Images

from(::Val{:png}, file::AbstractString; ka...) = Images.load(file; ka...)

to(::Val{:png}, m::AbstractMatrix, file::AbstractString; ka...) = Images.save(file, m; ka...)
