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
