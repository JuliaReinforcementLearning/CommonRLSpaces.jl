module CommonRLSpaces

using Reexport

@reexport using IntervalSets

using StaticArrays
using FillArrays

export
    SpaceStyle,
    AbstractSpaceStyle,
    FiniteSpaceStyle,
    ContinuousSpaceStyle,
    UnknownSpaceStyle,
    bounds,
    elsize

include("basic.jl")

export
    Box,
    ArraySpace

include("array.jl")

export
    product

include("product.jl")

end
