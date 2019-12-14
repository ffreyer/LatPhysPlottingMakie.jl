# generic lattice plotting
function plot(
    		lattice :: L
            ;
            site_labels :: Bool = false,
    		site_radius :: Real = 25,
    		bond_thickness :: Real = 8,
    		visualize_periodic :: Bool = false,
    		colorcode_sites :: Union{Symbol,Dict} = Dict(),
    		colorcode_bonds :: Union{Symbol,Dict} = Dict(),
            kwargs...
        ) where {LS,D,LB,N,S<:AbstractSite{LS,D},B<:AbstractBond{LB,N},U,L<:AbstractLattice{S,B,U}}


    ##########-------------------------------
    # STEP 1 #  set the colors correctly
    ##########-------------------------------

    # set the fallback colors (site)
    color_fallback_site = RGB(0.2, 0.2, 0.2)
    label_fallback_site = getDefaultLabel(LS)

    # set the fallback colors (bond)
    color_fallback_bond = RGB(0.04, 0.04, 0.04) # NOTE that light?
    label_fallback_bond = getDefaultLabel(LB)

    # TODO automatically set dictonaries
    if typeof(colorcode_bonds) == Symbol
        if colorcode_bonds == :kitaev || colorcode_bonds == :Kitaev
            colorcode_bonds = generateBondColorcodeKitaev(lattice)
        elseif colorcode_bonds == :random || colorcode_bonds == :Random
            colorcode_bonds = generateBondColorcodeRandom(lattice)
        else
            println("colorcode :$(colorcode_bonds) could not be built, using fallback")
            colorcode_bonds = Dict()
        end
    end
    if typeof(colorcode_sites) == Symbol
        println("colorcode :$(colorcode_sites) could not be built, using fallback")
        colorcode_sites = Dict()
    end


    ##########-------------------------------
    # STEP 2 #  Plotting
    ##########-------------------------------


    ############---------------------
    # STEP 2.1 #  Plot all Bonds
    ############---------------------

    # get all bond labels
    bond_label_list = unique!(label.(bonds(lattice)))
    # iterate over all bond labels
    for l in bond_label_list
        # get all bonds to that label
        bond_list = B[b for b in bonds(lattice) if label(b)==l && from(b)>to(b) && (!isPeriodic(b) || visualize_periodic)]
        color     = get(colorcode_bonds, l, color_fallback_bond)
        # plot the bonds
        plotBonds(
            bond_list,
            sites(lattice),
            bond_thickness,
            color;
            kwargs...
        )
    end




    ############---------------------
    # STEP 2.2 #  Plot all Sites
    ############---------------------

    # get all site labels
    site_label_list = unique!(label.(sites(lattice)))

    # iterate over all site labels
    for l in site_label_list
        # get all sites to that label
        site_list = S[s for s in sites(lattice) if label(s)==l]
        color     = get(colorcode_sites, l, color_fallback_site)
        # plot the site
        plotSites(
            site_list,
            site_radius,
            color;
            site_labels = site_labels,
            kwargs...
        )
    end

    AbstractPlotting.current_scene()
end

# export the plot function
export plot
