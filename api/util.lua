local function split(pString, pPattern)
    local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pPattern
    local last_end = 1
    local s, e, cap = pString:find(fpat, 1)
    while s do
       if s ~= 1 or cap ~= "" then
      table.insert(Table,cap)
       end
       last_end = e+1
       s, e, cap = pString:find(fpat, last_end)
    end
    if last_end <= #pString then
       cap = pString:sub(last_end)
       table.insert(Table, cap)
    end
    return Table
end

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local function alert_dice(card, message, duration)
    attention_text({
        text = message,
        scale = 0.5, 
        hold = duration,
        backdrop_colour = G.C.MULT,
        align = "bm",
        major = card,
        offset = {x = 0, y = 0.05*card.T.h}
    })
end

local charges = {
    ["6"]= 1,
    ["4"] = 2,
    ["2"]= 3,
    ["1"] = 4
}

local function draw_charge(card, hold, charge) 
    card.children.charge = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS['wrenbind_charge'], {x=charge, y=charges[tostring(hold)]})
    card.children.charge.states.hover = card.states.hover
    card.children.charge.states.click = card.states.click
    card.children.charge.states.drag = card.states.drag
    card.children.charge.states.collide.can = false
    card.children.charge:set_role({major = card, role_type = 'Glued', draw_major = card})
    card.children.charge:draw()
    print("i should've drawn by now...")
end

local foley_num = {
    dice = 5
}

local function play_foley(type, vol)
    play_sound("wrenbind_foley_"..type..love.math.random(1,foley_num[type]), 1, vol)
end

return {
    split = split,
    has_value = has_value,
    alert_dice = alert_dice,
    play_foley = play_foley,
    draw_charge = draw_charge
}
 