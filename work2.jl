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
# α = vcat(fill(0.15, 40), fill(0.12, 40), fill(0.06, 40), fill(0.08, 50))
α = 0.09
param_probs = [0.01, 0.5, 0.015, 0.025]

model1 = ABES.AgentModel(ws_graph, α, param_probs..., dists..., 5, 5, 5, pop)
# @time df_results = ABES.simulate(model1, 179)
#
# first(df_results, 60)
# df_results.suspectible[end]
# # plot(α)
#
# plot(df_results.infected, label = :infected)
# plot!(df_results.exposed, label = :exposed)
# plot!(df_results.carrier, label = :carrier)
#
# # CSV.write("data/results_0125_0075_shoct_85_85.csv", df_results)
# # CSV.write("data/results_012_006_0085_85_45_40.csv", df_results)
# CSV.write("data/results_015_012_006_0085_40_40_40_50.csv", df_results)

###########

N_rep = 9
sim_res = Vector{Union{DataFrame, Nothing}}(nothing, N_rep)
@showprogress "Simulating ..." for i in 1:N_rep
    sim_res[i] = ABES.simulate(model1, 179)
end

plt = plot(sim_res[1].infected)
for i in 2:N_rep
    plot!(plt, sim_res[i].infected)
end

plt

total_df = sim_res[1]
total_df.idx = fill(1, 180)
for i in 2:N_rep
    sim_res[i].idx = fill(i, 180)
    append!(total_df, sim_res[i])
end

CSV.write("data/tot_res_009.csv", total_df)

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
