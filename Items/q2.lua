local TheBattery = {
    object_type="Joker",
    name="wrenbind_thebattery",
    key="thebattery",
    loc_txt={
        name="The Battery",
        text = {
            "\"Stores Energy\""
        }
    },
    atlas = "atlasone",
    pos = { x = 0, y = 0 },
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
            "\"Portable blood bank\""
        }
    },
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
            local discards = love.math.random(0,3)
            ease_discard(discards)
            return true     
        end
        WrenBind.util.alert_dice(card, "Can only use during Blind!", 0.85)
        return true
    end
}



return {
    name = "Quality 2 Jokers",
    items = {
        TheBattery,
        IVBag
    }
}