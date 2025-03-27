--[[--------------------------------------------------
----- VanillaGuide -----
------------------
Frame_MainFrame.lua
Authors: mrmr, Grommey
Version: 2.0
------------------------------------------------------
Description: 
    Main Frame management for VanillaGuide, including UI rendering
    and TomTom integration.
    2.0
        -- Refactored to attach methods to VGuide
        -- Simplified rendering and event handling
        -- TomTom functions kept here as requested
------------------------------------------------------]]

-- Initialize the main frame within VGuide
function VGuide:InitializeMainFrame(fParent, tTexture)
    if not tTexture then
        Dv("Error: tTexture is nil in InitializeMainFrame")
        return
    end

    local tUI = self.Settings:GetSettingsUI()
    self.MainFrame = { tWidgets = {} }

    -- Rendering functions
    local function Render_MF(fParent, sName, tTexture, tUI)
        local frame = CreateFrame("Frame", sName, fParent)
        frame:SetPoint(tUI.MainFrameAnchor.sFrom, UIParent, tUI.MainFrameAnchor.sTo, tUI.MainFrameAnchor.nX, tUI.MainFrameAnchor.nY)
        frame:SetWidth(tUI.MainFrameSize.nWidth)
        frame:SetHeight(tUI.MainFrameSize.nHeight)
        frame:SetMinResize(320, 320)
        frame:SetMaxResize(640, 840)
        frame:SetMovable(not tUI.Locked)
        frame:SetResizable(not tUI.Locked)
        frame:SetBackdrop(tTexture.BACKDROP)
        frame:SetBackdropColor(tUI.MainFrameColor.nR, tUI.MainFrameColor.nG, tUI.MainFrameColor.nB, tUI.MainFrameColor.nA)
        frame:EnableMouse(true)
        frame:SetClampedToScreen(true)
        frame:RegisterForDrag("LeftButton")

        frame:SetScript("OnMouseDown", function()
            local fStep = getglobal("VG_MainFrame_StepFrame")
            local fScroll = getglobal("VG_MainFrame_ScrollFrame")
            if arg1 == "LeftButton" and not tUI.Locked and not this.isMoving and not this.isResizing then
                local x, y = GetCursorPosition()
                local s = this:GetEffectiveScale()
                x, y = x / s, y / s
                local left, right, bottom, top = this:GetLeft(), this:GetRight(), this:GetBottom(), this:GetTop()
                local bottomStep = fStep:GetBottom()
                local topScroll = fScroll:GetTop()

                if x < left + 5 and y < bottom + 5 then this:StartSizing("BOTTOMLEFT"); this.isResizing = true
                elseif x < left + 5 and y > top - 5 then this:StartSizing("TOPLEFT"); this.isResizing = true
                elseif x > right - 5 and y < bottom + 5 then this:StartSizing("BOTTOMRIGHT"); this.isResizing = true
                elseif x > right - 5 and y > top - 5 then this:StartSizing("TOPRIGHT"); this.isResizing = true
                elseif x < left + 5 then this:StartSizing("LEFT"); this.isResizing = true
                elseif x > right - 5 then this:StartSizing("RIGHT"); this.isResizing = true
                elseif y < bottom + 5 then this:StartSizing("BOTTOM"); this.isResizing = true
                elseif y > top - 5 then this:StartSizing("TOP"); this.isResizing = true
                elseif tUI.StepFrameVisible and tUI.ScrollFrameVisible and x > left + 5 and x < right - 5 and y > topScroll and y < bottomStep then
                    local nH = this:GetHeight()
                    local nC = nH / 2
                    local nGapMin, nGapMax = nH * 0.85 - nC, nH * 0.45 - nC
                    fStep:SetMinResize(fStep:GetWidth(), nC - nGapMin - 23)
                    fStep:SetMaxResize(fStep:GetWidth(), nC - nGapMax - 23)
                    fStep:StartSizing("BOTTOM")
                    fStep.isResizing = true
                else
                    this:StartMoving()
                    this.isMoving = true
                end
            end
        end)

        frame:SetScript("OnMouseUp", function()
            local fStep = getglobal("VG_MainFrame_StepFrame")
            local fSlider = getglobal("VG_SettingsFrame_StepScrollSlider")
            if arg1 == "LeftButton" then
                if this.isMoving then
                    this:StopMovingOrSizing()
                    this.isMoving = false
                    local from, _, to, x, y = this:GetPoint(1)
                    tUI.MainFrameAnchor = { sFrom = from, sTo = to, nX = x, nY = y }
                    VGuide.Settings:SetSettingsUI(tUI)
                elseif this.isResizing then
                    this:StopMovingOrSizing()
                    this.isResizing = false
                end
                if fStep.isResizing then
                    fStep:StopMovingOrSizing()
                    fStep.isResizing = false
                    local newVal = math.floor(fStep:GetHeight() * 100 / this:GetHeight() + 4)
                    if newVal ~= fSlider:GetValue() then fSlider:SetValue(newVal) end
                end
            end
        end)

        frame:SetScript("OnSizeChanged", function()
            local fStep = getglobal("VG_MainFrame_StepFrame")
            local fScroll = getglobal("VG_MainFrame_ScrollFrame")
            local width, height = this:GetWidth(), this:GetHeight()
            if tUI.StepFrameVisible and not tUI.ScrollFrameVisible then
                height = height / tUI.StepScroll
            elseif tUI.StepFrameVisible and tUI.ScrollFrameVisible then
                local Per = height * (1 - tUI.StepScroll)
                local Gap = Per - (height / 2)
                fStep:SetPoint("BOTTOMRIGHT", this, "RIGHT", -5, Gap)
                fScroll:SetPoint("TOPLEFT", fStep, "BOTTOMLEFT", 0, -2)
            end
            tUI.MainFrameSize = { nWidth = width, nHeight = height }
            VGuide.Settings:SetSettingsUI(tUI)
        end)

        frame:SetScript("OnHide", function()
            if this.isMoving or this.isResizing then this:StopMovingOrSizing() end
            this.isMoving = false
            this.isResizing = false
        end)

        return frame
    end

    local function Render_MFTitle(fParent)
        local version = GetAddOnMetadata("VanillaGuide", "Version")
        local fs = fParent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        fs:SetPoint("TOPLEFT", fParent, "TOPLEFT", 31, -6)
        fs:SetTextColor(.91, .79, .11, 1)
        fs:SetText("|cccff1919Vanilla|ccceeeeeeGuide |ccca1a1a1v|ccc4a4aa1" .. version .. "|r")
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

    local function Render_MFStepFrame(fParent, sName, tTexture, tUI)
        local frame = CreateFrame("Frame", sName, fParent)
        frame:SetResizable(true)
        frame:SetBackdrop(tTexture.BACKDROP)
        frame:SetBackdropColor(tUI.StepFrameColor.nR, tUI.StepFrameColor.nG, tUI.StepFrameColor.nB, tUI.StepFrameColor.nA)
        frame:SetScript("OnHide", function()
            if this.isMoving or this.isResizing then this:StopMovingOrSizing() end
            this.isMoving = false
            this.isResizing = false
        end)
        return frame
    end

    local function Render_MFStepLabel(fParent, sName, tUI)
        local fs = fParent:CreateFontString(sName, "ARTWORK", "GameFontNormalSmall")
        fs:SetPoint("TOPLEFT", fParent, "TOPLEFT", 5, -5)
        fs:SetPoint("BOTTOMRIGHT", fParent, "BOTTOMRIGHT", -5, 5)
        fs:SetTextColor(tUI.StepFrameTextColor.nR, tUI.StepFrameTextColor.nG, tUI.StepFrameTextColor.nB, tUI.StepFrameTextColor.nA)
        fs:SetJustifyH("LEFT")
        fs:SetJustifyV("TOP")
        return fs
    end

    local function Render_MFScrollFrame(fParent, sName, tTexture, tUI)
        local frame = CreateFrame("ScrollFrame", sName, fParent)
        frame:SetBackdrop(tTexture.BACKDROP)
        frame:SetBackdropColor(tUI.ScrollFrameColor.nR, tUI.ScrollFrameColor.nG, tUI.ScrollFrameColor.nB, tUI.ScrollFrameColor.nA)
        frame:EnableMouseWheel(true)
        frame:SetScript("OnSizeChanged", function() VGuide:RefreshScrollFrame() end)
        frame:SetScript("OnMouseWheel", function()
            local fSlider = getglobal("VG_MainFrame_ScrollFrameSlider")
            local current, step = fSlider:GetValue(), fSlider:GetValueStep()
            local smin, smax = fSlider:GetMinMaxValues()
            if IsShiftKeyDown() and arg1 > 0 then fSlider:SetValue(0)
            elseif IsShiftKeyDown() and arg1 < 0 then fSlider:SetValue(smax)
            elseif arg1 < 0 and current < smax then fSlider:SetValue(current + 20)
            elseif arg1 > 0 and current > 1 then fSlider:SetValue(current - 20)
            end
        end)
        return frame
    end

    local function Render_MFScrollFrameChild(fParent, sName)
        local frame = CreateFrame("Frame", sName, fParent)
        frame:SetWidth(fParent:GetWidth() - 10)
        frame:SetHeight(fParent:GetHeight() - 10)
        frame.Entries = {}
        frame.nFSTotalWidth = 0
        frame.nFSTotalHeight = 0
        return frame
    end

    local function Render_MFScrollFrameSlider(fParent, sName)
        local sld = CreateFrame("Slider", sName, fParent)
        sld.background = sld:CreateTexture(nil, "BACKGROUND")
        sld.background:SetAllPoints(true)
        sld.background:SetTexture(.0, .0, .0, 0.5)
        sld.thumb = fParent:CreateTexture(nil, "OVERLAY")
        sld.thumb:SetTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
        sld.thumb:SetWidth(31)
        sld.thumb:SetHeight(31)
        sld:SetThumbTexture(sld.thumb)
        sld:SetWidth(14)
        sld:SetOrientation("VERTICAL")
        sld:SetValueStep(10)
        sld:SetScript("OnValueChanged", function() getglobal("VG_MainFrame_ScrollFrame"):SetVerticalScroll(arg1) end)
        return sld
    end

    local function ChangeView()
        local fMain = self.MainFrame.tWidgets.frame_MainFrame
        local fStep = self.MainFrame.tWidgets.frame_StepFrame
        local fScroll = self.MainFrame.tWidgets.frame_ScrollFrame
        local nMainFrameHeight = tUI.MainFrameSize.nHeight

        if tUI.ScrollFrameVisible then
            fMain:SetHeight(nMainFrameHeight)
            fMain:SetMinResize(320, 320)
            fMain:SetMaxResize(640, 640)
        else
            fMain:SetHeight(nMainFrameHeight * tUI.StepScroll)
            fMain:SetMinResize(320, 320 * tUI.StepScroll)
            fMain:SetMaxResize(640, 640 * tUI.StepScroll)
        end

        if tUI.StepFrameVisible and not tUI.ScrollFrameVisible then
            fScroll:Hide()
            fStep:SetPoint("BOTTOMRIGHT", fMain, "BOTTOMRIGHT", -5, 27)
            fStep:Show()
        elseif not tUI.StepFrameVisible and tUI.ScrollFrameVisible then
            fStep:Hide()
            fScroll:SetPoint("TOPLEFT", fMain, "TOPLEFT", 5, -23)
            fScroll:Show()
        elseif tUI.StepFrameVisible and tUI.ScrollFrameVisible then
            local nH = fMain:GetHeight()
            local nGap = (nH - 2 * tUI.StepScroll * nH) / 2
            fStep:SetPoint("BOTTOMRIGHT", fMain, "RIGHT", -5, nGap)
            fScroll:SetPoint("TOPLEFT", fStep, "BOTTOMLEFT", 0, -2)
            fStep:Show()
            fScroll:Show()
        end
    end

    -- Render UI components
    self.MainFrame.tWidgets.frame_MainFrame = Render_MF(nil, "VG_MainFrame", tTexture, tUI)
    self.MainFrame.tWidgets.fs_Title = Render_MFTitle(self.MainFrame.tWidgets.frame_MainFrame)
    self.MainFrame.tWidgets.button_CloseButton = Render_Button(self.MainFrame.tWidgets.frame_MainFrame, nil, 16, 16, tTexture.B_CLOSE)
    self.MainFrame.tWidgets.button_CloseButton:SetPoint("TOPRIGHT", -6, -5)
    self.MainFrame.tWidgets.button_SettingsButton = Render_Button(self.MainFrame.tWidgets.frame_MainFrame, nil, 20, 20, tTexture.B_OPTION)
    self.MainFrame.tWidgets.button_SettingsButton:SetPoint("BOTTOMRIGHT", -6, 5)
    self.MainFrame.tWidgets.button_AboutButton = Render_Button(self.MainFrame.tWidgets.frame_MainFrame, nil, 20, 20, tTexture.B_ABOUT)
    self.MainFrame.tWidgets.button_AboutButton:SetPoint("BOTTOMRIGHT", -27, 5)

    if tUI.Locked then
        self.MainFrame.tWidgets.button_LockButton = Render_Button(self.MainFrame.tWidgets.frame_MainFrame, nil, 16, 16, tTexture.B_LOCKED)
    else
        self.MainFrame.tWidgets.button_LockButton = Render_Button(self.MainFrame.tWidgets.frame_MainFrame, nil, 16, 16, tTexture.B_UNLOCKED)
    end
    self.MainFrame.tWidgets.button_LockButton:SetPoint("TOPLEFT", 6, -5)

    self.MainFrame.tWidgets.button_ChangeViewButton = Render_Button(self.MainFrame.tWidgets.frame_MainFrame, nil, 16, 16, tTexture.B_FLASH)
    self.MainFrame.tWidgets.button_ChangeViewButton:SetPoint("TOPRIGHT", -105, -5)
    self.MainFrame.tWidgets.button_PrevGuideButton = Render_Button(self.MainFrame.tWidgets.frame_MainFrame, nil, 25, 16, tTexture.B_DOUBLEARROWLEFT)
    self.MainFrame.tWidgets.button_PrevGuideButton:SetPoint("BOTTOMRIGHT", -75, 7)
    self.MainFrame.tWidgets.button_NextGuideButton = Render_Button(self.MainFrame.tWidgets.frame_MainFrame, nil, 25, 16, tTexture.B_DOUBLEARROWRIGHT)
    self.MainFrame.tWidgets.button_NextGuideButton:SetPoint("BOTTOMRIGHT", -50, 7)
    self.MainFrame.tWidgets.button_PrevStepButton = Render_Button(self.MainFrame.tWidgets.frame_MainFrame, nil, 25, 16, tTexture.B_DOUBLEARROWLEFT)
    self.MainFrame.tWidgets.button_PrevStepButton:SetPoint("TOPRIGHT", -76, -5)
    self.MainFrame.tWidgets.button_NextStepButton = Render_Button(self.MainFrame.tWidgets.frame_MainFrame, nil, 25, 16, tTexture.B_DOUBLEARROWRIGHT)
    self.MainFrame.tWidgets.button_NextStepButton:SetPoint("TOPRIGHT", -26, -5)
    self.MainFrame.tWidgets.frame_StepFrame = Render_MFStepFrame(self.MainFrame.tWidgets.frame_MainFrame, "VG_MainFrame_StepFrame", tTexture, tUI)
    self.MainFrame.tWidgets.frame_StepFrame:SetPoint("TOPLEFT", 5, -23)
    self.MainFrame.tWidgets.fs_StepFrame = Render_MFStepLabel(self.MainFrame.tWidgets.frame_StepFrame, "VG_MainFrame_StepFrameLabel", tUI)
    self.MainFrame.tWidgets.frame_ScrollFrame = Render_MFScrollFrame(self.MainFrame.tWidgets.frame_MainFrame, "VG_MainFrame_ScrollFrame", tTexture, tUI)
    self.MainFrame.tWidgets.frame_ScrollFrame:SetPoint("BOTTOMRIGHT", -25, 27)
    self.MainFrame.tWidgets.frame_ScrollFrameChild = Render_MFScrollFrameChild(self.MainFrame.tWidgets.frame_ScrollFrame, "VG_MainFrame_ScrollFrameChild")
    self.MainFrame.tWidgets.frame_ScrollFrameChild:SetPoint("TOPLEFT", 0, 0)
    self.MainFrame.tWidgets.slider_ScrollFrameSlider = Render_MFScrollFrameSlider(self.MainFrame.tWidgets.frame_ScrollFrame, "VG_MainFrame_ScrollFrameSlider")
    self.MainFrame.tWidgets.slider_ScrollFrameSlider:SetPoint("TOPLEFT", self.MainFrame.tWidgets.frame_ScrollFrame, "TOPRIGHT", 2, -5)
    self.MainFrame.tWidgets.slider_ScrollFrameSlider:SetPoint("BOTTOMLEFT", self.MainFrame.tWidgets.frame_ScrollFrame, "BOTTOMRIGHT", 2, 5)

    -- UI Event Handlers
    self.MainFrame.tWidgets.button_CloseButton:SetScript("OnClick", function()
        local fMain = self.MainFrame.tWidgets.frame_MainFrame
        local fSettings = getglobal("VG_SettingsFrame")
        local fAbout = getglobal("VG_AboutFrame")
        fMain:Hide()
        if fSettings and fSettings:IsVisible() then fSettings:Hide(); fSettings.showthis = true end
        if fAbout and fAbout:IsVisible() then fAbout:Hide() end
        VGuide:RefreshTomTom()
    end)
    self.MainFrame.tWidgets.button_LockButton:SetScript("OnClick", function()
        tUI.Locked = not tUI.Locked
        if tUI.Locked then
            this:SetNormalTexture(tTexture.B_LOCKED.NORMAL)
            this:SetPushedTexture(tTexture.B_LOCKED.PUSHED)
        else
            this:SetNormalTexture(tTexture.B_UNLOCKED.NORMAL)
            this:SetPushedTexture(tTexture.B_UNLOCKED.PUSHED)
        end
        self.MainFrame.tWidgets.frame_MainFrame:SetMovable(not tUI.Locked)
        self.MainFrame.tWidgets.frame_MainFrame:SetResizable(not tUI.Locked)
        VGuide.Settings:SetSettingsUI(tUI)
    end)
    self.MainFrame.tWidgets.button_SettingsButton:SetScript("OnClick", function()
		local fSettings = getglobal("VG_SettingsFrame")
		if fSettings then
			if fSettings:IsVisible() then
				VGuide:HideSettingsFrame()
			else
				VGuide:ShowSettingsFrame()
			end
		end
	end)
    self.MainFrame.tWidgets.button_AboutButton:SetScript("OnClick", function()
		local fAbout = getglobal("VG_AboutFrame")
		if fAbout then
			if fAbout:IsVisible() then
				VGuide:HideAboutFrame()
			else
				VGuide:ShowAboutFrame()
			end
		end
	end)
    self.MainFrame.tWidgets.button_ChangeViewButton:SetScript("OnClick", function()
        if tUI.StepFrameVisible and tUI.ScrollFrameVisible then
            tUI.StepFrameVisible, tUI.ScrollFrameVisible = true, false
        elseif tUI.StepFrameVisible and not tUI.ScrollFrameVisible then
            tUI.StepFrameVisible, tUI.ScrollFrameVisible = false, true
        else
            tUI.StepFrameVisible, tUI.ScrollFrameVisible = true, true
        end
        VGuide.Settings:SetSettingsUI(tUI)
        ChangeView()
    end)
    self.MainFrame.tWidgets.button_PrevGuideButton:SetScript("OnClick", function()
        self:PrevGuide()
        self:RefreshData()
    end)
    self.MainFrame.tWidgets.button_NextGuideButton:SetScript("OnClick", function()
        self:NextGuide()
        self:RefreshData()
    end)
    self.MainFrame.tWidgets.button_PrevStepButton:SetScript("OnClick", function()
        self:PrevStep()
        self:RefreshData()
    end)
    self.MainFrame.tWidgets.button_NextStepButton:SetScript("OnClick", function()
        self:NextStep()
        self:RefreshData()
    end)

    -- External Methods
    function VGuide:RefreshStepFrameLabel()
		self.MainFrame.tWidgets.fs_StepFrame:SetText(self:GetStepLabel())
	end
	
	function VGuide:RefreshScrollFrame()
		local fScroll = self.MainFrame.tWidgets.frame_ScrollFrame
		local fChild = self.MainFrame.tWidgets.frame_ScrollFrameChild
		local fSlider = self.MainFrame.tWidgets.slider_ScrollFrameSlider
		local scrollFrameWidth = fScroll:GetWidth() / fScroll:GetEffectiveScale()
		local tUI = self.Settings:GetSettingsUI()
		local tTexture = self.Textures
	
		for _, v in pairs(fChild.Entries) do v:Hide() end
		local t = self:GetScrollFrameDisplay()
		fChild.Entries = {}
	
		local totalHeight, tEntries = 0, { textWidth = {}, textHeight = {} }
		local fs = CreateFrame("Frame"):CreateFontString(nil, "ARTWORK", tTexture.FONT)
		fs:SetFont(tTexture.FONT_PATH, tTexture.FONT_HEIGHT)
		for k, v in pairs(t) do
			fs:SetText(v)
			tEntries.textWidth[k] = fs:GetWidth()
			local val = math.floor(tEntries.textWidth[k] / scrollFrameWidth)
			tEntries.textHeight[k] = (val + 1) * tTexture.FONT_HEIGHT + 5
			totalHeight = totalHeight + tEntries.textHeight[k] + tTexture.SCROLLFRAME_PADDING
		end
	
		local nFrameH = fScroll:GetHeight() + 5
		local sliderVisible = totalHeight - nFrameH + 10 > 0
		local shWidth = sliderVisible and (fScroll:GetWidth() - 40) or (fScroll:GetWidth() - 20)
		if sliderVisible then
			fSlider:SetMinMaxValues(0, totalHeight - nFrameH + 10)
			fSlider:Show()
			fScroll:SetPoint("BOTTOMRIGHT", self.MainFrame.tWidgets.frame_MainFrame, "BOTTOMRIGHT", -25, 27)
		else
			fSlider:SetMinMaxValues(0, 0)
			fSlider:SetValue(0)
			fSlider:Hide()
			fScroll:SetPoint("BOTTOMRIGHT", self.MainFrame.tWidgets.frame_MainFrame, "BOTTOMRIGHT", -5, 27)
		end
	
		totalHeight = 0
		local tColF = tUI.StepFrameColor
		for k, v in pairs(t) do
			if k <= self:GetCurrentStepCount() then
				local sh = CreateFrame("SimpleHTML", "VG_shEntry" .. k, fChild)
				sh:SetFont(tTexture.FONT_PATH, tTexture.FONT_HEIGHT)
				sh:SetTextColor(tUI.ScrollFrameTextColor.nR, tUI.ScrollFrameTextColor.nG, tUI.ScrollFrameTextColor.nB, tUI.ScrollFrameTextColor.nA)
				sh:SetBackdrop(tTexture.BACKDROPSH)
				sh:SetBackdropColor(k == self:GetCurrentStep() and tColF.nR or .1, k == self:GetCurrentStep() and tColF.nG or .1, k == self:GetCurrentStep() and tColF.nB or .1, k == self:GetCurrentStep() and tColF.nA or .5)
				sh:SetJustifyH("LEFT")
				sh:SetJustifyV("TOP")
				sh:SetPoint("TOPLEFT", k > 1 and fChild.Entries[k-1] or fChild, k > 1 and "BOTTOMLEFT" or "TOPLEFT", 0, k > 1 and -tTexture.SCROLLFRAME_PADDING or -15)
				sh:SetWidth(shWidth)
				sh:SetHeight(tEntries.textHeight[k])
				sh:SetText(v)
				sh:Show()
				sh:SetScript("OnEnter", function() this:SetTextColor(.91, .91, .91, .99); this:SetBackdropColor(.3, .3, .3, .7) end)
				sh:SetScript("OnLeave", function()
					this:SetTextColor(tUI.ScrollFrameTextColor.nR, tUI.ScrollFrameTextColor.nG, tUI.ScrollFrameTextColor.nB, tUI.ScrollFrameTextColor.nA)
					this:SetBackdropColor(this:GetName():sub(11) == tostring(self:GetCurrentStep()) and tColF.nR or .1, this:GetName():sub(11) == tostring(self:GetCurrentStep()) and tColF.nG or .1, this:GetName():sub(11) == tostring(self:GetCurrentStep()) and tColF.nB or .1, this:GetName():sub(11) == tostring(self:GetCurrentStep()) and tColF.nA or .5)
				end)
				sh:SetScript("OnMouseUp", function()
					if arg1 == "LeftButton" then
						local step = self:GetCurrentStep()
						fChild.Entries[step]:SetBackdropColor(.1, .1, .1, .5)
						local tx = tonumber(this:GetName():sub(11))
						self:StepByID(tx)
						self:RefreshData()
					end
				end)
				fChild.Entries[k] = sh
				totalHeight = totalHeight + tEntries.textHeight[k] + tTexture.SCROLLFRAME_PADDING
			end
		end
		fChild:SetHeight(totalHeight - tTexture.SCROLLFRAME_PADDING)
		fScroll:UpdateScrollChildRect()
	end
	
	function VGuide:RefreshTomTom()
		if IsAddOnLoaded("TomTom") then
			local tTomTom = self.Settings:GetSettingsTomTom()
			if tTomTom.Presence then
				local title = self:GetGuideTitle()
				local t = self:GetCurrentStepInfo()
				if tTomTom.ArrowEnable then
					self:SetTomTomDestination(t.x, t.y, t.zone, title)
				else
					TomTom:RemoveAllWaypoints()
				end
			end
		end
	end
	
	function VGuide:RefreshData()
		self:RefreshStepFrameLabel()
		self:RefreshScrollFrame()
		self:RefreshTomTom()
	end

    function VGuide:SetTomTomDestination(nX, nY, sZone, title)
        if not ZoneMapIDs or not TomTom then return end
        TomTom:RemoveAllWaypoints()

        local continentId = ZoneMapIDs:GetContinentID(sZone)
        local zoneIndex = ZoneMapIDs:GetZoneIndex(sZone)
        if continentId and zoneIndex and type(nX) == "number" and type(nY) == "number" then
            TomTom:AddMFWaypoint(continentId, zoneIndex, nX / 100, nY / 100, { title = title })
        end
    end

    -- Initialization
    ChangeView()
    self.MainFrame.tWidgets.frame_ScrollFrame:SetScrollChild(self.MainFrame.tWidgets.frame_ScrollFrameChild)
    self:RefreshData()
    self.MainFrame.tWidgets.frame_MainFrame:SetAlpha(tUI.Opacity)
    self.MainFrame.tWidgets.frame_MainFrame:SetScale(tUI.Scale)
    self.MainFrame.tWidgets.frame_MainFrame:SetFrameStrata(tUI.Layer)
end