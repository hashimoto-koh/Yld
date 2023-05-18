import ProgressMeter
import IJulia

import ..PrimalCommon: toBool

loop_range(N::Integer,
           nthr::Union{Nothing, Integer}=nothing,
           ithr::Union{Nothing, Integer}=nothing) =
begin
    n = isnothing(nthr) ? Threads.nthreads() : nthr
    id = isnothing(ithr) ? Threads.threadid() : ithr
    m = N % n
    M = N ÷ n
    i0 = (id-1) * M + 1 + (id <= m ? id-1 : m)
    i1 = i0 + M - (id <= m ? 0 : 1)
    i0:i1
end

loop_range(itr,
           nthr::Union{Nothing, Integer}=nothing,
           ithr::Union{Nothing, Integer}=nothing) =
begin
    irng = loop_range(length(itr), nthr, ithr)
    Iterators.take(Iterators.drop(itr, irng.start-1), length(irng))
end

loop_ranges(itr::Integer, nthr=Threads.nthreads()) = loop_ranges(1:itr, nthr)

loop_ranges(itr, nthr=Threads.nthreads()) =
begin
    nthr = min(length(itr), nthr)
    [loop_range(itr, nthr, ithr) for ithr in 1:nthr]
end

to_rng(i::Integer) = i>=1 ? (1:i) : (-1:-1:i)
to_rng(x) = x
to_rng(x...) = Iterators.product(to_rng.(x)...)

"""
    sloop(fnc, rng...)
    return values: nothing
    example:
        sloop(10:15, 7) do (i, j)
            println("(i)  (j)")
        end
"""
sloop(gen::Base.Generator; kw...) = sloop(gen.f, gen.iter; kw...)
sloop(fnc::Function, rng...; kw...) =
    (for x in to_rng(rng...); fnc(x); end; nothing)

"""
    tloop(fnc, rng...; nthr=Threads.nthreads())
    return values: nothing
    example:
    ```
        tloop(10:15, 7; nthr=5) do (i, j)
            println("(i)  (j)")
        end
    ```
"""
tloop(gen::Base.Generator; nthr=Threads.nthreads(), kw...) = tloop(gen.f, gen.iter; nthr, kw...)
tloop(fnc::Function, rng...; nthr=Threads.nthreads(), kw...) =
begin
    tsks = [(Threads.@spawn sloop(fnc, rg; kw...))
            for rg in loop_ranges(to_rng(rng...), nthr)]
    sloop(wait, tsks)
    nothing
end

"""
    uloop(fnc, rng...; nthr=Threads.nthreads())
    return values: nothing
    example:
    ```
        uloop(10:15, 7; nthr=5) do (i, j)
            println("(i)  (j)")
        end
    ```
"""
uloop(gen::Base.Generator; nthr=Threads.nthreads(), kw...) = uloop(gen.f, gen.iter; nthr, kw...)
uloop(fnc::Function, rng...; nthr=Threads.nthreads(), kw...) =
begin
    Threads.@threads for x in to_rng(rng...)
        fnc(x)
    end
    nothing
end

"""
    scoop(fnc, rng...)
    return values: an array
    example:
        scoop(10:15, 7) do (i, j)
            i + j
        end
"""
scoop(gen::Base.Generator; kw...) = collect(gen)
scoop(fnc::Function, rng...; kw...) = scoop(Base.Generator(fnc, to_rng(rng...)))

"""
    tcoop(fnc, rng...; nthr=Threads.nthreads())
    return values: an array
    example:
        tcoop(10:15, 7; nthr=5) do (i, j)
            i + j
        end
"""
tcoop(gen::Base.Generator; nthr=Threads.nthreads(), kw...) = tcoop(gen.f, gen.iter; nthr, kw...)
tcoop(fnc::Function, rng...; nthr=Threads.nthreads(), kw...) =
begin
    rg = to_rng(rng...)
    tsks = [(Threads.@spawn scoop(fnc, r; kw...))
            for r in loop_ranges(rg, nthr)]
    rslt = scoop(fetch, tsks)
    reshape(vcat(rslt...), size(rg))
end

"""
    ucoop(fnc, rng...; nthr=Threads.nthreads())
    return values: an array
    example:
        ucoop(10:15, 7; nthr=5) do (i, j)
            i + j
        end
"""
ucoop(gen::Base.Generator; nthr=Threads.nthreads(), kw...) = ucoop(gen.f, gen.iter; nthr, kw...)
ucoop(fnc::Function, rng...; nthr=Threads.nthreads(), kw...) =
begin
    rg = to_rng(rng...)
    tsks = [(Threads.@spawn fnc(r)) for r in rg]
    rslt = scoop(fetch, tsks)
    reshape(rslt, size(rg))
end

#=
_ploop_impl(pbar, rng, fnc, nthr, loopfnc, ::Nothing, ::Nothing) =
    loopfnc(rng; nthr) do x
        y = fnc(x)
        ProgressMeter.next!(pbar)
        y
    end
_ploop_impl(pbar, rng, fnc, nthr, loopfnc, prgfnc, ::Nothing) =
begin
    n = length(rng)
    loopfnc(enumerate(rng); nthr) do (i,x)
        y = fnc(x)
        ProgressMeter.next!(pbar; showvalues=prgfnc((i,n),(x,y)))
        y
    end
end
_ploop_impl(pbar, rng, fnc, nthr, loopfnc, ::Nothing, dscfnc) =
begin
    n = length(rng)
    loopfnc(enumerate(rng); nthr) do (i,x)
        y = fnc(x)
        ProgressMeter.next!(pbar)
        pbar.desc = dscfnc(i,n)
        y
    end
end
_ploop_impl(pbar, rng, fnc, nthr, loopfnc, prgfnc, dscfnc) =
begin
    n = length(rng)
    loopfnc(enumerate(rng); nthr) do (i,x)
        y = fnc(x)
        ProgressMeter.next!(pbar; showvalues=prgfnc((i,n),(x,y)))
        pbar.desc = dscfnc(i,n)
        y
    end
end
=#
_ploop_impl(pbar, rng, fnc, nthr, loopfnc, ::Nothing, ::Nothing) =
begin
    loopfnc(rng; nthr) do x
        y = fnc(x)
        ProgressMeter.next!(pbar)
        y
    end
end
_ploop_impl(pbar, rng, fnc, nthr, loopfnc, prgfnc, ::Nothing) =
begin
    loopfnc(rng; nthr) do x
        y = fnc(x)
        ProgressMeter.next!(pbar; showvalues=prgfnc((pbar.counter + 1, pbar.n), (x, y)))
        y
    end
end
_ploop_impl(pbar, rng, fnc, nthr, loopfnc, ::Nothing, dscfnc) =
begin
    loopfnc(rng; nthr) do x
        y = fnc(x)
        pbar.desc = dscfnc(pbar.counter + 1, pbar.n)
        ProgressMeter.next!(pbar)
        y
    end
end
_ploop_impl(pbar, rng, fnc, nthr, loopfnc, prgfnc, dscfnc) =
begin
    loopfnc(rng; nthr) do x
        y = fnc(x)
        pbar.desc = dscfnc(pbar.counter + 1, pbar.n)
        ProgressMeter.next!(pbar; showvalues=prgfnc((pbar.counter + 1, pbar.n), (x, y)))
        y
    end
end
_ploop(loopfnc,
       fnc, rng...;
       prgfnc=nothing,
       dscfnc=((i,n) -> "[$(i)/$(n)] "),
       dt::Real=0.1,
       desc::AbstractString="Progress: ",
       color::Symbol=:green,
       output::IO=stderr,
       barlen=nothing,
       barglyphs::ProgressMeter.BarGlyphs=ProgressMeter.BarGlyphs('|','█', Sys.iswindows() ? '█' : ['▏','▎','▍','▌','▋','▊','▉'],' ','|',),
       offset::Integer=0,
       start::Integer=0,
       enabled=true,
       showspeed=true,
       ijulia_behavior=:clear,
       clear_output=false,
       nthr=Threads.nthreads()) =
begin
    rg = to_rng(rng...)
    !isnothing(ijulia_behavior) && ProgressMeter.ijulia_behavior(ijulia_behavior)
    pbar = ProgressMeter.Progress(length(rg); dt, desc, color, output, barlen, barglyphs, offset, start, enabled=toBool(enabled), showspeed=toBool(showspeed))
    result = _ploop_impl(pbar, rg, fnc, nthr, loopfnc, prgfnc, dscfnc)
    if toBool(clear_output)
        IJulia.clear_output(true)
        ProgressMeter.update!(pbar)
    end
    result
end

"""
    psloop(fnc, rng...;
           prgfnc=nothing,
           dscfnc=((i,n) -> "[(i)/(n)] "),
           dt::Real=0.1,
           desc::AbstractString="Progress: ",
           color::Symbol=:green,
           output::IO=stderr,
           barlen=nothing,
           barglyphs::ProgressMeter.BarGlyphs=ProgressMeter.BarGlyphs('|','█', Sys.iswindows() ? '█' : ['▏','▎','▍','▌','▋','▊','▉'],' ','|',),
           offset::Integer=0,
           start::Integer=0,
           enabled=true,
           showspeed=true,
           ijulia_behavior=:clear,
           clear_output=false)
    return values: nothing
    example:
        psloop(10:15, 7; prgfnc=((i,n),(x,y)) -> ((:i, "(i)/(n)"), (:xy, "(x)->(y)"))) do (i, j)
            sleep(i+j)
        end
"""
psloop(gen::Base.Generator; kw...) = psloop(gen.f, gen.iter; kw...)
psloop(fnc::Function, rng...;
       prgfnc=nothing,
       dscfnc=((i,n) -> "[$(i)/$(n)] "),
       dt::Real=0.1,
       desc::AbstractString="Progress: ",
       color::Symbol=:yellow,
       output::IO=stderr,
       barlen=nothing,
       barglyphs::ProgressMeter.BarGlyphs=ProgressMeter.BarGlyphs('|','█', Sys.iswindows() ? '█' : ['▏','▎','▍','▌','▋','▊','▉'],' ','|',),
       offset::Integer=0,
       start::Integer=0,
       enabled=true,
       showspeed=true,
       ijulia_behavior=:clear,
       clear_output=false,
       nthr=Threads.nthreads()) =
_ploop(sloop, fnc, rng...; prgfnc, dscfnc, dt, desc, color, output, barlen, barglyphs, offset, start, enabled, showspeed, ijulia_behavior, clear_output, nthr)

"""
    ptloop(fnc, rng...;
           nthr=Threads.nthreads(),
           prgfnc=nothing,
           dscfnc=((i,n) -> "[(i)/(n)] "),
           dt::Real=0.1,
           desc::AbstractString="Progress: ",
           color::Symbol=:green,
           output::IO=stderr,
           barlen=nothing,
           barglyphs::ProgressMeter.BarGlyphs=ProgressMeter.BarGlyphs('|','█', Sys.iswindows() ? '█' : ['▏','▎','▍','▌','▋','▊','▉'],' ','|',),
           offset::Integer=0,
           start::Integer=0,
           enabled=true,
           showspeed=true,
           ijulia_behavior=:clear,
           clear_output=false)
    return values: nothing
    example:
        ptloop(10:15, 7; nthr=5) do (i, j)
            sleep(i+j)
        end
"""
ptloop(gen::Base.Generator; kw...) = ptloop(gen.f, gen.iter; kw...)
ptloop(fnc::Function, rng...;
       nthr=Threads.nthreads(),
       prgfnc=nothing,
       dscfnc=((i,n) -> "[$(i)/$(n)] "),
       dt::Real=0.1,
       desc::AbstractString="Progress: ",
       color::Symbol=:cyan,
       output::IO=stderr,
       barlen=nothing,
       barglyphs::ProgressMeter.BarGlyphs=ProgressMeter.BarGlyphs('|','█', Sys.iswindows() ? '█' : ['▏','▎','▍','▌','▋','▊','▉'],' ','|',),
       offset::Integer=0,
       start::Integer=0,
       enabled=true,
       showspeed=true,
       ijulia_behavior=:clear,
       clear_output=false) =
_ploop(tloop, fnc, rng...;
       prgfnc, dscfnc, dt, desc, color, output, barlen, barglyphs, offset, start, enabled, showspeed, ijulia_behavior, clear_output, nthr)

"""
    puloop(fnc, rng...;
           nthr=Threads.nthreads(),
           prgfnc=nothing,
           dscfnc=((i,n) -> "[(i)/(n)] "),
           dt::Real=0.1,
           desc::AbstractString="Progress: ",
           color::Symbol=:green,
           output::IO=stderr,
           barlen=nothing,
           barglyphs::ProgressMeter.BarGlyphs=ProgressMeter.BarGlyphs('|','█', Sys.iswindows() ? '█' : ['▏','▎','▍','▌','▋','▊','▉'],' ','|',),
           offset::Integer=0,
           start::Integer=0,
           enabled=true,
           showspeed=true,
           ijulia_behavior=:clear,
           clear_output=false)
    return values: nothing
    example:
        puloop(10:15, 7; nthr=5) do (i, j)
            sleep(i+j)
        end
"""
puloop(gen::Base.Generator; kw...) = puloop(gen.f, gen.iter; kw...)
puloop(fnc::Function, rng...;
       nthr=Threads.nthreads(),
       prgfnc=nothing,
       dscfnc=((i,n) -> "[$(i)/$(n)] "),
       dt::Real=0.1,
       desc::AbstractString="Progress: ",
       color::Symbol=:cyan,
       output::IO=stderr,
       barlen=nothing,
       barglyphs::ProgressMeter.BarGlyphs=ProgressMeter.BarGlyphs('|','█', Sys.iswindows() ? '█' : ['▏','▎','▍','▌','▋','▊','▉'],' ','|',),
       offset::Integer=0,
       start::Integer=0,
       enabled=true,
       showspeed=true,
       ijulia_behavior=:clear,
       clear_output=false) =
_ploop(uloop, fnc, rng...;
       prgfnc, dscfnc, dt, desc, color, output, barlen, barglyphs, offset, start, enabled, showspeed, ijulia_behavior, clear_output, nthr)

"""
    pscoop(fnc, rng...;
           prgfnc=nothing,
           dscfnc=((i,n) -> "[(i)/(n)] "),
           dt::Real=0.1,
           desc::AbstractString="Progress: ",
           color::Symbol=:green,
           output::IO=stderr,
           barlen=nothing,
           barglyphs::ProgressMeter.BarGlyphs=ProgressMeter.BarGlyphs('|','█', Sys.iswindows() ? '█' : ['▏','▎','▍','▌','▋','▊','▉'],' ','|',),
           offset::Integer=0,
           start::Integer=0,
           enabled=true,
           showspeed=true,
           ijulia_behavior=:clear,
           clear_output=false)
     returnvalues: an array
    example:
        pscoop(10:15, 7) do (i, j)
            i + j
        end
"""
pscoop(gen::Base.Generator; kw...) = pscoop(gen.f, gen.iter; kw...)
pscoop(fnc::Function, rng...;
       prgfnc=nothing,
       dscfnc=((i,n) -> "[$(i)/$(n)] "),
       dt::Real=0.1,
       desc::AbstractString="Progress: ",
       color::Symbol=:green,
       output::IO=stderr,
       barlen=nothing,
       barglyphs::ProgressMeter.BarGlyphs=ProgressMeter.BarGlyphs('|','█', Sys.iswindows() ? '█' : ['▏','▎','▍','▌','▋','▊','▉'],' ','|',),
       offset::Integer=0,
       start::Integer=0,
       enabled=true,
       showspeed=true,
       ijulia_behavior=:clear,
       clear_output=false,
       nthr=Threads.nthreads()) =
_ploop(scoop, fnc, rng...;
       prgfnc, dscfnc, dt, desc, color, output, barlen, barglyphs, offset, start, enabled, showspeed, ijulia_behavior, clear_output, nthr)

"""
    ptcoop(fnc, rng...;
           nthr=Threads.nthreads(),
           prgfnc=nothing,
           dscfnc=((i,n) -> "[(i)/(n)] "),
           dt::Real=0.1,
           desc::AbstractString="Progress: ",
           color::Symbol=:green,
           output::IO=stderr,
           barlen=nothing,
           barglyphs::ProgressMeter.BarGlyphs=ProgressMeter.BarGlyphs('|','█', Sys.iswindows() ? '█' : ['▏','▎','▍','▌','▋','▊','▉'],' ','|',),
           offset::Integer=0,
           start::Integer=0,
           enabled=true,
           showspeed=true,
           ijulia_behavior=:clear,
           clear_output=false)
    return values: an array
    example:
        ptcoop(10:15, 7) do (i, j)
            i + j
        end
"""
ptcoop(gen::Base.Generator; kw...) = ptcoop(gen.f, gen.iter; kw...)
ptcoop(fnc::Function, rng...;
       nthr=Threads.nthreads(),
       prgfnc=nothing,
       dscfnc=((i,n) -> "[$(i)/$(n)] "),
       dt::Real=0.1,
       desc::AbstractString="Progress: ",
       color::Symbol=:blue,
       output::IO=stderr,
       barlen=nothing,
       barglyphs::ProgressMeter.BarGlyphs=ProgressMeter.BarGlyphs('|','█', Sys.iswindows() ? '█' : ['▏','▎','▍','▌','▋','▊','▉'],' ','|',),
       offset::Integer=0,
       start::Integer=0,
       enabled=true,
       showspeed=true,
       ijulia_behavior=:clear,
       clear_output=false) =
_ploop(tcoop, fnc, rng...;
       prgfnc, dscfnc, dt, desc, color, output, barlen, barglyphs, offset, start, enabled, showspeed, ijulia_behavior, clear_output, nthr)

"""
    pucoop(fnc, rng...;
           nthr=Threads.nthreads(),
           prgfnc=nothing,
           dscfnc=((i,n) -> "[(i)/(n)] "),
           dt::Real=0.1,
           desc::AbstractString="Progress: ",
           color::Symbol=:green,
           output::IO=stderr,
           barlen=nothing,
           barglyphs::ProgressMeter.BarGlyphs=ProgressMeter.BarGlyphs('|','█', Sys.iswindows() ? '█' : ['▏','▎','▍','▌','▋','▊','▉'],' ','|',),
           offset::Integer=0,
           start::Integer=0,
           enabled=true,
           showspeed=true,
           ijulia_behavior=:clear,
           clear_output=false)
    return values: an array
    example:
        pucoop(10:15, 7) do (i, j)
            i + j
        end
"""
pucoop(gen::Base.Generator; kw...) = pucoop(gen.f, gen.iter; kw...)
pucoop(fnc::Function, rng...;
       nthr=Threads.nthreads(),
       prgfnc=nothing,
       dscfnc=((i,n) -> "[$(i)/$(n)] "),
       dt::Real=0.1,
       desc::AbstractString="Progress: ",
       color::Symbol=:blue,
       output::IO=stderr,
       barlen=nothing,
       barglyphs::ProgressMeter.BarGlyphs=ProgressMeter.BarGlyphs('|','█', Sys.iswindows() ? '█' : ['▏','▎','▍','▌','▋','▊','▉'],' ','|',),
       offset::Integer=0,
       start::Integer=0,
       enabled=true,
       showspeed=true,
       ijulia_behavior=:clear,
       clear_output=false) =
_ploop(ucoop, fnc, rng...;
       prgfnc, dscfnc, dt, desc, color, output, barlen, barglyphs, offset, start, enabled, showspeed, ijulia_behavior, clear_output, nthr)

const  loop =  sloop
const  coop =  scoop
const ploop = psloop
const pcoop = pscoop
