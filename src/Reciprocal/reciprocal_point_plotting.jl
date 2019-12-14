################################################################################
#
#   FUNCTIONS FOR PLOTTING OF RECIPROCAL POINTS
#   (overwriting plotSite function for AbstractSite)
#
################################################################################

# PLOTTING RECIPROCAL POINTS IN 2D
function LatPhysPlottingPyPlot.plotSite(
            site    :: S,
            radius  :: Real,
            color   :: Vector{<:Integer}
            ;
            kwargs...
        ) where {D, S<:AbstractReciprocalPoint{D}}
    plotSite(site, radius, RGB((color ./ 255)...); kwargs...)
end
function LatPhysPlottingPyPlot.plotSite(
            site    :: S,
            radius  :: Real,
            color   :: Colorant
            ;
            site_labels :: Bool = true,
            use_LaTeX :: Bool = true,
            site_label_fontsize :: Real = 12,
            site_label_offset :: Vector{<:Real} = [0.1, 0.0],
            kwargs...
        ) where {S<:AbstractReciprocalPoint{2}}

    scene = AbstractPlotting.current_scene()
    # scatter the point
    Makie.scatter(Point2f0[point(site)], color=color)
    # maybe annotate the label as text
    if site_labels
        if use_LaTeX
            error("Don't use latex >:(\nYou can use unicode though...")
            Makie.text!(
                scene,
                string(labelLaTeX(site)),
                position = Point2f0(point(site) + site_label_offset),
                textsize = site_label_fontsize,
                color = color
            )
        else
            Makie.text!(
                scene,
                String(label(site)),
                Point2f0(point(site) + site_label_offset),
                textsize = site_label_fontsize,
                color = color
            )
        end
    end
    scene
end

# PLOTTING RECIPROCAL POINTS IN 3D
function LatPhysPlottingPyPlot.plotSite(
            site    :: S,
            radius  :: Real,
            color   :: Colorant
            ;
            site_labels :: Bool = true,
            use_LaTeX :: Bool = true,
            site_label_fontsize :: Real = 12,
            site_label_offset :: Vector{<:Real} = [0.1, 0.0, 0.0],
            kwargs...
        ) where {S<:AbstractReciprocalPoint{3}}

    scene = AbstractPlotting.current_scene()
    # scatter the point
    Makie.scatter(Point3f0[point(site)], color=color)
    # maybe annotate the label as text
    if site_labels
        if use_LaTeX
            error("Don't use latex >:(\nYou can use unicode though...")
            Makie.text!(
                scene,
                string(labelLaTeX(site)),
                position = Point3f0(point(site) + site_label_offset),
                textsize = site_label_fontsize,
                color = color
            )
        else
            Makie.text!(
                scene,
                String(label(site)),
                Point3f0(point(site) + site_label_offset),
                textsize = site_label_fontsize,
                color = color
            )
        end
    end
    scene
end

# export the function
export plotSite
