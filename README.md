# conceptDAQ

Concept implementation using julia for building data acquisition systems.

# Installation

Clone the repository, change to the ```src/``` directory and run 

```bash
julia --project -e 'using Pkg; Pkg.instantiate()' 
```

load install the dependencies. This only needs to be performed once.

# Brief Description

The GUI is created using glade (see gui.glade as example). 

The module DataAcquisitionLoops contains an example of timed concurrent data acquisition at 1 and 10 Hz. The data are stored in a circular buffer. Data are also written to an interpolated 1 Hz and 10 Hz regularly gridded structure. Raw data is written to file in the ~/Data directory

DataAcquistionLoops is executed on a separate core. This allows the program to perform high-load computation task on the main core (e.g. data processing), without affecting the critical timing of the DAQ loops. Data acquisition loops are polling synthetic data for demonstration. No hardware I/O is performed

Running main.jl in ther REPL will bring up the GUI and start the Acquisition loop. 

If you want a responsive REPL while the program runs in the background, comment out the 

```julia
wait(Godot)
```

at the end of the program or click the "Stop DAQ" button. (The program will continue to run when in REPL mode, but will terminate when called from the command line).

Examples include how to generate a responsive graph (with dropdown selection of signals) and GUI textbox to display data. 

# Run a standalone program

Call

```bash
julia -q --project main.jl  
```

This will compile the project and run the program. The "End DAQ" button will close the program.

# Screenshots

![A](doc/raw_data.png)

![A](doc/graphs.png)

# Low-latency startup
Use [PackageCompiler.jl](https://julialang.github.io/PackageCompiler.jl/dev/) to create a 
custom sysimage. Note that this requires significant memory (>6 GB). Create a large swap partion on systems with limited memory (e.g. single-board-computers).

```bash
julia --project --optimize=3 -e 'using PackageCompiler; create_sysimage([:CSV, :Colors, :DataFrames, :DataStructures, :Dates, :Distributed, :Distributions, :Gtk, :InspectDR, :Interpolations, :NumericIO, :Printf, :Random, :Reactive, :Statistics], sysimage_path="sys_daq.so", precompile_execution_file="main.jl")'
```

Then call with custom image

```bash
julia -q --project --sysimage sys_daq.so main.jl 
```
