@testset "Styles of types outside of this package" begin
    struct TestSpace1 end
    @test SpaceStyle(TestSpace1()) == UnknownSpaceStyle()
    @test SpaceStyle((1,2)) == FiniteSpaceStyle()
    @test SpaceStyle((a=1, b=2)) == FiniteSpaceStyle()
    @test SpaceStyle([1,2]) == FiniteSpaceStyle()
    @test SpaceStyle(Dict(:a=>1)) == FiniteSpaceStyle()
    @test SpaceStyle(Set([1,2])) == FiniteSpaceStyle()
    @test SpaceStyle(1..2) == ContinuousSpaceStyle()
end
