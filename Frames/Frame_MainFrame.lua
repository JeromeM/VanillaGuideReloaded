--[[
Vanilla Guide Reloaded

Author: Grommey (originally by mrmr)
Version: 2.0.0

Description:
Implements the main frame UI component for the addon.
Handles the display of guide content and user interactions.
Part of the Vanilla Guide Reloaded addon.
]]--

objMainFrame = {}
objMainFrame.__index = objMainFrame

function objMainFrame:new(fParent, tTexture, oSettings, oDisplay)
	fParent = fParent or nil
	local obj = {}
	setmetatable(obj, self)

	local tUI = oSettings:GetSettingsUI()


	-- Main Frame
	local bLocked = tUI.Locked
	local tSize = tUI.MainFrameSize
	local tAnch = tUI.MainFrameAnchor
	local frame = CreateFrame("Frame", "VG_MainFrame", nil)

	frame:ClearAllPoints()
	frame:SetPoint(tAnch.sFrom, UIParent, tAnch.sTo, tAnch.nX, tAnch.nY)
	frame:SetMinResize(320,320)
	frame:SetMaxResize(1200,1600)
	frame:SetWidth(tSize.nWidth)
	frame:SetHeight(tSize.nHeight)
	frame:SetScale(tUI.Scale or 1)
	frame:SetMovable(true)
	frame:SetResizable(true)
	if bLocked then
		frame:SetMovable(false)
		frame:SetResizable(false)
	end
	frame:SetBackdrop(tTexture.BACKDROP)
	frame:SetBackdropColor(.03, .03, .03, .7)
	frame:SetBackdropBorderColor(0, 0, 0, 1)
	frame:EnableMouse(true)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")
	frame.isMoving = nil
	frame.isResizing = nil

	frame:SetScript("OnMouseDown", function()
		local fStep = getglobal("VG_MainFrame_StepFrame")
		local StepFrame = tUI.StepFrameVisible
		local bLocked = tUI.Locked
		local x, y = GetCursorPosition()
		local s = this:GetEffectiveScale()
		x = x / s
		y = y / s
		local bottom = this:GetBottom();
		local top = this:GetTop();
		local left = this:GetLeft();
		local right = this:GetRight();
		local bottomStep = fStep:GetBottom()

		if arg1 == "LeftButton" and not this.isMoving and not this.isResizing and not bLocked then
			if (x < left + 5 and y < bottom + 5) then
				this:StartSizing("BOTTOMLEFT")
				this.isResizing = true
			elseif (x < left + 5 and y > top - 5) then
				this:StartSizing("TOPLEFT")
				this.isResizing = true
			elseif (x > right - 5 and y < bottom + 5) then
				this:StartSizing("BOTTOMRIGHT")
				this.isResizing = true
			elseif (x > right - 5 and y > top - 5) then
				this:StartSizing("TOPRIGHT")
				this.isResizing = true
			elseif (x < left + 5) then
				this:StartSizing("LEFT")
				this.isResizing = true
			elseif (x > right - 5) then
				this:StartSizing("RIGHT")
				this.isResizing = true
			elseif (y < bottom + 5) then
				this:StartSizing("BOTTOM")
				this.isResizing = true
			elseif (y > top - 5) then
				this:StartSizing("TOP")
				this.isResizing = true
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
				tUI.MainFrameAnchor = {
					sFrom = from,
					sTo = to,
					nX = x,
					nY = y,
				}
				oSettings:SetSettingsUI(tUI)
			elseif this.isResizing then
				this:StopMovingOrSizing()
				this.isResizing = false
			end
			if fStep.isResizing then
				fStep:StopMovingOrSizing()
				fStep.isResizing = false
				local nH = fStep:GetHeight()
				local oldVal = fSlider:GetValue()
				local newVal = math.floor(nH * 100 / this:GetHeight() + 4)
				if newVal ~= oldVal then
					fSlider:SetValue(newVal)
				end
			end
		end
	end)

	frame:SetScript("OnSizeChanged", function()
		local fStep = getglobal("VG_MainFrame_StepFrame")
		local StepFrame = tUI.StepFrameVisible
		local StepScroll = tUI.StepScroll
		local width = this:GetWidth()
		local height = this:GetHeight()
		height = height / StepScroll
		tUI.MainFrameSize = {
			nWidth = width,
			nHeight = height,
		}
		oSettings:SetSettingsUI(tUI)
	end)

	frame:SetScript("OnHide", function()
		if this.isMoving then
			this:StopMovingOrSizing();
			this.isMoving = false;
		end
		if this.isResizing then
			this:StopMovingOrSizing();
			this.isResizing = false;
		end
	end)
		

	-- Title
	local version = GetAddOnMetadata("VanillaGuideReloaded", "Version")
	local fsTitle = frame:CreateFontString("VG_MainFrame_Title", "ARTWORK", "GameFontNormalSmall")
	fsTitle:SetPoint("TOPLEFT", frame, "TOPLEFT", 31, -6)
	fsTitle:SetTextColor(.91, .79, .11, 1)
	fsTitle:SetJustifyH("CENTER")
	fsTitle:SetJustifyV("CENTER")
	fsTitle:SetText("|ccc4a4aa1Vanilla|ccca1a1a1Guide|cccff1919Reloaded|r v" .. version)


	-- Close Button
	local closeButton = CreateFrame("Button", nil, frame)
	closeButton:SetWidth(16)
	closeButton:SetHeight(16)
	closeButton:SetNormalTexture(tTexture.B_CLOSE.NORMAL)
	closeButton:SetPushedTexture(tTexture.B_CLOSE.PUSHED)
	closeButton:SetHighlightTexture(tTexture.B_CLOSE.HIGHLIGHT)
	closeButton:RegisterForClicks("LeftButtonUp")
	closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -6, -5)

	closeButton:SetScript("OnClick", function()
		local fMain = getglobal("VG_MainFrame")
		local fSettings = getglobal("VG_SettingsFrame")
		local fAbout = getglobal("VG_AboutFrame")
		fMain:Hide()
		if fSettings:IsVisible() then
			fSettings:Hide()
			fSettings.showthis = true
		end
		if fAbout:IsVisible() then
			fAbout:Hide()
		end
	end)

	
	-- Settings Button
	local settingsButton = CreateFrame("Button", nil, frame)
	settingsButton:SetWidth(20)
	settingsButton:SetHeight(20)
	settingsButton:SetNormalTexture(tTexture.B_OPTION.NORMAL)
	settingsButton:SetPushedTexture(tTexture.B_OPTION.PUSHED)
	settingsButton:SetHighlightTexture(tTexture.B_OPTION.HIGHLIGHT)
	settingsButton:RegisterForClicks("LeftButtonUp")
	settingsButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -6, 5)

	settingsButton:SetScript("OnClick", function()
		local fSettings = getglobal("VG_SettingsFrame")
		if fSettings:IsVisible() then
			fSettings:Hide()
		else
			fSettings:Show()
		end
	end)


	-- About Button
	local aboutButton = CreateFrame("Button", nil, frame)
	aboutButton:SetWidth(20)
	aboutButton:SetHeight(20)
	aboutButton:SetNormalTexture(tTexture.B_ABOUT.NORMAL)
	aboutButton:SetPushedTexture(tTexture.B_ABOUT.PUSHED)
	aboutButton:SetHighlightTexture(tTexture.B_ABOUT.HIGHLIGHT)
	aboutButton:RegisterForClicks("LeftButtonUp")
	aboutButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -27, 5)

	aboutButton:SetScript("OnClick", function()
		local fAbout = getglobal("VG_AboutFrame")
		if fAbout:IsVisible() then
			fAbout:Hide()
		else
			fAbout:Show()
		end
	end)


	-- Lock Button
	local lockTexture = tUI.Locked and tTexture.B_LOCKED or tTexture.B_UNLOCKED
	local lockButton = CreateFrame("Button", nil, frame)
	lockButton:SetWidth(16)
	lockButton:SetHeight(16)
	lockButton:SetNormalTexture(lockTexture.NORMAL)
	lockButton:SetPushedTexture(lockTexture.PUSHED)
	lockButton:SetHighlightTexture(lockTexture.HIGHLIGHT)
	lockButton:RegisterForClicks("LeftButtonUp")
	lockButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 6, -5)

	lockButton:SetScript("OnClick", function()
		local bLocked = tUI.Locked
		local frame = getglobal("VG_MainFrame")
		if bLocked then
			this:SetNormalTexture(tTexture.B_UNLOCKED.NORMAL)
			this:SetPushedTexture(tTexture.B_UNLOCKED.PUSHED)
			tUI.Locked = false
			oSettings:SetSettingsUI(tUI)
			frame:SetMovable(true)
			frame:SetResizable(true)
		else
			this:SetNormalTexture(tTexture.B_LOCKED.NORMAL)
			this:SetPushedTexture(tTexture.B_LOCKED.PUSHED)
			tUI.Locked = true
			oSettings:SetSettingsUI(tUI)
			frame:SetMovable(false)
			frame:SetResizable(false)
		end
	end)


	-- Previous Step Button
	local prevStepButton = CreateFrame("Button", nil, frame)
	prevStepButton:SetWidth(25)
	prevStepButton:SetHeight(16)
	prevStepButton:SetNormalTexture(tTexture.B_DOUBLEARROWLEFT.NORMAL)
	prevStepButton:SetPushedTexture(tTexture.B_DOUBLEARROWLEFT.PUSHED)
	prevStepButton:SetHighlightTexture(tTexture.B_DOUBLEARROWLEFT.HIGHLIGHT)
	prevStepButton:RegisterForClicks("LeftButtonUp")
	prevStepButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -76, -5)

	prevStepButton:SetScript("OnClick", function()
		oDisplay:PrevStep()
		obj:RefreshData()
	end)


	-- Next Step Button
	local nextStepButton = CreateFrame("Button", nil, frame)
	nextStepButton:SetWidth(25)
	nextStepButton:SetHeight(16)
	nextStepButton:SetNormalTexture(tTexture.B_DOUBLEARROWRIGHT.NORMAL)
	nextStepButton:SetPushedTexture(tTexture.B_DOUBLEARROWRIGHT.PUSHED)
	nextStepButton:SetHighlightTexture(tTexture.B_DOUBLEARROWRIGHT.HIGHLIGHT)
	nextStepButton:RegisterForClicks("LeftButtonUp")
	nextStepButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -26, -5)

	nextStepButton:SetScript("OnClick", function()
		oDisplay:NextStep()
		obj:RefreshData()
	end)


	-- Prev Guide Button
	local prevGuideButton = CreateFrame("Button", nil, frame)
	prevGuideButton:SetWidth(25)
	prevGuideButton:SetHeight(16)
	prevGuideButton:SetNormalTexture(tTexture.B_DOUBLEARROWLEFT.NORMAL)
	prevGuideButton:SetPushedTexture(tTexture.B_DOUBLEARROWLEFT.PUSHED)
	prevGuideButton:SetHighlightTexture(tTexture.B_DOUBLEARROWLEFT.HIGHLIGHT)
	prevGuideButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -75, 7)

	prevGuideButton:SetScript("OnClick", function()
		oDisplay:PrevGuide()
		obj:RefreshData()
	end)


	-- Next Guide Button
	local nextGuideButton = CreateFrame("Button", nil, frame)
	nextGuideButton:SetWidth(25)
	nextGuideButton:SetHeight(16)
	nextGuideButton:SetNormalTexture(tTexture.B_DOUBLEARROWRIGHT.NORMAL)
	nextGuideButton:SetPushedTexture(tTexture.B_DOUBLEARROWRIGHT.PUSHED)
	nextGuideButton:SetHighlightTexture(tTexture.B_DOUBLEARROWRIGHT.HIGHLIGHT)
	nextGuideButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -50, 7)

	nextGuideButton:SetScript("OnClick", function()
		oDisplay:NextGuide()
		obj:RefreshData()
	end)


	-- Step Number Frame and Label
	local stepNumberFrame = CreateFrame("Frame", nil, frame)
	stepNumberFrame:SetWidth(25)
	stepNumberFrame:SetHeight(18)
	stepNumberFrame:SetBackdrop(tTexture.BACKDROP)
	stepNumberFrame:SetBackdropColor(.1, .1, .1, .9)
	stepNumberFrame:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -51, -4)

	local fsStepNumber = stepNumberFrame:CreateFontString("VG_MainFrame_StepNumberFrameLabel", "ARTWORK", "GameFontNormalSmall")
	fsStepNumber:SetPoint("CENTER", stepNumberFrame, "CENTER", 0, 0)
	fsStepNumber:SetTextColor(.71, .71, .71, 1)
	fsStepNumber:SetJustifyH("CENTER")
	fsStepNumber:SetJustifyV("CENTER")


	-- Dropdown Menu
	local dropdownFrame = CreateFrame("Frame", "VG_MainFrame_DropDownMenu", frame)
	dropdownFrame.UncheckHack = function()
		getglobal(this:GetName().."Check"):Hide()
	end
	dropdownFrame.displayMode = "MENU"
	dropdownFrame.info = {}
	dropdownFrame:SetHeight(25)
	dropdownFrame:SetWidth(25)
	dropdownFrame:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 12, 26)
	dropdownFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", 22, 3)
	

	-- Dropdown Menu Button
	dropdownMenuButton = CreateFrame("Button", nil, dropdownFrame)
	dropdownMenuButton:SetWidth(16)
	dropdownMenuButton:SetHeight(16)
	dropdownMenuButton:SetNormalTexture(tTexture.B_DDMRIGHT_DOWN.NORMAL)
	dropdownMenuButton:SetPushedTexture(tTexture.B_DDMRIGHT_DOWN.PUSHED)
	dropdownMenuButton:SetHighlightTexture(tTexture.B_DDMRIGHT_DOWN.HIGHLIGHT)
	dropdownMenuButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	dropdownMenuButton:SetPoint("CENTER", dropdownFrame, "LEFT", 3, 0)

	dropdownMenuButton:SetScript("OnClick", function()
		GuideRegistry:ShowMenu(dropdownMenuButton)
	end)


	-- Dropdown Menu Zone Frame and Label
	local dropdownMenuZoneframe = CreateFrame("Frame", nil, dropdownFrame)
	dropdownMenuZoneframe:SetBackdrop(tTexture.BACKDROP);
	dropdownMenuZoneframe:SetBackdropColor(.1, .1, .1, .7)
	dropdownMenuZoneframe:SetPoint("TOPLEFT", dropdownFrame, "TOPLEFT", 5, -2)
	dropdownMenuZoneframe:SetPoint("BOTTOMRIGHT", prevGuideButton, "LEFT", -5, -10)
	
	local fsDropDownMenuZone = dropdownMenuZoneframe:CreateFontString("VG_MainFrame_DropDownMenuLabel", "ARTWORK", "GameFontNormalSmall")
	fsDropDownMenuZone:SetTextColor(.91, .91, .91, 1)
	fsDropDownMenuZone:SetJustifyH("CENTER")
	fsDropDownMenuZone:SetJustifyV("CENTER")
	fsDropDownMenuZone:SetPoint("BOTTOMLEFT", dropdownMenuZoneframe, "BOTTOMLEFT", 15, 6)


	-- Step Frame
	local stepFrame = CreateFrame("Frame", "VG_MainFrame_StepFrame", frame)
	stepFrame:SetResizable(true)
	stepFrame:SetBackdrop(tTexture.BACKDROP)
	stepFrame:SetBackdropColor(.03, .03, .03, .7)
	stepFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -23)

	stepFrame:SetScript("OnHide" , function()
		if this.isMoving then
			this:StopMovingOrSizing();
			this.isMoving = false;
		end
		if this.isResizing then
			this:StopMovingOrSizing();
			this.isResizing = false;
		end
	end)

	local fsStepFrame = stepFrame:CreateFontString("VG_MainFrame_StepFrameLabel", "ARTWORK", "GameFontNormalSmall")
	fsStepFrame:SetPoint("TOPLEFT", stepFrame, "TOPLEFT", 5, -5)
	fsStepFrame:SetPoint("BOTTOMRIGHT", stepFrame, "BOTTOMRIGHT", -5, 5)
	fsStepFrame:SetTextColor(.91, .91, .91, .99)
	fsStepFrame:SetJustifyH("LEFT")
	fsStepFrame:SetJustifyV("TOP")


	obj.tWidgets = {
		frame_MainFrame = frame,
		fs_Title = fsTitle,
		frame_StepFrame = stepFrame,
		fs_StepFrame = fsStepFrame,
		fs_StepNumber = fsStepNumber,
		fs_DropDownMenuZone = fsDropDownMenuZone,
	}


	obj.RefreshStepFrameLabel = function(self)
		local s = oDisplay:GetStepLabel()
		local fs = obj.tWidgets.fs_StepFrame
		fs:SetText(s)
	end

	obj.RefreshStepNumberFrameLabel = function(self)
		local t = oDisplay:GetCurrentStep()
		local fs = obj.tWidgets.fs_StepNumber
		fs:SetText(t)
	end

	obj.RefreshDropDownMenuLabel = function(self)
		local t = oDisplay:GetGuideTitle()
		local fs = obj.tWidgets.fs_DropDownMenuZone
		fs:SetText(t)
	end

	local waypoint = nil
	obj.RefreshTomTom = function(self)
		
		if not TomTom or type(TomTom) ~= "table" or not oSettings:GetSettingsTomTom() then
			if waypoint then

				if TomTom and type(TomTom.RemoveWaypoint) == "function" then
					TomTom:RemoveWaypoint(waypoint)
				end
				waypoint = nil
			end
			return
		end

		local t = oDisplay:GetCurrentStepInfo()
		if not t or not t.x or not t.y or not t.zone then
			if waypoint and TomTom and type(TomTom.RemoveWaypoint) == "function" then
				TomTom:RemoveWaypoint(waypoint)
				waypoint = nil
			end
			return
		end

		if waypoint and TomTom and type(TomTom.RemoveWaypoint) == "function" then
			TomTom:RemoveWaypoint(waypoint)
			waypoint = nil
		end

		if not TomTom.GetZoneInfo or not TomTom.CleanZoneName or not TomTom.AddMFWaypoint then
			DEFAULT_CHAT_FRAME:AddMessage("VanillaGuide: Incorrect TomTom version")
			return
		end

		local success, result = pcall(function()
			local zoneName = type(t.zone) == "string" and t.zone or tostring(t.zone)
			local cleanZone = TomTom:CleanZoneName(zoneName)
			local continent, zone = TomTom:GetZoneInfo(cleanZone)
			
			if not continent or not zone then
				DEFAULT_CHAT_FRAME:AddMessage("VanillaGuide: Can't find zone: " .. tostring(zoneName))
				return nil
			end
			
			local options = { 
				title = string.format("[VG] %s (step %d/%d)", oDisplay:GetGuideTitle(), oDisplay:GetCurrentStep(), oDisplay:GetCurrentStepCount())
			}
			
			return TomTom:AddMFWaypoint(continent, zone, t.x/100, t.y/100, options)
		end)
		
		if not success then
			DEFAULT_CHAT_FRAME:AddMessage("VanillaGuide: Error adding TomTom waypoint: " .. tostring(result))
			waypoint = nil
		else
			waypoint = result
		end
	end
	
	obj.RefreshData = function(self)
		obj:RefreshStepFrameLabel()
		obj:RefreshStepNumberFrameLabel()
		obj:RefreshDropDownMenuLabel()
		obj:RefreshTomTom()
	end

	
	local function ChangeView(tUI)
		local fMain = getglobal("VG_MainFrame")
		local fStep = getglobal("VG_MainFrame_StepFrame")
		local nStepScroll = tUI.StepScroll
		local nMainFrameHeight = tUI.MainFrameSize.nHeight

		fMain:SetHeight(nMainFrameHeight*nStepScroll)
		fMain:SetMinResize(320, 320*nStepScroll)
		fMain:SetMaxResize(1200, 1600*nStepScroll)
		fStep:SetPoint("BOTTOMRIGHT", fMain, "BOTTOMRIGHT", -5, 27)
		fStep:Show()
	end

	do
		ChangeView(tUI)
		obj:RefreshData(true)
		obj.tWidgets.frame_MainFrame:SetAlpha(tUI.Opacity)
		obj.tWidgets.frame_MainFrame:SetScale(tUI.Scale)
		obj.tWidgets.frame_MainFrame:SetFrameStrata(tUI.Layer)
	end

	return obj
end
