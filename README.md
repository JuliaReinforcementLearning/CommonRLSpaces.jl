# CommonRLSpaces

[![Build Status](https://github.com/JuliaReinforcementLearning/CommonRLSpaces.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaReinforcementLearning/CommonRLSpaces.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/JuliaReinforcementLearning/CommonRLSpaces.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaReinforcementLearning/CommonRLSpaces.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![PkgEval](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/C/CommonRLSpaces.svg)](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/report.html)

## Introduction

A space is simply a set of objects. In a reinforcement learning context, spaces define the sets of possible states, actions, and observations.

In Julia, spaces can be represented by a variety of objects. For instance, a small discrete action set might be represented with `["up", "left", "down", "right"]`, or an interval of real numbers might be represented with an object from the `IntervalSets` package. In general, the space defined by any Julia object is the set of objects `x` for which `x in space` returns `true`.

In addition to establishing the definition above, this package provides three useful tools:
1. Traits to communicate about the properties of spaces, e.g. whether they are continuous or discrete, how many dimensions they have, and how to interact with them.
2. Functions such as `product` for constructing more complex spaces
3. Constructors to for spaces whose elements are arrays, such as `ArraySpace` and `Box`.

## Concepts and Interface

### Interface for all spaces

Since a space is simply a set of objects, a wide variety of common Julia types including `Vector`, `Set`, `Tuple`, and `Dict`<sup>1</sup>can represent a space.
Because of this inclusive definition, there is a very minimal interface that all spaces are expected to implement. Specifically, it consists of 
- `in(x, space)`, which tests whether `x` is a member of the set `space` (this can also be called with the `x in space` syntax).
- `rand(space)`, which returns a valid member of the set<sup>2</sup>.
- `eltype(space)`, which returns the type of the elements in the space.

In addition, the `SpaceStyle` trait is always defined. Calling `SpaceStyle(space)` will return either a `FiniteSpaceStyle`, `ContinuousSpaceStyle`, `HybridSpaceStyle`, or an `UnknownSpaceStyle` object.

### Finite discrete spaces

Spaces with a finite number of elements have `FiniteSpaceStyle`. These spaces are guaranteed to be iterable, implementing Julia's [iteration interface](https://docs.julialang.org/en/v1/manual/interfaces/). In particular `collect(space)` will return all elements in an array.

### Continuous spaces

Continuous spaces represent sets that have an uncountable number of elements they have a `SpaceStyle` of type `ContinuousSpaceStyle`. CommonRLSpaces does not adopt a rigorous mathematical definition of a continuous set, but, roughly, elements in the interior of a continuous space have other elements arbitrarily close to them.
Continuous spaces have two additional interface functions:
- `bounds(space)` returns upper and lower bounds in a tuple. For example, if `space` is a unit circle, `bounds(space)` will return `([-1.0, -1.0], [1.0, 1.0])`. This allows agents to choose policies that appropriately cover the space e.g. a normal distribution with a mean of `mean(bounds(space))` and a standard deviation of half the distance between the bounds.
- [I have a few other ideas, but we can discuss later]

### Hybrid spaces

[need to figure this out]

### Spaces of arrays

[need to figure this out, but I think `elsize(space)` should return the size of the arrays in the space]

---

<sup>1</sup>Note: the elements of a space represented by a `Dict` are key-value `Pair`s.
<sup>2</sup>[TODO: should we make any guarantees about whether `rand(space)` is drawn from a uniform distribution?]

## Usage

### Construction

|Category|Style|Example|
|:---|:----|:-----|
|Enumerable discrete space| `FiniteSpaceStyle{()}()` | `(:cat, :dog)`, `0:1`, `["a","b","c"]` |
|One dimensional continuous space| `ContinuousSpaceStyle{()}()` | `-1.2..3.3`, `Interval(1.0, 2.0)` |
|Multi-dimensional discrete space| `FiniteSpaceStyle{(3,4)}()` | `ArraySpace((:cat, :dog), 3, 4)`, `ArraySpace(0:1, 3, 4)`, `ArraySpace(1:2, 3, 4)`, `ArraySpace(Bool, 3, 4)`|
|Multi-dimensional variable discrete space| `FiniteSpaceStyle{(2,)}()` | `product((:cat, :dog), (:litchi, :longan, :mango))`, `product(-1:1, (false, true))`|
|Multi-dimensional continuous space| `ContinuousSpaceStyle{(2,)}()` or `ContinuousSpaceStyle{(3,4)}()` | `Box([-1.0, -2.0], [2.0, 4.0])`, `product(-1.2..3.3, -4.6..5.0)`, `ArraySpace(-1.2..3.3, 3, 4)`, `ArraySpace(Float32, 3, 4)` |
|Multi-dimensional hybrid space| `HybridSpaceStyle{(2,),()}()` | `product(-1.2..3.3, -4.6..5.0, [:cat, :dog])`, `product(Box([-1.0, -2.0], [2.0, 4.0]), [1,2,3])`|

### API

```julia
julia> using CommonRLSpaces

julia> s = (:litchi, :longan, :mango)

julia> rand(s)
:litchi

julia> rand(s) in s
true

julia> length(s)
3
```

```julia
julia> s = ArraySpace(UInt8, 2,3)

julia> rand(s)
2×3 Matrix{UInt8}:
 0x7b  0x38  0xf3
 0x6a  0xe1  0x28

julia> rand(s) in s
true

julia> SpaceStyle(s)
FiniteSpaceStyle{(2, 3)}()

julia> elsize(s)
(2, 3)
```

```julia
julia> s = product(-1..1, 0..1)

julia> rand(s)
2-element SVector{2, Float64} with indices SOneTo(2):
 0.5563101538643473
 0.9227368869418011

julia> rand(s) in s
true

julia> SpaceStyle(s)
ContinuousSpaceStyle{(2,)}()

julia> elsize(s)
(2,)
```
