--[[--------------------------------------------------
----- VanillaGuide -----
------------------
Settings.lua
Authors: mrmr
Version: 1.04.3
------------------------------------------------------
Description: 
    	This object handles the various addon settings
    1.00
		-- Initial Ace2 release
	1.99a
		-- Ally addition starter version
    1.03
		-- No Changes. Just adjusting "version".
    		1.99x for a beta release was a weird choise.
	1.04.1
		-- Settings and/or "Saved Variables" are inclosed in
			VGuide.Settings
	1.04.2
		-- scraped MetaMapBWP settings for MetaMapBWP
			Now support for MetaMapNotes, too
		-- Added a function for a proper MetaMap checking
			MetaMapBWPSupportCheck()
    1.04.3
	-- no changes in here for this revision
	1.05
		-- Removed MetaMap support and added TomTom support
------------------------------------------------------
Connection:
--]]--------------------------------------------------

--local VGuide = VGuide
Dv(" VGuide Settings.lua Start")

objSettings = {}
objSettings.__index = objSettings

function objSettings:new()
	local obj = {}
    setmetatable(obj, self)

	local profile_defaults = {}
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
			MainFrameColor = {
				nR = .11,
				nG = .11,
				nB = .11,
				nA = .81,
			},
			StepFrameColor = {
				nR = .11,
				nG = .11,
				nB = .41,
				nA = .71,
			},
			ScrollFrameColor = {
				nR = .41,
				nG = .11,
				nB = .11,
				nA = .71,
			},
			StepFrameTextColor = {
				nR = .91,
				nG = .91,
				nB = .91,
				nA = .99,
			},
			ScrollFrameTextColor = {
				nR = .59,
				nG = .59,
				nB = .59,
				nA = .71,
			},
		},
	    CharInfo = {
			CharName = "Unknown",	--CharName,
			RealmName = "Unknown",	--RealmName,
			Class = "Unknown",		--Class,
			Race = "Unknown",		--Race,
			Faction = "Unknown",	--Faction,
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

	obj = AceLibrary("AceAddon-2.0"):new("AceDB-2.0")

	obj:RegisterDB("VanillaGuideDB", "VanillaGuideDBPC")
	
	obj:RegisterDefaults("profile", profile_defaults)
	obj:RegisterDefaults("char", char_defaults)
	
	obj.PrintSettings = function(self)
		Dv("---------------------------")
		Dv(" -- CharInfo")
		Dv(" -  - Name: " .. tostring(obj.db.char.CharInfo.CharName))
		Dv(" -  - Faction: " .. tostring(obj.db.char.CharInfo.Faction))
		Dv(" -  - Race: " .. tostring(obj.db.char.CharInfo.Race))
		Dv(" ------------------")
		Dv(" -- TomTom")
		Dv(" -  - Presence: " .. tostring(obj.db.char.TomTom.Presence))
		Dv(" -  - ArrowEnable: " .. tostring(obj.db.char.TomTom.ArrowEnable))
		Dv(" -  - Enabled: " .. tostring(obj.db.char.TomTom.Enabled))
		Dv(" ------------------")
		Dv(" -- GuideValues")
		Dv(" -  - GuideID: " .. tostring(obj.db.char.GuideValues.GuideID))
		Dv(" -  - Step: " .. tostring(obj.db.char.GuideValues.Step))
		Dv(" ------------------")
		Dv(" -- UI")
		Dv(" -  - Locked: " .. tostring(obj.db.char.UI.Locked))
		Dv(" -  - MainFrameSize  X: " .. tostring(obj.db.char.UI.MainFrameSize.nWidth) .. "  Y: " .. tostring(obj.db.char.UI.MainFrameSize.nHeight))
		Dv("---------------------------")
	end

	obj.CheckSettings = function(self)

		-- TOMTOM SUPPORT CHECK
		local function TomTomSupportCheck()
			local frame = CreateFrame("Frame")
		    local isTomTomLoaded = false
			local TomTomPresence = false

			if IsAddOnLoaded("TomTom") and TomTom then
				isTomTomLoaded = true
			else
				frame:RegisterEvent("ADDON_LOADED")
				frame:SetScript("OnEvent", function(self, event, addonName)
					if event == "ADDON_LOADED" and addonName == "TomTom" then
						if TomTom then
							isTomTomLoaded = true
						end
						self:UnregisterEvent("ADDON_LOADED")
					end
				end)
			end

			Dv("    TomTom Support Check:")
			if isTomTomLoaded then
				Di("      - TomTom Support Present")
				TomTomPresence = true
			else
				Di("      - TomTom Support not Present - no pointing arrow for ya")
			end
			
			return TomTomPresence
		end

		if obj.db.char.CharInfo.CharName == "Unknown" then
			Di(" New Settings for \"|cFFbb7777" .. AceLibrary("AceDB-2.0").CHAR_ID .. " - " .. AceLibrary("AceDB-2.0").FACTION .."|r\"")
			obj.db.char.CharInfo.CharName = AceLibrary("AceDB-2.0").NAME
			obj.db.char.CharInfo.RealmName = AceLibrary("AceDB-2.0").REALM
			obj.db.char.CharInfo.Class = AceLibrary("AceDB-2.0").CLASS_ID
			obj.db.char.CharInfo.Race = UnitRace("player")
			obj.db.char.CharInfo.Faction = AceLibrary("AceDB-2.0").FACTION
		elseif obj.db.char.CharInfo.CharName == AceLibrary("AceDB-2.0").NAME then
			if obj.db.char.CharInfo.Faction ~= AceLibrary("AceDB-2.0").FACTION then
				Di(" Settings for \"|cFFbb7777 " .. AceLibrary("AceDB-2.0").CHAR_ID .. " - " .. AceLibrary("AceDB-2.0").FACTION .. "|r\" need to be wiped out!")
				Di("   This character was already used on the opposite faction!")
				obj:ResetDB("char")
			else
				Di(" Settings for \"|cFFbb7777" .. AceLibrary("AceDB-2.0").CHAR_ID .. " - " .. AceLibrary("AceDB-2.0").FACTION .. "|r\" loaded!")
			end
		end

		obj.db.char.TomTom.Presence = TomTomSupportCheck()
	end

	obj.GetSettingsCharInfo = function(self)
		return obj.db.char.CharInfo
	end

	obj.GetSettingsUI = function(self)
		return obj.db.char.UI
	end

	obj.GetSettingsGuideValues = function(self)
		return obj.db.char.GuideValues
	end

	obj.GetSettingsVGuideFu = function(self)
		return obj.db.char.VGuideFu
	end

	obj.GetSettingsTomTom = function(self)
		return obj.db.char.TomTom
	end

	obj.GetSettingsEntireCharDB = function(self)
		return obj.db.char
	end

	obj.SetSettingsCharInfo = function(self, tCharInfo)
		obj.db.char.CharInfo = tCharInfo
	end

	obj.SetSettingsUI = function(self, tUI)
		obj.db.char.UI = tUI
	end

	obj.SetSettingsGuideValues = function(self, tGuideValues)
		obj.db.char.GuideValues = tGuideValues
	end

	obj.SetSettingsVGuideFu = function(self, tVGuideFu)
		obj.db.char.VGuideFu = tVGuideFu
	end

	obj.SetSettingsTomTom = function(self, tTomTom)
		obj.db.char.TomTom = tTomTom
	end

	obj.SetSettingEntireCharDB = function(self, tSettingsTable)
		VGuide.Settings.db.char = tSettingsTable
	end

	return obj
end

Dv(" VGuide Settings.lua End")
--return VGuide
