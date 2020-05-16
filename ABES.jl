#### ABES - Agent-Based Epidemic Simulation

module ABES

export pdf

using Random
using LightGraphs
using Distributions
using Statistics

@enum Condition begin
    suspectible = 1
    exposed = 2
    carrier = 3
    infected = 4
    recovered = 5
    dead = 6
end

mutable struct Agent
    condition::Condition
    incubation_time::Int64
    infection_time::Int64
end

function pdf(d::Union{Distribution, Vector{Float64}}, x::Real)
    if typeof(d) == Vector{Float64}
        @inbounds return x in eachindex(d) ? d[x] : 0
    end

    return pdf(d, x)
end

# α - prawdopobieństwo spotkania osoby z C
# β - prawdopobieństwo spotkania osoby z I
# γ - prawdopobieństwo trafienia z E do I zamiast C
# δ - prawdopobieństwo zgonu
# ζ - prawdopobieństwo wyzdrowienia bez odporności
# inf_dist - rozkład dnia końca inkubacji
# end_dist - rozkład dnia zakończenia choroby (zgon lub wyleczenie)

# function simulate_base(N::Int64, α::Float64, β::Float64)
#
# end

end
