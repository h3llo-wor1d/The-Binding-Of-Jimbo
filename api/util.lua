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

local function scramble(min, max)
    local numbers = {}
    local scrambled = {}

    for i = min, max do
        table.insert(numbers, i)
    end

    math.randomseed(os.time())

    while #numbers > 0 do
        local index = math.random(#numbers)
        table.insert(scrambled, numbers[index])
        table.remove(numbers, index)
    end

    return scrambled
end

local function has_joker(j_key)
    for i=1, #G.jokers.cards do
        print(G.jokers.cards[i].config.center.key)
        if G.jokers.cards[i].config.center.key == j_key then
            return true
        end
    end
    return false
end

local function find_joker(j_key)
    for i=1, #G.jokers.cards do
        if G.jokers.cards[i].config.center.name == j_key then
            return G.jokers.cards[i]
        end
    end
    return false
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
    if tab then
        for index, value in ipairs(tab) do
            if value == val then
                return true
            end
        end
    end

    return false
end

local function deck_joker(vars)
    local c = create_card('Joker', G.jokers, nil, nil, nil, nil, "j_"..vars.joker, "wbin")
    c:start_materialize(nil, true)
    c:add_to_deck()
    if vars.eternal then
        c:set_eternal(true)
    end
    if vars.negative then
        c:set_edition({negative = true}, nil, true)
    end
    G.jokers:emplace(c)
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
    reroll_tags = reroll_tags,
    scramble = scramble,
    deck_joker = deck_joker,
    has_joker = has_joker,
    find_joker = find_joker
}
 