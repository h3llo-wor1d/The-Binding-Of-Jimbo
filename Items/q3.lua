local CoalLump = {
    object_type = "Joker",
    name = "wrenbind_coallump",
    key = "coallump",
    loc_txt = {
        name = "A Lump of Coal",
        text = {
            "\"My Xmas present\""
        }
    },
    atlas = "atlasone",
    rarity = "wrenbind_q3",
    config = {extra = {count = 0}},
    pos = { x = 7, y = 0 },
    cost = 16,
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