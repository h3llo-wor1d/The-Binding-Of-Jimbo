local CursedEye = {
    -- this joker doesn't work for some reason...
    object_type="Joker",
    name="wrenbind_cursedeye",
    key="cursedeye",
    loc_txt={
        name="Cursed Eye",
        text = {
            "Retrigger played Hand {C:Attention}3{} times.",
            "If Played Hand does not complete this Blind,",
            "{C:Attention}-1{} Hands for this Blind.",
            "{C:Attention}This card is broken, it will be fixed soon.{}"
        }
    },
    atlas = "atlasone",
    pos = { x = 0, y = 0 },
    rarity = "wrenbind_q0", -- todo: custom rarities, add quality 0
    cost = 8,
    calculate = function(self, card, context)
        -- i can't get this to work the way i want it to :(((((
        if context.cardarea == G.play and context.repetition and not context.repetition_only then
            return {
                message = "Again!",
                repetitions = 3,
                card = context.other_card
            }
        end

        if context.cardarea == G.play and context.after and not context.repetition and not context.repetition_only then
            --WrenBind.globals.cursed_eye.count = WrenBind.globals.cursed_eye.count+2
            -- none of this shit works
        end

        if not context.end_of_round and context.after and not context.repetition then 
            --G.GAME.round_resets.hands = G.GAME.round_resets.hands - WrenBind.globals.cursed_eye.count
            return {
                message = "This doesn't work!"
            }
        end
        -- calc after: after end_of_round, return hands back to expected values
        if context.end_of_round and not context.game_over and not context.repetition and not context.blueprint then
            -- Reset hands to correct size
            --G.GAME.round_resets.hands = G.GAME.round_resets.hands + WrenBind.globals.cursed_eye.count
            --WrenBind.globals.cursed_eye.count = 0 -- reset to 0 afterwards
            return {
                message = "Reset!"
            }
        end
    end

}

return {
    name = "Quality 0 Jokers",
    items = {
        CursedEye
    }
}