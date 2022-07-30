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
