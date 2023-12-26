#
# This is a solution to the Advent of Code 2023 problem for day 6 in Julia 1.9:
#
# https://adventofcode.com/2023/day/6
#
# It needs the corresponding input.txt stored into the same directory.

function get_time_dist(lines)
    times = map(s -> parse(Int, s), split(lines[1], " ", keepempty=false)[2:end])
    distances = map(s -> parse(Int, s), split(lines[2], " ", keepempty=false)[2:end])
    return times, distances
end

function get_time_dist_2(lines)
    times = [parse(Int, prod(split(lines[1], " ", keepempty=false)[2:end]))]
    distances = [parse(Int, prod(split(lines[2], " ", keepempty=false)[2:end]))]
    return times, distances
end

open("input.txt", "r") do io
    lines = readlines(io);
#    lines = ["Time:      7  15   30", "Distance:  9  40  200"];

#    times, distances = get_time_dist(lines)  # First part
    times, distances = get_time_dist_2(lines)  # Second part
    @show times distances;

    disc = 1.0 * times.^2 - 4.0 * distances;
    @show disc

    b1 = 0.5 * times - 0.5 * .√disc;
    b2 = 0.5 * times + 0.5 * .√disc;

    b1i = ceil.(Int, b1 .+ 1e-12)
    b2i = floor.(Int, b2 .- 1e-12)
    n = b2i - b1i .+ 1

    @show b1 b2
    @show b1i b2i
    @show n
    @show prod(n)
end


