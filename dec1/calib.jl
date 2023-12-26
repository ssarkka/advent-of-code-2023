#
# This is a solution to the Advent of Code 2023 problem for day 1 in Julia 1.9:
#
# https://adventofcode.com/2023/day/1
#
# It needs the corresponding input.txt stored into the same directory.

function get_total(lines)
    total = 0

    for line in lines
        i = findfirst(isnumeric, line)
        first_digit =  line[i]

        i = findlast(isnumeric, line)
        last_digit = line[i]

        number = parse(Int, first_digit * last_digit)
        total = total + number
    end

    return total
end

function text_to_digits(lines)
    digits = ["one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]

    new_lines = Array{String}(undef, 0)

    for line in lines
        new_line = ""
        i = 1
        while i <= length(line)
            j = 1
            dig = 0
            len = 1
            while j <= length(digits) && dig == 0
                k = i + length(digits[j]) - 1
                if k <= length(line) && line[i:k] == digits[j]
                    dig = j
                    len = length(digits[j])
                end
                j = j + 1
            end

            if dig != 0
                new_line = new_line * "$dig"
#                i = i + len
                i = i + 1
            else
                new_line = new_line * line[i]
                i = i + 1
            end
        end

        push!(new_lines, new_line)

#        print(line * "\n")
#        print(new_line * "\n")
    end

    return new_lines
end


open("input.txt", "r") do io
    lines = readlines(io)
#    lines = ["1abc2", "pqr3stu8vwx", "a1b2c3d4e5f", "treb7uchet"]
    
    total = get_total(lines)
    print("Total 1 = $total\n")

#    lines = ["two1nine", "eightwothree", "abcone2threexyz", "xtwone3four", "4nineeightseven2", "zoneight234", "7pqrstsixteen"]
    new_lines = text_to_digits(lines)
    total = get_total(new_lines)
    print("Total 2 = $total\n")
end

