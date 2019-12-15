function combinedBandstructurePlot(args...; kwargs...)
    bs = getBandstructure(args...)
    combinedBandstructurePlot(bs)
end

function combinedBandstructurePlot(
        bs::AbstractBandstructure;
        BZ_color = RGB(0.04, 0.04, 0.04),
        BZ_linewidth = 1.0,
        kwargs...
    )
    path = bs.path
    uc = bs.h.unitcell
    bz = getBrillouinZone(uc)

    left_scene = Scene()
    right_scene = Scene()

    mesh = bz_to_mesh(bz)
    Makie.wireframe!(left_scene, mesh, color=BZ_color, linewidth=BZ_linewidth)
    Makie.scatter!(left_scene, GeometryTypes.vertices(mesh), color = BZ_color)

    # vbox(left_scene, right_scene)
end


export combinedBandstructurePlot
