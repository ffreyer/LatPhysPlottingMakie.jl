################################################################################
#
#   ENERGY MANIFOLD PLOTTING
#
################################################################################

# function to plot an energy manifold (2D)
function plotEnergyManifold(
        em::AEM; color::Vector{<:Integer} = [100,120,255], kwargs...
    ) where {AEM <: AbstractEnergyManifold}
    plotEnergyManifold(em, color = RGB((color ./ 255)...); kwargs...)
end
function plotEnergyManifold(
            em :: AEM
            ;
            # new_figure :: Bool = true,
            figsize :: Tuple = (6,6),
            color :: Colorant = RGB(0.39, 0.37, 1.0),
            plot_bz :: Bool = true,
            ms :: Real = 0.5,
            BZ_corners :: Bool = false,
            kwargs...
        ) where {
            LS, D, S <: AbstractSite{LS,D},
            L, B, UC <: AbstractUnitcell{S,B},
            HB, H <: AbstractHamiltonian{L,UC,HB},
            AEM <: AbstractEnergyManifold{H}
        }


    ###########################
    #   INITIAL SETTINGS
    ###########################

    scene = Scene(resolution = 100 .* figsize, scale_plot = false)
    if plot_bz
        # plot the brillouin zone
        plotBrillouinZone(
            getBrillouinZone(unitcell(hamiltonian(em))),
            figsize=figsize,
            BZ_corners=BZ_corners
        )
    end



    ###########################
    #   PLOT POINTS
    ###########################

    # obtain the points
    k_points = kpoints(em)

    # scatter all points
    Makie.scatter!(scene, kpoints(em), color=color, markersize=ms)

    # return the figure object
    return scene
end


# export plotting function
export plotEnergyManifold





# pass unknown arguments directly to construction of band structure
function plotEnergyManifold(args...; kwargs...)
    # create and plot a bandstructure
    plotEnergyManifold(getEnergyManifold(args...); kwargs...)
end
