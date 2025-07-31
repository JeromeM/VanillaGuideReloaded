--[[
Vanilla Guide Reloaded

Author: Grommey (originally by mrmr)
Version: 2.0.0

Description:
Manages addon settings and saved variables.
Handles configuration persistence and default values.
Part of the Vanilla Guide Reloaded addon.
]]--

objSettings = {}
objSettings.__index = objSettings

function objSettings:new()
	local obj = {}
	setmetatable(obj, self)

	local char_defaults = {
		UI = {
			Locked = false,
			StepFrameVisible = true,
			StepScroll = 0.33,
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
			PrevGuideID = 0,
			NextGuideID = 0,
		},
		TomTomToggle = false,
		QuestTracking = {
			accepted = {},
			completed = {},
		}
	}

	obj = AceLibrary("AceAddon-2.0"):new("AceDB-2.0")

	obj:RegisterDB("VanillaGuideReloadedDBPC")
	obj:RegisterDefaults("char", char_defaults)

	obj.CheckSettings = function(self)
		local charName = AceLibrary("AceDB-2.0").NAME
		local realmName = AceLibrary("AceDB-2.0").REALM
		local classID = AceLibrary("AceDB-2.0").CLASS_ID
		local faction = AceLibrary("AceDB-2.0").FACTION
		
		if obj.db.char.CharInfo.CharName == "Unknown" or obj.db.char.CharInfo.CharName ~= charName then
			obj.db.char.CharInfo.CharName = charName
			obj.db.char.CharInfo.RealmName = realmName
			obj.db.char.CharInfo.Class = classID
			obj.db.char.CharInfo.Race = UnitRace("player")
			obj.db.char.CharInfo.Faction = faction
		elseif obj.db.char.CharInfo.CharName == charName then
			if obj.db.char.CharInfo.Faction ~= faction then
				obj:ResetDB("char")
			end
		end

	end

	obj.GetSettingsEntireCharDB = function(self)
		return obj.db.char
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

	obj.GetSettingsTomTom = function(self)
		return obj.db.char.TomTomToggle
	end

	obj.GetSettingsQuestTracking = function(self)
		return obj.db.char.QuestTracking
	end


	obj.SetSettingEntireCharDB = function(self, tSettingsTable)
		obj.db.char = tSettingsTable
	end

	obj.SetSettingsCharInfo = function(self, tCharInfo)
		obj.db.char.CharInfo = tCharInfo
	end

	obj.SetSettingsUI = function(self, tUI)
		local dbUI = obj.db.char.UI
		for k, v in pairs(tUI) do
			dbUI[k] = v
		end
	end

	obj.SetSettingsGuideValues = function(self, tGuideValues)
		obj.db.char.GuideValues = tGuideValues
	end

	obj.SetSettingsTomTom = function(self, bTomTom)
		obj.db.char.TomTomToggle = bTomTom
	end

	obj.SetSettingsQuestTracking = function(self, tQuestTracking)
		obj.db.char.QuestTracking = tQuestTracking
	end

	return obj
end
