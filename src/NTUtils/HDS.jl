import DataStructures: OrderedDict
import HDF5
import JLD2
import H5C
using ..FuncUtils: functionize

### func tags
## _Prp
struct _Prp{T} g::T end
struct _PrpFnc{F} f::F end
Base.setproperty!(x::_Prp, a::Symbol, f) = Base.setproperty!(x.g, a, _PrpFnc(functionize(f)))

## _Req
struct _Req{T} g::T end
struct _ReqFnc{F} f::F end
Base.setproperty!(x::_Req, a::Symbol, f) = Base.setproperty!(x.g, a, _ReqFnc(functionize(f)))

## _Mth
struct _Mth{T} g::T end
struct _MthFnc{F} f::F end
Base.setproperty!(x::_Mth, a::Symbol, f) = Base.setproperty!(x.g, a, _MthFnc(functionize(f)))

## _Fnc
struct _Fnc{T} g::T end
struct _FncFnc{F} f::F end
Base.setproperty!(x::_Fnc, a::Symbol, f) = Base.setproperty!(x.g, a, _FncFnc(functionize(f)))

# helper funcs
supertypeof(x::T) where {T} =
    (isempty(T.parameters) ? supertype(T) : T.name.wrapper)

#################################
# AbstHDS
#################################

abstract type AbstHDS{T} <: Function end
Base.propertynames(hds::AbstHDS) = Base.keys(hds)
Base.hasproperty(hds::AbstHDS, p::Symbol) = p in Base.propertynames(hds)
Base.show(io::IO, mime::MIME"text/plain", x::AbstHDS) = Base.show(io, mime, x._)
..InfoUtils._printnmdtpl(io, d::AbstHDS, k="", str="") = ..InfoUtils._printnmdtpl(io, d._, k, str)
Base.getkey(hds::AbstHDS, p::Symbol) = _HDS(_getkey(hds, p))
_HDS(x) = x

Base.delete!(hds::AbstHDS) = Base.delete!(hds, Base.keys(hds))
Base.delete!(hds::AbstHDS, p::Vararg{Symbol}) = Base.delete!(hds, p)
Base.delete!(hds::AbstHDS, p::Tuple{Vararg{Symbol}}) = (for k in p delkey!(hds, k) end; hds)

#################################
# HDS
#################################

mutable struct HDS{T} <: AbstHDS{T}
    _::T
end
HDS{T}(;kw...) where {T} = HDS{T}(T(KV(;kw...)))

_copy(x) = x
_copy(x::HDS{T}) where {T} = T(KV(keys(x), _copy.(_HDS.(values(x)))))
Base.copy(x::HDS{T}) where {T} = HDS{T}(_copy(x))

# _HDS(x::T)
Base.keys(hds::AbstHDS) = Base.keys(hds._)
Base.values(hds::AbstHDS) = Base.values(hds._)
Base.haskey(hds::AbstHDS, p::Symbol) = Base.haskey(hds._, p)
_getkey(hds::AbstHDS, p::Symbol) = Base.getproperty(hds._, p)
# addkey!(hds::HDS{T}, p::Symbol, x)
# delkey!(hds::HDS{T}, p::Symbol)
# setkey!(hds::HDS{T}, p::Symbol, x)
newkey!(hds::HDS{T}, p::Symbol) where {T} = addkey!(hds, p, T())
Base.getproperty(hds::AbstHDS, p::Symbol) = begin
    Base.hasfield(typeof(hds), p) && (return Base.getfield(hds, p))
    p == :prp && (return _Prp(hds))
    p == :req && (return _Req(hds))
    p == :mth && (return _Mth(hds))
    p == :fnc && (return _Fnc(hds))

    if Base.haskey(hds, p)
        x = Base.getkey(hds, p)
        isa(x, _PrpFnc)  && (return x.f(hds))
        isa(x, _ReqFnc)  && (y = x.f(hds); Base.setproperty!(hds, p, y); return y)
        isa(x, _MthFnc)  && (return (a...; ka...) -> x.f(hds, a...; ka...))
        isa(x, _FncFnc)  && (return (a...; ka...) -> x.f(hds._, a...; ka...))

        return Base.getkey(hds, p)
    else
        error("""this HDS does not have a property named '$(p)'.""")
    end
    # Base.haskey(hds, p) && (return Base.getkey(hds, p))
    # error("""this HDS does not have a property named '$(p)'.""")

    # newkey!(hds, p)
    # Base.getkey(hds, p)
end
Base.setproperty!(hds::AbstHDS, p::Symbol, x) = begin
    Base.hasfield(typeof(hds), p) && (Base.setfield!(hds, p, x); return)
    setkey!(hds, p, x)
end

#################################
# HDct, HODct
#################################

HDct = HDS{Dict}
HODct = HDS{OrderedDict}
_HDS(x::T) where T <: AbstractDict = HDS{supertypeof(x)}(x)
_getkey(hds::HDS{T}, p::Symbol) where T <: AbstractDict = hds._[p]
addkey!(hds::HDS{T}, p::Symbol, x) where T <: AbstractDict = (hds._[p] = x; hds)
delkey!(hds::HDS{T}, p::Symbol) where T <: AbstractDict = (delete!(hds._, p); hds)
setkey!(hds::HDS{T}, p::Symbol, x) where T <: AbstractDict = (hds._[p] = x; hds)
toNT(hds::HDS{T}) where T <: AbstractDict = (;hds._...)

#################################
# HNT
#################################

HNT = HDS{NamedTuple}
_HDS(x::NamedTuple) = HNT(x)
HDS{NamedTuple}(x::H5C.AbstH5CParent) = HNT(toNT(x))
addkey!(hds::HNT, p::Symbol, x) =
    (hds._ = NamedTuple{(keys(hds._)..., p)}((values(hds._)..., x)); hds)
delkey!(hds::HNT, p::Symbol) =
    (hds._ = NamedTuple((k,v) for (k,v) in pairs(hds._) if k != p); hds)
setkey!(hds::HNT, p::Symbol, x) = begin
    # (haskey(hds, p) && delkey!(hds, p); addkey!(hds, p, x))
    !haskey(hds, p) && (return addkey!(hds, p, x))

    hds._ = let
        vls = values(hds)
        kys = keys(hds)
        n = findfirst(x -> x == p, kys)
        NamedTuple(zip(kys, (vls[1:n-1]..., x, vls[n+1:end]...)))
    end
    hds
end
toNT(hds::HNT) = hds._
toj2(x::HNT, filename::AbstractString, mode=:a; kw...) =
    toj2(toNT(x), filename, mode; kw...)

clear!(x::HNT) = (x._ = (;); x)

### MutableNamedTuple
#=
HMNT = HDS{MNT}
_HDS(x::MNT) = HMNT(x)
Base.haskey(hds::HMNT, p::Symbol) = p ∈ Base.keys(hds)
addkey!(hds::HMNT, p::Symbol, x) =
    (hds._ = MNT(;(NamedTuple{(keys(hds._)..., p)}((values(hds._)..., x)))...); hds)
delkey!(hds::HMNT, p::Symbol) =
    (hds._ = MNT(;NamedTuple((k,v) for (k,v) in pairs(hds._) if k != p)...); hds)
setkey!(hds::HMNT, p::Symbol, x) = begin
    try
        Base.setproperty!(hds._, p, x)
    catch
        # (haskey(hds, p) && delkey!(hds, p); addkey!(hds, p, x))
        !haskey(hds, p) && (return addkey!(hds, p, x))
        nt = let
            kys, vls = keys(hds), values(hds)
            n = findfirst(x -> x == p, kys)
            NamedTuple(zip(kys, (vls[1:n-1]..., x, vls[n+1:end]...)))
        end
        hds._ = MNT(;nt...)
        hds
    end
end
ToNamedTuple.toNT(hds::HMNT) = ToNamedTuple.toNT(hds._)
toj2(x::HMNT, filename::AbstractString, mode=:a; kw...) =
    toj2(ToNamedTuple.toNT(x), filename, mode; kw...)
=#

#################################
# HD5
#################################

HDS{HDF5.Group}(filename::String, mode::Symbol; kw...) =
    HDS{HDF5.Group}(filename, string(mode); kw...)
HDS{HDF5.Group}(filename::String, mode::String="cw"; kw...) = begin
    (mode == "a") && (mode = "cw")

    h = HD5(HDF5.h5open(filename, mode)["/"])
    for (k,v) in pairs(kw)
        addkey!(h, k, v)
    end
    h
end
HD5 = HDS{HDF5.Group}
Base.close(h::HD5) = Base.close(h._.file)
Base.keys(hds::HD5) = Tuple(Symbol.(Base.keys(hds._)))
Base.values(hds::HD5) = Tuple(getkey(hds, k) for k in Base.keys(hds))
_read(x) = x
_read(x::HD5) = Base.read(x)
Base.read(h::HD5) = NamedTuple{keys(h)}(_read.(values(h)))
_HDS(x::HDF5.Group) = HD5(x)
_getkey(hds::HD5, p::Symbol) =
    # (x = Base.getindex(Base.getfield(hds, :_), string(p));
    # isa(x, HDF5.Group) ? x : HDF5.read(x))
    begin
        x = Base.getindex(Base.getfield(hds, :_), string(p));
        isa(x, HDF5.Group) && (return x)
        if isa(x, HDF5.Dataset)
            ndims(HDF5.dataspace(x)) == 0 && (return HDF5.read(x))
            HDF5.ismmappable(x) && (return HDF5.readmmap(x))
            return HDF5.read(x)
        end
        x
    end
addkey!(hds::HD5, p::Symbol, x) = (hds._[string(p)] = x; hds)
addkey!(hds::HD5, p::Symbol, x::NamedTuple) = begin
    g = HDS(HDF5.create_group(hds._, string(p)))
    for (k,v) in pairs(x)
        addkey!(g, k ,v)
    end
    hds
end
delkey!(hds::HD5, p::Symbol) = (HDF5.delete_object(hds._, string(p)); hds)
setkey!(hds::HD5, p::Symbol, x) = (haskey(hds, p) && delkey!(hds, p); addkey!(hds, p, x))
newkey!(hds::HD5, p::Symbol) = addkey!(hds, p, (;))
Base.haskey(hds::HD5, p::Symbol) = p in Base.keys(hds)
# Base.haskey(hds::HD5, p::Symbol) = Base.haskey(hds._, String(p))

toNT(hds::HD5) = read(hds)
fromhd5(filename::AbstractString) = (h = HD5(filename, "r"); nt = toNT(h); close(h); nt)

#################################
# JD2
#################################

HDS{JLD2.JLDFile}(filename::String, mode::Symbol; kw...) =
    HDS{JLD2.JLDFile}(filename, string(mode); kw...)
HDS{JLD2.JLDFile}(filename::String, mode::String="a"; kw...) = begin
    (mode == "a") && (mode = "a+")

    h = JD2(JLD2.jldopen(filename, mode))
    for (k,v) in pairs(kw)
        addkey!(h, k, v)
    end
    h
end

JD2  = HDS{JLD2.JLDFile}
JD2G = HDS{JLD2.Group}
JD2U = Union{JD2, JD2G}

_HDS(x::JLD2.JLDFile)  = JD2(x)
_HDS(x::JLD2.Group) = JD2G(x)

Base.close(h::JD2) = Base.close(h._)
Base.keys(hds::JD2U) = Tuple(Symbol.(Base.keys(hds._)))
Base.values(hds::JD2U) = Tuple(getkey(hds, k) for k in Base.keys(hds))
Base.haskey(hds::JD2U, p::Symbol) = p in Base.keys(hds)

_read(x::JD2U) = Base.read(x)
Base.read(h::JD2U) = NamedTuple{keys(h)}(_read.(values(h)))

_getkey(hds::JD2U, p::Symbol) = (x = hds._[string(p)]; isa(x, JLD2.Group) ? JD2G(x) : x)
addkey!(hds::JD2U, p::Symbol, x) = begin
    hds._[string(p)] = x
    hds
end
addkey!(hds::JD2U, p::Symbol, x::NamedTuple) = begin
    g = JD2G(JLD2.Group(hds._, string(p)))
    for (k,v) in pairs(x)
        addkey!(g, k ,v)
    end
    hds
end
# delkey!(hds::JD2U, p::Symbol)
setkey!(hds::JD2U, p::Symbol, x) = addkey!(hds, p, x)
newkey!(hds::JD2U, p::Symbol) = addkey!(hds, p, (;))

toNT(hds::JD2U) = read(hds)
fromj2(filename) = (j = JD2(filename, "r"); t = read(j); close(j); t)
toj2(x::NamedTuple, filename::AbstractString, mode=:a; kw...) = toj2(filename, mode; x..., kw...)
toj2(filename::AbstractString, mode=:a; kw...) = close(JD2(filename, mode; kw...))
