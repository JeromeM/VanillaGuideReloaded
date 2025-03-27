--[[--------------------------------------------------
----- VanillaGuide -----
------------------
GuideTable.lua
Authors: mrmr, Grommey
Version: 2.0
------------------------------------------------------
Description: 
    Guide table management for VanillaGuide
    2.0
        -- Refactored to integrate with VGuide
        -- Removed objGuideTable, methods attached to VGuide
------------------------------------------------------]]

function VGuide:InitializeGuideTable(oSettings)
    local function TablesMerge(t1, t2)
        for k, v in pairs(t2) do
            if (type(v) == "table") and (type(t1[k] or false) == "table") then
                TablesMerge(t1[k], t2[k])
            else
                t1[k] = v
            end
        end
        return t1
    end

    local function ColorizeTable(t1)
		for k1, _ in pairs(t1) do
			if type(t1[k1].items) == "table" then
				for k2, v2 in pairs(t1[k1].items) do
					if v2 then
						local opentext = {
							[1] = {["find"] = "#GET", ["replace"] = "|c0000ffff"},
							[2] = {["find"] = "#DO", ["replace"] = "|c000079d2"},
							[3] = {["find"] = "#IN", ["replace"] = "|c0000ff00"},
							[4] = {["find"] = "#NPC", ["replace"] = "|c00ff00ff"},
							[5] = {["find"] = "#COORD", ["replace"] = "|c00ffff00"},
							[6] = {["find"] = "#VIDEO", ["replace"] = "|c00ff0000"},
							[7] = {["find"] = "#ITEM", ["replace"] = "|c00fca742"},
							[8] = {["find"] = "#SKIP", ["replace"] = "|c00a80000"},
						}
						for n = 1, getn(opentext) do
							t1[k1].items[k2].str = gsub(t1[k1].items[k2].str, opentext[n]["find"], opentext[n]["replace"])
						end
						t1[k1].items[k2].str = gsub(t1[k1].items[k2].str, "#", "|r")
					end
				end
			end
		end
		return t1
	end

    self.TableDDM = {
        lvl1 = {
            {"v", "Introduction", id = 1},
            {"s", "Starting Zones"},
            {"s", "Later Leveling"},
            {"s", "Profession Guides"},
        },
        lvl2 = {
            ["Later Leveling"] = {
                {"s", "12-20"},
                {"s", "20-30"},
                {"s", "30-40"},
                {"s", "40-50"},
                {"s", "50-60"},
            },
            ["Profession Guides"] = {
                {"v", "Alchemy", id = nil},
                {"v", "Blacksmithing", id = nil},
                {"v", "[H] Cooking", id = nil},
                {"v", "[A] Cooking", id = nil},
                {"v", "Enchanting", id = nil},
                {"v", "Engineering", id = nil},
                {"v", "Leatherworking", id = nil},
                {"v", "Tailoring", id = nil}
            },
            ["[H] Starting Zones"] = {
                {"s", "Orcs & Trolls"},
                {"s", "Taurens"},
                {"s", "Undeads"},
            },
            ["[A] Starting Zones"] = {
                {"s", "Humans"},
                {"s", "Dwarves & Gnomes"},
                {"s", "Night Elves"},
            },
        },
        lvl3 = {
            ["Orcs & Trolls"] = {
                {"v", "1-6 Durotar", id = nil},
                {"v", "6-9 Durotar", id = nil},
                {"v", "9-12 Durotar", id = nil},
            },
            ["Taurens"] = {
                {"v", "1-6 Mulgore", id = nil},
                {"v", "6-10 Mulgore", id = nil},
                {"v", "10-12 Mulgore", id = nil},
            },
            ["Undeads"] = {
                {"v", "1-6 DeathKnell", id = nil},
                {"v", "6-10 Tirisfal Glades", id = nil},
                {"v", "10-12 Tirisfal Glades", id = nil},          
            },
            ["Humans"] = {
                {"v", "1-10 Elwynn Forest", id = nil},
                {"v", "10-12 Westfall and Lock Modan", id = nil},
            },
            ["Dwarves & Gnomes"] = {
                {"v", "1-6 Cold Ridge Valley", id = nil},
                {"v", "6-12 Dun Morogh", id = nil},
            },
            ["Night Elves"] = {
                {"v", "1-6 Teldrassil", id = nil},
                {"v", "6-12 Teldrassil", id = nil},
            },
            ["[H] 12-20"] = {
                {"v", "12-15 Barrens", id = nil},
                {"v", "15-16 Stonetalon Mountains", id = nil},
                {"v", "16-20 Barrens (part 1)", id = nil},
                {"v", "16-20 Barrens (part 2)", id = nil},
            },
            ["[H] 20-30"] = {
                {"v", "20-21 Stonetalon Mountains", id = nil},
                {"v", "21-21 Ashenvale", id = nil},
                {"v", "22-23 Southern Barrens", id = nil},
                {"v", "23-25 Stonetalon Mountains", id = nil},
                {"v", "25-25 Southern Barrens", id = nil},
                {"v", "25-26 Thousand Needles", id = nil},
                {"v", "26-27 Ashenvale", id = nil},
                {"v", "27-27 Stonetalon Mountains", id = nil},
                {"v", "27-29 Thousand Needles", id = nil},
                {"v", "29-30 Hillsbrad Foothills", id = nil},
            },
            ["[H] 30-40"] = {
                {"v", "30-30 Alterac Mountains", id = nil},
                {"v", "30-30 Arathi Highlands", id = nil},
                {"v", "30-31 Stranglethorn Vale", id = nil},
                {"v", "31-32 TN (Shimmering Flats)", id = nil},
                {"v", "32-34 Desolace", id = nil},
                {"v", "34-35 Stranglethorn Vale", id = nil},
                {"v", "35-37 Arathi Highlands", id = nil},
                {"v", "37-37 Alterac Mountains", id = nil},
                {"v", "37-37 Thousand Needles", id = nil},
                {"v", "37-38 Dustwallow Marsh", id = nil},
                {"v", "38-40 Stranglethorn Vale", id = nil},
            },
            ["[H] 40-50"] = {
                {"v", "40-41 Badlands", id = nil},
                {"v", "41-42 Swamp of Sorrows", id = nil},
                {"v", "42-43 Stranglethorn Vale", id = nil},
                {"v", "43-43 Desolace", id = nil},
                {"v", "43-43 Dustwallow Marsh", id = nil},
                {"v", "43-44 Tanaris", id = nil},
                {"v", "44-46 Feralas", id = nil},
                {"v", "46-46 Azshara", id = nil},
                {"v", "46-47 Hinterlands", id = nil},
                {"v", "47-47 Stranglethorn Vale", id = nil},
                {"v", "47-48 Searing Gorge", id = nil},
                {"v", "48-48 Swamp of Sorrows", id = nil},
                {"v", "48-49 Ferelas", id = nil},
                {"v", "49-50 Tanaris", id = nil},
            },
            ["[H] 50-60"] = {
                {"v", "50-50 Azshara", id = nil},
                {"v", "50-50 Hinterlands", id = nil},
                {"v", "50-51 Blasted Lands", id = nil},
                {"v", "51-52 Un'Goro Crater", id = nil},
                {"v", "52-53 Burning Steppes", id = nil},
                {"v", "53-54 Azshara", id = nil},
                {"v", "54-54 Felwood", id = nil},
                {"v", "54-55 Winterspring", id = nil},
                {"v", "55-55 Felwood", id = nil},
                {"v", "55-55 Silithus", id = nil},
                {"v", "55-56 Western Plaguelands", id = nil},
                {"v", "56-57 Eastern Plaguelands", id = nil},
                {"v", "57-58 Western Plaguelands", id = nil},
                {"v", "58-60 Winterspring", id = nil},
            },
            ["[A] 12-20"] = {
                {"v", "12-14 Darkshore", id = nil},
                {"v", "14-17 Darkshore", id = nil},
                {"v", "17-18 Loch Modan", id = nil},
                {"v", "18-20 Redredge Mountains", id = nil},
            },
            ["[A] 20-30"] = {
                {"v", "20-21 Darkshore", id = nil},
                {"v", "21-22 Ashenvale", id = nil},
                {"v", "22-23 Stonetalon Mountains", id = nil},
                {"v", "23-24 Darkshore", id = nil},
                {"v", "24-25 Ashenvale", id = nil},
                {"v", "25-27 Wetlands", id = nil},
                {"v", "27-28 Lakeshire", id = nil},
                {"v", "28-29 Duskwood", id = nil},
                {"v", "29-30 Ashenvale", id = nil},
                {"v", "30-30 Wetlands", id = nil},
            },
            ["[A] 30-40"] = {
                {"v", "30-31 Hillsbrad Foothills", id = nil},
                {"v", "31-31 Alterac Mountains", id = nil},
                {"v", "31-32 Arathi Highlands", id = nil},
                {"v", "32-32 Stranglethorn Vale", id = nil},
                {"v", "32-33 Thousand Needles (Shimmering Flats)", id = nil},
                {"v", "33-33 Stonetalon Mountains", id = nil},
                {"v", "33-35 Desolace", id = nil},
                {"v", "35-36 Stranglethorn Vale", id = nil},
                {"v", "36-37 Alterac Mountains", id = nil},
                {"v", "37-38 Arathi Highlands", id = nil},
                {"v", "38-38 Dustwallow Marsh", id = nil},
                {"v", "38-40 Stranglethorn Vale", id = nil},
            },
            ["[A] 40-50"] = {
                {"v", "40-41 Badlands", id = nil},
                {"v", "41-41 Swamp of Sorrows", id = nil},
                {"v", "41-42 Desolace", id = nil},
                {"v", "42-43 Stranglethron Vale", id = nil},
                {"v", "43-43 Tanaris", id = nil},
                {"v", "43-45 Feralas", id = nil},
                {"v", "45-46 Uldaman", id = nil},
                {"v", "46-47 The Hinterlands", id = nil},
                {"v", "47-47 Feralas", id = nil},
                {"v", "47-48 Tanaris", id = nil},
                {"v", "48-48 The Hinterlands", id = nil},
                {"v", "48-49 Stranglethorn Vale", id = nil},
                {"v", "49-50 Blasted Lands", id = nil},
            },
            ["[A] 50-60"] = {
                {"v", "50-51 Searing Gorge", id = nil},
                {"v", "51-52 Un’Goro Crater", id = nil},
                {"v", "52-53 Azshara", id = nil},
                {"v", "53-54 Felwood", id = nil},
                {"v", "54-54 Tanaris", id = nil},
                {"v", "54-54 Felwood", id = nil},
                {"v", "54-55 Winterspring", id = nil},
                {"v", "55-56 Burning Steppes", id = nil},
                {"v", "56-56 Tanaris", id = nil},
                {"v", "56-56 Silithus", id = nil},
                {"v", "56-57 Western Plaguelands", id = nil},
                {"v", "57-58 Eastern Plaguelands", id = nil},
                {"v", "58-58 Western Plaguelands", id = nil},
                {"v", "58-58 Eastern Plaguelands", id = nil},
                {"v", "58-59 Western Plaguelands", id = nil},
                {"v", "59-60 Winterspring", id = nil},
            },
        },
    }

    local tCharInfo = oSettings:GetSettingsCharInfo()

    self.Guide = {}
    self.NoGuide = {}
    self.GuideCount = 0
    self.NoGuideCount = 0
    self.Faction = tCharInfo.Faction
    self.Race = tCharInfo.Race

    -- Guides Preparation methods
    function VGuide:PrepareGuidesTableHorde(tRace)
        self.Guide = TablesMerge(self.Guide, ColorizeTable(Table_001_Introduction))
        if tRace == "Tauren" then 
            self.Guide = TablesMerge(self.Guide, ColorizeTable(Table_002_Mulgore))
        elseif tRace == "Undead" then 
            self.Guide = TablesMerge(self.Guide, ColorizeTable(Table_002_TirisfalGlades))
        else 
            self.Guide = TablesMerge(self.Guide, ColorizeTable(Table_002_Durotar))
        end
        self.Guide = TablesMerge(self.Guide, ColorizeTable(Table_003_Horde_12to20))
        self.Guide = TablesMerge(self.Guide, ColorizeTable(Table_003_Horde_20to30))
        self.Guide = TablesMerge(self.Guide, ColorizeTable(Table_003_Horde_30to40))
        self.Guide = TablesMerge(self.Guide, ColorizeTable(Table_003_Horde_40to50))
        self.Guide = TablesMerge(self.Guide, ColorizeTable(Table_003_Horde_50to60))
        self.Guide = TablesMerge(self.Guide, ColorizeTable(Table_004_Professions))
    end

    function VGuide:PrepareNoGuidesTableHorde(tRace)
        if tRace == "Tauren" then 
            self.NoGuide = TablesMerge(self.NoGuide, ColorizeTable(Table_002_TirisfalGlades))
            self:NormalizeGuide(self.NoGuide, nil)
            self.NoGuide = TablesMerge(self.NoGuide, ColorizeTable(Table_002_Durotar))
        elseif tRace == "Undead" then 
            self.NoGuide = TablesMerge(self.NoGuide, ColorizeTable(Table_002_Durotar))
            self:NormalizeGuide(self.NoGuide, nil)
            self.NoGuide = TablesMerge(self.NoGuide, ColorizeTable(Table_002_Mulgore))			
        else
            self.NoGuide = TablesMerge(self.NoGuide, ColorizeTable(Table_002_Mulgore))
            self:NormalizeGuide(self.NoGuide, nil)
            self.NoGuide = TablesMerge(self.NoGuide, ColorizeTable(Table_002_TirisfalGlades))
        end
    end

    function VGuide:PrepareGuidesTableAlliance(tRace)
        self.Guide = TablesMerge(self.Guide, ColorizeTable(Table_001_Introduction))
        if tRace == "Human" then
            self.Guide = TablesMerge(self.Guide, ColorizeTable(Table_002_ElwynnForest))
        elseif tRace == "Night Elf" then
            self.Guide = TablesMerge(self.Guide, ColorizeTable(Table_002_Teldrassil))
        else
            self.Guide = TablesMerge(self.Guide, ColorizeTable(Table_002_DunMorogh))
        end
        self.Guide = TablesMerge(self.Guide, ColorizeTable(Table_003_Alliance_12to20))
        self.Guide = TablesMerge(self.Guide, ColorizeTable(Table_003_Alliance_20to30))
        self.Guide = TablesMerge(self.Guide, ColorizeTable(Table_003_Alliance_30to40))
        self.Guide = TablesMerge(self.Guide, ColorizeTable(Table_003_Alliance_40to50))
        self.Guide = TablesMerge(self.Guide, ColorizeTable(Table_003_Alliance_50to60))
        self.Guide = TablesMerge(self.Guide, ColorizeTable(Table_004_Professions))
    end

    function VGuide:PrepareNoGuidesTableAlliance(tRace)
        if tRace == "Human" then
            self.NoGuide = TablesMerge(self.NoGuide, ColorizeTable(Table_002_DunMorogh))
            self:NormalizeGuide(self.NoGuide, nil)
            self.NoGuide = TablesMerge(self.NoGuide, ColorizeTable(Table_002_Teldrassil))
        elseif tRace == "Night Elf" then
            self.NoGuide = TablesMerge(self.NoGuide, ColorizeTable(Table_002_ElwynnForest))
            self:NormalizeGuide(self.NoGuide, nil)
            self.NoGuide = TablesMerge(self.NoGuide, ColorizeTable(Table_002_DunMorogh))
        else
            self.NoGuide = TablesMerge(self.NoGuide, ColorizeTable(Table_002_Teldrassil))
            self:NormalizeGuide(self.NoGuide, nil)
            self.NoGuide = TablesMerge(self.NoGuide, ColorizeTable(Table_002_ElwynnForest))
        end
    end

    function VGuide:NormalizeGuide(t, offset)
        if not offset then offset = 0 end
        local index_table = {}
        for i, _ in pairs(t) do
            table.insert(index_table, i)
        end
        table.sort(index_table)

        local c = 0 + offset
        for _, v in ipairs(index_table) do
            c = c + 1
            t[c] = t[v]
            if v ~= c then
                t[v] = nil
            end
        end
        return t, c - offset
    end

    -- DropDownMenu Preparation methods
    local function xSearchID(tDDMsection)
        for _, v1 in ipairs(tDDMsection) do
            for k, v2 in ipairs(self.Guide) do
                if string.find(v2.title, v1[2], 1, true) then 
                    v1.id = k
                end
            end
        end
    end
    
    function VGuide:DefineDDMProfessionsSubMenu()
        xSearchID(self.TableDDM.lvl2["Profession Guides"])
    end

    function VGuide:DefineDDMStartingZonesSubMenu(tFaction)
        if tFaction == "Horde" then
            xSearchID(self.TableDDM.lvl3["Orcs & Trolls"])
            xSearchID(self.TableDDM.lvl3["Taurens"])
            xSearchID(self.TableDDM.lvl3["Undeads"])
        else
            xSearchID(self.TableDDM.lvl3["Humans"])
            xSearchID(self.TableDDM.lvl3["Night Elves"])
            xSearchID(self.TableDDM.lvl3["Dwarves & Gnomes"])
        end
    end

    function VGuide:DefineDDMLaterLevelingSubMenu(tFaction)
        if tFaction == "Horde" then
            xSearchID(self.TableDDM.lvl3["[H] 12-20"])
            xSearchID(self.TableDDM.lvl3["[H] 20-30"])
            xSearchID(self.TableDDM.lvl3["[H] 30-40"])
            xSearchID(self.TableDDM.lvl3["[H] 40-50"])
            xSearchID(self.TableDDM.lvl3["[H] 50-60"])
        else
            xSearchID(self.TableDDM.lvl3["[A] 12-20"])
            xSearchID(self.TableDDM.lvl3["[A] 20-30"])
            xSearchID(self.TableDDM.lvl3["[A] 30-40"])
            xSearchID(self.TableDDM.lvl3["[A] 40-50"])
            xSearchID(self.TableDDM.lvl3["[A] 50-60"])
        end
    end

    function VGuide:ClearInitialTablesContent()
        Table_001_Introduction = nil
        Table_002_Durotar = nil
        Table_002_Mulgore = nil
        Table_002_TirisfalGlades = nil
        Table_002_DunMorogh = nil
        Table_002_Teldrassil = nil
        Table_002_ElwynnForest = nil
        Table_003_Horde_12to20 = nil
        Table_003_Horde_20to30 = nil
        Table_003_Horde_30to40 = nil
        Table_003_Horde_40to50 = nil
        Table_003_Horde_50to60 = nil
        Table_003_Alliance_12to20 = nil
        Table_003_Alliance_20to30 = nil
        Table_003_Alliance_30to40 = nil
        Table_003_Alliance_40to50 = nil
        Table_003_Alliance_50to60 = nil
        Table_004_Professions = nil
    end

    -- Query methods
    function VGuide:GetGuide(nGuideID)
        if nGuideID > self.GuideCount then 
            Dv(" -- Guide not present! ID exceed the GuideCount value!")
        elseif nGuideID < 1 then
            Dv(" -- negative or zero ID! Are you joking?")
        else
            return self.Guide[nGuideID]
        end
    end

    function VGuide:GetTableDDM()
        return self.TableDDM
    end

    -- Constructor Main
    if self.Faction == "Horde" then
        self:PrepareGuidesTableHorde(self.Race)
        self:PrepareNoGuidesTableHorde(self.Race)
    else
        self:PrepareGuidesTableAlliance(self.Race)
        self:PrepareNoGuidesTableAlliance(self.Race)
    end
    
    self.NoGuide, self.NoGuideCount = self:NormalizeGuide(self.NoGuide, 100500)
    self.Guide = TablesMerge(self.Guide, self.NoGuide)
    
    self.Guide, self.GuideCount = self:NormalizeGuide(self.Guide, nil)

    self:DefineDDMProfessionsSubMenu()
    self:DefineDDMStartingZonesSubMenu(self.Faction)
    self:DefineDDMLaterLevelingSubMenu(self.Faction)

    self:ClearInitialTablesContent()
end