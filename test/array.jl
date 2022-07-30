@testset "Box" begin
    @testset "Box with StaticVector" begin
        lower = SA[-1.0, -2.0]
        upper = SA[1.0, 2.0]
        b = Box(lower, upper)
        @test @inferred SpaceStyle(b) == ContinuousSpaceStyle()
        @test eltype(b) <: AbstractArray{Float64}
        @test eltype(b) <: StaticArray
        @test @inferred typeof(rand(b)) == eltype(b)
        @test @inferred [0.0, 0.0] in b
        @test @inferred rand(b) in b
        @test @inferred bounds(b) == (lower, upper)
        @test @inferred clamp(SA[3.0, 4.0], b) in b
        @test @inferred elsize(b) == (2,)
    end

    @testset "Box with Vector{Float64}" begin
        lower = [-1.0, -2.0]
        upper = [1.0, 2.0]
        b = Box(lower, upper; convert_to_static=false)
        @test @inferred SpaceStyle(b) == ContinuousSpaceStyle()
        @test @inferred eltype(b) == Vector{Float64}
        @test @inferred [0.0, 0.0] in b
        @test @inferred rand(b) in b
        @test @inferred bounds(b) == (lower, upper)
        @test @inferred clamp([3.0, 4.0], b) in b
        @test @inferred elsize(b) == (2,)
    end

    @testset "Box with Vector{Int}" begin
        lower = [-1, -2]
        upper = [1, 2]
        b = Box(lower, upper)
        @test @inferred SpaceStyle(b) == ContinuousSpaceStyle()
        @test eltype(b) <: AbstractVector{Float64}
        @test @inferred [0.0, 0.0] in b
        @test @inferred rand(b) in b
        @test @inferred bounds(b) == (lower, upper)
        @test @inferred clamp([3.0, 4.0], b) in b
        @test @inferred elsize(b) == (2,)
    end

    @testset "Box with Matrix" begin
        lower = -[1 2; 3 4]
        upper =  [1 2; 3 4]
        b = Box(lower, upper)
        @test @inferred SpaceStyle(b) == ContinuousSpaceStyle()
        @test eltype(b) <: AbstractMatrix{Float64}
        @test @inferred zeros(2,2) in b
        @test @inferred rand(b) in b
        @test @inferred bounds(b) == (lower, upper)
        @test @inferred clamp([3 -4; 5 -6], b) in b
        @test @inferred elsize(b) == (2,2)
    end
end
