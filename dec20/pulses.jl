#
# This is a solution to the Advent of Code 2023 problem for day 20 in Julia 1.9:
#
# https://adventofcode.com/2023/day/20
#
# It needs the corresponding input.txt stored into the same directory.
#
# Note: The actual answer requires some investigation on the properties
# of the input though the final answer is printed.

using Printf
using Graphs
using GraphPlot
import Cairo, Fontconfig
using Compose

using Karnak
using NetworkLayout
using Colors


function example_data_1()
    return [
        "broadcaster -> a, b, c", 
        "%a -> b", 
        "%b -> c", 
        "%c -> inv", 
        "&inv -> a"
    ]
end

function example_data_2()
    return [
        "broadcaster -> a", 
        "%a -> inv, con", 
        "&inv -> b", 
        "%b -> con", 
        "&con -> output"
    ]
end

function parse_input(lines)
    broadcaster = []
    conj_dict = Dict{String,Dict{String,Bool}}()
    flipflop_dict = Dict{String,Bool}()
    succ_dict = Dict{String,Array{String}}()

    for line in lines
        tmp = split(line, " -> ", keepempty=false)
        left = tmp[1]
        rest = split(tmp[2], ", ")

        if left[1] ∈ ['%','&']
            succ_dict[left[2:end]] = rest
        else
            succ_dict[left] = rest
        end

        if left == "broadcaster"
            broadcaster = rest
        elseif left[1] == '%'
            flipflop_dict[left[2:end]] = false
        elseif left[1] == '&'
            conj_dict[left[2:end]] = Dict{String,Bool}()
        else
            @assert false "Opsidoo"
        end
    end

    for key in keys(succ_dict)
        for succ in succ_dict[key]
            if haskey(conj_dict, succ)
                conj_dict[succ][key] = false
            end
            if !haskey(succ_dict, succ)
                succ_dict[succ] = []
            end
        end
    end

    return broadcaster, succ_dict, conj_dict, flipflop_dict
end

function button!(broadcaster, succ_dict, conj_dict, flipflop_dict, monitor="rx")
    sending = map(s -> ("broadcaster", s, false), broadcaster)

    low_pulses = 1
    high_pulses = 0
    rx_low = false

    while length(sending) > 0
#        @show sending
        new_sending = []
        for msg in sending
            sender = msg[1]
            recipient = msg[2]
            signal = msg[3]

            if signal
                high_pulses += 1
            else
                low_pulses += 1
            end

            if recipient == monitor
                if signal
#                    @show "$monitor is high"
                else
                    @info "$monitor is low"
                    rx_low = true
                end
            end

            if haskey(conj_dict, recipient)
                # Inverter
                conj_dict[recipient][sender] = signal
                all_high = true
                for key in keys(conj_dict[recipient])
                    if !conj_dict[recipient][key]
                        all_high = false
                    end
                end
                signal = !all_high
                for new_recipient in succ_dict[recipient]
                    push!(new_sending, (recipient, new_recipient, signal))
                end
                
            elseif haskey(flipflop_dict, recipient)
                # Flop flop
                if !signal
                    flipflop_dict[recipient] = !flipflop_dict[recipient]
                    signal = flipflop_dict[recipient]
                    for new_recipient in succ_dict[recipient]
                        push!(new_sending, (recipient, new_recipient, signal))
                    end    
                end
            else
#                @info "Unknown recipient \"$recipient\""
            end
        end

        sending = new_sending
    end

    return low_pulses, high_pulses, rx_low
end

function make_graph(succ_dict, subset=Set())
    # Make list and dictionary of vertices
    count = 0
    vertex_list = []
    vertex_dict = Dict()

    for v1 in keys(succ_dict)
        if (isempty(subset) || (v1 ∈ subset)) && !haskey(vertex_dict, v1)
            count += 1
            vertex_dict[v1] = count
            push!(vertex_list, v1)
        end
        for v2 in succ_dict[v1]
            if (isempty(subset) || (v2 ∈ subset)) && !haskey(vertex_dict, v2)
                count += 1
                vertex_dict[v2] = count
                push!(vertex_list, v2)
            end
        end
    end

    # Add edges to the graph
    @show count
    
    G = DiGraph(count)
    for v1 in keys(succ_dict)
        for v2 in succ_dict[v1]
            if haskey(vertex_dict, v1) && haskey(vertex_dict, v2)
                add_edge!(G, vertex_dict[v1], vertex_dict[v2])
            end
        end
    end

    return G, vertex_list, vertex_dict
end

open("input.txt") do io
    lines = readlines(io)
#    lines = example_data_1()
#    lines = example_data_2()

    # Do part 1
    broadcaster, succ_dict, conj_dict, flipflop_dict = parse_input(lines)
    signal = false
    total_low_pulses = 0
    total_high_pulses = 0

    n = 1000
    @info "n: " n

    for i in 1:n
        low_pulses, high_pulses, rx_low = button!(broadcaster, succ_dict, conj_dict, flipflop_dict, "rx")
        total_low_pulses += low_pulses
        total_high_pulses += high_pulses
    end

    result_1 = total_high_pulses * total_low_pulses
    @show result_1

    # Do part 2
    broadcaster, succ_dict, conj_dict, flipflop_dict = parse_input(lines)

    signal = false
    total_low_pulses = 0
    total_high_pulses = 0

    curr_max = 0
    when_rx_low = []
    monitor = "pm"  # pm, vk, ks, dl
    n = 10000
    @info "n: " n

    names = ["xd", "ts", "vr", "pf"]
    groups = []
    for name in names
        @show name
        dict = Dict()
        if !haskey(dict, name)
            dict[name] = true
        end
        for key in succ_dict[name]
            if !haskey(dict, key)
                dict[key] = true
            end
        end
        for key in keys(succ_dict)
            if name ∈ succ_dict[key]
                dict[key] = true
            end
        end

        push!(groups, collect(keys(dict)))
    end

    groups[1] = ["qz", "gc", "xv", "hq", "zt", "vl", "bc", "qx", "gb", "vj", "hd", "mg", "xd", "vk"]
    groups[2] = ["jr", "qm", "bf", "rr", "cd", "vn", "lq", "gk", "kx", "xg", "pb", "mt", "ts", "dl"]
    groups[3] = ["tx", "jg", "sb", "lz", "kk", "vf", "cn", "tr", "xz", "lt", "ng", "gx", "vr", "ks"]
    groups[4] = ["hk", "tv", "rl", "qn", "zr", "vx", "lj", "fl", "pp", "zn", "vh", "cb", "pf", "pm"]

    all_list = []

    for i in 1:n
        low_pulses, high_pulses, rx_low = button!(broadcaster, succ_dict, conj_dict, flipflop_dict, monitor)
        total_low_pulses += low_pulses
        total_high_pulses += high_pulses

        if rx_low
            push!(when_rx_low, i)
        end

        if true
            if i == 1
                @info names
            end

            print("$i :")
            @printf "%-3d" i
            for i in 1:length(groups)
                name = names[i]
                str = ""
                val = 0
                for e in reverse(groups[i])
                    if haskey(flipflop_dict, e)
                        if flipflop_dict[e]
                            str *= "1"
                            val = (val << 1) + 1
                        else
                            str *= "0"
                            val = (val << 1) + 0
                        end
                    else
                        lst = collect(values(conj_dict[e]))
                        if length(lst) == 1
                            if lst[1]
                                str *= "+"
                            else
                                str *= "-"
                            end
                        end
                    end
                end
                print(" $str[$val]")
            end

            println("")
        end

        if false
            if i == 1
                @info names
            end
            print("$i :")
            @printf "%-3d" i
            for name in names
                count = 0
                print(" ")
                all_ones = true
                for key in keys(conj_dict[name])
                    if conj_dict[name][key]
                        print("1")
                        count += 1
                    else
                        print("0")
                        all_ones = false
                    end
                end
                if all_ones
                    push!(all_list, (name, i))
                    println("---- ")
                end
            end

            println("")
        end

    end

    @info "Monitoring: " monitor
    display(when_rx_low)

    if true
        for name in names
            print("$name :")
            for key in keys(conj_dict[name])
                print(" $key")
            end
            println("")
        end
    end

    graph = 1   # 0,...,4

    if graph == 0
        G, vertex_list, vertex_dict = make_graph(succ_dict)
    else
        G, vertex_list, vertex_dict = make_graph(succ_dict, Set(groups[graph]))
    end
    display(G)

    vertex_labels = []
    for v in vertex_list
        if haskey(flipflop_dict, v)
            v = "%" * v
        elseif haskey(conj_dict, v)
            v = "&" * v
        end
        push!(vertex_labels, v)
    end

    @drawsvg begin
        background("black")
        sethue("grey40")
        drawgraph(G, 
            layout=spring,
            edgestrokeweights = 1, 
            vertexlabels = vertex_labels,
            edgecurvature=5,
            vertexfillcolors = 
                [RGB(rand(3)/2...) 
                for i in 1:nv(G)]
        )
    end 600 400

    p = gplot(G, nodelabel=vertex_list)
    display(p)

#    draw(PDF("mygraph.pdf", 50cm, 50cm), gplot(G, nodelabel=vertex_list))

    # The conclusion is that the system consists of 4 binary counters
    # with different reset times. The right signals are only sent when_rx_low
    # the counters reset, so the first signal is got when all the counters
    # reset at the same time. Here is the final conclusion:

    xd_reset = Int(0b111100100101)
    ts_reset = Int(0b111010111001)
    vr_reset = Int(0b111101001101)
    pf_reset = Int(0b111011111001)

    result_2 = xd_reset * ts_reset * vr_reset * pf_reset
    @show result_2

end
