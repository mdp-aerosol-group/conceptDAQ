using Distributed, Gtk, InspectDR, Reactive, Colors, DataFrames, DataStructures
using Dates, Interpolations, Statistics, Printf, CSV, NumericIO

# Start DAQ Loops
addprocs(1)                           # Add one dedicated processor for DAQ
include("DataAquisitionLoops.jl")
using. DataAquisitionLoops
Godot = @spawnat 2 DataAquisitionLoops.aquire()

(@isdefined wnd) && destroy(wnd)                   # Destroy window if exists
gui = GtkBuilder(filename=pwd()*"/gui.glade")      # Load the GUI template
wnd = gui["mainWindow"]                            # Set the main windowx

include("gtk_graphs.jl")         # Generic GTK graphing routines
include("global_variables.jl")   # Signals and global constants
include("setup_graphs.jl")       # Initialize graphs for GUI
include("gtk_callbacks.jl")      # Link GTK GUI fields with code
include("gui_updates.jl")        # Update loops for GUI IO

Gtk.showall(wnd)                 # Show the window

oneHz = every(1.0)               # 1  Hz timer
tenHz = every(0.1)               # 10 Hz timer
griddedHz = every(10)            # regridding update frequency
graphHz = every(10)              # graph update frequency

griddedData = map(_->(@async update_gridded_data()), griddedHz)
graphLoop2  = map(_->(@async update_graphs()), graphHz)
oneHzFields = map(_->(@async update_oneHz()), oneHz)
tenHzFields = map(_->(@async update_tenHz()), tenHz)