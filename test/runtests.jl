using CommonRLSpaces
using Test

@testset "CommonRLSpaces.jl" begin
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

    # for _ in 1:100
    for s in [s1, s2, s3, s4, s5, s6, s7]
        @info s
        @test rand(s) in s
    end
    # end
end
