#### ABES - Agent-Based Epidemic Simulation

module ABES

export simulate_base, generate_initial_population

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

mutable struct AgentModel{T<:AbstractFloat, U<:Integer, V<:Unsigned}
    G::AbstractGraph
    α::Union{Vector{T},T}
    β::T
    γ::T
    δ::T
    ζ::T
    exposed_time::Distribution
    infected_time::Distribution
    carrier_time::Distribution
    E₀::U
    I₀::U
    C₀::U
    initial_population::Vector{Agent{V}}
end

## zaimplementuj bardziej generycznie typy
function generate_initial_population(N::T, E₀::T, I₀::T, C₀::T, exposed_time::Distribution, infected_time::Distribution, carrier_time::Distribution) where T <: Integer
    population = fill(Agent(suspectible, UInt16(0)), N)

    indexes = rand(1:N, E₀+C₀+I₀)
    view(population, indexes[1:E₀]) .= [ Agent(exposed, round(UInt16, rand(exposed_time)+1)) for i in 1:E₀ ]
    view(population, indexes[(E₀+1):(E₀+C₀)]) .= [ Agent(carrier, round(UInt16, rand(carrier_time))) for i in 1:C₀ ]
    view(population, indexes[(E₀+C₀+1):(E₀+C₀+I₀)]) .= [ Agent(infected, round(UInt16, rand(infected_time))) for i in 1:I₀ ]

    return DataFrame(:Condition => [Int32(a.condition) for a in population],
    :Time => [a.end_time for a in population])
end

function load_initial_population(df::DataFrame)
    return [ Agent(Condition(df.Condition[i]), UInt16(df.Time[i])) for i in 1:nrow(df) ]
end

function simulate(m::AgentModel{T,U,V}, max_iter::Int64) where {T<:AbstractFloat, U<:Integer, V<:Unsigned}
    if max_iter <= 0 throw(DomainError(max_iter, "argument must be greater than 0")) end
    if typeof(m.α) == Vector{T} && length(m.α) < max_iter throw(DomainError(max_iter, "α can't be shortert that max_iter")) end

    if typeof(m.α) == Vector{T}
        α_vector = m.α
    else
        α_vector = fill(m.α, max_iter)
    end

    population = deepcopy(m.initial_population)

    S, E, I, C, D, R = Threads.Atomic{Int64}(nv(m.G)-m.E₀-m.C₀-m.I₀), Threads.Atomic{Int64}(m.E₀), Threads.Atomic{Int64}(m.I₀), Threads.Atomic{Int64}(m.C₀), Threads.Atomic{Int64}(0), Threads.Atomic{Int64}(0)
    state = DataFrame(suspectible=S[], exposed=E[], infected=I[], carrier=C[], dead=D[], recovered=R[], new_inf=0)

    iteration = 1
    while (E[] + I[] + C[]) > 0 && iteration <= max_iter
        m.α = α_vector[iteration]

        println(iteration, " | ", m.α)

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

        @inbounds Threads.@threads for i in eachindex(new_infections)
            if new_infections[i] == true
                population[i] = Agent(exposed, round(UInt16, iteration + 1 + rand(m.exposed_time)))
            end
        end

        newly_matured = Threads.Atomic{Int64}(0)

        @inbounds Threads.@threads for i in eachindex(population)
            if population[i].end_time > 0 && population[i].end_time == iteration
                if population[i].condition == exposed
                    Threads.atomic_sub!(E, 1)
                    if rand() < m.γ
                        population[i] = Agent(infected, round(UInt16, iteration + rand(m.infected_time)))
                        Threads.atomic_add!(I, 1)
                        Threads.atomic_add!(newly_matured, 1)
                    else
                        population[i] = Agent(carrier, round(UInt16, iteration + rand(m.carrier_time)))
                        Threads.atomic_add!(C, 1)
                    end
                elseif population[i].condition == infected
                    Threads.atomic_sub!(I, 1)
                    population[i].end_time = UInt16(0)
                    if rand() < m.δ
                        population[i].condition = dead
                        Threads.atomic_add!(D, 1)
                    else
                        population[i].condition = recovered
                        Threads.atomic_add!(R, 1)
                    end
                elseif population[i].condition == carrier
                    Threads.atomic_sub!(C, 1)
                    population[i].end_time = UInt16(0)
                    if rand() < m.ζ
                        population[i].condition = suspectible
                        Threads.atomic_add!(S, 1)
                    else
                        population[i].condition = recovered
                        Threads.atomic_add!(R, 1)
                    end
                end
            end
        end

        new_infections_numb = sum(new_infections)
        S[] -= new_infections_numb
        E[] += new_infections_numb

        push!(state, (S[], E[], I[], C[], D[], R[], newly_matured[]))

        iteration += 1
    end

    return state

end

end
