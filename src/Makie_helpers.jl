
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
