@inline ⩅(itr, fnc) = fgen(fnc, itr)
# @inline ⩂(fnc, itr) = fgen(fnc, itr)
@inline ⋓(itr, fnc) = fary(fnc, itr, Val(false))
@inline ⩐(itr, fnc) = fary(fnc, itr, Val(true))
@inline ⩏(itr, fnc) = tfary(fnc, itr, Val(false))
@inline ⊔(itr, fnc) = tfary(fnc, itr, Val(true))
#=
@inline ⩣(itr, fnc) = lfary(fnc, itr)
@inline ⩢(itr, fnc) = lfary(fnc, itr; prgrs=true)
@inline ⩣(args::Tuple, fnc) = lfary(fnc, args)
# @inline ⩖(itr, fnc) = pfary(fnc, itr)
# @inline ⩒(itr, fnc) = pfary(fnc, itr; prgrs=true)
@inline ⩖(itr, fnc::Function) = pfary(fnc, itr)
@inline ⩖(itr, nthr_fnc::Tuple{Integer,Function}) =
    pfary(nthr_fnc[2], itr; nthr=nthr_func[1])
@inline ⩒(itr, fnc::Function) = pfary(fnc, itr; prgrs=true)
@inline ⩒(itr, nthr_fnc::Tuple{Integer,Function}) =
    pfary(nthr_fnc[2], itr; prgrs=true, nthr=nthr_fnc[1])
=#

@inline ⋓(itr::Base.Generator, ::typeof(colgen)) = colgen(itr.iter, itr.f, Val(:colgen_single_col))
@inline ⩐(itr::Base.Generator, ::typeof(colgen)) = colgen(itr.iter, itr.f, Val(:colgen_prgrs_single_col))
@inline ⩏(itr::Base.Generator, ::typeof(colgen)) = colgen(itr.iter, itr.f, Val(:colgen_thread_multi_spawn))
@inline ⊔(itr::Base.Generator, ::typeof(colgen)) = colgen(itr.iter, itr.f, Val(:colgen_prgrs_thread_multi_spawn))
@inline ⩖(itr::Base.Generator, ::typeof(colgen)) = colgen(itr.iter, itr.f, Val(:colgen_process_single_pmap))

struct _loop_prefix_func{T} <: Function; f::T; end
(f::_loop_prefix_func)(a...; ka...) = f.f(a...; ka...)
Base.:|(a, f::_loop_prefix_func) = f | a
Base.:|(f::_loop_prefix_func, a) = wlib.infix_func(fnc::Function -> f(fnc,a))
Base.:|(f::_loop_prefix_func, a::Base.Generator) = f.f(a)

sloop(;  kw...) = _loop_prefix_func((a...) -> (sloop( a...; kw...)))
tloop(;  kw...) = _loop_prefix_func((a...) -> (tloop( a...; kw...)))
uloop(;  kw...) = _loop_prefix_func((a...) -> (uloop( a...; kw...)))
scoop(;  kw...) = _loop_prefix_func((a...) -> (scoop( a...; kw...)))
tcoop(;  kw...) = _loop_prefix_func((a...) -> (tcoop( a...; kw...)))
ucoop(;  kw...) = _loop_prefix_func((a...) -> (ucoop( a...; kw...)))
psloop(; kw...) = _loop_prefix_func((a...) -> (psloop(a...; kw...)))
ptloop(; kw...) = _loop_prefix_func((a...) -> (ptloop(a...; kw...)))
puloop(; kw...) = _loop_prefix_func((a...) -> (puloop(a...; kw...)))
pscoop(; kw...) = _loop_prefix_func((a...) -> (pscoop(a...; kw...)))
ptcoop(; kw...) = _loop_prefix_func((a...) -> (ptcoop(a...; kw...)))
pucoop(; kw...) = _loop_prefix_func((a...) -> (pucoop(a...; kw...)))

Base.:|(itr, f::Union{typeof(sloop),
                      typeof(tloop),
                      typeof(uloop),
                      typeof(scoop),
                      typeof(tcoop),
                      typeof(ucoop),
                      typeof(psloop),
                      typeof(ptloop),
                      typeof(puloop),
                      typeof(pscoop),
                      typeof(ptcoop),
                      typeof(pucoop)}) = itr | f(;)
Base.:|(f::Union{typeof(sloop),
                 typeof(tloop),
                 typeof(uloop),
                 typeof(scoop),
                 typeof(tcoop),
                 typeof(ucoop),
                 typeof(psloop),
                 typeof(ptloop),
                 typeof(puloop),
                 typeof(pscoop),
                 typeof(ptcoop),
                 typeof(pucoop)}, itr) = itr | f(;)
