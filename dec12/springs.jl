#
# This is a solution to the Advent of Code 2023 problem for day 12 in Julia 1.9:
#
# https://adventofcode.com/2023/day/12
#
# It needs the corresponding input.txt stored into the same directory.

using Printf

function parse_input(lines)
    strs = []
    counts = []

    for line in lines
        tmp = split(line, " ", keepempty=false)
        push!(strs, tmp[1])
        tmp = map(s -> parse(Int, s), split(tmp[2], ","))
        push!(counts, tmp)
    end

    return strs, counts
end

function check_match(str, count)
    tmp = split(str, ".", keepempty=false)
    tmp = map(length, tmp)

    return length(tmp) == length(count) && all(tmp .== count)
end

function match_one(str, count, final="")
    c = 0

    if length(str) == 0
        if check_match(final, count)
            c += 1
        end
    else
        if str[1] == '?'
            c += match_one(str[2:end], count, final * '.')
            c += match_one(str[2:end], count, final * '#')
        else
            c += match_one(str[2:end], count, final * str[1])
        end
    end

    return c
end

function match_one_mem(str, count, final="", mem_dict=Dict())
    c = 0

    curr_key = str * final

    if haskey(mem_dict, curr_key)
        return mem_dict[curr_key]
    end

    if length(str) == 0
        if check_match(final, count)
            c += 1
        end
    else
        if str[1] == '?'
            c += match_one_mem(str[2:end], count, final * '.', mem_dict)
            c += match_one_mem(str[2:end], count, final * '#', mem_dict)
        else
            c += match_one_mem(str[2:end], count, final * str[1], mem_dict)
        end
    end

    mem_dict[curr_key] = c

    return c
end


function unfold(strs, counts)
    new_strs = []
    new_counts = []
    for i in eachindex(strs)
        new_str = ""
        for j in 1:5
            if j == 1
                new_str = strs[i]
            else
                new_str = new_str * '?' * strs[i]
            end
        end
        push!(new_strs, new_str)
        push!(new_counts, repeat(counts[i], 5))
    end
    return new_strs, new_counts
end

function match_one_2(str, count, final="")
    len = length(str)

    s = split(final, ".", keepempty=false)
    if !isempty(s)
        len_list = map(length, s)
        if length(len_list) > length(count)
            return 0
        end
        if length(len_list) > 1 && !all(len_list[1:end-1] .== count[1:length(len_list)-1])
            return 0
        end
        if len_list[end] > count[length(len_list)]
            return 0
        end
        if length(len_list) < length(count)
            if length(str) < sum(count[length(len_list)+1:end])
                return 0
            end
        end
    end

    c = 0
    if length(str) == 0
        if check_match(final, count)
            c += 1
        end
    else
        if str[1] == '?'
            c += match_one_2(str[2:end], count, final * '.')
            c += match_one_2(str[2:end], count, final * '#')
        else
            c += match_one_2(str[2:end], count, final * str[1])
        end
    end

    return c
end

function make_pattern(count)
    patt = ""

    for j in 1:length(count)
        patt *= '*' * repeat("#", count[j])
        if j < length(count)
            patt *= '.'
        end
    end
    patt *= '*'

    return patt
end


function match_patt(patt, str)
    s = Array{Int}(undef, length(patt)+1, length(str)+1)

    a = patt
    b = str

    s[1,1] = 1
    for j in 2:size(s,2)
        s[1,j] = 0
    end

    for i in 1:length(a)
        if a[i] == '*'
            s[i+1,1] = s[i,1]
        else
            s[i+1,1] = 0
        end

        for j in 1:length(b)
            if a[i] == '.' && b[j] == '.'
                s[i+1,j+1] = s[i,j]
            elseif a[i] == '.' && b[j] == '?'
                s[i+1,j+1] = s[i,j]
            elseif a[i] == '.' && b[j] == '#'
                s[i+1,j+1] = 0
            elseif a[i] == '#' && b[j] == '.'
                s[i+1,j+1] = 0
            elseif a[i] == '#' && b[j] == '?'
                s[i+1,j+1] = s[i,j]
            elseif a[i] == '#' && b[j] == '#'
                s[i+1,j+1] = s[i,j]
            elseif a[i] == '*' && b[j] == '.'
#                s[i+1,j+1] = s[i,j] + s[i+1,j] + s[i,j+1]
                if s[i+1,j] > 0
                    s[i+1,j+1] = s[i+1,j] + s[i,j+1]
                else
                    s[i+1,j+1] = s[i,j] + s[i,j+1]
                end
             elseif a[i] == '*' && b[j] == '?'
#                s[i+1,j+1] = s[i,j] + s[i+1,j] + s[i,j+1]
                if s[i+1,j] > 0
                    s[i+1,j+1] = s[i+1,j] + s[i,j+1]
                else
                    s[i+1,j+1] = s[i,j] + s[i,j+1]
                end
            elseif a[i] == '*' && b[j] == '#'
                s[i+1,j+1] = s[i,j+1]
            end
        end
    end

    return s
end

function show_s(s, patt, str)
    for i in 1:size(s,1)
        if i == 1
            for j in 1:size(s,2)
                if j == 1
                    @printf "   o  "
                else
                    @printf "%c  " str[j-1]
                end
            end
            @printf "\n"
        end
        if i == 1
            @printf "o "
        else
            @printf "%c " patt[i-1]
        end
        for j in 1:size(s,2)
            @printf "%2d " s[i,j]
        end
        @printf "\n"
    end
end


open("input.txt") do io
    lines = readlines(io)
#    lines = ["???.### 1,1,3", ".??..??...?##. 1,1,3", "?#?#?#?#?#?#?#? 1,3,1,6", "????.#...#... 4,1,1", "????.######..#####. 1,6,5", "?###???????? 3,2,1"]

#    display(lines)

    strs, counts = parse_input(lines)

    c = 0
    for i in eachindex(strs)
        match_c = match_one_mem(strs[i], counts[i])
#        @show match_c
        c += match_c
    end
    @info "For the first part:" c

#    i = 5
#    patt = make_pattern(counts[i]);
#    str = strs[i]

#    @show patt
#    @show str

#    s = match_patt(patt, str);
#    show_s(s, patt, str)

    strs, counts = unfold(strs, counts)

#    display(strs)
#    display(counts)

    c = 0
    for i in eachindex(strs)
        patt = make_pattern(counts[i]);
        s = match_patt(patt, strs[i]);
        match_c = s[end,end]
#        @show match_c
        c += match_c
    end
    @info "For the second part:" c

end
