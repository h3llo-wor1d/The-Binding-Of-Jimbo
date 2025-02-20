local function gfuels()
    local counter = 1
    for i=1, #G.jokers.cards do
        if G.jokers.cards[i].config.center.name == "wrenbind_gfuel" then
            counter = counter + 1
        end
    end
    return counter
end

to_big = to_big or function(n) return n end

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
    blueprint_compat = true,
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

local RockBottom = {
    object_type = "Joker",
    name = "wrenbind_rbottom",
    key = "rbottom",
    loc_txt = {
        name = "Rock Bottom",
        text = {
            "All Stats are permanently",
            "their max value throughout",
            "the current run.",
            "{s:0.7}{C:mult}Mult #1# {}{C:grey}~ {}{C:chips}Chips #2# {}{C:grey}~{}{C:attention} Luck #3# {}{C:grey}~{}{C:green} Money #4#{}"
        }
    },
    loc_vars = function(self,info_queue,card)
        return { vars = { card.ability.extra.mult.d, card.ability.extra.chips.d, card.ability.extra.luck, card.ability.extra.money } }
    end,
    atlas = "atlasone",
    pos={ x=0, y=0},
    rarity="wrenbind_q4",
    cost=20,
    config = {
        extra = {
            luck = 0,
            mult = {
                r = 0,
                d = 0
            },
            chips = {
                r = 0,
                d = 0
            },
            money = 0,
            discards = 0,
            hands = 0
        }
    },
    added_to_deck = function(self,card,context)
        if not from_debuff and G.STAGE == G.STAGES.RUN and not G.screenwipe then
            -- Save max stats when gained
            card.ability.extra.discards = G.GAME.round_resets.discards
            card.ability.extra.hands = G.GAME.round_resets.hands
        end
    end,
    remove_from_deck = function(self,card,context)
        G.GAME.probabilities.normal = G.GAME.probabilities.real
    end,
    calculate = function(self,card,context)
        if context.stat_changed then
            if context.stat_changed.name == "luck" then
                if G.GAME.probabilities.real > G.GAME.probabilities.normal then
                    card.ability.extra.luck = G.GAME.probabilities.real
                    G.GAME.probabilities.normal = G.GAME.probabilities.real
                end
            end
            if context.stat_changed.name == "money" then
                if context.stat_changed.value > card.ability.extra.money then
                    card.ability.extra.money = context.stat_changed.value
                end
            end
        end

        -- Mult/Chip logic (shouldn't be a problem to auto-check for tables since this mod lists talisman as a requirement...?)
        if context.cardarea == G.jokers and not context.before and not context.after and not context.debuffed_hand and hand_chips and mult then
            local has_changed_values = false

            if type(card.ability.extra.mult.r) ~= "table" or mult > card.ability.extra.mult.r then
                card.ability.extra.mult.d = mult:to_number()
                card.ability.extra.mult.r = mult
            else
                has_changed_values = true
                mult = mod_mult(card.ability.extra.mult.r)
            end

            if type(card.ability.extra.chips.r) ~= "table" or hand_chips > card.ability.extra.chips.r then
                card.ability.extra.chips.d = hand_chips:to_number()
                card.ability.extra.chips.r = hand_chips
            else
                has_changed_values = true
                hand_chips = mod_mult(card.ability.extra.chips.r)
            end  

            if has_changed_values then
                update_hand_text({ delay = 0 }, { mult = card.ability.extra.mult.r, chips = card.ability.extra.chips.r })
                return {
                    message = "Min/Maxed!"
                }
            end   
        end
    end
}

return {
    name = "Quality 4 Jokers",
    quality = "q4",
    items = {
        Polyphemus,
        GFuel,
        RockBottom
    }
}