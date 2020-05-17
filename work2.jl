#### workfile 2

using LightGraphs
using JLD
using Future


# α - prawdopobieństwo spotkania osoby z C
# β - prawdopobieństwo spotkania osoby z I
# γ - prawdopobieństwo trafienia z E do I zamiast C
# δ - prawdopobieństwo zgonu
# ζ - prawdopobieństwo wyzdrowienia bez odporności

ws_graph1 = watts_strogatz(UInt32(1000), 15, 0.3)

dists = collect(values(load("data/duration_dists.jld")))[[3,1,2]]
param_probs = [0.2, 0.05, 0.8, 0.005, 0.05]

model1 = ABES.AgentModel(ws_graph1, param_probs..., dists...)
tmp_result = ABES.simulate(model1, 1)

res_idx = findall(x -> x.condition == ABES.exposed, tmp_result)
Int16(tmp_result[res_idx[1]].end_time)

values(dists)
