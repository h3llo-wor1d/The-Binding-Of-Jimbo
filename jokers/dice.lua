local function is_battery()
    for i=1, #G.jokers.cards do
        if G.jokers.cards[i].config.center.name == "wrenbind_thebattery" then
            return true
        end
    end
    return false
end

local function charge_logic(self, card, context)
    if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
        local charges = card.ability.extra.charges
        charges = charges + 1
        if is_battery() then
            if charges < (card.ability.extra.charge_max*2) then
                play_sound("wrenbind_active_charge", 1, 1)
                card.ability.extra.charges = charges
                self.pos.extra.x = charges
            elseif charges ~= (card.ability.extra.charge_max*2)+1 then
                play_sound("wrenbind_active_charged", 1, 1)
                card.ability.extra.charges = (card.ability.extra.charge_max*2)
                self.pos.extra.x = (card.ability.extra.charge_max*2)
                return {
                    message = "Charged!"
                }
            end
        else
            if charges < card.ability.extra.charge_max then
                play_sound("wrenbind_active_charge", 1, 1)
                card.ability.extra.charges = charges
                self.pos.extra.x = charges
            elseif charges ~= (card.ability.extra.charge_max+1) then
                play_sound("wrenbind_active_charged", 1, 1)
                card.ability.extra.charges = card.ability.extra.charge_max
                self.pos.extra.x = card.ability.extra.charge_max
                return {
                    message = "Charged!"
                }
            end
        end
    end
end

local function init_logic(self, card, context)
    card.config.center.pos.extra.x = card.ability.extra.charge_max
end

local D12 = {
    object_type = "Joker",
    name = "wrenbind_d12",
    key = "d12",
    loc_txt = {
        name = "D12",
        text = {
            "\"Rerolls Tags\""
        }
    },
    config = {extra = {charges = 3, charge_max = 3}}, 
    atlas = "atlasone",
    pos = { x = 5, y = 0, extra = {x = 3, y = 2, atlas="wrenbind_charge"} },
    soul_pos = { x = 6, y = 0 },
    rarity = "wrenbind_q2",
    cost = 16,
    calculate = charge_logic,
    added_to_deck = init_logic,
    remove_from_deck = init_logic, 
    use = function(card)
        local new_charges = card.ability.extra.charges-card.ability.extra.charge_max
        card.ability.extra.charges = new_charges
        card.config.center.pos.extra.x = new_charges
        WrenBind.util.alert_dice(card, "Roll!", 0.75)
        WrenBind.util.play_foley("dice", 1)
        WrenBind.util.reroll_tags()
        return true
    end
}

local D20 = {
    object_type = "Joker",
    name = "wrenbind_d20f",
    key = "d20",
    loc_txt = {
        name = "D20",
        text = {
            "\"Reroll The Basics\""
        }
    },
    -- todo: set charge_max and replace can_roll with if charges > charge_max and then subtract charges by charge_max for battery cases
    config = {extra = {charges = 4, charge_max = 4}}, 
    atlas = "atlasone",
    pos = { x = 1, y = 0, extra = {x = 4, y = 1, atlas="wrenbind_charge"} },
    soul_pos = { x = 2, y = 0 },
    rarity = "wrenbind_q4",
    cost = 20,
    calculate = charge_logic,
    added_to_deck = init_logic,
    remove_from_deck = init_logic, 
    use=function(card)
        if #G.consumeables.cards == 0 then
            WrenBind.util.alert_dice(card, "Nothing to roll!", 0.65)
            return true
        end
        local new_charges = card.ability.extra.charges-card.ability.extra.charge_max
        card.ability.extra.charges = new_charges
        card.config.center.pos.extra.x = new_charges
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

-- get_new_boss() for changing boss for whatever card was going to do that

-- charge = 6 blinds
local D4 = {
    object_type = "Joker",
    name = "wrenbind_d4",
    key = "d4",
    loc_txt = {
        name = "D4",
        text = {
            "\"Reroll Into Something Else\""
        }
    },
    atlas = "atlasone",
    config = {extra = {charges = 5, charge_max = 5}},
    pos = { x = 3, y = 0, extra = {x = 5, y = 0, atlas="wrenbind_charge"} },
    soul_pos = { x = 4, y = 0 },
    rarity = "wrenbind_q4",
    cost = 20,
    added_to_deck = init_logic,
    remove_from_deck = init_logic,
    calculate = charge_logic,
    use = function(card)
        if #G.jokers.cards-1 == 0 then
            WrenBind.util.alert_dice(card, "Nothing to roll!", 0.65)
            return true
        end
        local new_charges = card.ability.extra.charges-card.ability.extra.charge_max
        card.ability.extra.charges = new_charges
        card.config.center.pos.extra.x = new_charges
        WrenBind.util.alert_dice(card, "Roll!", 0.75)
        WrenBind.util.play_foley("dice", 1)
        local count = #G.jokers.cards
        local counter = 1
        for i=1, count do
            if G.jokers.cards[i] ~= card then
                local rarity = G.jokers.cards[i].config.center.rarity
                local is_soul = false
                if type(rarity) ~= "string" then
                    rarity = (rarity == 4 and 4) or (rarity == 3 and 0.98) or (rarity == 2 and 0.75) or 0
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
    end
}

return {
    name = "Dice Jokers",
    items = {
        D20,
        D4,
        D12
    }
}