#### ABES - Agent-Based Epidemic Simulation

module ABES

export simulate_base

using Random
using LightGraphs
using Distributions
using Statistics
using Future

@enum Condition begin
    suspectible = 1
    exposed = 2
    carrier = 3
    infected = 4
    recovered = 5
    dead = 6
end

mutable struct Agent{T<:Unsigned}
    condition::Condition
    inf_duration::T
end

mutable struct AgentModel{T<:AbstractFloat}
    G::AbstractGraph
    α::T
    β::T
    γ::T
    δ::T
    ζ::T
    exposed_time::Vector{T}
    infected_time::Vector{T}
    carrier_time::Vector{T}
end

# α - prawdopobieństwo spotkania osoby z C
# β - prawdopobieństwo spotkania osoby z I
# γ - prawdopobieństwo trafienia z E do I zamiast C
# δ - prawdopobieństwo zgonu
# ζ - prawdopobieństwo wyzdrowienia bez odporności
# mature_dist - rozkład dnia końca inkubacji
# remove_dist - rozkład dnia zakończenia choroby (zgon lub wyleczenie)

function check_time_to_move(rng::MersenneTwister, time::T,
    discrete_dist::Vector{U}) where T <: Unsigned where U <: AbstractFloat

    if time > length(discrete_dist)
        return true
    else
        return rand(rng) < discrete_dist[time]
    end
end

function simulate(m::AgentModel{T}, max_iter::U) where T<:AbstractFloat where U<:Integer
    if n <= 1 throw(DomainError(n, "argument must be greater than 0")) end

    rngs = let m = MersenneTwister(1234)
            [m; accumulate(Future.randjump, fill(big(10)^20, Threads.nthreads()-1), init=m)]
        end

    population = fill(Agent(suspectible, UInt16(0)), nv(m.G))
    population[rand(rngs[1], 1:nv(m.G))] = Agent(infected, UInt16(1))

    state = DataFrame(s=n-1, e=0, i=1, c=0, d=0, r=0)

    iteration = 1
    while iteration < max_iter

        condition_changes = zeros(Int8, nv(m.G))
        Threads.@threads for i in eachindex(population)
            if population[i].condition == suspectible
                for j in neighbors(m.G, i)
                    r = rand(rngs[Threads.threadid()])
                    if (population[j].condition == carrier && r < α) || (population[j].condition == infected && r < β)
                        becomes_exposed[i] = Int8(1)
                    end
                end
            elseif population[i].condition == carrier
                for j in neighbors(m.G, i)
                    r = rand(rngs[Threads.threadid()])
                    if population[j].condition == suspectible && r < α
                        becomes_exposed[j] = Int8(1)
                    end
                end
                if check_time_to_move(rngs[Threads.threadid()], population[i].inf_duration, m.carrier_time)
                    condition_changes[i] = rand(rngs[Threads.threadid()]) < ζ ? Int8(7) : Int8(6)
                end
            elseif population[i].condition == suspectible
                for j in neighbors(m.G, i)
                    r = rand(rngs[Threads.threadid()])
                    if population[j].condition == suspectible && r < β
                        becomes_exposed[j] = Int8(1)
                    end
                end
                if check_time_to_move(rngs[Threads.threadid()], population[i].inf_duration, m.infected_time)
                    condition_changes[i] = rand(rngs[Threads.threadid()]) < δ ? Int8(4) : Int8(5)
                end
            elseif population[i].condition == exposed
                if check_time_to_move(rngs[Threads.threadid()], population[i].inf_duration, m.exposed_time)
                    condition_changes[i] = rand(rngs[Threads.threadid()]) < γ ? Int8(2) : Int8(3)
                end
            end
        end

    end





end

end
