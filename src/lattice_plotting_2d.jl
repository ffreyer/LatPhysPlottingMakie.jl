# generic lattice plotting in 2D (with fance everything)
function plotLattice(
    		lattice :: L
            ;
            figsize :: Tuple{<:Real, <:Real} = (8,5), # eh
            coordinate_system :: Bool = false,
            # new_figure :: Bool = false, # Makie only allows one :(
            kwargs...
        ) where {LS,LB,N,S<:AbstractSite{LS,2},B<:AbstractBond{LB,N},U,L<:AbstractLattice{S,B,U}}

    # make a copy of the lattice
    lattice = deepcopy(lattice)
    # shift the new lattice to the center
    center = sum(point.(sites(lattice))) ./ length(sites(lattice))
    for s in sites(lattice)
        point!(s, point(s) .- center)
    end

    # limits, centering
    # Manual centering because I dont know how to do it automatically
    # max_value = maximum([abs(p[i]) for i in 1:2 for p in point.(sites(lattice))])
    xlim = lattice |> sites .|> point .|> (x -> x[1]) |> extrema
    ylim = lattice |> sites .|> point .|> (x -> x[2]) |> extrema
    xlim, ylim = centered_boundaries(figsize[1] / figsize[2], xlim, ylim)

    # limits are weird...
    # and resolution is in pixels
    scene = Makie.Scene(
        resolution = 100 .* figsize,
        limits = FRect(xlim[1], ylim[1], xlim[2]-xlim[1], ylim[2]-ylim[1]),
        scale_plot = false,
        show_axis = coordinate_system
    )

    plot(lattice; kwargs...)

    return scene
end

# export plotting function
export plotLattice
