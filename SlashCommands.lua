--[[--------------------------------------------------
----- VanillaGuide -----
------------------
SlashCommands.lua
Authors: mrmr, Grommey
Version: 2.0
------------------------------------------------------
Description: 
    Slash command handling for VanillaGuide
    2.0
        -- Refactored to integrate with VGuide
        -- Updated frame references and removed Ace2 remnants
------------------------------------------------------]]

function VGuide:InitializeSlashCommands()
    -- Slash command options
    local options = { 
        type = 'group',
        args = {
            toggle = {
                type = 'toggle',
                name = 'toggle',
                desc = 'This toggles VanillaGuide Main Frame visibility',
                get = function() return self:IsMainFrameVisible() end,
                set = function() self:ToggleMainFrameVisibility() end
            }
        }
    }

    -- Register slash commands
    self:RegisterChatCommand({"/vguide", "/vg"}, options)
end

function VGuide:IsMainFrameVisible()
    local frame = self.MainFrame.tWidgets.frame_MainFrame
    return frame:IsVisible()
end

function VGuide:ToggleMainFrameVisibility()
    local frame = self.MainFrame.tWidgets.frame_MainFrame
    local fSettings = self.SettingsFrame.tWidgets.frame_SettingFrame
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
