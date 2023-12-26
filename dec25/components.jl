#
# This is a solution to the Advent of Code 2023 problem for day 25 in Julia 1.9:
#
# https://adventofcode.com/2023/day/25
#
# It needs the corresponding input.txt stored into the same directory.
#
# Note: The solution required some investigation of the input.

using Graphs
using GraphPlot
import Cairo, Fontconfig
using Compose


function example_data()
    return [
        "jqt: rhn xhk nvd", 
        "rsh: frs pzl lsr", 
        "xhk: hfx", 
        "cmg: qnr nvd lhk bvb", 
        "rhn: xhk bvb hfx", 
        "bvb: xhk hfx", 
        "pzl: lsr hfx nvd", 
        "qnr: nvd", 
        "ntq: jqt hfx bvb xhk", 
        "nvd: lhk", 
        "lsr: lhk", 
        "rzs: qnr cmg lsr rsh", 
        "frs: qnr lhk lsr"
    ]
end


function make_graph(lines)

    # Make list and dictionary of vertices
    count = 0
    vertex_list = []
    vertex_dict = Dict()
    for line in lines
        tmp = split(line, ": ")
        v1 = tmp[1]
        if !haskey(vertex_dict, v1)
            count += 1
            vertex_dict[v1] = count
            push!(vertex_list, v1)
        end
        for v2 in split(tmp[2], " ")
            if !haskey(vertex_dict, v2)
                count += 1
                vertex_dict[v2] = count
                push!(vertex_list, v2)
            end
        end
    end

    # Add edges to the graph
#    @show count
    
    G = Graph(count)

    for line in lines
        tmp = split(line, ": ")
        v1 = tmp[1]
        for v2 in split(tmp[2], " ")
            add_edge!(G, vertex_dict[v1], vertex_dict[v2])
        end
    end

    return G, vertex_list, vertex_dict
end

function rem_edges(G, vertex_dict, to_remove)
    # This is super inefficient, but works

    rem_list = []
    for e_str in to_remove
        e_lst = split(e_str, "/")
        v1 = vertex_dict[e_lst[1]]
        v2 = vertex_dict[e_lst[2]]
        push!(rem_list, (v1, v2))
        push!(rem_list, (v2, v1))
    end

#    @show rem_list

    new_G = Graph(nv(G))

    for e in edges(G)
        if (src(e),dst(e)) ∉ rem_list
            add_edge!(new_G, src(e), dst(e))            
        else
#            @show src(e) dst(e)
        end
    end

    return new_G
end    

open("input.txt") do io
    lines = readlines(io)
#    lines = example_data()

    G, vertex_list, vertex_dict = make_graph(lines)
#    display(G)

    p = gplot(G, nodelabel=vertex_list)
    display(p)

    draw(PDF("mygraph.pdf", 16cm, 16cm), gplot(G, nodelabel=vertex_list))

#    C = connected_components(G)
#    @info "Original connected components:" length(C)

    # At this point, you look at the graph in the stored PDF and see which the
    # 3 cluster connecting lines are:
    to_remove = ["mvv/xkz", "gbc/hxr", "tmt/pnz"]
#    to_remove = ["hfx/pzl", "bvb/cmg", "nvd/jqt"]

    new_G = rem_edges(G, vertex_dict, to_remove)
#    display(new_G)

    gplot(new_G, nodelabel=vertex_list)

    C = connected_components(new_G)
    @info "New connected components:" length(C) prod(map(c -> length(c), C))

    p = gplot(new_G, nodelabel=vertex_list)
    display(p)
end
