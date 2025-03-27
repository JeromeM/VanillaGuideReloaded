--[[--------------------------------------------------
----- VanillaGuide -----
------------------
Frame_SettingsFrame.lua
Authors: mrmr
Version: 1.05
------------------------------------------------------
Description: 
    Settings Frame management for VanillaGuide
    1.05
        -- Refactored to integrate with VGuide
        -- Removed objSettingsFrame, methods attached to VGuide
        -- Updated for TomTom support
------------------------------------------------------]]

function VGuide:InitializeSettingsFrame(fParent, tTexture)
    fParent = fParent or nil
    local tCharInfo = self.Settings:GetSettingsCharInfo()
    local tUI = self.Settings:GetSettingsUI()
    local tTomTom = self.Settings:GetSettingsTomTom()

    local bMinimapToggle = tUI.MinimapToggle
    local nMinimapPos = tUI.MinimapPos
    local nStepScroll = tUI.StepScroll
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

    -- Rendering functions
    local function Render_SF(fParent, sName)
        local frame = CreateFrame("Frame", sName)
        frame:SetScale(1)
        frame:SetFrameStrata("TOOLTIP")
        frame:SetWidth(220)
        frame:SetHeight(315)
        frame:SetPoint("CENTER", nil, "CENTER", 0, 0)
        frame:SetBackdrop(tTexture.BACKDROP)
        frame:SetBackdropColor(.01, .01, .01, .91)
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:SetClampedToScreen(true)
        frame:RegisterForDrag("LeftButton")
        frame.showthis = false
        return frame
    end

    local function Render_SFCloseButton(fParent, tTexture, sName)
        local btn = CreateFrame("Button", sName, fParent)
        btn:SetWidth(16)
        btn:SetHeight(16)
        btn:SetNormalTexture(tTexture.B_CLOSE.NORMAL)
        btn:SetPushedTexture(tTexture.B_CLOSE.PUSHED)
        btn:SetHighlightTexture(tTexture.B_CLOSE.HIGHLIGHT)
        btn:SetPoint("TOPRIGHT", fParent, "TOPRIGHT", -5, -5)
        return btn
    end

    local function Render_SFTomTomSupportCheckBox(fParent, sName, tTomTom)
        local chkbtn = CreateFrame("CheckButton", sName, fParent, "UICheckButtonTemplate")
        chkbtn:SetWidth(20)
        chkbtn:SetHeight(20)
        chkbtn.tooltip = "Enable the use of TomTom pointing arrow."
        getglobal(chkbtn:GetName() .. 'Text'):SetText("   TomTom Support")
        if tTomTom.Presence then
            chkbtn:Enable()
        else
            chkbtn:Disable()
        end
        if chkbtn:IsEnabled() then
            chkbtn:SetChecked(tTomTom.ArrowEnable)
        else
            chkbtn:SetChecked(false)
        end
        return chkbtn
    end

    local function Render_SFMinimapCheckBox(fParent, sName)
        local checkbutton = CreateFrame("CheckButton", sName, fParent, "UICheckButtonTemplate")
        checkbutton:SetWidth(20)
        checkbutton:SetHeight(20)
        checkbutton:SetPoint("TOPLEFT", fParent, "TOPLEFT", 10, -10)
        getglobal(checkbutton:GetName() .. 'Text'):SetText("Minimap Button")
        checkbutton:SetChecked(bMinimapToggle)
        return checkbutton
    end

    local function Render_SFColorSwatch(fParent, sText, tUI)
        local tCol = nil
        if sText == "VG_MainFrame" then
            tCol = tUI.MainFrameColor
        elseif sText == "VG_MainFrame_StepFrame" then
            tCol = tUI.StepFrameColor
        elseif sText == "VG_MainFrame_ScrollFrame" then
            tCol = tUI.ScrollFrameColor
        elseif sText == "VG_MainFrame_StepFrameLabel" then
            tCol = tUI.StepFrameTextColor
        elseif sText == "VG_MainFrame_ScrollFrameLabels" then
            tCol = tUI.ScrollFrameTextColor
        end
        local sSwatchName = "VG_ColorSwatch" .. "_" .. sText
        local btn = CreateFrame("Button", sSwatchName, fParent)
        local background = btn:CreateTexture(nil, "BACKGROUND")
        background:SetWidth(16)
        background:SetHeight(16)
        background:SetPoint("CENTER", 0, 0)
        background:SetTexture(.3, .3, .3, 1)
        local artwork = btn:CreateTexture(nil, "ARTWORK")
        artwork:SetWidth(13)
        artwork:SetHeight(13)
        artwork:SetPoint("CENTER", 0, 0)
        artwork:SetTexture(tCol.nR, tCol.nG, tCol.nB, tCol.nA)
        btn.background = background
        btn.artwork = artwork
        btn:SetWidth(16)
        btn:SetHeight(16)
        btn:SetNormalTexture(artwork)
        btn:SetScript("OnClick", function()
            local frame = getglobal(sText)
            local tCol = nil
            local opacitySlider = nil 
            if sText == "VG_MainFrame" then
                tCol = tUI.MainFrameColor
                opacitySlider = true
            elseif sText == "VG_MainFrame_StepFrame" then
                tCol = tUI.StepFrameColor
                opacitySlider = true
            elseif sText == "VG_MainFrame_ScrollFrame" then
                tCol = tUI.ScrollFrameColor
                opacitySlider = true
            elseif sText == "VG_MainFrame_StepFrameLabel" then
                tCol = tUI.StepFrameTextColor
                opacitySlider = false
            elseif sText == "VG_MainFrame_ScrollFrameLabels" then
                tCol = tUI.ScrollFrameTextColor
                opacitySlider = false
            end
            
            local r1, g1, b1, a1 = tCol.nR, tCol.nG, tCol.nB, tCol.nA
            if ColorPickerFrame:IsShown() then
                ColorPickerFrame:Hide()
            else
                ColorPickerFrame.func = function(pV)
                    local nr, ng, nb, na
                    if pV then
                        nr, ng, nb, na = pV.r, pV.g, pV.b, pV.a
                        ColorPickerFrame.previousValues = {}
                    else
                        nr, ng, nb = ColorPickerFrame:GetColorRGB()
                        na = 1 - OpacitySliderFrame:GetValue()
                    end
                    r1, g1, b1, a1 = nr, ng, nb, na
                    btn.artwork:SetVertexColor(r1, g1, b1, a1)
                    if sText == "VG_MainFrame" then 
                        frame:SetBackdropColor(r1, g1, b1, a1)
                        tUI.MainFrameColor = { nR = r1, nG = g1, nB = b1, nA = a1 }
                        VGuide.Settings:SetSettingsUI(tUI)
                    elseif sText == "VG_MainFrame_StepFrame" then
                        frame:SetBackdropColor(r1, g1, b1, a1)
                        tUI.StepFrameColor = { nR = r1, nG = g1, nB = b1, nA = a1 }
                        VGuide.Settings:SetSettingsUI(tUI)
                    elseif sText == "VG_MainFrame_ScrollFrame" then
                        frame:SetBackdropColor(r1, g1, b1, a1)
                        tUI.ScrollFrameColor = { nR = r1, nG = g1, nB = b1, nA = a1 }
                        VGuide.Settings:SetSettingsUI(tUI)
                    elseif sText == "VG_MainFrame_StepFrameLabel" then
                        a1 = .99
                        frame:SetTextColor(r1, g1, b1, a1)
                        tUI.StepFrameTextColor = { nR = r1, nG = g1, nB = b1, nA = a1 }
                        VGuide.Settings:SetSettingsUI(tUI)
                    elseif sText == "VG_MainFrame_ScrollFrameLabels" then
                        local frame = getglobal("VG_MainFrame_ScrollFrameChild")
                        local shEH = frame.Entries
                        a1 = .71
                        for _, v in pairs(shEH) do
                            v:SetTextColor(r1, g1, b1, a1)
                        end
                        tUI.ScrollFrameTextColor = { nR = r1, nG = g1, nB = b1, nA = a1 }
                        VGuide.Settings:SetSettingsUI(tUI)
                    end
                end
                ColorPickerFrame.cancelFunc = ColorPickerFrame.func
                ColorPickerFrame.opacityFunc = ColorPickerFrame.func
                ColorPickerFrame.hasOpacity = opacitySlider
                ColorPickerFrame.opacity = 1 - a1
                ColorPickerFrame.previousValues = { r = r1, g = g1, b = b1, a = a1 }
                ColorPickerFrame:SetColorRGB(r1, g1, b1, a1)
                ColorPickerFrame:Hide() -- Need to run the OnShow handler.
                ColorPickerFrame:Show()
            end
        end)
        return btn
    end

    local function Render_SFColorSwatchLabel(fParent, sText)
        local fs = fParent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        fs:SetPoint("LEFT", fParent, "RIGHT", 10, 0)
        fs:SetText(sText)
        return fs
    end

    local function Render_Button(fParent, sName, nWidth, nHeight, tTexture)
        local btn = CreateFrame("Button", sName, fParent)
        btn:SetWidth(nWidth)
        btn:SetHeight(nHeight)
        btn:SetNormalTexture(tTexture.NORMAL)
        btn:SetPushedTexture(tTexture.PUSHED)
        btn:SetHighlightTexture(tTexture.HIGHLIGHT)
        btn:RegisterForClicks("LeftButtonUp")
        return btn
    end

    local function Render_SFSlider(fParent, sName, sText, sLow, sHigh, nMin, nMax, nValue, sAppend)
        local sldr = CreateFrame("Slider", sName, fParent, "OptionsSliderTemplate")
        sldr:SetOrientation("HORIZONTAL")
        sldr:SetWidth(195)
        sldr:SetHeight(14)
        getglobal(sldr:GetName() .. 'Text'):SetText(sText)
        getglobal(sldr:GetName() .. 'Low'):SetText(sLow)
        getglobal(sldr:GetName() .. 'High'):SetText(sHigh)
        sldr:SetValueStep(1)
        sldr:SetMinMaxValues(nMin, nMax)
        sldr:SetValue(nValue)
        local fs = sldr:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        fs:SetTextColor(.59, .59, .59, 1)
        fs:SetJustifyH("CENTER")
        fs:SetJustifyV("BOTTOM")
        fs:SetPoint("CENTER", sldr, "BOTTOM", 0, -2)
        if sAppend then
            fs:SetText(tostring(nValue) .. sAppend)
        else
            fs:SetText(tostring(nValue))
        end
        sldr.fs = fs
        return sldr
    end

    -- Initialize SettingsFrame widgets
    self.SettingsFrame = { tWidgets = {} }
    local sf = self.SettingsFrame.tWidgets

    -- Rendering
    sf.frame_SettingFrame = Render_SF(fParent, "VG_SettingsFrame")
    sf.button_CloseButton = Render_Button(sf.frame_SettingFrame, nil, 16, 16, tTexture.B_CLOSE)
    sf.button_CloseButton:SetPoint("TOPRIGHT", sf.frame_SettingFrame, "TOPRIGHT", -5, -5)
    
    sf.checkbutton_TomTomSupport = Render_SFTomTomSupportCheckBox(sf.frame_SettingFrame, "VG_SettingsFrame_TomTomCheckButton", tTomTom)
    sf.checkbutton_TomTomSupport:SetPoint("TOPLEFT", sf.frame_SettingFrame, "TOPLEFT", 8, -20)
    
    sf.colorpicker_StepFrameTextColor = Render_SFColorSwatch(sf.frame_SettingFrame, "VG_MainFrame_StepFrameLabel", tUI)
    sf.colorpicker_StepFrameTextColor:SetPoint("TOPLEFT", sf.frame_SettingFrame, "TOPLEFT", 10, -45)
    sf.fs_ColorPickerStepFrameTextColor = Render_SFColorSwatchLabel(sf.colorpicker_StepFrameTextColor, "StepFrame TextColor")
    
    sf.colorpicker_ScrollFrameTextColor = Render_SFColorSwatch(sf.frame_SettingFrame, "VG_MainFrame_ScrollFrameLabels", tUI)
    sf.colorpicker_ScrollFrameTextColor:SetPoint("TOPLEFT", sf.frame_SettingFrame, "TOPLEFT", 10, -63)
    sf.fs_ColorPickerScrollFrameTextColor = Render_SFColorSwatchLabel(sf.colorpicker_ScrollFrameTextColor, "ScrollFrame TextColor")
    
    sf.colorpicker_MainFrame = Render_SFColorSwatch(sf.frame_SettingFrame, "VG_MainFrame", tUI)
    sf.colorpicker_MainFrame:SetPoint("TOPLEFT", sf.frame_SettingFrame, "TOPLEFT", 10, -93)
    sf.fs_ColorPickerMainFrame = Render_SFColorSwatchLabel(sf.colorpicker_MainFrame, "MainFrame Background")

    sf.colorpicker_StepFrame = Render_SFColorSwatch(sf.frame_SettingFrame, "VG_MainFrame_StepFrame", tUI)
    sf.colorpicker_StepFrame:SetPoint("TOPLEFT", sf.frame_SettingFrame, "TOPLEFT", 10, -110)
    sf.fs_ColorPickerStepFrame = Render_SFColorSwatchLabel(sf.colorpicker_StepFrame, "StepFrame Tint")

    sf.colorpicker_ScrollFrame = Render_SFColorSwatch(sf.frame_SettingFrame, "VG_MainFrame_ScrollFrame", tUI)
    sf.colorpicker_ScrollFrame:SetPoint("TOPLEFT", sf.frame_SettingFrame, "TOPLEFT", 10, -127)
    sf.fs_ColorPickerScrollFrame = Render_SFColorSwatchLabel(sf.colorpicker_ScrollFrame, "ScrollFrame Tint")

    sf.slider_StepScroll = Render_SFSlider(sf.frame_SettingFrame, "VG_SettingsFrame_StepScrollSlider", "Value", "15%", "55%", 15, 55, math.floor(nStepScroll*100), "%")
    sf.slider_StepScroll:SetPoint("TOP", sf.frame_SettingFrame, "TOP", 0, -160)
    sf.slider_Opacity = Render_SFSlider(sf.frame_SettingFrame, "VG_SettingsFrame_OpacitySlider", "Opacity", "15%", "100%", 15, 100, math.floor(nOpacity*100), "%")
    sf.slider_Opacity:SetPoint("TOP", sf.frame_SettingFrame, "TOP", 0, -200)
    sf.slider_Scale = Render_SFSlider(sf.frame_SettingFrame, "VG_SettingsFrame_ScaleSlider", "Scale", "25%", "175%", 25, 175, math.floor(nScale*100), "%")
    sf.slider_Scale:SetPoint("TOP", sf.frame_SettingFrame, "TOP", 0, -240)
    sf.slider_Layer = Render_SFSlider(sf.frame_SettingFrame, "VG_SettingsFrame_LayerSlider", "Layer", "BG", "DIALOG", 1, 5, Layers[sLayer], sLayer)
    sf.slider_Layer:SetPoint("TOP", sf.frame_SettingFrame, "TOP", 0, -280)
    sf.slider_Layer.fs:SetText(sLayer)

    -- UI Events Handling
    sf.frame_SettingFrame:SetScript("OnMouseDown", function()
        if arg1 == "LeftButton" and not this.isMoving then
            this:StartMoving()
            this.isMoving = true
        end
    end)
    sf.frame_SettingFrame:SetScript("OnMouseUp", function()
        if arg1 == "LeftButton" and this.isMoving then
            this:StopMovingOrSizing()
            this.isMoving = false
        end
    end)
    sf.frame_SettingFrame:SetScript("OnHide", function()
        if this.isMoving then
            this:StopMovingOrSizing()
            this.isMoving = false
        end
    end)
    sf.button_CloseButton:SetScript("OnClick", function()
        local frame = this:GetParent()
        frame:Hide()
        frame.showthis = false
        VGuide:RefreshTomTom()
    end)

    sf.checkbutton_TomTomSupport:SetScript("OnClick", function()
        if arg1 == "LeftButton" then
            local bVal = this:GetChecked()
            local tTomTom = VGuide.Settings:GetSettingsTomTom()
            tTomTom.ArrowEnable = bVal
            VGuide.Settings:SetSettingsTomTom(tTomTom)
            VGuide:RefreshTomTom()
        end
    end)

    sf.slider_StepScroll:SetScript("OnValueChanged", function()
        local nVal = arg1
        local fMain = getglobal("VG_MainFrame")
        local fStep = getglobal("VG_MainFrame_StepFrame")
        local fScroll = getglobal("VG_MainFrame_ScrollFrame")
        local tUI = VGuide.Settings:GetSettingsUI()
        local bStepFrame = tUI.StepFrameVisible
        local bScrollFrame = tUI.ScrollFrameVisible

        if bStepFrame and bScrollFrame then
            local nfMHeight = fMain:GetHeight()
            local nPer = nfMHeight * (1 - nVal/100)
            local nGap = nPer - (nfMHeight/2)
            fStep:SetPoint("TOPLEFT", fMain, "TOPLEFT", 5, -23)
            fStep:SetPoint("BOTTOMRIGHT", fMain, "RIGHT", -5, nGap)
            fScroll:SetPoint("TOPLEFT", fStep, "BOTTOMLEFT", 0, -2)
        end
        tUI.StepScroll = nVal/100
        VGuide.Settings:SetSettingsUI(tUI)
        this.fs:SetText(nVal.."%")
    end)

    sf.slider_Opacity:SetScript("OnValueChanged", function()
        local nVal = arg1
        local frame = getglobal("VG_MainFrame")
        local tUI = VGuide.Settings:GetSettingsUI()
        frame:SetAlpha(nVal/100)
        tUI.Opacity = nVal/100
        VGuide.Settings:SetSettingsUI(tUI)
        this.fs:SetText(nVal.."%")
    end)

    sf.slider_Scale:SetScript("OnValueChanged", function()
        local nVal = arg1
        local frame = getglobal("VG_MainFrame")
        local tUI = VGuide.Settings:GetSettingsUI()
        frame:SetScale(nVal/100)
        tUI.Scale = nVal/100
        VGuide.Settings:SetSettingsUI(tUI)
        this.fs:SetText(nVal.."%")
    end)
    
    sf.slider_Layer:SetScript("OnValueChanged", function()
        local nVal = arg1
        local frame = getglobal("VG_MainFrame")
        local tUI = VGuide.Settings:GetSettingsUI()
        tUI.Layer = Layers[nVal]
        VGuide.Settings:SetSettingsUI(tUI)
        frame:SetFrameStrata(tUI.Layer)
        this.fs:SetText(tUI.Layer)
    end)

    -- Initialization
    sf.frame_SettingFrame:Hide()

    -- External methods
    function VGuide:ShowSettingsFrame()
        local f = self.SettingsFrame.tWidgets.frame_SettingFrame
        if not f:IsVisible() then
            f:Show()
        end
    end

    function VGuide:HideSettingsFrame()
        local f = self.SettingsFrame.tWidgets.frame_SettingFrame
        if f:IsVisible() then
            f:Hide()
        end
    end
end