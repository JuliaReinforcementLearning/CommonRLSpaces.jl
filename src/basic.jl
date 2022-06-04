export Space, SpaceStyle, DiscreteSpaceStyle, ContinuousSpaceStyle, TupleSpace, NamedSpace, DictSpace

using Random

struct Space{T}
    s::T
end

Space(s::Type{T}) where {T<:Integer} = Space(typemin(T):typemax(T))
Space(s::Type{T}) where {T<:AbstractFloat} = Space(typemin(T) .. typemax(T))

Space(x, dims::Int...) = Space(Fill(x, dims))
Space(x::Type{T}, dim::Int, extra_dims::Int...) where {T<:Integer} = Space(Fill(typemin(x):typemax(T), dim, extra_dims...))
Space(x::Type{T}, dim::Int, extra_dims::Int...) where {T<:AbstractFloat} = Space(Fill(typemin(x) .. typemax(T), dim, extra_dims...))
Space(x::Type{T}, dim::Int, extra_dims::Int...) where {T} = Space(Fill(T, dim, extra_dims...))

Base.size(s::Space) = size(SpaceStyle(s))
Base.length(s::Space) = length(SpaceStyle(s), s)
Base.getindex(s::Space, i...) = getindex(SpaceStyle(s), s, i...)
Base.:(==)(s1::Space, s2::Space) = s1.s == s2.s

#####

abstract type AbstractSpaceStyle{S} end

struct DiscreteSpaceStyle{S} <: AbstractSpaceStyle{S} end
struct ContinuousSpaceStyle{S} <: AbstractSpaceStyle{S} end

SpaceStyle(::Space{<:Tuple}) = DiscreteSpaceStyle{()}()
SpaceStyle(::Space{<:AbstractVector{<:Number}}) = DiscreteSpaceStyle{()}()
SpaceStyle(::Space{<:AbstractInterval}) = ContinuousSpaceStyle{()}()

SpaceStyle(s::Space{<:AbstractArray{<:Tuple}}) = DiscreteSpaceStyle{size(s.s)}()
SpaceStyle(s::Space{<:AbstractArray{<:AbstractRange}}) = DiscreteSpaceStyle{size(s.s)}()
SpaceStyle(s::Space{<:AbstractArray{<:AbstractInterval}}) = ContinuousSpaceStyle{size(s.s)}()

Base.size(::AbstractSpaceStyle{S}) where {S} = S
Base.length(::DiscreteSpaceStyle{()}, s) = length(s.s)
Base.getindex(::DiscreteSpaceStyle{()}, s, i...) = getindex(s.s, i...)
Base.length(::DiscreteSpaceStyle, s) = mapreduce(length, *, s.s)

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
Base.iterate(::DiscreteSpaceStyle{()}, s::Space, args...) = iterate(s.s, args...)

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