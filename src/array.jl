abstract type AbstractArraySpace end
# Maybe AbstractArraySpace should have an eltype parameter so that you could call convert(AbstractArraySpace{Float32}, space)

"""
    Box(lower, upper)

A Box represents a space of real-valued arrays bounded element-wise above by `upper` and below by `lower`, e.g. `Box([-1, -2], [3, 4]` represents the two-dimensional vector space that is the Cartesian product of the two closed sets: ``[-1, 3] \\times [-2, 4]``.

The elements of a Box are always `AbstractArray`s with `AbstractFloat` elements. `Box`es always have `ContinuousSpaceStyle`, and products of `Box`es with `Box`es or `ClosedInterval`s are `Box`es when the dimensions are compatible.
"""
struct Box{A<:AbstractArray{<:AbstractFloat}} <: AbstractArraySpace
    lower::A
    upper::A

    Box{A}(lower, upper) where {A<:AbstractArray} = new(lower, upper)
end

function Box(lower, upper; convert_to_static::Bool=false)
    @assert size(lower) == size(upper)
    sz = size(lower)
    continuous_lower = convert(AbstractArray{float(eltype(lower))}, lower)
    continuous_upper = convert(AbstractArray{float(eltype(upper))}, upper)
    if convert_to_static
        final_lower = SArray{Tuple{sz...}}(continuous_lower)
        final_upper = SArray{Tuple{sz...}}(continuous_upper)
    else
        final_lower, final_upper = promote(continuous_lower, continuous_upper)
    end 
    return Box{typeof(final_lower)}(final_lower, final_upper)
end

# By default, convert builtin arrays to static
Box(lower::Array, upper::Array) = Box(lower, upper; convert_to_static=true)

SpaceStyle(::Box) = ContinuousSpaceStyle()

function Base.rand(rng::AbstractRNG, sp::Random.SamplerTrivial{<:Box})
    box = sp[]
    return box.lower + rand_similar(rng, box.lower) .* (box.upper-box.lower)
end

rand_similar(rng::AbstractRNG, a::StaticArray) = rand(rng, typeof(a))
rand_similar(rng::AbstractRNG, a::AbstractArray) = rand(rng, eltype(a), size(a)...)

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

Base.rand(rng::AbstractRNG, sp::Random.SamplerTrivial{<:RepeatedSpace}) = rand(rng, sp[].base_space, sp[].elsize...)

Base.in(x::AbstractArray, s::RepeatedSpace) = all(entry in s.base_space for entry in x)
Base.eltype(s::RepeatedSpace) = AbstractArray{eltype(s.base_space), length(s.elsize)}
Base.eltype(s::RepeatedSpace{<:AbstractInterval}) = AbstractArray{Random.gentype(s.base_space), length(s.elsize)}
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