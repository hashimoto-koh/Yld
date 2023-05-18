import TiffImages

info(::Val{:tif}, file::AbstractString; ka...) =
    info(TiffImages.load(file; mmap=true))
