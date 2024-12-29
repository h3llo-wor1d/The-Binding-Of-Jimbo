local lilbattery = {
	object_type = "Consumable",
	set = "Tarot",
	name = "wrenbind-lilbattery",
	key = "lilbattery",
	order = 1,
	pos = { x = 0, y = 0 },
	cost = 3,
	atlas = "atlasone",
    config = { max_highlighted = 1 },
    loc_txt = {
        name = "Lil' Battery",
        text = {
            "Adds 2 charges to",
			"{C:gold}Active{} Joker"
        }
    },
	can_use = function(self, card)
		local success, result = pcall(function()
            return G.jokers.highlighted[1].ability 
            and G.jokers.highlighted[1].ability.extra 
            and G.jokers.highlighted[1].ability.extra.charges
        end)
        if success and result then
            local card = G.jokers.highlighted[1]
            if card.ability.extra.charges < card.ability.extra.charge_max then
                return true
            elseif card.ability.extra.charges >= card.ability.extra.charge_max and is_battery() then
                return true
            end
        end
        return false
	end,
	use = function(self, card, area, copier)
        local used_consumable = copier or card
		for i = 1, #G.jokers.highlighted do
			local highlighted = G.jokers.highlighted[i]
			G.E_MANAGER:add_event(Event({
				func = function()
					play_sound("tarot1")
					highlighted:juice_up(0.3, 0.5)
					return true
				end,
			}))
			G.E_MANAGER:add_event(Event({
				trigger = "after",
				delay = 0.1,
				func = function()
					if highlighted then
						charge_logic(highlighted, 2)
					end
					return true
				end,
			}))
			delay(0.5)
			G.E_MANAGER:add_event(Event({
				trigger = "after",
				delay = 0.2,
				func = function()
					G.jokers:unhighlight_all()
					return true
				end,
			}))
		end
	end,
}

local megabattery = {
	object_type = "Consumable",
	set = "Tarot",
	name = "wrenbind-megabattery",
	key = "megabattery",
	order = 1,
	pos = { x = 0, y = 0 },
	cost = 3,
	atlas = "atlasone",
    config = { max_highlighted = 1 },
    loc_txt = {
        name = "Mega Battery",
        text = {
            "Double-charge selected",
			"{C:gold}Active{} Joker"
        }
    },
	can_use = function(self, card)
		local success, result = pcall(function()
            return G.jokers.highlighted[1].ability 
            and G.jokers.highlighted[1].ability.extra 
            and G.jokers.highlighted[1].ability.extra.charges
        end)
        if success and result then
            local card = G.jokers.highlighted[1]
            if card.ability.extra.charges < card.ability.extra.charge_max*2 then
                return true
            end
        end
        return false
	end,
	use = function(self, card, area, copier)
        local used_consumable = copier or card
		for i = 1, #G.jokers.highlighted do
			local highlighted = G.jokers.highlighted[i]
			G.E_MANAGER:add_event(Event({
				func = function()
					play_sound("tarot1")
					highlighted:juice_up(0.3, 0.5)
					return true
				end,
			}))
			G.E_MANAGER:add_event(Event({
				trigger = "after",
				delay = 0.1,
				func = function()
					if highlighted then
						charge_logic(highlighted, (highlighted.ability.extra.charge_max*2)+3, true)
					end
					return true
				end,
			}))
			delay(0.5)
			G.E_MANAGER:add_event(Event({
				trigger = "after",
				delay = 0.2,
				func = function()
					G.jokers:unhighlight_all()
					return true
				end,
			}))
		end
	end,
}

return {
    name = "Consumeables",
    items = {
        lilbattery,
		megabattery
    }
}