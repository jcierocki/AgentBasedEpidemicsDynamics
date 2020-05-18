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

function simulate(m::AgentModel{T}, max_iter::Int64 = 20, c_count₀::Int64 = 1, i_count₀::Int64 = 0) where T<:AbstractFloat
    if max_iter <= 0 throw(DomainError(max_iter, "argument must be greater than 0")) end

    population = fill(Agent(suspectible, UInt16(0)), nv(m.G))

    view(population, rand(1:nv(m.G), c_count₀)) .= [ Agent(carrier, round(UInt16, rand(m.carrier_time))) for i in 1:c_count₀ ]
    view(population, rand(1:nv(m.G), i_count₀)) .= [ Agent(infected, round(UInt16, rand(m.infected_time))) for i in 1:i_count₀ ]

    s_count, e_count, i_count, c_count, d_count, r_count = Threads.Atomic{Int64}{nv(m.G)-c_count₀-i_count₀}, Threads.Atomic{Int64}{0}, Threads.Atomic{Int64}{i_count₀}, Threads.Atomic{Int64}{c_count₀}, Threads.Atomic{Int64}{0}, Threads.Atomic{Int64}{0}
    state = DataFrame("suspectible"=nv(m.G)-1, "exposed"=e_count[], "infected"=i_count[], "carrier"=c_count[], "dead"=d_count[], "recovered"=r_count[])

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
                    Threads.atomic_sub!(e_count, UInt16(1))
                    if rand() < m.γ
                        population[i] = Agent(infected, round(UInt16, iteration + rand(m.infected_time)))
                        Threads.atomic_add!(i_count, UInt16(1))
                    else
                        population[i] = Agent(carrier, round(UInt16, iteration + rand(m.carrier_time)))
                        Threads.atomic_add!(c_count, UInt16(1))
                    end
                elseif population[i].condition == infected
                    Threads.atomic_sub!(i_count, UInt16(1))
                    population[i].end_time = UInt16(0)
                    if rand() < m.δ
                        population[i].condition = dead
                        Threads.atomic_add!(d_count, UInt16(1))
                    else
                        population[i].condition = recovered
                        Threads.atomic_add!(r_count, UInt16(1))
                    end
                elseif population[i].condition == carrier
                    Threads.atomic_sub!(c_count, UInt16(1))
                    population[i].end_time = UInt16(0)
                    if rand() < m.ζ
                        population[i].condition = suspectible
                        Threads.atomic_add!(s_count, UInt16(1))
                    else
                        population[i].condition = recovered
                        Threads.atomic_add!(r_count, UInt16(1))
                    end
                end
            end
        end

        @inbounds Threads.@threads for i in eachindex(new_infections)
            if new_infections[i] == true
                population[i] = Agent(exposed, round(UInt16, iteration + rand(m.exposed_time)))
            end
        end

        new_infections_numb = sum(new_infections)
        s_count[] -= new_infections_numb
        e_count[] += new_infections_numb

        push!(state, s_count[], e_count[], i_count[], c_count[], d_count[], r_count[])

        iteration += 1
    end

    return state

end

end
