product(i1::ClosedInterval, i2::ClosedInterval) = Box(SA[minimum(i1), minimum(i2)], SA[maximum(i1), maximum(i2)])

product(b::Box, i::ClosedInterval) = product(b, convert(Box, i))
product(i::ClosedInterval, b::Box) = product(convert(Box, i), b)
product(b1::Box{<:AbstractVector}, b2::Box{<:AbstractVector}) = Box(vcat(b1.lower, b2.lower), vcat(b1.upper, b2.upper))
function product(b1::Box, b2::Box)
    if size(b1.lower, 2) == size(b2.lower, 2) # same number of columns
        return Box(vcat(b1.lower, b2.lower), vcat(b1.upper, b2.upper))
    else
        return GenericrSpaceProduct((b1, b2))
    end
end

# handle case of 3 or more
product(s1, s2, s3, args...) = product(product(s1, s2), s3, args...)

struct GenericrSpaceProduct{T<:Tuple}
    members::T
end

# handle any case not covered above
product(s1, s2) = GenericrSpaceProduct((s1, s2))
product(s1::GenericrSpaceProduct, s2) = GenericrSpaceProduct((s1.members..., s2))
