--[[--------------------------------------------------
----- VanillaGuide -----
------------------
Frame_AboutFrame.lua
Authors: mrmr, Grommey
Version: 2.0
------------------------------------------------------
Description: 
    About Frame management for VanillaGuide
    2.0
        -- Refactored to integrate with VGuide
        -- Removed objAboutFrame, methods attached to VGuide
        -- Updated author to Grommey
------------------------------------------------------]]

function VGuide:InitializeAboutFrame(fParent, tTexture)
    fParent = fParent or nil

    local version = GetAddOnMetadata("VanillaGuide", "Version")
    local tCharInfo = self.Settings:GetSettingsCharInfo()

    local sAboutTextHorde = "|cccff1919Vanilla|ccceeeeeeGuide" ..
        " |ccca1a1a1v|ccc4a4aa1" .. version .. "|r" ..
        "\n\n\n|ccca1a1a1A 'remake' of the original by mrmr|r" ..
        "\n|cccff1919J|ccceeeeeeoana`s |cccff1919Horde|ccceeeeee Leveling Guide.|r" ..
        "\n|ccca1a1a1in an in-game addon.\n" ..
        "\n                           Remade by |ccca11919Grommey|r|ccca1a1a1!|r"
    local sAboutTextAlliance = "|cccff1919Vanilla|ccceeeeeeGuide" .. 
        " |ccca1a1a1v|ccc4a4aa1" .. version .. "|r" ..
        "\n\n\n|ccca1a1a1A 'remake' of the original by mrmr|r" ..
        "\n|ccc3939aaB|ccceeeeeerian |ccc3939aaKopps|ccceeeeee Leveling Guide.|r" ..
        "\n|ccca1a1a1in an in-game addon.\n" ..
        "\n                           Remade by |ccca11919Grommey|r|ccca1a1a1!|r"    

    local sAboutText = tCharInfo.Faction == "Horde" and sAboutTextHorde or sAboutTextAlliance

    -- Rendering functions
    local function Render_AF(fParent, tTexture, sName)
        local frame = CreateFrame("Frame", sName)
        frame:SetFrameStrata("TOOLTIP")
        frame:SetFrameLevel(8)
        frame:SetWidth(195)
        frame:SetHeight(125)
        frame:SetScale(1)
        frame:SetPoint("BOTTOMLEFT", fParent, "TOPLEFT", 0, 10)
        frame:SetBackdrop(tTexture.BACKDROP)
        frame:SetBackdropColor(.01, .01, .01, .99)
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:SetClampedToScreen(true)
        frame:RegisterForDrag("LeftButton")
        return frame
    end

    local function Render_AFCloseButton(tParent, tTexture, sName)
        local btn = CreateFrame("Button", sName, tParent)
        btn:SetWidth(16)
        btn:SetHeight(16)
        btn:SetNormalTexture(tTexture.B_CLOSE.NORMAL)
        btn:SetPushedTexture(tTexture.B_CLOSE.PUSHED)
        btn:SetHighlightTexture(tTexture.B_CLOSE.HIGHLIGHT)
        btn:SetPoint("TOPRIGHT", tParent, "TOPRIGHT", -5, -5)
        return btn
    end

    local function Render_AFLabel(tParent, sName, sText)
        local fs = tParent:CreateFontString(sName, "ARTWORK", "GameFontNormalSmall")
        fs:SetPoint("CENTER", tParent, "CENTER", 0, 0)
        fs:SetTextColor(.91, .79, .11, 1)
        fs:SetJustifyH("CENTER")
        fs:SetJustifyV("CENTER")
        fs:SetText(sText)
        return fs
    end

    -- Initialize AboutFrame widgets
    self.AboutFrame = { tWidgets = {} }
    local af = self.AboutFrame.tWidgets

    -- Rendering
    af.frame_AboutFrame = Render_AF(fParent, tTexture, "VG_AboutFrame")
    af.button_CloseButton = Render_AFCloseButton(af.frame_AboutFrame, tTexture, nil)
    af.fs_AboutFrame = Render_AFLabel(af.frame_AboutFrame, nil, sAboutText)

    -- UI Events Handling
    af.frame_AboutFrame:SetScript("OnMouseDown", function()
        if arg1 == "LeftButton" and not this.isMoving then
            this:StartMoving()
            this.isMoving = true
        end
    end)
    af.frame_AboutFrame:SetScript("OnMouseUp", function()
        if arg1 == "LeftButton" and this.isMoving then
            this:StopMovingOrSizing()
            this.isMoving = false
        end
    end)
    af.frame_AboutFrame:SetScript("OnHide", function()
        if this.isMoving then
            this:StopMovingOrSizing()
            this.isMoving = false
        end
    end)
    af.button_CloseButton:SetScript("OnClick", function()
        local frame = this:GetParent()
        frame:Hide()
    end)

    -- Initialization
    af.frame_AboutFrame:Hide()

    -- External methods
    function VGuide:ShowAboutFrame()
        local f = self.AboutFrame.tWidgets.frame_AboutFrame
        if not f:IsVisible() then
            f:Show()
        end
    end

    function VGuide:HideAboutFrame()
        local f = self.AboutFrame.tWidgets.frame_AboutFrame
        if f:IsVisible() then
            f:Hide()
        end
    end
end