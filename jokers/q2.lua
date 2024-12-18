local TheBattery = {
    -- this joker doesn't work for some reason...
    object_type="Joker",
    name="wrenbind_thebattery",
    key="thebattery",
    loc_txt={
        name="The Battery",
        text = {
            "All {C:attention}Active Jokers{} may be charged twice."
        }
    },
    atlas = "atlasone",
    pos = { x = 0, y = 0 },
    rarity = "wrenbind_q2", -- todo: custom rarities, add quality 0
    cost = 8
}


return {
    name = "Quality 2 Jokers",
    items = {
        TheBattery
    }
}