--[[
Vanilla Guide Reloaded

Author: Grommey (originally by mrmr)
Version: 2.0.0

Description:
Manages the registration and retrieval of leveling guides.
Handles guide data, quest information, and UI menu integration.
Part of the Vanilla Guide Reloaded addon.
]]--
VGuide = Vguide or {}

GuideRegistry = {}
GuideRegistry.guides = {}
GuideRegistry.tree = {}

local Dewdrop = AceLibrary("Dewdrop-2.0")

local GuideParser = GuideParser.new()

-- Create a custom frame for styling
local menuFrame = CreateFrame("Frame", "VGuideMenuFrame", UIParent)
menuFrame:SetBackdrop({
    bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
menuFrame:SetBackdropColor(0.2, 0.2, 0.2, 1)  -- Dark grey
menuFrame:SetBackdropBorderColor(0, 0, 0, 1)   -- Black border
menuFrame:Hide()


-- Global function for backward compatibility with guide files
function RegisterGuide(guide)
    return GuideRegistry:RegisterGuide(guide)
end

function GuideRegistry:RegisterGuide(guide)
  assert(guide.id, "Guide must have an id")
  assert(guide.title, "Guide must have a title")
  assert(guide.category, "Guide must have a category")
  
  -- Valider et formater les étapes
  if not guide.steps or type(guide.steps) ~= "table" then
    guide.steps = {}
    DEFAULT_CHAT_FRAME:AddMessage(string.format("Warning: Guide %d has no valid steps table", guide.id))
  end
  
  -- S'assurer que chaque étape a une clé 'text'
  for i, step in ipairs(guide.steps) do
    if type(step) == "table" and step.str and not step.text then
      step.text = step.str
      step.str = nil
    end
  end
  
  -- Store the guide
  self.guides[guide.id] = guide
  
  self.GuideCount = (self.GuideCount or 0) + 1

  -- Add to the tree
  self:_insertIntoTree(guide)
  
  return guide
end

-- Internal: builds Dewdrop tree from categories
function GuideRegistry:_insertIntoTree(guide)
    local node = self.tree

    -- Split category by either forward slash or backslash
    for part in string.gfind(guide.category, "([^/\\]+)") do
        node.children = node.children or {}
        node.children[part] = node.children[part] or {}
        node = node.children[part]
    end

    -- Permet plusieurs guides par catégorie
    node.guides = node.guides or {}
    table.insert(node.guides, guide)
end

function GuideRegistry:GetGuide(id)
  return GuideRegistry.guides[id]
end

function GuideRegistry:GetGuideByID(guideID)
    local id = tonumber(guideID) or guideID
    
    local guide = self.guides[id]
    
    if not guide and type(guideID) == "string" then
        id = tonumber(guideID)
        if id then
            guide = self.guides[id]
        end
    end
    
    if not guide then
        DEFAULT_CHAT_FRAME:AddMessage(string.format("GuideRegistry: Aucun guide trouvé avec l'ID: %s", tostring(guideID)))
        return nil
    end
        
    local guideData = {
        title = guide.title,
        nextGuideID = guide.nextGuideID,  
        steps = {}
    }
    
    for i, step in ipairs(guide.steps or {}) do
        local stepText = step.text or step.str
        if stepText then
            local processedText, x, y, zone = GuideParser:Parse(stepText)
            
            table.insert(guideData.steps, {
                text = processedText,
                x = x or step.x,
                y = y or step.y,
                zone = zone or step.zone
            })
        end
    end
    
    return guideData
end


function GuideRegistry:BuildMenu(level, value)
  local node = value or self.tree
  if not node then 
    return 
  end

  function loadGuide(guide)
    if VGuide and VGuide.Display then
      local success, errorMsg = pcall(function()
        VGuide.Display:GuideByID(guide.id)
        if VGuide.UI and VGuide.UI.RefreshData then
          VGuide.UI:RefreshData()
        else
          local mainFrame = getglobal("VG_MainFrame")
          if mainFrame and mainFrame.obj and mainFrame.obj.RefreshData then
            mainFrame.obj:RefreshData()
          end
        end
        GuideRegistry:CloseMenu()
      end)
    end
  end

  -- Si ce noeud contient plusieurs guides, les afficher
  if node.guides then
    for _, guide in ipairs(node.guides) do
      Dewdrop:AddLine(
        "text", guide.title,
        "color", {1, 0.8, 0, 1},  -- Or
        "highlight", {1, 0.9, 0.5, 1},  -- Or clair
        "func", loadGuide,
        "arg1", guide
      )
    end
  end

  -- Ajout des sous-catégories (inchangé)
  if node.children then
    local sortedChildren = {}
    for name, _ in pairs(node.children) do
      table.insert(sortedChildren, name)
    end
    table.sort(sortedChildren)

    for _, name in ipairs(sortedChildren) do
      local child = node.children[name]
      local hasChildren = child.children ~= nil and next(child.children) ~= nil
      local hasGuides = false
      if child.guides then
        for _ in ipairs(child.guides) do
          hasGuides = true
          break
        end
      end

      Dewdrop:AddLine(
        "text", name,
        "color", {0.8, 0.8, 0.8, 1},
        "hasArrow", hasChildren or hasGuides,
        "value", child,
        "tooltipTitle", name,
        "tooltipOnButton", true
      )
    end
  end
end

function GuideRegistry:ShowMenu(anchor)
  -- Show the custom frame
  menuFrame:ClearAllPoints()
  menuFrame:SetPoint("TOPLEFT", anchor, "TOPLEFT", 0, 0)
  menuFrame:Show()
  
  Dewdrop:Open(
    anchor,
    "children", function(level, value)
      GuideRegistry:BuildMenu(level, value)
    end,
    "textHeight", 14,
    "textJustifyH", "LEFT"
  )
end

function GuideRegistry:CloseMenu()
  Dewdrop:Close()
  menuFrame:Hide()
end

-- Register for Dewdrop close events
local function OnEvent(self, event, ...)
    if event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_ENTERING_WORLD" then
        GuideRegistry:CloseMenu()
    end
end

-- Create a frame to handle events
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", OnEvent)

-- Also close menu when escape is pressed
table.insert(UISpecialFrames, "VGuideMenuFrame")

-- Expose GuideRegistry to VGuide
VGuide.GuideRegistry = GuideRegistry