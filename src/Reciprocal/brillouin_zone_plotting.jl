################################################################################
#
#   FUNCTIONS FOR PLOTTING OF BRILLOUIN ZONES
#
################################################################################

function plot(
            bz::BZ; BZ_color::Vector{<:Integer} = [10,10,10], kwargs...
        ) where {BZ <: AbstractBrillouinZone}
    plot(bz, BZ_color = RGB((BZ_color ./ 255)...); kwargs...)
end
function plot(
            bz :: BZ
            ;
            BZ_corners :: Bool = true,
            BZ_color :: Colorant = RGB(0.04, 0.04, 0.04),
            BZ_corner_size :: Real = 1,
            BZ_linewidth :: Real = 1,
            kwargs...
        ) where {
            L, N, D, P <: AbstractReciprocalPoint{D},
            B <: AbstractBond{L,N},
            R <: AbstractReciprocalUnitcell{P,B},
            BZ <: AbstractBrillouinZone{R}
        }

    scene = AbstractPlotting.current_scene()

    # scatter all corners
    if BZ_corners
        # scatter all corners
        Makie.scatter!(
            scene,
            Point{D, Float32}[c for c in corners(bz)],
            color = BZ_color
        )
    end

    # TODO make this into a mesh, maybe
    # draw the surrounding faces
    for f in faces(bz)
        # obtain lists of x y and z values
        points = [corners(bz)[i] for i in f]
        # push the first element into the lists to close the loops
        push!(points, points[1])
        # plot the BZ face
        Makie.lines!(
            scene,
            points,
            color = BZ_color,
            linewidth = BZ_linewidth
        )
    end
end

# export the plot function
export plot


# Explicit fancy function to plot a Brillouin zone
function plotBrillouinZone(
            bz :: BZ
            ;
            figsize :: Tuple{<:Real, <:Real} = (6,6),
            coordinate_system :: Bool = false,
            kwargs...
        ) where {
            D, L, N, P <: AbstractReciprocalPoint{D},
            B <: AbstractBond{L,N},
            R <: AbstractReciprocalUnitcell{P,B},
            BZ <: AbstractBrillouinZone{R}
        }


    # create a new figure
    scene = Scene(
        resolution = 100 .* figsize,
        scale_plot = false,
        show_axis = coordinate_system
    )

    # plot the lattice
    plot(bz; kwargs...)

    # Idk if this will work
    AbstractPlotting.center!(scene)

    scene
end

# export the plot function
export plotBrillouinZone
