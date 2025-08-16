--[[
Vanilla Guide Reloaded

Author: Grommey (originally by mrmr)

Description:
Manages the main UI components including Main, Settings, and About frames.
Handles window creation, layout, and user interactions.
Part of the Vanilla Guide Reloaded addon.
]]--

objUI = {}
objUI.__index = objUI

function objUI:new(oSettings, oDisplay)
	local VG_TEXTURE_DIR = "Interface\\AddOns\\VanillaGuideReloaded\\Textures\\"
	local VG_TEXTURE = {
		FONT = "GameFontNormalSmall",
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

	}

	local obj = {}
    setmetatable(obj, self)

    obj.fMain = {}
    obj.fSettings = {}
    obj.fAbout = {}

    obj.fMain = objMainFrame:new(nil, VG_TEXTURE, oSettings, oDisplay)
    obj.fSettings = objSettingsFrame:new(obj.fMain.tWidgets.frame_MainFrame, VG_TEXTURE, oSettings)
    obj.fAbout = objAboutFrame:new(obj.fMain.tWidgets.frame_MainFrame, VG_TEXTURE, oSettings)
    
    return obj
end
