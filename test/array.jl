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

    @testset "ArraySpace with Range" begin
        s = ArraySpace(1:5, 3, 4)
        @test @inferred SpaceStyle(s) == FiniteSpaceStyle()
        @test eltype(s) <: AbstractMatrix{eltype(1:5)}
        @test @inferred ones(Int, 3, 4) in s
        @test @inferred rand(s) in s
        @test rand(s) isa Matrix{Int}
        # @test @inferred bounds(s) == (ones(Int, 3, 4), 5*ones(Int, 3, 4)) # note: not actually required by interface since this is FiniteSpaceStyle
        @test_broken collect(s) isa Vector{Matrix{Int}}
        @test @inferred elsize(s) == (3,4)
    end

    @testset "ArraySpace with IntervalSet" begin
        s = ArraySpace(1..5, 3, 4)
        @test @inferred SpaceStyle(s) == ContinuousSpaceStyle()
        @test eltype(s) <: AbstractMatrix{Float64}
        @test @inferred ones(Float64, 3, 4) in s
        @test @inferred rand(s) in s
        @test rand(s) isa Matrix{Float64}
        @test @inferred bounds(s) == (ones(3, 4), 5*ones(3, 4))
        @test @inferred clamp(zeros(3,4), s) == ones(3,4)
        @test @inferred elsize(s) == (3,4)
    end
end
