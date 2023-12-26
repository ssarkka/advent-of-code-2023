#
# This is a solution to the Advent of Code 2023 problem for day 23 in Julia 1.9:
#
# https://adventofcode.com/2023/day/23
#
# It needs the corresponding input.txt stored into the same directory.

function example_data()
    return [
        "#.#####################", 
        "#.......#########...###", 
        "#######.#########.#.###", 
        "###.....#.>.>.###.#.###", 
        "###v#####.#v#.###.#.###", 
        "###.>...#.#.#.....#...#", 
        "###v###.#.#.#########.#", 
        "###...#.#.#.......#...#", 
        "#####.#.#.#######.#.###", 
        "#.....#.#.#.......#...#", 
        "#.#####.#.#.#########v#", 
        "#.#...#...#...###...>.#", 
        "#.#.#v#######v###.###v#", 
        "#...#.>.#...>.>.#.###.#", 
        "#####v#.#.###v#.#.###.#", 
        "#.....#...#...#.#.#...#", 
        "#.#########.###.#.#.###", 
        "#...###...#...#...#.###", 
        "###.###.#.###v#####v###", 
        "#...#...#.#.>.>.#.>.###", 
        "#.###.###.#.###.#.#v###", 
        "#.....###...###...#...#", 
        "#####################.#"        
    ]
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


function find_max_routes(M, r, c)
    if M[r, c] ∉ ".<>^v"
        return []
    end
    if r == size(M,1)
        return [(r,c)]
    end

    m = M[r, c]
    M[r, c] = 'O'

    if m == '.'
        sub_route = []
        if r > 1
            cand_sub_route = find_max_routes(M, r-1, c)
            if length(cand_sub_route) > length(sub_route)
                sub_route = cand_sub_route
            end
        end
        if c > 1
            cand_sub_route = find_max_routes(M, r, c-1)
            if length(cand_sub_route) > length(sub_route)
                sub_route = cand_sub_route
            end
        end
        if r < size(M,1)
            cand_sub_route = find_max_routes(M, r+1, c)
            if length(cand_sub_route) > length(sub_route)
                sub_route = cand_sub_route
            end
        end
        if c < size(M,2)
            cand_sub_route = find_max_routes(M, r, c+1)
            if length(cand_sub_route) > length(sub_route)
                sub_route = cand_sub_route
            end
        end
    elseif m == '<'
        sub_route = find_max_routes(M, r, c-1)
    elseif m == '>'
        sub_route = find_max_routes(M, r, c+1)
    elseif m == '^'
        sub_route = find_max_routes(M, r-1, c)
    elseif m == 'v'
        sub_route = find_max_routes(M, r+1, c)
    end

    M[r, c] = m

    if length(sub_route) > 0
        return vcat([(r,c)], sub_route)
    end
    
    return []
end

function find_max_routes_2(M, r, c)
    allowed = ".<>^v"
    if M[r, c] ∉ allowed
        return []
    end
    if r == size(M,1)
        return [(r,c)]
    end

    m = M[r, c]
    M[r, c] = 'O'

    sub_route = []
    if m ∈ allowed
        if r > 1
            cand_sub_route = find_max_routes_2(M, r-1, c)
            if length(cand_sub_route) > length(sub_route)
                sub_route = cand_sub_route
            end
        end
        if c > 1
            cand_sub_route = find_max_routes_2(M, r, c-1)
            if length(cand_sub_route) > length(sub_route)
                sub_route = cand_sub_route
            end
        end
        if r < size(M,1)
            cand_sub_route = find_max_routes_2(M, r+1, c)
            if length(cand_sub_route) > length(sub_route)
                sub_route = cand_sub_route
            end
        end
        if c < size(M,2)
            cand_sub_route = find_max_routes_2(M, r, c+1)
            if length(cand_sub_route) > length(sub_route)
                sub_route = cand_sub_route
            end
        end
    end

    M[r, c] = m

    if length(sub_route) > 0
        return vcat([(r,c)], sub_route)
    end
    
    return []
end

open("input.txt") do io
    lines = readlines(io)
#    lines = example_data()

    M = to_matrix(lines)

    route = find_max_routes(M, 1, 2)
    steps1 = length(route)-1
    @show steps1

    M = to_matrix(lines)
    
    route = find_max_routes_2(M, 1, 2)
    steps2 = length(route)-1
    @show steps2

end

