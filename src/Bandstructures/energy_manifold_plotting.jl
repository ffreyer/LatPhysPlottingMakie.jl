################################################################################
#
#   ENERGY MANIFOLD PLOTTING
#
################################################################################

# function to plot an energy manifold (2D)
function plotEnergyManifold(
        em::AEM; color::Vector{<:Integer} = [100,120,255], kwargs...
    ) where {AEM <: AbstractEnergyManifold}
    plotEnergyManifold(em, color = RGBA((color ./ 255)..., 0.4); kwargs...)
end
function plotEnergyManifold(
            em :: AEM
            ;
            # new_figure :: Bool = true,
            figsize :: Tuple = (6,6),
            color :: Colorant = RGBA(0.39, 0.37, 1.0, 0.4),
            plot_bz :: Bool = true,
            ms :: Real = 0.5,
            BZ_corners :: Bool = false,
            method :: Symbol = :contour,

            # For contour plots
            k_min :: Real = -1.0pi,
            k_max :: Real = 2.0pi,
            kx_min :: Real = k_min,
            kx_max :: Real = k_max,
            ky_min :: Real = k_min,
            ky_max :: Real = k_max,
            kz_min :: Real = k_min,
            kz_max :: Real = k_max,
            alpha :: Real = 1.0,
            levels :: Real = 5,

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

    scene = Scene(
        resolution = 100 .* figsize,
        scale_plot = false,
        transparency = true
    )

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
    if method == :contour
        # TODO
        # What should be the range here?
        # Cutting one direction makes things easier to see...
        xs = range(kx_min, kx_max, length=50)
        ys = range(ky_min, ky_max, length=100)
        zs = range(kz_min, kz_max, length=100)
        contour!(
            scene,
            xs, ys, zs,
            (x, y, z) -> minimum(eigvals(matrixAtK(em.h, [x, y, z]))),
            levels = levels,
            alpha = alpha,
            transparency = alpha < 1.0
        )
    else
        # scatter all points
        Makie.scatter!(
            scene,
            Point{D, Float32}.(kpoints(em)),
            color = color,
            markersize = ms,
            transparency = color.alpha < 1.0
        )
    end
    # Adjust rotation speed
    cameracontrols(scene).rotationspeed[] = 1f-2

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
