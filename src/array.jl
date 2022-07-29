abstract type AbstractArraySpace end

struct Box{A<:AbstractArray} <: AbstractArraySpace
    lower::A
    upper::A

    Box{A}(lower, upper) where {A<:AbstractArray} = new(lower, upper)
end

function Box(lower, upper; convert_to_static=true)
    @assert size(lower) == size(upper)
    sz = size(lower)
    continuous_lower = convert(AbstractArray{similar_continuous_type(eltype(lower))}, lower)
    continuous_upper = convert(AbstractArray{similar_continuous_type(eltype(upper))}, upper)
    if convert_to_static
        final_lower = SArray{Tuple{sz...}}(continuous_lower)
        final_upper = SArray{Tuple{sz...}}(continuous_upper)
    else
        final_lower, final_upper = promote(continuous_lower, continuous_upper)
    end 
    return Box{typeof(final_lower)}(final_lower, final_upper)
end

SpaceStyle(::Box) = ContinuousSpaceStyle()

function Base.rand(rng::AbstractRNG, sp::Random.SamplerTrivial{<:Box})
    box = sp[]
    return box.lower + rand_similar(rng, box.lower) .* (box.upper-box.lower)
end

rand_similar(rng::AbstractRNG, a::StaticArray) = rand(rng, typeof(a))
rand_similar(rng::AbstractRNG, a::AbstractArray) = rand(rng, eltype(a), size(a)...)

similar_continuous_type(T::Type{<:AbstractFloat}) = T
similar_continuous_type(T::Type{<:Number}) = Float64

Base.in(x::AbstractArray, b::Box) = all(b.lower .<= x .<= b.upper)

Base.eltype(::Box{A}) where A = A
elsize(b::Box) = size(b.lower)

bounds(b::Box) = (b.lower, b.upper)
Base.clamp(x::AbstractArray, b::Box) = clamp(x, b.lower, b.upper)
