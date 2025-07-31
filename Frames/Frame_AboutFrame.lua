--[[
Vanilla Guide Reloaded

Author: Grommey (originally by mrmr)
Version: 2.0.0

Description:
Implements the about frame UI component for the addon.
Displays version information and credits.
Part of the Vanilla Guide Reloaded addon.
]]--

objAboutFrame = {}
objAboutFrame.__index = objAboutFrame

function objAboutFrame:new(fParent, tTexture, oSettings)
    local obj = {}
    setmetatable(obj, self)

    local version = GetAddOnMetadata("VanillaGuideReloaded", "Version")
    local tCharInfo = oSettings:GetSettingsCharInfo()

    local sTitle = "About VanillaGuideReloaded"
    local sAboutText = "VanillaGuideReloaded v" .. version .. "\n\n" ..
        "Sage Guide for both Alliance and Horde\n\n" ..
        "VanillaGuide original Author : mrmr\n" ..
        "Remake by Grommey\n"


    -- Main Frame
    local frame = CreateFrame("Frame", "VG_AboutFrame")
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(10)
    frame:SetWidth(320)
    frame:SetHeight(180)
    frame:SetScale(0.8)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        tile = false, tileSize = 0, edgeSize = 2,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    frame:SetBackdropColor(.03, 0.03, .03, .70)
    frame:SetBackdropBorderColor(0, 0, 0, 1)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:RegisterForDrag("LeftButton")

    frame:SetScript("OnMouseDown", function()
        if arg1 == "LeftButton" and not frame.isMoving then
            frame:StartMoving()
            frame.isMoving = true
        end
    end)

    frame:SetScript("OnMouseUp", function()
        if arg1 == "LeftButton" and frame.isMoving then
            frame:StopMovingOrSizing()
            frame.isMoving = false
        end
    end)

    frame:SetScript("OnHide", function()
        if frame.isMoving then
            frame:StopMovingOrSizing()
            frame.isMoving = false
        end
    end)


    -- Title
    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -16)
    title:SetText(sTitle)


    -- Main Text
    local aboutText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    aboutText:SetPoint("TOP", title, "BOTTOM", 0, -12)
    aboutText:SetWidth(frame:GetWidth() - 40)
    aboutText:SetJustifyH("LEFT")
    aboutText:SetJustifyV("TOP")
    aboutText:SetText(sAboutText)


    -- Close Button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetWidth(24)
    closeBtn:SetHeight(24)
    closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -6, -6)
    
    closeBtn:SetScript("OnClick", function()
		local frame = closeBtn:GetParent()
		frame:Hide()
		frame.showthis = false
	end)


    -- Widgets
    obj.tWidgets = {
        frame_AboutFrame = frame,
        button_CloseButton = closeBtn,
        fs_Title = title,
        fs_AboutText = aboutText,
    }

    obj.ShowFrame = function(self)
        local f = obj.tWidgets.frame_AboutFrame
        if not f:IsVisible() then
            f:Show()
        end
    end

    obj.HideFrame = function(self)
        local f = obj.tWidgets.frame_AboutFrame
        if f:IsVisible() then
            f:Hide()
        end
    end

    frame:Hide()

    return obj
end
