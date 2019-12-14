# generic lattice plotting in 3D (with fancy everything)
function plotLattice(
    		lattice :: L
            ;
            figsize :: Tuple{<:Real, <:Real} = (6,6),
            coordinate_system :: Bool = false,
            # new_figure :: Bool = false,
            kwargs...
        ) where {LS,LB,N,S<:AbstractSite{LS,3},B<:AbstractBond{LB,N},U,L<:AbstractLattice{S,B,U}}

    # make a copy of the lattice
    lattice = deepcopy(lattice)
    # shift the new lattice to the center
    center = sum(point.(sites(lattice))) ./ length(sites(lattice))
    for s in sites(lattice)
        point!(s, point(s) .- center)
    end

    # create a new figure
    # if new_figure
    #     fig = PyPlot.figure(figsize = figsize)
    # else
    #     fig = PyPlot.gcf()
    # end
    scene = Makie.Scene(
        resolution = 100 .* figsize,
        # limits = FRect(xlim[1], ylim[1], xlim[2]-xlim[1], ylim[2]-ylim[1]),
        scale_plot = false,
        show_axis = coordinate_system
    )

    # plot the lattice
    plot(lattice; kwargs...)

    AbstractPlotting.center!(scene)

    # Adjust rotation speed
    cameracontrols(scene).rotationspeed[] = 1f-2

    return scene
end

# export plotting function
export plotLattice
