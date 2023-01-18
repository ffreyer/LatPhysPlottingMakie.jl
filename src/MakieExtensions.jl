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


# Brillouin Zone
function convert_arguments(P::Type{<:Scatter}, bz::BZ) where {
        D, PT <: AbstractReciprocalPoint{D},
        R <: AbstractReciprocalUnitcell{PT},
        BZ <: AbstractBrillouinZone{R}
    }
    convert_arguments(P, Point{D, Float32}[c for c in corners(bz)])
end

# TODO mabye duplicate points for sharp edges?
function BZ_to_mesh(bz::BZ) where {
        D, PT <: AbstractReciprocalPoint{D},
        R <: AbstractReciprocalUnitcell{PT},
        BZ <: AbstractBrillouinZone{R}
    }
    # I assume that every face is flat and rotates around a central point
    points = Point{D, Float32}.(corners(bz))
    _faces = GLTriangleFace[]
    for f in LatPhysReciprocal.faces(bz)
        center = mean(points[f])
        push!(points, center)
        c = length(points)
        append!(_faces, GLTriangleFace.(c, f[1:end-1], f[2:end]))
        push!(_faces, GLTriangleFace(c, f[end], f[1]))
    end
    normal_mesh(points, _faces)
end
function convert_arguments(P::Type{<: MakieCore.Mesh}, bz::AbstractBrillouinZone)
    convert_arguments(P, BZ_to_mesh(bz))
end
function convert_arguments(P::Type{<: Wireframe}, bz::AbstractBrillouinZone)
    convert_arguments(P, BZ_to_mesh(bz))
end

# Only really works with one face
function convert_arguments(P::Type{<:Lines}, bz::AbstractBrillouinZone)
    points = Point{D, Float32}.(corners(bz))
    face_points = [points[i] for f in LatPhysReciprocal.faces(bz) for i in [f..., f[1]]]
    convert_arguments(P, face_points)
end

function convert_arguments(P::Type{<:LineSegments}, bz::BZ) where {
        D, PT <: AbstractReciprocalPoint{D},
        R <: AbstractReciprocalUnitcell{PT},
        BZ <: AbstractBrillouinZone{R}
    }
    points = Point{D, Float32}.(corners(bz))
    face_points = Point{D, Float32}[]
    for f in LatPhysReciprocal.faces(bz)
        ps = [points[i] for i in [f..., f[1]] for _ in 1:2][2:end-1]
        append!(face_points, ps)
    end
    convert_arguments(P, face_points)
end



# Bandstructure (doesn't really make sense for anything but scatter, whatever)
function convert_arguments(P::Type{<:Scatter}, bs::AbstractBandstructure)
    k_point_indices = zeros(Int64, length(energies(bs))+1)
    points = Point2f[]
    for s in 1:length(energies(bs))
        k_point_indices[s+1] = length(energies(bs)[s][1]) + k_point_indices[s] - 1
        xvals = range(k_point_indices[s], stop=k_point_indices[s+1], length=length(energies(bs)[s][1]))
        for band in energies(bs)[s]
            append!(points, Point2f.(xvals, band))
        end
    end
    convert_arguments(P, points)
end

function convert_arguments(P::Type{<:LineSegments}, bs::AbstractBandstructure)
    k_point_indices = zeros(Int64, length(energies(bs))+1)
    points = Point2f[]
    for s in 1:length(energies(bs))
        k_point_indices[s+1] = length(energies(bs)[s][1]) + k_point_indices[s] - 1
        xvals = range(k_point_indices[s], stop=k_point_indices[s+1], length=length(energies(bs)[s][1]))
        for band in energies(bs)[s]
            append!(points, [p for p in Point2f.(xvals, band) for _ in 1:2][2:end-1])
        end
    end
    convert_arguments(P, points)
end


# Energy Manifold
function convert_arguments(P::Type{<:Scatter}, em::EM) where {
        LS, D, S <: AbstractSite{LS,D},
        L, UC <: AbstractUnitcell{S},
        H <: AbstractHamiltonian{L,UC},
        EM <: AbstractEnergyManifold{H}
    }
    convert_arguments(P, Point{D, Float32}.(kpoints(em)))
end
function convert_arguments(P::Type{<:Contour}, em::AbstractEnergyManifold)
    convert_arguments(P,
        range(-2pi, 2pi, length=100),
        range(-2pi, 2pi, length=100),
        (x, y) -> minimum(eigvals(matrixAtK(em.h, [x, y])))
    )
end
# Why doesn't this work?
# function convert_arguments(P::Type{<:Contour}, em::EM) where {
#         LS, S <: AbstractSite{LS,3},
#         L, UC <: AbstractUnitcell{S},
#         H <: AbstractHamiltonian{L,UC},
#         EM <: AbstractEnergyManifold{H}
#     }
#     xs = range(-2pi, 2pi, length=100)
#     ys = range(-2pi, 2pi, length=100)
#     zs = range(-2pi, 2pi, length=100)
#     values = [
#         minimum(eigvals(matrixAtK(em.h, [x, y, z])))
#         for x in xs, y in ys, z in zs
#     ]
#     convert_arguments(Contour3d, values)
# end


################################################################################
### Full extensions
################################################################################


# TODO: this probably exists in Makie...
const_lift(o::Observable) = o
const_lift(x) = Observable(x)
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
        site_marker = Sphere(Point3f(0), 1f0),
        site_matcap = nothing,
        bond_color = :white,
        bond_width = 0.05,
        bond_matcap = nothing
    )
end

function plot!(p::Plot(LT)) where {
        T, S <: AbstractSite{T, 3}, LT <: AbstractLattice{S}
    }
    lattice = const_lift(p[1])

    attr = copy(p.attributes)
    bond_width = pop!(attr, :bond_width)
    bond_color = pop!(attr, :bond_color)
    bond_matcap = pop!(attr, :bond_matcap)

    site_color      = pop!(attr, :site_color)
    site_markersize = pop!(attr, :site_size)
    site_marker     = pop!(attr, :site_marker)
    site_matcap     = pop!(attr, :site_matcap)

    bond_attributes = merge(attr, Attributes(
        color = bond_color, matcap = bond_matcap
    ))

    site_attributes = merge(attr, Attributes(
        color = site_color, markersize = site_markersize,
        marker = site_marker, matcap = site_matcap
    ))
    meshscatter!(p, lattice; site_attributes...)

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
    
    marker = map(bond_width) do w
        Cylinder(Point3f(0), Point3f(0, 0, 1), Float32(w))
    end

    merge!(bond_attributes, Attributes(
        marker = marker,
        rotations = map(vs -> normalize.(vs), dir),
        markersize = map(vs -> norm.(vs), dir)
    ))
    meshscatter!(p, _bonds, _sites; bond_attributes...)
end



# 2D Lattice
########################################


function default_theme(scene::SceneLike, ::Type{<: Plot(L)}) where {
        LS,S<:AbstractSite{LS,2},L<:AbstractLattice{S}
    }
    scatter_defaults = default_theme(scene, Scatter)
    line_defaults = default_theme(scene, Lines)
    Attributes(
        site_color = :orange,
        site_size = scatter_defaults[:markersize][],
        site_marker = scatter_defaults[:marker][],
        bond_color = :grey,
        bond_width = line_defaults[:linewidth][]
    )
end

function plot!(p::Plot(L)) where {
        LS,S<:AbstractSite{LS,2},L<:AbstractLattice{S}
    }
    bond_attributes = Attributes(
        linewidth  = pop!(p.attributes, :bond_width),
        color      = pop!(p.attributes, :bond_color)
    )

    site_attributes = Attributes(
        color       = pop!(p.attributes, :site_color),
        markersize  = pop!(p.attributes, :site_size),
        marker      = pop!(p.attributes, :site_marker),
    )

    merge!(site_attributes, p.attributes)
    scatter!(p, p[1]; site_attributes...)

    merge!(bond_attributes, p.attributes)
    linesegments!(p, p[1]; bond_attributes...)
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

function plot!(p::Plot(P)) where {P <: AbstractReciprocalPath}
    stripped = Attributes(p)
    mc = pop!(stripped, :markercolor)
    lc = pop!(stripped, :linecolor)
    lines!(p, p[1], color = lc; stripped...)
    scatter!(p, p[1], color = mc; stripped...)
end



# Reciprocal Path
########################################

# TODO: use spheres as corners?
function default_theme(scene::SceneLike, ::Type{<: Plot(BZ)}) where {BZ<:AbstractBrillouinZone}
    Attributes(
        BZ_corners = true
    )
end

function plot!(p::Plot(BZ)) where {BZ <: AbstractBrillouinZone}
    linesegments!(p, p[1]; Attributes(p)...)
    scatter!(p, p[1]; Attributes(p)..., visible=p[:BZ_corners])
end



# Bandstructure
########################################

# Not using lines here to make this very... interactive?
# Using scatter allows us to collect all points here, which means
# the number of bands in a bandstructure can also change without breaking the plot
function default_theme(scene::SceneLike, ::Type{<: Plot(BS)}) where {BS <: AbstractBandstructure}
    Attributes()
end

function plot!(p::Plot(BS)) where {BS <: AbstractBandstructure}
    linesegments!(p, const_lift(p[1]); Attributes(p)...)
end


