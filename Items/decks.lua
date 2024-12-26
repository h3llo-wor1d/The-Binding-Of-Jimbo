local IsaacDeck = {
    object_type = "Back",
    name = "wrenbind-Isaac",
    key = "isaac",
    loc_txt = {
        name = "Isaac Deck",
        text = {
            "Start with an",
            "{C:attention}Eternal Negative{}",
            "D6 Joker."
        }
    },
    order = 1,
    pos = { x = 0, y = 0 },
    atlas = "atlasdeck",
    apply = function()
        G.E_MANAGER:add_event(Event({
			func = function()
                WrenBind.util.deck_joker({
                    joker = "wrenbind_d6",
                    negative = true
                })
				return true
			end
		}))
    end
}

local LostDeck = {
    object_type = "Back",
    name = "wrenbind-Lost",
    key = "lost",
    loc_txt = {
        name = "Lost Deck",
        text = {
            "Start with a {C:attention}Negative{}",
            "ED6 Joker and Holy Mantle Joker.",
            "{C:mult}x2{} Mult, 1 Hand",
            "and 1 Discard."
        }
    },
    config = { hands = -3, discards = -2},
    order = 2,
    pos = { x = 0, y = 0 },
    atlas = "atlasdeck",
    apply = function()
        G.E_MANAGER:add_event(Event({
			func = function()
                G.GAME.round_resets.hands = 1
                G.GAME.round_resets.discards = 1
                WrenBind.util.deck_joker({
                    joker = "wrenbind_ed6",
                    negative = true
                })
                WrenBind.util.deck_joker({
                    joker = "wrenbind_holymantle",
                    negative = true,
                    eternal = true
                })
				return true
			end
		}))
    end,
    trigger_effect = function(self, args)
		if args.context == 'final_scoring_step' then
            args.mult = args.mult*2
            args.chips = args.chips*2
            update_hand_text({delay = 0}, {mult = args.mult, chips = args.chips})
            delay(0.6)
            return args.chips, args.mult
        end
	end,
}

return {
    name = "Character Decks",
    items = {
        IsaacDeck,
        LostDeck
    },
    
}