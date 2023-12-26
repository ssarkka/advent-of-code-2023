#
# This is a solution to the Advent of Code 2023 problem for day 15 in Julia 1.9:
#
# https://adventofcode.com/2023/day/15
#
# It needs the corresponding input.txt stored into the same directory.

function example_data()
    return [
        "rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7"
    ]
end

function hash(str)
    h = 0

    for ch in str
        h += Int(ch)
        h *= 17
        h %= 256
    end
    return h
end

function apply_op(boxes, op)
    if op[end] == '-'
        m = match(r"(\S+)-", op)
        lbl = m.captures[1]
        foc = 0
        cmd = '-'
    else
        m = match(r"(\S+)=(\d+)", op)
        lbl = m.captures[1]
        foc = m.captures[2]
        cmd = '='
    end

#    @info op lbl cmd foc hash(lbl)

    box = hash(lbl)+1

    if cmd == '-'
        if haskey(boxes, box)
            filter!(e -> e[1] != lbl, boxes[box])
        end
    else
        if haskey(boxes, box)
            i = findfirst(e -> e[1] == lbl, boxes[box])
            if !isnothing(i)
                boxes[box][i] = (lbl, foc)
            else
                push!(boxes[box], (lbl, foc))
            end
        else
            boxes[box] = [(lbl, foc)]
        end
    end

end

function get_focusing_power(line)
    commands = split(line, ",")

    boxes = Dict()
    for op in commands
        apply_op(boxes, op)
#        @show boxes
    end

    total = 0
    for box in keys(boxes)
        if !isempty(boxes[box])
            for i in 1:length(boxes[box])
                (lbl, foc) = boxes[box][i]
                foc_power = box * i * parse(Int, foc)
#                @show lbl foc_power
                total += foc_power
            end
        end
    end

    return total
end

open("input.txt") do io
    lines = readlines(io)
#    lines = example_data()
    line = lines[1]

    res1 = sum(hash.(split(line, ",")))
    @show res1

    res2 = get_focusing_power(line)
    @show res2
end


