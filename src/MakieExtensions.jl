import AbstractPlotting: convert_arguments
using AbstractPlotting: PointBased



################################################################################
### Sites
################################################################################



# These shouldn't really exist
convert_arguments(P::Type{<:Scatter}, s::S) where {T, D, S<:AbstractSite{T, D}} =
    convert_arguments(P, [p |> point |> Point{D, Float32}])
convert_arguments(P::Type{<:MeshScatter}, s::S) where {T, D, S<:AbstractSite{T, D}} =
    convert_arguments(P, [p |> point |> Point{D, Float32}])


convert_arguments(P::Type{<:Scatter}, s::Vector{S}) where {
    T, D, S<:AbstractSite{T, D}
} = convert_arguments(P, s .|> point .|> Point{D, Float32})
convert_arguments(P::Type{<:MeshScatter}, s::Vector{S}) where {
    T, D, S<:AbstractSite{T, D}
} = convert_arguments(P, s .|> point .|> Point{D, Float32})



################################################################################
### Bonds
################################################################################



# These shouldn't really exist
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



################################################################################
### Lattice
################################################################################



convert_arguments(P::Type{<:Scatter}, l::AbstractLattice) =
    convert_arguments(P, sites(l))
convert_arguments(P::Type{<:MeshScatter}, l::AbstractLattice) =
    convert_arguments(P, sites(l))
convert_arguments(P::Type{<:LineSegments}, l::AbstractLattice) =
    convert_arguments(P, bonds(l), sites(l))
