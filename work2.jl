#### workfile 2

using LightGraphs
using JLD
using Distributions
using DataFrames
using Plots
using CSV

# α - prawdopobieństwo spotkania osoby z C
# β - prawdopobieństwo spotkania osoby z I
# γ - prawdopobieństwo trafienia z E do I zamiast C
# δ - prawdopobieństwo zgonu
# ζ - prawdopobieństwo wyzdrowienia bez odporności

# ws_graph1 = watts_strogatz(UInt32(1_000_000), 15, 0.3)
ws_graph2 = loadgraph("data/abcd_graph1.lgz")

dists = collect(values(load("data/duration_dists.jld")))[[3,1,2]]
α = 0.3
param_probs = [α, α/4, 0.5, 0.01, 0.05]

model1 = ABES.AgentModel(ws_graph2, param_probs..., dists...)
@time df_results = ABES.simulate(model1, 60, 3)

# CSV.write("data/results1.csv", df_results)
#
# plt1 = plot(tmp_state.suspectible, label = "zdrowy")
# plot!(plt1, tmp_state.recovered, label = "wyzdrowiały")
#
# savefig(plt1, "figures/s_and_r.png")
#
# plt2 = plot(tmp_state.infected, label = "chory")
# plot!(plt2, tmp_state.exposed, label = "inkubacja")
# plot!(plt2, tmp_state.carrier, label = "nosiciel")
# plot!(plt2, tmp_state.dead, label = "zmarły")
#
# savefig(plt2, "figures/i_e_c_d.png")
