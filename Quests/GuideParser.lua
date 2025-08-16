--[[
Vanilla Guide Reloaded

Author: Grommey (originally by mrmr)

Description:
Parse the special commands of the guides.
Part of the Vanilla Guide Reloaded addon.
]]--

GuideParser = {}
GuideParser.__index = GuideParser

function GuideParser:new()
    local obj = {}
    setmetatable(obj, self)

    if type(string.match) ~= "function" then
        string.match = function(s, pattern)
            return string.gfind(s, pattern)() -- fallback 1.12
        end
    end

    obj.Parse = function(self, text)
        local x, y, z = nil, nil, nil
        text = self:SimpleCommand(text)
        text = self:ClassCommand(text)
        text = self:Experience(text)
        text = self:GroupQuest(text)
        -- text = self:ClickableLink(text)
        text, x, y, z = self:CheckPNJ(text, x, y, z)
        text, x, y, z = self:Quest(text, x, y, z)
        text, x, y, z = self:GoTo(text, x, y, z)
        return text, x, y, z
    end

    obj.Quest = function(self, text, x, y, z)

        local dialect = {
            ["A"] = {
                ["search"] = "start",
                ["color"]  = "0000ffff",
            },
            ["C"] = {
                ["search"] = "",
                ["color"]  = "000079d2",
            },
            ["T"] = {
                ["search"] = "end",
                ["color"]  = "0000ff00",
            },
        }

        local lX, lY, lZ = x, y, z
        local rep = text

        if not VGDB or not VGDB["quests"] or not VGDB["quests"]["enUS"] then 
            return text, lX, lY, lZ 
        end

        rep = string.gsub(rep, "%[Q([ACT])(%d+)%s*(.-)%]", function(type, id, name)
            type = tostring(type)
            id = tonumber(id)

            local coords = {}

            -- Get QuestID
            local questLocalized = VGDB["quests"]["enUS"][id]
            local name = questLocalized and questLocalized["T"] or ("Quest "..id)

            -- Get Coords
            local quest = VGDB["quests"]["data"][id]
            local dialectType = dialect[type]
            
            if dialectType["search"] == "start" or dialectType["search"] == "end" then
               local startOrStop = quest and quest[dialectType["search"]] or {}
               local startOrStopId = nil

               if startOrStop["U"] then
                   startOrStopId = startOrStop["U"][1]
                   coords = VGDB["units"]["data"][startOrStopId] and VGDB["units"]["data"][startOrStopId]["coords"] and VGDB["units"]["data"][startOrStopId]["coords"][1] or {}
               elseif startOrStop["O"] then
                   startOrStopId = startOrStop["O"][1]
                   coords = VGDB["objects"]["data"][startOrStopId] and VGDB["objects"]["data"][startOrStopId]["coords"] and VGDB["objects"]["data"][startOrStopId]["coords"][1] or {}
               end

            elseif dialectType["search"] == "" then
                local item = {}
                local typeOfObject = quest and quest["obj"] or nil

                if typeOfObject ~= nil then
                    for id, key in pairs(typeOfObject) do
                        if id == "I" then
                            local itemId = typeOfObject[id][1]
                            if VGDB["items"]["data"][itemId]["U"] then
                                units =  VGDB["items"]["data"][itemId]["U"] or {}
                                for id, key in pairs(units) do
                                    coords = VGDB["units"]["data"][id]["coords"] and VGDB["units"]["data"][id]["coords"][1] or {}
                                    if coords ~= {} then
                                        break
                                    end
                                end
                            elseif VGDB["items"]["data"][itemId]["O"] then
                                items =  VGDB["items"]["data"][itemId]["O"] or {}
                                for id, key in pairs(items) do
                                    coords = VGDB["objects"]["data"][id]["coords"] and VGDB["objects"]["data"][id]["coords"][1] or {}
                                    if coords ~= {} then
                                        break
                                    end
                                end
                            end
                        elseif id == "U" then
                            local unitId = typeOfObject[id][1]
                            if VGDB["units"]["data"][unitId]["coords"] then
                                coords = VGDB["units"]["data"][unitId]["coords"][1]
                            end
                        elseif id == "A" then
                            local areaTriggerId = typeOfObject[id][1]
                            if VGDB["areatrigger"]["data"][areaTriggerId]["coords"] then
                                coords = VGDB["areatrigger"]["data"][areaTriggerId]["coords"][1]
                            end
                        end
                    end

                end
            end

            lX = coords and coords[1] or nil
            lY = coords and coords[2] or nil

            -- Get Zonename for TomTom ...
            lZ = coords and coords[3] or nil
            if VGDB["zones"] and VGDB["zones"]["enUS"] and lZ then
                lZ = VGDB["zones"]["enUS"][lZ]
            end

            return string.format("%s", "|c" .. dialectType["color"] .. name .. "|r")
            
        end)

        return rep, lX, lY, lZ
    end

    -- Simple Commands
    obj.SimpleCommand = function(self, text)
        local dialect = {
            ["H"] = { ["text"] = "[*] %s" },
            ["S"] = { ["text"] = "[#] %s" },
            ["F"] = { ["text"] = "[>] %s" },
            ["P"] = { ["text"] = "[+] %s" },
            ["T"] = { ["text"] = "[!]"},
            ["V"] = { ["text"] = "Vendor "},
            ["R"] = { ["text"] = "Repair "},
        }

        local rep = string.gsub(text, "%[([HSFPTVR])%s?(.-)%]", function(type, text)
            if type == "V" or type == "R" or type == "T" then
                return string.format(dialect[type]["text"])
            end
            return string.format(dialect[type]["text"], text)
        end)

        return rep

    end

    -- Class Commands (Keep only if good class)
    obj.ClassCommand = function(self, text)
        local lines = {}
        for line in string.gfind(text, "([^\n]+)") do
            table.insert(lines, line)
        end
    
        local newLines = {}
        local playerClass = string.lower(UnitClass("player"))
        local playerRace = string.lower(UnitRace("player"))
    
        for _, line in ipairs(lines) do
            local classRaceTags = string.match(line, "%[A ([^%]]+)%]")
            if classRaceTags then
                for classRaceTag in string.gfind(classRaceTags, "([^,]+)") do

                    classRaceTag = string.gsub(classRaceTag, "%s+", "")
                    classRaceTag = string.lower(classRaceTag)

                    if string.lower(classRaceTag) == playerClass then
                        -- Class
                        line = string.gsub(line, "%[A " .. classRaceTags .. "%]", "")
                        table.insert(newLines, line)
                    elseif string.lower(classRaceTag) == playerRace then
                        -- Race
                        line = string.gsub(line, "%[A " .. classRaceTags .. "%]", "")
                        table.insert(newLines, line)
                    end

                end
            else
                table.insert(newLines, line) -- keep lines without any [A xxx]
            end
        end
    
        return table.concat(newLines, "\n")
    end

    -- Search for PNJ coords
    obj.CheckPNJ = function(self, text, x, y, z)
        local lX, lY, lZ = x, y, z

        local rep = string.gsub(text, "%[PNJ (.-)%]", function(name)
            lX, lY, lZ = GetPnjLocation(name)
            return string.format("|c00ff00ff" .. name .. "|r")
        end)

        return rep, lX, lY, lZ
    end

    -- Goto
    obj.GoTo = function(self, text, x, y, z)
        local lX, lY, lZ = x, y, z

        local rep = string.gsub(text, "%[G%s*(%d+%.?%d*),%s*(%d+%.?%d*)%s*(.-)%]", function(x, y, z)
            
            lX = x
            lY = y
            lZ = z

            return "|c00ffff00" .. z .. "|r"
        end)

        return rep, lX, lY, lZ
    end

    -- XP
    obj.Experience = function(self, text)
        local rep = string.gsub(text, "%[XP(%d*)%-?(%d*)%s+([%a%d%s]*)%]", function(level, xp, text)
            local currentLevel = UnitLevel("player")
            local currentXP = UnitXP("player")

            return text

        end)
        
        return rep
    end

    -- Group Quests
    obj.GroupQuest = function(self, text)
        local rep = string.gsub(text, "%[GROUP(%d+%+?)%]", function(number)
            return string.format("|c00ff0000GROUP %s|r", number)
        end)

        return rep
    end

    -- Clickable Link
    -- obj.ClickableLink = function(self, text)
    --     local rep = string.gsub(text, "%[CLICK%s+([%w_%-]+)%s+([%w%s%-%.%,%'%:%(%)]+)%]", function(guideID, displayText)
    --         local linkText = string.format("|cffffff00Click to load the guide: %s|r", displayText)
    --         return string.format("|Hvgload:%s|h%s|h", guideID, linkText)
    --     end)
    --     return rep
    -- end

    return obj
end
