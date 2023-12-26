#
# This is a solution to the Advent of Code 2023 problem for day 11 in Julia 1.9:
#
# https://adventofcode.com/2023/day/11
#
# It needs the corresponding input.txt stored into the same directory.

function expand_universe_lines(lines)
    new_lines = []
    for line in lines
        if line == repeat('.', length(line))
            push!(new_lines, line)
        end
        push!(new_lines, line)
    end

    return new_lines
end

function transpose_universe(lines)
    new_lines = []

    for j in 1:lastindex(lines[1])
        new_line = ""
        for i in 1:lastindex(lines)
            new_line *= lines[i][j]
        end
        push!(new_lines, new_line)
    end

    return new_lines
end


function expand_universe(lines)
    return expand_universe_lines(transpose_universe(expand_universe_lines(transpose_universe(lines))))
end


function find_galaxies(lines)
    galaxies = []

    for i in 1:lastindex(lines)
        for j in 1:lastindex(lines[1])
            if lines[i][j] == '#'
                push!(galaxies, (i,j))
            end
        end
    end

    return galaxies
end

function shortest(g1, g2)
    i1, j1 = g1
    i2, j2 = g2

    di = abs(i2 - i1)
    dj = abs(j2 - j1)

    return di + dj
end

function sum_of_paths(galaxies)
    s = 0

    for i in 1:length(galaxies)-1
        for j in i+1:length(galaxies)
            s += shortest(galaxies[i], galaxies[j])
        end
    end

    return s
end


function find_empty_lines(lines)
    indices = []

    for i in 1:length(lines)
        if lines[i] == repeat('.', length(lines[i]))
            push!(indices, i)
        end
    end

    return indices
end

function expand_galaxies(galaxies, empty_rows, empty_cols, factor)
    new_galaxies = []

    for i in 1:length(galaxies)
        offset = 0
        for j in 1:length(empty_rows)
            if galaxies[i][1] > empty_rows[j]
                offset += factor - 1
            end
        end
        new_i = galaxies[i][1] + offset

        offset = 0
        for j in 1:length(empty_cols)
            if galaxies[i][2] > empty_cols[j]
                offset += factor - 1
            end
        end
        new_j = galaxies[i][2] + offset

        push!(new_galaxies, (new_i, new_j))
    end

    return new_galaxies
end


open("input.txt") do io
    lines = readlines(io)
#    lines = ["...#......", ".......#..", "#.........", "..........", "......#...", ".#........", ".........#", "..........", ".......#..", "#...#....."]
   
#    display(lines)

    trans_uni = transpose_universe(lines)

 #   display(trans_uni)

    exp_lines = expand_universe(lines)

#    display(exp_lines)

    galaxies = find_galaxies(exp_lines)

#    @show galaxies

    shortest(galaxies[1], galaxies[7])

    s = sum_of_paths(galaxies)
    @show s

    #

    galaxies = find_galaxies(lines)

    empty_rows = find_empty_lines(lines)
    tmp = transpose_universe(lines)
    empty_cols = find_empty_lines(tmp)

    galaxies_2 = expand_galaxies(galaxies, empty_rows, empty_cols, 1000000)
 #   @show galaxies_2

    s_2 = sum_of_paths(galaxies_2)
    @show s_2
end

