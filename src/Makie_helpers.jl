
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


function VestaTheme()
    Theme(
        ambient   = Vec3f0(0.1),
        diffuse   = Vec3f0(0.9),
        specular  = Vec3f0(0.8),
        shininess = 32f0
    )
end


function setup_axis!(scene, obj)
    if obj isa Node
        throw(MethodError(setup_axis!, (scene, obj)))
    else
        return setup_axis!(scene, const_lift(obj))
    end
end
function setup_axis!(ax::LAxis, bs::Node{BS}) where {BS <: AbstractBandstructure}
    ax.xlabel = "Momentum"
    ax.ylabel = "Energy"
    on(bs) do bs
        k_point_labels = label.(path(bs))
        Es = energies(bs)
        ticks = cumsum(vcat(1, [length(Es[i][1]) for i in eachindex(Es)]))
        ax.xticks[] = (ticks, k_point_labels)
    end
    # Trigger update of ticks
    bs[] = bs[]
    ax.ygridvisible = false

    ax
end
function setup_axis!(ls::LScene, bz::Node{BZ}) where {BZ <: AbstractBrillouinZone}
    setup_axis!(ls.scene, bz)

end
function setup_axis!(s::Scene, bz::Node{BZ}) where {BZ <: AbstractBrillouinZone}
    s.show_axis = false
    s.update_limits = false
    on(bz) do bz
        min, max = extrema(corners(bz))
        center = mean(corners(bz))
        width = 1.2maximum(max .- min)
        s.limits[] = FRect(Point((center .- 0.5width)...), Vec{length(center)}(width))
    end
    bz[] = bz[]
end
