#### workfile 1

using Statistics
using Distributions
using Plots
using Random
using JLD


Random.seed!(69)

my_x = 1:42

CustomDist = Union{Distribution, Vector{Float64}}

EX = 5
r = 6
p = EX/(r+EX)

neg_bin = NegativeBinomial(r,p)::CustomDist
# neg_bin = [0.5, 0.2, 0.2, 0.1]::CustomDist

plot(pdf(neg_bin, my_x))

pdf(neg_bin, 14)

############

my_x = 1:43

EX = 21
σ = 1/4
μ = log(EX)- (σ^2)/2

log_norm = LogNormal(μ, σ)
plot(pdf(log_norm, my_x))

cdf_discrete = cdf.(log_norm, my_x)
pdf_discrete = cdf_discrete[2:end] - cdf_discrete[1:(end-1)]
# pdf_discrete[42]
pdf_discrete = pdf_discrete / sum(pdf_discrete) .+ 0.05

plot(pdf_discrete)

sum(pdf_discrete[40:42])
sum(pdf_discrete)

#############

# x = rand(20)
# rand(20) .< pdf(neg_bin, 1:20)

res = [sum(rand(20) .< pdf(neg_bin, 1:20)) for i in 1:1000]
sum(res .== 0)/length(res)

res2 = [sum(rand(20) .< pdf(neg_bin, 1:20)) for i in 1:1000]

sum(pdf(neg_bin, 1:20))

pdf_discrete = pdf_discrete .+ 0.05

sum([sum(rand(42) .< [ABES.pdf(pdf_discrete, i) for i in 1:42]) for j in 1:10000] .== 0)/10000

dens_discrete = zeros(42)
lim = [ABES.pdf(pdf_discrete, i) for i in 1:42]

for i in 1:10_000
    dens_discrete .+= rand(42) .< lim
end

dens_discrete = dens_discrete

plot(dens_discrete)
dens_disc = dens_discrete / sum(dens_discrete)

sum(dens_disc[1:21])

pdf_discrete2 = pdf.(neg_bin, 1:14)
pdf_discrete2 = pdf_discrete2 / sum(pdf_discrete2) .+ 0.08
lim2 = pdf_discrete2

sum([sum(rand(42) .< [ABES.pdf(pdf_discrete2, i) for i in 1:42]) for j in 1:10000] .== 0)/10000

plot(lim2)

dens_discrete2 = zeros(14)
for i in 1:10_000
    dens_discrete2 .+= rand(14) .< lim2
end

dens_discrete2 = dens_discrete2 / sum(dens_discrete2)

plot(dens_discrete2)

save("data/discrete_dists.jld", "dist1", pdf_discrete2, "dist2", pdf_discrete)
