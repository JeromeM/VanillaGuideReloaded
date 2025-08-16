--[[
Vanilla Guide Reloaded

Author: Grommey (originally by mrmr)

Description:
Core functionality for Vanilla Guide Reloaded.
Handles addon initialization, event registration, and core systems.
]]--

VGuide = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceConsole-2.0", "AceDebug-2.0")

-- Keybindings
BINDING_HEADER_VGUIDE = "Vanilla Guide Reloaded"
BINDING_NAME_VGUIDE_TOGGLE = "Toggle Vanilla Guide Reloaded"
BINDING_NAME_VGUIDE_PREV_STEP = "Prev Step"
BINDING_NAME_VGUIDE_NEXT_STEP = "Next Step"
BINDING_NAME_VGUIDE_PREV_GUIDE = "Prev Guide"
BINDING_NAME_VGUIDE_NEXT_GUIDE = "Next Guide"


function VGuide:OnInitialize(Addon_Name)
    if Addon_Name == "VanillaGuideReloaded"  then
        DEFAULT_CHAT_FRAME:AddMessage("|c003B59D3Vanilla|r|cFFFFFFFFGuide|r|cFFCB2F30Reloaded|r Loaded")
    end
end

function VGuide:OnEnable(first)
    
    local name, title = GetAddOnInfo("VanillaGuideReloaded")
    local author = GetAddOnMetadata("VanillaGuideReloaded", "Author") or "Unknown"
    local version = GetAddOnMetadata("VanillaGuideReloaded", "Version") or "Unknown"
    local CharName = UnitName("player") or "Unknown"
    local RealmName = GetRealmName() or "Unknown"
    
    local _, classToken = UnitClass("player")
    local _, raceToken = UnitRace("player")
    
    local Faction = (UnitFactionGroup and UnitFactionGroup("player")) or (UnitFaction and UnitFaction("player")) or "Unknown"
    
    title = title or name or "VanillaGuideReloaded"

    self.Settings = objSettings:new()
    self.Settings:CheckSettings()
    
    -- Initialisation des modules
    self.GuideRegistry = GuideRegistry
    self.Display = objDisplay:new(self.Settings)
    self.UI = objUI:new(self.Settings, self.Display)
    self.QuestTracker = objQuestTracker:new(self.Settings)

    -- Créer une référence globale pour les raccourcis clavier
    VGuide = self

end

return VGuide
