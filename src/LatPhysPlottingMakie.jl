module LatPhysPlottingMakie

using LatPhysBase

using Colors
using Makie


# TODO
# Make Makie more usuable:
# - fix stupidly fast rotation
# - maybe change zoom to be screen centered rather than mouse centered
# - speed up translation
# - mess with theme

# Plotting of bonds and sites and other stuff
include("helper_functions.jl")
include("colorcodes.jl")

# Generic plotting by overwriting PyPlot.plot function
include("lattice_plotting_plot.jl")

# # Plotting of 2D lattices
# include("lattice_plotting_2d.jl")
#
# # Plotting of 3D lattices
# include("lattice_plotting_3d.jl")


end # module
