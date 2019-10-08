@everywhere module DataAquisitionLoops

using Reactive, DataStructures, Dates, CSV, DataFrames, LabjackU6Library


include("synthetic_data_stream.jl")   # Synthetic Data Aquistion for testing

# Raw data streams - single record saved in named tuples. The named tuple entry
#                    is appended to the data file upon receipt and values are then
#                    added to the circular buffers beliw
# RS232 Data
t = now()

const datestr = Signal(Dates.format(now(), "yyyymmdd"))
const HHMM = Signal(Dates.format(now(), "HHMM"))
const rs = DataFrame(t=t,tInt=0,A=0.0,B=0.0,C=0.0)
const path = mapreduce(a->"/"*a,*,(pwd() |> x->split(x,"/"))[2:3])*"/Data/"
const RS232dataFilename = Signal(path*"RS232dataStream_"*datestr.value*"_"*HHMM.value*".csv")
const RS232dataStream = Signal(rs)
RS232dataStream.value |> CSV.write(RS232dataFilename.value)

# LJ Data
const lj = DataFrame(t=t,tInt=0,A=0.0,B=0.0,C=0.0)
const LJdataFilename = Signal(path*"RS232dataStream_"*datestr.value*"_"*HHMM.value*".csv")
const LJdataStream = Signal(lj)
LJdataStream.value |> CSV.write(LJdataFilename.value)

const newDay = map(droprepeats(datestr)) do x
    push!(HHMM, Dates.format(now(), "HHMM"))
    push!(LJdataFilename, path*"LJdataStream_"*datestr.value*"_"*HHMM.value*".csv")
    push!(RS232dataFilename, path*"RS232dataStream_"*datestr.value*"_"*HHMM.value*".csv")
end

# Circular Buffers - these buffers hold a time history of the data
#                    these form the basis of the interpolation below 
function LJcircBuff(n)
    t = CircularBuffer{DateTime}(n)
    A = CircularBuffer{Float64}(n)
    B = CircularBuffer{Float64}(n)
    C = CircularBuffer{Float64}(n)

    (t=t,A=A,B=B,C=C)
end

function RScircBuff(n)
    t = CircularBuffer{DateTime}(n)
    A = CircularBuffer{Float64}(n)
    B = CircularBuffer{Float64}(n)
    C = CircularBuffer{Float64}(n)

    (t=t,A=A,B=B,C=C)
end

const LJBuffers    = Signal(LJcircBuff(18000))  # 30 min @ 10 Hz
const RS232Buffers = Signal(RScircBuff(1800))   # 30 min @  1 Hz

function oneHz_daq_loop()
    push!(datestr,Dates.format(now(), "yyyymmdd"))
    RS232dataStream.value |> CSV.write(RS232dataFilename.value, append=true)
    frame = RS232dataStream.value

    push!(RS232Buffers.value.t, (frame.t)[1])
    push!(RS232Buffers.value.A, (frame.A)[1])
    push!(RS232Buffers.value.B, (frame.B)[1])
    push!(RS232Buffers.value.C, (frame.C)[1])
end

function tenHz_daq_loop()
    LJdataStream.value |> CSV.write(LJdataFilename.value, append=true)
    frame = LJdataStream.value

    push!(LJBuffers.value.t, (frame.t)[1])
    push!(LJBuffers.value.A, (frame.A)[1])
    push!(LJBuffers.value.B, (frame.B)[1])
    push!(LJBuffers.value.C, (frame.C)[1])
end

# Asynchronous DAQ loops
function aquire()
    oneHz = every(1.0)      # 1  Hz timer for RS232
    tenHz = every(0.1)      # 10 Hz timer for LJ

    # DAQ Loops
    labjackDAQ  = map(_->synthetic_labjack(),tenHz)
    tenHzDAQ    = map(_->(@async tenHz_daq_loop()), labjackDAQ)
    serialDAQ   = map(_->synthetic_serial(), oneHz)
    oneHzDAQ    = map(_->(@async oneHz_daq_loop()), serialDAQ)

    # Empty all buffers for a clean start
    empty!(LJBuffers.value.t) 
    empty!(LJBuffers.value.A) 
    empty!(LJBuffers.value.B) 
    empty!(LJBuffers.value.C) 

    empty!(RS232Buffers.value.t) 
    empty!(RS232Buffers.value.A) 
    empty!(RS232Buffers.value.B) 
    empty!(RS232Buffers.value.C) 

    labjackDAQ, tenHzDAQ, serialDAQ, oneHzDAQ
end

end