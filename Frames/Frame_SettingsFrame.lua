--[[
Vanilla Guide Reloaded

Author: Grommey (originally by mrmr)
Version: 2.0.0

Description:
Implements the settings frame UI component for the addon.
Manages user preferences and configuration options.
Part of the Vanilla Guide Reloaded addon.
]]--

objSettingsFrame = {}
objSettingsFrame.__index = objSettingsFrame

function objSettingsFrame:new(fParent, tTexture, oSettings)
	fParent = fParent or nil
	local obj = {}
	setmetatable(obj, self)

	local sTitle = "Settings"

	local tUI = oSettings:GetSettingsUI()
	local tomtomState = oSettings:GetSettingsTomTom()

	local nOpacity = tUI.Opacity
	local nScale = tUI.Scale
	local sLayer = tUI.Layer

	local Layers = {
		["DIALOG"] = 5,
		["HIGH"] = 4,
		["MEDIUM"] = 3,
		["LOW"] = 2,
		["BACKGROUND"] = 1,
		[5] = "DIALOG",
		[4] = "HIGH",
		[3] = "MEDIUM",
		[2] = "LOW",
		[1] = "BACKGROUND",
	}


	-- Main Frame
	local frame = CreateFrame("Frame", "VG_SettingsFrame")
	frame:SetFrameStrata("DIALOG")
	frame:SetFrameLevel(10)
	frame:SetWidth(220)
	frame:SetHeight(260)
	frame:SetScale(0.8)
	frame:SetPoint("CENTER", nil, "CENTER", 0, 0)
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
	frame.showthis = false

	frame:SetScript("OnMouseDown", function()
		if arg1 == "LeftButton" and not frame.isMoving then
			frame:StartMoving();
			frame.isMoving = true;
		end
	end)

	frame:SetScript("OnMouseUp", function()
		if arg1 == "LeftButton" and frame.isMoving then
			frame:StopMovingOrSizing();
			frame.isMoving = false;
		end
	end)

	frame:SetScript("OnHide", function()
		if frame.isMoving then
			frame:StopMovingOrSizing();
			frame.isMoving = false;
		end
	end)


	-- Title
    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -16)
    title:SetText(sTitle)
	

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
	

	-- Tomtom Support checkbutton
	local tomtomCheckBtn = CreateFrame("checkButton", "VG_SettingsFrame_TomTomCheckButton", frame, "UICheckButtonTemplate")
	tomtomCheckBtn:SetWidth(14)
	tomtomCheckBtn:SetHeight(14)
	tomtomCheckBtn:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -45)

	getglobal(tomtomCheckBtn:GetName() .. 'Text'):SetText("   TomTom Support")

	tomtomCheckBtn:SetScript("OnShow", function()
		if TomTom ~= nil then
			tomtomCheckBtn:Enable()
		else
			tomtomCheckBtn:Disable()
		end
		if tomtomCheckBtn:IsEnabled() then
			if tomtomState then
				tomtomCheckBtn:SetChecked(true)
			else
				tomtomCheckBtn:SetChecked(false)
			end
		else
			tomtomCheckBtn:SetChecked(false)
		end
	end)

	tomtomCheckBtn:SetScript("OnClick", function()
		if arg1 == "LeftButton" then
			tomtomState = tomtomCheckBtn:GetChecked()
			oSettings:SetSettingsTomTom(tomtomState)
			if not tomtomState then
				TomTom:RemoveAllWaypoints()
			else
				VGuide.UI.fMain:RefreshTomTom()
			end
		end
	end)


	-- Guide Opacity Slider
	local opacityValue = math.floor(nOpacity * 100)
	local opacitySlider = CreateFrame("Slider", "VG_SettingsFrame_OpacitySlider", frame, "OptionsSliderTemplate")
	opacitySlider:SetOrientation("HORIZONTAL")
	opacitySlider:SetWidth(195)
	opacitySlider:SetHeight(14)
	opacitySlider:SetPoint("TOP", frame, "TOP", 0, -100)
	opacitySlider:SetValueStep(1)
	opacitySlider:SetMinMaxValues(15, 100)
	opacitySlider:SetValue(opacityValue)

	getglobal(opacitySlider:GetName() .. 'Text'):SetText("Opacity")
	getglobal(opacitySlider:GetName() .. 'Low'):SetText("15%")
	getglobal(opacitySlider:GetName() .. 'High'):SetText("100%")

	local opacityText = opacitySlider:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	opacityText:SetTextColor(.59, .59, .59, 1)
	opacityText:SetJustifyH("CENTER")
	opacityText:SetJustifyV("BOTTOM")
	opacityText:SetPoint("CENTER", opacitySlider, "BOTTOM", 0, -2)
	opacityText:SetText(tostring(opacityValue) .. "%")
	opacitySlider.fs = opacityText

	opacitySlider:SetScript("OnValueChanged", function()
		local nVal = arg1
		local frame = getglobal("VG_MainFrame")
		local tUI = oSettings:GetSettingsUI()

		frame:SetAlpha(nVal/100)
		tUI.Opacity = nVal/100
		oSettings:SetSettingsUI(tUI)
		opacitySlider.fs:SetText(nVal.."%")
	end)


	-- Guide Scale Slider
	local scaleValue = math.floor(nScale * 100)
	local scaleSlider = CreateFrame("Slider", "VG_SettingsFrame_ScaleSlider", frame, "OptionsSliderTemplate")
	scaleSlider:SetOrientation("HORIZONTAL")
	scaleSlider:SetWidth(195)
	scaleSlider:SetHeight(14)
	scaleSlider:SetPoint("TOP", frame, "TOP", 0, -150)
	scaleSlider:SetValueStep(1)
	scaleSlider:SetMinMaxValues(50, 175)
	scaleSlider:SetValue(scaleValue)

	getglobal(scaleSlider:GetName() .. 'Text'):SetText("Scale")
	getglobal(scaleSlider:GetName() .. 'Low'):SetText("50%")
	getglobal(scaleSlider:GetName() .. 'High'):SetText("175%")

	local scaleText = scaleSlider:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	scaleText:SetTextColor(.59, .59, .59, 1)
	scaleText:SetJustifyH("CENTER")
	scaleText:SetJustifyV("BOTTOM")
	scaleText:SetPoint("CENTER", scaleSlider, "BOTTOM", 0, -2)
	scaleText:SetText(tostring(scaleValue) .. "%")
	scaleSlider.fs = scaleText

	scaleSlider:SetScript("OnValueChanged", function()
		local nVal = arg1
		local frame = getglobal("VG_MainFrame")
		frame:SetScale(nVal / 100)
		tUI.Scale = nVal/100
		oSettings:SetSettingsUI(tUI)
		scaleSlider.fs:SetText(nVal.."%")
	end)


	-- Guide Layer Slider
	local layerValue = Layers[sLayer]
	local layerSlider = CreateFrame("Slider", "VG_SettingsFrame_LayerSlider", frame, "OptionsSliderTemplate")
	layerSlider:SetOrientation("HORIZONTAL")
	layerSlider:SetWidth(195)
	layerSlider:SetHeight(14)
	layerSlider:SetPoint("TOP", frame, "TOP", 0, -200)
	layerSlider:SetValueStep(1)
	layerSlider:SetMinMaxValues(1, 5)
	layerSlider:SetValue(layerValue)

	getglobal(layerSlider:GetName() .. 'Text'):SetText("Layer")
	getglobal(layerSlider:GetName() .. 'Low'):SetText("BG")
	getglobal(layerSlider:GetName() .. 'High'):SetText("DIALOG")

	local layerText = layerSlider:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	layerText:SetTextColor(.59, .59, .59, 1)
	layerText:SetJustifyH("CENTER")
	layerText:SetJustifyV("BOTTOM")
	layerText:SetPoint("CENTER", layerSlider, "BOTTOM", 0, -2)
	layerText:SetText(sLayer)
	layerSlider.fs = layerText

	layerSlider:SetScript("OnValueChanged", function()
		local nVal = arg1
		local frame = getglobal("VG_MainFrame")
		tUI.Layer = Layers[nVal]
		oSettings:SetSettingsUI(tUI)
		frame:SetFrameStrata(tUI.Layer)
		layerSlider.fs:SetText(tUI.Layer)
	end)


	-- Widgets
	obj.tWidgets = {
		frame_SettingsFrame = frame,
		fs_Title = title,
		button_CloseButton = closeBtn,
		button_TomTomSupport = tomtomCheckBtn,
		slider_Opacity = opacitySlider,
		slider_Scale = scaleSlider,
		slider_Layer = layerSlider,
	}

	obj.ShowFrame = function(self)
		local f = obj.tWidgets.frame_SettingsFrame
		if not f:IsVisible() then
			f:Show()
		end
	end

	obj.HideFrame = function(self)
		local f = obj.tWidgets.frame_SettingsFrame
		if f:IsVisible() then
			f:Hide()
		end
	end

	frame:Hide()

	return obj
end
