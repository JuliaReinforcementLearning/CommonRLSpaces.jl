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

    @testset "Box comparison" begin
        @test Box([1,2], [3,4]) == Box([1,2], [3,4])
        @test Box([1,2], [3,4]) != Box([1,3], [3,4])
    end

    @testset "Box type check" begin
        T =  [
            BigFloat, Float64, Float32, Float16,
            BigInt, Int128, Int64, Int32, Int16, Int8,
            UInt128, UInt64, UInt16, UInt32, UInt8
        ]
        for T1 in T, T2 in T
            x, y = [1,2], [3,4]
            box = Box(T1.(x), T2.(y))
            T_goal = float(promote_type(T1, T2))
            box_goal = Box{SVector{2, T_goal}}(
                SVector{2,T_goal}(T_goal.(x)), 
                SVector{2,T_goal}(T_goal.(y))
            )
            @testset "$T1, $T2" begin
                @test box == box_goal
            end 
        end
    end

    @testset "Box random sample" begin
        box = Box([-10, -Inf, 3, -Inf], [10, Inf, Inf, 6])
        Random.seed!(0)
        x = rand(box)
        Random.seed!(0)
        y = SA[rand(Uniform(-10, 10)), rand(Normal()), 3+rand(Exponential()), 6-rand(Exponential())]
        @test x == y
    end

    @testset "Interval to box conversion" begin
        @test convert(Box, 1..2) == Box([1], [2])
    end
end

@testset "RepeatedSpace" begin
    @testset "RepeatedSpace with Range" begin
        s = RepeatedSpace(1:5, 3, 4)
        @test @inferred SpaceStyle(s) == FiniteSpaceStyle()
        @test eltype(s) <: AbstractMatrix{eltype(1:5)}
        @test @inferred ones(Int, 3, 4) in s
        @test @inferred rand(s) in s
        @test rand(s) isa Matrix{Int}
        # @test @inferred bounds(s) == (ones(Int, 3, 4), 5*ones(Int, 3, 4)) # note: not actually required by interface since this is FiniteSpaceStyle
        @test_broken collect(s) isa Vector{Matrix{Int}}
        @test @inferred elsize(s) == (3,4)
    end

    @testset "RepeatedSpace with IntervalSet" begin
        s = RepeatedSpace(1..5, 3, 4)
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
