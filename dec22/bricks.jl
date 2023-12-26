#
# This is a solution to the Advent of Code 2023 problem for day 22 in Julia 1.9:
#
# https://adventofcode.com/2023/day/22
#
# It needs the corresponding input.txt stored into the same directory.

function example_data()
    return [
        "1,0,1~1,2,1", 
        "0,0,2~2,0,2", 
        "0,2,3~2,2,3", 
        "0,0,4~0,2,4", 
        "2,0,5~2,2,5", 
        "0,1,6~2,1,6", 
        "1,1,8~1,1,9"
    ]
end


function parse_input(lines)
    brick_xyz1s = Array{Int}(undef, length(lines), 3)
    brick_xyz2s = Array{Int}(undef, length(lines), 3)

    for i in 1:length(lines)
        line = lines[i]
        strs = split(line, "~")
        brick_xyz1s[i, :] = map(s -> parse(Int, s), split(strs[1], ","))
        brick_xyz2s[i, :] = map(s -> parse(Int, s), split(strs[2], ","))
    end

    return brick_xyz1s, brick_xyz2s
end



function occupied(xyz, brick_xyz1s, brick_xyz2s)
    if xyz[end] < 1
        return true
    end

    for i in 1:size(brick_xyz1s,1)
        all_in = true
        for j in 1:size(brick_xyz1s,2)
            if xyz[j] ∉ brick_xyz1s[i, j]:brick_xyz2s[i, j]
                all_in = false
            end
        end
        if all_in
            return true
        end
    end
    return false
end


function drop_brick!(brick_xyz1s, brick_xyz2s, dont_update=false)
    for i in 1:size(brick_xyz1s,1)
        all_free = true
        for x in brick_xyz1s[i, 1]:brick_xyz2s[i, 1]
            for y in brick_xyz1s[i, 2]:brick_xyz2s[i, 2]
                z = brick_xyz1s[i, 3] - 1
                if occupied([x,y,z], brick_xyz1s, brick_xyz2s)
                    all_free = false
                end
            end
        end
        if all_free
            if !dont_update
                brick_xyz1s[i, 3] -= 1
                brick_xyz2s[i, 3] -= 1
            end
            return i
        end
    end

    return 0
end

function can_remove_brick(brick_i, brick_xyz1s, brick_xyz2s)
    ind = [1:brick_i-1; brick_i+1:size(brick_xyz1s, 1)]
    return drop_brick!(brick_xyz1s[ind, :], brick_xyz2s[ind, :], true) == 0
end

function which_fall(brick_i, brick_xyz1s, brick_xyz2s)
    ind = [1:brick_i-1; brick_i+1:size(brick_xyz1s, 1)]

    new_brick_xyz1s = copy(brick_xyz1s[ind, :])
    new_brick_xyz2s = copy(brick_xyz2s[ind, :])

    brick_list = []
    i = 1
    while i > 0
        i = drop_brick!(new_brick_xyz1s, new_brick_xyz2s)
        if i > 0
            append!(brick_list, i)
        end
    end

    return unique(brick_list)
end
    

open("input.txt") do io
    lines = readlines(io)
#    lines = example_data()

    brick_xyz1s, brick_xyz2s = parse_input(lines)

    dropped = 1
    while dropped > 0
        dropped = drop_brick!(brick_xyz1s, brick_xyz2s)
#        @show dropped
    end

    # Part 1
    count1 = 0
    for i in 1:size(brick_xyz1s, 1)
        res = can_remove_brick(i, brick_xyz1s, brick_xyz2s)
#        println("$i $res")

        if res
            count1 += 1
        end
    end

    @show count1

    # Part 2
    count2 = 0
    for i in 1:size(brick_xyz1s, 1)
        list = which_fall(i, brick_xyz1s, brick_xyz2s)
        count2 += length(list)
    end

    @show count2

end
