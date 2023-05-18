#################################
# helper
#################################

_to_rng(i::Integer) = i>=1 ? (1:i) : (-1:-1:i)
_to_rng(x) = x

###############################
# zip
###############################

@inline ⊕(x, y) = zip(_to_rng(x), _to_rng(y))

@inline ⊕(x::Base.Iterators.Zip, y) = zip(x.is..., _to_rng(y))

@inline ⊕(x::Base.Iterators.Zip, y::Base.Iterators.Zip) = zip(x, y)

@inline ⊕(x...) = zip(x...)

###############################
# product
###############################

@inline ⊗(x, y) = Base.Iterators.product(_to_rng(x), _to_rng(y))

@inline ⊗(x::Base.Iterators.ProductIterator, y) =
    Iterators.product(x.iterators..., _to_rng(y))

@inline ⊗(x::Base.Iterators.ProductIterator, y::Base.Iterators.ProductIterator) =
    Iterators.product(x, y)

@inline ⊗(x...) = Iterators.product(x...)
