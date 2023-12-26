#
# This is a solution to the Advent of Code 2023 problem for day 19 in Julia 1.9:
#
# https://adventofcode.com/2023/day/19
#
# It needs the corresponding input.txt stored into the same directory.

function example_data()
    return [
        "px{a<2006:qkq,m>2090:A,rfg}", 
        "pv{a>1716:R,A}", 
        "lnx{m>1548:A,A}", 
        "rfg{s<537:gd,x>2440:R,A}", 
        "qs{s>3448:A,lnx}", 
        "qkq{x<1416:A,crn}", 
        "crn{x>2662:A,R}", 
        "in{s<1351:px,qqz}", 
        "qqz{s>2770:qs,m<1801:hdj,R}", 
        "gd{a>3333:R,R}", 
        "hdj{m>838:A,pv}", 
        "", 
        "{x=787,m=2655,a=1222,s=2876}", 
        "{x=1679,m=44,a=2067,s=496}", 
        "{x=2036,m=264,a=79,s=2244}", 
        "{x=2461,m=1339,a=466,s=291}", 
        "{x=2127,m=1623,a=2188,s=1013}"
    ]
end

function parse_input(lines)
    rule_dict = Dict()

    i = 1
    while length(lines[i]) > 0
        line = lines[i]
        j = 1

        name = ""
        while line[j] != '{'
            name *= line[j]
            j += 1
        end
        rules = split(line[j+1:end-1], ",")

        rule_dict[name] = rules
        i += 1
    end

    var_dicts = []

    i += 1
    while i <= length(lines)
        line = lines[i]

        var_dict = Dict()
        strs = split(line[2:end-1], ",")

        for str in strs
            m = match(r"([a-z])=(\d+)", str)
            var = m.captures[1]
            val = parse(Int, m.captures[2])
            var_dict[var] = val
        end
        push!(var_dicts, var_dict)

        i += 1
    end

    return rule_dict, var_dicts
end

function run_workflow(rule_dict, var_dict, workflow="in")
    rules = rule_dict[workflow]
    index = 1

    while true
        if occursin(r"[a-z][<>]\d+", rules[index])
            m = match(r"([a-z])([<>])(\d+):([a-zA-Z]+)$", rules[index])
            var = m.captures[1]
            op  = m.captures[2]
            val = parse(Int, m.captures[3])
            name = m.captures[4]

            if (op == "<" && var_dict[var] < val) || (op == ">" && var_dict[var] > val)
                if name != "A" && name != "R"
#                    println("Moving to $name by rule $(rules[index])")
                    workflow = name
                    rules = rule_dict[workflow]
                    index = 1
                else
                    return name
                end
            else
                index += 1
            end
        elseif rules[index] == "A" || rules[index] == "R"
            return rules[index]
        else
            name = rules[index]
#            println("Moving to $name by default rule")
            workflow = name
            rules = rule_dict[workflow]
            index = 1
        end
    end
end

function get_var_cuts(rule_dict)
    var_cut_dict = Dict()

    for key in keys(rule_dict)
        rules = rule_dict[key]
   
        for rule in rules
            if occursin(r"[a-z][<>]\d+", rule)
                m = match(r"([a-z])([<>])(\d+):([a-zA-Z]+)$", rule)
                var = m.captures[1]
                op  = m.captures[2]
                val = parse(Int, m.captures[3])
                name = m.captures[4]

                if op == ">"
                    val += 1
                end

                if haskey(var_cut_dict, var)
                    elem = var_cut_dict[var]
                    push!(elem, val)
                    sort!(elem)
                    var_cut_dict[var] = elem
                else
                    var_cut_dict[var] = [val]
                end
            end
        end        
    end

    return var_cut_dict
end


open("input.txt") do io
    lines = readlines(io)
#    lines = example_data()

    rule_dict, var_dicts = parse_input(lines)

    total = 0
    for var_dict in var_dicts
        if run_workflow(rule_dict, var_dict) == "A"
            total += sum(values(var_dict))
        end
    end
    @info "For first part:" total

    var_cut_dict = get_var_cuts(rule_dict)
    for var in keys(var_cut_dict)
        elem = var_cut_dict[var]
        push!(elem, 1)
        sort!(elem)
        var_cut_dict[var] = elem
    end
#    display(var_cut_dict)

    var_max = 4000

    var_names = collect(keys(var_cut_dict))
    var_indices = collect(1:length(var_names))
    var_counters = ones(Int, length(var_names))
    var_bounds = map(v -> length(var_cut_dict[v]), var_names)

    var_dict = Dict{String,Int}()

    total_volume = 0
    done = true
    while var_counters ≤ var_bounds && done
#        @show var_counters

        volume = 1
        for i in 1:length(var_names)
            var = var_names[i]
            cnt = var_counters[i]
            cut_list = var_cut_dict[var]
            val = cut_list[cnt]
            if cnt < length(cut_list)
                val2 = cut_list[cnt + 1]
            else
                val2 = 4001
            end    
            var_dict[var] = val

            volume *= val2 - val
        end

        result = run_workflow(rule_dict, var_dict)
        if result == "A"
            total_volume += volume
        end

#        @show result volume

        done = false
        i = 1
        while i <= length(var_counters) && !done
            var_counters[i] += 1
            if var_counters[i] > var_bounds[i]
                var_counters[i] = 1
                i += 1
            else
                done = true
            end
        end
    end

    @info "For second part:" total_volume
end
