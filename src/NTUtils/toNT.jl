import HDF5
import JLD
import H5C
import DataStructures: OrderedDict

#################################
# toNT
#################################

toNT(x) = x

toNT(x::Union{AbstractDict}) = (kv = KV(x); NamedTuple(pairs(KV(Symbol.(kv.k), toNT.(kv.v)))))

toNT(x::Union{Tuple{Vararg{Pair}}, AbstractVector{Pair}}) = toNT(OrderedDict(x))

toNT(; ka...) = toNT(ka)

toNT(o::Union{H5C.H5CJFile, H5C.H5CJGroup}) =
begin
    k = keys(o)
    v = Tuple((child = o(key);
              (isa(child, H5C.AbstH5CDataset) ? H5C.h5cobj(child[].plain) : toNT(child)))
               for key ∈ k)
    (;zip(Symbol.(k),v)...)
end

toNT(o::Union{H5C.H5CHFile, H5C.H5CHGroup}) =
begin
    k = keys(o)
    v = Tuple((child = o(key);
              (isa(child, H5C.AbstH5CDataset) ? H5C.h5cobj(child[]) : toNT(child)))
               for key ∈ k)
    (;zip(Symbol.(k),v)...)
end

toNT(h::Union{HDF5.File, HDF5.Group}) =
begin
    k = keys(h)
    v = Tuple(isa(h[key], HDF5.Dataset) ? H5C.h5cobj(h[key]) : toNT(h[key]) for key ∈ k)
    (;zip(Symbol.(k),v)...)
end

toNT(j::Union{JLD.JldFile, JLD.JldGroup}) =
begin
    k = keys(j)
    v = Tuple(isa(j[key], JLD.JldDataset) ? H5C.h5cobj(h[key].plain) : toNT(j[key]) for key ∈ k)
    (;zip(Symbol.(k),v)...)
end

