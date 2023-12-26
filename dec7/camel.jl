#
# This is a solution to the Advent of Code 2023 problem for day 7 in Julia 1.9:
#
# https://adventofcode.com/2023/day/7
#
# It needs the corresponding input.txt stored into the same directory.

function get_card_dicts()
    card_chs = ['A', 'K', 'Q', 'J', 'T', '9', '8', '7', '6', '5', '4', '3', '2']
    card_sts = length(card_chs):-1:1

    return Dict(zip(card_chs, card_sts)), Dict(zip(card_sts, card_chs))
end

function get_card_dicts_2()
    card_chs = ['A', 'K', 'Q', 'T', '9', '8', '7', '6', '5', '4', '3', '2', 'J']
    card_sts = length(card_chs):-1:1

    return Dict(zip(card_chs, card_sts)), Dict(zip(card_sts, card_chs))
end

function parse_input(lines)
    card_bids = []

    for line in lines
        strs = split(line, " ")
        push!(card_bids, (strs[1], parse(Int, strs[2])))
    end

    return card_bids
end

function get_strength(card)
#    @show card

    hist = Dict(zip(card, zeros(Int, length(card))))

    for ch in card
        hist[ch] += 1
    end

#    @show hist

    ks = keys(hist)
    vs = sort(collect(values(hist)))

    if length(ks) == length(card)
#        println("All unique")
        return 1
    elseif length(ks) == length(card)-1
#        println("One pair")
        return 2
    elseif vs == [1,2,2]
#        println("Two pairs")
        return 3
    elseif vs == [1,1,3]
#        println("Three of a kind")
        return 4
    elseif vs == [2,3]
#        println("Full house")
        return 5
    elseif vs == [1,4]
#        println("Four of a kind")
        return 6
    elseif vs == [5]
#        println("Five of a kind")
        return 7
    end

    @error "Unknown strength for $card"
    return 0
end

function get_strength_2(card)
    card_chs = ['A', 'K', 'Q', 'T', '9', '8', '7', '6', '5', '4', '3', '2']

#    @show card

    if contains(card, 'J')
        strength = 0
        for ch in card_chs
            card_2 = replace(card, 'J' => ch, count=1)
            strength = max(strength, get_strength_2(card_2))
        end
    else
        strength = get_strength(card)
    end

    return strength
end


function encode_card(card, c2s_dict)
    return vcat([get_strength(card)], [c2s_dict[ch] for ch in card])
end

function sort_card_bids(card_bids, c2s_dict)
    return sort(card_bids, by=(card_bid -> encode_card(card_bid[1], c2s_dict)))
end


function encode_card_2(card, c2s_dict)
    return vcat([get_strength_2(card)], [c2s_dict[ch] for ch in card])
end

function sort_card_bids_2(card_bids, c2s_dict)
    return sort(card_bids, lt=(x,y) -> x < y, by=(card_bid -> encode_card_2(card_bid[1], c2s_dict)))
end

open("input.txt") do io
    lines = readlines(io)
#    lines = ["32T3K 765", "T55J5 684", "KK677 28", "KTJJT 220", "QQQJA 483"]

    card_bids = parse_input(lines)

    c2s_dict, s2c_dict = get_card_dicts()

#    @show c2s_dict
#    for card_bid in card_bids
#        @show get_strength(card_bid[1])
#    end

    sorted_card_bids = sort_card_bids(card_bids, c2s_dict)
#    @show sorted_card_bids

    winning_1 = 0
    for i in 1:length(card_bids)
        winning_1 += i * sorted_card_bids[i][2]
    end

    @show winning_1



    c2s_dict, s2c_dict = get_card_dicts_2()

#    @show c2s_dict
#    for card_bid in card_bids
#        @show get_strength_2(card_bid[1])
#    end

    sorted_card_bids = sort_card_bids_2(card_bids, c2s_dict)
#    @show sorted_card_bids

    winning_2 = 0
    for i in 1:length(card_bids)
        winning_2 += i * sorted_card_bids[i][2]
    end

    @show winning_2
end
