#
# This is a solution to the Advent of Code 2023 problem for day 21 in Julia 1.9:
#
# https://adventofcode.com/2023/day/21
#
# It needs the corresponding input.txt stored into the same directory.
#
# Note: The solution required a bit of investigation of the properties of input.

using DelimitedFiles
using Plots

function example_data()
    return [
        "...........", 
        ".....###.#.", 
        ".###.##..#.", 
        "..#.#...#..", 
        "....#.#....", 
        ".##..S####.", 
        ".##..#...#.", 
        ".......##..", 
        ".##.#.####.", 
        ".##..##.##.", 
        "..........."
    ]
end

function extract_start!(lines)
    for r in 1:length(lines)
        for c in 1:length(lines[r])
            if lines[r][c] == 'S'
                lines[r] = replace(lines[r], "S" => ".", count=1)
                return (r,c)
            end
        end
    end

    return (0,0)
end

function to_matrix(lines)
    rows = length(lines)
    cols = length(lines[1])
    M = Array{Char}(undef, rows, cols)
    for r in 1:size(M,1)
        for c in 1:size(M,2)
            M[r, c] = lines[r][c]
        end
    end
    return M
end

function make_adj_dict(M)
    adj_dict = Dict{Tuple{Int,Int}, Array{Tuple{Int,Int}}}()

    for r in 1:size(M,1)
        for c in 1:size(M,2)
            adj_dict[(r,c)] = []
            if r > 1 && M[r-1, c] == '.'
                push!(adj_dict[(r,c)], (r-1,c))
            end
            if c > 1 && M[r, c-1] == '.'
                push!(adj_dict[(r,c)], (r,c-1))
            end
            if r < size(M,1) && M[r+1, c] == '.'
                push!(adj_dict[(r,c)], (r+1,c))
            end
            if c < size(M,2) && M[r, c+1] == '.'
                push!(adj_dict[(r,c)], (r,c+1))
            end
        end
    end

    return adj_dict
end

function solve_1(lines, N=64)
    start = extract_start!(lines)

#    @info start
    M = to_matrix(lines)
    
    adj_dict = make_adj_dict(M)
    pos_dict = Dict{Tuple{Int,Int},Int}()
    pos_dict[start] = 1

    for i in 1:N
        new_pos_dict = Dict{Tuple{Int,Int},Int}()
        for pos in keys(pos_dict)
            for new_pos in adj_dict[pos]
                if haskey(new_pos_dict, new_pos)
                    new_pos_dict[new_pos] += 1
                else
                    new_pos_dict[new_pos] = 1
                end
            end
        end
        pos_dict = new_pos_dict
    end

#    display(pos_dict)

    return length(pos_dict)
end


function make_wrap_adj_dict(M)
    adj_dict = Dict{Tuple{Int,Int}, Array{Tuple{Int,Int,Int,Int}}}()

    for r in 1:size(M,1)
        for c in 1:size(M,2)
            adj_dict[(r,c)] = []
            if r > 1 && M[r-1, c] == '.'
                push!(adj_dict[(r,c)], (r-1,c, 0,0))
            end
            if r == 1 && M[size(M,1), c] == '.'
                push!(adj_dict[(r,c)], (size(M,1),c, -1,0))
            end
            if c > 1 && M[r, c-1] == '.'
                push!(adj_dict[(r,c)], (r,c-1, 0,0))
            end
            if c == 1 && M[r, size(M,2)] == '.'
                push!(adj_dict[(r,c)], (r,size(M,2), 0,-1))
            end
            if r < size(M,1) && M[r+1, c] == '.'
                push!(adj_dict[(r,c)], (r+1,c, 0,0))
            end
            if r == size(M,1) && M[1, c] == '.'
                push!(adj_dict[(r,c)], (1,c, 1,0))
            end
            if c < size(M,2) && M[r, c+1] == '.'
                push!(adj_dict[(r,c)], (r,c+1, 0,0))
            end
            if c == size(M,2) && M[r, 1] == '.'
                push!(adj_dict[(r,c)], (r,1, 0,1))
            end
        end
    end

    return adj_dict
end

function make_wrap_adj_dict_b(M)
    adj_dict = Dict{Tuple{Int,Int}, Dict{Tuple{Int,Int,Int,Int},Bool}}()

    for r in 1:size(M,1)
        for c in 1:size(M,2)
            adj_dict[(r,c)] = Dict{Tuple{Int,Int,Int,Int},Bool}()
            if r > 1 && M[r-1, c] == '.'
                adj_dict[(r,c)][(r-1,c, 0,0)] = true
            end
            if r == 1 && M[size(M,1), c] == '.'
                adj_dict[(r,c)][(size(M,1),c, -1,0)] = true
            end
            if c > 1 && M[r, c-1] == '.'
                adj_dict[(r,c)][(r,c-1, 0,0)] = true
            end
            if c == 1 && M[r, size(M,2)] == '.'
                adj_dict[(r,c)][(r,size(M,2), 0,-1)] = true
            end
            if r < size(M,1) && M[r+1, c] == '.'
                adj_dict[(r,c)][(r+1,c, 0,0)] = true
            end
            if r == size(M,1) && M[1, c] == '.'
                adj_dict[(r,c)][(1,c, 1,0)] = true
            end
            if c < size(M,2) && M[r, c+1] == '.'
                adj_dict[(r,c)][(r,c+1, 0,0)] = true
            end
            if c == size(M,2) && M[r, 1] == '.'
                adj_dict[(r,c)][(r,1, 0,1)] = true
            end
        end
    end

    return adj_dict
end


function solve_2a(lines, N)
    (r,c) = extract_start!(lines)

#    @info (r,c)
    M = to_matrix(lines)
    
    adj_dict = make_wrap_adj_dict(M)
    posw_dict = Dict{Tuple{Int,Int,Int,Int},Int}()
    posw_dict[(r,c,0,0)] = 1

    counts = []
    for i in 1:N
#        println("$i / $N")

        new_posw_dict = Dict{Tuple{Int,Int,Int,Int},Int}()
        for (r,c,wr,wc) in keys(posw_dict)
            pos = (r,c)
            for (new_r, new_c, dwr, dwc) in adj_dict[pos]
                new_posw = (new_r, new_c, wr + dwr, wc + dwc)
                if haskey(new_posw_dict, new_posw)
                    new_posw_dict[new_posw] += 1
                else
                    new_posw_dict[new_posw] = 1
                end
            end
        end
        posw_dict = new_posw_dict
        push!(counts, length(keys(posw_dict)))
    end

#    display(posw_dict)

    return counts
end


function comb_adj_dicts(adj_dict_a, adj_dict_b)
    adj_dict_c = Dict{keytype(adj_dict_a),valtype(adj_dict_a)}()

    for pos_a in keys(adj_dict_a)
        tmp_dict = Dict{Tuple{Int,Int,Int,Int},Bool}()  # Could infer the type

        for elem_a in keys(adj_dict_a[pos_a])
            new_pos_a = elem_a[1:2]
            dw_a = elem_a[3:end]
            for elem_b in keys(adj_dict_b[new_pos_a])
                new_pos_b = elem_b[1:2]
                dw_b = elem_b[3:end]
                dw = dw_a .+ dw_b
                elem_c = (new_pos_b..., dw...)
                tmp_dict[elem_c] = true
            end
        end

        adj_dict_c[pos_a] = tmp_dict
    end

    return adj_dict_c
end


function solve_2b(lines, N)
    (r,c) = extract_start!(lines)

    @info (r,c)
    M = to_matrix(lines)
    
    unit_adj_dict = make_wrap_adj_dict_b(M)
    adj_power_dict = unit_adj_dict

    adj_dict = nothing
    while N != 0
        @show N
        if N & 1 != 0
            if isnothing(adj_dict)
                adj_dict = adj_power_dict
            else
                adj_dict = comb_adj_dicts(adj_dict, adj_power_dict)
            end
        end
        N >>= 1
        if N != 0
            adj_power_dict = comb_adj_dicts(adj_power_dict, adj_power_dict)
        end
    end

    posw_dict = Dict{Tuple{Int,Int,Int,Int},Int}()
    wr = 0
    wc = 0
    pos = (r,c)
    for (new_r, new_c, dwr, dwc) in keys(adj_dict[pos])
        posw = (new_r, new_c, wr + dwr, wc + dwc)
        if haskey(posw_dict, posw)
            posw_dict[posw] += 1
        else
            posw_dict[posw] = 1
        end
    end

    display(posw_dict)

    @show length(keys(posw_dict))

end



open("input.txt") do io
    lines = readlines(io)
#    lines = example_data()

    tmp_lines = []
    for line in lines
        push!(tmp_lines, line)
    end
    result_1 = solve_1(tmp_lines)

    @show result_1

    rows = length(lines)
    cols = length(lines[1])

#    @show rows cols

    from_file = false
#    from_file = true

    counts = []
    if !from_file
        println("Computing time series values...")
        counts = solve_2a(lines, 2000)

        open("counts.txt", "w") do io
            writedlm(io, counts)
        end
    else
        println("Loading time series values...")
        counts = readdlm("counts.txt", '\t', Int, '\n')[:,1]
    end

#    display(counts)
#    p = plot(1:length(counts)-1, diff(counts), markershape=:o, markersize=1)
#    display(p)
#    diff(diff(counts[1000:rows:end]))

    N = 1899
    Ns = collect(N-2*rows:rows:N)
    Cs = counts[N-2*rows:rows:N]

    A = [BigInt(Ns[1])^2 BigInt(Ns[1]) 1//1;
         BigInt(Ns[2])^2 BigInt(Ns[2]) 1//1;
         BigInt(Ns[3])^2 BigInt(Ns[3]) 1//1]
         
#    display(A)
#    display(Cs)
    abc = A \ Cs

    a = abc[1]
    b = abc[2]
    c = abc[3]

#    @show a b c

    N = 1899
#    @info counts[N] a * N^2 + b * N + c

    N=26501365
    result_2 = a * N^2 + b * N + c
    @show result_2

end
