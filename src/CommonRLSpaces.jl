module CommonRLSpaces

using Reexport

@reexport using IntervalSets

using StaticArrays
using FillArrays
using Random
import Base: clamp

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
    RepeatedSpace,
    ArraySpace

include("array.jl")

export
    product,
    TupleProduct

include("product.jl")

end
