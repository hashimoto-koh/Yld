vary(m::AbstractVector; mltthrd=false) =
begin
    !isa(m[1], AbstractArray) && (return m)

    if !(eltype(m[1]) <: AbstractArray)
        mm = Array{eltype(m[1]), 1+ndims(m[1])}(undef,size(m[1])...,size(m,1))
        J = keys(m)
        cln = ntuple(_->(:), ndims(m[1]))
        if toBool(mltthrd)
            Threads.@threads for i in Base.OneTo(size(m,1))
                mm[cln...,i] = m[J[i]]
            end
        else
            for i in Base.OneTo(size(m,1))
                mm[cln...,i] = m[J[i]]
            end
        end
        return mm
    end
    vary(map(m->vary(m; mltthrd), m); mltthrd)
end

vary(m::AbstractArray; mltthrd=false) =
begin
    !isa(m[1], AbstractArray) && (return m)

    # if !isa(m[1][1], AbstractArray)
    if !(eltype(m[1]) <: AbstractArray)
        mm = Array{eltype(m[1]), ndims(m)+ndims(m[1])}(undef,
                                                       size(m[1])...,
                                                       size(m)...)
        J = keys(m)
        cln = ntuple(_->(:), ndims(m[1]))
        if toBool(mltthrd)
            Threads.@threads for i in Base.Iterators.ProductIterator(Base.OneTo.(size(m))...)
                mm[cln...,i...] = m[J[i...]]
            end
            # Threads.@threads for (a, b) in collect(zip(axview(mm, ndims(m[1])+1:ndims(m)+ndims(m[1])), m))
            #     a .= b
            # end
        else
            for i in Base.Iterators.ProductIterator(Base.OneTo.(size(m))...)
                mm[cln...,i...] = m[J[i...]]
            end
            # for (a, b) in zip(axview(mm, ndims(m[1])+1:ndims(m)+ndims(m[1])), m)
            #     a .= b
            # end
        end
        return mm
    end
    vary(map(m->vary(m; mltthrd), m); mltthrd)
end
#=
    if !(m[1] <: AbstractArray)
        m
    elseif !(m[1][1]) <: AbstractArray)
        reshape(collect(Iterators.flatten(m)),
                (size(m[1])..., size(m)...))
    else
        reshape(collect(Iterators.flatten(Iterators.flatten(m))),
                (size(m[1][1])..., size(m[1])..., size(m)...))
    end
=#

tvary(m::AbstractArray) = vary(m; mltthrd=true)
