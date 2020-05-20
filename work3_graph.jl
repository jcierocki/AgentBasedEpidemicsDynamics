#### workfile 3 - ABCD graf

using ABCDGraphGenerator
using LightGraphs
using CSV
using DataFrames
using GraphIO

N = 1_000_000
communities = CSV.read("data/powiaty.csv")
cluster_sizes = sort(collect(communities.numb_of_citizens), rev = true)
cluster_sizes = round.(Int64, cluster_sizes / (sum(cluster_sizes) / N))
view(cluster_sizes, rand(1:length(cluster_sizes), N - sum(cluster_sizes))) .+= 1

vertex_degrees = ABCDGraphGenerator.sample_degrees(2.5, 10, 300, N, 500)
sum(vertex_degrees)/N

graph_params1 = ABCDGraphGenerator.ABCDParams(vertex_degrees, cluster_sizes, nothing, 0.3, true, false)

@time edges, clusters = ABCDGraphGenerator.gen_graph(graph_params1)

edge_pair_df = DataFrame(edges)
CSV.write("data/abcd_edges.txt", edge_pair_df, writeheader=false)

graph_moddel1 = loadgraph("data/abcd_edges.txt", "graph_key", EdgeListFormat())
graph_model1 = graph_moddel1

vert1 = vertices(graph_model1)

savegraph("data/abcd_graph1.lgz", graph_model1)
