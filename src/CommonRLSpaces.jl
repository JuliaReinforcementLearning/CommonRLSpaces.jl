module CommonRLSpaces

using Reexport

@reexport using IntervalSets

using StaticArrays
using FillArrays
using Random
using Distributions
import Base: clamp

export
    SpaceStyle,
    AbstractSpaceStyle,
    FiniteSpaceStyle,
    ContinuousSpaceStyle,
    HybridProductSpaceStyle,
    UnknownSpaceStyle,
    AbstractArraySpace,
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
