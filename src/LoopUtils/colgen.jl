import ProgressMeter
import Distributed

Base.getindex(itr::Base.Iterators.ProductIterator, idx...) =
    Iterators.product((i[I] for (i,I) in zip(itr.iterators, idx))...)

Base.getindex(itr::Base.Iterators.Zip, idx...) =
    Iterators.zip((i[idx...] for i in itr.is)...)

Base.getindex(gen::Base.Generator, idx...) = begin
    f = gen.f
    itr = gen.iter
    ((*)(length.(idx)...) == 1
     ? f(itr[idx...]...)
     : (f(x) for x in itr[idx...]))
end

# fgen
"""
# fgen(fnc, itr)
# fgen(fnc, itrs...)
fnc : function <br>
itr: iterator <br>
Ret: generator <br>
Example: fgen((x,y)->x^2 + y, 4, 5:20)
"""
fgen(fnc, gen::Base.Generator) = Base.Generator(fnc ∘ gen.f, gen.iter)

fgen(fnc, itr) = Base.Generator(fnc, to_rng(itr))
# fgen(fnc, itr) = Base.Generator(x -> x | fnc, to_rng(itr))
#=
fgen(fnc, itr) =
    begin
        it = to_rng(itr)
        f = (hasmethod(fnc, Tuple{dtype(it)})
             ? fnc
             : x -> fnc(x...))
        Base.Generator(f, it)
    end
=#
fgen(fnc, itrs...) = fgen(fnc, Iterators.product(map(to_rng, itrs)...))

# colgen with additional func
colgen(gen, fnc, val::Val; kw...) = colgen(fgen(fnc, gen), val; kw...)

# colgen for single thread
colgen(gen, ::Val{:colgen_single}) = colgen(gen, Val(:colgen_single_col))

colgen(gen, ::Val{:colgen_single_col}) = scoop(gen.f, gen.iter) # collect(gen)

colgen(gen, ::Val{:colgen_single_dot}) = gen.f.(gen.iter)

colgen(gen, ::Val{:colgen_single_map}) = map(gen.f, gen.iter)

# colgen for multi thread
colgen(gen, ::Val{:colgen_thread}; nthr=Threads.nthreads()) =
    colgen(gen, Val(:colgen_thread_multi_spawn); nthr)

colgen(gen, ::Val{:colgen_thread_single_spawn}) =
begin
    tsks = [Threads.@spawn gen.f(x) for x in gen.iter]
    colgen(tsks, fetch, Val(:colgen_single))
    # [fetch(t) for t in tsks]
end

colgen(gen, ::Val{:colgen_thread_multi_spawn};
       nthr=Threads.nthreads()) =
    tcoop(gen.f, gen.iter; nthr)
# begin
# #=
#     if length(gen.iter) <= nthr
#         return colgen(gen, Val(:colgen_thread_single_spawn))
#     end
# =#
#     single_method = :colgen_single
#     fetch_method = :colgen_single
#     nthr = min(nthr, length(gen.iter))
#     tsks = [(Threads.@spawn colgen(X, gen.f, Val(single_method)))
#             for X in __get_loop_ranges(gen.iter, nthr)]
#     resp = colgen(tsks, fetch, Val(fetch_method))
#     reshape(vcat(resp...), size(gen))
# end

# colgen for multi process
colgen(gen, ::Val{:colgen_process}) = colgen(gen, Val(:colgen_process_multi_spawnat))

colgen(gen, ::Val{:colgen_process_single_pmap}) =
    Distributed.pmap(gen.f, gen.iter)

colgen(gen, ::Val{:colgen_process_multi_spawnat};
       nthr=Distributed.nworkers()) =
    begin
        (nthr > Distributed.nworkers() &&
            (nthr = Distributed.nworkers()))

        if length(gen.iter) <= nthr
            return colgen(gen, Val(:colgen_process_single_pmap))
        end

        single_method = :colgen_single
        fetch_method = :colgen_single
        tsks = [(Distributed.@spawnat k colgen(X, gen.f, Val(single_method)))
                for X in __get_loop_ranges(gen.iter, nthr)]
        resp = colgen(tsks, fetch, Val(fetch_method))
        reshape(vcat(resp...), size(gen))
    end

# colgen for single thread with pbar
_make_colgen_pbarfnc(gen) =
begin
    n, num = 0, length(gen)
    ProgressMeter.ijulia_behavior(:clear);
    pbar = ProgressMeter.Progress(num; showspeed=true)
    x -> (n+=1; next!(pbar; showvalues=[(:i, "$(n) / $(num)")]); x)
end

colgen(gen, ::Val{:colgen_prgrs_single}) = colgen(gen, Val(:colgen_prgrs_single_col))

colgen(gen, ::Val{:colgen_prgrs_single_col}) =
    pscoop(gen.f, gen.iter)
#=
    colgen(gen,
           _make_colgen_pbarfnc(gen),
           Val(:colgen_single_col))
=#
colgen(gen, ::Val{:colgen_prgrs_single_dot}) =
    colgen(gen,
           _make_colgen_pbarfnc(gen),
           Val(:colgen_single_dot))

colgen(gen, ::Val{:colgen_prgrs_single_map}) =
    colgen(gen,
           _make_colgen_pbarfnc(gen),
           Val(:colgen_single_map))

# multi thread with pbar
#=
_make_pbarfnc_colgen_thread(gen, fnc) =
begin
    n, num = 0, length(gen)
    ProgressMeter.ijulia_behavior(:clear);
    pbar = ProgressMeter.Progress(num; showspeed=true)
    x -> (n+=1; next!(pbar; showvalues=[(:i, "$(n) / $(num)")]); fnc(x))
end
=#
colgen(gen, ::Val{:colgen_prgrs_thread};
       nthr=Threads.nthreads()) =
        colgen(gen, Val(:colgen_prgrs_thread_multi_spawn); nthr)

colgen(gen, ::Val{:colgen_prgrs_thread_single_spawn}) =
    colgen(gen,
           _make_colgen_pbarfnc(gen),
           Val(:colgen_thread_single_spawn))

colgen(gen, ::Val{:colgen_prgrs_thread_multi_spawn};
       nthr=Threads.nthreads()) =
    ptcoop(gen.f, gen.iter; nthr)
    #=
    colgen(gen,
           _make_colgen_pbarfnc(gen),
           Val(:colgen_thread_multi_spawn); nthr)
    =#

# mtx
mtx(f::Function, lck=lck) =
    (x...) -> (lock(lck); a = f(x...); unlock(lck); a)

mtx(gen::Base.Generator, lck=lck) =
    (f = mtx(gen.f, lck); (f(x) for x in gen.iter))

# __get_loop_range
function __get_looprange(N::Integer,
        nthr::Union{Nothing, Integer}=nothing,
        ithr::Union{Nothing, Integer}=nothing)
    n = isnothing(nthr) ? Threads.nthreads() : nthr
    id = isnothing(ithr) ? Threads.threadid() : ithr
    m = N % n
    M = N ÷ n
    i0 = (id-1) * M + 1 + (id <= m ? id-1 : m)
    i1 = i0 + M - (id <= m ? 0 : 1)
    i0:i1
end

# __get_loop_ranges
function __get_loop_ranges(itr, nthr=Threads.nthreads())
    l = length(itr)
    [(I = __get_looprange(l, nthr, i);
      Iterators.take(Iterators.drop(itr, I.start-1), length(I)))
     for i in 1:nthr]
end

#=
function __get_looprange(itr,
        nthr::Union{Nothing, Integer}=nothing,
        ithr::Union{Nothing, Integer}=nothing)
I = __get_looprange(length(itr), nthr, ithr)
(I, Iterators.take(Iterators.drop(itr, I.start-1), length(I)))
end
=#
