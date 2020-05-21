#### workfile 4 - initial populations

using JLD
using Distributions

dists = load("data/duration_dists.jld")
dists = [dists["F_E"], dists["F_I"], dists["F_C"]]

ini_pop1 = ABES.generate_initial_population(1_000_000, 10, 10, 10, dists...)
ini_pop2 = ABES.generate_initial_population(100_000, 5, 5, 5, dists...)
ini_pop3 = ABES.generate_initial_population(4_000_000, 20, 20, 20, dists...)

save("data/ini_pop1.jld", "ini_pop1", ini_pop1)
save("data/ini_pop2.jld", "ini_pop2", ini_pop2)
save("data/ini_pop3.jld", "ini_pop3", ini_pop3)
