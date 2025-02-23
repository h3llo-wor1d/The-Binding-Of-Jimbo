local TMTrainerParent = {

}

function getNestedValue(context, keys)
    local value = context
    for _, key in ipairs(keys) do
        if type(value) == "table" and value[key] then
            value = value[key]
        else
            return nil -- Return nil if any key is missing
        end
    end
    return value
end

function shuffle(str)
    math.randomseed(os.time())
    -- Convert string to a table of characters
    local chars = {}
    for char in str:gmatch(".") do
        table.insert(chars, char)
    end

    -- Fisher-Yates shuffle algorithm
    for i = #chars, 2, -1 do
        local j = math.random(i)
        chars[i], chars[j] = chars[j], chars[i]  -- Swap elements
    end

    -- Convert table back to string
    return table.concat(chars)
end

-- Types
-- 1: context
-- 2: G.{var}

local TMTriggers = {
    { { 1, {"ending_shop"} } },
    { { 1, { "other_card", "lucky_trigger" } }, { 1, { "individual" } } }
}

local TMTypes = {
    [2] = function() return G end
}

local TMEffects = {
    function (self,card,context)
        local me = card
        local eligibleJokers = {}
        for i = 1, #G.consumeables.cards do
            if G.consumeables.cards[i].ability.consumeable then
                eligibleJokers[#eligibleJokers + 1] = G.consumeables.cards[i]
            end
        end
        if #eligibleJokers > 0 then
            G.E_MANAGER:add_event(Event({
                func = function() 
                    local card = copy_card(pseudorandom_element(eligibleJokers, pseudoseed('perkeo')), nil)
                    card:set_edition({negative = true}, true)
                    card:add_to_deck()
                    G.consumeables:emplace(card) 
                    return true
                end}))
            card_eval_status_text(me, 'extra', nil, nil, nil, {message = shuffle(localize('k_duplicated_ex'))})
            return nil, true
        end
        return nil
    end
}

function TMAlgo(self, card, context)
    local boolvar = 0
    for i=1, #TMTriggers[card.ability.extra.trigger] do
        if TMTriggers[card.ability.extra.trigger][i][1] == 1 and getNestedValue(context, TMTriggers[card.ability.extra.trigger][i][2]) then boolvar = boolvar + 1 end
        if TMTriggers[card.ability.extra.trigger][i][1] ~= 1 then
            if getNestedValue(TMTypes[TMTriggers[card.ability.extra.trigger][i][1]], TMTriggers[card.ability.extra.trigger][i][2]) then
                boolvar = boolvar + 1
            end
        end
    end
    return boolvar == #TMTriggers[card.ability.extra.trigger]
end

local TMTrainerChild = {
    object_type="Joker",
    name="wrenbind_tmtrainerchild",
    key="tmtrainerchild",
    loc_txt={
        name="TMTRAINER CHILD",
        text = {
            "\"This is gonna suck\"",
        }
    },
    config = {
        extra = {
            stored_vars = {},
            effect = 0,
            trigger = 0,
        }
    },
    atlas = "atlasone",
    pos = { x = 0, y = 0 },
    draw = function(self, card, layer)
        card.children.center:draw_shader('wrenbind_tmtrainer',nil, card.ARGS.send_to_shader)
    end,
    add_to_deck = function(self,card,context)
        local trigger = math.floor(pseudorandom('TMTriggers') * #TMTriggers) + 1
        card.ability.extra.trigger = (trigger < #TMTriggers and trigger or #TMTriggers)
        local effect = math.floor(pseudorandom('TMEffect') * #TMEffects) + 1
        card.ability.extra.effect = (effect < #TMEffects and effect or #TMEffects)
        print("Local settings made for new TMTrainer!")
        print("Trigger set to "..card.ability.extra.trigger)
        print("Effect set to "..card.ability.extra.effect)
    end,
    calculate = function(self,card,context)
        if TMAlgo(self,card,context) then
            local request = TMEffects[card.ability.extra.effect](self,card,context)
            if request ~= nil then return request end
        end
    end
}

return {
    name = "TMTRAINER",
    quality = "q0",
    items = {
        TMTrainerChild
    }
}