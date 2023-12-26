#
# This is a solution to the Advent of Code 2023 problem for day 10 in Julia 1.9:
#
# https://adventofcode.com/2023/day/10
#
# It needs the corresponding input.txt stored into the same directory.

using Graphs
using GraphPlot

function deduce_S(lines)
    S_list = []
    crd_list = []
    new_lines = []

    for i in eachindex(lines)
        new_line = ""
        for j in eachindex(lines[i])
            if lines[i][j] == 'S'
                @info "S found in " (i,j)

                reachable = ""
                if j > 1 && (lines[i][j-1] ∈ ['F','L','-'])
                    reachable *= 'W'
                end
                if j < lastindex(lines[i]) && (lines[i][j+1] ∈ ['J','7','-'])
                    reachable *= 'E'
                end
                if i > 1 && (lines[i-1][j] ∈ ['F','7','|'])
                    reachable *= 'N'
                end
                if i < lastindex(lines) && (lines[i+1][j] ∈ ['J','L','|'])
                    reachable *= 'S'
                end
                reachable = join(sort(collect(reachable)))

                @info "S is reachable from " reachable

                S = nothing
                if reachable == "NS"
                    S = '|'
                elseif reachable == "EW"
                    S = '-'
                elseif reachable == "EN"
                    S = 'L'
                elseif reachable == "NW"
                    S = 'J'
                elseif reachable == "SW"
                    S = '7'
                elseif reachable == "ES"
                    S = 'F'
                else
                    @assert false "Cannot reduce S"
                end

                @info "S is thus " S

                push!(S_list, S)
                push!(crd_list, (i,j))

                new_line *= S
            else
                new_line *= lines[i][j]
            end
        end
        push!(new_lines, new_line)
    end

    return new_lines, S_list, crd_list
end

function get_reachable(c)
    if c == '|'
        reachable = "NS"
    elseif c == '-'
        reachable = "EW"                
    elseif c == 'L'
        reachable = "EN"
    elseif c == 'J'
        reachable = "NW"
    elseif c == '7'
        reachable = "SW"
    elseif c == 'F'
        reachable = "ES"
    else
        reachable = ""
    end
    return reachable
end

function make_graph(lines)
    nv = lastindex(lines) * lastindex(lines[1])

    G = Graph(nv)
    v2rc_dict = Dict{Int,Tuple{Int,Int}}()
    rc2v_dict = Dict{Tuple{Int,Int},Int}()

    v = 1
    for i in eachindex(lines)
        for j in eachindex(lines[i])
            v2rc_dict[v] = (i,j)
            rc2v_dict[(i,j)] = v
            v += 1
        end
    end

    for i in eachindex(lines)
        for j in eachindex(lines[i])
            c = lines[i][j]

            v1 = rc2v_dict[(i,j)]
            if i > 1 && ('N' ∈ get_reachable(c)) && ('S' ∈ get_reachable(lines[i-1][j]))
                v2 = rc2v_dict[(i-1,j)]
                add_edge!(G, v1, v2)
            end
            if i < lastindex(lines) && ('S' ∈ get_reachable(c)) && ('N' ∈ get_reachable(lines[i+1][j]))
                v2 = rc2v_dict[(i+1,j)]
                add_edge!(G, v1, v2)
            end
            if j > 1 && ('W' ∈ get_reachable(c)) && ('E' ∈ get_reachable(lines[i][j-1]))
                v2 = rc2v_dict[(i,j-1)]
                add_edge!(G, v1, v2)
            end
            if j < lastindex(lines[i]) && ('E' ∈ get_reachable(c)) && ('W' ∈ get_reachable(lines[i][j+1]))
                v2 = rc2v_dict[(i,j+1)]
                add_edge!(G, v1, v2)
            end
        end
    end

    return G, v2rc_dict, rc2v_dict
end

function clean_nonloop(lines, dists, v2rc_dict, rc2v_dict)
    new_lines = []
    for i in eachindex(lines)
        new_line = ""
        line = lines[i]
        for j in eachindex(line)
            d = dists[rc2v_dict[(i,j)]]
            if d >= 0
                new_line *= line[j]
            else
                new_line *= '.'
            end
        end
        push!(new_lines, new_line)
    end
    return new_lines
end

function get_inside(lines)
    cnt = 0

    new_lines = []
    for line in lines
        new_line = ""

        onpipe = false
        inside = false
        startc = '.'

        for c in line
            if onpipe
                if c == '7'
                    if startc == 'L'
                        inside = !inside
                    end
                    onpipe = false
                elseif c == 'J'
                    if startc == 'F'
                        inside = !inside
                    end
                    onpipe = false
                else
                    @assert c == '-'
                end
            else
                if c == 'F' || c == 'L'
                    startc = c
                    onpipe = true
                elseif c == '|'
                    inside = !inside
                else
                    @assert c == '.'
                end
            end

            if c == '.'
                new_line *= inside ? 'I' : 'O'
                if inside
                    cnt += 1
                end
            else
                new_line *= c
            end
        end

        push!(new_lines, new_line)
    end

    return new_lines, cnt
end

open("input.txt") do io
    lines = readlines(io)
#    lines = [".....", ".S-7.", ".|.|.",".L-J.","....."]
#    lines = ["..F7.", ".FJ|.", "SJ.L7", "|F--J", "LJ..."]
#    lines = ["7-F7-", ".FJ|7", "SJLL7", "|F--J", "LJ.LJ"]
#    lines = ["...........", ".S-------7.", ".|F-----7|.", ".||.....||.", ".||.....||.", ".|L-7.F-J|.", ".|..|.|..|.", ".L--J.L--J.", "..........."]
#    lines = ["..........", ".S------7.", ".|F----7|.", ".||....||.", ".||....||.", ".|L-7F-J|.", ".|..||..|.", ".L--JL--J.", ".........."]

    new_lines, Ss, coords = deduce_S(lines)

#    display(new_lines)

    graph, v2rc_dict, rc2v_dict = make_graph(new_lines);
 #   @show graph

    coord = coords[1]
    v = rc2v_dict[coord]

    paths = bellman_ford_shortest_paths(graph, v);

    dists = map(v -> v < typemax(Int) ? v : -1, paths.dists)

    mat = reshape(dists, lastindex(lines), lastindex(lines[1]))'
#    display(mat)

    max_dist = maximum(dists)

    @show max_dist

    new_lines_loop = clean_nonloop(new_lines, dists, v2rc_dict, rc2v_dict)
#    display(new_lines_loop)

    new_lines_loop_ins, cnt = get_inside(new_lines_loop)
#    display(new_lines_loop_ins)

    @show cnt
end
