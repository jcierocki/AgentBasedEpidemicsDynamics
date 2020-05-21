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

ws_graph = watts_strogatz(UInt32(4_000_000), 15, 0.3)
ws_graph = nothing
# ws_graph = loadgraph("data/abcd_graph1.lgz")
pop_df = load("data/ini_pop3.jld", "ini_pop3")
pop = ABES.load_initial_population(pop_df)

dists = load("data/duration_dists.jld")
dists = [dists["F_E"], dists["F_I"], dists["F_C"]]
α = 0.09
param_probs = [α, 0.01, 0.5, 0.015, 0.025]

model1 = ABES.AgentModel(ws_graph, param_probs..., dists..., 10, 10, 10, pop)
model2 = ABES.AgentModel(graph_model1, param_probs..., dists..., 10, 10, 10, pop)
@time df_results = ABES.simulate(model1, 99)

plot(df_results.infected)

CSV.write("data/results1.csv", df_results)

# model_loop = ABES.AgentModel(ws_graph, param_probs..., dists..., 5, 5, 5, pop)
# range = 0.08:0.005:0.13
# df_param_fit = DataFrame()
# @showprogress "Simulating ..." for new_alpha in range, _ in 1:64
#     model_loop.α = new_alpha
#     df_res = ABES.simulate(model_loop, 69)
#     push!(df_param_fit, (pcontact = new_alpha, day_30 = df_res.infected[30], day_50 = df_res.infected[50], day_70 = df_res.infected[70]))
# end
#
# df_agg = combine(groupby(df_param_fit, :pcontact), :day_30 => mean, :day_50 => mean, :day_70 => mean, :day_70 => x->var(x)/length(x))
#
# CSV.write("data/compare_pcontact.csv", df_param_fit)
# CSV.write("data/compare_pcontact_agg.csv", df_agg)


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
