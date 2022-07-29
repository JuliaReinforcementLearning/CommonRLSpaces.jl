using Random

#####

abstract type AbstractSpaceStyle end

struct FiniteSpaceStyle <: AbstractSpaceStyle end
struct ContinuousSpaceStyle <: AbstractSpaceStyle end
struct UnknownSpaceStyle <: AbstractSpaceStyle end

SpaceStyle(space::Any) = UnknownSpaceStyle()

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


#=
Base.size(::AbstractSpaceStyle{S}) where {S} = S
Base.length(::FiniteSpaceStyle{()}, s) = length(s.s)
Base.getindex(::FiniteSpaceStyle{()}, s, i...) = getindex(s.s, i...)
Base.length(::FiniteSpaceStyle, s) = mapreduce(length, *, s.s)

#####

Random.rand(rng::Random.AbstractRNG, s::Space) = rand(rng, s.s)

Random.rand(
    rng::Random.AbstractRNG,
    s::Union{
        <:Space{<:AbstractArray{<:Tuple}},
        <:Space{<:AbstractArray{<:AbstractRange}},
        <:Space{<:AbstractArray{<:AbstractInterval}}
    }
) = map(x -> rand(rng, x), s.s)

Base.in(x, s::Space) = x in s.s
Base.in(x, s::Space{<:Type}) = x isa s.s

Base.in(
    x,
    s::Union{
        <:Space{<:AbstractArray{<:Tuple}},
        <:Space{<:AbstractArray{<:AbstractRange}},
        <:Space{<:AbstractArray{<:AbstractInterval}}
    }
) = size(x) == size(s) && all(x -> x[1] in x[2], zip(x, s.s))

function Random.rand(rng::AbstractRNG, s::Interval{:closed,:closed,T}) where {T}
    if s == typemin(T) .. typemax(T)
        rand(T)
    else
        r = rand(rng)

        if r == 0.0
            r = rand(Bool)
        end

        r * (s.right - s.left) + s.left
    end
end

Base.iterate(s::Space, args...) = iterate(SpaceStyle(s), s, args...)
Base.iterate(::FiniteSpaceStyle{()}, s::Space, args...) = iterate(s.s, args...)

#####

const TupleSpace = Tuple{Vararg{Space}}
const NamedSpace = NamedTuple{<:Any,<:TupleSpace}
const VectorSpace = Vector{<:Space}
const DictSpace = Dict{<:Any,<:Space}

Random.rand(rng::AbstractRNG, s::Union{TupleSpace,NamedSpace,VectorSpace}) = map(x -> rand(rng, x), s)
Random.rand(rng::AbstractRNG, s::DictSpace) = Dict(k => rand(rng, s[k]) for k in keys(s))

Base.in(xs::Tuple, ts::TupleSpace) = length(xs) == length(ts) && all(((x, s),) -> x in s, zip(xs, ts))
Base.in(xs::AbstractVector, ts::VectorSpace) = length(xs) == length(ts) && all(((x, s),) -> x in s, zip(xs, ts))
Base.in(xs::NamedTuple{names}, ns::NamedTuple{names,<:TupleSpace}) where {names} = all(((x, s),) -> x in s, zip(xs, ns))
Base.in(xs::Dict, ds::DictSpace) = length(xs) == length(ds) && all(k -> haskey(ds, k) && xs[k] in ds[k], keys(xs))
=#
