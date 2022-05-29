# CommonRLSpaces

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaReinforcementLearning.github.io/CommonRLSpaces.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://JuliaReinforcementLearning.github.io/CommonRLSpaces.jl/dev/)
[![Build Status](https://github.com/JuliaReinforcementLearning/CommonRLSpaces.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaReinforcementLearning/CommonRLSpaces.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/JuliaReinforcementLearning/CommonRLSpaces.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/JuliaReinforcementLearning/CommonRLSpaces.jl)
[![Code Style: Blue](https://img.shields.io/badge/code%20style-blue-4495d1.svg)](https://github.com/invenia/BlueStyle)
[![PkgEval](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/C/CommonRLSpaces.svg)](https://JuliaCI.github.io/NanosoldierReports/pkgeval_badges/report.html)

## Usage

### Construction

|Category|Style|Example|
|:---|:----|:-----|
|Enumerable discrete space| `DiscreteSpaceStyle{2, ()}()` | `Space((:cat, :dog))`, `Space(0:1)`, `Space(1:2)`, `Space(Bool)`|
|Multi-dimensional discrete space| `DiscreteSpaceStyle{2, (3,4)}()` | `Space((:cat, :dog), 3, 4)`, `Space(0:1, 3, 4)`, `Space(1:2, 3, 4)`, `Space(Bool, 3, 4)`|
|Multi-dimensional variable discrete space| `DiscreteSpaceStyle{(2,)}()` | `Space(SVector((:cat, :dog), (:litchi, ：longan, ：mango))`, `Space([-1:1, (false, true)])`|
|Continuous space| `ContinuousSpaceStyle()` | `Space(-1.2..3.3)`, `Space(Float32)`|
|Multi-dimensional continuous space| `ContinuousSpaceStyle{(3,4)}()` | `Space(-1.2..3.3, 3, 4)`, `Space(Float32, 3, 4)`|

### API

### Size Info

```julia
```

#### Sampling

```julia
```

### Existence Checking

```julia
```
