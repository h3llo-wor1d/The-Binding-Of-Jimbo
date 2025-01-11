local angel_object_type = {
    object_type = "ObjectType",
    key = "Angel",
    default = "j_wrenbind_holymantle",
	cards = {
		j_wrenbind_holymantle = true
	},
    inject = function(self)
        SMODS.ObjectType.inject(self)
    end
}

local pack1 = {
	object_type = "Booster",
	key = "angel_1",
	kind = "Angel",
	atlas = "atlaspacks",
	pos = { x = 0, y = 0 },
	order = 5,
	config = { extra = 2, choose = 1 },
	cost = 14,
	weight = 0.0,
	create_card = function(self, card)
		WrenBind.can_spawn_angels = true
		return create_card("Angel", G.pack_cards, nil, nil, true, true, nil, "wrenbind_angel")
	end,
	ease_background_colour = function(self)
		ease_colour(G.C.DYN_UI.MAIN, G.ARGS.LOC_COLOURS.angelbg)
		ease_background_colour({ new_colour = G.ARGS.LOC_COLOURS.angel, special_colour = G.ARGS.LOC_COLOURS.angelbg, contrast = 2 })
	end,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.config.center.config.choose, card.ability.extra } }
	end, --For some reason, I need to keep the loc_txt or else it crashes
	loc_txt = {
		name = "Angel Pack",
		text = {
			"Choose {C:attention}#1#{} of",
			"up to {C:attention}#2# Angel Jokers{}",
		},
	},
	update_pack = function(self, dt)
		ease_colour(G.C.DYN_UI.MAIN, G.ARGS.LOC_COLOURS.angelbg)
		ease_background_colour({ new_colour = G.ARGS.LOC_COLOURS.angel, special_colour = G.ARGS.LOC_COLOURS.angelbg, contrast = 2 })
		SMODS.Booster.update_pack(self, dt)
	end,
	group_key = "k_wrenbind_angel_pack",
}

local HolyMantle = {
    object_type = "Joker",
    name = "wrenbind_holymantle",
    key = "holymantle",
    loc_txt = {
        name = "Holy Mantle",
        text = {
            "Prevents {C:attention}Game Over{} giving",
            "{C:attention}+1{} Hand and {C:attention}+1{} Discard to",
            "finish the blind, {C:attention}once{} per Blind."
        }
    },
    atlas = "atlasone",
    pos = { x = 0, y = 0},
    rarity = "wrenbind_q4",
	weight = 0,
	in_pool = function()
		return false
	end,
    config = {
        extra = {active=true}
    },
    cost = 20,
    loc_vars = function(self, info_queue, center)
		info_queue[#info_queue + 1] = { set = "Other", key = "wrenbind_angelpool" }
	end,
    calculate = function(self, card, context)
        if context.end_of_round and not context.game_over and not context.repetition and not context.blueprint and not context.individual then
            card.ability.extra.active = true
        end
    end,
	added_to_deck = function(self, card, context)
		WrenBind.can_spawn_angels = false
	end
}

return {
    name = "Angel Pool",
    items = {
		angel_object_type,
		pack1,
		HolyMantle
	}
}