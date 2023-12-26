#
# This is a solution to the Advent of Code 2023 problem for day 16 in Julia 1.9:
#
# https://adventofcode.com/2023/day/16
#
# It needs the corresponding input.txt stored into the same directory.

function example_data()
    return [
        ".|...\\....", 
        "|.-.\\.....", 
        ".....|-...", 
        "........|.", 
        "..........", 
        ".........\\", 
        "..../.\\\\..", 
        ".-.-/..|..", 
        ".|....-|.\\", 
        "..//.|...."]
end

function bounce(lines, max_iter, initial=(1,0,0,1))
    beams = [initial]
    rows = length(lines)
    cols = length(lines[1])

    energized = Array{Bool}(undef, rows, cols)
    energized .= false
            
    marked = Dict()

    iter = 0
    while !isempty(beams) && iter < max_iter
        new_beams = []
        for (r,c,dr,dc) in beams
            r += dr
            c += dc
            if r >= 1 && r <= rows && c >= 1 && c <= cols
                energized[r, c] = true
                if lines[r][c] == '|'
                    if dc != 0
                        # Split
                        elem = (r,c,1,0)
                        if !haskey(marked, elem)
                            marked[elem] = true
                            push!(new_beams, elem)
                        end
                        elem = (r,c,-1,0)
                        if !haskey(marked, elem)
                            marked[elem] = true
                            push!(new_beams, elem)
                        end
                    else
                        # Pass
                        elem = (r,c,dr,dc)
                        if !haskey(marked, elem)
                            marked[elem] = true
                            push!(new_beams, elem)
                        end
                    end
                elseif lines[r][c] == '-'
                    if dr != 0
                        # Split
                        elem = (r,c,0,1)
                        if !haskey(marked, elem)
                            marked[elem] = true
                            push!(new_beams, elem)
                        end
                        elem = (r,c,0,-1)
                        if !haskey(marked, elem)
                            marked[elem] = true
                            push!(new_beams, elem)
                        end
                    else
                        # Pass
                        elem = (r,c,dr,dc)
                        if !haskey(marked, elem)
                            marked[elem] = true
                            push!(new_beams, elem)
                        end
                    end
                elseif lines[r][c] == '/'
                    if dr == 1
                        elem = (r,c,0,-1)
                        if !haskey(marked, elem)
                            marked[elem] = true
                            push!(new_beams, elem)
                        end
                    elseif dr == -1
                        elem = (r,c,0,1)
                        if !haskey(marked, elem)
                            marked[elem] = true
                            push!(new_beams, elem)
                        end
                    elseif dc == 1
                        elem = (r,c,-1,0)
                        if !haskey(marked, elem)
                            marked[elem] = true
                            push!(new_beams, elem)
                        end
                    elseif dc == -1
                        elem = (r,c,1,0)
                        if !haskey(marked, elem)
                            marked[elem] = true
                            push!(new_beams, elem)
                        end
                    end
                elseif lines[r][c] == '\\'
                    if dr == 1
                        elem = (r,c,0,1)
                        if !haskey(marked, elem)
                            marked[elem] = true
                            push!(new_beams, elem)
                        end
                    elseif dr == -1
                        elem = (r,c,0,-1)
                        if !haskey(marked, elem)
                            marked[elem] = true
                            push!(new_beams, elem)
                        end
                    elseif dc == 1
                        elem = (r,c,1,0)
                        if !haskey(marked, elem)
                            marked[elem] = true
                            push!(new_beams, elem)
                        end
                    elseif dc == -1
                        elem = (r,c,-1,0)
                        if !haskey(marked, elem)
                            marked[elem] = true
                            push!(new_beams, elem)
                        end
                    end
                else
                    # Pass
                    elem = (r,c,dr,dc)
                    if !haskey(marked, elem)
                        marked[elem] = true
                        push!(new_beams, elem)
                    end
                end
            end
        end
        beams = new_beams
#        @show beams
#        display(energized)
        iter += 1
    end

    return energized
end

function find_best(lines, max_iter)
    rows = length(lines)
    cols = length(lines[1])

    max_energized = []
    curr_max = 0
    max_rc = ()
    for r in 1:rows
#        @info "Left row $r / $rows"
        initial = (r,0,0,1)
        energized = bounce(lines, max_iter, initial)
        curr_sum = sum(energized)
        if curr_sum > curr_max
            curr_max = curr_sum
            max_energized = copy(energized)
            max_rc = (r,0)
#            @show curr_max
        end
    end
    for r in 1:rows
#        @info "Right row $r / $rows"
        initial = (r,cols+1,0,-1)
        energized = bounce(lines, max_iter, initial)
        curr_sum = sum(energized)
        if curr_sum > curr_max
            curr_max = curr_sum
            max_energized = copy(energized)
            max_rc = (r,cols+1)
#            @show curr_max
        end
    end
    for c in 1:cols
#        @info "Top col $c / $cols"
        initial = (0,c,1,0)
        energized = bounce(lines, max_iter, initial)
        curr_sum = sum(energized)
        if curr_sum > curr_max
            curr_max = curr_sum
            max_energized = copy(energized)
            max_rc = (0,c)
#            @show curr_max
        end
    end
    for c in 1:cols
#        @info "Bottom col $c / $cols"
        initial = (rows+1,c,-1,0)
        energized = bounce(lines, max_iter, initial)
        curr_sum = sum(energized)
        if curr_sum > curr_max
            curr_max = curr_sum
            max_energized = copy(energized)
            max_rc = (rows+1,c)
 #           @show curr_max
        end
    end

    return curr_max, max_energized, max_rc
end


open("input.txt") do io
    lines = readlines(io)
#    lines = example_data()

#    for line in lines
#        println(line)
#    end

    energized = bounce(lines, 1000);
    res1 = sum(energized);

    @info "First:" res1

#    display(energized)

    res2, max_energized, max_rc = find_best(lines, 1100)    

#    display(max_energized)
    @info "Second:" res2

end


