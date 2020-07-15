# LatPhysPlottingMakie

LatPhysPlottingMakie is a [Makie](https://github.com/JuliaPlots/Makie.jl) plotting extension for [LatticePhysics](https://github.com/janattig/LatticePhysics.jl). It doesn't follow the definitions from [LatPhysPlottingPyPlot](https://github.com/janattig/LatPhysPlottingPyPlot.jl). Instead this package adds conversions to enable plotting with Makies native functions. Where applicable one can use `lines`, `scatter`, etc to plot objects from `LatticePhysics`. Most objects also have a `plot()` definition, which may include multiple native plots (for example `plot(lattice)` include `lines` and `scatter` to draw both bonds and sites).

This may require `AbstractPlotting#master`.

## Simple Examples

Here are some example which aim to show off what this package enables. As such the plots are not touched up to be particularly pretty. For this purpose we refer to [Makie](https://github.com/JuliaPlots/Makie.jl) and [MakieLayout](https://github.com/jkrumbiegel/MakieLayout.jl) which is currently being merged with Makie. We may also include helper functions in the future to do theming of plots. (Some of these already exist in the form of `setup_axis!()` and `VestaTheme()`)


### 3D Lattice Plot

You can pass `show_axis = false` to hide the axis.

```julia
uc = getUnitcellFCC()
l = getLatticeOpen(uc, 4)
plot(l, site_color = :blue)
```

![](https://github.com/ffreyer/LatPhysPlottingMakie.jl/blob/assets/assets/lattice3D.png)


### 2D Lattice Plot

```julia
uc = getUnitcellKagome()
l = getLatticeOpen(uc, 4)
plot(l)
```

![](https://github.com/ffreyer/LatPhysPlottingMakie.jl/blob/assets/assets/lattice2D.png)


### Reciprocal Path + Brillouin zone

```julia
uc = getUnitcellHoneycomb()
bz = getBrillouinZone(uc)
p = getReciprocalPath(uc, :Gamma, :K, :M, :Gamma)
scene = plot(bz)
plot!(scene, p, color=:red)
```

![](https://github.com/ffreyer/LatPhysPlottingMakie.jl/blob/assets/assets/BZ_path.png)


### Bandstructure

Bandstructure plots currently use a scatter plot to be maximally adjustable. If you supply the band structure as a `Node` you should be able to adjust the resolution and even the unit cell without any problems.

```julia
uc = getUnitcellHoneycomb()
bs = getBandstructure(uc, p)
plot(bs)
```

![](https://github.com/ffreyer/LatPhysPlottingMakie.jl/blob/assets/assets/bandstructure.png)


### Bandstructure GUI

This combines a plot of the reciprocal path and the brilluoin zone with a plot of the bandstructure and a bunch of sliders to adjust hopping parameters of the given unitcell.

```julia
uc = getUnitcellKagome()
BandstructureGUI(uc)
```


![](https://github.com/ffreyer/LatPhysPlottingMakie.jl/blob/assets/assets/BandstructureGUI.png)
