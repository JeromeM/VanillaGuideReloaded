VGDB = VGDB or {}

function GetPnjLocation(name)
    local x, y, z = nil, nil, nil

    if not VGDB or not VGDB["units"] or not VGDB["units"]["enUS"] then 
        return nil, nil, nil 
    end

    for id, data in pairs(VGDB["units"]["enUS"]) do
        if string.lower(data) == string.lower(name) then
            coords = VGDB["units"]["data"][id] and VGDB["units"]["data"][id]["coords"] and VGDB["units"]["data"][id]["coords"][1] or {}
        
            x = coords[1] or nil
            y = coords[2] or nil

            -- Get Zonename for TomTom ...
            if VGDB["zones"] and VGDB["zones"]["enUS"] and coords[3] then
                z = VGDB["zones"]["enUS"][coords[3]]
            end

            return x, y, z
        end
    end

    return nil, nil, nil
end