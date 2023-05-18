uary(m::AbstractArray; mltthrd=false) =
begin
    !isa(m[1], AbstractArray) && (return m)

    if !isa(m[1][1], AbstractArray)
        mm = Array{typeof(m[1][1]), ndims(m)+ndims(m[1])}(undef,
                                                          size(m)...,
                                                          size(m[1])...)
        if toBool(mltthrd)
            Threads.@threads for (a, b) in collect(zip(axview(mm, 1:ndims(m)), m))
                a .= b
            end
        else
            for (a, b) in zip(axv(mm, 1:ndims(m)), m)
                a .= b
            end
        end
        return mm
    end
    uary(map(m->uary(m; mltthrd=mltthrd), m); mltthrd)
end
#=
    if !(eltype(m) <: AbstractArray)
        m
    elseif !(eltype(m[1]) <: AbstractArray)
        dms = collect(1:ndims(m) + ndims(m[1]))
        perm(vary(m), vcat(dms[ndims(m[1])+1:end], dms[1:ndims(m[1])]))
    else
        dms = collect(1:ndims(m) + ndims(m[1]) + ndims(m[1][1]))
        perm(vary(m),
             vcat(dms[ndims(m[1][1])+ndims(m[1])+1:end],
                  dms[ndims(m[1][1])+1:ndims(m[1][1])+ndims(m[1])],
                  dms[1:ndims(m[1][1])]))
    end
=#

tuary(m::AbstractArray) = uary(m; mltthrd=true)
