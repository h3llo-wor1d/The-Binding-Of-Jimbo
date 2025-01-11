local devil_object_type = {
    object_type = "ObjectType",
    key = "Devil",
    default = "j_wrenbind_quarter",
	cards = {
		j_wrenbind_brimstone = true,
        j_wrenbind_coallump = true,
        j_wrenbind_cursedeye = true,
        j_wrenbind_quarter = true
	},
    inject = function(self)
        SMODS.ObjectType.inject(self)
    end
}

local pack1 = {
	object_type = "Booster",
	key = "devil_1",
	kind = "Devil",
	atlas = "atlaspacks",
	pos = { x = 0, y = 0 },
	order = 6,
	config = { extra = 2, choose = 1 },
	cost = 14,
    weight = 0,
	create_card = function(self, card)
        WrenBind.has_devil = true
		return create_card("Devil", G.pack_cards, nil, nil, true, true, nil, "wrenbind_devil")
	end,
	ease_background_colour = function(self)
		ease_colour(G.C.DYN_UI.MAIN, G.ARGS.LOC_COLOURS.devilbg)
		ease_background_colour({ new_colour = G.ARGS.LOC_COLOURS.devil, special_colour = G.ARGS.LOC_COLOURS.devilbg, contrast = 2 })
	end,
	loc_vars = function(self, info_queue, card)
		return { vars = { card.config.center.config.choose, card.ability.extra } }
	end, 
	update_pack = function(self, dt)
		ease_colour(G.C.DYN_UI.MAIN, G.ARGS.LOC_COLOURS.devilbg)
		ease_background_colour({ new_colour = G.ARGS.LOC_COLOURS.devil, special_colour = G.ARGS.LOC_COLOURS.devilbg, contrast = 2 })
		SMODS.Booster.update_pack(self, dt)
	end,
	group_key = "k_wrenbind_devil_pack",
}

local Brimstone = {
    object_type = "Joker",
    name = "wrenbind_brimstone",
    key = "brimstone",
    loc_txt = {
        name = "Brimstone",
        text = {
            "Gives {X:mult,C:white}x6{} mult for every",
            "card scored. {X:mult,C:white}-1x{} mult",
            "per card scored until {X:mult,C:white}1x{}."
        }
    },
    loc_vars = function(self, info_queue, center)
		info_queue[#info_queue + 1] = { set = "Other", key = "wrenbind_devilpool" }
	end,
    atlas = "atlasone",
    pos = { x = 0, y = 0 },
    rarity = "wrenbind_q4",
    config = {extra = {count = -1}},
    cost = 30,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.after then
            card.ability.extra.count = -1
        end
        if context.individual and context.cardarea == G.play then
            card.ability.extra.count = card.ability.extra.count + 1
            if (6-card.ability.extra.count <= 0) == false then 
                return {
                    x_mult = 6-card.ability.extra.count,
                    card = context.other_card
                }
            end
        end 
    end
}

local Quarter = {
    object_type="Joker",
    name="wrenbind_quarter",
    key="quarter",
    loc_txt={
        name="A Quarter",
        text = {
            "Gives {C:green}$25{} when sold",
        }
    },
    atlas = "atlasone",
    pos = { x = 0, y = 0 },
    rarity = "wrenbind_q0",
    cost = 0,
    loc_vars = function(self, info_queue, center)
		info_queue[#info_queue + 1] = { set = "Other", key = "wrenbind_devilpool" }
	end,
    calculate = function(self, card, context)
        if context.selling_self then
            ease_dollars(25)
        end
    end
}



local CoalLump = {
    object_type = "Joker",
    name = "wrenbind_coallump",
    key = "coallump",
    loc_txt = {
        name = "A Lump of Coal",
        text = {
            "For every card scored ({C:chips}x{}),",
            "gives {C:chips}50(1/2x){} extra {C:chips}Chips{}."
        }
    },
    atlas = "atlasone",
    rarity = "wrenbind_q3",
    config = {extra = {count = 0}},
    pos = { x = 7, y = 0 },
    cost = 16,
    extra_pool = "Devil",
    loc_vars = function(self, info_queue, center)
		info_queue[#info_queue + 1] = { set = "Other", key = "wrenbind_devilpool" }
	end,
    calculate = function(self, card, context)
        if context.cardarea == G.jokers and context.after then
            card.ability.extra.count = 0
        end
        if context.individual and context.cardarea == G.play then
            card.ability.extra.count = card.ability.extra.count + 1
            if card.ability.extra.count > 1 then
                return {
                    chips = (card.ability.extra.count*0.5)*50,
                    card = context.other_card
                }
            end
        end
    end
}

return {
    name = "Devil Pool",
    items = {
		devil_object_type,
        CoalLump,
        Brimstone,
        Quarter,
		pack1
	}
}