import Images

info(::Val{:png}, file::AbstractString; ka...) = info(Images.load(file; ka...))

