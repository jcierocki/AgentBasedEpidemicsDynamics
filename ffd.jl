#### full factorial design analysis

ws_graph = watts_strogatz(UInt32(100_000), 23, 0.3)
# ws_graph = loadgraph("data/abcd_graph2.lgz")

dists = load("data/duration_dists.jld")
dists = [dists["F_E"], dists["F_I"], dists["F_C"]]
α = 0.0075
param_probs = [0.01, 0.5, 0.015, 0.025]

pop_df = load("data/ini_pop2.jld", "ini_pop2")
pop = ABES.load_initial_population(pop_df)

model_loop = ABES.AgentModel(ws_graph, α, param_probs..., dists..., 3, 3, 3, pop)
range = 0.1:0.005:0.2
df_param_fit = DataFrame()
@showprogress "Simulating ..." for new_alpha in range, _ in 1:64
        model_loop.α = new_alpha
        model_loop.initial_population = ABES.load_initial_population(ABES.generate_initial_population(100_000, 3, 3, 3, dists...))
        df_res = ABES.simulate(model_loop, 69)
        push!(df_param_fit, (pcontact = new_alpha, I_30 = df_res.infected[30], I_50 = df_res.infected[50],
        I_70 = df_res.infected[70], S_70 = df_res.suspectible[70], D_70 = df_res.dead[70], R_70 = df_res.recovered[70]))
end

df_agg = combine(groupby(df_param_fit, :pcontact), :day_30 => mean, :day_50 => mean, :day_70 => mean, :day_70 => x->var(x)/length(x))

df_agg_recovered = combine(groupby(df_param_fit, :pcontact), :R_70 => mean, :R_70 => x->var(x)/length(x))

# CSV.write("data/compare_pcontact_01_02_ws_333_const_pop.csv", df_param_fit)
# CSV.write("data/compare_pcontact_075_014_abcd_333_const_pop.csv", df_param_fit)

# CSV.write("data/compare_pcontact_01_02_abcd_333_var_pop.csv", df_param_fit)
CSV.write("data/compare_pcontact_01_02_ws_333_var_pop.csv", df_param_fit)
