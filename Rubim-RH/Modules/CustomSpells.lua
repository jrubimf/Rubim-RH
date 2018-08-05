local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;

local function GetTexture (Object)
    -- Spells
    local SpellID = Object.SpellID;
    if SpellID then
        if Object.TextureSpellID ~= nil then
            if #Object.TextureSpellID == 1 then
                return GetSpellTexture(Object.TextureSpellID[1]);
            else
                return Object.TextureSpellID[2];
            end
        else
            return GetSpellTexture(SpellID);
        end

    end
    -- Items
    local ItemID = Object.ItemID;
    if ItemID then
        local _, _, _, _, _, _, _, _, _, texture = GetItemInfo(ItemID);
        print('item')
        return texture
    end
end

RubimRH.castSpellSequence = {}
local lastCast = 1

function RubimRH.CastSequence()
    if not Player:AffectingCombat() then
        lastCast = 1
        return nil
    end

    if RubimRH.castSpellSequence ~= nil and Player:PrevGCD(1, RubimRH.castSpellSequence[lastCast]) then
        lastCast = lastCast + 1
    end

    if lastCast > #RubimRH.castSpellSequence then
        RubimRH.castSpellSequence = {}
        return nil
    end

    return RubimRH.castSpellSequence[lastCast]
end

RubimRH.queuedSpell = { RubimRH.Spell[1].Empty, 0 }

function Spell:Queue(powerExtra)
    local powerEx = powerExtra or 0
    RubimRH.queuedSpell = { self, powerEx }
end

function RubimRH.QueuedSpell()
    return RubimRH.queuedSpell[1] or RubimRH.Spell[1].Empty
end

--/run RubimRH.queuedSpell ={ RubimRH.Spell[103].Prowl, 0 }

function Spell:Queued(powerEx)
    local powerExtra = powerEx or 0
    if RubimRH.queuedSpell[1] == RubimRH.Spell[1].Empty then
        return false
    end

    if Player:PrevGCD(1, RubimRH.QueuedSpell()) then
        RubimRH.queuedSpell = { RubimRH.Spell[1].Empty, 0 }
        return false
    end

    local powerCost = GetSpellPowerCost(self:ID())
    local powerCostQ = GetSpellPowerCost(RubimRH.queuedSpell[1]:ID())
    local costType = nil
    local costTypeQ = nil
    local costs = 0
    local costsQ = 0

    for i = 1, #powerCost do
        if powerCost[i].cost > 0 then
            costType = powerCost[i].type
            break
        end
    end

    for i = 1, #powerCostQ do
        if powerCostQ[i].cost > 0 then
            costTypeQ = powerCostQ[i].type
            costsQ = powerCostQ[i].cost
            break
        end
    end
    if Player:PrevGCD(1, RubimRH.queuedSpell[1]) and UnitPower("player", costTypeQ) >= costsQ + RubimRH.queuedSpell[2] then
        RubimRH.queuedSpell = { RubimRH.Spell[1].Empty, 0 }
        return false
    end

    if self:ID() == RubimRH.queuedSpell[1]:ID() then
        return false
    end

    if costType ~= costTypeQ then
        return false
    end
    return true
end

function Spell:IsAvailable (CheckPet)
    return CheckPet and IsSpellKnown(self.SpellID, true) or IsPlayerSpell(self.SpellID);
end

function Spell:IsCastableP (Range, AoESpell, ThisUnit, BypassRecovery, Offset)
    if Range then
        local RangeUnit = ThisUnit or Target;
        return self:IsLearned() and self:CooldownRemainsP(BypassRecovery, Offset or "Auto") == 0 and RangeUnit:IsInRange(Range, AoESpell);
    else
        return self:IsLearned() and self:CooldownRemainsP(BypassRecovery, Offset or "Auto") == 0;
    end
end

function Spell:IsCastable(Range, AoESpell, ThisUnit)
    if not self:IsAvailable() or self:Queued() then
        return false
    end

    if Range then
        local RangeUnit = ThisUnit or Target;
        return self:IsLearned() and self:CooldownUp() and RangeUnit:IsInRange(Range, AoESpell);
    else
        return self:IsLearned() and self:CooldownUp();
    end
end

function Spell:IsReady(Range, AoESpell, ThisUnit)
    local range = Range or 8
    if not self:IsAvailable() or self:Queued() then
        return false
    end

    if RubimPvP then
        if RubimRH.db.profile.mainOption.ccbreak then
            return false
        elseif not RubimRH.db.profile.mainOption.ccbreak == false and RubimRH.breakableAreaCC(range) then
            return false
        end
    end

    if self:IsEnabled() == false then
        return false
    end
    range = self:MaximumRange() or 5
    HL.GetEnemies(range, true)
    if range <= 8 and RubimRH.db.profile.mainOption.startattack == true and Cache.EnemiesCount[range] >= 1 then
        return self:IsCastable(Range, AoESpell, ThisUnit) and self:IsUsable();
    end

    return self:IsCastable(Range, AoESpell, ThisUnit) and self:IsUsable();
end

function Spell:IsCastableMorph(Range, AoESpell, ThisUnit)
    if self:IsEnabled() == false then
        return false
    end
    if Range then
        local RangeUnit = ThisUnit or Target;
        return self:IsLearned() and self:CooldownUp() and RangeUnit:IsInRange(Range, AoESpell);
    else
        return self:IsLearned() and self:CooldownUp();
    end
end

function Spell:IsReadyMorph(Range, AoESpell, ThisUnit)
    if RubimPvP then
        if RubimRH.db.profile.mainOption.ccbreak then
            return false
        elseif not RubimRH.db.profile.mainOption.ccbreak == false and RubimRH.breakableAreaCC(Range) then
            return false
        end
    end

    if self:IsEnabled() == false then
        return false
    end
    local range = range or 5
    HL.GetEnemies(range, true)
    if RubimRH.db.profile.mainOption.startattack == true and Cache.EnemiesCount[range] >= 1 then
        return self:IsCastableMorph() and self:IsUsable();
    end
    return self:IsCastableMorph(Range, AoESpell, ThisUnit) and self:IsUsable();
end

function Spell:IsEnabled()
    if #RubimRH.db.profile.mainOption.disabledSpells == 0 then
        return true
    end

    for i = 1, #RubimRH.db.profile.mainOption.disabledSpells do
        if self.SpellID == RubimRH.db.profile.mainOption.disabledSpells[i].value then
            return false
        end
    end
    return true
end

function RubimRH.updateEnabledSpells()
    for i, spell in ipairs(table_name) do
        print(i, v)
    end

end

function RubimRH.isSpellEnabled(spellIDs)
    local isEnabled = true

    for _, spellID in pairs(RubimRH.db.profile.mainOption.disabledSpells) do
        if spellIDs == spellID then
            isEnabled = false
        end
    end
    return isEnabled
end

function RubimRH.addSpellDisabled(spellIDs)
    local exists = false
    for pos, spellID in pairs(RubimRH.db.profile.mainOption.disabledSpells) do
        if spellIDs == spellID then
            table.remove(RubimRH.db.profile.mainOption.disabledSpells, pos)
            exists = true
            print("|cFF00FF00Unblocking|r - " .. GetSpellInfo(spellIDs) .. " (" .. spellIDs .. ")")
            break
        end
    end

    if exists == false then
        table.insert(RubimRH.db.profile.mainOption.disabledSpells, spellIDs)
        print("|cFFFF0000Blocking|r - " .. GetSpellInfo(spellIDs) .. " (" .. spellIDs .. ")")
    end
end

function Spell:Cast()
    return GetTexture(self)
end

function Spell:SetTexture(id)
    self.TextureID = id
end


-- Player On Cast Success Listener
HL:RegisterForSelfCombatEvent(function(_, _, _, _, _, _, _, _, _, _, _, SpellID)
    for i, spell in ipairs(RubimRH.allSpells) do
        if SpellID == spell.SpellID then
            spell.LastCastTime = HL.GetTime()
            spell.LastHitTime = HL.GetTime() + spell:TravelTime()
        end
    end
end, "SPELL_CAST_SUCCESS")

-- Pet On Cast Success Listener
HL:RegisterForPetCombatEvent(function(_, _, _, _, _, _, _, _, _, _, _, SpellID)
    for i, spell in ipairs(RubimRH.allSpells) do
        if SpellID == spell.SpellID then
            spell.LastCastTime = HL.GetTime()
            spell.LastHitTime = HL.GetTime() + spell:TravelTime()
        end
    end
end, "SPELL_CAST_SUCCESS")

-- Player Aura Applied Listener
HL:RegisterForSelfCombatEvent(function(_, _, _, _, _, _, _, _, _, _, _, SpellID)
    for i, spell in ipairs(RubimRH.allSpells) do
        if SpellID == spell.SpellID then
            spell.LastAppliedOnPlayerTime = HL.GetTime()
        end
    end
end, "SPELL_AURA_APPLIED")

-- Player Aura Removed Listener
HL:RegisterForSelfCombatEvent(function(_, _, _, _, _, _, _, _, _, _, _, SpellID)
    for i, spell in ipairs(RubimRH.allSpells) do
        if SpellID == spell.SpellID then
            spell.LastRemovedFromPlayerTime = HL.GetTime()
        end
    end
end, "SPELL_AURA_REMOVED")

local lustBuffs = {
    Spell(80353),
    Spell(2825),
    Spell(32182),
    Spell(90355),
    Spell(160452),
    Spell(178207),
    Spell(35475),
    Spell(230935),
    Spell(256740),
}

function Unit:LustDuration()
    for i = 1, #HeroismBuff do
        local Buff = HeroismBuff[i]
        if self:Buff(Buff, nil, true) then
            return ThisUnit:BuffRemains(Buff, true) or 0
        end
    end
    return 0
end