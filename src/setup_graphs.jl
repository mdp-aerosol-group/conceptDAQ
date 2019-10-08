using NumericIO
using InspectDR
using Colors

function block_series(yaxis)
	plot = InspectDR.transientplot(yaxis, title="")
	InspectDR.overwritefont!(plot.layout, fontname="Helvetica", fontscale=1.0)
	plot.layout[:enable_legend] = false
	plot.layout[:enable_timestamp] = false
	plot.layout[:length_tickmajor] = 10
	plot.layout[:length_tickminor] = 6
	plot.layout[:format_xtick] = InspectDR.TickLabelStyle(UEXPONENT)
	plot.layout[:frame_data] =  InspectDR.AreaAttributes(
         line=InspectDR.line(style=:solid, color=RGBA(0,0,0,1), width=0.5))
	plot.layout[:line_gridmajor] = InspectDR.LineStyle(:solid, Float64(0.75), 
													   RGBA(0, 0, 0, 1))

	plot.xext = InspectDR.PExtents1D()
	plot.xext_full = InspectDR.PExtents1D(0, 30)

	a = plot.annotation
	a.xlabel = ""
	a.ylabels = [""]

	return plot
end


plotXPXP1 = block_series(:lin)
mpPlotXPXP1,gplotPlotXPXP1 = push_plot_to_gui!(plotXPXP1, gui["xpxp1"], wnd)
wfrm = add(plotXPXP1, [0.0], [22.0], id="A")
wfrm.line = line(color=black, width=1, style=:solid)
wfrm = add(plotXPXP1, [0.0], [22.0], id="B")
wfrm.line = line(color=red, width=1, style=:solid)