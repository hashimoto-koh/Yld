###############################
# array_to_fstrream
###############################

"""
# array_to_fstream(m::AbstractArray, fstream::IO; outtype=nothing)
Write an array to file stream
"""
array_to_fstream(m::AbstractArray{<: Real}, fstream::IO; outtype=nothing) =
    begin
        isnothing(outtype) && (return array_to_fstream(m, IO; outtype=eltype(m)))
        (outtype <: Complex) && (return array_to_fstream(convert(Array{outtype}, m), IO; outtype))
        write(fstream, eltype(m) == outtype ? m : convert(Array{outtype}, m))
        nothing
    end

array_to_fstream(m::AbstractArray{<: Complex}, fstream::IO; outtype=nothing) =
    begin
        (outtype <: Real) && error("outtype should be Complex{T}")
        isnothing(outtype) && (return array_to_fstream(m, IO; outtype=eltype(m)))
        for f in [real, imag]
            array_to_fstream(f.(m), fstream; outtype=outtype.parameters[1])
        end
        nothing
    end

