export prgrsbar, pgbar

import ProgressMeter

#################################
# prgrsbar
#################################

prgrsbar(n; desc="progress: ", color=:black, output=stdout, dt=0.1, showspeed=true, ka...) =
    ProgressMeter.Progress(n; desc, color, output, dt, showspeed, ka...)
Base.:+(p::ProgressMeter.Progress) = (ProgressMeter.next!(p); p)

#################################
# pgbar
#################################

pgbar(f, rg; enumerated=false, color=:blue, info_func=((pb, i) -> [(:i, "$(pb.counter) / $(pb.n)")]), kw...) = begin
    ProgressMeter.ijulia_behavior(:clear);
    n = length(rg)
    pbar = prgrsbar(n; color, kw...)
    if toBool(enumerated)
        for (i,x) in enumerate(rg)
            ProgressMeter.next!(pbar; showvalues=info_func(pbar, i))
            f(i,x)
        end
    else
        for (i,x) in enumerate(rg)
            ProgressMeter.next!(pbar; showvalues=info_func(pbar, i))
            f(x)
        end
    end
end

pgbar(f, n::Integer; kw...) = pgbar(f, 1:n; kw...)

