local CursedEye = {
    -- this joker doesn't work for some reason...
    object_type="Joker",
    name="wrenbind_cursedeye",
    key="cursedeye",
    loc_txt={
        name="Cursed Eye",
        text = {
            "\"Cursed Charge Shot\"",
        }
    },
    atlas = "atlasone",
    pos = { x = 0, y = 0 },
    rarity = "wrenbind_q0",
    cost = 4,
    blueprint_compat = true,
    calculate = function(self, card, context)
        if context.cardarea == G.play and context.repetition and not context.repetition_only then
            return {
                message = "Again!",
                repetitions = 3,
                card = context.other_card
            }
        end
        local success, result = pcall(function()
            return G.GAME.chips < G.GAME.blind.chips and context.cardarea == G.jokers and context.after
        end)
        
        if success and result then
            ease_hands_played(-1)
            return {
                message = "Fuck You!"
            }
        end
    end
}
return {
    name = "Quality 0 Jokers",
    quality = "q0",
    items = {
        CursedEye
    }
}