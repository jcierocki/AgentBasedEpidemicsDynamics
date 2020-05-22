# #### archive
#
# function simulate_single_thread(m::AgentModel{T,U,V}, max_iter::Int64) where {T<:AbstractFloat, U<:Integer, V<:Unsigned}
#     if max_iter <= 0 throw(DomainError(max_iter, "argument must be greater than 0")) end
#     if typeof(m.α) == Vector{T} && length(m.α) < max_iter throw(DomainError(max_iter, "α can't be shortert that max_iter")) end
#
#     if typeof(m.α) == Vector{T}
#         α_vector = m.α
#     else
#         α_vector = fill(m.α, max_iter)
#     end
#
#     population = deepcopy(m.initial_population)
#
#     S, E, I, C, D, R = nv(m.G)-m.E₀-m.C₀-m.I₀, m.E₀, m.I₀, m.C₀, 0, 0
#     state = DataFrame(suspectible=S, exposed=E, infected=I, carrier=C, dead=D, recovered=R)
#
#     iteration = 1
#     while (E[] + I[] + C[]) > 0 && iteration <= max_iter
#         m.α = α_vector[iteration]
#
#         # println(iteration, " | ", m.α)
#
#         new_infections = falses(nv(m.G))
#         @inbounds for i in eachindex(population)
#             if population[i].condition == carrier
#                 for j in neighbors(m.G, i)
#                     if population[j].condition == suspectible && rand() < m.α && rand() < m.α
#                         new_infections[j] = true
#                     end
#                 end
#             elseif population[i].condition == infected
#                 for j in neighbors(m.G, i)
#                     if population[j].condition == suspectible && rand() < m.β && rand() < m.β
#                         new_infections[j] = true
#                     end
#                 end
#             end
#         end
#
#         @inbounds for i in eachindex(new_infections)
#             if new_infections[i] == true
#                 population[i] = Agent(exposed, round(UInt16, iteration + 1 + rand(m.exposed_time)))
#             end
#         end
#
#         @inbounds for i in eachindex(population)
#             if population[i].end_time > 0 && population[i].end_time == iteration
#                 if population[i].condition == exposed
#                     E -= 1
#                     if rand() < m.γ
#                         population[i] = Agent(infected, round(UInt16, iteration + rand(m.infected_time)))
#                         I += 1
#                     else
#                         population[i] = Agent(carrier, round(UInt16, iteration + rand(m.carrier_time)))
#                         C += 1
#                     end
#                 elseif population[i].condition == infected
#                     I -= 1
#                     population[i].end_time = UInt16(0)
#                     if rand() < m.δ
#                         population[i].condition = dead
#                         D += 1
#                     else
#                         population[i].condition = recovered
#                         R += 1
#                     end
#                 elseif population[i].condition == carrier
#                     C -= 1
#                     population[i].end_time = UInt16(0)
#                     if rand() < m.ζ
#                         population[i].condition = suspectible
#                         S += 1
#                     else
#                         population[i].condition = recovered
#                         R += 1
#                     end
#                 end
#             end
#         end
#
#         new_infections_numb = sum(new_infections)
#         S -= new_infections_numb
#         E += new_infections_numb
#
#         push!(state, (S, E, I, C, D, R))
#
#         iteration += 1
#     end
#
#     return state
#
# end
