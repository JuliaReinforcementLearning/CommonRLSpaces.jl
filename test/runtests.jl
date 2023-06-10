using CommonRLSpaces
using Test

using StaticArrays
using Distributions
using Random

@testset "CommonRLSpaces.jl" begin
    include("basic.jl")
    include("array.jl")
    include("product.jl")
end
