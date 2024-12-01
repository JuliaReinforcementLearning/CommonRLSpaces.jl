```@meta
CurrentModule = CommonRLSpaces
```

# CommonRLSpaces

Documentation for [CommonRLSpaces](https://github.com/JuliaReinforcementLearning/CommonRLSpaces.jl).

## Space Styles

```@autodocs
Modules = [CommonRLSpaces]
Filter = t -> typeof(t) === DataType && t <: AbstractSpaceStyle
```

```@docs
SpaceStyle
```

## Interface

Common
 - Base.in
 - Base.rand - https://docs.julialang.org/en/v1/stdlib/Random/#Hooking-into-the-Random-API
 - Base.eltype
 - product

Finite
 - Base.collect

Continuous
 - bounds
 - Base.clamp