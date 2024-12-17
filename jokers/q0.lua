local CursedEye = {
    object_type="Joker",
    name="wrenbind_cursedeye",
    key="cursedeye",
    loc_txt={
        name="Cursed Eye",
        text = {
            "Retrigger played Hand {C:Attention}3{} times.",
            "If Played Hand does not complete this Blind,"
            "{C:Attention}-1{} Hands for this Blind."
        }
    },
    atlas = "atlasone",
    pos = { x = 0, y = 0 },
    rarity = 1, -- todo: custom rarities, add quality 0
    cost = 8,
    calculate = function(self, card, context)
        -- calc below after scoring phase if it is not end of round
        -- G.GAME.round_resets.hands = G.GAME.round_resets.hands - WrenBind.globals.cursed_eye.count

        -- actual retrigger mechanics
        if context.cardarea == G.play and context.repetition and not context.repetition_only then
            WrenBind.globals.cursed_eye.count = WrenBind.globals.cursed_eye.count+1
            return {
                message = "Again!",
                repetitions = 3,
                card = context.other_card
            }
        end
        -- calc after: after end_of_round, return hands back to expected values
        if context.end_of_round and not context.game_over and not context.repetition and not context.blueprint then
            -- Reset hands to correct size
            G.GAME.round_resets.hands = G.GAME.round_resets.hands + WrenBind.globals.cursed_eye.count
            WrenBind.globals.cursed_eye.count = 0 -- reset to 0 afterwards
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