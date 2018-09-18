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
        if Object.TextureSpellID ~= nil then
            if #Object.TextureSpellID == 1 then
                return GetSpellTexture(Object.TextureSpellID[1]);
            else
                return Object.TextureSpellID[2];
            end
        else
            local _, _, _, _, _, _, _, _, _, texture = GetItemInfo(ItemID);
            return texture
        end
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

function Spell:IsQueuedPowerCheck(powerEx)
    local powerExtra = powerEx or 0
    if RubimRH.queuedSpell[1] == RubimRH.Spell[1].Empty then
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

    if costType == 3 and RubimRH.queuedSpell[1]:CooldownRemains() >= Player:EnergyTimeToX(costsQ) then
        return true
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

function Spell:CooldownRemains(BypassRecovery, Offset)
    if RubimRH.db.profile[RubimRH.playerSpec].Spells ~= nil then
        for i, v in pairs(RubimRH.db.profile[RubimRH.playerSpec].Spells) do
            if v.spellID == self:ID() and v.isActive == false then
                return 1000
            end
        end
    end

    if self:IsEnabled() == false then
        return 1000
    end

    if self:IsEnabledCD() == false or self:IsEnabledCleave() == false then
        return 1000
    end

    local SpellInfo = Cache.SpellInfo[self.SpellID]
    if not SpellInfo then
        SpellInfo = {}
        Cache.SpellInfo[self.SpellID] = SpellInfo
    end
    local Cooldown = Cache.SpellInfo[self.SpellID].Cooldown
    local CooldownNoRecovery = Cache.SpellInfo[self.SpellID].CooldownNoRecovery
    if (not BypassRecovery and not Cooldown) or (BypassRecovery and not CooldownNoRecovery) then
        if BypassRecovery then
            CooldownNoRecovery = self:ComputeCooldown(BypassRecovery)
        else
            Cooldown = self:ComputeCooldown()
        end
    end
    if Offset then
        return BypassRecovery and math.max(HL.OffsetRemains(CooldownNoRecovery, Offset), 0) or math.max(HL.OffsetRemains(Cooldown, Offset), 0)
    else
        return BypassRecovery and CooldownNoRecovery or Cooldown
    end
end

--[[*
  * @function Spell:CooldownRemainsP
  * @override Spell:CooldownRemains
  * @desc Offset defaulted to "Auto" which is ideal in most cases to improve the prediction.
  *
  * @param {string|number} [Offset="Auto"]
  *
  * @returns {number}
  *]]

function Spell:IsCastable(Range, AoESpell, ThisUnit)
    if not self:IsAvailable() or self:IsQueuedPowerCheck() then
        return false
    end

    if Range then
        local RangeUnit = ThisUnit or Target;
        return self:IsLearned() and self:CooldownUp() and RangeUnit:IsInRange(Range, AoESpell);
    else
        return self:IsLearned() and self:CooldownUp();
    end
end

function Spell:IsReadyQueue(Range, AoESpell, ThisUnit)
    if RubimRH.db.profile.mainOption.startattack then
        if Target:Exists() then
            if self:IsCastable(Range, AoESpell, ThisUnit) and self:IsUsable() then
                return true
            end
        end
        local range = self:MaximumRange()
        if range == 0 or range > 8 then
            range = 10
        else
            range = 8
        end
        HL.GetEnemies(8, true)
        if self:IsMelee() and Cache.EnemiesCount[8] >= 1 then
            return self:IsCastableMorph(nil, nil, nil) and self:IsUsable();
        end
    end

    if not RubimRH.TargetIsValid() then
        return false
    end

    return self:IsCastableMorph(Range, AoESpell, ThisUnit) and self:IsUsable();
end

function Spell:IsReady(Range, AoESpell, ThisUnit)
    if not self:IsAvailable() or self:IsQueuedPowerCheck() then
        return false
    end

    if RubimRH.db.profile[RubimRH.playerSpec].Spells ~= nil then
        for i, v in pairs(RubimRH.db.profile[RubimRH.playerSpec].Spells) do
            if v.spellID == self:ID() and v.isActive == false then
                return false
            end
        end
    end

    if RubimRHPvP ~= nil and RubimRHPvP.active then
        if RubimRH.breakableAreaCC(8) then
            return false
        end
    end

    if self:IsEnabled() == false then
        return false
    end

    if self:IsEnabledCD() == false or self:IsEnabledCleave() == false then
        return false
    end

    if RubimRH.db.profile.mainOption.startattack then
        local range = self:MaximumRange()
        if range == 0 or range > 8 then
            range = 10
        else
            range = 8
        end
        HL.GetEnemies(8, true)
        if self:IsMelee() and Cache.EnemiesCount[8] >= 1 then
            return self:IsCastable(nil, nil, nil) and self:IsUsable();
        end
    end

    if RubimRH.TargetIsValid() == false and self:MaximumRange() <= 29 then
        return false
    end
    return self:IsCastable(Range, AoESpell, ThisUnit) and self:IsUsable();
end

function Spell:IsReadyP(Range, AoESpell, ThisUnit)
    if not self:IsAvailable() or self:IsQueuedPowerCheck() then
        return false
    end

    if RubimRH.db.profile[RubimRH.playerSpec].Spells ~= nil then
        for i, v in pairs(RubimRH.db.profile[RubimRH.playerSpec].Spells) do
            if v.spellID == self:ID() and v.isActive == false then
                return false
            end
        end
    end

    if RubimRHPvP ~= nil and RubimRHPvP.active then
        if RubimRH.breakableAreaCC(8) then
            return false
        end
    end

    if self:IsEnabled() == false then
        return false
    end

    if self:IsEnabledCD() == false or self:IsEnabledCleave() == false then
        return false
    end

    if RubimRH.db.profile.mainOption.startattack then

        if Target:Exists() then
            if self:IsCastable(Range, AoESpell, ThisUnit) and self:IsUsable() then
                return true
            end
        end

        local range = self:MaximumRange()
        if range == 0 or range > 8 then
            range = 10
        else
            range = 8
        end
        HL.GetEnemies(8, true)
        if self:IsMelee() and Cache.EnemiesCount[8] >= 1 then
            return self:IsCastableP(nil, nil, nil) and self:IsUsableP();
        end
    end

    if not RubimRH.TargetIsValid() then
        return false
    end

    return self:IsCastableP(Range, AoESpell, ThisUnit) and self:IsUsableP();
end

function Spell:IsCastableP(Range, AoESpell, ThisUnit, BypassRecovery, Offset)
    if not self:IsAvailable() or self:IsQueuedPowerCheck() then
        return false
    end
    if Range then
        local RangeUnit = ThisUnit or Target
        return self:IsLearned() and self:CooldownRemainsP(BypassRecovery or true, Offset or "Auto") == 0 and RangeUnit:IsInRange(Range, AoESpell)
    else
        return self:IsLearned() and self:CooldownRemainsP(BypassRecovery or true, Offset or "Auto") == 0
    end
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
    if RubimRHPvP ~= nil and RubimRHPvP.active then
        if RubimRH.breakableAreaCC(range) then
            return false
        end
    end

    if self:IsEnabled() == false then
        return false
    end

    if self:IsEnabledCD() == false or self:IsEnabledCleave() == false then
        return false
    end

    if RubimRH.db.profile.mainOption.startattack then
        if Target:Exists() then
            if self:IsCastable(Range, AoESpell, ThisUnit) and self:IsUsable() then
                return true
            end
        end
        local range = self:MaximumRange()
        if range == 0 or range > 8 then
            range = 10
        else
            range = 8
        end
        HL.GetEnemies(8, true)
        if self:IsMelee() and Cache.EnemiesCount[8] >= 1 then
            return self:IsCastableMorph(nil, nil, nil) and self:IsUsable();
        end
    end

    if not RubimRH.TargetIsValid() then
        return false
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

function Spell:IsEnabledCD()
    if #RubimRH.db.profile.mainOption.disabledSpellsCD == 0 and RubimRH.CDsON() then
        return true
    end

    for i = 1, #RubimRH.db.profile.mainOption.disabledSpellsCD do
        if self.SpellID == RubimRH.db.profile.mainOption.disabledSpellsCD[i].value then
            return false
        end
    end
    return true
end

function RubimRH.addSpellDisabledCD(spellid)
    local exists = false

    if #RubimRH.db.profile.mainOption.disabledSpellsCD > 0 then
        for i = 1, #RubimRH.db.profile.mainOption.disabledSpellsCD do
            if spellid == RubimRH.db.profile.mainOption.disabledSpellsCD[i].value then
                exists = true
            end
        end
    end

    if exists == false then
        table.insert(RubimRH.db.profile.mainOption.disabledSpellsCD, { text = GetSpellInfo(spellid), value = spellid })
    end
end

function RubimRH.delSpellDisabledCD(spellid)
    if #RubimRH.db.profile.mainOption.disabledSpellsCD > 0 then
        for i = 1, #RubimRH.db.profile.mainOption.disabledSpellsCD do
            if spellid == RubimRH.db.profile.mainOption.disabledSpellsCD[i].value then
                table.remove(RubimRH.db.profile.mainOption.disabledSpellsCD, i)
            end
            break
        end
    end
end

function Spell:IsEnabledCleave()
    if #RubimRH.db.profile.mainOption.disabledSpellsCleave == 0 and not RubimRH.db.profile.mainOption.smartCleave then
        return true
    end

    for i = 1, #RubimRH.db.profile.mainOption.disabledSpellsCleave do
        if self.SpellID == RubimRH.db.profile.mainOption.disabledSpellsCleave[i].value then
            return false
        end
    end
    return true
end

function RubimRH.addSpellDisabledCleave(spellid)
    local exists = false

    if #RubimRH.db.profile.mainOption.disabledSpellsCleave > 0 then
        for i = 1, #RubimRH.db.profile.mainOption.disabledSpellsCleave do
            if spellid == RubimRH.db.profile.mainOption.disabledSpellsCleave[i].value then
                exists = true
            end
        end
    end

    if exists == false then
        table.insert(RubimRH.db.profile.mainOption.disabledSpellsCleave, { text = GetSpellInfo(spellid), value = spellid })
    end
end

function RubimRH.delSpellDisabledCleave(spellid)
    if #RubimRH.db.profile.mainOption.disabledSpellsCleave > 0 then
        for i = 1, #RubimRH.db.profile.mainOption.disabledSpellsCleave do
            if spellid == RubimRH.db.profile.mainOption.disabledSpellsCleave[i].value then
                table.remove(RubimRH.db.profile.mainOption.disabledSpellsCleave, i)
            end
            break
        end
    end
end

function Spell:Cast()
    return GetTexture(self)
end

function Item:Cast()
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