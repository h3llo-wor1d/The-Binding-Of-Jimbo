local Polyphemus = {
    object_type = "Joker",
    name = "wrenbind_polyphemus",
    key = "polyphemus",
    loc_txt = {
        name = "Polyphemus",
        text = {
            "{C:Mult}\"Double\"{} Mult"
        }
    },
    atlas = "atlasone",
    config = {extra = {active = false}},
    pos = { x = 0, y = 0 },
    rarity = "wrenbind_q4",
    cost = 20,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.after and not card.ability.extra.active then
            card.ability.extra.active = true
        end
        if 
            context.cardarea == G.jokers
            and not context.before
            and not context.after
            and card.ability.extra.active
        then
            card.ability.extra.active = false
            hand_chips = hand_chips^1.50
            mult = mult^1.50
            SMODS.eval_this(card, {message = "x2?", colour = G.C.MULT})
        end   
    end
}

return {
    name = "Quality 4 Jokers",
    items = {
        Polyphemus
    }
}