#
# This is a solution to the Advent of Code 2023 problem for day 9 in Julia 1.9:
#
# https://adventofcode.com/2023/day/9
#
# It needs the corresponding input.txt stored into the same directory.

function parse_matrix(lines)
    mat = []
    
    for line in lines
        row = map(s -> parse(Int, s), split(line, " ", keepempty=false))

        cols = length(row)
        if isempty(mat)
            mat = Array{Int}(undef, 0, cols)
        end
        mat = [mat; row']
    end

    return mat
end


function extrapolate(mat)
    summed = 0

    for j in 1:size(mat,1)
        vec_list = []
        vec = mat[j,:]
        push!(vec_list, vec)
        while !all(vec .== 0)
            vec = diff(vec)
            push!(vec_list, vec)
        end

        # vec carries over
        push!(vec, 0)
        for i in length(vec_list)-1:-1:1
            prev_vec = vec
            vec = vec_list[i]
            push!(vec, prev_vec[end] + vec[end])
        end

        res = vec[end]
#        @show res

        summed += res
    end

    return summed
end


function extrapolate_2(mat)
    summed = 0

    for j in 1:size(mat,1)
        vec_list = []
        vec = mat[j,:]
        push!(vec_list, vec)
        while !all(vec .== 0)
            vec = diff(vec)
            push!(vec_list, vec)
        end

#        @show vec_list

        # vec carries over
        pushfirst!(vec, 0)
        for i in length(vec_list)-1:-1:1
            prev_vec = vec
            vec = vec_list[i]
            pushfirst!(vec, vec[1] - prev_vec[1])
        end

#        @show vec_list

        res = vec[1]
#        @show res

        summed += res
    end

    return summed
end


open("input.txt") do io
    lines = readlines(io);
#    lines = ["0 3 6 9 12 15", "1 3 6 10 15 21", "10 13 16 21 30 45"]
#    lines = ["10  13  16  21  30  45"]

    mat = parse_matrix(lines)
    
    summed_1 = extrapolate(mat)
    @show summed_1

    summed_2 = extrapolate_2(mat)
    @show summed_2
end
