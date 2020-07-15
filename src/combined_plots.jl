function BandstructureGUI(
        uc::UC,
        path = getReciprocalPath(uc, :Gamma, :K, :M, :Gamma),
        slider_range = -2:0.1:2
    ) where {
        LS, D, S <: AbstractSite{LS,D}, UC <: AbstractUnitcell{S}
    }
    labels = unique(uc |> bonds .|> label)
    H = getHoppingHamiltonianDict(uc)
    trigger = Node(nothing)

    scene, layout = layoutscene()
    sublayout = layout[1, 1] = GridLayout()
    bs_axis = sublayout[1, 1] = LAxis(scene)
    uc_scene = sublayout[1, 2] = LScene(scene, scenekw = (raw=false,))
    sublayout[1, 2] = LRect(scene, color=:transparent, strokecolor = :gray24, strokewidth=1)
    colsize!(sublayout, 2, Aspect(1, 1))


    N_rows = div(length(labels), 4)
    sliders = layout[2, 1] = GridLayout()
    for (i, label) in enumerate(labels)
        s = sliders[2 + 2div(i-1, 4), mod1(i, 4)] = LSlider(
            scene, range = slider_range, width = Relative(1)
        )
        sliders[1 + 2div(i-1, 4), mod1(i, 4)] = LText(
            scene,
            map(v -> @sprintf("Coupling %s = %0.2f", label, v), s.value),
            tellwidth=false
        )
        on(v -> (H.couplings[label] = v; trigger[] = trigger[]), s.value)
    end

    path_signal = Node(path)
    bs = Node{AbstractBandstructure}(getBandstructure(uc, path_signal[], H))
    on(_ -> bs[] = getBandstructure(uc, path_signal[], H), trigger)
    plot!(bs_axis, bs, strokewidth=0, markersize=5)
    setup_axis!(bs_axis, bs)

    bz = getBrillouinZone(uc)
    plot!(uc_scene, bz)
    plot!(uc_scene, path_signal, color=:red, overdraw=true)
    setup_axis!(uc_scene, bz)

    scene
end
