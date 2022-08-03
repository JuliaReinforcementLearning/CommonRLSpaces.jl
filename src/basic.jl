using Random

#####

abstract type AbstractSpaceStyle end

struct FiniteSpaceStyle <: AbstractSpaceStyle end
struct ContinuousSpaceStyle <: AbstractSpaceStyle end
struct UnknownSpaceStyle <: AbstractSpaceStyle end

SpaceStyle(space::Any) = UnknownSpaceStyle()

SpaceStyle(::Tuple) = FiniteSpaceStyle()
SpaceStyle(::NamedTuple) = FiniteSpaceStyle()

function SpaceStyle(x::Union{AbstractArray,AbstractDict,AbstractSet,AbstractRange})
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

function elsize end # note: different than Base.elsize

function bounds end

bounds(i::AbstractInterval) = (infimum(i), supremum(i))
Base.clamp(x, i::AbstractInterval) = IntevalSets.clamp(x, i)
