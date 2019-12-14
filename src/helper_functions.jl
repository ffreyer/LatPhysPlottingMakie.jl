################################################################################
#
#   PLOTTING SITES
#
################################################################################

# PLOTTING SITES IN 2D (but complex)
function plotSiteComplex(
            site    :: AbstractSite,
            radius  :: Real,
            color   :: Vector{<:Integer}
            ;
            kwargs...
        )
    plotSiteComplex(site, radius, RGB((color ./ 255)...); kwargs...)
end
function plotSiteComplex(
            site    :: S,
            radius  :: Real,
            color   :: Colorant
            ;
            kwargs...
        ) where {L,S<:AbstractSite{L,2}}

    p = Point2f0(point(site))
    shape = Circle(Point2f0(0), Float32(radius))
    scene = AbstractPlotting.current_scene()
    Makie.scatter!(scene, [p], marker=shape, color=color)
end

# PLOTTING SITES IN 3D (but complex)
function plotSiteComplex(
            site    :: S,
            radius  :: Real,
            color   :: Colorant
            ;
            detail  :: Int64 = 7,
            kwargs...
        ) where {L,S<:AbstractSite{L,3}}

    shape = Sphere(Point3f0(0), Float32(radius))
    mesh = GLNormalUVMesh(shape, detail)
    scene = AbstractPlotting.current_scene()
    Makie.meshscatter!(scene, Point3f0[point(site)], marker=shape, color=color)
end



# TODO combine 2D and 2D methods
# TODO only need to make site_label_offset generic
function plotSite(
            site    :: AbstractSite,
            radius  :: Real,
            color   :: Vector{<:Integer}
            ;
            kwargs...
        )
    plotSite(site, radius, RGB((color ./ 255)...); kwargs...)
end
# PLOTTING SITES IN 2D
function plotSite(
            site    :: S,
            radius  :: Real,
            color   :: Colorant
            ;
            site_labels :: Bool = true,
            site_label_fontsize :: Real = 12,
            site_label_offset :: Vector{<:Real} = [0.1, 0.0],
            kwargs...
        ) where {L,S<:AbstractSite{L,2}}

    scene = AbstractPlotting.current_scene()
    Makie.scatter!(scene, Point2f0[point(site)], color=color)
    # maybe annotate the label as text
    if site_labels
        Makie.text!(
            scene,
            string(label(site)),
            position = Point2f0(point(site) + site_label_offset),
            textsize = 0.01 * site_label_fontsize,
            color = color
        )
    end
end

# PLOTTING SITES IN 3D
function plotSite(
            site    :: S,
            radius  :: Real,
            color   :: Colorant
            ;
            site_labels :: Bool = true,
            site_label_fontsize :: Real = 12,
            site_label_offset :: Vector{<:Real} = [0.1, 0.0, 0.0],
            kwargs...
        ) where {L,S<:AbstractSite{L,3}}

    scene = AbstractPlotting.current_scene()
    Makie.scatter!(scene, Point3f0[point(site)], color=color)
    # maybe annotate the label as text
    if site_labels
        Makie.text!(
            scene,
            string(label(site)),
            position = Point3f0(point(site) + site_label_offset),
            textsize = 0.01 * site_label_fontsize,
            color = color
        )
    end
end


# plotting based on scattering
# TODO combine 2D and 2D methods
# TODO only need to make site_label_offset generic
function plotSites(
            sites   :: Vector{S},
            radius  :: Real,
            color   :: Vector{<:Integer}
            ;
            kwargs...
        ) where {L,S<:AbstractSite}
    plotSites(sites, radius, RGB((color ./ 255)...); kwargs...)
end
# PLOTTING SITES IN 2D
function plotSites(
            sites   :: Vector{S},
            radius  :: Real,
            color   :: Colorant
            ;
            site_labels :: Bool = true,
            site_label_fontsize :: Real = 12,
            site_label_offset :: Vector{<:Real} = [0.1, 0.0],
            kwargs...
        ) where {L,S<:AbstractSite{L,2}}

    scene = AbstractPlotting.current_scene()
    Makie.scatter!(scene, Point2f0[point(s) for s in sites], color=color, overdraw=true) #zorder=10)
    # maybe annotate the label as text
    if site_labels
        Makie.annotations!(
            scene,
            string.(label.(sites)),
            Point2f0[point(site) + site_label_offset for site in sites],
            textsize = 0.01 * site_label_fontsize,
            color = color
        )
    end
end

# 3D
function plotSites(
            sites   :: Vector{S},
            radius  :: Real,
            color   :: Colorant
            ;
            site_labels :: Bool = true,
            site_label_fontsize :: Real = 12,
            site_label_offset :: Vector{<:Real} = [0.1, 0.0, 0.0],
            kwargs...
        ) where {L,S<:AbstractSite{L,3}}

    # scatter the points
    scene = AbstractPlotting.current_scene()
    # NOTE we want to (mesh?)scatter Sphere() here (for z-order, 3D-nes)
    Makie.scatter!(scene, Point3f0[point(s) for s in sites], color=color)
    # maybe annotate the label as text
    if site_labels
        # TODO vectorized Makie.text?
        Makie.annotations!(
            scene,
            string.(label.(sites)),
            Point3f0[point(site) + site_label_offset for site in sites],
            textsize = 0.01 * site_label_fontsize,
            color = color
        )
    end
end

# 3D


# export the functions
export plotSite, plotSites, plotSiteComplex




################################################################################
#
#   PLOTTING BONDS
#
################################################################################

# PLOTTING BONDS IN 2D
function plotBond(
            site_from :: AbstractSite,
            site_to   :: AbstractSite,
            radius    :: Real,
            color     :: Vector{<:Integer}
            ;
            kwargs...
        ) where {L,D}
    plotBond(site_from, site_to, radius, RGB((color ./ 255)...); kwargs...)
end
function plotBond(
            site_from :: AbstractSite{L,D},
            site_to   :: AbstractSite{L,D},
            radius    :: Real,
            color     :: Colorant
            ;
            kwargs...
        ) where {L,D}

    # TODO radius -> linewidth?
    scene = AbstractPlotting.current_scene()
    Makie.lines!(
        scene,
        Point{D, Float32}[point(site_from), point(site_to)],
        color=color
    )
end



# Plot bonds based on line collections
# https://gist.github.com/gizmaa/7214002#linecollection

# 2D
function plotBonds(
            bonds  :: Vector{B},
            sites  :: Vector{S},
            radius :: Real,
            color  :: Vector{<:Integer}
            ;
            kwargs...
        ) where {S<:AbstractSite, B<:AbstractBond}
    plotBonds(bonds, sites, radius, RGB((color ./ 255)...); kwargs...)
end
function plotBonds(
            bonds  :: Vector{B},
            sites  :: Vector{S},
            radius :: Real,
            color  :: Colorant
            ;
            kwargs...
        ) where {LS, D, S<:AbstractSite{LS,D}, B<:AbstractBond}

    # make a list of all lines
    lines = Point{D, Float32}[]
    for b in bonds
        # get the coordinates to where the bond is pointing
        p1 = Point{D, Float32}(point(sites[from(b)]))
        # get the coordinates to where the bond is pointing
        p2 = Point{D, Float32}(point(sites[to(b)]))
        # push a new entry into the line list
        push!(lines, p1, p2)
    end

    scene = AbstractPlotting.current_scene()
    Makie.linesegments!(scene, lines, color = color) # labels :(
end


# export the functions
export plotBond, plotBonds
