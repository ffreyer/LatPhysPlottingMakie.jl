module LatPhysPlottingMakie

using Reexport
using LatPhysBase, LatPhysReciprocal, LatPhysBandstructures

using LinearAlgebra, Printf
using Statistics: mean
using GeometryBasics
@reexport using Makie, Makie.AbstractPlotting.MakieLayout
@reexport using Colors

import AbstractPlotting: convert_arguments, PointBased, Plot, default_theme,
                         plot!, automatic, Attributes

include("colorcodes.jl")
include("Makie_helpers.jl")
export setup_axis!

include("MakieExtensions.jl")
include("combined_plots.jl")
export BandstructureGUI

end # module
