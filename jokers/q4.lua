local Polyphemus = {
    object_type = "Joker",
    name = "wrenbind_polyphemus",
    key = "polyphemus",
    loc_txt = {
        name = "Polyphemus",
        text = {
            "{C:Mult}^2{} Mult"
        }
    },
    atlas = "atlasone",
    pos = { x = 0, y = 1 },
    soul_pos = {x=1, y=1},
    rarity = 3,
    cost = 20,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.after and not WrenBind.is_active.polyphemus then
            WrenBind.is_active.polyphemus = true
        end
        if 
            context.cardarea == G.jokers
            and not context.before
            and not context.after
            and WrenBind.is_active.polyphemus
        then
            WrenBind.is_active.polyphemus = false
            hand_chips = hand_chips*hand_chips
            mult = mult*mult
            SMODS.eval_this(card, {message = "^2", colour = G.C.MULT})
        end   
    end
}

return {
    name = "Quality 4 Jokers",
    items = {
        Polyphemus
    }
}