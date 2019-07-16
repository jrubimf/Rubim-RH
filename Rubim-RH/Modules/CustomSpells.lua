local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;
local Focus, MouseOver = Unit.Focus, Unit.MouseOver;
local Arena, Boss, Nameplate = Unit.Arena, Unit.Boss, Unit.Nameplate;
local Party, Raid = Unit.Party, Unit.Raid;

-- Queen's Court specific rotation (Dont repeat same spell twice)
local currentZoneID = select(8, GetInstanceInfo())
RubimRH.Spell[998] = {
  RepeatPerformance = Spell(301244),
}
local S = RubimRH.Spell[998]

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

RubimRH.queuedSpellAuto = { RubimRH.Spell[1].Empty, 0 }
function Spell:QueueAuto(powerExtra)
    local powerEx = powerExtra or 0
    RubimRH.queuedSpellAuto = { self, powerEx }
end

RubimRH.queuedSpell = { RubimRH.Spell[1].Empty, 0 }
function Spell:Queue(powerExtra, bypassRemove)
    local bypassRemove = bypassRemove or false
    local powerEx = powerExtra or 0
    if self:ID() == RubimRH.queuedSpell[1]:ID() and bypassRemove == false then
        RubimRH.print("|cFFFF0000Removed from Queue:|r " .. GetSpellLink(self:ID()))
        RubimRH.queuedSpell = { RubimRH.Spell[1].Empty, 0 }
        RubimRH.playSoundR("Interface\\Addons\\Rubim-RH\\Media\\queuecast.ogg")
        return
    end

    if self:IsAvailable() then
        RubimRH.queuedSpell = { self, powerEx }
        RubimRH.print("|cFFFFFF00Queued:|r " .. GetSpellLink(self:ID()))
        RubimRH.playSoundR("Interface\\Addons\\Rubim-RH\\Media\\queue.ogg")
        return
    end
    RubimRH.print("|cFFFF0000Can't Queue:|r " .. GetSpellLink(self:ID()))

end

function RubimRH.QueuedSpell()
    return RubimRH.queuedSpell[1] or RubimRH.Spell[1].Empty
end

function RubimRH.QueuedSpellAuto()
    return RubimRH.queuedSpellAuto[1] or RubimRH.Spell[1].Empty
end

--/run RubimRH.queuedSpell ={ RubimRH.Spell[103].Prowl, 0 }

function Spell:IsQueuedPowerCheck(powerEx)
    local powerExtra = powerEx or 0
    if RubimRH.queuedSpell[1] == RubimRH.Spell[1].Empty and RubimRH.queuedSpellAuto[1] == RubimRH.Spell[1].Empty then
        return false
    end

    local powerCostQ, queuedSpellCD, queuedSpellID
    if RubimRH.queuedSpell[1] == RubimRH.Spell[1].Empty then
        powerCostQ = GetSpellPowerCost(RubimRH.queuedSpellAuto[1]:ID())
        queuedSpellCD = RubimRH.queuedSpellAuto[1]:CooldownRemains()
        queuedSpellID = RubimRH.queuedSpellAuto[1]:ID()
    else
        powerCostQ = GetSpellPowerCost(RubimRH.queuedSpell[1]:ID())
        queuedSpellCD = RubimRH.queuedSpell[1]:CooldownRemains()
        queuedSpellID = RubimRH.queuedSpell[1]:ID()
    end

    local powerCost = GetSpellPowerCost(self:ID())
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
        if powerCostQ[i].cost > 0 or powerCostQ[i].costPerSec > 0 or powerCostQ[i].costPercent > 0 then
            costTypeQ = powerCostQ[i].type
            costsQ = powerCostQ[i].cost
            break
        end
    end

    if costType == 3 and queuedSpellCD >= Player:EnergyTimeToX(costsQ) then
        return true
    end

    if self:ID() == queuedSpellID then
        return false
    end

    if costType ~= costTypeQ then
        return false
    end
    return true
end

function Spell:IsAvailable(CheckPet)
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

function Spell:CooldownRemainsTrue(BypassRecovery, Offset)
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
	
	-- Queens Court - Repeat Performance debuff checker
	if currentZoneID == 2164 and Player:DebuffRemainsP(S.RepeatPerformance) > 0 then
	    if Player:PrevGCD(1) ~= self:ID() then
	        return true
		else
		    return false
		end
	end

    if Range then
        local RangeUnit = ThisUnit or Target;
        return self:IsLearned() and self:CooldownUp() and RangeUnit:IsInRange(Range, AoESpell);
    else
        return self:IsLearned() and self:CooldownUp();
    end
end

function Spell:IsCastableQueue(Range, AoESpell, ThisUnit)
    -- Queens Court - Repeat Performance debuff checker
	if currentZoneID == 2164 and Player:DebuffRemainsP(S.RepeatPerformance) > 0 then
	    if Player:PrevGCD(1) ~= self:ID() then
	        return true
		else
		    return false
		end
	end	
	if Range then
        local RangeUnit = ThisUnit or Target;
        return self:IsLearned() and self:CooldownRemainsTrue() <= 0.2 and RangeUnit:IsInRange(Range, AoESpell);
    else
        return self:IsLearned() and self:CooldownRemainsTrue() <= 0.2;
    end
end

function Spell:IsReadyQueue(Range, AoESpell, ThisUnit)
    if not RubimRH.TargetIsValid() then
        return false
    end
	

    return self:IsCastableQueue(Range, AoESpell, ThisUnit) and self:IsUsable();
end

function Spell:SanityChecks()
    if self:IsQueuedPowerCheck() then
        return false
    end

    if self:IsEnabled() == false then
        return false
    end

    if self:IsEnabledCD() == false or self:IsEnabledCleave() == false then
        return false
    end

    if not Target:Exists() then
        return false
    end
end

function Spell:IsReady(Range, AoESpell, ThisUnit)

    if self:SanityChecks() == false then
        return false
    end
	
	-- Queens Court - Repeat Performance debuff checker
	if currentZoneID == 2164 and Player:DebuffRemainsP(S.RepeatPerformance) > 0 then
	    if Player:PrevGCD(1) ~= self:ID() then
	        return true
		else
		    return false
		end
	end

    if not self:IsAvailable() then
        return false
    end
	
    return self:IsCastable(Range, AoESpell, ThisUnit) and self:IsUsable();
end

function Spell:IsReadyP(Range, AoESpell, ThisUnit)
    if not self:IsAvailable() or self:IsQueuedPowerCheck() then
        return false
    end
	
	-- Queens Court - Repeat Performance debuff checker
	if currentZoneID == 2164 and Player:DebuffRemainsP(S.RepeatPerformance) > 0 then
	    if Player:PrevGCD(1) ~= self:ID() then
	        return true
		else
		    return false
		end
	end	

    if RubimRH.db.profile[RubimRH.playerSpec].Spells ~= nil then
        for i, v in pairs(RubimRH.db.profile[RubimRH.playerSpec].Spells) do
            if v.spellID == self:ID() and v.isActive == false then
                return false
            end
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
	
	-- Queens Court - Repeat Performance debuff checker
	if currentZoneID == 2164 and Player:DebuffRemainsP(S.RepeatPerformance) > 0 then
	    if Player:PrevGCD(1) ~= self:ID() then
	        return true
		else
		    return false
		end
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
	
	-- Queens Court - Repeat Performance debuff checker
	if currentZoneID == 2164 and Player:DebuffRemainsP(S.RepeatPerformance) > 0 then
	    if Player:PrevGCD(1) ~= self:ID() then
	        return true
		else
		    return false
		end
	end
	
    if Range then
        local RangeUnit = ThisUnit or Target;
        return self:IsLearned() and self:CooldownUp() and RangeUnit:IsInRange(Range, AoESpell);
    else
        return self:IsLearned() and self:CooldownUp();
    end
end

function Spell:IsReadyMorph(Range, AoESpell, ThisUnit)
    if self:IsEnabled() == false then
        return false
    end
	
	-- Queens Court - Repeat Performance debuff checker
	if currentZoneID == 2164 and Player:DebuffRemainsP(S.RepeatPerformance) > 0 then
	    if Player:PrevGCD(1) ~= self:ID() then
	        return true
		else
		    return false
		end
	end

    if self:IsEnabledCD() == false or self:IsEnabledCleave() == false then
        return false
    end

    if not RubimRH.TargetIsValid() then
        return false
    end

    return self:IsCastableMorph(Range, AoESpell, ThisUnit) and self:IsUsable();
end

function Spell:IsEnabled()
    if RubimRH.db.profile.mainOption.disabledSpells[self.SpellID] ~= nil then
        return false
    end

    return true
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

local GroundSpells = {
    [43265] = true,
    [152280] = true,
}

function Spell:Cast()
    RubimRH.ShowButtonGlow(self:ID())
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
    if SpellID == 49998 then
        RubimRH.clearLastDamage()
    end

    if RubimRH.QueuedSpellAuto().SpellID == SpellID then
        RubimRH.queuedSpellAuto = { RubimRH.Spell[1].Empty, 0 }
    end

    if RubimRH.QueuedSpell().SpellID == SpellID then
        RubimRH.queuedSpell = { RubimRH.Spell[1].Empty, 0 }
        RubimRH.print("|cFFFFFF00Queued:|r " .. GetSpellLink(SpellID) .. " casted!")
        RubimRH.playSoundR("Interface\\Addons\\Rubim-RH\\Media\\queuecast.ogg")
    end
    for i, spell in pairs(RubimRH.Spell[RubimRH.playerSpec]) do
        if SpellID == spell.SpellID then
            spell.LastCastTime = HL.GetTime()
            spell.LastHitTime = HL.GetTime() + spell:TravelTime()
        end
    end
end, "SPELL_CAST_SUCCESS")

-- Pet On Cast Success Listener
HL:RegisterForPetCombatEvent(function(_, _, _, _, _, _, _, _, _, _, _, SpellID)
    for i, spell in pairs(RubimRH.allSpells) do
        if SpellID == spell.SpellID then
            spell.LastCastTime = HL.GetTime()
            spell.LastHitTime = HL.GetTime() + spell:TravelTime()
        end
    end
end, "SPELL_CAST_SUCCESS")

-- Player Aura Applied Listener
HL:RegisterForSelfCombatEvent(function(_, _, _, _, _, _, _, _, _, _, _, SpellID)
    for i, spell in pairs(RubimRH.Spell[RubimRH.playerSpec]) do
        if SpellID == spell.SpellID then
            spell.LastAppliedOnPlayerTime = HL.GetTime()
        end
    end
end, "SPELL_AURA_APPLIED")

-- Player Aura Removed Listener
HL:RegisterForSelfCombatEvent(function(_, _, _, _, _, _, _, _, _, _, _, SpellID)
    for i, spell in pairs(RubimRH.Spell[RubimRH.playerSpec]) do
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

function Spell:ArenaCast(arenaTarget)
    local arenaTarget = arenaTarget:ID()
    if UnitName(arenaTarget) == UnitName('arena1') then
        RubimRH.Arena1Icon(self:Cast())
    elseif UnitName(arenaTarget) == UnitName('arena2') then
        RubimRH.Arena2Icon(self:Cast())
    elseif UnitName(arenaTarget) == UnitName('arena3') then
        RubimRH.Arena3Icon(self:Cast())
    end
end

-- Is the current unit valid during cycle ?
function RubimRH.UnitIsCycleValid (Unit, BestUnitTTD, TimeToDieOffset)
    return not Unit:IsFacingBlacklisted() and not Unit:IsUserCycleBlacklisted() and (not BestUnitTTD or Unit:FilteredTimeToDie(">", BestUnitTTD, TimeToDieOffset));
end

-- GetSpellTexture cached function
local GetSpellTexture = GetSpellTexture -- remap default API, since if Blizzard change GetSpellTexture then you can just replace it in one space instead edit everything
local spelltexture = setmetatable({}, { __index = function(t, v)
            local pwr = GetSpellTexture(v)
            if pwr then
                t[v] = { 1, pwr }
                return t[v]
            end     
            return 0
end })

function CacheGetSpellTexture(a)
    return unpack(spelltexture[a]) 
end

function RubimRH.GetDescription(spellID)
    local text = GetSpellDescription(spellID) 
    if not text then 
        return {0, 0} 
    end
    local deleted_space, numbers = string.gsub(text, "%s+", ''), {}
    deleted_space = string.gsub(deleted_space, "%d+%%", "")
    for num in string.gmatch(deleted_space, "%d+") do
        table.insert(numbers, tonumber(num))
    end
    if #numbers == 1 then
        return numbers
    end
    table.sort(numbers, function (x, y)
            return x > y
    end)
    return numbers
end

