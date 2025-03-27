--[[--------------------------------------------------
----- VanillaGuide -----
------------------
Display.lua
Authors: mrmr, Grommey
Version: 2.0
------------------------------------------------------
Description: 
    Display management for VanillaGuide
    2.0
        -- Refactored to integrate with VGuide
        -- Removed objDisplay, methods attached to VGuide
------------------------------------------------------]]

function VGuide:InitializeDisplay(oSettings, oGuideTables)
    local tGuideValues = oSettings:GetSettingsGuideValues()

    self.CurrentStep = tGuideValues.Step
    self.CurrentGuideID = tGuideValues.GuideID
    self.CurrentStepCount = nil

    self.GuideTitle = nil
    self.StepFrameDisplay = nil
    self.ScrollFrameDisplay = {}
    self.StepInfoDisplay = {}

    function VGuide:ScrollFrameDisplayWipe()
        for k, _ in ipairs(self.ScrollFrameDisplay) do
            self.ScrollFrameDisplay[k] = nil
        end
    end

    function VGuide:StepInfoDisplayWipe()
        for k, _ in ipairs(self.StepInfoDisplay) do
            self.StepInfoDisplay[k] = nil
        end
    end

    function VGuide:RetrieveData()
        local t = oGuideTables:GetGuide(self.CurrentGuideID)
        local count = 0
        self.GuideTitle = t.title
        self.StepFrameDisplay = t.items[self.CurrentStep].str
        self:ScrollFrameDisplayWipe()
        self:StepInfoDisplayWipe()
        for k, v in ipairs(t.items) do
            count = count + 1
            self.ScrollFrameDisplay[k] = v.str
            self.StepInfoDisplay[k] = {}
            self.StepInfoDisplay[k].x = v.x or nil
            self.StepInfoDisplay[k].y = v.y or nil
            self.StepInfoDisplay[k].zone = v.zone or nil
        end
        self.CurrentStepCount = count
        self:UpdateGuideValuesSettings()
    end

    function VGuide:RetrieveTableDDM()
        local t = oGuideTables:GetTableDDM()
        return t
    end

    function VGuide:UpdateGuideValuesSettings()
        tGuideValues.Step = self.CurrentStep
        tGuideValues.GuideID = self.CurrentGuideID
        oSettings:SetSettingsGuideValues(tGuideValues)
    end

    function VGuide:GuideByID(nGuideID)
        local bChange = false
        self.CurrentGuideID = nGuideID
        self.CurrentStep = 1
        self:RetrieveData()
        bChange = true
        return bChange
    end

    function VGuide:StepByID(nStep)
        self.CurrentStep = nStep
        self:RetrieveData()
    end

    function VGuide:PrevGuide(bPrevStepBackGuide)
        if self.CurrentGuideID > 1 then
            self.CurrentGuideID = self.CurrentGuideID - 1
            self.CurrentStep = 1
            self:RetrieveData()
            if bPrevStepBackGuide then
                self.CurrentStep = self.CurrentStepCount
                self.StepFrameDisplay = self.ScrollFrameDisplay[self.CurrentStep]
            end
        else
            Dv(" -- Already at GuideID 1")
        end
    end

    function VGuide:NextGuide()
        if self.CurrentGuideID < oGuideTables.GuideCount then
            self.CurrentGuideID = self.CurrentGuideID + 1
            self.CurrentStep = 1
            self:RetrieveData()
        else
            Dv(" -- Already at last GuideID (" .. oGuideTables.GuideCount .. ")")
        end
    end

    function VGuide:PrevStep()
        if self.CurrentStep > 1 then
            self.CurrentStep = self.CurrentStep - 1
            self.StepFrameDisplay = self.ScrollFrameDisplay[self.CurrentStep]
            self:UpdateGuideValuesSettings()
        else
            self:PrevGuide(true)
        end
    end

    function VGuide:NextStep()
        if self.CurrentStep < self.CurrentStepCount then
            self.CurrentStep = self.CurrentStep + 1
            self.StepFrameDisplay = self.ScrollFrameDisplay[self.CurrentStep]
            self:UpdateGuideValuesSettings()
        else
            self:NextGuide()
        end
    end

    function VGuide:GetCurrentStep()
        return self.CurrentStep
    end

    function VGuide:GetCurrentGuideID()
        return self.CurrentGuideID
    end

    function VGuide:GetCurrentStepCount()
        return self.CurrentStepCount
    end

    function VGuide:GetCurrentStepInfo()
        return self.StepInfoDisplay[self.CurrentStep]
    end

    function VGuide:GetStepLabel()
        return self.StepFrameDisplay
    end

    function VGuide:GetGuideTitle()
        return self.GuideTitle
    end

    function VGuide:GetScrollFrameDisplay()
        return self.ScrollFrameDisplay
    end

    -- Initial data retrieval
    self:RetrieveData()
end
