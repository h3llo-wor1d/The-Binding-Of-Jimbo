local mod_path = SMODS.current_mod.path
Wrenbind_config = SMODS.current_mod.config

print("INIT WRENBIND")
WrenBind = {util = nil, pills_order = nil}

IS_GFUEL = false

function is_battery()
    for i=1, #G.jokers.cards do
        if G.jokers.cards[i].config.center.name == "wrenbind_thebattery" then
            return true
        end
    end
    return false
end

function charge_logic(self, card, context)
    if context.end_of_round and not context.repetition and not context.individual and not context.blueprint then
        local charges = card.ability.extra.charges
        charges = charges + 1
        if is_battery() then
            if charges < (card.ability.extra.charge_max*2) then
                play_sound("wrenbind_active_charge", 1, 1)
                card.ability.extra.charges = charges
                self.pos.extra.x = charges
            elseif charges ~= (card.ability.extra.charge_max*2)+1 then
                play_sound("wrenbind_active_charged", 1, 1)
                card.ability.extra.charges = (card.ability.extra.charge_max*2)
                self.pos.extra.x = (card.ability.extra.charge_max*2)
                return {
                    message = "Charged!"
                }
            end
        else
            if charges < card.ability.extra.charge_max then
                play_sound("wrenbind_active_charge", 1, 1)
                card.ability.extra.charges = charges
                self.pos.extra.x = charges
            elseif charges ~= (card.ability.extra.charge_max+1) then
                
                play_sound("wrenbind_active_charged", 1, 1)
                card.ability.extra.charges = card.ability.extra.charge_max
                self.pos.extra.x = card.ability.extra.charge_max
                return {
                    message = "Charged!"
                }
            end
        end
    end
end

function init_logic(self, card, context)
    card.config.center.pos.extra.x = card.ability.extra.charge_max
end


SMODS.Sound:register_global()

SMODS.Atlas({
	key = "atlasone",
	path = "atlasone.png",
	px = 71,
	py = 95,
}):register()

SMODS.Atlas({
	key = "charge",
	path = "atlascharge.png",
	px = 71,
	py = 95,
}):register()

SMODS.Atlas({
	key = "atlasdeck",
	path = "atlasdeck.png",
	px = 71,
	py = 95,
}):register()

-- register pills atlas
-- pills will be added in a future version of The Binding of Jimbo.

--[[SMODS.Atlas({
	key = "atlaspills",
	path = "atlaspills.png",
	px = 71,
	py = 95,
}):register()

SMODS.ConsumableType{
	key = "WrenPills",
	primary_colour = G.C.MONEY,
	secondary_colour = G.C.MONEY,
	collection_rows = { 4, 5 },
	loc_txt = {
        collection = "Pills",
        name = "Pills",
        undiscovered = {
            name = "Pill",
            text = {"Effect Unknown"}
        }
    },
    shop_rate = 1
}

SMODS.UndiscoveredSprite{
    key = 'WrenPills', --must be the same key as the consumabletype
    atlas = 'atlaspills',
    pos = {x = 0, y = 0}
}]]



SMODS.Rarity {
    key = "q4",
    loc_txt = {
        name = "Quality 4"
    },
    badge_colour = HEX('ffd100'),
    default_weight = 0.075,
    pools = {["Joker"] = true},
}

SMODS.Rarity {
    key = "q3",
    loc_txt = {
        name = "Quality 3"
    },
    default_weight=0.085,
    badge_colour = HEX('ff54ec'),
    pools = {["Joker"] = true}
}

SMODS.Rarity {
    key = "q2",
    loc_txt = {
        name = "Quality 2"
    },
    default_weight=0.095,
    badge_colour = HEX('65d5ff'),
    pools = {["Joker"] = true}
}

SMODS.Rarity {
    key = "q0",
    loc_txt = {
        name = "Quality 0"
    },
    default_weight=0.1,
    badge_colour = HEX('c2c2c2'),
    pools = {["Joker"] = true}
}

WrenBind.util = SMODS.load_file("api/util.lua")()
WrenBind.pill_order = WrenBind.util.scramble(0,10)

local os = love.system.getOS()
local steamid = nil

local old_createuiblind = create_UIBox_blind_select
function create_UIBox_blind_select(skip_ani)
    if skip_ani then
        G.blind_prompt_box = UIBox{
            definition =
              {n=G.UIT.ROOT, config = {align = 'cm', colour = G.C.CLEAR, padding = 0.2}, nodes={
                {n=G.UIT.R, config={align = "cm"}, nodes={
                  {n=G.UIT.O, config={object = DynaText({string = localize('ph_choose_blind_1'), colours = {G.C.WHITE}, shadow = true, scale = 0.6, maxw = 5, silent=true}), id = 'prompt_dynatext1'}}
                }},
                {n=G.UIT.R, config={align = "cm"}, nodes={
                  {n=G.UIT.O, config={object = DynaText({string = localize('ph_choose_blind_2'), colours = {G.C.WHITE}, shadow = true, scale = 0.7, maxw = 5, silent = true}), id = 'prompt_dynatext2'}}
                }},
                (G.GAME.used_vouchers["v_retcon"] or G.GAME.used_vouchers["v_directors_cut"]) and
                UIBox_button({label = {localize('b_reroll_boss'), localize('$')..'10'}, button = "reroll_boss", func = 'reroll_boss_button'}) or nil
              }},
            config = {align="cm", offset = {x=0,y=0},major = G.HUD:get_UIE_by_ID('row_blind'), bond = 'Weak'}
        }
    
        local width = G.hand.T.w
        G.GAME.blind_on_deck = 
        not (G.GAME.round_resets.blind_states.Small == 'Defeated' or G.GAME.round_resets.blind_states.Small == 'Skipped' or G.GAME.round_resets.blind_states.Small == 'Hide') and 'Small' or
        not (G.GAME.round_resets.blind_states.Big == 'Defeated' or G.GAME.round_resets.blind_states.Big == 'Skipped'or G.GAME.round_resets.blind_states.Big == 'Hide') and 'Big' or 
        'Boss'
        
        G.blind_select_opts = {}
        G.blind_select_opts.small = G.GAME.round_resets.blind_states['Small'] ~= 'Hide' and UIBox{definition = {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={UIBox_dyn_container({create_UIBox_blind_choice('Small')},false,get_blind_main_colour('Small'))}}, config = {align="bmi", offset = {x=0,y=0}}} or nil
        G.blind_select_opts.big = G.GAME.round_resets.blind_states['Big'] ~= 'Hide' and UIBox{definition = {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={UIBox_dyn_container({create_UIBox_blind_choice('Big')},false,get_blind_main_colour('Big'))}}, config = {align="bmi", offset = {x=0,y=0}}} or nil
        G.blind_select_opts.boss = G.GAME.round_resets.blind_states['Boss'] ~= 'Hide' and UIBox{definition = {n=G.UIT.ROOT, config={align = "cm", colour = G.C.CLEAR}, nodes={UIBox_dyn_container({create_UIBox_blind_choice('Boss')},false,get_blind_main_colour('Boss'), mix_colours(G.C.BLACK, get_blind_main_colour('Boss'), 0.8))}}, config = {align="bmi", offset = {x=0,y=0}}} or nil
        
        local t = {n=G.UIT.ROOT, config = {align = 'tm',minw = width, r = 0.15, colour = G.C.CLEAR}, nodes={
        {n=G.UIT.R, config={align = "cm", padding = 0.5}, nodes={
            G.GAME.round_resets.blind_states['Small'] ~= 'Hide' and {n=G.UIT.O, config={align = "cm", object = G.blind_select_opts.small}} or nil,
            G.GAME.round_resets.blind_states['Big'] ~= 'Hide' and {n=G.UIT.O, config={align = "cm", object = G.blind_select_opts.big}} or nil,
            G.GAME.round_resets.blind_states['Boss'] ~= 'Hide' and {n=G.UIT.O, config={align = "cm", object = G.blind_select_opts.boss}} or nil,
        }}
        }}
        return t 
    end
    return old_createuiblind()
end

--[[
    "Borrowed" from Cryptid
]]
local files = NFS.getDirectoryItems(mod_path .. "Items")
print(#files.." files found to add!")
WrenBind.obj_buffer = {}
for _, file in ipairs(files) do
	print("Loading file " .. file)
	local f, err = SMODS.load_file("Items/" .. file)
	if err then
		print("Error loading file: " .. err)
	else
		local curr_obj = f()
        if curr_obj.init then
            curr_obj:init()
        end
        if not curr_obj.items then
            print("Warning: " .. file .. " has no items")
        else
            for _, item in ipairs(curr_obj.items) do
                if not item.order then
                    item.order = 0
                end
                if curr_obj.order then
                    item.order = item.order + curr_obj.order
                end
                if SMODS[item.object_type] then
                    if not WrenBind.obj_buffer[item.object_type] then
                        WrenBind.obj_buffer[item.object_type] = {}
                    end
                    WrenBind.obj_buffer[item.object_type][#WrenBind.obj_buffer[item.object_type] + 1] = item
                else
                    print("Error loading item " .. item.key .. " of unknown type " .. item.object_type)
                end
            end
        end
	end
end
for set, objs in pairs(WrenBind.obj_buffer) do
	table.sort(objs, function(a, b)
		return a.order < b.order
	end)
	for i = 1, #objs do
		if objs[i].post_process and type(objs[i].post_process) == "function" then
			objs[i]:post_process()
		end
		SMODS[set](objs[i])
	end
end

-- active item overrides
-- this was going to be too big for one file, so to save my eyes and everyone else's, it is now stored elsewhere.
local G_UIDEF_use_and_sell_buttons_ref = G.UIDEF.use_and_sell_buttons

--[[function G.FUNCS.can_roll_selected(e)
    local area = e.config.ref_table.area
    local mergable = 0
    for i = 1, #area.highlighted do
        if area.highlighted[i].ability.extra and type(area.highlighted[i].ability.extra) == "table" and area.highlighted[i].ability.extra.can_select then
            mergable = mergable + 1
            active_select_card = area.highlighted[i]
        end
    end
    if mergable == 1 then
        e.config.colour = G.C.DARK_EDITION
        e.config.button = "use_select_active"
    else
        e.config.colour = G.C.UI.BACKGROUND_INACTIVE
        e.config.button = nil
    end
end]]

--[[function G.FUNCS.use_select_active(e)
    e.config.ref_table.area:remove_from_highlighted(e.config.ref_table)
    G.E_MANAGER:add_event(Event({
        trigger = "after",
        delay = 1,
        func = function()
            local area = e.config.ref_table.area
            area:remove_card(e.config.ref_table)
            active_select_card:use()
            e.config.ref_table:remove()
            e.config.ref_table = nil
            return true
        end,
    }))
end]]

function G.UIDEF.use_and_sell_buttons(card)
    local m = G_UIDEF_use_and_sell_buttons_ref(card)  
    if
        card.area
        and card.area == G.jokers
        and card.ability.extra and type(card.ability.extra) == "table" and card.ability.extra.charges
    then
        -- borrowed from cryptid with permission!
        local use = {
            n = G.UIT.C,
            config = { align = "cr" },
            nodes = {
                {
                    n = G.UIT.C,
                    config = {
                        ref_table = card,
                        align = "cr",
                        maxw = 1.25,
                        padding = 0.1,
                        r = 0.2,
                        hover = true,
                        shadow = true,
                        colour = G.C.UI.BACKGROUND_INACTIVE,
                        one_press = false,
                        button = "nothing",
                        func = "can_roll",
                    },
                    nodes = {
                        { n = G.UIT.B, config = { w = 0.1, h = 0.3 } },
                        {
                            n = G.UIT.T,
                            config = {
                                text = "Use!",
                                colour = G.C.UI.TEXT_LIGHT,
                                scale = 0.3,
                                shadow = true,
                            },
                        }
                    },
                }
            },
        }
        local n = m.nodes[1]
        if not card.added_to_deck then
            use.nodes[1].nodes = { use.nodes[1].nodes[2] }
        end
        n.nodes = n.nodes or {}
        table.insert(n.nodes, {
            n = G.UIT.R,
            config = { align = "cl" },
            nodes = { use, }
        })
    end
    return m
end

-- overrides borrowed with permission from aura to allow for the charge sprites to be drawn over the jokers.
-- todo: these are not drawn over joker shaders for some reason?
local css = Card.set_sprites
function Card:set_sprites(c, f)
    css(self, c,f)
    if self.config.center and self.config.center.pos and self.config.center.pos.extra and self.config.center.pos.extra.atlas then
        if not self.children.front then
            self.children.front = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS[self.config.center.pos.extra.atlas], self.config.center.pos)
            self.children.front.states.hover = self.states.hover
            self.children.front.states.click = self.states.click
            self.children.front.states.drag = self.states.drag
            self.children.front.states.collide.can = false
            self.children.front:set_role({major = self, role_type = 'Glued', draw_major = self})
        else
            self.children.front:set_sprite_pos(self.config.center.pos.extra)
        end
    end
end

local cd = Card.draw
function Card:draw(layer)
    if self.config and self.config.center and self.config.center.pos and self.config.center.pos.extra and self.config.center.pos.extra.atlas then self:set_sprites() end
    cd(self,layer)
end

local cl = Card.load

function Card:load(cardTable, other_card)
    local scale = 1
    self.config = {}
    self.config.center_key = cardTable.save_fields.center
    self.config.center = G.P_CENTERS[self.config.center_key]
    self.params = cardTable.params
    self.sticker_run = nil

    local H = G.CARD_H
    local W = G.CARD_W
    if self.config.center.name == "Half Joker" then 
        self.T.h = H*scale/1.7*scale
        self.T.w = W*scale
    elseif self.config.center.name == "Wee Joker" then 
        self.T.h = H*scale*0.7*scale
        self.T.w = W*scale*0.7*scale
    elseif self.config.center.name == "Photograph" then 
        self.T.h = H*scale/1.2*scale
        self.T.w = W*scale
    elseif self.config.center.name == "Square Joker" then

        H = W 
        self.T.h = H*scale
        self.T.w = W*scale
    elseif self.config.center.set == 'Booster' then 
        self.T.h = H*1.27
        self.T.w = W*1.27
    else
        self.T.h = H*scale
        self.T.w = W*scale
    end
    self.VT.h = self.T.H
    self.VT.w = self.T.w

    self.config.card_key = cardTable.save_fields.card
    self.config.card = G.P_CARDS[self.config.card_key]
    self.no_ui = cardTable.no_ui
    self.base_cost = cardTable.base_cost
    self.extra_cost = cardTable.extra_cost
    self.cost = cardTable.cost
    self.sell_cost = cardTable.sell_cost
    self.facing = cardTable.facing
    self.sprite_facing = cardTable.sprite_facing
    self.flipping = cardTable.flipping
    self.highlighted = cardTable.highlighted
    self.debuff = cardTable.debuff
    self.rank = cardTable.rank
    self.added_to_deck = cardTable.added_to_deck
    self.label = cardTable.label
    self.playing_card = cardTable.playing_card
    self.base = cardTable.base
    self.sort_id = cardTable.sort_id
    self.bypass_discovery_center = cardTable.bypass_discovery_center
    self.bypass_discovery_ui = cardTable.bypass_discovery_ui
    self.bypass_lock = cardTable.bypass_lock

    

    self.ability = cardTable.ability
    self.pinned = cardTable.pinned
    self.edition = cardTable.edition
    self.seal = cardTable.seal

    if WrenBind.util.has_value(WrenBind.dice, self.config.center.key) then
        self.config.center.pos.extra.x = self.ability.extra.charges
    end

    remove_all(self.children)
    self.children = {}
    self.children.shadow = Moveable(0, 0, 0, 0)

    self:set_sprites(self.config.center, self.config.card)
end

function G.FUNCS.can_roll(e)
    if e.config.ref_table.ability.extra.charges >= e.config.ref_table.ability.extra.charge_max then
        e.config.colour = G.C.BLUE
        e.config.button = "roll"
        return
    end
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = "nothing"
end

function G.FUNCS.roll(e)
    e.config.ref_table.config.center.use(e.config.ref_table)
    return true
end

function G.FUNCS.nothing(e)
    return true
end

G.FUNCS.cycle_update = function(args)
    args = args or {}
    if args.cycle_config and args.cycle_config.ref_table and args.cycle_config.ref_value then
        args.cycle_config.ref_table[args.cycle_config.ref_value] = args.to_key
    end
end
-- Is not working? I don't know why...
SMODS.current_mod.config_tab = function()
    return {
        n=G.UIT.ROOT, config={align = "cm", padding = 0.05, colour = G.C.CLEAR}, 
        nodes={
            create_option_cycle({
                label="Which Version Are You Playing?", 
                ref_table=Wrenbind_config, 
                ref_value="IsaacVersion", 
                options={
                    1,
                    2,
                    3,
                    4,
                    5
                },
                current_option=Wrenbind_config.IsaacVersion,
                callback="cycle_update"
            }),
            create_option_cycle({
                label="Choose Your Isaac Save File",
                ref_table=Wrenbind_config, 
                current_option=Wrenbind_config.IsaacSaveFileNum,
                ref_value="IsaacSaveFileNum", 
                options={1,2,3},
                callback="cycle_update"
            }),
        }
    }
end