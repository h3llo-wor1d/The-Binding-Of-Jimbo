local YumHeart = WrenBind.ActiveJoker({
    name = "yumheart",
    loc_txt = {
        name = "Yum Heart",
        text = {
            "Add {C:attention}+1 hand{} for this round",
        }
    },
    loc_vars = function(self, info_queue, center)
		info_queue[#info_queue + 1] = { set = "Other", key = "wrenbind_activejoker" }
	end,
    atlas = "atlasone",
    charges=3,
    rarity = "wrenbind_q1",
    cost = 8,
    pos = { x = 0, y = 0},
    use = function(card)
        if G.GAME and G.GAME.blind and G.GAME.blind.in_blind then
            local new_charges = card.ability.extra.charges-card.ability.extra.charge_max
            card.ability.extra.charges = new_charges
            card.config.center.pos.extra.x = new_charges
            WrenBind.util.alert_dice(card, "+1 Hand", 0.75)
            ease_hands_played(1)
            return true  
        end
        WrenBind.util.alert_dice(card, "Can only use during Blind!", 1)
        play_sound("wrenbind_error_buzz")
        return true
    end
})

return {
    name = "Quality 1 Jokers",
    quality = "q1",
    items = {
        YumHeart
    }
}