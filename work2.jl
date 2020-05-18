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

ws_graph1 = watts_strogatz(UInt32(1_000_000), 15, 0.3)

dists = collect(values(load("data/duration_dists.jld")))[[3,1,2]]
param_probs = [0.2, 0.05, 0.8, 0.01, 0.05]

model1 = ABES.AgentModel(ws_graph1, param_probs..., dists...)
@time tmp_state, tmp_pop = ABES.simulate(model1, 1000, 3)

CSV.write("data/results1.csv", tmp_state)

plt1 = plot(tmp_state.suspectible, label = "zdrowy")
plot!(plt1, tmp_state.recovered, label = "wyzdrowiały")

savefig(plt1, "figures/s_and_r.png")

plt2 = plot(tmp_state.infected, label = "chory")
plot!(plt2, tmp_state.exposed, label = "inkubacja")
plot!(plt2, tmp_state.carrier, label = "nosiciel")
plot!(plt2, tmp_state.dead, label = "zmarły")

savefig(plt2, "figures/i_e_c_d.png")

sums = [ sum(view(tmp_state, i, :)) for i in 1:nrow(tmp_state) ]

sum(sums .!= 1_000_000)
