#
# This is a solution to the Advent of Code 2023 problem for day 18 in Julia 1.9:
#
# https://adventofcode.com/2023/day/18
#
# It needs the corresponding input.txt stored into the same directory.

function example_data()
    return [
        "R 6 (#70c710)",
        "D 5 (#0dc571)",
        "L 2 (#5713f0)",
        "D 2 (#d2c081)",
        "R 2 (#59c680)",
        "D 2 (#411b91)",
        "L 5 (#8ceee2)",
        "U 2 (#caa173)",
        "L 1 (#1b58a2)",
        "U 2 (#caa171)",
        "R 2 (#7807d2)",
        "U 3 (#a77fa3)",
        "L 2 (#015232)",
        "U 2 (#7a21e3)"      
    ]
end

function parse_input(lines)
    dirs = []
    steps = []
    hexs = []
    colors = []

    for line in lines
#        println(line)
        strs = split(line, " ", keepempty=false)
        dir = strs[1]
        step = parse(Int, strs[2])
        m = match(r"\(#([0-9a-fA-F]+)\)", strs[3])
        hex = m.captures[1]
        color = parse(UInt32, hex, base=16)

#        @show dir step hex color

        push!(dirs, dir)
        push!(steps, step)
        push!(hexs, hex)
        push!(colors, color)
    end

    return dirs, steps, hexs, colors
end

function get_edge_plane(dirs, steps)
    r = 1
    c = 1
    rs = []
    cs = []
    ds = []
    for (dir, step) in zip(dirs, steps)
        dr = 0
        dc = 0
        if dir == "L"
            dr = 0
            dc = -1
        elseif dir == "R"
            dr = 0
            dc = 1
        elseif dir == "D"
            dr = 1
            dc = 0
        elseif dir == "U"
            dr = -1
            dc = 0
        else
            @assert false "Oops"
        end
        for i in 1:step
            r += dr
            c += dc
            push!(rs, r)
            push!(cs, c)
            push!(ds, dir[1])
        end
    end

    return rs, cs, ds
end

function get_plan_matrix(rs, cs, ds)
    r0 = minimum(rs)
    c0 = minimum(cs)

    rows = maximum(rs) - r0 + 1
    cols = maximum(cs) - c0 + 1

#    @show rows cols

    mat = Array{Char}(undef, rows, cols)
    mat .= '.'

    for i in 1:length(rs)
        r = rs[i] - r0 + 1
        c = cs[i] - c0 + 1
        d = ds[i]
        if i < length(rs)
            if ds[i+1] ∈ ['D', 'U'] && ds[i] ∈ ['R','L']
                d = ds[i+1]
            end
        end
        mat[r,c] = d
    end

    return mat
end

function fill_plan_matrix(mat)
    mat = copy(mat)

    for i in 1:size(mat,1)
        inside = false


        last_ud = '.'
        for j in 1:size(mat,2)
            if mat[i,j] ∈ ['U','D']
                if mat[i,j] != last_ud
                    inside = !inside
                    last_ud = mat[i,j]
                end
            end
            if inside && mat[i,j] == '.'
                mat[i,j] = '*'
            end
        end
    end

    return mat
end

function get_bool_matrix(mat)
    bmat = Array{Bool}(undef, size(mat,1), size(mat,2))

    for i in 1:size(mat,1)
        for j in 1:size(mat,2)
            if mat[i,j] == '.'
                bmat[i,j] = false
            else
                bmat[i,j] = true
            end
        end
    end

    return bmat
end


function get_line_list(dirs, steps)
    min_r = 1
    min_c = 1
    r = 1
    c = 1
    vlines = []
    for (dir, step) in zip(dirs, steps)
        r0 = r
        c0 = c

        dr = 0
        dc = 0
        if dir == "L"
            dr = 0
            dc = -1
        elseif dir == "R"
            dr = 0
            dc = 1
        elseif dir == "D"
            dr = 1
            dc = 0
        elseif dir == "U"
            dr = -1
            dc = 0
        else
            @assert false "Oops"
        end

        r += dr * step
        c += dc * step

        if dr != 0
            if r0 < r
                push!(vlines, (r0,c0,r,c,dir))
            else
                push!(vlines, (r,c,r0,c0,dir))
            end
        end

        if r < min_r
            min_r = r
        end
        if c < min_c
            min_c = c
        end
    end

    for i in 1:length(vlines)
        (r1, c1, r2, c2, d) = vlines[i]
        vlines[i] = (r1 - min_r + 1, c1 - min_c + 1, r2 - min_r + 1, c2 - min_c + 1, d)
    end

    return vlines
end

function fill_vlines(vlines)
    min_row = vlines[1][1]
    max_row = vlines[1][1]

    for (r1,c1,r2,c2,d) in vlines
        if r1 < min_row
            min_row = r1
        end
        if r2 > max_row
            max_row = r2
        end
    end

    partial_sums = []
    total_sum = 0
    for r in min_row:max_row
        curr_vlines = filter(vlines) do (r1,c1,r2,c2,d)
            r1 ≤ r ≤ r2
        end

        if length(curr_vlines) > 0
            sort!(curr_vlines, by=(vl -> vl[2]))
#            if r == 8
#                @info "Row " r
#                display(curr_vlines)
#            end

            start_c = 0
            col_sum = 0

            i = 1
            inside = false
            while i <= length(curr_vlines)
                (r1,c1,r2,c2,d) = curr_vlines[i]

                extremum = false
                saddle = false
                if i < length(curr_vlines)
                    (next_r1,next_c1,next_r2,next_c2,next_d) = curr_vlines[i+1]
                    if d == next_d
                        if r2 == next_r1 || r1 == next_r2
#                            @info "Saddle on row" r
                            saddle = true
                        else
                            @assert false "Opsidoo"
                        end
                    elseif r == r1 == next_r1 || r == r2 == next_r2
#                        @info "Extremum on row" r
                        extremum = true
                    end
                end

                if !inside
                    start_c = c1
                    if saddle
                        i += 1
                        inside = true
                    elseif extremum
                        i += 1
                        col_sum += next_c1 - start_c + 1
                    else
                        inside = true
                    end
                else
                    if saddle
                        col_sum += next_c1 - start_c + 1
                        i += 1
                        inside = false
                    elseif extremum
                        i += 1
                    else
                        col_sum += c1 - start_c + 1
                        inside = false
                    end
                end

                i += 1
            end

            push!(partial_sums, col_sum)
#            display(col_sum)

            total_sum += col_sum
        end
    end

    return total_sum, partial_sums
end

function parse_input_2(lines)
    dirs = []
    steps = []

    for line in lines
#        println(line)
        strs = split(line, " ", keepempty=false)
        m = match(r"\(#([0-9a-fA-F]+)\)", strs[3])
        hex = m.captures[1]
        step = parse(Int, hex[1:end-1], base=16)
        dir = ["R","D","L","U"][parse(Int, hex[end:end])+1]

#        @show dir step

        push!(dirs, dir)
        push!(steps, step)
    end

    return dirs, steps
end


open("input.txt") do io
    lines = readlines(io)
#    lines = example_data()

    dirs, steps, hexs, colors = parse_input(lines)
    rs, cs, ds = get_edge_plane(dirs, steps)
    mat = get_plan_matrix(rs, cs, ds)
#    display(join(mat[8,:]))
    mat_filled = fill_plan_matrix(mat)
#    display(mat_filled)
    mat_bool = get_bool_matrix(mat_filled)

    result_1 = sum(mat_bool)
    @show result_1


#    dirs, steps, hexs, colors = parse_input(lines)
#    vlines = get_line_list(dirs, steps)
#    total_sum, partial_sums = fill_vlines(vlines)

#    partial_sums_bf = sum(mat_bool, dims=2)

#    for i in 1:length(partial_sums)
#        if partial_sums[i] != partial_sums_bf[i]
#            println("$i : $(partial_sums[i]) $(partial_sums_bf[i]) ")
#        end
#    end

    dirs, steps = parse_input_2(lines)
    vlines = get_line_list(dirs, steps)
    total_sum, partial_sums = fill_vlines(vlines)
    result_2 = total_sum
    @show result_2

end