#################################
# to_rng
#################################

to_rng(i::Integer) = i>=1 ? (1:i) : (-1:-1:i)
to_rng(x) = x
to_rng(x...) = Iterators.product(to_rng.(x)...)
