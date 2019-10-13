
# Connect dropdown menus with callback functions...
gSelect1= gui["xpxp1G1"]
signal_connect(gSelect1, "changed") do widget, others...
	update_graph()
end

gSelect2= gui["xpxp1G2"]
signal_connect(gSelect2, "changed") do widget, others...
	update_graph()
end
