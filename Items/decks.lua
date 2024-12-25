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
                local c = SMODS.create_card({
                    set="Joker", 
                    area=G.jokers, 
                    skip_materialize=true, 
                    key="j_wrenbind_d6", 
                    edition="e_negative",
                    stickers={"eternal"}
                })
                c:add_to_deck()
                G.jokers:emplace(c)
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