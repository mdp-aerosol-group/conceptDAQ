using Random, Distributions

function synthetic_labjack()
    t = now()
    A = 2.0*(rand(1))[1] .+ 10.0
    B = 3.0*(rand(1))[1] .+ 20.0
    C = 4.0*(rand(1))[1] .+ 30.0
    
    push!(LJdataStream, DataFrame(t=t,tint=Dates.value(t),A=A,B=B,C=C))
end

function synthetic_serial()
    t = now()
    A = 2.0*(rand(1))[1] .+ 10
    B = 3.0*(rand(1))[1] .+ 20
    C = 4.0*(rand(1))[1] .+ 30

    push!(RS232dataStream, DataFrame(t=t,tint=Dates.value(t),A=A,B=B,C=C))
end
