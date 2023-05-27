abstract type AbstractSpaceStyle end

struct FiniteSpaceStyle <: AbstractSpaceStyle end
struct ContinuousSpaceStyle <: AbstractSpaceStyle end
struct UnknownSpaceStyle <: AbstractSpaceStyle end

"""
    SpaceStyle(space)

Holy-style trait that describes whether the space is continuous, finite discrete, or an unknown type. See CommonRLInterface for a more detailed description of the styles.
"""
SpaceStyle(::Any) = UnknownSpaceStyle()

SpaceStyle(::Tuple) = FiniteSpaceStyle()
SpaceStyle(::NamedTuple) = FiniteSpaceStyle()

function SpaceStyle(x::Union{AbstractArray,AbstractDict,AbstractSet})
    if Base.IteratorSize(x) isa Union{Base.HasLength, Base.HasShape} && length(x) < Inf
        return FiniteSpaceStyle()
    else
        return UnknownSpaceStyle()
    end
end

SpaceStyle(::AbstractInterval) = ContinuousSpaceStyle()

promote_spacestyle(::FiniteSpaceStyle, ::FiniteSpaceStyle) = FiniteSpaceStyle()
promote_spacestyle(::ContinuousSpaceStyle, ::ContinuousSpaceStyle) = ContinuousSpaceStyle()
promote_spacestyle(_, _) = UnknownSpaceStyle()

# handle case of 3 or more
promote_spacestyle(s1, s2, s3, others...) = foldl(promote_spacestyle, (s1, s2, s3, args...))

"Return the size of the objects in a space. This is guaranteed to be defined if the objects in the space are arrays, but otherwise it may not be defined."
function elsize end # note: different than Base.elsize

"""
    bounds(space)

Return a `Tuple` containing lower and upper bounds for the elements in a space.

For example, if `space` is a unit circle, `bounds(space)` will return `([-1.0, -1.0], [1.0, 1.0])`. This allows agents to choose policies that appropriately cover the space e.g. a normal distribution with a mean of `mean(bounds(space))` and a standard deviation of half the distance between the bounds.

`bounds` should be defined for ContinuousSpaceStyle spaces.

# Example
```juliadoctest
julia> bounds(1..2)
(1, 2)
```
"""
function bounds end

"""
    clamp(x, space)

Return an element of `space` that is near `x`.

For example, if `space` is a unit circle, `clamp([2.0, 0.0], space)` might return `[1.0, 0.0]`. This allows for a convenient way for an agent to find a valid action if they sample actions from a distribution that doesn't match the space exactly (e.g. a normal distribution).
"""
function clamp end

bounds(i::AbstractInterval) = (infimum(i), supremum(i))
Base.clamp(x, i::AbstractInterval) = IntevalSets.clamp(x, i)
