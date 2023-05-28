abstract type AbstractArraySpace end
# Maybe AbstractArraySpace should have an eltype parameter so that you could call 
# convert(AbstractArraySpace{Float32}, space)

"""
    Box(lower, upper)

A Box represents a space of real-valued arrays bounded element-wise above by `upper` and 
below by `lower`, e.g. `Box([-1, -2], [3, 4]` represents the two-dimensional vector space 
that is the Cartesian product of the two closed sets: ``[-1, 3] \\times [-2, 4]``.

The elements of a Box are always `AbstractArray`s with `AbstractFloat` elements. `Box`es 
always have `ContinuousSpaceStyle`, and products of `Box`es with `Box`es or 
`ClosedInterval`s are `Box`es when the dimensions are compatible.
"""
struct Box{A<:AbstractArray{<:AbstractFloat}} <: AbstractArraySpace
    lower::A
    upper::A

    Box{A}(lower, upper) where {A<:AbstractArray} = new(lower, upper)
end

function Box(lower, upper; convert_to_static::Bool=false)
    @assert size(lower) == size(upper)
    T = promote_type(eltype(lower), eltype(upper)) |> float
    continuous_lower = convert(AbstractArray{T}, lower)
    continuous_upper = convert(AbstractArray{T}, upper)
    if convert_to_static
        final_lower = SArray{Tuple{size(continuous_lower)...}}(continuous_lower)
        final_upper = SArray{Tuple{size(continuous_upper)...}}(continuous_upper)
    else
        final_lower, final_upper = continuous_lower, continuous_upper
    end 
    return Box{typeof(final_lower)}(final_lower, final_upper)
end

function Base.:(==)(b1::T, b2::T) where {T <: Box}
    return (b1.lower == b2.lower) && (b1.upper == b2.upper)
end

# By default, convert builtin arrays to static
Box(lower::Array, upper::Array) = Box(lower, upper; convert_to_static=true)

SpaceStyle(::Box) = ContinuousSpaceStyle()

"""
    Base.rand(::AbstractRNG, ::Random.SamplerTrivial{<:Box})

Generate an array where each element is sampled from a dimension of a Box space.

  * Finite intervals [a,b] are sampled from uniform distributions.
  * Semi-infinite intervals (a,Inf) and (-Inf,b) are sampled from shifted exponential distributions.
  * Infinite intervals (-Inf,Inf) are sampled from normal distributions.

#Example
```julia
julia> using Random: seed!

julia> using Distributions: Uniform, Normal, Exponential

julia> box = Box([-10, -Inf, 3], [10, Inf, Inf])
Box{StaticArraysCore.SVector{3, Float64}}([-10.0, -Inf, 3.0], [10.0, Inf, Inf])

julia> seed!(0); rand(box)
3-element StaticArraysCore.SVector{3, Float64} with indices SOneTo(3):
 -1.8860105821594164
  0.13392275765318448
  3.837385552384043

julia> seed!(0); [rand(Uniform(-10,10)), rand(Normal()), 3+rand(Exponential())]
3-element Vector{Float64}:
 -1.8860105821594164
  0.13392275765318448
  3.837385552384043
```
"""
function Base.rand(rng::AbstractRNG, sp::Random.SamplerTrivial{Box{T}}) where {T}
    box = sp[]
    x = [rand_interval(rng, lb, ub) for (lb, ub) in zip(box.lower, box.upper)]
    return T(x)
end

function rand_interval(rng::AbstractRNG, lb::T, ub::T) where {T <: Real}
    offset, sign = zero(T), one(T)

    if isfinite(lb) && isfinite(ub)
        dist = Uniform(lb, ub)
    elseif isfinite(lb) && !isfinite(ub)
        offset = lb
        dist = Exponential(one(T))
    elseif !isfinite(lb) && isfinite(ub)
        offset = ub
        sign = -one(T)
        dist = Exponential(one(T))
    else
        dist = Normal(zero(T), one(T))
    end

    return offset + sign * rand(rng, dist)
end

Base.in(x::AbstractArray, b::Box) = all(b.lower .<= x .<= b.upper)

Base.eltype(::Box{A}) where A = A
elsize(b::Box) = size(b.lower)

bounds(b::Box) = (b.lower, b.upper)
Base.clamp(x::AbstractArray, b::Box) = clamp.(x, b.lower, b.upper)

Base.convert(t::Type{<:Box}, i::ClosedInterval) = t(SA[minimum(i)], SA[maximum(i)])

"""
    RepeatedSpace(base_space, elsize)

A RepeatedSpace reperesents a space of arrays with shape `elsize`, where each element of 
the array is drawn from `base_space`.
"""
struct RepeatedSpace{B, S<:Tuple} <: AbstractArraySpace
    base_space::B
    elsize::S
end

RepeatedSpace(base_size, elsize...) = RepeatedSpace(base_size, elsize)

SpaceStyle(s::RepeatedSpace) = SpaceStyle(s.base_space)

function Base.rand(rng::AbstractRNG, sp::Random.SamplerTrivial{<:RepeatedSpace})
    return rand(rng, sp[].base_space, sp[].elsize...)
end

Base.in(x::AbstractArray, s::RepeatedSpace) = all(entry in s.base_space for entry in x)

Base.eltype(s::RepeatedSpace) = AbstractArray{eltype(s.base_space), length(s.elsize)}
function Base.eltype(s::RepeatedSpace{<:AbstractInterval})
    return AbstractArray{Random.gentype(s.base_space), length(s.elsize)}
end

elsize(s::RepeatedSpace) = s.elsize

function bounds(s::RepeatedSpace)
    bs = bounds(s.base_space)
    return (Fill(first(bs), s.elsize...), Fill(last(bs), s.elsize...))
end

Base.clamp(x::AbstractArray, s::RepeatedSpace) = map(entry -> clamp(entry, s.base_space), x)

"""
    ArraySpace(base_space, size...)

Constructor for RepeatedSpace and Box.

If `base_space` is an AbstractFloat or ClosedInterval return a Box (preferred), otherwise 
return a RepeatedSpace.
"""
ArraySpace(base_space, size...) = RepeatedSpace(base_space, size)

function ArraySpace(::Type{T}, size...) where {T<:AbstractFloat}
    lower = fill(typemin(T), size)
    upper = fill(typemax(T), size)
    return Box(lower, upper)
end

function ArraySpace(i::ClosedInterval, size...)
    lower = fill(minimum(i), size)
    upper = fill(maximum(T), size)
    return Box(lower, upper)
end