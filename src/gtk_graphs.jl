# +
# gtk_graphs.jl
#
# collection of routines to push graphs to the UI
#
# function push_plot_to_gui!(plot, box, wnd)
# -- adds the plot to a Gtk box located in a window
#
# function refreshplot(gplot::InspectDR.GtkPlot)
# -- refreshes the Gtk plot on screen
#
# function addpoint!(x::Float64,y::Float64,plot::InspectDR.Plot2D,
#  				     gplot::InspectDR.GtkPlot)
# -- adds an x/y point to the plot
#

import NumericIO:UEXPONENT

# -- adds an x/y point to the plot
function addpoint!(x::Float64,y::Float64,plot::InspectDR.Plot2D,
				   gplot::InspectDR.GtkPlot,strip::Int,autoscale::Bool)
	
	push!(plot.data[strip].ds.x,x)
	push!(plot.data[strip].ds.y,y)
	cut = plot.data[strip].ds.x[end]-bufferlength
	ii = plot.data[strip].ds.x .<= cut
	deleteat!(plot.data[strip].ds.x, ii)	
	deleteat!(plot.data[strip].ds.y, ii)
	plot.xext = InspectDR.PExtents1D()
	plot.xext_full = InspectDR.PExtents1D(plot.data[strip].ds.x[1],
										  plot.data[strip].ds.x[end])

	if autoscale == true
		miny,maxy = Float64[],Float64[]
		for x in plot.data
			push!(miny, minimum(x.ds.y))
			push!(maxy, maximum(x.ds.y))
		end
		miny =  minimum(miny)
		maxy =  maximum(maxy)
		graph = plot.strips[1]
		graph.yext = InspectDR.PExtents1D() 
		graph.yext_full = InspectDR.PExtents1D(miny, maxy)
	end

	refreshplot(gplot)
end

function addseries!(x::Array{Float64},y::Array{Float64},plot::InspectDR.Plot2D,
	gplot::InspectDR.GtkPlot,strip::Int,autoscalex::Bool, autoscaley::Bool)

	plot.data[strip].ds.x = x
	plot.data[strip].ds.y = y
	if autoscaley == true
		miny,maxy = Float64[],Float64[]
		for x in plot.data
			push!(miny, minimum(x.ds.y))
			push!(maxy, maximum(x.ds.y))
		end
		miny =  minimum(miny)
		maxy =  maximum(maxy)
		graph = plot.strips[1]
		graph.yext = InspectDR.PExtents1D() 
		graph.yext_full = InspectDR.PExtents1D(miny, maxy)
	end

	if autoscalex == true
		minx,maxx = Float64[],Float64[]
		for x in plot.data
			push!(minx, minimum(x.ds.x))
			push!(maxx, maximum(x.ds.x))
		end
		minx =  minimum(minx)
		maxx =  maximum(maxx)
		plot.xext = InspectDR.PExtents1D() 
		plot.xext_full = InspectDR.PExtents1D(minx, maxx)
	end

	refreshplot(gplot)
end
# -- adds the plot to a Gtk box located in a window
function push_plot_to_gui!(plot::InspectDR.Plot2D, 
						   box::GtkBoxLeaf, 
						   wnd::GtkWindowLeaf)

	mp = InspectDR.Multiplot()
	InspectDR._add(mp, plot)
	grd = Gtk.Grid()
	Gtk.set_gtk_property!(grd, :column_homogeneous, true)
	status = _Gtk.Label("")
	push!(box, grd)
	gplot = InspectDR.GtkPlot(false, wnd, grd, [], mp, status)
	InspectDR.sync_subplots(gplot)
	return mp,gplot
end

# -- setup of the frame for a particular GUI plot
# Traced from InspectDR source code without title refresh
function refreshplot(gplot::InspectDR.GtkPlot)
	if !gplot.destroyed
		set_gtk_property!(gplot.grd, :visible, false) 
		InspectDR.sync_subplots(gplot)
		for sub in gplot.subplots
			InspectDR.render(sub, refreshdata=true)  
			Gtk.draw(sub.canvas)
		end
		set_gtk_property!(gplot.grd, :visible, true)
		Gtk.showall(gplot.grd)
		sleep(eps(0.0))
	end
end