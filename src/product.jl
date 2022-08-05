product(i1::ClosedInterval, i2::ClosedInterval) = Box(SA[minimum(i1), minimum(i2)], SA[maximum(i1), maximum(i2)])

product(b::Box, i::ClosedInterval) = product(b, convert(Box, i))
product(i::ClosedInterval, b::Box) = product(convert(Box, i), b)
product(b1::Box{<:AbstractVector}, b2::Box{<:AbstractVector}) = Box(vcat(b1.lower, b2.lower), vcat(b1.upper, b2.upper))
function product(b1::Box, b2::Box)
    if size(b1.lower, 2) == size(b2.lower, 2) # same number of columns
        return Box(vcat(b1.lower, b2.lower), vcat(b1.upper, b2.upper))
    else
        return TupleSpaceProduct((b1, b2))
    end
end

# handle case of 3 or more
product(s1, s2, s3, args...) = foldl(product, (s1, s2, s3, args...)) # not totally sure if this should be foldl or foldr

struct TupleProduct{T<:Tuple}
    ss::T
end

"""
    TupleProduct(space1, space2, ...)

Create a space representing the Cartesian product of the argument. Each element is a `Tuple` containing one element from each of the constituent spaces.

Use `subspaces` to access a `Tuple` containing the constituent spaces.
"""
TupleProduct(s1, s2, others...) = TupleProduct((s1, s2, others...))

"Return a `Tuple` containing the spaces used to create a `TupleProduct`"
subspaces(s::TupleProduct) = s.ss

product(s1::TupleProduct, s2::TupleProduct) = TupleProduct(subspaces(s1)..., subspaces(s2)...)

# handle any case not covered elsewhere by making a TupleProduct
# if one of the members is already a TupleProduct, we add put them together in a new "flat" TupleProduct
# note: if we had defined product(s1::TupleProduct, s2) it might be annoying because product(s1, s2::AnotherProduct) would be ambiguous with it
function product(s1, s2)
    if s1 isa TupleProduct
        return TupleProduct(subspaces(s1)..., s2)
    elseif s2 isa TupleProduct
        return TupleProduct(s1, subspaces(s2)...)
    else
        return TupleProduct(s1, s2)
    end
end

SpaceStyle(s::TupleProduct) = promote_spacestyle(map(SpaceStyle, subspaces(s))...)

Base.rand(rng::AbstractRNG, sp::Random.SamplerTrivial{<:TupleProduct}) = map(s->rand(rng, s), subspaces(sp[]))
function Base.in(element, space::TupleProduct)
    @assert length(element) == length(subspaces(space))
    return all(element[i] in s for (i, s) in enumerate(subspaces(space)))
end
Base.eltype(space::TupleProduct) = Tuple{map(eltype, subspaces(space))...}

Base.length(space::TupleProduct) = mapreduce(length, *, subspaces(space))
Base.iterate(space, args...) = iterate(Iterators.product(subspaces(space)...), args...)

function bounds(s::TupleProduct)
    bds = map(bounds, subspaces(s))
    return (first.(bds), last.(bds))
end
Base.clamp(x, s::TupleProduct) = map(clamp, x, subspaces(s))
