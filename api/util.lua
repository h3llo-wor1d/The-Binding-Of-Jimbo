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

local function reroll_tags ()
    G.GAME.round_resets.blind_tags.Small = get_next_tag_key()
    G.GAME.round_resets.blind_tags.Big = get_next_tag_key()
    if G.STATE ~= G.STATES.BLIND_SELECT then return end
    G.blind_prompt_box:remove()
    G.blind_select:remove()
    G.blind_select = UIBox{
        definition = create_UIBox_blind_select(true),
        config = {align="bmi", offset = {x=0,y=G.ROOM.T.y + 29},major = G.hand, bond = 'Weak'}
    }
    G.blind_select.alignment.offset.y = 0.8-(G.hand.T.y - G.jokers.T.y) + G.blind_select.T.h
    G.blind_select.alignment.offset.x = 0
    save_run()
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
    reroll_tags = reroll_tags
}
 