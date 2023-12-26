#
# This is a solution to the Advent of Code 2023 problem for day 5 in Julia 1.9:
#
# https://adventofcode.com/2023/day/5
#
# It needs the corresponding input.txt stored into the same directory.

function example_data()
    return [
        "seeds: 79 14 55 13", 
        "", 
        "seed-to-soil map:", 
        "50 98 2", 
        "52 50 48", 
        "", 
        "soil-to-fertilizer map:", 
        "0 15 37", 
        "37 52 2", 
        "39 0 15", 
        "", 
        "fertilizer-to-water map:", 
        "49 53 8", 
        "0 11 42", 
        "42 0 7", 
        "57 7 4", 
        "", 
        "water-to-light map:", 
        "88 18 7", 
        "18 25 70", 
        "", 
        "light-to-temperature map:", 
        "45 77 23", 
        "81 45 19", 
        "68 64 13", 
        "", 
        "temperature-to-humidity map:", 
        "0 69 1", 
        "1 0 69", 
        "", 
        "humidity-to-location map:", 
        "60 56 37", 
        "56 93 4"
    ]
end

function get_seeds(line)
    tmp = split(line, " ")
    return tmp[2:end]
end


function map_seed(lines, seed)
    id = seed
    got_it = false

    for line in lines
        if !isempty(line)
            if isnumeric(line[1])
                if !got_it
                    nums = split(line, " ")
                    a = parse(Int, nums[1])
                    b = parse(Int, nums[2])
                    c = parse(Int, nums[3])
#                    @show nums

                    if (b <= id) && (id <= b+c-1)
                        got_it = true
                        id = id - b + a
#                        @show id
                    end
                end
            else
                maptitle = split(line, " ")
#                @show maptitle
            end
        else
            got_it = false
        end        
    end

    return id
end

function lowest_location(seeds, lines)
    ids = Array{Int}(undef, 0)
    for seed in seeds
        id = map_seed(lines, parse(Int, seed))
#        @show id

        push!(ids, id)
    end

    return minimum(ids)
end

function range_map_range(range, map_range, map_delta)
    rem_ranges = []
    new_range = ()

    if range[2] < map_range[1] || range[1] > map_range[2]
        # rrrr mmm || mmm rrr
        rem_ranges = [range]
    elseif range[1] >= map_range[1] && range[2] <= map_range[2]
        # mrm 
        new_range = (range[1] + map_delta, range[2] + map_delta)
    elseif range[1] < map_range[1] && range[2] > map_range[2]
        # rmr
        new_range = (map_range[1] + map_delta, map_range[2] + map_delta)
        range1 = (range[1], map_range[1]-1)
        range2 = (map_range[2]+1, range[2])
        push!(rem_ranges, range1)
        push!(rem_ranges, range2)
    elseif range[1] < map_range[1] && range[2] <= map_range[2]
        # rm
        new_range = (map_range[1] + map_delta, range[2] + map_delta)
        range1 = (range[1], map_range[1]-1)
        push!(rem_ranges, range1)
    elseif range[1] >= map_range[1] && range[2] > map_range[2]
        # mr
        new_range = (range[1] + map_delta, map_range[2] + map_delta)
        range2 = (map_range[2]+1, range[2])
        push!(rem_ranges, range2)
    else
        @assert false "Oops"
    end

    return rem_ranges, new_range
end

function ranges_map_ranges(ranges, map_ranges, map_deltas)
#    println("-- BEGIN ranges_map_ranges -- ")
#    @show map_ranges
#    @show map_deltas
#    @show ranges

    new_ranges = []
    rem_ranges = ranges

    for (map_range, map_delta) in zip(map_ranges, map_deltas)
        new_rem_ranges = []
        for range in rem_ranges
            new_rem_ranges_to_add, new_range = range_map_range(range, map_range, map_delta)
#            @show new_rem_ranges_to_add
#            @show new_range
            if !isempty(new_range)
                push!(new_ranges, new_range)
            end
            append!(new_rem_ranges, new_rem_ranges_to_add)
        end
        rem_ranges = new_rem_ranges
    end

    append!(new_ranges, rem_ranges)

#    @show new_ranges

#    println("-- END ranges_map_ranges -- ") 

    return new_ranges
end

function range_border_seeds(lines)
    seeds = map(s -> parse(Int, s), get_seeds(lines[1]))
    ranges = zip(seeds[1:2:end], seeds[1:2:end] + seeds[2:2:end] .- 1)

#    for range in ranges
#        @show range
#    end

    map_ranges = []
    map_deltas = []

    for line in lines[3:end]
        if !isempty(line)
            if isnumeric(line[1])
                nums = split(line, " ")
                a = parse(Int, nums[1])
                b = parse(Int, nums[2])
                c = parse(Int, nums[3])

                map_range = (b,b+c-1)
                map_delta = a - b

                push!(map_ranges, map_range)
                push!(map_deltas, map_delta)

            else
#                @show map_ranges
#                @show map_deltas
                ranges = ranges_map_ranges(ranges, map_ranges, map_deltas)
#                @show ranges

                maptitle = split(line, " ")
#                @show maptitle

                map_ranges = []
                map_deltas = []
            end
        else
            # map changing
        end        
    end

    return ranges
end

open("input.txt", "r") do io
    lines = readlines(io);
#    lines = example_data();

    seeds = get_seeds(lines[1])
#    @show seeds

    lowest_id_1 = lowest_location(seeds, lines[3:end])
    @show lowest_id_1

    ranges = Any[(81, 94), (57, 69)]
    map_ranges = Any[(53, 60), (11, 52), (0, 6), (7, 10)]
    map_deltas = Any[-4, -11, 42, 50]

    new_ranges = ranges_map_ranges(ranges, map_ranges, map_deltas)
#    @show new_ranges

    ranges = range_border_seeds(lines)
#    @show ranges

    lowest_id_2 = minimum([i for (i,j) in ranges])
    @show lowest_id_2
end

