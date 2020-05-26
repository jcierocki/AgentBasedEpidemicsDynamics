#### diagrams

using TikzGraphs
using LightGraphs
using TikzPictures

g = DiGraph(6)
add_edge!(g, 1, 2)
add_edge!(g, 2, 3)
add_edge!(g, 2, 4)
add_edge!(g, 3, 5)
add_edge!(g, 3, 6)
add_edge!(g, 4, 5)
add_edge!(g, 4, 1)

# TikzGraphs.plot(g, ["S", "E", "I"])
plt = TikzGraphs.plot(g, ["S", "E", "I", "C", "R", "D"])

TikzPictures.save(SVG("figures/graph"), plt)
