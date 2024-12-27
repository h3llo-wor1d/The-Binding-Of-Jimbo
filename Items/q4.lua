local function gfuels()
    local counter = 1
    for i=1, #G.jokers.cards do
        if G.jokers.cards[i].config.center.name == "wrenbind_gfuel" then
            counter = counter + 1
        end
    end
    return counter
end

local GFUEL_FLAVORS = {
    "HUMOR UP!",
    "G UP!",
    "FASTER UP!",
    "EXPLOSIONS UP!",
    "AMBITION UP!",
    "RESPECT UP!",
    "GENEROSITY UP!",
    "WHITE BLOOD CELLS UP!",
    "MANA UP!",
    "ENERGY UP!",
    "RANK UP! REACHED RANK: ISAAC'S FACE",
    "FEAR UP!",
    "REACTION UP!",
    "ACCEPTANCE UP!",
    "ACIDITY UP!",
    "THOU ART HERO!",
    "VOLUME UP!",
    "FAVOR UP!",
    "SOUL UP!"
}

local gf_eff = {
    function(card, static) 
        return {
            x_mult = card.ability.extra.perm_mult
        }
    end,
    function(card, static)
        return {
            x_mult = card.ability.extra.perm_mult,
            chip_mod = 100*card.ability.extra.perm_mult
        }
    end,
    function(card, static)
        mult = (static and card.ability.extra.perm_mult*mult or 1)
        return {
            chip_mod = ((hand_chips*40)*card.ability.extra.perm_mult)-hand_chips
        }
    end,
    function(card, static)
        return {
            chip_mod = 300*card.ability.extra.perm_mult,
            x_mult = card.ability.extra.perm_mult
        }
    end,
    function(card, static)
        return {
            chip_mod = 200*card.ability.extra.perm_mult,
            x_mult = card.ability.extra.perm_mult
        }
    end,
    function(card, static)
        return {
            chip_mod = ((hand_chips*60)*card.ability.extra.perm_mult) - hand_chips,
            x_mult = card.ability.extra.perm_mult
        }
    end,
    function(card, static)
        return {
            chip_mod = 100*card.ability.extra.perm_mult,
            x_mult = card.ability.extra.perm_mult
        }
    end
}
local function calculate_gfuel(card)
    local effect = (gfuels()-1 > 7 and true or gfuels()-1)
    -- static mult ups
    card.ability.extra.perm_mult = ((card.ability.extra.perm_mult^0.95)*1.4)+1

    if type(effect) ~= "boolean" then
        return gf_eff[effect](card)
    else
        return gf_eff[love.math.random(1,#gf_eff)](card, true)
    end
end

local Polyphemus = {
    object_type = "Joker",
    name = "wrenbind_polyphemus",
    key = "polyphemus",
    loc_txt = {
        name = "Polyphemus",
        text = {
            "{X:mult,C:white}^1.5{} mult"
        }
    },
    atlas = "atlasone",
    config = {extra = {active = false}},
    pos = { x = 0, y = 0 },
    rarity = "wrenbind_q4",
    cost = 20,
    calculate = function(self, card, context)
        if 
            context.cardarea == G.jokers
            and context.joker_main
        then
            return {
                mult_mod = math.floor(((mult^1.50)-mult) + 0.5),
                chip_mod = math.floor(((hand_chips^1.50)-hand_chips) + 0.5),
                message = "Mega!",
                card = self
            }
        end   
    end
}

local Brimstone = {
    object_type = "Joker",
    name = "wrenbind_brimstone",
    key = "brimstone",
    loc_txt = {
        name = "Brimstone",
        text = {
            "Gives {X:mult,C:white}x6{} mult for every",
            "card scored. {X:mult,C:white}-1x{} mult",
            "per card scored until {X:mult,C:white}1x{}."
        }
    },
    loc_vars = function(self, info_queue, center)
		info_queue[#info_queue + 1] = { set = "Other", key = "wrenbind_devilpool" }
	end,
    atlas = "atlasone",
    pos = { x = 0, y = 0 },
    rarity = "wrenbind_q4",
    config = {extra = {count = -1}},
    cost = 30,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.after then
            card.ability.extra.count = -1
        end
        if context.individual and context.cardarea == G.play then
            card.ability.extra.count = card.ability.extra.count + 1
            if (6-card.ability.extra.count <= 0) == false then 
                return {
                    x_mult = 6-card.ability.extra.count,
                    card = context.other_card
                }
            end
        end 
    end
}

local GFuel = {
    object_type = "Joker",
    name = "wrenbind_gfuel",
    key = "gfuel",
    loc_txt = {
        name = "GFUEL",
        text = {
            "#1#"
        }
    },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.flavor } }
    end,
    atlas = "atlasone",
    pos = { x = 1, y = 1 },
    soul_pos = {x = 2, y = 1},
    rarity = "wrenbind_q4",
    immutable = true,
    config = {
        eternal=true, 
        extra = {id=0, flavor="G UP!", active=true, perm_mult=1}
    },
    cost = 20,
    
    add_to_deck = function(self, card, from_debuff)
        if not from_debuff and G.STAGE == G.STAGES.RUN and not G.screenwipe then
            card.ability.extra.flavor = GFUEL_FLAVORS[love.math.random(1,#GFUEL_FLAVORS)]
            IS_GFUEL = true
            local count = gfuels()
            card.ability.extra.id = count
            if count > 7 then
                count = 7
            end
            play_sound("wrenbind_gfuel"..count)
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = card.ability.extra.flavor})
        end
    end,
    calculate = function(self, card, context)
        if card.ability.extra.id == 1 then
            if context.cardarea == G.jokers and context.after and not card.ability.extra.active then
                card.ability.extra.active = true
            end
            if context.joker_main then
                card.ability.extra.active = false
                local calc = calculate_gfuel(card, effect)
                calc.message = "GFUEL!"
                return calc
            end
            if context.end_of_round and not context.game_over and not context.repetition and not context.blueprint and not context.individual then
                play_sound("wrenbind_gfexplosion"..(gfuels() > 4 and 4 or gfuels()), 1, 1)
            end
            if G.GAME.blind.boss and not context.game_over and context.end_of_round and not context.repetition and not context.blueprint and not context.individual then
                local c = copy_card(card)
                c:add_to_deck()
                G.jokers:emplace(c)
            end  
        end   
    end
}

local HolyMantle = {
    object_type = "Joker",
    name = "wrenbind_holymantle",
    key = "holymantle",
    loc_txt = {
        name = "Holy Mantle",
        text = {
            "Prevents {C:attention}Game Over{} giving",
            "{C:attention}+1{} Hand and {C:attention}+1{} Discard to",
            "finish the blind, {C:attention}once{} per Blind."
        }
    },
    atlas = "atlasone",
    pos = { x = 0, y = 0},
    rarity = "wrenbind_q4",
    config = {
        extra = {active=true}
    },
    cost = 20,
    loc_vars = function(self, info_queue, center)
		info_queue[#info_queue + 1] = { set = "Other", key = "wrenbind_angelpool" }
	end,
    calculate = function(self, card, context)
        if G.GAME.chips < G.GAME.blind.chips and context.cardarea == G.jokers and context.joker_main then
            -- todo: check for plasma deck calc as well in this if statement if using plasma
            if card.ability.extra.active and G.GAME.current_round.hands_left == 0 then
                card.ability.extra.active = false
                G.STATES.GAME_OVER = false
                ease_hands_played(1)
                ease_discard(1)
                play_sound("wrenbind_mantle_shatter")
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Safe!"})
            end
        end
        if context.end_of_round and not context.game_over and not context.repetition and not context.blueprint and not context.individual then
            card.ability.extra.active = true
        end
    end
}

return {
    name = "Quality 4 Jokers",
    quality = "q4",
    items = {
        Polyphemus,
        GFuel,
        Brimstone,
        HolyMantle
    }
}