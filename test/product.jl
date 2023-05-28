@testset "Product of boxes" begin
    @test product(Box([1], [2]), Box([3], [4])) == Box([1,3], [2,4])
    @test product(Box(ones(2,1), 2*ones(2,1)), Box([3], [4])) == Box(@SMatrix([1;1;3]), @SMatrix([2;2;4]))
end

@testset "Product of intervals" begin
    @test @inferred product(1..2, 3..4) == Box([1,3], [2,4])
    @test @inferred product(1..2, 3..4, 5..6) == Box([1,3,5], [2,4,6])
    @test @inferred product(1..2, 3..4, 5..6, 7..8) == Box([1,3,5,7], [2,4,6,8])
end

@testset "Product of Box and interval" begin
    @test @inferred product(Box([1,3], [2,4]), 5..6) == Box([1,3,5], [2,4,6])
    @test @inferred product(5..6, Box([1,3], [2,4])) == Box([5,1,3], [6,2,4])
end

@testset "TupleProduct discrete" begin
    tp = TupleProduct([1,2], [3,4])
    @test @inferred rand(tp) in tp
    @test (1,3) in tp
    @test !((1,2) in tp)
    @test @inferred eltype(tp) == Tuple{Int, Int}
    @test @inferred SpaceStyle(tp) == FiniteSpaceStyle()
    elems = @inferred collect(tp)
    @test @inferred all(e in tp for e in elems)
    @test @inferred all(e in elems for e in tp)
end

@testset "TupleProduct continuous" begin
    tp = TupleProduct(1..2, 3..4)
    @test @inferred rand(tp) in tp
    @test (1,3) in tp
    @test !((1,2) in tp)
    @test_broken eltype(tp) == Tuple{Float64, Float64} # IntervalSets eltype -> Int64
    @test @inferred SpaceStyle(tp) == ContinuousSpaceStyle()
    @test @inferred bounds(tp) == ((1,3), (2,4))
    @test @inferred bounds(TupleProduct(1..2, 3..4, 5..6)) == ((1,3,5), (2,4,6))
    @test @inferred clamp((0,0), tp) == (1, 3)
end

@testset "TupleProduct hybrid" begin
    tp = TupleProduct(1.0..2.0, [3,4])
    @test @inferred rand(tp) in tp
    @test (1.5,3) in tp
    @test !((1.5,3.5) in tp)
    @test eltype(tp) == Tuple{Float64, Int64}
    @test @inferred SpaceStyle(tp) == HybridSpaceStyle()
end


