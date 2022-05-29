export Space, SpaceStyle, DiscreteSpaceStyle, ContinuousSpaceStyle, TupleSpace, NamedSpace, DictSpace

using Random

struct Space{T}
    s::T
end

Space(s::Type{T}) where {T} = Space(typemin(T):typemax(T))

Space(x, dims::Int...) = Space(fill(x, dims))
Space(x::Type{T}, dims::Int...) where {T<:Integer} = Space(fill(typemin(x):typemax(T), dims))
Space(x::Type{T}, dims::Int...) where {T<:AbstractFloat} = Space(fill(typemin(x) .. typemax(T), dims))

Base.size(s::Space) = size(SpaceStyle(s))

#####

abstract type AbstractSpaceStyle{S} end

Base.size(::AbstractSpaceStyle{S}) where {S} = S

struct DiscreteSpaceStyle{S} <: AbstractSpaceStyle{S} end
struct ContinuousSpaceStyle{S} <: AbstractSpaceStyle{S} end

SpaceStyle(::Space{<:Tuple}) = DiscreteSpaceStyle{()}()
SpaceStyle(::Space{<:AbstractRange}) = DiscreteSpaceStyle{()}()
SpaceStyle(::Space{<:AbstractInterval}) = ContinuousSpaceStyle{()}()

SpaceStyle(s::Space{<:AbstractArray{<:Tuple}}) = DiscreteSpaceStyle{size(s.s)}()
SpaceStyle(s::Space{<:AbstractArray{<:AbstractRange}}) = DiscreteSpaceStyle{size(s.s)}()
SpaceStyle(s::Space{<:AbstractArray{<:AbstractInterval}}) = ContinuousSpaceStyle{size(s.s)}()

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

#####

const TupleSpace = Tuple{Vararg{<:Space}}
const NamedSpace = NamedTuple{<:Any,<:TupleSpace}
const DictSpace = Dict{<:Any,<:Space}

Random.rand(rng::AbstractRNG, s::Union{TupleSpace,NamedSpace}) = map(x -> rand(rng, x), s)
Random.rand(rng::AbstractRNG, s::DictSpace) = Dict(k => rand(rng, s[k]) for k in keys(s))

Base.in(xs::Tuple, ts::TupleSpace) = length(xs) == length(ts) && all(((x, s),) -> x in s, zip(xs, ts))
Base.in(xs::NamedTuple{names}, ns::NamedTuple{names,<:TupleSpace}) where {names} = all(((x, s),) -> x in s, zip(xs, ns))
Base.in(xs::Dict, ds::DictSpace) = length(xs) == length(ds) && all(k -> haskey(ds, k) && xs[k] in ds[k], keys(xs))