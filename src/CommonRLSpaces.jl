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
    UnknownSpaceStyle
include("basic.jl")

end
