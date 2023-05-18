import Distributed
# import ProgressBars:tqdm
using ProgressMeter
# using LoopVectorization

import ..PrimalCommon: toBool

###############################
# fary
###############################

"""
# fary(fnc, itr)
# fary(fnc, itrs...)
fnc : function <br>
itr: iterator <br>
Ret: array <br>
Example: fary((x,y)->x^2 + y, 4, 5:20)
"""
fary(fnc, itr, ::Val{true}) =
    colgen(itr, fnc, Val(:colgen_prgrs_single_col))

fary(fnc, itr, ::Val{false}) =
    colgen(itr, fnc, Val(:colgen_single_col))

fary(fnc, itr; prgrs=false) =
    fary(fnc, itr, Val(toBool(prgrs)))

fary(fnc, itrs...; prgrs=false) =
    fary(fnc, Iterators.product(map(Wild.to_rng, itrs)...); prgrs)

###############################
# tfary
###############################

"""
# tfary(fnc, itr)
# tfary(fnc, itrs...)
fnc : function <br>
itr: iterator <br>
Ret: array <br>
Example: tfary((x,y)->x^2 + y, 4, 5:20)
"""
tfary(fnc, itr, ::Val{true}; nthr=Threads.nthreads()) =
    colgen(itr, fnc, Val(:colgen_prgrs_thread_multi_spawn); nthr)

tfary(fnc, itr, ::Val{false}; nthr=Threads.nthreads()) =
    colgen(itr, fnc, Val(:colgen_thread_multi_spawn); nthr)

tfary(fnc, itr; prgrs=false, nthr=Threads.nthreads()) =
    tfary(fnc, itr, Val(toBool(prgrs)); nthr)

tfary(fnc, itrs...; prgrs=false, nthr=Threads.nthreads()) =
    tfary(fnc,
          Iterators.product(map(Wild.to_rng, itrs)...);
          prgrs, nthr)

# ###############################
# # lfary
# ###############################

# """
#     lfary
#     lfary(fnc::Function, iterator; prgrs=false)
#     lfary(fnc::Function, (mat1, mat2,...))
#     lfary(fnc::Function, mat1, mat2,...)
# """
# lfary(fnc, itr; prgrs=false) =
#     [vmapntt(fnc, a...) for a in (toBool(prgrs) ? tqdm(itr) : itr)]
# lfary(fnc, tpl::Tuple) = vmapntt(fnc, tpl...)
# lfary(fnc, matrices...) = lfary(fnc, matrices)

# ###############################
# # pfary
# ###############################

# """
# # pfary(fnc, itr)
# # pfary(fnc, itrs...)
# fnc : function <br>
# itr: iterator <br>
# Ret: array <br>
# Example: pfary((x,y)->x^2 + y, 4, 5:20)
# """
# pfary(fnc, itr, ::Val{false}; nthr=Distributed.nworkers()) =
#     colgen(itr, fnc, Val(:colgen_process_single_pmap))

# pfary(fnc, itr, ::Val{true}; nthr=Distributed.nworkers()) =
#     colgen(itr, fnc, Val(:colgen_prgrs_process_single_pmap))

# pfary(fnc, itr; prgrs=false, nthr=Distributed.nworkers()) =
#     pfary(fnc, itr, Val(toBool(prgrs)))

# pfary(fnc, itrs...; prgrs=false, nthr=Threads.nthreads()) =
#     tfary(fnc,
#           Iterators.product(map(Wild.to_rng, itrs)...);
#           prgrs, nthr)
# #=
# pfary(fnc,
#       itr;
#       prgrs=false,
#       nthr::Union{Nothing, Integer}=nothing) =
#     begin
#         nthr = isnothing(nthr) ? Distributed.nworkers()+1 : nthr

#         it = Wild.to_rng(itr)
#         argtype = Tuple{dtype(it)}
#         f = hasmethod(fnc, argtype) ? fnc : x -> fnc(x...)

#         tskp = [
#             (X = wlib.__get_looprange(it, nthr, k)[2];
#              (Distributed.@spawnat k map(f, X)))
#             for k in (2:nthr) #Distributed.workers()
#         ]
#         res1 = let
#             I, X = wlib.__get_looprange(it, nthr, 1)
#             pbar = toBool(prgrs) && length(I) > 1
#             pbar ? (p = tqdm(1:length(I)); map(x -> (p[1]; f(x)), X)) : map(f, X)
#         end
#         resp= map(fetch, tskp)
#         reshape(vcat(res1, resp...), size(it))
#     end
# pfary(fnc, itrs...;
#       prgrs=false,
#       nthr=nothing) =
#     pfary(fnc, Iterators.product(map(Wild.to_rng, itrs)...); prgrs, nthr)
# =#
