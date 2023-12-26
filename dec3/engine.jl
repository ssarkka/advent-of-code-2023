#
# This is a solution to the Advent of Code 2023 problem for day 3 in Julia 1.9:
#
# https://adventofcode.com/2023/day/3
#
# It needs the corresponding input.txt stored into the same directory.

function example_data()
    lines = [
        "467..114..", 
        "...*......", 
        "..35..633.", 
        "......#...", 
        "617*......", 
        ".....+.58.", 
        "..592.....", 
        "......755.", 
        "...\$.*....", 
        ".664.598.."
    ]
    return lines
end

function issym(ch)
    return !isnumeric(ch) && ch != '.'
end

function find_touching(lines)
    touching_numbers = Array{Int}(undef, 0)
    sym_linenos = Array{Int}(undef, 0)
    sym_charnos = Array{Int}(undef, 0)

    all_sym_linenos = Array{Array{Int}}(undef, 0)
    all_sym_charnos = Array{Array{Int}}(undef, 0)

    for lineno in 1:length(lines)
        line = lines[lineno]

        if lineno > 1
            prev_line = lines[lineno - 1]
        else
            prev_line = repeat(".", length(line))
        end

        if lineno < length(lines)
            next_line = lines[lineno + 1]
        else
            next_line = repeat(".", length(line))
        end

        in_num = false
        num_str = ""
        touching = false
        sym_linenos = Array{Int}(undef, 0)
        sym_charnos = Array{Int}(undef, 0)

        for charno in 1:length(line)
            if isnumeric(line[charno])
                if in_num
                    num_str = num_str * line[charno]
                else
                    num_str = line[charno]
                    in_num = true
                end

                if charno > 1 && issym(line[charno - 1])
                    touching = true
                    push!(sym_linenos, lineno)
                    push!(sym_charnos, charno - 1)
                end
                if charno < length(line) && issym(line[charno + 1])
                    touching = true
                    push!(sym_linenos, lineno)
                    push!(sym_charnos, charno + 1)
                end

                if charno > 1 && issym(prev_line[charno - 1])
                    touching = true
                    push!(sym_linenos, lineno - 1)
                    push!(sym_charnos, charno - 1)
                end
                if issym(prev_line[charno])
                    touching = true
                    push!(sym_linenos, lineno - 1)
                    push!(sym_charnos, charno)
                end
                if charno < length(prev_line) && issym(prev_line[charno + 1])
                    touching = true
                    push!(sym_linenos, lineno - 1)
                    push!(sym_charnos, charno + 1)
                end

                if charno > 1 && issym(next_line[charno - 1])
                    touching = true
                    push!(sym_linenos, lineno + 1)
                    push!(sym_charnos, charno - 1)
                end
                if issym(next_line[charno])
                    touching = true
                    push!(sym_linenos, lineno + 1)
                    push!(sym_charnos, charno)
                end
                if charno < length(next_line) && issym(next_line[charno + 1])
                    touching = true
                    push!(sym_linenos, lineno + 1)
                    push!(sym_charnos, charno + 1)
                end

            else
                if in_num
                    number = parse(Int, num_str)
                    if touching
                        push!(touching_numbers, number)
                        push!(all_sym_linenos, sym_linenos)
                        push!(all_sym_charnos, sym_charnos)
                        sym_linenos = Array{Int}(undef, 0)
                        sym_charnos = Array{Int}(undef, 0)
                    end

#                    print("$(number), $(touching), $(sym_linenos), $(sym_charnos)\n")
                    in_num = false
                    touching = false
                end
            end
        end

        if in_num
            number = parse(Int, num_str)
            if touching
                push!(touching_numbers, number)
                push!(all_sym_linenos, sym_linenos)
                push!(all_sym_charnos, sym_charnos)
                sym_linenos = Array{Int}(undef, 0)
                sym_charnos = Array{Int}(undef, 0)
            end
        end
    end

    return touching_numbers, all_sym_linenos, all_sym_charnos
end

function just_stars(lines)
    new_lines = Array{String}(undef, 0);

    for line in lines
        new_line = ""

        for ch in line
            if isnumeric(ch) || ch == '*'
                new_line = new_line * ch
            else
                new_line = new_line * '.'
            end
        end

        push!(new_lines, new_line)
    end

    return new_lines
end

function sum_gears(gear_touching_numbers, all_sym_linenos, all_sym_charnos)
    gear_sum = 0;

    done = Dict{String,Bool}()

    for i in 1:(length(gear_touching_numbers)-1)
        for j in (i+1):length(gear_touching_numbers)

            linenos_i = all_sym_linenos[i]
            charnos_i = all_sym_charnos[i]
            linenos_j = all_sym_linenos[j]
            charnos_j = all_sym_charnos[j]

            for ki in 1:length(linenos_i)
                for kj in 1:length(linenos_j)
                    if linenos_i[ki] == linenos_j[kj] && charnos_i[ki] == charnos_j[kj]
                        lino = linenos_i[ki]
                        chno = charnos_i[ki]
                        ni = gear_touching_numbers[i]
                        nj = gear_touching_numbers[j]

                        str = "Gear at $(lino), $(chno) touches $(ni) and $(nj)."
                        if !haskey(done, str)
                            done[str] = true
#                            print("$(str)\n")

                            gear_sum += ni * nj
                        end
                    end
                end
            end
        end
    end

    return gear_sum
end

open("input.txt", "r") do io

    lines = readlines(io)
#    lines = example_data()

    touching_numbers, all_sym_linenos, all_sym_charnos = find_touching(lines)
#    print("$(touching_numbers)\n")
    s = sum(touching_numbers)

    print("Sum 1 = $(s)\n")

    new_lines = just_stars(lines)
#    for line in new_lines
#        print("$(line)\n")
#    end

    gear_touching_numbers, all_sym_linenos, all_sym_charnos = find_touching(new_lines)

#    print("Numbers = $(gear_touching_numbers)\n")
#    print("Linenos = $(all_sym_linenos)\n")
#    print("Charnos = $(all_sym_charnos)\n")

    gear_sum = sum_gears(gear_touching_numbers, all_sym_linenos, all_sym_charnos)
    print("Sum 2 = $(gear_sum)\n")
end
