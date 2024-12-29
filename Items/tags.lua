local LazyTag = {
	object_type = "Tag",
	atlas = "wrenbind_tags",
	pos = { x = 0, y = 0 },
	name = "wrenbind-LazyTag",
	order = 1,
    loc_txt = {
        name = "Lazy Tag",
        text = {
            "1/4 chance to spawn",
            "{C:gold}Legendary{} Joker",
            "In the next shop"
        }
    },
	--requires = 'j_cry_googol_play',
	config = { type = "store_joker_create" },
	key = "lazy",
	apply = function(tag, context)
		if context.type == "store_joker_create" then
			local card
			if love.math.random(1,4) == 1 then
				card = create_card("Joker", context.area, true, nil, nil, nil, nil, "wrb")
				create_shop_card_ui(card, "Joker", context.area)
				card.states.visible = false
				tag:yep("+", G.C.RARITY.cry_epic, function()
					card:start_materialize()
					card:set_cost()
					return true
				end)
			else
				tag:nope()
			end
			tag.triggered = true
			return card
		end
	end,
}

return {
    name = "Tags",
    items = {
        LazyTag
    }
}