#### ABES - Agent-Based Epidemic Simulation

module ABES

export simulate_base

using Random
using LightGraphs
using Distributions
using Statistics
using Future
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
            if population[i].condition == exposed && population[i].end_time == iteration

            end
            #### dokończ
        end

        @inbounds Threads.@threads for i in eachindex(new_infections)
            if new_infections[i] == true
                population[i] = Agent(exposed, iteration + round(UInt16, rand(m.exposed_time)))
            end
        end

        return population

        iteration += 1
    end

end

end

# if population[i].condition == suspectible
#     for j in neighbors(m.G, i)
#         r = eval(rexp)
#         if (population[j].condition == carrier && r < m.α) || (population[j].condition == infected && r < m.β)
#             new_infections[i] = true
#         end
#     end
# else
# if population[i].condition == carrier
#     for j in neighbors(m.G, i)
#         if population[j].condition == suspectible && eval(rexp) < m.α
#             new_infections[j] = true
#         end
#     end
# elseif population[i].condition == infected
#     for j in neighbors(m.G, i)
#         if population[j].condition == suspectible && eval(rexp) < m.β
#             new_infections[j] = true
#         end
#     end
# end
