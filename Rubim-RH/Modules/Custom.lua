function table.removeKey(t, k)
    local i = 0
    local keys, values = {}, {}
    for k, v in pairs(t) do
        i = i + 1
        keys[i] = k
        values[i] = v
    end

    while i > 0 do
        if keys[i] == k then
            table.remove(keys, i)
            table.remove(values, i)
            break
        end
        i = i - 1
    end

    local a = {}
    for i = 1, #keys do
        a[keys[i]] = values[i]
    end

    return a
end

local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;

--- ============================   CUSTOM   ============================
local function round2(num, idp)
    mult = 10 ^ (idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function ttd(unit)
    unit = unit or "target";
    if thpcurr == nil then
        thpcurr = 0
    end
    if thpstart == nil then
        thpstart = 0
    end
    if timestart == nil then
        timestart = 0
    end
    if UnitExists(unit) and not UnitIsDeadOrGhost(unit) then
        if currtar ~= UnitGUID(unit) then
            priortar = currtar
            currtar = UnitGUID(unit)
        end
        if thpstart == 0 and timestart == 0 then
            thpstart = UnitHealth(unit)
            timestart = GetTime()
        else
            thpcurr = UnitHealth(unit)
            timecurr = GetTime()
            if thpcurr >= thpstart then
                thpstart = thpcurr
                timeToDie = 999
            else
                if ((timecurr - timestart) == 0) or ((thpstart - thpcurr) == 0) then
                    timeToDie = 999
                else
                    timeToDie = round2(thpcurr / ((thpstart - thpcurr) / (timecurr - timestart)), 2)
                end
            end
        end
    elseif not UnitExists(unit) or currtar ~= UnitGUID(unit) then
        currtar = 0
        priortar = 0
        thpstart = 0
        timestart = 0
        timeToDie = 9999999999999999
    end
    if timeToDie == nil then
        return 99999999
    else
        return timeToDie
    end
end

function DiyingIn()
    HL.GetEnemies(10, true); -- Blood Boil
    totalmobs = 0
    dyingmobs = 0
    for _, CycleUnit in pairs(Cache.Enemies[10]) do
        totalmobs = totalmobs + 1;
        if CycleUnit:TimeToDie() <= 20 then
            dyingmobs = dyingmobs + 1;
        end
    end
    if dyingmobs == 0 then
        return 0
    else
        return totalmobs / dyingmobs
    end
end

function GetTotalMobs()
    local totalmobs = 0
    for reference, unit in pairs(activeUnitPlates) do
        if CheckInteractDistance(unit, 3) then
            totalmobs = totalmobs + 1
        end
    end
    return totalmobs
end

function GetMobsDying()
    local totalmobs = 0
    local dyingmobs = 0
    for reference, unit in pairs(activeUnitPlates) do
        if CheckInteractDistance(unit, 3) then
            totalmobs = totalmobs + 1
            if ttd(unit) <= 6 then
                dyingmobs = dyingmobs + 1
            end
        end
    end

    if totalmobs == 0 then
        return 0
    end

    return (dyingmobs / totalmobs) * 100
end

function GetMobs(spellId)
    local totalmobs = 0
    for reference, unit in pairs(activeUnitPlates) do
        if IsSpellInRange(GetSpellInfo(spellId), unit) then
            totalmobs = totalmobs + 1
        end
    end
    return totalmobs
end

local SpellsInterrupt = {
    194610, 198405, 194657, 199514, 199589, 216197, --Maw of Souls
    -- PvP Spells
	118, -- Polymorph
    20066, -- Repentance
    51514, -- Hex
    19386, -- Wyvern Sting
    5782, -- Fear
    33786, -- Cyclone
    605, -- Mind Control 
    982, -- Revive Pet 
    32375, -- Mass Dispel 
    203286, -- Greatest Pyroblast
    116858, -- Chaos Bolt 
    20484, -- Rebirth
    203155, -- Sniper Shot 
    47540, -- Penance
    596, -- Prayer of Healing
    2060, -- Heal
    2061, -- Flash Heal
    32546, -- Binding Heal                        (priest, holy)
    33076, -- Prayer of Mending
    64843, -- Divine Hymn
    120517, -- Halo                                (priest, holy/disc)
    186263, -- Shadow Mend
    194509, -- Power Word: Radiance
    265202, -- Holy Word: Salvation                (priest, holy)
    289666, -- Greater Heal                        (priest, holy)
    740, -- Tranquility
    8936, -- Regrowth
    48438, -- Wild Growth
    289022, -- Nourish                             (druid, restoration)
    1064, -- Chain Heal
    8004, -- Healing Surge
    73920, -- Healing Rain
    77472, -- Healing Wave
    197995, -- Wellspring                          (shaman, restoration)
    207778, -- Downpour                            (shaman, restoration)
    19750, -- Flash of Light
    82326, -- Holy Light
    116670, -- Vivify
    124682, -- Enveloping Mist
    191837, -- Essence Font
    209525, -- Soothing Mist
    227344, -- Surging Mist                        (monk, mistweaver)
	
	
	
	
	
	
	0
}

local function ShouldInterrupt()
    local importantCast = false
    local castName, _, _, _, castStartTime, castEndTime, _, _, notInterruptable, spellID = UnitCastingInfo("target")

    if castName == nil then
        local castName, nameSubtext, text, texture, startTimeMS, endTimeMS, isTradeSkill, notInterruptible = UnitChannelInfo("unit")
    end

    if spellID == nil or notInterruptable == true then
        return false
    end

    for i, v in ipairs(SpellsInterrupt) do
        if spellID == v then
            importantCast = true
            break
        end
    end

    if spellID == nil or castInterruptable == false then
        return false
    end

    if int_smart == false then
        importantCast = false
    end

    if importantCast == false then
        return false
    end

    local timeSinceStart = (GetTime() * 1000 - castStartTime) / 1000
    local timeLeft = ((GetTime() * 1000 - castEndTime) * -1) / 1000
    local castTime = castEndTime - castStartTime
    local currentPercent = timeSinceStart / castTime * 100000
    local interruptPercent = math.random(10, 30)
    if currentPercent >= interruptPercent then
        return true
    end
    return false
end

local movedTimer = 0
function RubimRH.lastMoved()
    if Player:IsMoving() then
        movedTimer = GetTime()
    end
    return GetTime() - movedTimer
end

local playerGUID
local damageAmounts, damageTimestamps = {}, {}
local damageInLast3Seconds = 0
local lastMeleeHit = 0

local combatLOG = CreateFrame("Frame")
combatLOG:RegisterEvent("PLAYER_LOGIN")
combatLOG:SetScript("OnEvent", function(self, event)
    playerGUID = UnitGUID("player")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self:SetScript("OnEvent", function()
        local timestamp, event, arg3, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, arg12, arg13, arg14, arg15, arg16 = CombatLogGetCurrentEventInfo()
        if destGUID ~= playerGUID then
            return
        end
        local amount = nil
        if event == "SPELL_DAMAGE" or event == "SPELL_PERIODIC_DAMAGE" or event == "RANGE_DAMAGE" then
            amount = arg15
            --amount = camount
        elseif event == "SWING_DAMAGE" then
            lastMeleeHit = GetTime()
            amount = arg12
        elseif event == "ENVIRONMENTAL_DAMAGE" then
            amount = arg13
        end
        if amount then
            -- Record new damage at the top of the log:
            tinsert(damageAmounts, 1, amount)
            tinsert(damageTimestamps, 1, timestamp)
            -- Clear out old entries from the bottom, and add up the remaining ones:
            local cutoff = timestamp - 3
            damageInLast3Seconds = 0
            for i = #damageTimestamps, 1, -1 do
                local timestamp = damageTimestamps[i]
                if timestamp < cutoff then
                    damageTimestamps[i] = nil
                    damageAmounts[i] = nil
                else
                    damageInLast3Seconds = damageInLast3Seconds + damageAmounts[i]
                end
            end
        end
    end)
end)

function RubimRH.lastSwing()
    if lastMeleeHit > 0 then
        return GetTime() - lastMeleeHit
    end
    return 0
end

function RubimRH.getLastDamage()
    return damageInLast3Seconds
end

function RubimRH.clearLastDamage()
    damageInLast3Seconds = 0
end

function RubimRH.LastDamage()
    local IncomingDPS = (damageInLast3Seconds / UnitHealthMax("player")) * 100
    return (math.floor((IncomingDPS * ((100) + 0.5)) / (100)))
end

function RubimRH.SetFramePos(frame, x, y, w, h)
    local xOffset0 = 1
    if frame == nil then
        return
    end
    if GetCVar("gxMaximize") == "0" then
        xOffset0 = 0.9411764705882353
    end
    xPixel, yPixel, wPixel, hPixel = x, y, w, h
    xRes, yRes = string.match(({ GetScreenResolutions() })[GetCurrentResolution()], "(%d+)x(%d+)");
    uiscale = UIParent:GetScale();
    XCoord = xPixel * (768.0 / xRes) * GetMonitorAspectRatio() / uiscale / xOffset0
    YCoord = yPixel * (768.0 / yRes) / uiscale;
    Weight = wPixel * (768.0 / xRes) * GetMonitorAspectRatio() / uiscale
    Height = hPixel * (768.0 / yRes) / uiscale;
    if x and y then
        frame:SetPoint("TOPLEFT", XCoord, YCoord)
    end
    if w and h then
        frame:SetSize(Weight, Height)
    end
end

function RubimRH.ColorOnOff(boolean)
    if boolean == true then
        return "|cFF00FF00"
    else
        return "|cFFFF0000"
    end
end

-- Target Valid
function RubimRH.TargetIsValid(override)
    local override = override or false

    local unitReaction = UnitReaction("Player", "Target") or 0
    if not override and unitReaction >= 4 and not Player:AffectingCombat() then
        return false
    end

    local isValid = false

    if Target:Exists() and Player:CanAttack(Target) and not Target:IsDeadOrGhost() then
        isValid = true
    end

    return isValid
end

-- will be replaced
function RubimRH.azerite(slot, azeriteID)
    local IsArmor = C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(ItemLocation:CreateFromEquipmentSlot(slot));
    if IsArmor == true then
        local azeriteLearned = C_AzeriteEmpoweredItem.IsPowerSelected(ItemLocation:CreateFromEquipmentSlot(slot), azeriteID);
        if azeriteLearned == true then
            return true
        else
            return false
        end
    end
    return false
end

function RubimRH.DebugPrint(Text)
    if RubimRH.db.profile.mainOption.debug == true then
        print("DEBUG: " .. Text)
    end
end


--NeP RIP
RubimRH.Buttons = {}

local nBars = {
    "ActionButton",
    "MultiBarBottomRightButton",
    "MultiBarBottomLeftButton",
    "MultiBarRightButton",
    "MultiBarLeftButton"
}

local lastSpell = 0
local function UpdateButtons()
    lastSpell = 0
    wipe(RubimRH.Buttons)
    for _, group in ipairs(nBars) do
        for i = 1, 12 do
            local button = _G[group .. i]
            if button then
                local actionType, id = _G.GetActionInfo(_G.ActionButton_CalculateAction(button, "LeftButton"))
                if actionType == 'spell' then
                    --local spell = GetSpellInfo(id)
                    local spell = id
                    if spell then
                        RubimRH.Buttons[spell] = button
                        --RubimRH.Buttons[spell].glow = false
                        --RubimRH.Buttons[spell].text = RubimRH.Buttons[spell]:CreateFontString('ButtonText')
                        --RubimRH.Buttons[spell].text:SetFont("Fonts\\ARIALN.TTF", 22, "OUTLINE")
                        --RubimRH.Buttons[spell].text:SetPoint("CENTER", RubimRH.Buttons[spell])
                        --RubimRH.Buttons[spell].GlowTexture = RubimRH.Buttons[spell]:CreateTexture(nil, "TOOLTIP")
                        --RubimRH.Buttons[spell].GlowTexture:SetScale(0.8)
                        --RubimRH.Buttons[spell].GlowTexture:SetAlpha(0.5)
                        --RubimRH.Buttons[spell].GlowTexture:SetPoint("CENTER")
                        --RubimRH.Buttons[spell] = button:GetName()
                    end
                end
            end
        end
    end

end

RubimRH.Listener:Add('NeP_Buttons', 'ACTIVE_TALENT_GROUP_CHANGED', function()
    UpdateButtons()
end)

RubimRH.Listener:Add('NeP_Buttons', 'PLAYER_PVP_TALENT_UPDATE', function()
    UpdateButtons()
end)

RubimRH.Listener:Add('NeP_Buttons', 'PLAYER_ENTERING_WORLD', function()
    UpdateButtons()
end)

RubimRH.Listener:Add('NeP_Buttons', 'ACTIONBAR_SLOT_CHANGED', function()
    UpdateButtons()
end)

RubimRH.Listener:Add('NeP_Buttons', 'PLAYER_TALENT_UPDATE', function()
    UpdateButtons()
end)

function RubimRH.HideButtonGlow(spellID)
    local isString = (type(spellID) == "string")

    if isString and spellID == "All" then
        for i, button in pairs(RubimRH.Buttons) do
            --if button.glow == true then
                button.glow = false
                button.GlowTexture:SetTexture(nil)
                --button.text:SetText("")
                --button.NormalTexture:SetColorTexture(0, 0, 0, 0)
                --ActionButton_HideOverlayGlow(button)
            --end
        end
        return
    end

    if RubimRH.Buttons[spellID] ~= nil then
        --RubimRH.Buttons[spellID].GlowTexture:SetTexture(nil)
        --RubimRH.Buttons[spellID].glow = false
        --RubimRH.Buttons[spellID].text:SetText("")
        --RubimRH.Buttons[spellID].NormalTexture:SetColorTexture(0, 0, 0, 0)
        --for i, button in pairs(RubimRH.Buttons) do
        --button.NormalTexture:SetColorTexture(0, 0, 0, 0)
        --ActionButton_HideOverlayGlow(button)
        --end
    end
end

function RubimRH.OLDShowButtonGlow(spellID)
    RubimRH.HideButtonGlow("All")
    if RubimRH.Buttons[spellID] ~= nil then
        if lastSpell > 0 and spellID ~= lastSpell then
            --RubimRH.Buttons[spellID].glow = false
           -- RubimRH.Buttons[spellID].GlowTexture:SetTexture(nil)
            lastSpell = spellID
        end
        --ActionButton_ShowOverlayGlow(RubimRH.Buttons[spellID])
        --RubimRH.Buttons[spellID].text:SetText("|cffff0000=>|r")
        RubimRH.Buttons[spellID].GlowTexture:SetTexture("Interface\\Addons\\Rubim-RH\\Media\\combat.tga")
        RubimRH.Buttons[spellID].glow = true
        lastSpell = spellID
    end
end

function RubimRH.ShowButtonGlowQueue(spellID)
    if RubimRH.Buttons[spellID] ~= nil then
        RubimRH.Buttons[spellID].GlowTexture:SetTexture("Interface\\Addons\\Rubim-RH\\Media\\disarmed.tga")
    end
end

local activeFrame = CreateFrame('Frame', 'ShowIcon', _G.UIParent)
activeFrame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                         edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                         tile = true, tileSize = 16, edgeSize = 16,
                         insets = { left = 4, right = 4, top = 4, bottom = 4 }
});


activeFrame:SetBackdropColor(0,0,0,0);
activeFrame.texture = activeFrame:CreateTexture()
activeFrame.texture:SetTexture("Interface/Addons/Rubim-RH/Media/combat.tga")
activeFrame.texture:SetPoint("CENTER")
activeFrame:SetFrameStrata('HIGH')
activeFrame:Hide()

local display = CreateFrame('Frame', 'Faceroll_Info', activeFrame)
display:SetClampedToScreen(true)
display:SetSize(0, 0)
display:SetPoint("TOP")
display:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                     edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                     tile = true, tileSize = 16, edgeSize = 16,
                     insets = { left = 4, right = 4, top = 4, bottom = 4 }
});
display:SetBackdropColor(0,0,0,1);
display.text = display:CreateFontString('Nothing')
display.text:SetFont("Fonts\\ARIALN.TTF", 16)
display.text:SetPoint("CENTER", display)

function RubimRH.ShowButtonGlow(spellID)

    if RubimRH.db.profile.mainOption.glowactionbar == false then
        return
    end

    local spellButton = RubimRH.Buttons[spellID]
    if not spellButton then return end
    local bSize = spellButton:GetWidth()
    activeFrame:SetSize(bSize+5, bSize+5)
    --display:SetSize(display.text:GetStringWidth()+20, display.text:GetStringHeight()+20)
    activeFrame.texture:SetSize(activeFrame:GetWidth()-5,activeFrame:GetHeight()-5)
    activeFrame:SetPoint("CENTER", spellButton, "CENTER")
    --display:SetPoint("TOP", spellButton, 0, display.text:GetStringHeight()+20)
    --spell = '|cff'..NeP.Color.."Spell:|r "..spell
    --local isTargeting = '|cff'..NeP.Color..tostring(_G.UnitIsUnit("target", target or 'player'))
    --target = '|cff'..NeP.Color.."\nTarget:|r"..(_G.UnitName(target or 'player') or '')
    --display.text:SetText(spell..target.."("..isTargeting..")")
    activeFrame:Show()
end

function RubimRH.HideButtonGlow()
    activeFrame:Hide()
end

function RubimRH.print(text, color)
    print("|cff828282RRH: |r" .. text)
end

function RubimRH.GetCurrentLatency()
    local latency = select(3,GetNetStats())	
	local percentlatency = latency * 0.001
	
	return percentlatency or 0
	
end

--------------------------------------
-- ElvyUI Fix
--------------------------------------
local handled = {["Frame"] = true}
local object = CreateFrame("Frame")
object.t = object:CreateTexture(nil,"BACKGROUND")
local OldTexelSnappingBias = object.t:GetTexelSnappingBias()

local function Fix(frame)
    if (frame and not frame:IsForbidden()) and frame.PixelSnapDisabled and not frame.PixelSnapTurnedOff then
        if frame.SetSnapToPixelGrid then
            frame:SetTexelSnappingBias(OldTexelSnappingBias)
        elseif frame.GetStatusBarTexture then
            local texture = frame:GetStatusBarTexture()
            if texture and texture.SetSnapToPixelGrid then                
                texture:SetTexelSnappingBias(OldTexelSnappingBias)
            end
        end
        frame.PixelSnapTurnedOff = true 
    end
end

local function addapi(object)
    local mt = getmetatable(object).__index
        if mt.DisabledPixelSnap then 
        if mt.SetSnapToPixelGrid then hooksecurefunc(mt, 'SetSnapToPixelGrid', Fix) end
        if mt.SetStatusBarTexture then hooksecurefunc(mt, 'SetStatusBarTexture', Fix) end
        if mt.SetColorTexture then hooksecurefunc(mt, 'SetColorTexture', Fix) end
        if mt.SetVertexColor then hooksecurefunc(mt, 'SetVertexColor', Fix) end
        if mt.CreateTexture then hooksecurefunc(mt, 'CreateTexture', Fix) end
        if mt.SetTexCoord then hooksecurefunc(mt, 'SetTexCoord', Fix) end
        if mt.SetTexture then hooksecurefunc(mt, 'SetTexture', Fix) end
    end
end

addapi(object)
addapi(object:CreateTexture())
addapi(object:CreateFontString())
addapi(object:CreateMaskTexture())
object = EnumerateFrames()
while object do
    if not object:IsForbidden() and not handled[object:GetObjectType()] then
        addapi(object)
        handled[object:GetObjectType()] = true
    end

    object = EnumerateFrames(object)
end

--------------------------------------
-- MSG Addon
--------------------------------------
-- UPDATED 8.0.1 Macro
--/script C_ChatInfo.SendAddonMessage("grip", UnitName("player"), "RAID")
C_ChatInfo.RegisterAddonMessagePrefix("grip") --Fix BFA 8.0.1
C_ChatInfo.RegisterAddonMessagePrefix("bark") --Fix BFA 8.0.1
C_ChatInfo.RegisterAddonMessagePrefix("swap") --Fix BFA 8.0.1
C_ChatInfo.RegisterAddonMessagePrefix("bop") --Fix BFA 8.0.1

-- Leap handler
local spellId = 73325
local debuffDuration = 5

-- create the spell icon to show on raid frame
RubimRH.addLeapIcon = function(parentFrame)
    local frame = CreateFrame("Frame",nil,parentFrame)
    frame:SetFrameStrata("HIGH")
    frame:SetWidth(RubimRH.iconWidth)
    frame:SetHeight(RubimRH.iconHeight)
    frame:SetAlpha(RubimRH.iconAlpha)
    
    local texture = frame:CreateTexture(nil,"HIGH")
    texture:SetTexture(select(3, GetSpellInfo(spellId)))
    texture:SetAllPoints(frame)
    frame.texture = texture
    
    frame:SetPoint(RubimRH.position,0,0)
    
    local cooldown = CreateFrame("COOLDOWN", nil, frame, "CooldownFrameTemplate")
    cooldown:SetCooldown(GetTime(), debuffDuration)
    cooldown:SetAllPoints(frame)
    cooldown:SetDrawEdge(false)
    cooldown:SetHideCountdownNumbers(IsAddOnLoaded("OmniCC") or false)
    
    frame:Show()
    C_Timer.After(debuffDuration, function()
            frame:Hide()
    end)
end

-- Leap Highlight on raid frame depending on the current asker name and if our spell cd is ready
RubimRH.Leaphighlight = function(target)
    local hasGrid2 = IsAddOnLoaded("Grid2")
    local hasElvUIParty = _G["ElvUF_Party"] and _G["ElvUF_Party"]:IsVisible()
    local hasElvUIRaid = _G["ElvUF_Raid"] and _G["ElvUF_Raid"]:IsVisible()
    --local isOnCD = GetSpellCooldown(73325)
    
    
    -- Check Spell Cooldown and show custom status
    local IsOnCD = false;
    local name = GetSpellInfo(73325);
    local start, duration, enabled = GetSpellCooldown(name);
    -- msg when grip up
	local msg1 = "Grip pas up, sorry"
	-- msg if grip down
    local msg2 = "Grip up, no stress"    
    
    -- spell on cd
    if ( start > 0 and duration > 1.5) then
        print("DEMANDE DE GRIP DE "..target.."MAIS CD PAS UP") -- TO DO CUSTOMIZE A BIT BETTER
        
        -- if spell is not available, whisp our target to tell the spell is on cd
        SendChatMessage(msg1, "WHISPER", nil, target)
        
        IsOnCD = true;
    else
        print("GRIP URGENT SUR "..target.." !!") -- TO DO CUSTOMIZE A BIT BETTER
        SendChatMessage(msg2, "WHISPER", nil, target)
        IsOnCD = false;
    end    
    
    
    -- Fix Raid Group 8.0.1 + cooldown verification
    if hasElvUIRaid and IsOnCD == false  then
        for i=1, 8 do
            for j=1, 5 do
                local f = _G["ElvUF_RaidGroup"..i.."UnitButton"..j]
                if f and f.unit and UnitName(f.unit) == target then
                    RubimRH.addLeapIcon(f)
                    return
                end
            end
        end
        
        -- Fix Party Group 8.0.1 + cooldown verification
    elseif hasElvUIParty and IsOnCD == false then
        for i=1, 8 do
            for j=1, 5 do
                local f = _G["ElvUF_PartyGroup"..i.."UnitButton"..j]
                if f and f.unit and UnitName(f.unit) == target then
                    RubimRH.addLeapIcon(f)
                    return
                end
            end
        end
        
    elseif hasGrid2 and IsOnCD == false then
        local layout = Grid2LayoutFrame
        
        if layout then
            local children = {layout:GetChildren()}
            for _, child in ipairs(children) do
                if child:IsVisible() then
                    local frames = {child:GetChildren()}
                    for _, f in ipairs(frames) do
                        if f.unit and UnitName(f.unit) == target then
                            RubimRH.addLeapIcon(f)
                            return
                        end
                    end
                end
            end
        end
    else
        if IsOnCD == false then
            for i=1, 40 do
                local f = _G["CompactRaidFrame"..i]
                if f and f.unitExists and f.unit and UnitName(f.unit) == target then
                    RubimRH.addLeapIcon(f)
                    return
                end
            end
        end
        -- Fix party group
        -- for i=1, 5 do
        --   local f = _G["CompactPartyFrameMember"..i]
        -- if f and f.unitExists and f.unit and UnitName(f.unit) == target then
        --   RubimRH.addLeapIcon(f)
        --  return
        -- end
        -- end
        
        
        if IsOnCD == false then
            for i=1, 4 do
                for j=1, 5 do
                    local f = _G["CompactRaidGroup"..i.."Member"..j]
                    if f and f.unitExists and f.unit and UnitName(f.unit) == target then
                        RubimRH.addLeapIcon(f)
                        return
                    end
                end
                
            end
        end
    end
end

-- Leap message handler return player name
function LeapMessage(e, prefix, message)    
    local actionasked = prefix
	if prefix == "grip" then
        --message contains the players name
        RubimRH.Leaphighlight(message)
    end	
	return actionasked
end


function RubimRH.AskedForLeap()
    if actionasked == "grip" then
	    return true
	else
	    return false
    end		
end

function RubimRH.AskedForBark()
    if HandleChatMsgAddon() == true then
	    return true
	else
	    return false	
    end		
end

function RubimRH.AskedForSwap()
    if HandleChatMsgAddon() == true then
	    return true
	else
	    return false
    end		
end

function RubimRH.AskedForBop()
    if HandleChatMsgAddon() == true then
	    return true
	else
	    return false
    end		
end

--- Core DB Saved Var
-- @usage Automata.GetDB('core', 'icon')
function RubimRH.GetDB( option, key )
    local tempStr = "return RubimRH.db.profile." .. option .. "." .. key
    local temp = loadstring( tempStr )( )
    
    if not temp then
        RubimRH.Print( "Error: " .. tempStr )
        return
    end
    
    return temp
end

--- Class DB Saved Var
-- @usage RubimRH.GetClassDB(250, 'VP').Value
function RubimRH.GetClassDB( class, key )
    if type( key ) == "string" then
        key = [[']] .. key .. [[']]
    end
    
    --[[
        if RubimRH.db.profile.selectedProfile then
        local tempStr = "return RubimRH.db.profile.classprofile[".. RubimRH.db.profile.selectedProfile .. "]" .. "[" .. class .. "][" .. key .. "]"
    end--]]
    
    local tempStr = "return RubimRH.db.profile[" .. class .. "][" .. key .. "]"
    local temp = loadstring( tempStr )( )
    
    if not temp then
        RubimRH.Print( "Error: " .. tempStr )
        return
    end
    
    return temp
end
