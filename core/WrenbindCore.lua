return {
    init = function()
        function WrenBind.ActiveJoker(args)
            local x = {
                object_type = "Joker",
                name = "wrenbind_"..args.name,
                key = args.name,
                loc_txt = {
                    name = args.loc_txt.name,
                    text = args.loc_txt.text
                },
                loc_vars = function(self, info_queue, center)
                    info_queue[#info_queue + 1] = { set = "Other", key = "wrenbind_activejoker" }
                end,
                config = {extra = {charges = args.charges, charge_max = args.charges}}, 
                atlas = args.atlas,
                pos = { x = args.pos.x, y = args.pos.y, extra = {x = args.charges, y = 5-args.charges, atlas="wrenbind_charge"} },
                rarity = args.rarity,
                cost = args.cost,
                added_to_deck = init_logic,
                remove_from_deck = init_logic, 
                use = args.use
            }
            if args.soul_pos then
                x.soul_pos = args.soul_pos
            end
            if args.loc_vars then
                x.loc_vars = args.loc_vars
            end
            return x
        end
    end
}