#
# This is a solution to the Advent of Code 2023 problem for day 13 in Julia 1.9:
#
# https://adventofcode.com/2023/day/13
#
# It needs the corresponding input.txt stored into the same directory.

function example_lines()
    return [
        "#.##..##.", 
        "..#.##.#.", 
        "##......#", 
        "##......#", 
        "..#.##.#.", 
        "..##..##.", 
        "#.#.##.#.", 
        "", 
        "#...##..#", 
        "#....#..#", 
        "..##..###", 
        "#####.##.", 
        "#####.##.", 
        "..##..###", 
        "#....#..#"]
end

function split_to_patterns(lines)
    patterns = []
    pattern = []

    for line in lines
        if length(line) == 0
            push!(patterns, pattern)
            pattern = []
        else
            push!(pattern, line)
        end
    end
    if !isempty(pattern)
        push!(patterns, pattern)
    end
    return patterns
end


function transpose_lines(lines)
    new_lines = []

    for j in 1:lastindex(lines[1])
        new_line = ""
        for i in 1:lastindex(lines)
            new_line *= lines[i][j]
        end
        push!(new_lines, new_line)
    end

    return new_lines
end

function get_pair_matrix(pattern)
    s = Array{Bool}(undef, length(pattern), length(pattern))
    for i in 1:length(pattern)-1
        s[i,i] = true
        for j in i+1:length(pattern)
            if pattern[i] == pattern[j]
                s[i,j] = true
                s[j,i] = true
            else
                s[i,j] = false
                s[j,i] = false
            end
        end
    end

    return s
end

function find_hreflection(pattern, old_r=0)
    s = get_pair_matrix(pattern)
    for r in 1:size(s,1)-1
        all_reflect = true
        for n in 0:size(s,1)
            if r-n >= 1 && r+1+n <= size(s,1)
                if !s[r-n,r+1+n]
                    all_reflect = false
                    break
                end
            end
        end
        if all_reflect && r != old_r
            return r
        end
    end

    return 0
end

function all_reflections(patterns)
    total = 0
    for i in 1:length(patterns)
        hpattern = patterns[i]
        hr = find_hreflection(hpattern)
#        @show hr

        vpattern = transpose_lines(hpattern)
        vr = find_hreflection(vpattern)
#        @show vr

        @assert vr != 0 || hr != 0 "Both vr and hr are zero at pattern $i"

        if vr != 0
            total += vr
        else
            total += 100 * hr
        end
    end
    return total
end

function find_smudge_hreflection(pattern)
    r = find_hreflection(pattern)
    @assert r != 0

    new_pattern = Array{String}(undef, length(pattern))
    for i in 1:length(pattern)
        new_pattern[i] = pattern[i]
    end

    for i in 1:length(pattern)        
        for j in 1:length(pattern[i])
            old_str = pattern[i]
            new_str = ""

            for k in 1:length(old_str)
                if k != j
                    new_str *= old_str[k]
                else
                    if old_str[k] == '#'
                        new_str *= '.'
                    else
                        new_str *= '#'
                    end
                end
            end

            new_pattern[i] = new_str

            new_hr = find_hreflection(new_pattern, r)
            new_vr = find_hreflection(transpose_lines(new_pattern))
            new_pattern[i] = old_str

            if new_hr != 0 || new_vr != 0
                return (new_hr, new_vr)
            end
        end
    end

    return (0,0)
end


function all_smudge_reflections(patterns)
    total = 0
    for i in 1:length(patterns)
        hpattern = patterns[i]
        hr = find_hreflection(hpattern)
#        @show hr

        vpattern = transpose_lines(hpattern)
        vr = find_hreflection(vpattern)
#        @show vr

        @assert vr != 0 || hr != 0 "Both vr and hr are zero at pattern $i"

        new_vr = 0
        new_hr = 0

        if vr != 0
            (new_vr, new_hr) = find_smudge_hreflection(vpattern)
#            display(vpattern)
        else
            (new_hr, new_vr) = find_smudge_hreflection(hpattern)
 #           display(hpattern)
        end

#        @show new_vr
#        @show new_hr

        @assert !(new_vr == 0 && new_hr == 0) "Both new_vr and new_hr are zero at pattern $i"

        if new_vr != 0
            total += new_vr
        end
        if new_hr != 0
            total += 100 * new_hr
        end
end
    return total
end


open("input.txt") do io
    lines = readlines(io)
#    lines = example_lines()

    patterns = split_to_patterns(lines)
    total_1 = all_reflections(patterns)
    @show total_1

    total_2 = all_smudge_reflections(patterns)
    @show total_2

end
