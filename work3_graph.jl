#### workfile 3 - ABCD graf

using ABCDGraphGenerator
using LightGraphs
using CSV
using DataFrames

N = 100_000
communities = CSV.read("data/powiaty.csv")
cluster_sizes = sort(collect(communities.numb_of_citizens), rev = true)
cluster_sizes = round.(Int64, cluster_sizes / (sum(cluster_sizes) / N))
# sum(cluster_sizes)
view(cluster_sizes, rand(1:length(cluster_sizes), abs(N - sum(cluster_sizes)))) .-= 1

vertex_degrees = ABCDGraphGenerator.sample_degrees(2.5, 10, 300, N, 500)
sum(vertex_degrees)/N

graph_params1 = ABCDGraphGenerator.ABCDParams(vertex_degrees, cluster_sizes, nothing, 0.3, true, false)

@time edges, clusters = ABCDGraphGenerator.gen_graph(graph_params1)

edges = Edge.(collect(Tuple{Int32, Int32}.(edges)))

graph_model1 = SimpleGraph(edges)

savegraph("data/abcd_graph2.lgz", graph_model1)
