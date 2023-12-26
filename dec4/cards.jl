#
# This is a solution to the Advent of Code 2023 problem for day 4 in Julia 1.9:
#
# https://adventofcode.com/2023/day/4
#
# It needs the corresponding input.txt stored into the same directory.

function parse_card(line)
    cwo = match(r"Card\s+(\d+):\s+(\d(?:\d|\s)*\d)\s+\|\s+(\d(?:\d|\s)*\d)\s*$", line)
    card = parse(Int, cwo.captures[1])

    wins = map(s -> parse(Int, s), split(cwo.captures[2], r"\s+"))
    owns = map(s -> parse(Int, s), split(cwo.captures[3], r"\s+"))

    return card, wins, owns
end

function get_points(wins, owns)
    isect = intersect(wins, owns)
    points = 0
    if length(isect) > 0
        points = 2^(length(isect)-1)
    end
    return points
end

function total_points(lines)
    points = 0

    for line in lines
        @show line
        card, wins, owns = parse_card(line)
        points += get_points(wins, owns)
    end

    return points
end



function multiply_cards!(lines)
    i = 1

    while i <= length(lines)
        line = lines[i]
        card, wins, owns = parse_card(line)
        nwins = length(intersect(wins, owns))

        if nwins > 0
            for win_card in (card+1):(card+nwins)
#                println("Push $(lines[win_card])")
                push!(lines, lines[win_card])
            end
        end
        i = i + 1
    end

    return length(lines)
end


open("input.txt", "r") do io
    lines = readlines(io)
#    lines = ["Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53", "Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19", "Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1", "Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83", "Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36", "Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11"]

    points = total_points(lines)
    @show points

    count = multiply_cards!(lines)
    @show count
end

