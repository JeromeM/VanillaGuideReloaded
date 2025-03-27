--[[--------------------------------------------------
----- VanillaGuide -----
------------------
Settings.lua
Authors: mrmr, Grommey
Version: 2.0
------------------------------------------------------
Description: 
    Handles the addon settings using AceDB-2.0.
    Integrated into VGuide for consistency.
    2.0
        -- Refactored to attach settings to VGuide
        -- Simplified TomTom check
        -- Removed MetaMap remnants
------------------------------------------------------]]


-- Attach settings to VGuide (assumes VGuide is already defined in Core.lua)
function VGuide:InitializeSettings()
    -- Inherit from AceDB-2.0
    self.Settings = AceLibrary("AceAddon-2.0"):new("AceDB-2.0")
    
    -- Default settings
    local char_defaults = {
        UI = {
            Locked = false,
            StepFrameVisible = true,
            ScrollFrameVisible = true,
            StepScroll = 0.33,
            MinimapToggle = true,
            MinimapPos = 0,
            Opacity = 1,
            Scale = 1,
            Layer = "HIGH",
            MainFrameSize = {
                nWidth = 320,
                nHeight = 320,
            },
            MainFrameAnchor = {
                sFrom = "CENTER",
                sTo = "CENTER",
                nX = 0,
                nY = 0,
            },
            MainFrameColor = { nR = .11, nG = .11, nB = .11, nA = .81 },
            StepFrameColor = { nR = .11, nG = .11, nB = .41, nA = .71 },
            ScrollFrameColor = { nR = .41, nG = .11, nB = .11, nA = .71 },
            StepFrameTextColor = { nR = .91, nG = .91, nB = .91, nA = .99 },
            ScrollFrameTextColor = { nR = .59, nG = .59, nB = .59, nA = .71 },
        },
        CharInfo = {
            CharName = "Unknown",
            RealmName = "Unknown",
            Class = "Unknown",
            Race = "Unknown",
            Faction = "Unknown",
        },
        GuideValues = {
            GuideID = 1,
            Step = 1,
        },
        VGuideFu = {
            ShowTitle = true,
            ShowGuideName = false,
            ShowGuideStep = false,
            ShowLabels = true,
        },
        TomTom = {
            Presence = false,
            ArrowEnable = false,
            Enabled = false,
        },
    }

    -- Register database with AceDB
    self.Settings:RegisterDB("VanillaGuideDB", "VanillaGuideDBPC")
    self.Settings:RegisterDefaults("char", char_defaults)
    self.Settings:RegisterDefaults("profile", {}) -- Empty profile defaults as in original

    -- Method to print settings for debugging
    function self.Settings:PrintSettings()
        Dv("---------------------------")
        Dv(" -- CharInfo")
        Dv(" -  - Name: ", self.db.char.CharInfo.CharName)
        Dv(" -  - Faction: ", self.db.char.CharInfo.Faction)
        Dv(" -  - Race: ", self.db.char.CharInfo.Race)
        Dv(" ------------------")
        Dv(" -- TomTom")
        Dv(" -  - Presence: ", tostring(self.db.char.TomTom.Presence))
        Dv(" -  - ArrowEnable: ", tostring(self.db.char.TomTom.ArrowEnable))
        Dv(" -  - Enabled: ", tostring(self.db.char.TomTom.Enabled))
        Dv(" ------------------")
        Dv(" -- GuideValues")
        Dv(" -  - GuideID: ", self.db.char.GuideValues.GuideID)
        Dv(" -  - Step: ", self.db.char.GuideValues.Step)
        Dv(" ------------------")
        Dv(" -  - Locked: ", tostring(self.db.char.UI.Locked))
        Dv(" -  - MainFrameSize  X: ", self.db.char.UI.MainFrameSize.nWidth, "  Y: ", self.db.char.UI.MainFrameSize.nHeight)
        Dv("---------------------------")
    end

    -- Method to check and initialize settings
    function self.Settings:CheckSettings()
        -- TomTom support check
        local function TomTomSupportCheck()
            if IsAddOnLoaded("TomTom") and TomTom then
                Di("TomTom Support Present")
                return true
            else
                Di("TomTom Support not Present - no pointing arrow for you")
                return false
            end
        end

        local charID = AceLibrary("AceDB-2.0").CHAR_ID
        local faction = AceLibrary("AceDB-2.0").FACTION
        if self.db.char.CharInfo.CharName == "Unknown" then
            Di("New Settings for \"|cFFbb7777", charID, " - ", faction, "|r\"")
            self.db.char.CharInfo.CharName = AceLibrary("AceDB-2.0").NAME
            self.db.char.CharInfo.RealmName = AceLibrary("AceDB-2.0").REALM
            self.db.char.CharInfo.Class = AceLibrary("AceDB-2.0").CLASS_ID
            self.db.char.CharInfo.Race = UnitRace("player")
            self.db.char.CharInfo.Faction = faction
        elseif self.db.char.CharInfo.CharName == AceLibrary("AceDB-2.0").NAME then
            if self.db.char.CharInfo.Faction ~= faction then
                Di("Settings for \"|cFFbb7777", charID, " - ", faction, "|r\" need to be wiped out!")
                Di("This character was already used on the opposite faction!")
                self:ResetDB("char")
            else
                Di("Settings for \"|cFFbb7777", charID, " - ", faction, "|r\" loaded!")
            end
        end

        self.db.char.TomTom.Presence = TomTomSupportCheck()
    end

    -- Getters
    function self.Settings:GetSettingsCharInfo()
        return self.db.char.CharInfo
    end

    function self.Settings:GetSettingsUI()
        return self.db.char.UI
    end

    function self.Settings:GetSettingsGuideValues()
        return self.db.char.GuideValues
    end

    function self.Settings:GetSettingsVGuideFu()
        return self.db.char.VGuideFu
    end

    function self.Settings:GetSettingsTomTom()
        return self.db.char.TomTom
    end

    function self.Settings:GetSettingsEntireCharDB()
        return self.db.char
    end

    -- Setters
    function self.Settings:SetSettingsCharInfo(tCharInfo)
        self.db.char.CharInfo = tCharInfo
    end

    function self.Settings:SetSettingsUI(tUI)
        self.db.char.UI = tUI
    end

    function self.Settings:SetSettingsGuideValues(tGuideValues)
        self.db.char.GuideValues = tGuideValues
    end

    function self.Settings:SetSettingsVGuideFu(tVGuideFu)
        self.db.char.VGuideFu = tVGuideFu
    end

    function self.Settings:SetSettingsTomTom(tTomTom)
        self.db.char.TomTom = tTomTom
    end

    function self.Settings:SetSettingsEntireCharDB(tSettingsTable)
        self.db.char = tSettingsTable
    end
end
