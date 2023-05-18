import ImageFiltering.MapWindow: mapwindow
import ImageFiltering: median!

import ..PrimalCommon: toBool
import ..ArrayUtils: xav, vary
import ..LoopUtils: ⩏

mfl_pos(m::AbstractMatrix{<:Integer}; thr, pat=3, rec=true, N=10) =
    mfl_pos(asf4(m); thr, pat, rec, N)

mfl_pos(m::AbstractMatrix{<:AbstractFloat}; thr, pat=3, rec=true, N=10) =
begin
    pos = (m .> thr)
    count(pos) == 0 && (return m)

    mm = mapwindow(median!, m, (pat, pat))
    M = copy(m)
    M[pos] .= mm[pos]
    (toBool(rec) && N>0) ? mfl_pos(M; pat, thr, rec, N=N-1) : M

    #=
    c == 0 && (return m)
    mm = copy(m)
    bg = axes(m) .|> (x -> x[begin])
    ed = axes(m) .|> (x -> x[end])
    p = isa(pat, Integer) ? fill(pat, ndims(m)) : pat
    med(i) = begin
        j1 = i .- p ⊕ bg ⋓ -max
        j2 = i .+ p ⊕ ed ⋓ -min
        h = j1⊕j2 ⋓ -((j1,j2) -> (j1:j2))
        median(m[h...])
    end
    ⊗(axes(m)...) ⩏ (i -> (m[i...] >= thr) && (mm[i...] = med(i)))
    toBool(rec) && N>0 ? mfl(mm; pat=p, thr, rec, N=N-1) : mm
    =#
end

mfl_neg(m; thr, pat=3, rec=true, N=10) = -mfl_pos(-m; thr=-thr, pat, rec, N)

mfl(m::AbstractMatrix; thr, pat=3, rec=true, N=10, neg=false) =
    (
        isa(thr, Real)
        ? (toBool(neg) ? mfl_neg(m; pat, thr, rec) : mfl_pos(m; pat, thr, rec))
        : mfl_neg(mfl_pos(m; pat, thr=max(thr...), rec, N); pat, thr=min(thr...), rec, N)
    )

mfl(m::AbstractArray; kw...) = xav(m, (1,2)) ⩏ (x -> mfl(x; kw...)) |> vary

mfl(m::AbstractMatrix{<:Integer}; kw...) = mfl(m; kw...)
