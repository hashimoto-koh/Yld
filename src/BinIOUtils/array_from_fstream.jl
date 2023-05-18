###############################
# array_from_fstrream
###############################

"""
# array_from_fstream(fstream::IO, n::Integer...; offset=0, intype=UInt16, outtype=nothing)
# array_from_fstream(fstream::IO, n::Tuple; offset=0, intype=UInt16, outtype=nothing)
Read an array from file stream
"""
array_from_fstream(fstream::IO,
                   n::Integer...;
                   offset=0,
                   intype=UInt16,
                   outtype=nothing,
                   mmap=false) =
    begin
        isnothing(outtype) && (outtype = intype)
        skip(fstream, offset)
        if intype <: Real
            if toBool(mmap)
                m0 = Mmap.mmap(fstream, Array{intype, length(n)}, Int.(n))
                intype == outtype ? m0 : convert(Array{outtype}, m0)
            else
                m1 = Array{intype, length(n)}(undef, n)
                read!(fstream, m1)
                intype == outtype ? m1 : convert(Array{outtype}, m1)
            end
        else
            outtype <: Complex || error("output type should be Complex{T}")
            z = array_from_fstream(fstream, n..., 2;
                                   intype=intype.parameters[1],
                                   outtype=outtype.parameters[1])
            @rv[1](z) + outtype(1im) * @rv[2](z)
        end
    end

array_from_fstream(fstream::IO,
                   n::Tuple;
                   offset=0,
                   intype=UInt16,
                   outtype=nothing,
                   mmap=false) =
    array_from_stream(fstream, n...; offset=offset, intype=intype, outtype=outtype, mmap=mmap)
