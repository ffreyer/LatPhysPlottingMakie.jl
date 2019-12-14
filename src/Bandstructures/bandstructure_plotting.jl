################################################################################
#
#   BAND STRUCTURE PLOTTING
#
################################################################################

# function to plot a bandstructure
function plotBandstructure(
        bs::BS; color::Vector{<:Integer}=[100,120,255], kwargs...
    ) where {BS <: AbstractBandstructure}
    plotBandstructure(bs, RGB((color ./ 255)...); kwargs...)
end
function plotBandstructure(
            bs :: BS
            ;
            # new_figure :: Bool = true,
            figsize :: Tuple = (6,4),
            color :: Colorant = RGB(0.39, 0.47, 1.0),
            kwargs...
        ) where {
            RP,
            P <: AbstractReciprocalPath{RP},
            L, UC, HB, H <: AbstractHamiltonian{L,UC,HB},
            BS <: AbstractBandstructure{P,H}
        }

    ###########################
    #   INITIAL SETTINGS
    ###########################

    # configure plot environment
    #rc("font", family="serif")

    # create a new figure
    # if new_figure
    #     fig = figure(figsize=figsize)
    # else
    #     fig = gcf()
    # end
    scene = Scene(resolution=100figsize)



    ###########################
    #   PLOT BANDS
    ###########################

    # collect the segment breaks
    k_point_indices = zeros(Int64, length(energies(bs))+1)
    # get the labels of these breaks
    k_point_labels = label.(path(bs))

    # plot the band structure
    for s in 1:length(energies(bs))
        # push the next k point as index into the array
        k_point_indices[s+1] = length(energies(bs)[s][1]) + k_point_indices[s] - 1
        # plotting segment s, collecting x values for bands
        xvals = range(k_point_indices[s], stop=k_point_indices[s+1], length=length(energies(bs)[s][1]))
        # plot all bands
        for band in energies(bs)[s]
            Makie.lines!(scene, xvals, band, color=color)
        end
    end



    ###########################
    #   SET ALL TICKS (POINTS)
    ###########################

    ax = scene[Axis]

    ax[:ticks, :ranges_labels][] = (
        (ticks_and_labels[1], k_point_indices),
        (k_point_labels, ticks_and_labels[2])
    )

    # Hmm...
    # # configure ticks on x axis
    # axx.set_tick_params(which="both", direction="out")
    # axx.set_tick_params(which="top", color="none")
    #
    # # configure ticks on x axis
    # axy = ax.get_yaxis()
    # axy.set_tick_params(which="both", direction="out")

    # plot vertical lines for each point
    # NOTE There's probably a better way to do this
    E_min, E_max = extrema(extrema.(energies(bs)))
    points = [Point2f0(x, y) for x in k_point_indices for y in [E_min, E_max]]
    Makie.linesegments!(scene, points, linestyle=:dashed, color=RGB(0.6, 0.6, 0.6))


    ###########################
    #   CONFIGURE AXIS
    ###########################

    # label the axis
    ax[:names, :axisnames][] = ("momentum", "energy")


    # return the figure object
    return scene
end

# pass unknown arguments directly to construction of band structure
function plotBandstructure(args...; kwargs...)
    # create and plot a bandstructure
    plotBandstructure(getBandstructure(args...); kwargs...)
end

# export the function
export plotBandstructure
