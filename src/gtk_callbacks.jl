
# Connect dropdown menus with callback functions...
gSelect1= gui["xpxp1G1"]
signal_connect(gSelect1, "changed") do widget, others...
	update_graphs()
end

gSelect2= gui["xpxp1G2"]
signal_connect(gSelect2, "changed") do widget, others...
	update_graphs()
end

Godot = @task _->false
id = signal_connect(x->schedule(Godot), gui["EndButton"], "clicked")
Godot = @task _->false