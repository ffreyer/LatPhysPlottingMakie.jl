import AbstractPlotting: convert_arguments
import AbstractPlotting: PointBased



################################################################################
### Basic extension
################################################################################


# Sites
convert_arguments(::PointBased, s::S) where {T, D, S<:AbstractSite{T, D}} =
    ([s |> point |> Point{D, Float32}],)
convert_arguments(::PointBased, s::Vector{S}) where {T, D, S<:AbstractSite{T, D}} =
    (s .|> point .|> Point{D, Float32},)



# Bonds

# These shouldn't really exist (single bond from two sites)
for T in (LineSegments, Lines)
    @eval function convert_arguments(P::Type{<:$T}, s1::S, s2::S)  where {
            T, D, S<:AbstractSite{T, D}
        }
        p1 = point(s1)
        p2 = point(s2)
        convert_arguments(P, Point{D, Float32}[p1, p2])
    end
end

# Maybe also wireframe?
function convert_arguments(
        P::Type{<:LineSegments}, bonds::Vector{B}, sites::Vector{S}
    ) where {
        T, D, S <: AbstractSite{T, D}, B <: AbstractBond
    }
    ps = [point(sites[i]) for b in bonds for i in [from(b), to(b)]]
    convert_arguments(P, Point{D, Float32}.(ps))
end

function convert_arguments(
        P::Type{<:MeshScatter}, bonds::Vector{B}, sites::Vector{S}
    ) where {
        T, D, S <: AbstractSite{T, D}, B <: AbstractBond
    }
    convert_arguments(P, sites[bonds .|> from] .|> point .|> Point{D, Float32})
end


# Lattice


convert_arguments(P::Type{<:Scatter}, l::AbstractLattice) =
    convert_arguments(P, sites(l))
convert_arguments(P::Type{<:MeshScatter}, l::AbstractLattice) =
    convert_arguments(P, sites(l))
convert_arguments(P::Type{<:LineSegments}, l::AbstractLattice) =
    convert_arguments(P, bonds(l), sites(l))



# ReciprocalPath
function convert_arguments(::PointBased, p::P) where {
        D, P <: AbstractReciprocalPath{<: AbstractReciprocalPoint{D}}
    }
    (Point{D, Float32}.(point.(points(p))),)
end



################################################################################
### Full extensions
################################################################################



import AbstractPlotting: Plot, default_theme, plot!, automatic, Attributes

# TODO: this probably exists in AbstractPlotting...
const_lift(o::Node) = o
const_lift(x) = Node(x)
#Attributes(p::AbstractPlot; kwargs...) = merge(Attributes(; kwargs...), Attributes(p))



# 3D Lattice
########################################


# TODO: How do I get all default attributes in here and pass them?
function default_theme(scene::SceneLike, ::Type{<: Plot(LT)}) where {
        T, S <: AbstractSite{T, 3}, LT <: AbstractLattice{S}
    }
    Attributes(
        site_color = :orange,
        site_size = 0.1,
        site_marker = Sphere(Point3f0(0), 1f0),
        bond_color = :white,
        bond_width = 0.05
    )
end

function AbstractPlotting.plot!(p::Plot(LT)) where {
        T, S <: AbstractSite{T, 3}, LT <: AbstractLattice{S}
    }
    lattice = const_lift(p[1])
    meshscatter!(
        p, lattice,
        color = p[:site_color], markersize = p[:site_size],
        marker = p[:site_marker]
    )

    # Need to do some explicit construction to make cylinder work
    _sites = map(sites, lattice)
    _bonds = map(bonds, lattice)

    dir = map(_sites, _bonds) do s, bs
        dir = Point{3, Float32}[]
        for b in bs
            p1 = Point{3, Float32}(point(s[from(b)]))
            p2 = Point{3, Float32}(point(s[to(b)]))
            push!(dir, p2 - p1)
        end
        dir
    end

    marker = map(p[:bond_width]) do w
        Cylinder(Point3f0(0), Point3f0(0, 0, 1), Float32(w))
    end

    meshscatter!(
        p, _bonds, _sites,
        marker = marker,
        rotations = map(vs -> normalize.(vs), dir),
        markersize = map(vs -> norm.(vs), dir),
        color = p[:bond_color]
    )
end



# 2D Lattice
########################################


function default_theme(scene::SceneLike, ::Type{<: Plot(L)}) where {
        LS,S<:AbstractSite{LS,2},L<:AbstractLattice{S}
    }
    Attributes(
        site_color = :orange,
        site_size = 20.0,
        site_marker = '●',
        bond_color = :grey,
        bond_width = 3
    )
end

function AbstractPlotting.plot!(p::Plot(L)) where {
        LS,S<:AbstractSite{LS,2},L<:AbstractLattice{S}
    }
    linesegments!(
        p, p[1],
        linewidth = p[:bond_width],
        color = p[:bond_color]
    )

    scatter!(
        p, p[1],
        color = p[:site_color],
        markersize = p[:site_size],
        marker = p[:site_marker]
    )
end



# Reciprocal Path
########################################


# Not gonna do special 3D paths now...
# see lattice recipe if you want to add it
function default_theme(scene::SceneLike, ::Type{<: Plot(P)}) where {P<:AbstractReciprocalPath}
    Attributes(
        markercolor = :gray65,
        linecolor = :black
    )
end

function AbstractPlotting.plot!(p::Plot(P)) where {P <: AbstractReciprocalPath}
    stripped = Attributes(p)
    mc = pop!(stripped, :markercolor)
    lc = pop!(stripped, :linecolor)
    lines!(p, p[1], color = lc; stripped...)
    scatter!(p, p[1], color = mc; stripped...)
end
