################################################################################
#
#   FUNCTIONS FOR PLOTTING OF RECIPROCAL POINTS
#   (overwriting plotSite function for AbstractSite)
#
################################################################################

function plot(
        path::P; color::Vector{<:Integer} = [250,30,0], kwargs...
    ) where {P<:AbstractReciprocalPath}
    plot(path, color = RGB((color ./ 255)...); kwargs...)
end
function plot(
            path :: P
            ;
            color :: Colorant = RGB(0.98, 0.12, 0.0),
            site_radius :: Real = 0.5,
            kwargs...
        ) where {D, S<:AbstractReciprocalPoint{D}, P<:AbstractReciprocalPath{S}}

    scene = AbstractPlotting.current_scene()
    # plot all points in the path
    plotSites(points(path), site_radius, color; kwargs...)
    # connect the points
    Makie.lines!(
        scene,
        Point{D, Float32}.(point.(points(path))), # NOTE
        color = color,
        linewidth = 1
    )
end

# export the plot function
export plot
