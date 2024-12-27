local TheBattery = {
    object_type="Joker",
    name="wrenbind_thebattery",
    key="thebattery",
    loc_txt={
        name="The Battery",
        text = {
            "Allows you to charge",
            "{C:gold}Active Jokers{} twice."
        }
    },
    atlas = "atlasone",
    pos = { x = 10, y = 0 },
    rarity = "wrenbind_q2",
    cost = 8
}

local IVBag = {
    object_type="Joker",
    name="wrenbind_ivbag",
    key="ivbag",
    loc_txt={
        name="IV Bag",
        text = {
            "On use, removes {C:attention}1{} Hand",
            "for {C:green}#1# to 3{} Discards",
            "for the current round."
        }
    },
    loc_vars = function(self, info_queue, center)
		info_queue[#info_queue + 1] = { set = "Other", key = "wrenbind_activejoker" }
        return {vars = {(G.GAME.probabilities.normal-1)}}
	end,
    atlas = "atlasone",
    config = {extra = {charges = 1, charge_max = 1}},
    pos = { x = 0, y = 0, extra = {x = 1, y = 4, atlas="wrenbind_charge"} },
    rarity = "wrenbind_q2",
    cost = 8,
    added_to_deck = init_logic,
    remove_from_deck = init_logic,
    calculate = charge_logic,
    use = function(card)
        if G.GAME and G.GAME.blind and G.GAME.blind.in_blind then
            play_sound("wrenbind_blood_use", 1, 1)
            local new_charges = card.ability.extra.charges-card.ability.extra.charge_max
            card.ability.extra.charges = new_charges
            card.config.center.pos.extra.x = new_charges
            WrenBind.util.alert_dice(card, "Prick!", 0.75)
            ease_hands_played(-1)
            local prob_add = G.GAME.probabilities.normal-1
            local discards = love.math.random(0,3)
            if discards + prob_add > 3 and G.GAME.probabilities.normal-1 <= 3 then
                ease_discard(discards)
            else
                ease_discard(discards+prob_add)
            end
            return true  
        end
        WrenBind.util.alert_dice(card, "Can only use during Blind!", 1)
        play_sound("wrenbind_error_buzz")
        return true
    end
}



return {
    name = "Quality 2 Jokers",
    quality = "q2",
    items = {
        TheBattery,
        IVBag
    }
}