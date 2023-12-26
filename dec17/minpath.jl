#
# This is a solution to the Advent of Code 2023 problem for day 17 in Julia 1.9:
#
# https://adventofcode.com/2023/day/17
#
# It needs the corresponding input.txt stored into the same directory.

function example_data()
    return [
        "2413432311323", 
        "3215453535623", 
        "3255245654254", 
        "3446585845452", 
        "4546657867536", 
        "1438598798454", 
        "4457876987766", 
        "3637877979653", 
        "4654967986887", 
        "4564679986453", 
        "1224686865563", 
        "2546548887735", 
        "4322674655533"]
end

function example_data_2()
    return [
        "111111111111", 
        "999999999991", 
        "999999999991", 
        "999999999991", 
        "999999999991"
    ]
end

function get_cost_matrix(lines)
    C = Array{Int}(undef, length(lines), length(lines[1]))
    for i in 1:length(lines)
        for j in 1:length(lines[i])
            C[i,j] = parse(Int, lines[i][j:j])
        end
    end

    return C
end

function solve_path(C, max_steps, min_n=1, max_n=3)
    rows = size(C,1)
    cols = size(C,2)

    turn = Dict()
    turn[(1,0,-1)] = (0,1)
    turn[(1,0,0)]  = (1,0)
    turn[(1,0,1)]  = (0,-1)
    turn[(-1,0,-1)] = (0,-1)
    turn[(-1,0,0)]  = (-1,0)
    turn[(-1,0,1)]  = (0,1)
    turn[(0,1,-1)] = (-1,0)
    turn[(0,1,0)]  = (0,1)
    turn[(0,1,1)]  = (1,0)
    turn[(0,-1,-1)] = (1,0)
    turn[(0,-1,0)]  = (0,-1)
    turn[(0,-1,1)]  = (-1,0)

    U = Dict()
    V = Dict()
    V[(rows, cols, 1, 0)] = 0
    V[(rows, cols, 0, 1)] = 0
    U[(rows, cols, 1, 0)] = []
    U[(rows, cols, 0, 1)] = []

    i_opt = 0
    U_opt = []
    V_opt = typemax(Int)

    for i in 1:max_steps
        V_prev = V
        U_prev = U
        V = Dict()
        U = Dict()
        for (r,c,dr,dc) in keys(V_prev)
            for θ in [-1,1]
                (pdr, pdc) = turn[(dr, dc, -θ)]
                for n in min_n:max_n
                    pr = r - n * pdr
                    pc = c - n * pdc
                    if 1 ≤ pr ≤ rows && 1 ≤ pc ≤ cols
                        u = [n,θ]
                        cost = 0
                        for m in 1:n
                            cost += C[r - (m-1) * pdr, c - (m-1) * pdc]
                        end
                        px = (r - n * pdr, c - n * pdc, pdr, pdc)
                        qval = cost + V_prev[(r,c,dr,dc)]
                        if haskey(V, px)
                            if qval < V[px]
                                V[px] = qval
                                U[px] = vcat([u], U_prev[(r,c,dr,dc)])
                            end
                        else
                            V[px] = qval
                            U[px] = vcat([u], U_prev[(r,c,dr,dc)])
                        end
                    end
                end
            end
        end

        key = (1, 1, 0, 1)
        if haskey(V, key) && V[key] < V_opt
            U_opt = U[key]
            V_opt = V[key]
            i_opt = i

#            @show key V_opt i_opt
        end

        key = (1, 1, 1, 0)
        if haskey(V, key) && V[key] < V_opt
            U_opt = U[key]
            V_opt = V[key]
            i_opt = i

#            @show key V_opt i_opt
        end
    end

    return V_opt, U_opt, i_opt
end

open("input.txt") do io
    lines = readlines(io)
#    lines = example_data()
#    lines = example_data_2()

    C = get_cost_matrix(lines)

    V_opt1, U_opt1, i_opt1 = solve_path(C, 300)

#    display(U_opt1)
    @show V_opt1 


    V_opt2, U_opt2, i_opt2 = solve_path(C, 300, 4, 10)

#    display(U_opt2)
    @show V_opt2 
end
