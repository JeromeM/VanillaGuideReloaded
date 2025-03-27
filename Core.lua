--[[
    ----- VanillaGuide -----
    Core.lua
    Authors: mrmr, Grommey
    Version: 2.0
    ------------------------------------------------------
    Description: 
        Powerleveling Guide for 1.12.1 servers
        based on Joana Guide. Core FILE!

--]]

--[[ DEBUG ]]--
VGuide_DebugInfo = true
VGuide_DebugVerbose = false

function Di(...)
    if VGuide_DebugInfo then
        for k, v in pairs(arg) do arg[k] = tostring(v) end
        DEFAULT_CHAT_FRAME:AddMessage("|cFFff6633VGuide info:|r " .. table.concat(arg, ", "))
    end
end

function Dv(...)
    if VGuide_DebugVerbose then
        for k, v in pairs(arg) do arg[k] = tostring(v) end
        DEFAULT_CHAT_FRAME:AddMessage("     |cFFff6677VGuide debug:|r " .. table.concat(arg, ", "))
    end
end

function Dtprint(tbl, indent)
    if not VGuide_DebugVerbose then return end
    indent = indent or 0
    for k, v in pairs(tbl) do
        local formatting = string.rep(" ", indent) .. "[" .. k .. "]: "
        if type(v) == "table" then
            Dv(formatting)
            Dtprint(v, indent + 4)
        else
            Dv(formatting .. tostring(v))
        end
    end
end

--[[ INIT ]]--
VGuide = AceLibrary("AceAddon-2.0"):new("AceEvent-2.0", "AceConsole-2.0", "AceDebug-2.0")

BINDING_HEADER_VGUIDE = "Vanilla Guide"
BINDING_NAME_VGUIDE_TOGGLE = "Toggle Vanilla Guide"
BINDING_NAME_VGUIDE_PREV_STEP = "Prev Step"
BINDING_NAME_VGUIDE_NEXT_STEP = "Next Step"
BINDING_NAME_VGUIDE_PREV_GUIDE = "Prev Guide"
BINDING_NAME_VGUIDE_NEXT_GUIDE = "Next Guide"


function VGuide:OnInitialize()
    self:RegisterEvent("PLAYER_LOGIN")

    local _, title = GetAddOnInfo("VanillaGuide")
    local author = GetAddOnMetadata("VanillaGuide", "Author")
    local version = GetAddOnMetadata("VanillaGuide", "Version")
    Di("Title: ", title, " | Author: ", author, " | Version: |cccff1919", version, "|r")
end

function VGuide:PLAYER_LOGIN()
    Dv("PLAYER_LOGIN: Initializing VGuide components")
    
    -- Initialisation des paramètres
    if not self.InitializeSettings then
        Dv("Error: InitializeSettings not defined")
        return
    end
    self:InitializeSettings()
    self.Settings:CheckSettings()
    
    -- Initialisation des tables de guide et affichage
    if not objGuideTable or not objDisplay then
        Dv("Error: objGuideTable or objDisplay not defined")
        return
    end
    self.GuideTable = objGuideTable:new(self.Settings)
    self.Display = objDisplay:new(self.Settings, self.GuideTable)
    
    -- Initialisation de l'UI
    if not self.InitializeUI then
        Dv("Error: InitializeUI not defined")
        return
    end
    self:InitializeUI(self.Settings, self.Display)
    
    Dv("PLAYER_LOGIN: VGuide initialization complete")
end

function VGuide:OnEnable()
    Dv("OnEnable: VGuide fully enabled")
end

function VGuide:OnDisable()
    Dv("OnDisable: VGuide disabled")
end

return VGuide