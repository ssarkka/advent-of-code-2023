#
# This is a solution to the Advent of Code 2023 problem for day 14 in Julia 1.9:
#
# https://adventofcode.com/2023/day/14
#
# It needs the corresponding input.txt stored into the same directory.
#
# Note: This solution required a bit of exploring of the properties of the input.

function example_data()
    return [
        "O....#....", 
        "O.OO#....#", 
        ".....##...", 
        "OO.#O....O", 
        ".O.....O#.", 
        "O.#..O.#.#", 
        "..O..#O..O", 
        ".......O..", 
        "#....###..", 
        "#OO..#...."
    ]
end

function get_matrix(lines)
    rows = length(lines)
    cols = length(lines[1])

    m = Array{Char}(undef, rows, cols)

    for i in 1:rows
        for j in 1:cols
            m[i,j] = lines[i][j]
        end
    end

    return m
end

function rollem!(m)
    changes = 1

    while changes > 0
        changes = 0
        for i in 1:size(m,1)-1
            for j in 1:size(m,2)
                if m[i,j] == '.' && m[i+1,j] == 'O'
                    m[i,j] = 'O'
                    m[i+1,j] = '.'
                    changes += 1
                end
            end
        end
#        display(m)
    end
end

function rotate!(new_m, m)
    for i in 1:size(m,1)
        for j in 1:size(m,2)
            new_i = j
            new_j = size(new_m,2) + 1 - i

            new_m[new_i,new_j] = m[i,j]
        end
    end
end

function compute_weight(m)
    w = 0

    for i in 1:size(m,1)
        for j in 1:size(m,2)
            if m[i,j] == 'O'
                w += size(m,1)+1-i
            end
        end
    end

    return w
end

open("input.txt") do io
    lines = readlines(io)
#    lines = example_data()

#    display(lines)

    m = get_matrix(lines)
    rollem!(m)
    w = compute_weight(m)
    @info "Answer to part 1:" w


    m = get_matrix(lines)
#    display(m)

    mt = Array{Char}(undef, size(m,2), size(m,1))

#    n = 1000000000
#    n = 3
    n = 1000
    w_series = Array{Int}(undef, n)
    for i = 1:n
        rollem!(m)
        rotate!(mt, m)
        rollem!(mt)
        rotate!(m, mt)
        rollem!(m)
        rotate!(mt, m)
        rollem!(mt)
        rotate!(m, mt)
 
        w = compute_weight(m)
#        @show w

        w_series[i] = w
    end

    for i = length(w_series)-40:length(w_series)
        w = w_series[i]
        println("$i $w")
    end

    # We deduce that there is a period length of 17 and the second right answer (89089) is a index 993.
    @show 1000000000 % 17
    @show 993 % 17
end
