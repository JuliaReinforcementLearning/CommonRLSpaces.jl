abstract type AbstractArraySpace end
# Maybe AbstractArraySpace should have an eltype parameter so that you could call convert(AbstractArraySpace{Float32}, space)

struct Box{A<:AbstractArray} <: AbstractArraySpace
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

struct RepeatedSpace{B, S<:Tuple} <: AbstractArraySpace
    base_space::B
    elsize::S
end

ArraySpace(base_space, size...) = RepeatedSpace(base_space, size)

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
