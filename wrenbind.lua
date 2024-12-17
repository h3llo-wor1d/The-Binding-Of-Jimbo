--- STEAMODDED HEADER
--- MOD_NAME: The Binding Of Jimbo
--- MOD_ID: balatro_binding
--- PREFIX: wrenbind
--- MOD_AUTHOR: [Wrench]
--- MOD_DESCRIPTION: Adds 50+ new jokers and items based on the Binding Of Isaac by Edmund McMillen
--- BADGE_COLOUR: 708b91
--- DEPENDENCIES: [Steamodded>=1.0.0~ALPHA-0917a]
--- VERSION: 0.0.1a
--- PRIORITY: 99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999

----------------------------------------------
------------MOD CODE -------------------------
local mod_path = "" .. SMODS.current_mod.path
Wrenbind_config = SMODS.current_mod.config

WrenBind = {
    logic = {},
    can_roll = {
        d20 = true,
        d6 = true,
        d4 = true
    },
    dice = {
        "j_wrenbind_d20",
        "j_wrenbind_d4"
    },
    is_active = {
        polyphemus=true
    },
    globals = {
        cursed_eye = {count = 0}
    }
}

SMODS.Sound:register_global()

SMODS.Atlas({
	key = "atlasone",
	path = "atlasone.png",
	px = 71,
	py = 95,
}):register()

--[[ scrapped for now- desync issues
SMODS.Sound {
    key = "music_main",
    path = "main.ogg",
    replace = "music1",
    pitch = 1,
    sync = true
}

SMODS.Sound {
    key = "music_arcana",
    path = "arcana.ogg",
    replace = "music2",
    pitch = 1,
    sync = true
}
SMODS.Sound {
    key = "music_celestial",
    path = "celestial.ogg",
    replace = "music3",
    pitch = 1,
    sync = true
}
SMODS.Sound {
    key = "music_shop",
    path = "shop.ogg",
    replace = "music4",
    pitch = 1,
    sync = true
}
SMODS.Sound {
    key = "music_boss",
    path = "boss.ogg",
    replace = "music5",
    pitch = 1,
    sync = true
}
]]

local irp = SMODS.load_file("api/isaac.lua")() -- todo: load everything into an array that can be read instead of individually loading modules
WrenBind.util = SMODS.load_file("api/util.lua")()

local os = love.system.getOS()
local steamid = nil

--[[
    "Borrowed" from Cryptid
]]

local files = NFS.getDirectoryItems(mod_path .. "jokers")
WrenBind.obj_buffer = {}
for _, file in ipairs(files) do
	print("Loading file " .. file)
	local f, err = SMODS.load_file("jokers/" .. file)
	if err then
		print("Error loading file: " .. err)
	else
		local curr_obj = f()
        if curr_obj.init then
            curr_obj:init()
        end
        if curr_obj.logic then
            for key, val in pairs(curr_obj.logic) do
                print("Initialized logic for "..key)
                WrenBind.logic[key] = val
            end
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

--[[
if os == "Windows" then
    -- logic to find isaac directory (i had multiple users on my pc so i'm trying to guesstimate the user's id)
    local users = NFS.getDirectoryItems("C:\\Program Files (x86)\\Steam\\userdata\\")

    for i=1, #users do
        for _, value in ipairs(NFS.getDirectoryItems("C:\\Program Files (x86)\\Steam\\userdata\\"..users[i])) do
            if value == "250900" then
                steamid = users[i]
                break
            end
        end
    end
end
]]

if steamid ~= nil then
    -- only register these jokers and data if you have isaac on steam
    local irp_dat = irp.read("C:\\Program Files (x86)\\Steam\\userdata\\"..steamid.."\\250900\\remote\\rep+persistentgamedata1.dat")
    
    local irp_sec = irp.getSecrets(irp_dat)

    WrenBind.isaac = {
        donations = irp.getInt(irp_dat, irp.getSectionOffsets(irp_dat)[2] + 0x4 + 0x4C),
        deadgod = irp_sec[#irp_sec],
        streak = irp.getInt(irp_dat, irp.getSectionOffsets(irp_dat)[2] + 0x4 + 0x54)
    }

    if WrenBind.isaac.streak < 0 then
        WrenBind.isaac.streak = 0
    end

    SMODS.Joker {
        key = 'save',
        loc_txt = {
          name = 'Save!',
          text = {
            "This Joker gains",
            "{C:mult}+1{} Mult per {C:attention}Win{} in your",
            "{C:mult}Binding of Isaac{} Win Streak",
            "currently {X:mult}+"..WrenBind.isaac.streak.."{} Mult"
          }
        },
        rarity = 2,
        atlas = 'atlasone',
        config = { extra = { mult = WrenBind.isaac.streak } },
        pos = { x = 3, y = 0 },
        cost = 4,
        calculate = function(self, card, context)
            if context.joker_main then
                return {
                  mult_mod = card.ability.extra.mult,
                  message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } }
                }
            end
        end
    }
end

-- dice overrides
local G_UIDEF_use_and_sell_buttons_ref = G.UIDEF.use_and_sell_buttons
function G.UIDEF.use_and_sell_buttons(card)
    local m = G_UIDEF_use_and_sell_buttons_ref(card)
    if
        card.area
        and card.area == G.jokers
        and WrenBind.util.has_value(WrenBind.dice, card.config.center.key)
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
                        r = 0.05,
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
                                text = "Roll",
                                colour = G.C.UI.TEXT_LIGHT,
                                scale = 0.3,
                                shadow = true,
                            },
                        },
                    },
                },
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

function G.FUNCS.can_roll(e)
    local d = WrenBind.util.split(e.config.ref_table.ability.name, "_")
    if WrenBind.can_roll[d[#d]] then
        e.config.colour = G.C.BLUE
        e.config.button = "roll"
        return
    end
    e.config.colour = G.C.UI.BACKGROUND_INACTIVE
    e.config.button = "nothing"
end

function G.FUNCS.roll(e)
    local d = WrenBind.util.split(e.config.ref_table.ability.name, "_")
    WrenBind.logic[d[#d]](e.config.ref_table)
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
----------------------------------------------
------------MOD CODE END----------------------