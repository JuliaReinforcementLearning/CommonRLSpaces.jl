using CommonRLSpaces
using Test

@testset "CommonRLSpaces.jl" begin
    @testset "Spaces" begin
        s1 = Space((:cat, :dog))
        @test :cat in s1
        @test !(nothing in s1)

        s2 = Space(0:1)
        @test 0 in s2
        @test !(0.5 in s2)

        s3 = Space(Bool)
        @test false in s3
        @test true in s3

        s4 = Space(Float64)
        @test rand() in s4
        @test 0 in s4

        s5 = Space(Float64, 3, 4)
        @test rand(3, 4) in s5

        s6 = Space(SVector((:cat, :dog), (:litchi, :longan, :mango)))
        @test SVector(:dog, :litchi) in s6

        s7 = Space([-1 .. 1, 2 .. 3])
        @test [0, 2] in s7
        @test !([-5, 5] in s7)

        for _ in 1:100
            for s in [s1, s2, s3, s4, s5, s6, s7]
                @test rand(s) in s
            end
        end
    end

    @testset "Meta Spaces" begin
        s1 = (Space(1:2), Space(Float64, 2, 3))
        @test (1, rand(2, 3)) in s1

        s2 = (a=Space(1:2), b=Space(Float64, 2, 3))
        @test (a=1, b=rand(2, 3)) in s2

        s3 = Dict(:a => Space(1:2), :b => Space(Float64, 2, 3))
        @test Dict(:a => 1, :b => rand(2, 3)) in s3

        for _ in 1:100
            for s in [s1, s2, s3]
                rand(s) in s
            end
        end
    end
end
