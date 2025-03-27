-- ZoneMapIDs.lua
ZoneMapIDs = ZoneMapIDs or {}

-- Table de base avec mapID et continentID (zoneIndex sera défini dynamiquement)
local db = {
    -- Kalimdor (continentID = 1)
    ["Ashenvale"] = { mapID = 331, continentID = 1 },
    ["Azshara"] = { mapID = 16, continentID = 1 },
    ["Barrens"] = { mapID = 17, continentID = 1 },
    ["Darkshore"] = { mapID = 148, continentID = 1 },
    ["Darnassis"] = { mapID = 1657, continentID = 1 }, -- Darnassus
    ["Desolace"] = { mapID = 405, continentID = 1 },
    ["Durotar"] = { mapID = 14, continentID = 1 },
    ["Dustwallow"] = { mapID = 15, continentID = 1 },
    ["Felwood"] = { mapID = 361, continentID = 1 },
    ["Feralas"] = { mapID = 357, continentID = 1 },
    ["Moonglade"] = { mapID = 493, continentID = 1 },
    ["Mulgore"] = { mapID = 215, continentID = 1 },
    ["Ogrimmar"] = { mapID = 1637, continentID = 1 },
    ["Silithus"] = { mapID = 1377, continentID = 1 },
    ["StonetalonMountains"] = { mapID = 406, continentID = 1 },
    ["Tanaris"] = { mapID = 440, continentID = 1 },
    ["Teldrassil"] = { mapID = 141, continentID = 1 },
    ["ThousandNeedles"] = { mapID = 400, continentID = 1 },
    ["ThunderBluff"] = { mapID = 1638, continentID = 1 },
    ["UngoroCrater"] = { mapID = 490, continentID = 1 },
    ["Winterspring"] = { mapID = 618, continentID = 1 },
    -- Eastern Kingdoms (continentID = 2)
    ["Alterac"] = { mapID = 36, continentID = 2 },
    ["Arathi"] = { mapID = 45, continentID = 2 },
    ["Badlands"] = { mapID = 3, continentID = 2 },
    ["BlastedLands"] = { mapID = 4, continentID = 2 },
    ["BurningSteppes"] = { mapID = 46, continentID = 2 },
    ["DeadwindPass"] = { mapID = 41, continentID = 2 },
    ["DunMorogh"] = { mapID = 1, continentID = 2 },
    ["Duskwood"] = { mapID = 10, continentID = 2 },
    ["EasternPlaguelands"] = { mapID = 139, continentID = 2 },
    ["Elwynn"] = { mapID = 12, continentID = 2 },
    ["Hilsbrad"] = { mapID = 267, continentID = 2 },
    ["Hinterlands"] = { mapID = 47, continentID = 2 },
    ["Ironforge"] = { mapID = 1537, continentID = 2 },
    ["LochModan"] = { mapID = 38, continentID = 2 },
    ["Redridge"] = { mapID = 44, continentID = 2 },
    ["SearingGorge"] = { mapID = 51, continentID = 2 },
    ["Silverpine"] = { mapID = 130, continentID = 2 },
    ["Stormwind"] = { mapID = 1519, continentID = 2 },
    ["Stranglethorn"] = { mapID = 33, continentID = 2 },
    ["SwampOfSorrows"] = { mapID = 8, continentID = 2 },
    ["Tirisfal"] = { mapID = 85, continentID = 2 },
    ["Undercity"] = { mapID = 1497, continentID = 2 },
    ["WesternPlaguelands"] = { mapID = 28, continentID = 2 },
    ["Westfall"] = { mapID = 40, continentID = 2 },
    ["Wetlands"] = { mapID = 11, continentID = 2 },
}

-- Initialiser ZoneMapIDs avec les données de base
for zoneName, data in pairs(db) do
    ZoneMapIDs[zoneName] = data
end

-- Mettre à jour les zoneIndex dynamiquement
local function UpdateZoneIndexes()
    local zoneNamesByContinent = {
        [1] = {GetMapZones(1)}, -- Kalimdor
        [2] = {GetMapZones(2)}, -- Eastern Kingdoms
    }
    for continentID, zoneNames in pairs(zoneNamesByContinent) do
        for index, zoneName in ipairs(zoneNames) do
            for dbZoneName, data in pairs(ZoneMapIDs) do
                -- Utiliser string.lower explicitement pour éviter toute ambiguïté
                if data.continentID == continentID and string.lower(zoneName) == string.lower(dbZoneName) then
                    data.zoneIndex = index
                    break
                end
            end
        end
    end
end

-- Appeler la mise à jour au chargement
UpdateZoneIndexes()

function ZoneMapIDs:GetMapID(zoneName)
    local data = self[zoneName]
    if data then return data.mapID end
    return nil
end

function ZoneMapIDs:GetContinentID(zoneName)
    local data = self[zoneName]
    if data then return data.continentID end
    return nil
end

function ZoneMapIDs:GetZoneIndex(zoneName)
    local data = self[zoneName]
    if data then return data.zoneIndex end
    return nil
end