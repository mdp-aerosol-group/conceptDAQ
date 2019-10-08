# Populate 1Hz Boxes
function update_oneHz()
    frame = @fetchfrom 2 DataAquisitionLoops.RS232dataStream.value
    set_gtk_property!(gui["OneHzTime"], :text, Dates.format((frame.t)[1], "HH:MM:SS.s"))
    set_gtk_property!(gui["A1Hz"], :text, @sprintf("%.1f", (frame.A)[1]))
    set_gtk_property!(gui["B1Hz"], :text, @sprintf("%.1f", (frame.B)[1]))
    set_gtk_property!(gui["C1Hz"], :text, @sprintf("%.1f", (frame.C)[1]))

    dstr = @fetchfrom 2 DataAquisitionLoops.datestr
    HM = @fetchfrom 2 DataAquisitionLoops.HHMM
    push!(datestr, dstr.value)
    push!(HHMM, HM.value)
end

# Populate 10Hz Boxes
function update_tenHz()
    frame = @fetchfrom 2 DataAquisitionLoops.LJdataStream.value
    set_gtk_property!(gui["TenHzTime"], :text, Dates.format((frame.t)[1], "HH:MM:SS.s"))
    set_gtk_property!(gui["A10Hz"], :text, @sprintf("%.2f", (frame.A)[1]))
    set_gtk_property!(gui["B10Hz"], :text, @sprintf("%.2f", (frame.B)[1]))
    set_gtk_property!(gui["C10Hz"], :text, @sprintf("%.2f", (frame.C)[1])) 
end

# Update Graphs
function update_graphs()
    frame = @fetchfrom 2 DataAquisitionLoops.RS232Buffers.value
    t1 = t1HzInt.value
    x = (t1HzInt.value .- t1HzInt.value[1])./1000/60

    function updateXPXP1(extp1,extp2, plot, gplot)
        set_gtk_property!(gui["xpxp1FieldG1"], :text, @sprintf("%.2f", mean(extp1.value(t1))))
        set_gtk_property!(gui["xpxp1FieldG2"], :text, @sprintf("%.2f", mean(extp2.value(t1))))
        addseries!(x,extp1.value(t1), plot, gplot, 1, false, true)
        addseries!(x,extp2.value(t1), plot, gplot, 2, false, true)
    end

    function parse_xpxp(id)
        (y = extpA1Hz)
        (id == "A") && (y = extpA1Hz)
        (id == "B") && (y = extpB1Hz)
        (id == "C") && (y = extpC1Hz)
        y
    end

    xpxpA = get_gtk_property(gui["xpxp1G1"], "active-id", String)
    ypA = parse_xpxp(xpxpA)
    xpxpB = get_gtk_property(gui["xpxp1G2"], "active-id", String)
    ypB = parse_xpxp(xpxpB)
    updateXPXP1(ypA,ypB, plotXPXP1, gplotPlotXPXP1)
end

# Update gridded data
function update_gridded_data()
    LJBuffers = @fetchfrom 2 DataAquisitionLoops.LJBuffers
    t = convert(Array{DateTime},LJBuffers.value.t)
    x = Dates.value.(t)
    t1Hz = LJBuffers.value.t[1]:Dates.Second(1):LJBuffers.value.t[end]
    push!(t1HzInt, Dates.value.(t1Hz))
    t10Hz = LJBuffers.value.t[1]:Dates.Millisecond(100):LJBuffers.value.t[end]
    push!(t10HzInt, Dates.value.(t10Hz))

    function getExtp(field)
        y = convert(Array{Float64},field)
        itp = interpolate((x,),y,Gridded(Linear()))
        extrapolate(itp,0)
    end

    push!(extpA10Hz, getExtp(LJBuffers.value.A))
    push!(extpB10Hz, getExtp(LJBuffers.value.B))
    push!(extpC10Hz, getExtp(LJBuffers.value.C))

    RS232Buffers = @fetchfrom 2 DataAquisitionLoops.RS232Buffers
    t = convert(Array{DateTime},RS232Buffers.value.t)
    x = Dates.value.(t)

    function getExtpRS232(field)
        y = convert(Array{Float64},field)
        itp = interpolate((x,),y,Gridded(Linear()))
        extrapolate(itp,0)
    end

    push!(extpA1Hz, getExtpRS232(RS232Buffers.value.A))
    push!(extpB1Hz, getExtpRS232(RS232Buffers.value.B))
    push!(extpC1Hz, getExtpRS232(RS232Buffers.value.C))
end