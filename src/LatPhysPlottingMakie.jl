module LatPhysPlottingMakie

using LatPhysBase

using Requires
using Reexport
using LinearAlgebra

@reexport using Colors
@reexport using Makie
using GeometryBasics


# TODO
# Make Makie more usuable:
# - fix stupidly fast rotation
# - maybe change zoom to be screen centered rather than mouse centered
# - speed up translation
# - mess with theme

# Plotting of bonds and sites and other stuff
include("Makie_helpers.jl")
include("helper_functions.jl")
include("colorcodes.jl")

# Generic plotting
include("lattice_plotting_plot.jl")

# Plotting of 2D lattices
include("lattice_plotting_2d.jl")

# Plotting of 3D lattices
include("lattice_plotting_3d.jl")


using LatPhysReciprocal
using LatPhysBandstructures


include("Reciprocal/Reciprocal.jl")
include("Bandstructures/Bandstructures.jl")


include("MakieExtensions.jl")

end # module
