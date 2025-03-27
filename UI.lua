--[[--------------------------------------------------
----- VanillaGuide -----
------------------
UI.lua
Authors: mrmr
Version: 1.04.3
------------------------------------------------------
Description: 
    UI initialization and texture definitions for VanillaGuide.
    1.04.3
        -- Refactored to integrate with VGuide directly
        -- Removed separate objMainFrame, objSettingsFrame, objAboutFrame
------------------------------------------------------]]

function VGuide:InitializeUI(oSettings, oDisplay)
    -- Texture definitions
    local VG_TEXTURE_DIR = "Interface\\AddOns\\VanillaGuide\\Textures\\"
    local VG_TEXTURE = {
        FONT = "GameFontNormalSmall",
        FONT_PATH = "Fonts\\FRIZQT__.TTF",
        FONT_HEIGHT = 9.5, -- DO NOT CHANGE THIS OR THE SCROLLFRAME WILL BE BORKED!

        BACKDROP = {
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Borders\\fer1",
            edgeSize = 4,
            insets = { left = 1, right = 1, top = 1, bottom = 1 },
        },

        BACKDROPSH = {
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            insets = { left = -1, right = -2, top = -3, bottom = -3 },
        },
        
        B_CLOSE = {
            NORMAL    = VG_TEXTURE_DIR .. "Buttons\\Button-Close-Normal",
            PUSHED    = VG_TEXTURE_DIR .. "Buttons\\Button-Close-Pushed",
            HIGHLIGHT = VG_TEXTURE_DIR .. "Buttons\\Button-Close-Highlight"
        },
        B_ARROWDOWN = {
            NORMAL    = VG_TEXTURE_DIR .. "Buttons\\Button-ArrowDown-Normal",
            PUSHED    = VG_TEXTURE_DIR .. "Buttons\\Button-ArrowDown-Pushed",
            HIGHLIGHT = VG_TEXTURE_DIR .. "Buttons\\Button-ArrowDown-Highlight"
        },
        B_ARROWUP = {
            NORMAL    = VG_TEXTURE_DIR .. "Buttons\\Button-ArrowUp-Normal",
            PUSHED    = VG_TEXTURE_DIR .. "Buttons\\Button-ArrowUp-Pushed",
            HIGHLIGHT = VG_TEXTURE_DIR .. "Buttons\\Button-ArrowUp-Highlight"
        },
        B_DETAILS = {
            NORMAL    = VG_TEXTURE_DIR .. "Buttons\\Button-Details-Normal",
            PUSHED    = VG_TEXTURE_DIR .. "Buttons\\Button-Details-Pushed",
            HIGHLIGHT = VG_TEXTURE_DIR .. "Buttons\\Button-Details-Highlight"
        },
        B_DOUBLEARROWLEFT = {
            NORMAL    = VG_TEXTURE_DIR .. "Buttons\\Button-DoubleArrowLeft-Normal",
            PUSHED    = VG_TEXTURE_DIR .. "Buttons\\Button-DoubleArrowLeft-Pushed",
            HIGHLIGHT = VG_TEXTURE_DIR .. "Buttons\\Button-DoubleArrowLeft-Highlight"
        },
        B_DOUBLEARROWRIGHT = {
            NORMAL    = VG_TEXTURE_DIR .. "Buttons\\Button-DoubleArrowRight-Normal",
            PUSHED    = VG_TEXTURE_DIR .. "Buttons\\Button-DoubleArrowRight-Pushed",
            HIGHLIGHT = VG_TEXTURE_DIR .. "Buttons\\Button-DoubleArrowRight-Highlight"
        },
        B_FLASH = {
            NORMAL    = VG_TEXTURE_DIR .. "Buttons\\Button-Flash-Normal",
            PUSHED    = VG_TEXTURE_DIR .. "Buttons\\Button-Flash-Pushed",
            HIGHLIGHT = VG_TEXTURE_DIR .. "Buttons\\Button-Flash-Highlight"
        },
        B_LOCKED = {
            NORMAL    = VG_TEXTURE_DIR .. "Buttons\\Button-Locked-Normal",
            PUSHED    = VG_TEXTURE_DIR .. "Buttons\\Button-Locked-Pushed",
            HIGHLIGHT = VG_TEXTURE_DIR .. "Buttons\\Button-Locked-Highlight"
        },
        B_UNLOCKED = {
            NORMAL    = VG_TEXTURE_DIR .. "Buttons\\Button-Unlocked-Normal",
            PUSHED    = VG_TEXTURE_DIR .. "Buttons\\Button-Unlocked-Pushed",
            HIGHLIGHT = VG_TEXTURE_DIR .. "Buttons\\Button-Unlocked-Highlight"
        },
        B_OPTION = {
            NORMAL    = VG_TEXTURE_DIR .. "Buttons\\Button-Option-Normal",
            PUSHED    = VG_TEXTURE_DIR .. "Buttons\\Button-Option-Pushed",
            HIGHLIGHT = VG_TEXTURE_DIR .. "Buttons\\Button-Option-Highlight"
        },
        B_ABOUT = {
            NORMAL    = VG_TEXTURE_DIR .. "Buttons\\Button-About-Normal",
            PUSHED    = VG_TEXTURE_DIR .. "Buttons\\Button-About-Pushed",
            HIGHLIGHT = VG_TEXTURE_DIR .. "Buttons\\Button-About-Highlight"
        },
        B_DUMLEFT_UP = {
            NORMAL    = VG_TEXTURE_DIR .. "Buttons\\Button-DUMonLeft-ArrowUp-Normal",
            PUSHED    = VG_TEXTURE_DIR .. "Buttons\\Button-DUMonLeft-ArrowUp-Pushed",
            HIGHLIGHT = VG_TEXTURE_DIR .. "Buttons\\Button-DUMonLeft-ArrowUp-Highlight"
        },
        B_DUMRIGHT_UP = {
            NORMAL    = VG_TEXTURE_DIR .. "Buttons\\Button-DUMonRight-ArrowUp-Normal",
            PUSHED    = VG_TEXTURE_DIR .. "Buttons\\Button-DUMonRight-ArrowUp-Pushed",
            HIGHLIGHT = VG_TEXTURE_DIR .. "Buttons\\Button-DUMonRight-ArrowUp-Highlight"
        },
        B_DDMLEFT_DOWN = {
            NORMAL    = VG_TEXTURE_DIR .. "Buttons\\Button-DDMonLeft-ArrowDown-Normal",
            PUSHED    = VG_TEXTURE_DIR .. "Buttons\\Button-DDMonLeft-ArrowDown-Pushed",
            HIGHLIGHT = VG_TEXTURE_DIR .. "Buttons\\Button-DDMonLeft-ArrowDown-Highlight"
        },
        B_DDMRIGHT_DOWN = {
            NORMAL    = VG_TEXTURE_DIR .. "Buttons\\Button-DDMonRight-ArrowDown-Normal",
            PUSHED    = VG_TEXTURE_DIR .. "Buttons\\Button-DDMonRight-ArrowDown-Pushed",
            HIGHLIGHT = VG_TEXTURE_DIR .. "Buttons\\Button-DDMonRight-ArrowDown-Highlight"
        },

        SCROLLFRAME_PADDING = 9
    }

    -- Store textures in VGuide
    self.Textures = VG_TEXTURE

    -- Initialize frames
    self:InitializeMainFrame(nil, self.Textures)
    self:InitializeSettingsFrame(self.MainFrame.tWidgets.frame_MainFrame, self.Textures)
    self:InitializeAboutFrame(self.MainFrame.tWidgets.frame_MainFrame, self.Textures)
end
