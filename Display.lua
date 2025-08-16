--[[
Vanilla Guide Reloaded

Author: Grommey (originally by mrmr)

Description:
Manages the display of guide content in the Main Frame.
Handles step navigation, text formatting, and UI updates.
Part of the Vanilla Guide Reloaded addon.
]]--
VGuide = VGuide or {}

objDisplay = {}
objDisplay.__index = objDisplay

function objDisplay:new(oSettings)
	local obj = {}
    setmetatable(obj, self)

    local tGuideValues = oSettings:GetSettingsGuideValues()

    obj.CurrentStep = tGuideValues.Step
    obj.CurrentGuideID = tGuideValues.GuideID
	obj.PrevGuideID = tGuideValues.PrevGuideID
	obj.NextGuideID = tGuideValues.NextGuideID
    obj.CurrentStepCount = nil

    obj.GuideTitle = nil
    obj.StepFrameDisplay = nil
	obj.StepInfoDisplay = {}

	obj.StepInfoDisplayWipe = function(self)
		for k,_ in ipairs(obj.StepInfoDisplay) do
			obj.StepInfoDisplay[k] = nil
		end
	end

	obj.RetrieveData = function(self)
		
		-- Get guide data from GuideRegistry
		local guideData = VGuide.GuideRegistry:GetGuideByID(obj.CurrentGuideID)
		if not guideData then
			DEFAULT_CHAT_FRAME:AddMessage(string.format("Display: Error - No guide found with ID: %d", obj.CurrentGuideID))
			return
		end
				
		-- Ensure we have valid steps
		if not guideData.steps or type(guideData.steps) ~= "table" or table.getn(guideData.steps) == 0 then
			DEFAULT_CHAT_FRAME:AddMessage(string.format("Display: Error - No valid steps found in guide ID: %d", obj.CurrentGuideID))
			return
		end
		
		local numSteps = 0
		for _ in pairs(guideData.steps) do
		    numSteps = numSteps + 1
		end
		
		-- Ensure current step is within bounds
		obj.CurrentStep = math.max(1, math.min(obj.CurrentStep or 1, numSteps))

		-- Get Prev and Next Guide ID
		if not obj.PrevGuideID or obj.PrevGuideID == 0 then
			obj.PrevGuideID = guideData.prevGuideID or 0
		end
		obj.NextGuideID = guideData.nextGuideID or 0
		
		local count = 0
		obj.GuideTitle = guideData.title or "Untitled Guide"
		
		-- Get the current step data
		local currentStep = guideData.steps[obj.CurrentStep]
		if not currentStep or not currentStep.text then
			DEFAULT_CHAT_FRAME:AddMessage(string.format("Display: Error - Invalid step data in guide ID: %d, Step: %d", 
				obj.CurrentGuideID, obj.CurrentStep))
			return
		end
		
		obj.StepFrameDisplay = currentStep.text
		
		-- Clear existing display data
		obj:StepInfoDisplayWipe()
		
		-- Process all steps
		local stepIndex = 1
		for _, step in pairs(guideData.steps) do
			if step and step.text then
				count = count + 1
				obj.StepInfoDisplay[stepIndex] = {
					x = step.x,
					y = step.y,
					zone = step.zone,
					text = step.text,
				}
				stepIndex = stepIndex + 1
			end
		end
		
		obj.CurrentStepCount = count
		obj:UpdateGuideValuesSettings()
		
	end

	obj.UpdateGuideValuesSettings = function(self)
		tGuideValues.Step = obj.CurrentStep
		tGuideValues.GuideID = obj.CurrentGuideID
		tGuideValues.PrevGuideID = obj.PrevGuideID
		tGuideValues.NextGuideID = obj.NextGuideID
		oSettings:SetSettingsGuideValues(tGuideValues)
	end

	obj.GuideByID = function(self, nGuideID)
		if not nGuideID then
			DEFAULT_CHAT_FRAME:AddMessage("Display: Error - No guide ID provided")
			return false
		end
		
		local bChange = false
		obj.CurrentGuideID = nGuideID
		obj.CurrentStep = 1
		
		local success, errorMsg = pcall(function()
			obj:RetrieveData()
		end)
		
		if not success then
			DEFAULT_CHAT_FRAME:AddMessage("Display: Error in RetrieveData - " .. tostring(errorMsg))
			return false
		end
		
		local mainObj = VGuide and VGuide.UI and VGuide.UI.fMain
		if mainObj then
			if mainObj.RefreshData then
				mainObj:RefreshData()
			else
				local refreshMethods = {
					"RefreshStepFrameLabel",
					"RefreshStepNumberFrameLabel",
					"RefreshDropDownMenuLabel",
					"RefreshTomTom"
				}
				
				for _, methodName in ipairs(refreshMethods) do
					if type(mainObj[methodName]) == "function" then
						mainObj[methodName](mainObj)
					end
				end
			end
			if CloseDropDownMenus then
				CloseDropDownMenus()
			end
		else
			local mainFrame = getglobal("VG_MainFrame")
			if mainFrame and mainFrame.obj and mainFrame.obj.RefreshData then
				mainFrame.obj:RefreshData()
			end
		end
		
		bChange = true
		return bChange
	end

	obj.StepByID = function(self, nStep)
		obj.CurrentStep = nStep
		obj:RetrieveData()
	end

	obj.PrevGuide = function(self, bPrevStepBackGuide)
		if obj.PrevGuideID and obj.PrevGuideID > 0 and VGuide.GuideRegistry:GetGuide(obj.PrevGuideID) then
			local temp = obj.CurrentGuideID
			obj.CurrentGuideID = obj.PrevGuideID
			obj.PrevGuideID = temp
			obj.CurrentStep = 1
			obj:RetrieveData()
		else
			local prevID = obj.CurrentGuideID - 1
			while prevID >= 1 do
				if VGuide.GuideRegistry:GetGuide(prevID) then
					obj.PrevGuideID = obj.CurrentGuideID
					obj.CurrentGuideID = prevID
					obj.CurrentStep = 1
					obj:RetrieveData()
					return
				end
				prevID = prevID - 1
			end
		end
	end

	obj.NextGuide = function(self)
		if obj.NextGuideID > 0 then
			obj.PrevGuideID = obj.CurrentGuideID
			obj.CurrentGuideID = obj.NextGuideID
			obj.CurrentStep = 1
			obj:RetrieveData()
		elseif obj.NextGuideID == 0 and obj.CurrentGuideID < VGuide.GuideRegistry.GuideCount then
			obj.CurrentGuideID = obj.CurrentGuideID + 1
			obj.CurrentStep = 1
			obj:RetrieveData()
		end
	end

	obj.PrevStep = function(self)
		if obj.CurrentStep > 1 then
			obj.CurrentStep = obj.CurrentStep - 1
			obj.StepFrameDisplay = obj.StepInfoDisplay[obj.CurrentStep].text
			obj:UpdateGuideValuesSettings()
		else
			obj:PrevGuide(true)
		end
	end

	obj.NextStep = function(self)
		if obj.CurrentStep < obj.CurrentStepCount then
			obj.CurrentStep = obj.CurrentStep + 1
			obj.StepFrameDisplay = obj.StepInfoDisplay[obj.CurrentStep].text
			obj:UpdateGuideValuesSettings()
		else
			obj:NextGuide()
		end
	end

	obj.GetCurrentStep = function(self)
		return obj.CurrentStep
	end
	obj.GetCurrentGuideID = function(self)
		return obj.CurrentGuideID
	end
	obj.GetCurrentStepCount = function(self)
		return obj.CurrentStepCount
	end
	obj.GetCurrentStepInfo = function(self)
		return obj.StepInfoDisplay[obj.CurrentStep]
	end

	obj.GetStepLabel = function(self)
		return obj.StepFrameDisplay
	end
	obj.GetGuideTitle = function(self)
		return obj.GuideTitle
	end
	
	obj:RetrieveData()

	return obj
end
