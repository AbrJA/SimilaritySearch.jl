# This file is a part of SimilaritySearch.jl
# License is Apache 2.0: https://www.apache.org/licenses/LICENSE-2.0.txt

using SimilaritySearch
using Test
#
# This file contains a set of tests for SearchGraph over databases of vectors (of Float32)
#

@testset "vector indexing with SearchGraph" begin
    # NOTE: The following algorithms are complex enough to say we are testing it doesn't have syntax errors, a more grained test functions are requiered
    ksearch = 10
    n, m, dim = 10_000, 100, 4

    db = [rand(Float32, dim) for i in 1:n]
    queries = [rand(Float32, dim) for i in 1:m]

    dist = SqL2Distance()
    seq = ExhaustiveSearch(dist, db, ksearch)
    perf = Performance(seq, queries, ksearch)

    for search_algo in [IHCSearch()]  #, BeamSearch()]
        #for neighborhood_algo in [ SatNeighborhood(), VorNeighborhood()]
        for neighborhood_algo in [FixedNeighborhood(16), LogNeighborhood(), LogSatNeighborhood()]
            graph = SearchGraph(dist, db;
                search_algo=search_algo,
                neighborhood_algo=neighborhood_algo,
                automatic_optimization=false)
            @test probe(perf, graph).macrorecall >= 0.9
        end
    end
end
