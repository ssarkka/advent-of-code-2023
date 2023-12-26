#
# This is a solution to the Advent of Code 2023 problem for day 24 in Julia 1.9:
#
# https://adventofcode.com/2023/day/24
#
# It needs the corresponding input.txt stored into the same directory.

using LinearAlgebra

function example_data()
    return [
        "19, 13, 30 @ -2,  1, -2", 
        "18, 19, 22 @ -1, -1, -2", 
        "20, 25, 34 @ -2, -2, -4", 
        "12, 31, 28 @ -1, -2, -1", 
        "20, 19, 15 @  1, -5, -3"
    ]
end

function parse_input(lines, T=BigFloat)
    pos = Array{T}(undef, 3, length(lines))
    vel = Array{T}(undef, 3, length(lines))

    for i in 1:length(lines)
        pv_str = split(lines[i], " @ ")
        p = map(s -> parse(T, s), split(pv_str[1],", "))
        v = map(s -> parse(T, s), split(pv_str[2],", "))

        pos[:, i] = p
        vel[:, i] = v
#        @show p v
    end

    return pos, vel
end

function intersects_in(pos, vel, x0, x1, y0, y1)
    # px1 + vx1 s = px2 + vx2 t
    # py1 + vy1 s = py2 + vy2 t
    # 
    # vx1 s - vx2 t = px2 - px1
    # vy1 s - vy2 t = py2 - py1

    count = 0

    for i in 1:size(pos,2)-1
        for j in i+1:size(pos,2)
            A = [vel[1, i] (-vel[1, j]); vel[2, i] (-vel[2, j])]
            b = [pos[1, j] - pos[1, i]; pos[2, j] - pos[2, i]]

            if abs(det(A)) > 1e-14
                st = A \ b
                if st[1] >= 0 && st[2] >= 0
                    xi = pos[1, i] + st[1] * vel[1, i]
                    yi = pos[2, i] + st[1] * vel[2, i]

                    if x0 ≤ xi ≤ x1 && y0 ≤ yi ≤ y1
                        count += 1
                    end
                end
            end
        end
    end

    return count
end

function ortho_vectors(v)
    v = [-2, 1, -2]
    i = argmax(abs.(v))
    E = zeros(typeof(v[1]), 3, 2)
    E[i % 3 + 1, 1] = 1
    E[(i + 1) % 3 + 1, 2] = 1

    v1 = cross(v, E[:,1])
    v2 = cross(v, E[:,2])

    return v1, v2
end

function plane_eqs(pos, vel)
    as = []
    bs = []
    cs = []
    ds = []

    for i in 1:size(pos,2)
        a, c = ortho_vectors(vel[:, i])
        b = -dot(a, pos[:, i])
        d = -dot(c, pos[:, i])
        push!(as, a)
        push!(bs, b)
        push!(cs, c)
        push!(ds, d)
    end

    return as, bs, cs, ds
end

open("input.txt") do io
    lines = readlines(io)
#    lines = example_data()

#    @info "BigFloat precision:" precision(BigFloat)

    pos, vel = parse_input(lines)

    x0 = BigFloat(200000000000000)
    x1 = BigFloat(400000000000000)
#    x0 = BigFloat(7)
#    x1 = BigFloat(27)
    y0 = x0
    y1 = x1
    count1 = intersects_in(pos, vel, x0, x1, y0, y1)
    @info "XY intersections:" count1

    T = BigFloat
    pos, vel = parse_input(lines, T)
 
    as, bs, cs, ds = plane_eqs(pos, vel)

    i = 1
    j = 2
    k = 4

    dp = vcat(pos[:, j] - pos[:, i], pos[:, k] - pos[:, i])
    x = ones(T, 6)
    x[4] = 1.0
    x[5] = 2.0
    x[6] = 3.0

    f(x) = vcat(pos[:, j] - pos[:, i] + x[5] .* vel[:, j] - x[5] .* x[1:3] - x[4] .* vel[:, i] + x[4] .* x[1:3],
                pos[:, k] - pos[:, i] + x[6] .* vel[:, k] - x[6] .* x[1:3] - x[4] .* vel[:, i] + x[4] .* x[1:3])

    ∂f(x) = hcat(vcat((x[4] - x[5]) .* I(3), (x[4] - x[6]) .* I(3)), vcat(-vel[:,i] + x[1:3], -vel[:,i] + x[1:3]), vcat(vel[:,j] - x[1:3], zeros(T,3)), vcat(zeros(T,3), vel[:,k] - x[1:3])) 

    for iter = 1:1000
        x = x - ∂f(x) \ f(x)
#        display(x)
    end
    
    pr = pos[:, i] + x[4] .* vel[:, i] - x[4] .* x[1:3]
 #   display(pr)
#    display(round.(Int64, pr))

    result_2 = sum(round.(Int64, pr))
    @show result_2

end

