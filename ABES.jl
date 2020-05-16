#### ABES - Agent-Based Epidemic Simulation

module ABES

import Random
import LightGraphs

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
    infection_time::Int64 = 0
end



end
