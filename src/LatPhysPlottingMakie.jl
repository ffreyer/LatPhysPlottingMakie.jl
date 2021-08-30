module LatPhysPlottingMakie

using Reexport
using LatPhysBase, LatPhysReciprocal, LatPhysBandstructures

using LinearAlgebra, Printf
using Statistics: mean
using GeometryBasics
using Makie, MakieCore
@reexport using Colors

import MakieCore: convert_arguments, PointBased, Plot, default_theme,
    plot!, automatic, Attributes

include("colorcodes.jl")
include("Makie_helpers.jl")
export setup_axis!

include("MakieExtensions.jl")
include("combined_plots.jl")
export BandstructureGUI

end # module
