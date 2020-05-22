#### workfile 2

using LightGraphs
using JLD
using Distributions
using DataFrames
using Plots
using CSV
using ProgressMeter

# α - prawdopobieństwo spotkania osoby z C
# β - prawdopobieństwo spotkania osoby z I
# γ - prawdopobieństwo trafienia z E do I zamiast C
# δ - prawdopobieństwo zgonu
# ζ - prawdopobieństwo wyzdrowienia bez odporności

# ws_graph = watts_strogatz(UInt32(100_000), 22, 0.3)
ws_graph = loadgraph("data/abcd_graph3.lgz")
pop_df = load("data/ini_pop3.jld", "ini_pop3")
pop = ABES.load_initial_population(pop_df)

dists = load("data/duration_dists.jld")
dists = [dists["F_E"], dists["F_I"], dists["F_C"]]
# α = vcat(range(0.2, 0.16, length=10), range(0.16, 0.07, length=10), range(0.07, 0.057, length=10), range(0.057, 0.065, length=70))
# α = vcat(range(0.2, 0.14, length=20), range(0.14, 0.08, length=10), range(0.08, 0.11, length=70))
α = 0.13
param_probs = [0.01, 0.5, 0.015, 0.025]

model1 = ABES.AgentModel(ws_graph, α, param_probs..., dists..., 5, 5, 5, pop)
# model2 = ABES.AgentModel(graph_model1, param_probs..., dists..., 10, 10, 10, pop)
@time df_results = ABES.simulate(model1, 99)

first(df_results, 60)
# plot(α)

plot(df_results.infected, label = :infected)
plot!(df_results.exposed, label = :exposed)
plot!(df_results.carrier, label = :carrier)

N_rep = 8
sim_res = Vector{Union{DataFrame, Nothing}}(nothing, N_rep)
@showprogress "Simulating ..." for i in 1:N_rep
    sim_res[i] = ABES.simulate(model1, 99)
end

# mean(map(x->x.infected[end], sim_res))
# mean(map(x->x.suspectible[end], sim_res))
# mean(map(x->x.dead[end], sim_res))

plt = plot(sim_res[1].infected)
for i in 2:N_rep
    plot!(plt, sim_res[i].infected)
end

plt

total_df = sim_res[1]
total_df.idx = fill(1, 100)
for i in 2:N_rep
    sim_res[i].idx = fill(i, 100)
    append!(total_df, sim_res[i])
end

CSV.write("data/total_results_015.csv", total_df)

# CSV.write("data/results2.csv", df_results)

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

dat2 = DataFrame(CSV.read("data/total_results_015.csv"))
dat2.idx .+= 8

append!(total_df, dat2)

total_df.idx
