#### workfile 2

using LightGraphs
using JLD
using Distributions
using DataFrames

# α - prawdopobieństwo spotkania osoby z C
# β - prawdopobieństwo spotkania osoby z I
# γ - prawdopobieństwo trafienia z E do I zamiast C
# δ - prawdopobieństwo zgonu
# ζ - prawdopobieństwo wyzdrowienia bez odporności

ws_graph1 = watts_strogatz(UInt32(1_000_000), 15, 0.3)

dists = collect(values(load("data/duration_dists.jld")))[[3,1,2]]
param_probs = [0.2, 0.05, 0.8, 0.005, 0.05]

model1 = ABES.AgentModel(ws_graph1, param_probs..., dists...)
@time tmp_state, tmp_pop = ABES.simulate(model1, 1000, 3)

first(tmp_result, 40)
last(tmp_result, 40)

length(findall(x -> x.condition == ABES.exposed, tmp_pop))

exposed_subarr = view(tmp_pop, findall(x -> x.condition == ABES.exposed, tmp_pop))

Int16(exposed_subarr[3].end_time)

end_days = map(x -> Int16(x.end_time), exposed_subarr)

pdf(dists[1], 0)
