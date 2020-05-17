#### workfile 2

using LightGraphs
using JLD

ws_graph1 = watts_strogatz(UInt32(10_000), 15, 0.3)

transision_dists = load("data/discrete_dists.jld")
model1 = ABES.AgentModel(ws_graph1, fill(0.5, 5)..., values(transision_dists)...)
tmp_result = ABES.simulate(model1, 1)
