# + 
# This file defines global constants and Signals
# The signals are defined as const to indicate type stability
#
# -

const _Gtk = Gtk.ShortNames
const black = RGBA(0, 0, 0, 1)
const red = RGBA(0.8, 0.2, 0, 1)
const mblue = RGBA(0, 0, 0.8, 1)
const mgrey = RGBA(0.4, 0.4, 0.4, 1)
const lpm = 1.666666e-5
const path = mapreduce(a->"/"*a,*,(pwd() |> x->split(x,"/"))[2:3])*"/Data/"

# Extrapolation Signals - these hold the data from the circ buffer and are used
#                         to interpolate the data onto a fixed 1Hz or 10 Hz grid
t = @fetchfrom 2 DataAquisitionLoops.t
const extp       = extrapolate(interpolate(([0, 1],),[0.0, 1],Gridded(Linear())),0)
const extpA1Hz   = Signal(extp)
const extpB1Hz   = Signal(extp)
const extpC1Hz   = Signal(extp)
const extpA10Hz  = Signal(extp)
const extpB10Hz  = Signal(extp)
const extpC10Hz  = Signal(extp)
const t1HzInt    = Signal(Dates.value.(t:Dates.Second(1):(t + Dates.Minute(1))))
const t10HzInt   = Signal(Dates.value.(t:Dates.Millisecond(100):(t + Dates.Minute(1))))

const datestr = @fetchfrom 2 DataAquisitionLoops.datestr
const HHMM = @fetchfrom 2 DataAquisitionLoops.HHMM