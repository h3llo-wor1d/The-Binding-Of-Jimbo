local CoalLump = {
    object_type = "Joker",
    name = "wrenbind_coallump",
    key = "coallump",
    loc_txt = {
        name = "A Lump of Coal",
        text = {
            "For every card scored ({C:chips}x{}),",
            "gives {C:chips}50(1/2x){} extra {C:chips}Chips{}."
        }
    },
    atlas = "atlasone",
    rarity = "wrenbind_q3",
    config = {extra = {count = 0}},
    pos = { x = 7, y = 0 },
    cost = 16,
    loc_vars = function(self, info_queue, center)
		info_queue[#info_queue + 1] = { set = "Other", key = "wrenbind_devilpool" }
	end,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.after then
            card.ability.extra.count = 0
        end
        if context.individual and context.cardarea == G.play then
            card.ability.extra.count = card.ability.extra.count + 1
            if card.ability.extra.count > 1 then
                return {
                    chips = (card.ability.extra.count*0.5)*50,
                    card = context.other_card
                }
            end
        end
    end
}

return {
    name = "Quality 3 Jokers",
    quality = "q3",
    items = {
        CoalLump
    }
}