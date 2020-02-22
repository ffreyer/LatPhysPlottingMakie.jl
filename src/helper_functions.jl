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

# Setup defaults (2D, 3D)
function plotSites(
            sites   :: Vector{<: AbstractSite{L,D}},
            radius  :: Real,
            color   :: Colorant
            ;
            site_labels :: Bool = true,
            site_label_fontsize :: Real = 12,
            site_label_offset :: Vector{<:Real} = Float64[],
            marker = nothing,
            overdraw = nothing,
            kwargs...
        ) where {L, D}
    _plotSites(
        sites, radius, color,
        site_labels = site_labels,
        site_label_fontsize = site_label_fontsize,
        site_label_offset = if isempty(site_label_offset)
            vcat(0.1, [0.0 for _ in 1:D-1])
        else
            site_label_offset
        end,
        marker = if marker == nothing
            Sphere(Point{D, Float32}(0.0), Float32(D == 3 ? radius/25 : radius))
        else
            marker
        end,
        overdraw = overdraw == nothing ? D == 2 : overdraw;
        kwargs...
    )
end
# Actually plot
function _plotSites(
            sites::Vector{<: AbstractSite{L,D}}, radius, color;
            site_labels, site_label_fontsize, site_label_offset,
            marker, overdraw,
            kwargs...
        ) where {L, D}

    # scatter the points
    scene = AbstractPlotting.current_scene()
    # Can we do this better?
    Makie.meshscatter!(
        scene,
        Point{D, Float32}[point(s) for s in sites],
        marker = marker,
        color = color,
        overdraw = overdraw;
        kwargs...
    )

    # maybe annotate the label as text
    if site_labels
        # TODO vectorized Makie.text?
        Makie.annotations!(
            scene,
            string.(label.(sites)),
            Point{D, Float32}[point(site) + site_label_offset for site in sites],
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
        ) where {LS, S<:AbstractSite{LS,2}, B<:AbstractBond}

    # make a list of all lines
    lines = Point{2, Float32}[]
    for b in bonds
        # get the coordinates to where the bond is pointing
        p1 = Point{2, Float32}(point(sites[from(b)]))
        # get the coordinates to where the bond is pointing
        p2 = Point{2, Float32}(point(sites[to(b)]))
        # push a new entry into the line list
        push!(lines, p1, p2)
    end

    scene = AbstractPlotting.current_scene()
    Makie.linesegments!(scene, lines, color = color) # labels :(
end

function plotBonds(
        bonds  :: Vector{<:AbstractBond},
        sites  :: Vector{<:AbstractSite{LS, 3}},
        radius :: Real,
        color  :: Colorant
        ;
        marker = Cylinder(Point3f0(0.0), Point3f0(0, 0, 1), 0.05f0),
        kwargs...
    ) where {LS}


    # make a list of all lines
    startat = Point{3, Float32}[]
    dir = Point{3, Float32}[]
    for b in bonds
        # get the coordinates to where the bond is pointing
        p1 = Point{3, Float32}(point(sites[from(b)]))
        # get the coordinates to where the bond is pointing
        p2 = Point{3, Float32}(point(sites[to(b)]))
        # push a new entry into the line list
        push!(startat, p1)
        push!(dir, p2 - p1)
    end

    scene = AbstractPlotting.current_scene()
    Makie.meshscatter!(
        scene,
        startat,
        marker = marker,
        rotation = normalize.(dir),
        markersize = norm.(dir),
        color = color;
        kwargs...
    )
end


# export the functions
export plotBond, plotBonds
