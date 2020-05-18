#### ABES - Agent-Based Epidemic Simulation

module ABES

export simulate_base

using Random
using LightGraphs
using Distributions
using Statistics
using DataFrames

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
    end_time::T
end

mutable struct AgentModel{T<:AbstractFloat}
    G::AbstractGraph
    α::T
    β::T
    γ::T
    δ::T
    ζ::T
    exposed_time::Distribution
    infected_time::Distribution
    carrier_time::Distribution
end

function simulate(m::AgentModel{T}, max_iter::Int64 = 20, seed::Int64 = 1234) where T<:AbstractFloat
    if max_iter <= 0 throw(DomainError(max_iter, "argument must be greater than 0")) end

    population = fill(Agent(suspectible, UInt16(0)), nv(m.G))
    population[rand(1:nv(m.G))] = Agent(carrier, UInt16(1))

    state = DataFrame(s=nv(m.G)-1, e=0, i=0, c=1, d=0, r=0)

    iteration = 1
    while iteration <= max_iter

        new_infections = falses(nv(m.G))
        @inbounds Threads.@threads for i in eachindex(population)
            if population[i].condition == carrier
                for j in neighbors(m.G, i)
                    if population[j].condition == suspectible && rand() < m.α && rand() < m.α
                        new_infections[j] = true
                    end
                end
            elseif population[i].condition == infected
                for j in neighbors(m.G, i)
                    if population[j].condition == suspectible && rand() < m.β && rand() < m.β
                        new_infections[j] = true
                    end
                end
            end
        end

        @inbounds Threads.@threads for i in eachindex(population)
            if population[i].end_time > 0 && population[i].end_time == iteration
                if population[i].condition == exposed
                    if rand() < m.γ
                        population[i] = Agent(infected, round(UInt16, iteration + rand(m.infected_time)))
                    else
                        population[i] = Agent(carrier, round(UInt16, iteration + rand(m.carrier_time)))
                    end
                elseif population[i].condition == infected
                    population[i].condition = rand() < m.δ ? dead : recovered
                    population[i].end_time = UInt16(0)
                elseif population[i].condition == carrier
                    population[i].condition = rand() < m.ζ ? suspectible : recovered
                    population[i].end_time = UInt16(0)
                end
            end
        end

        @inbounds Threads.@threads for i in eachindex(new_infections)
            if new_infections[i] == true
                population[i] = Agent(exposed, round(UInt16, iteration + rand(m.exposed_time)))
            end
        end

        return population

        iteration += 1
    end

end

end
