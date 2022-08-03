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

struct TupleSpaceProduct{T<:Tuple}
    ss::T
end

TupleSpaceProduct(s1, s2, others...) = TupleSpaceProduct((s1, s2, others...))

subspaces(s::TupleSpaceProduct) = s.ss

product(s1::TupleSpaceProduct, s2::TupleSpaceProduct) = TupleSpaceProduct(subspaces(s1)..., subspaces(s2)...)

# handle any case not covered elsewhere by making a TupleSpaceProduct
# if one of the members is already a TupleSpaceProduct, we add put them together in a new "flat" TupleSpaceProduct
# note: if we had defined product(s1::TupleSpaceProduct, s2) it might be annoying because product(s1, s2::AnotherSpace) would be ambiguous with it
function product(s1, s2)
    if s1 isa TupleSpaceProduct
        return TupleSpaceProduct(subspaces(s1)..., s2)
    elseif s2 isa TupleSpaceProduct
        return TupleSpaceProduct(s1, subspaces(s2)...)
    else
        return TupleSpaceProduct(s1, s2)
    end
end

SpaceStyle(s::TupleSpaceProduct) = promote_spacestyle(subspaces(s)...)
