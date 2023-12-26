#
# This is a solution to the Advent of Code 2023 problem for day 2 in Julia 1.9:
#
# https://adventofcode.com/2023/day/2
#
# It needs the corresponding input.txt stored into the same directory.

function parse_line(line)
#    print("$(line)\n");

    game_rest = split(line, ": ")
    game = parse(Int, split(game_rest[1], " ")[2])

#    print("$(game_rest)\n")
#    print("$(game)\n")

    reds = Array{Int}(undef, 0)
    greens = Array{Int}(undef, 0)
    blues = Array{Int}(undef, 0)

    subgames = split(game_rest[2], "; ")

    for subgame in subgames
        colors = split(subgame, ", ")

        red = 0
        green = 0
        blue = 0
        for color in colors
            count_color = split(color, " ")
            count = parse(Int, count_color[1])
            if count_color[2] == "red"
                red = count
            elseif count_color[2] == "green"
                green = count
            elseif count_color[2] == "blue"
                blue = count
            end
        end
#        print("$(red), $(green), $(blue)\n")
        push!(reds, red)
        push!(greens, green)
        push!(blues, blue)
    end

    return game, reds, greens, blues
end

function sum_valid_games(lines)
    sum = 0

    for line in lines
        game, reds, greens, blues = parse_line(line)

        if maximum(reds) <= 12 && maximum(greens) <= 13 && maximum(blues) <= 14
            sum = sum + game
        end
    end

    return sum
end

function sum_powers(lines)
    sum = 0

    for line in lines
        game, reds, greens, blues = parse_line(line)

        red = maximum(reds)
        green = maximum(greens)
        blue = maximum(blues)
        power = red * green * blue

        sum = sum + power
    end

    return sum
end

open("input.txt", "r") do io
    lines = readlines(io)
 #   lines = ["Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green", "Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue", "Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red", "Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red", "Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green"]

    sum = sum_valid_games(lines)

    print("Sum 1 = $sum\n")

    sum = sum_powers(lines)

    print("Sum 2 = $sum\n")
end
