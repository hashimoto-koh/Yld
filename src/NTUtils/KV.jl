import DataStructures: OrderedDict

#################################
# KV
#################################

struct KV{K,V}
    k::K
    v::V
end

KV(x) = KV(keys(x), values(x))

KV(d::AbstractDict) = (p = pairs(d); KV(Tuple(x.first for x ∈ p), Tuple(x.second for x ∈ p)))

KV(;x...) = KV(values(x))

(kv::KV)() = Base.pairs(kv)

Base.keys(kv::KV) = kv.k

Base.values(kv::KV) = kv.v

Base.pairs(kv::KV) = ((x=>y) for (x,y) ∈ Iterators.zip(kv.k, kv.v))

Base.Dict(kv::KV) = Base.Dict(pairs(kv))

OrderedDict(kv::KV) = OrderedDict(pairs(kv))

Base.NamedTuple(kv::KV) = Base.NamedTuple(pairs(kv))
# MutableNamedTuples.MutableNamedTuple(kv::KV) = MutableNamedTuples.MutableNamedTuple(;pairs(kv)...)

Base.Dict(x::NamedTuple) = Base.Dict(KV(x))

OrderedDict(x::NamedTuple) = OrderedDict(x |> KV)

# MutableNamedTuples.MutableNamedTuple(x::NamedTuple) = MutableNamedTuples.MutableNamedTuple(x |> KV)

Base.show(io::IO, mime::MIME"text/plain", kv::KV) = begin
    println(io, "KV")
    println(io, "keys:", kv.k)
    println(io, "values:", kv.v)
end
