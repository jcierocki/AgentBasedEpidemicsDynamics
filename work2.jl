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

dists = load("data/duration_dists.jld")
dists = [dists["F_E"], dists["F_I"], dists["F_C"]]
α = 0.1
param_probs = [α, 0.01, 0.5, 0.015, 0.05]

model1 = ABES.AgentModel(ws_graph2, param_probs..., dists...)
@time df_results = ABES.simulate(model1, 61, 30, 30)

plot(df_results.infected)

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
