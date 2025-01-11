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

return {
    name = "Character Decks",
    items = {
        IsaacDeck
    },
    
}