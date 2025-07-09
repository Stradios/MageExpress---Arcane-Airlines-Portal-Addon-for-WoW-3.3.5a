
DEFAULT_CHAT_FRAME:AddMessage("MageExpress loaded and running")

local portalSpells = {
    Alliance = {
        ["Stormwind"]  = { spell = 10059, message = "[Arcane Airlines] Now boarding: direct portal to STORMWIND! Keep your gear tight, your gnomes closer, and step inside the rune responsibly." },
        ["Ironforge"]  = { spell = 11416, message = "[Arcane Airlines] Welcome aboard your frostbitten ride to IRONFORGE! Hold your mugs, don’t poke the dwarves, and expect strong ale and stronger accents!" },
        ["Darnassus"]  = { spell = 11419, message = "[Arcane Airlines] Portal to DARNASSUS departing shortly. Please silence your pets, respect the ancient trees, and prepare for maximum elven vibes." },
        ["Exodar"]     = { spell = 32266, message = "[Arcane Airlines] Firing up the portal to THE EXODAR! Watch your step – the crash site still hums with crystal energy. No refunds, no fel magic, no kidding!" },
        ["Theramore"]  = { spell = 49360, message = "[Arcane Airlines] Portal to THERAMORE now open! Wear light armor, avoid commenting on Jaina, and don’t Blink over water." },
    },
    Horde = {
        ["Orgrimmar"]     = { spell = 11417, message = "[Arcane Airlines] Boarding for ORGRIMMAR! Hold your tusks and don’t mention the Alliance. Warchief requests no pyrotechnics." },
        ["Undercity"]     = { spell = 11418, message = "[Arcane Airlines] Now casting a portal to UNDERCITY. Keep your noses plugged and beware of falling ceiling tiles." },
        ["Thunder Bluff"] = { spell = 11420, message = "[Arcane Airlines] Onward to THUNDER BLUFF! Keep hooves inside the portal and avoid angering the druids." },
        ["Silvermoon"]    = { spell = 32267, message = "[Arcane Airlines] Spinning up a portal to SILVERMOON! Brace for sparkle, magisters, and magical excess!" },
        ["Stonard"]       = { spell = 49361, message = "[Arcane Airlines] Welcome aboard your swampy ride to STONARD. Wipe your boots and prepare for orc hospitality." },
    },
    Neutral = {
        ["Shattrath"] = { spell = 33691, message = "[Arcane Airlines] Now boarding for SHATTRATH CITY — the city of two factions, one Light, and zero flying mounts indoors!" },
        ["Dalaran"]   = { spell = 53142, message = "[Arcane Airlines] Opening a portal to DALARAN! Fasten your robes, keep your familiars seated, and avoid leaning over the edge." }
    }
}

local frame = CreateFrame("Frame", "MageExpressUI", UIParent)
frame:SetSize(240, 360)
frame:SetPoint("CENTER")
frame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
frame:SetBackdropColor(0, 0, 0, 0.8)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
frame:Hide()

frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
frame.title:SetPoint("TOP", frame, "TOP", 0, -10)
frame.title:SetText("MageExpress")

-- Determine which buttons to show
local faction = UnitFactionGroup("player")
local citiesToShow = {}

if portalSpells[faction] then
    for name, data in pairs(portalSpells[faction]) do
        table.insert(citiesToShow, { name = name, data = data })
    end
end
for name, data in pairs(portalSpells.Neutral) do
    table.insert(citiesToShow, { name = name, data = data })
end

-- Create buttons
for i, entry in ipairs(citiesToShow) do
    local btn = CreateFrame("Button", "MageExpressButton"..i, frame, "SecureActionButtonTemplate, UIPanelButtonTemplate")
    btn:SetSize(200, 24)
    btn:SetPoint("TOP", frame, "TOP", 0, -40 - ((i - 1) * 30))
    btn:SetText(entry.name)
    btn:SetAttribute("type", "spell")
    btn:SetAttribute("spell", entry.data.spell)
    btn:SetScript("PreClick", function()
        SendChatMessage(entry.data.message, "YELL")
    end)
end

-- Slash command
SLASH_MAGEEXPRESS1 = "/magex"
SlashCmdList["MAGEEXPRESS"] = function()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end

-- Minimap icon
local miniIcon = CreateFrame("Button", "MageExpressMiniMap", UIParent)
miniIcon:SetSize(32, 32)
miniIcon:SetPoint("CENTER", Minimap, "BOTTOM", 0, -20)
miniIcon:SetNormalTexture("Interface\Icons\Spell_Arcane_PortalStormWind")
miniIcon:SetHighlightTexture("Interface\Minimap\UI-Minimap-ZoomButton-Highlight")
miniIcon:SetMovable(true)
miniIcon:EnableMouse(true)
miniIcon:RegisterForDrag("LeftButton")
miniIcon:SetScript("OnDragStart", miniIcon.StartMoving)
miniIcon:SetScript("OnDragStop", miniIcon.StopMovingOrSizing)
miniIcon:Show()

miniIcon:SetScript("OnClick", function()
    if MageExpressUI:IsShown() then
        MageExpressUI:Hide()
    else
        MageExpressUI:Show()
    end
end)

miniIcon:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("MageExpress\nClick to toggle portal menu", 1, 1, 1)
    GameTooltip:Show()
end)

miniIcon:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)




-- Auto-create macro on login (avoid duplicates)
local createMacroFrame = CreateFrame("Frame")
createMacroFrame:RegisterEvent("PLAYER_LOGIN")
createMacroFrame:SetScript("OnEvent", function()
    local macroName = "MageX"
    local iconIndex = 1
    local body = "/magex"

    local found = false

    -- Check global and character-specific macros
    local numGlobal, numChar = GetNumMacros()
    for i = 1, numGlobal do
        local name = GetMacroInfo(i)
        if name == macroName then
            found = true
            break
        end
    end

    if not found then
        for i = 121, 120 + numChar do
            local name = GetMacroInfo(i)
            if name == macroName then
                found = true
                break
            end
        end
    end

    if not found and numChar < 18 then
        CreateMacro(macroName, iconIndex, body, true)
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00MageExpress: Macro '/magex' created.|r")
    elseif not found then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000MageExpress: Not enough macro slots!|r")
    end
end)
