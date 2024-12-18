local D20 = {
    object_type = "Joker",
    name = "wrenbind_d20",
    key = "d20",
    loc_txt = {
        name = "D20",
        text = {
            "Rerolls all {C:attention}Consumables{}",
            "Needs {C:attention}4 Charges{}"
        }
    },
    -- todo: set charge_max and replace can_roll with if charges > charge_max and then subtract charges by charge_max for battery cases
    config = {extra = {charges = 4, can_roll = true}}, 
    atlas = "atlasone",
    pos = { x = 1, y = 0, extra = {x = 4, y = 1, atlas="wrenbind_charge"} },
    soul_pos = { x = 2, y = 0 },
    rarity = "wrenbind_q4",
    cost = 20,
    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            local charges = card.ability.extra.charges
            charges = charges + 1
            if charges < 4 then
                play_sound("wrenbind_active_charge", 1, 1)
                card.ability.extra.charges = charges
                self.pos.extra.x = charges
            elseif charges ~= 5 then
                play_sound("wrenbind_active_charged", 1, 1)
                card.ability.extra.charges = 4
                self.pos.extra.x = 4
                card.ability.extra.can_roll = true
                return {
                    message = "Charged!"
                }
            end
        end
    end
}

-- charge = 6 blinds
-- d6 isn't working yet, sorry! - willow
--[[local D6 = {
    object_type = "Joker",
    name = "wrenbind_d6",
    key = "d6",
    loc_txt = {
        name = "D6",
        text = {
            "Rerolls one selected {C:attention}Joker{}",
            "Limit {C:attention}1 per Round{}" -- todo: make one per blind
        }
    },
    atlas = "atlasone",
    pos = { x = 0, y = 0, extra = {x = 0, y = 0, atlas="wrenbind_charge"}},
    --soul_pos = { x = 2, y = 0 },
    rarity = "wrenbind_q4",
    cost = 20,
    
    calculate = function(self, card, context)
        if context.end_of_round and not context.game_over and not context.repetition and not context.blueprint then
            WrenBind.can_roll.d6 = true
        end
    end
}]]

-- charge = 6 blinds
local D4 = {
    object_type = "Joker",
    name = "wrenbind_d4",
    key = "d4",
    loc_txt = {
        name = "D4",
        text = {
            "Rerolls all {C:attention}Jokers{}",
            "Needs {C:attention}5 Charges{}"
        }
    },
    atlas = "atlasone",
    config = {extra = {charges = 5, can_roll = true}},
    pos = { x = 4, y = 0, extra = {x = 5, y = 0, atlas="wrenbind_charge"} },
    soul_pos = { x = 5, y = 0 },
    rarity = "wrenbind_q4",
    cost = 20,
    calculate = function(self, card, context)
        if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
            local charges = card.ability.extra.charges
            charges = charges + 1
            if charges < 5 then
                play_sound("wrenbind_active_charge", 1, 1)
                card.ability.extra.charges = charges
                self.pos.extra.x = charges
            elseif charges ~= 6 then
                play_sound("wrenbind_active_charged", 1, 1)
                card.ability.extra.charges = 5
                self.pos.extra.x = 5
                card.ability.extra.can_roll = true
                return {
                    message = "Charged!"
                }
            end
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
            card.ability.extra.charges = 0
            card.config.center.pos.extra.x = 0
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
            card.ability.extra.can_roll = false
        end,
        d4 = function (card)
            if #G.jokers.cards-1 == 0 then
                WrenBind.util.alert_dice(card, "Nothing to roll!", 0.65)
                return true
            end
            card.ability.extra.charges = 0
            card.config.center.pos.extra.x = 0
            WrenBind.util.alert_dice(card, "Roll!", 0.75)
            WrenBind.util.play_foley("dice", 1)
            local count = #G.jokers.cards
            local counter = 1
            for i=1, count do
                if G.jokers.cards[i] ~= card then
                    local rarity = G.jokers.cards[i].config.center.rarity
                    if type(rarity) ~= "string" then
                        rarity = (rarity == 4 and 4) or (rarity == 3 and 0.98) or (rarity == 2 and 0.75) or 0
                        local is_soul = false
                        if rarity == 4 then
                            is_soul = true
                        end
                    end

                    local card_check = true
                    local c = nil
                    
                    while card_check do
                        c = create_card('Joker', G.jokers, is_soul, rarity, nil, nil, nil, "wbin")
                        if c.config.center.name ~= "D4" then
                            card_check = false
                            break 
                        end
                    end
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
            card.ability.extra.can_roll = false
            return true
        end,
        d6 = function (card) --todo: add context, selected_card, or something like that
            WrenBind.can_roll.d6 = false
            return true
        end
    },
    items = {
        D20,
        D4,
        --D6
    }
}