to(::Val{:raw}, m::AbstractArray, file::AbstractString; outtype=nothing) = toraw(m, file; outtype)

from(::Val{:raw}, file::AbstractString; n, offset=0, intype=UInt16, outtype=nothing, mmap=false) =
    fromraw(file, n...; offset, intype, outtype, mmap)

###############################
# fromraw, toraw
###############################

"""read from a binary-raw file"""
fromraw(fname::AbstractString,
        n::Integer...;
        offset=0,
        intype=UInt16,
        outtype=nothing,
        mmap=false) =
    open(fname, "r") do f
        array_from_fstream(f, reverse(n)...;
                           offset=offset,
                           intype=intype,
                           outtype=outtype,
                           mmap=mmap)
    end

fromraw(fname::AbstractString,
        n::Tuple;
        offset=0,
        intype=UInt16,
        outtype=nothing,
        mmap=false) = fromraw(fname, n...;
                               offset=offset,
                               intype=intype,
                               outtype=outtype,
                               mmap=mmap)

toraw(m::AbstractArray, fname; outtype=nothing, forcename=false) =
    begin
        isnothing(outtype) && (outtype = eltype(m))
        open(_force_ext(fname, "raw", forcename), "w") do f
            array_to_fstream(m, f; outtype=outtype)
        end
        nothing
    end
