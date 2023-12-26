#
# This is a solution to the Advent of Code 2023 problem for day 8 in Julia 1.9:
#
# https://adventofcode.com/2023/day/8
#
# It needs the corresponding input.txt stored into the same directory.
#
# Note: This solution required a bit of exploring of the properties of the
# input and this code just outputs the final answer, the exploration parts
# are commented out.

function parse_network(lines)
    inst = lines[1]

    all_vertices = Array{String}(undef, 0)
    all_left_edges = Array{String}(undef, 0)
    all_right_edges = Array{String}(undef, 0)

    vertex_dict = Dict{String,Int}()
    vertex_labels = Dict{Int,String}()

    v_index = 1
    for line in lines[2:end]
        if length(line) > 0
            e_v_strs = split(line, " = ")
            v_str = e_v_strs[1]
            if haskey(vertex_dict, v_index)
                @error "Oops"
            end
            vertex_dict[v_str] = v_index
            vertex_labels[v_index] = v_str
            v_index += 1

            e_strs = split(e_v_strs[2], ", ")
            el_str = e_strs[1][2:end]
            er_str = e_strs[2][1:end-1]

            push!(all_vertices, v_str)
            push!(all_left_edges, el_str)
            push!(all_right_edges, er_str)

#            @show v_str el_str er_str
        end
    end

    edges = Dict{Int,Tuple{Int,Int}}()

    for (v_str, el_str, er_str) in zip(all_vertices, all_left_edges, all_right_edges)
        v  = vertex_dict[v_str]
        el = vertex_dict[el_str]
        er = vertex_dict[er_str]
        edges[v] = (el,er)
    end

    return inst, vertex_dict, vertex_labels, edges
end

function traverse(v_source, v_target, inst, vertex_labels, edges, max_count)

    count = 0

#    @show v_source vertex_labels[v_source]
#    @show v_target vertex_labels[v_target]

    edge_list = []

    inst_index = 1
    while (count == 0 || v_source != v_target) && count < max_count
        edge = edges[v_source]

        if inst[inst_index] == 'L'
            v_source = edge[1]
        else
            v_source = edge[2]
        end

        count += 1
        inst_index += 1
        if inst_index > length(inst)
            inst_index = 1
        end
    end

    return count
end

function find_ends_to(vertex_labels, ch)
    new_list = []
    for v_key in keys(vertex_labels)
        v_lbl = vertex_labels[v_key]
        if v_lbl[end] == ch
            push!(new_list, v_key)
        end
    end

    return new_list
end

function count_matrix(v_sources, v_targets, inst, vertex_dict, vertex_labels, edges, max_count)
    mat = Array{Int}(undef, length(v_sources), length(v_targets))

    for i in 1:length(v_sources)
        for j in 1:length(v_targets)
            mat[i,j] = traverse(v_sources[i], v_targets[j], inst, vertex_labels, edges, max_count)
        end
    end

    return mat
end


function solve_and_check(x1, a, b)
    x = zeros(Int, size(a))

    x[1] = x1
    for n in 2:length(x)
        tmp = a[n-1] - a[n] + x[n-1] * b[n-1]
        if tmp % b[n] == 0
            x[n] = tmp / b[n]
        else
            return [], []
        end
#        @show x
    end

    c = zeros(Int, size(a))

    for n in 1:length(x)
        c[n] = a[n] + x[n] * b[n]
    end
    
    return x, c
end

function solve_diop(a, b)
    # a[n] + x[n] b[n] = a[n-1] + x[n-1] b[n-1] 
    # x[n] = (a[n-1] - a[n] + x[n-1] b[n-1]) / b[n] 

    x = []
    c = []
    x1 = 1
    while isempty(x)
        x, c = solve_and_check(x1, a, b)
        x1 += 1
    end

    return x, c
end

open("input.txt") do io
    lines = readlines(io);

#    lines = ["RL", "", "AAA = (BBB, CCC)", "BBB = (DDD, EEE)", "CCC = (ZZZ, GGG)", "DDD = (DDD, DDD)", "EEE = (EEE, EEE)", "GGG = (GGG, GGG)", "ZZZ = (ZZZ, ZZZ)"]
#    lines = ["LLR", "", "AAA = (BBB, BBB)", "BBB = (AAA, ZZZ)", "ZZZ = (ZZZ, ZZZ)"]
#    lines = ["LR", "", "11A = (11B, XXX)", "11B = (XXX, 11Z)", "11Z = (11B, XXX)", "22A = (22B, XXX)", "22B = (22C, 22C)", "22C = (22Z, 22Z)", "22Z = (22B, 22B)", "XXX = (XXX, XXX)"]

    inst, vertex_dict, vertex_labels, edges = parse_network(lines);
    v_source = vertex_dict["AAA"]
    v_target = vertex_dict["ZZZ"]
    max_count = 100000
    count_1 = traverse(v_source, v_target, inst, vertex_labels, edges, max_count)
    @show count_1

    a_list = find_ends_to(vertex_labels, 'A');
    z_list = find_ends_to(vertex_labels, 'Z');
    az_list = vcat(a_list, z_list)

#    mat = count_matrix(az_list, az_list, inst, vertex_dict, vertex_labels, edges, max_count);
#    @show mat;

    A1_Z3 = 19951
    A2_Z6 = 14893
    A3_Z2 = 20513
    A4_Z5 = 13207
    A5_Z1 = 12083
    A6_Z4 = 22199
    Z1_Z1 = 12083
    Z2_Z2 = 20513
    Z3_Z3 = 19951
    Z4_Z4 = 22199
    Z5_Z5 = 13207
    Z6_Z6 = 14893

    x,c = solve_diop([A5_Z1, A3_Z2, A1_Z3, A6_Z4, A4_Z5, A2_Z6],
                     [Z1_Z1, Z2_Z2, Z3_Z3, Z4_Z4, Z5_Z5, Z6_Z6])
#    @show x
#    @show c

    count_2 = c[1]
    @show count_2
end
