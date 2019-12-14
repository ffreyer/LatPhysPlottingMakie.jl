# function to generate a Kitaev colorcode
function generateBondColorcodeKitaev(
        lattice :: L
    ) :: Dict{LB,RGB} where {
        LB, N, U,
        S <: AbstractSite,
        B <: AbstractBond{LB,N},
        L <: AbstractLattice{S,B,U}
    }

    # put the default kitaev labels with default colors into a dictonary
    return Dict{LB,RGB}(
        getDefaultLabelX(LB) => RGB(1.0, 0.0, 0.0),
        getDefaultLabelY(LB) => RGB(0.0, 1.0, 0.0),
        getDefaultLabelZ(LB) => RGB(0.0, 0.0, 1.0)
    )
end

# function to generate a Kitaev colorcode
function generateBondColorcodeRandom(lattice::AbstractLattice)
    # TODO
    # This would be way better:
    # labels = unique(label.(bonds(lattice)))
    # colors = distinguishable_colors(length(labels)) # or a colormap
    # Dict([lb => color for (lb, color) in zip(labels, colors)])

    return Dict([
        lb => rand(RGB) for lb in unique(label.(bonds(lattice)))
    ])
end
