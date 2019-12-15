
"""
    centered_boundaries(aspect, xlim, ylim)
"""
function centered_boundaries(aspect, xlim, ylim)
    xmin, xmax, ymin, ymax = centered_boundaries(aspect, xlim..., ylim...)
    (xmin, xmax), (ymin, ymax)
end
"""
    centered_boundaries(aspect, xmin, xmax, ymin, ymax)
"""
function centered_boundaries(aspect, xmin, xmax, ymin, ymax)
    current_aspect = (xmax - xmin) / (ymax - ymin)
    if aspect >= current_aspect
        # fix height, pad width
        dw = (xmax - xmin) * (aspect / current_aspect - 1.0)
        xmin -= 0.5dw
        xmax += 0.5dw
    else
        # fix width, pad height
        dh = (ymax - ymin) * (current_aspect / aspect - 1.0)
        ymin -= 0.5dh
        ymax += 0.5dh
    end

    xmin, xmax, ymin, ymax
end


function bz_to_mesh(bz::BZ) where {
        L, N, D, P <: AbstractReciprocalPoint{D},
        B <: AbstractBond{L,N},
        R <: AbstractReciprocalUnitcell{P,B},
        BZ <: AbstractBrillouinZone{R}
    }
    _vertices = Point{D, Float32}.(corners(bz))

    # NOTE
    # If weird shadows pop up the index order of faces might be wrong
    # Try swapping two indices.
    # If that doesn't work the face definition in LatPhys might have different
    # winding directions
    _faces = GeometryTypes.Face{3, Int64}[]
    for face in faces(bz)
        center = sum(Point{D, Float32}.(corners(bz)[face])) / length(face)
        push!(_vertices, center)
        c = length(_vertices)
        for i in 1:length(face)
            push!(_faces, GeometryTypes.Face(
                c,
                face[i],
                face[mod1(face[i]+1, length(face))]
            ))
        end
    end
    # _faces = [GeometryTypes.Face(f...) for f in faces(bz)]

    GeometryTypes.GLNormalMesh(_vertices, _faces)
end
