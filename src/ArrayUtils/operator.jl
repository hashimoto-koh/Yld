import ..LoopUtils: to_rng

###############################
# zip
###############################

@inline ⊕(x, y) = zip(to_rng(x), to_rng(y))

@inline ⊕(x::Base.Iterators.Zip, y) = zip(x.is..., to_rng(y))

@inline ⊕(x::Base.Iterators.Zip, y::Base.Iterators.Zip) = zip(x, y)

@inline ⊕(x...) = zip(x...)

###############################
# product
###############################

@inline ⊗(x, y) = Base.Iterators.product(to_rng(x), to_rng(y))

@inline ⊗(x::Base.Iterators.ProductIterator, y) =
    Iterators.product(x.iterators..., to_rng(y))

@inline ⊗(x::Base.Iterators.ProductIterator, y::Base.Iterators.ProductIterator) =
    Iterators.product(x, y)

@inline ⊗(x...) = Iterators.product(x...)

###############################
# product
###############################

@inline ×(x, y) = ⊗(x, y)

@inline ×(x...) = ⊗(x...)
