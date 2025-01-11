local mod_path = SMODS.current_mod.path
Wrenbind_config = SMODS.current_mod.config

WrenBind = {
    util = nil, pills_order = nil, 
    special_jokers = {
        j_wrenbind_holymantle = "Angel",
        j_wrenbind_brimstone = "Devil",
        j_wrenbind_coallump = "Devil",
        j_wrenbind_quarter = "Devil"
    }, chances = {
        devil = 0,
        angel = 0
    }, 
    ante = 1, 
    has_devil = false
}

WrenBind.find_joker = function(card)
    for i=1, #G.jokers.cards do if G.jokers.cards[i].config.center.name == card then return i end end
end

local lc = loc_colour
function loc_colour(_c, _default)
	if not G.ARGS.LOC_COLOURS then
		lc()
	end

    -- Custom Pool Colors
	G.ARGS.LOC_COLOURS.devil = HEX("ffd6c4")
    G.ARGS.LOC_COLOURS.devilbg = HEX("d40001")
    G.ARGS.LOC_COLOURS.angel =  HEX("fefefe")
    G.ARGS.LOC_COLOURS.angelbg =  HEX("8999d3")
	return lc(_c, _default)
end

SMODS.Language {
    key = "en-us",
    label = "English (USA)"
}

IS_GFUEL = false

function is_battery()
    for i=1, #G.jokers.cards do
        if G.jokers.cards[i].config.center.name == "wrenbind_thebattery" then
            return true
        end
    end
    return false
end

function charge_logic(card, add, is_mega)
    local charges = card.ability.extra.charges
    local charge_max = card.ability.extra.charge_max
    if add == nil then add = 1 end
    charges = charges + add 

    if is_battery() or is_mega then
        if charges > (charge_max * 2) and add ~= 1 then charges = charge_max * 2 end
        if charges < (card.ability.extra.charge_max*2) then
            play_sound("wrenbind_active_charge", 1, 1)
            card.ability.extra.charges = charges
            card.config.center.pos.extra.x = charges
        elseif charges ~= (card.ability.extra.charge_max*2)+1 then
            play_sound("wrenbind_active_charged", 1, 1)
            card.ability.extra.charges = (card.ability.extra.charge_max*2)
            card.config.center.pos.extra.x = (card.ability.extra.charge_max*2)
            WrenBind.util.alert_dice(card, "Charged!", 1)
        end
        return true
    end
    if charges > charge_max and add ~= 1 then charges = charge_max end
    if charges < card.ability.extra.charge_max then
        play_sound("wrenbind_active_charge", 1, 1)
        card.ability.extra.charges = charges
        card.config.center.pos.extra.x = charges
    elseif charges ~= (card.ability.extra.charge_max+1) then
        play_sound("wrenbind_active_charged", 1, 1)
        card.ability.extra.charges = card.ability.extra.charge_max
        card.config.center.pos.extra.x = card.ability.extra.charge_max
        WrenBind.util.alert_dice(card, "Charged!", 1)
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

SMODS.Atlas({
	key = "atlaspacks",
	path = "atlaspacks.png",
	px = 71,
	py = 95,
}):register()

SMODS.Atlas({
	key = "wrenbind_tags",
	path = "tags.png",
	px = 34,
	py = 34,
}):register()

WrenBind.util = SMODS.load_file("api/util.lua")()
SMODS.load_file("core/WrenbindCore.lua")().init()

local function calc_weight(pool)
    local x = 0
    for i=1, #G.jokers.cards do
        if WrenBind.util.has_value(pool, G.jokers.cards[i].config.center.name) then
            x = x + 1
        end
    end
    if x ~= #pool then
        return 0.075
    else
        return 0
    end
end

SMODS.Rarity {
    key = "q4",
    loc_txt = {
        name = "Quality 4"
    },
    badge_colour = HEX('ffd100'),
    default_weight = 0.075,
    pools = {["Joker"] = true},
    get_weight = function(self, weight, object_type)
        return calc_weight(WrenBind.q4)
    end,
}

SMODS.Rarity {
    key = "q3",
    loc_txt = {
        name = "Quality 3"
    },
    default_weight=0.085,
    badge_colour = HEX('ff54ec'),
    pools = {["Joker"] = true},
    get_weight = function(self, weight, object_type)
        return calc_weight(WrenBind.q3)
    end,
}

SMODS.Rarity {
    key = "q2",
    loc_txt = {
        name = "Quality 2"
    },
    default_weight=0.095,
    badge_colour = HEX('65d5ff'),
    pools = {["Joker"] = true},
    get_weight = function(self, weight, object_type)
        return calc_weight(WrenBind.q2)
    end,
}

SMODS.Rarity {
    key = "q0",
    loc_txt = {
        name = "Quality 0"
    },
    default_weight=0.1,
    badge_colour = HEX('c2c2c2'),
    pools = {["Joker"] = true},
    get_weight = function(self, weight, object_type)
        return calc_weight(WrenBind.q0)
    end,
}


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
            if curr_obj.quality then WrenBind[curr_obj.quality] = {} end
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
                    if curr_obj.quality then WrenBind[curr_obj.quality][#WrenBind[curr_obj.quality]+1] = item.name end -- custom logic to add pooling globally
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

local G_UIDEF_use_and_sell_buttons_ref = G.UIDEF.use_and_sell_buttons

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

local css = Card.set_sprites
function Card:set_sprites(c, f)
    css(self, c,f)
    if self.config.center and self.config.center.pos and self.config.center.pos.extra and self.config.center.pos.extra.atlas then
        if not self.children.charges then
            self.children.charges = Sprite(self.T.x, self.T.y, self.T.w, self.T.h, G.ASSET_ATLAS[self.config.center.pos.extra.atlas])
            self.children.charges.states.hover = self.states.hover
            self.children.charges.states.click = self.states.click
            self.children.charges.states.drag = self.states.drag
            self.children.charges.states.collide.can = false
            self.children.charges:set_role({major = self, role_type = 'Glued', draw_major = self})
        else
            self.children.charges:set_sprite_pos(self.config.center.pos.extra)
        end
    end
end

local old_reset = reset_blinds
function reset_blinds()
    if G.GAME.round_resets.blind_states.Boss == 'Defeated' then
        WrenBind.ante = WrenBind.ante + 1
        if (WrenBind.ante == 2) then
            WrenBind.chances.devil = 1.0
        end
        if WrenBind.chances.devil ~= 1 and WrenBind.chances.angel ~= 1 and WrenBind.ante ~= 2 then
            if not WrenBind.has_devil then
                WrenBind.chances.angel = WrenBind.chances.angel + 0.15
            else
                WrenBind.chances.devil = WrenBind.chances.devil + 0.15
            end
        end
    end
    old_reset()
end

local old_pack = get_pack

function get_pack(_key, _type)
    local chance = pseudorandom(pseudoseed(_key))
    if (chance ~= 0) then
        if (chance <= WrenBind.chances.devil) then
            WrenBind.chances.devil = 0
            WrenBind.chances.angel = 0
            play_sound("wrenbind_devilappear", 1, 0.5)
            return G.P_CENTERS['p_wrenbind_devil_'..1]--(math.random(1, 2))
            
        elseif (chance <= WrenBind.chances.angel) then
            WrenBind.chances.devil = 0
            WrenBind.chances.angel = 0
            play_sound("wrenbind_angelappear", 1, 0.5)
            return G.P_CENTERS['p_wrenbind_angel_'..1]
        end
    end
    return old_pack(_key, _type)
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

function Game:update_new_round(dt)
    if self.buttons then self.buttons:remove(); self.buttons = nil end
    if self.shop then self.shop:remove(); self.shop = nil end

    if not G.STATE_COMPLETE then
        local card = WrenBind.find_joker("wrenbind_holymantle")
        if card ~= nil then
            card = G.jokers.cards[card]
            if card.ability.extra.active and G.GAME.current_round.hands_left == 0 then
                G.STATE = G.STATES.DRAW_TO_HAND
                card.ability.extra.active = false
                ease_hands_played(1)
                ease_discard(1)
                play_sound("wrenbind_mantle_shatter")
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = "Safe!"})
                return true
            end
        end
        for i=1, #G.jokers.cards do
            local card = G.jokers.cards[i]
            if card.ability and card.ability.extra ~= nil and type(card.ability.extra) == "table" and card.ability.extra.charges ~= nil then
                charge_logic(card)
            end
        end
        G.STATE_COMPLETE = true
        end_round()
    end
end

G.FUNCS.cycle_update = function(args)
    args = args or {}
    if args.cycle_config and args.cycle_config.ref_table and args.cycle_config.ref_value then
        args.cycle_config.ref_table[args.cycle_config.ref_value] = args.to_key
    end
end

-- todo: force skip banned pools unless if they are forced pools (i.e. no angel items unless if we forced angel pool)