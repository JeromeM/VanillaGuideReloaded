--[[
Vanilla Guide Reloaded

Author: Grommey (originally by mrmr)

Description:
Tracking of quests accepted, completed and abandoned.
Used to automatically change steps.
Part of the Vanilla Guide Reloaded addon.
]]--
VGuide = VGuide or {}

objQuestTracker = {}
objQuestTracker.__index = objQuestTracker

function objQuestTracker:new(oSettings)
    
    local obj = {}
    setmetatable(obj, self)
    
    local tQuestTracking = oSettings:GetSettingsQuestTracking()

    if not tQuestTracking.accepted then
        tQuestTracking.accepted = {}
    end
    if not tQuestTracking.completed then
        tQuestTracking.completed = {}
    end

    oSettings:SetSettingsQuestTracking(tQuestTracking)

    local original_AcceptQuest = AcceptQuest
    AcceptQuest = function()
        local title = GetTitleText()
        local id = VGuide.QuestTracker:GetQuestIDByName(title)
        VGuide.QuestTracker:TrackAccepted(id, title)
        original_AcceptQuest()
    end
    
    -- Hook CompleteQuest to detect quest hand-in
    local original_CompleteQuest = CompleteQuest
    CompleteQuest = function()
        local title = GetTitleText()
        local id = VGuide.QuestTracker:GetQuestIDByName(title)
        VGuide.QuestTracker:TrackCompleted(id, title)
        original_CompleteQuest()
    end

    local original_AbandonQuest = AbandonQuest
    AbandonQuest = function()
        local title = GetAbandonQuestName()
        if title then
            local id = VGuide.QuestTracker:GetQuestIDByName(title)
            if id then
                VGuide.QuestTracker:RemoveAccepted(id)
            end
        end
        original_AbandonQuest()
    end
    
    obj.Log = function(self, msg)
        if type(msg) == "table" then
            local msgStr = ""
            for k, v in pairs(msg) do
                msgStr = msgStr .. tostring(k) .. "=" .. tostring(v) .. " "
            end
            DEFAULT_CHAT_FRAME:AddMessage("|cFF33FF99[QuestTracker]|r " .. msgStr)
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFF33FF99[QuestTracker]|r " .. tostring(msg))
        end
    end
    
    obj.GetQuestIDByName = function(self, name)
        if not name then
            DEFAULT_CHAT_FRAME:AddMessage("GetQuestIDByName: name is nil!")
            return nil
        end
        
        if not tQuestTracking then
            DEFAULT_CHAT_FRAME:AddMessage("Error: tQuestTracking is nil!")
            return nil
        end
        
        if not VGDB then
            DEFAULT_CHAT_FRAME:AddMessage("VGDB is nil")
            return nil
        end
        
        if not VGDB.quests then
            DEFAULT_CHAT_FRAME:AddMessage("VGDB.quests is nil")
            return nil
        end
        
        if not VGDB.quests.enUS then
            DEFAULT_CHAT_FRAME:AddMessage("VGDB.quests.enUS is nil")
            return nil
        end
        
        for id, data in pairs(VGDB.quests.enUS) do
            if data and data.T and data.T == name then
                if not tQuestTracking.completed[id] then
                    return id
                end
            end
        end
        
        DEFAULT_CHAT_FRAME:AddMessage("Quest not found in database: " .. tostring(name))
        return nil
    end
    
    obj.TrackAccepted = function(self,id, title)
        if not id or type(id) ~= "number" then
            DEFAULT_CHAT_FRAME:AddMessage("Invalid quest ID: " .. tostring(id) .. " With type ID: " .. type(id))
            return
        end

        if not tQuestTracking.accepted then
            tQuestTracking.accepted = {}
        end

        if id and not tQuestTracking.accepted[id] then
            tQuestTracking.accepted[id] = {
                title = title,
                timestamp = time()
            }
            oSettings:SetSettingsQuestTracking(tQuestTracking)
            obj:Log("Accepted quest: " .. title .. " (ID: " .. tostring(id) .. ")")
        end
    end
    
    obj.TrackCompleted = function(self, id, title)
        if not id or type(id) ~= "number" then
            DEFAULT_CHAT_FRAME:AddMessage("Invalid quest ID: " .. tostring(id))
            return
        end

        if not tQuestTracking.completed then
            tQuestTracking.completed = {}
        end

        if id and not tQuestTracking.completed[id] then
            tQuestTracking.completed[id] = {
                title = title,
                timestamp = time()
            }
            oSettings:SetSettingsQuestTracking(tQuestTracking)
            obj:Log("Completed quest: " .. title .. " (ID: " .. tostring(id) .. ")")
        end
    end

    obj.RemoveAccepted = function(self, id)
        if not id or type(id) ~= "number" then
            DEFAULT_CHAT_FRAME:AddMessage("Invalid quest ID for removal: " .. tostring(id))
            return
        end
    
        if tQuestTracking.accepted and tQuestTracking.accepted[id] then
            local title = tQuestTracking.accepted[id].title
            tQuestTracking.accepted[id] = nil
            oSettings:SetSettingsQuestTracking(tQuestTracking)
            self:Log("Removed abandoned quest: " .. tostring(title) .. " (ID: " .. tostring(id) .. ")")
        end
    end
    
    return obj
end