local D20 = {
    object_type = "Joker",
    name = "wrenbind_d20",
    key = "d20",
    loc_txt = {
        name = "D20",
        text = {
            "Rerolls all {C:attention}Consumables{}",
            "Limit {C:attention}1 per round{}"
        }
    },
    atlas = "atlasone",
    pos = { x = 1, y = 0 },
    soul_pos = { x = 2, y = 0 },
    rarity = 4,
    cost = 20,
    calculate = function(self, card, context)
        if context.end_of_round and not context.game_over and not context.repetition and not context.blueprint then
            WrenBind.can_roll.d20 = true
        end
    end
}

local D4 = {
    object_type = "Joker",
    name = "wrenbind_d4",
    key = "d4",
    loc_txt = {
        name = "D4",
        text = {
            "Rerolls all {C:attention}Jokers{}",
            "Limit {C:attention}1 per round{}"
        }
    },
    atlas = "atlasone",
    pos = { x = 4, y = 0 },
    soul_pos = { x = 5, y = 0 },
    rarity = 4,
    cost = 20,
    calculate = function(self, card, context)
        if context.end_of_round and not context.game_over and not context.repetition and not context.blueprint then
            WrenBind.can_roll.d4 = true
        end
    end
}

return {
    name = "Dice Jokers",
    logic = {
        d20 = function (card)
            if #G.consumeables.cards == 0 then
                WrenBind.util.alert_dice(card, "Nothing to roll!", 0.65)
                return true
            end
            WrenBind.util.alert_dice(card, "Roll!", 0.75)
            WrenBind.util.play_foley("dice", 1)
            for i=1, #G.consumeables.cards do
                -- choose randomly from these 3 every time we replace, then make negative for all cards in hand
                local types = {
                    "Spectral",
                    "Tarot",
                    "Planet"
                }
        
                local card_config = {
                    type = types[love.math.random(1,#types)],
                    legendary = pseudorandom('soul_'..G.GAME.round_resets.ante) > 0.997
                }
        
                local c = create_card(card_config.type, G.consumeables, card_config.legendary, nil, true, true, nil, 'wbin')
                c:add_to_deck()
                local temp = G.consumeables.cards[i]
                if temp.edition ~= nil and temp.edition ~= "" then
                    c:set_edition({negative = true}, true, true)
                end
                G.consumeables:emplace(c)
                temp:remove()
                G.consumeables:remove_card(temp)
                table.insert(G.consumeables.cards, i, table.remove(G.consumeables.cards,#G.consumeables.cards))
                -- borrowed from my missingno mod
            end
            WrenBind.can_roll.d20 = false
        end,
        d4 = function (card)
            if #G.jokers.cards-1 == 0 then
                WrenBind.util.alert_dice(card, "Nothing to roll!", 0.65)
                return true
            end
            WrenBind.util.alert_dice(card, "Roll!", 0.75)
            WrenBind.util.play_foley("dice", 1)
            local count = #G.jokers.cards
            local counter = 1
            for i=1, count do
                if G.jokers.cards[i] ~= card then
                    local rarity = G.jokers.cards[i].config.center.rarity
                    rarity = (rarity == 4 and 4) or (rarity == 3 and 0.98) or (rarity == 2 and 0.75) or 0
                    local is_soul = false
                    if rarity == 4 then
                        is_soul = true
                    end
                    local c = create_card('Joker', G.jokers, is_soul, rarity, nil, nil, nil, "wbin")
                    c:add_to_deck()
                    local temp = G.jokers.cards[i]
                    G.jokers:emplace(c)
                    temp:remove()
                    G.jokers:remove_card(temp)
                    table.insert(G.jokers.cards, i, table.remove(G.jokers.cards,#G.jokers.cards))
                end
                counter = counter+1
                if counter > count then break end
            end
            WrenBind.can_roll.d4 = false
            return true
        end
    },
    items = {
        D20,
        D4
    }
}