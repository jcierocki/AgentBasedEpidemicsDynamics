#### workfile 1

using Statistics
using Distributions
using Plots
using Random
using JLD


# Random.seed!(1234)

#### przesuwamy o 1 bo rozkład musi spełniać f(1) = 0
EX₁ = 5 - 1
max_val1 = 14 - 1
distr_variants1 = [ (round(1-cdf(NegativeBinomial(r,EX₁/(r+EX₁)), max_val1),digits=3), r) for r in 2:0.1:8 ]
r₁ = distr_variants1[findfirst(x->x[1]==0.005, distr_variants1)][2]

neg_bin = NegativeBinomial(r₁, EX₁/(r₁+EX₁))

############

#### dodajemy 0.5 do wartości maksymalnej bo rozkład będzie dyskretyzowany przez zaokrąglanie matematyczne
EX₂ = 14
max_val2 = 42 + 0.5
distr_variants2 = [ (round(1-cdf(LogNormal(log(EX₂)- (σ^2)/2,σ), max_val2),digits=3), σ) for σ in 0.1:0.01:0.6 ]
σ₂ = distr_variants2[findfirst(x->x[1]==0.005, distr_variants2)][2]

log_norm1 = LogNormal(log(EX₂)- (σ₂^2)/2, σ₂)

#############

EX₃ = 10
max_val3 = 28 + 0.5
distr_variants3 = [ (round(1-cdf(LogNormal(log(EX₃)- (σ^2)/2,σ), max_val3),digits=3), σ) for σ in 0.1:0.01:0.6 ]
σ₃ = distr_variants3[findfirst(x->x[1]==0.005, distr_variants3)][2]

log_norm2 = LogNormal(log(EX₃)- (σ₃^2)/2, σ₃)

save("data/duration_dists.jld", Dict{String, Distribution}("F_E" => neg_bin, "F_I" => log_norm1, "F_C" => log_norm2))
