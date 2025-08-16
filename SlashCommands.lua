--[[
Vanilla Guide Reloaded

Author: Grommey (originally by mrmr)

Description:
Handles slash commands for the addon.
Manages command registration and execution for user interactions.
Part of the Vanilla Guide Reloaded addon.
]]--
local VGuide = VGuide or {}

local options = { 
    type='group',
    args = {
			toggle = {
				type = 'toggle',
				name = 'toggle',
				desc = 'This Toggle VanillaGuideReloaded Main Frame visibility',
				get = "IsMFVisible",
				set = "ToggleMFVisibility"
			}
		--},
	},
}

VGuide:RegisterChatCommand({"/vguide", "/vg"}, options)

function VGuide:IsMFVisible()
	local frame = getglobal("VG_MainFrame")
    return frame:IsVisible()
end

function VGuide:ToggleMFVisibility()
    local frame = getglobal("VG_MainFrame")
	local fSettings = getglobal("VG_SettingsFrame")
    if frame:IsVisible() then
        frame:Hide()
		if fSettings:IsVisible() then
			fSettings.showthis = true
			fSettings:Hide()
		end
    else
        frame:Show()
		if fSettings.showthis then
			fSettings:Show()
		end
    end
end

return VGuide