###########
# tee
###########

tee(f) = x -> (f(x); x)

###########
# wt
###########
#=
3 | wt / sqrt / println | square
=#

struct WT end
const wt = WT()

struct _wt <: Function
    l
    _wt() = (v = Vector{Any}(); sizehint!(v, 10); new(v))
end

Base.:/(::WT, f) = _wt() / functionize(f)
Base.:&(::WT, f) = _wt() & functionize(f)
Base.:/(w::_wt, f) = (push!(w.l, functionize(f)); w)
Base.:&(w::_wt, f) = w / f
(w::_wt)(x) = (reduce((x,f)->f(x), w.l; init=x); x)

###########
# wm
###########
#=
[3,4] | wm / sqrt == [3,4] .| sqrt
=#

struct WM end
const wm = WM()

struct _wm <: Function
    l
    _wm() = (v = Vector{Any}(); sizehint!(v, 10); new(v))
end

Base.:/(::WM, f) = _wm() / functionize(f)
Base.:&(::WM, f) = _wm() & functionize(f)
Base.:/(w::_wm, f) = (push!(w.l, functionize(f)); w)
Base.:&(w::_wm, f) = w / f
(w::_wm)(x) = x .| (x -> reduce((x,f)->f(x), w.l; init=x))

