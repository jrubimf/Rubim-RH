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

    if Range then
        local RangeUnit = ThisUnit or Target;
        return self:IsLearned() and self:CooldownUp() and RangeUnit:IsInRange(Range, AoESpell);
    else
        return self:IsLearned() and self:CooldownUp();
    end
end

function Spell:IsCastableQueue(Range, AoESpell, ThisUnit)
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

    if not self:IsAvailable() then
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
    if self:IsEnabled() == false then
        return false
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

-- Demono pets function start
HL.GuardiansTable = {
    --{ID, name, spawnTime, ImpCasts, Duration, despawnTime}
    Pets = { 
      },
      ImpCount = 0,
	  ImpCastsRemaing = 0,
	  ImpTotalEnergy = 0,
	  WildImpDuration = 0,
      FelguardDuration = 0,
      DreadstalkerDuration = 0,
      DemonicTyrantDuration = 0,
	  VilefiendDuration = 0,	  
};


-- local for pets count & duration functions    
local PetDurations = {
 -- en, fr ,de ,ru
 ["Traqueffroi"] = 12.25,
 ["Dreadstalker"] = 12.25, 
 ["Зловещий охотник"] = 12.25, 
 ["Schreckenspirscher"] = 12.25, 
 ["Diablotin sauvage"] = 20, 
 ["Wild Imp"] = 20, 
 ["Дикий бес"] = 20, 
 ["Wildwichtel"] = 20,  
 ["Gangregarde"] = 28, 
 ["Felguard"] = 20, 
 ["Страж Скверны"] = 20, 
 ["Teufelswache"] = 20,  
 ["Tyran démoniaque"] = 15, 
 ["Demonic Tyrant"] = 20, 
 ["Демонический тиран"] = 20, 
 ["Dämonischer Tyrann"] = 20, 
 ["Démon abject"] = 15,
 ["Vilefiend"] = 20, 
 ["Мерзотень"] = 20, 
 ["Finsteres Scheusal"] = 20 
 
 };

 local PetTypes = {
  -- en, fr ,de ,ru
 ["Traqueffroi"] = true, 
 ["Dreadstalker"] = true, 
 ["Зловещий охотник"] = true, 
 ["Schreckenspirscher"] = true,
 ["Diablotin sauvage"]  = true, 
 ["Wild Imp"] = true, 
 ["Дикий бес"] = true, 
 ["Wildwichtel"] = true, 
 ["Gangregarde"] = true, 
 ["Felguard"] = true, 
 ["Страж Скверны"] = true, 
 ["Teufelswache"] = true,   
 ["Tyran démoniaque"] = true, 
 ["Demonic Tyrant"] = true, 
 ["Демонический тиран"] = true, 
 ["Dämonischer Tyrann"] = true,  
 ["Démon abject"] = true,
 ["Vilefiend"] = true, 
 ["Мерзотень"] = true, 
 ["Finsteres Scheusal"] = true  
 };
local PetList= {
	    ["Wild Imp"] = 55659,
	    ["Wild Imp"] = 99737,
	    ["Dreadstalker"] = 98035,
	    ["Demonic Tyrant"] = 135002,
	    ["Felguard"] = 17252};
--------------------------
----- Demonology ---------
--------------------------
	-- Update the GuardiansTable
local function UpdatePetTable()
    for key, petTable in pairs(HL.GuardiansTable.Pets) do
        if petTable then
            -- Remove expired pets
            if GetTime() >= petTable.despawnTime then
		        if petTable.name == "Wild Imp" or petTable.name == "Diablotin sauvage" or petTable.name == "Дикий бес" or petTable.name == "Wildwichtel" then
                    HL.GuardiansTable.ImpCount = HL.GuardiansTable.ImpCount - 1
			    end
			    if petTable.name == "Gangregarde" or petTable.name == "Felguard" or petTable.name == "Страж Скверны" or petTable.name == "Teufelswache"  then
                    HL.GuardiansTable.FelguardDuration = 0
                elseif petTable.name == "Traqueffroi" or petTable.name == "Dreadstalker" or petTable.name == "Зловещий охотник" or petTable.name == "Schreckenspirscher" then
                    HL.GuardiansTable.DreadstalkerDuration = 0
                elseif petTable.name == "Tyran démoniaque" or petTable.name == "Demonic Tyrant" or petTable.name == "Демонический тиран" or petTable.name == "Dämonischer Tyrann" then
                    HL.GuardiansTable.DemonicTyrantDuration = 0
			    elseif petTable.name == "Démon abject" or petTable.name == "Vilefiend" or petTable.name == "Мерзотень" or petTable.name == "Finsteres Scheusal" then
                    HL.GuardiansTable.VilefiendDuration = 0
                elseif petTable.name == "Wild Imp" or petTable.name == "Diablotin sauvage" or petTable.name == "Дикий бес" or petTable.name == "Wildwichtel" then
                    HL.GuardiansTable.WildImpDuration = 0
                    HL.GuardiansTable.ImpCastsRemaing = HL.GuardiansTable.ImpCastsRemaing - petTable.ImpCasts
                    HL.GuardiansTable.ImpTotalEnergy =  HL.GuardiansTable.ImpCastsRemaing * 20
                end
                HL.GuardiansTable.Pets[key] = nil
            end
        end
        -- Remove any imp that has casted all of its bolts
        if petTable.ImpCasts <= 0 and  petTable.WildImpFrozenEnd < 1 then
            HL.GuardiansTable.ImpCount = HL.GuardiansTable.ImpCount - 1
            HL.GuardiansTable.Pets[key] = nil
        end
        -- Update Durations
        if GetTime() <= petTable.despawnTime then
            petTable.Duration = petTable.despawnTime - GetTime()
            if petTable.name == "Gangregarde" or petTable.name == "Felguard" or petTable.name == "Страж Скверны" or petTable.name == "Teufelswache" then
                HL.GuardiansTable.FelguardDuration = petTable.Duration
            elseif petTable.name == "Traqueffroi" or petTable.name == "Dreadstalker" or petTable.name == "Зловещий охотник" or petTable.name == "Schreckenspirscher" then
                HL.GuardiansTable.DreadstalkerDuration = petTable.Duration
            elseif petTable.name == "Tyran démoniaque" or petTable.name == "Demonic Tyrant" or petTable.name == "Демонический тиран" or petTable.name == "Dämonischer Tyrann" then
                HL.GuardiansTable.DemonicTyrantDuration = petTable.Duration
            elseif petTable.name == "Démon abject" or petTable.name == "Vilefiend" or petTable.name == "Мерзотень" or petTable.name == "Finsteres Scheusal" then
                HL.GuardiansTable.VilefiendDuration = petTable.Duration
            elseif petTable.name == "Wild Imp" or petTable.name == "Diablotin sauvage" or petTable.name == "Дикий бес" or petTable.name == "Wildwichtel" then
                HL.GuardiansTable.WildImpDuration = petTable.Duration
                if petTable.WildImpFrozenEnd ~= 0 then
                    local ImpTime =  math.floor(petTable.WildImpFrozenEnd - GetTime() + 0.5)
                    if ImpTime < 1 then 
					    petTable.WildImpFrozenEnd = 0 
					end
                end
            end	
            -- Add Time to pets  
		    if TyrantSpawed then
                if petName == "Tyran démoniaque" or petTable.name == "Demonic Tyrant" or petTable.name == "Демонический тиран" or petTable.name == "Dämonischer Tyrann" then
				    -- If not Talent Demonic Consumption
					if not S.DemonicConsumption:IsAvailable() then
                        for key, petTable in pairs(HL.GuardiansTable.Pets) do
                            if petTable then
                                petTable.spawnTime = GetTime() + petTable.Duration + 15 - PetDurations[petTable.name]
                                petTable.despawnTime = petTable.spawnTime + PetDurations[petTable.name]
                                if petTable.name == "Wild Imp" or petTable.name == "Diablotin sauvage" or petTable.name == "Дикий бес" or petTable.name == "Wildwichtel" then
                                    petTable.WildImpFrozenEnd = GetTime() + 15
							    end
                            end
                        end
                    -- If Talent Demonic Consumption
					elseif S.DemonicConsumption:IsAvailable() then
					    for key, petTable in pairs(HL.GuardiansTable.Pets) do
                            if petTable.name == "Wild Imp" or petTable.name == "Diablotin sauvage" or petTable.name == "Дикий бес" or petTable.name == "Wildwichtel" then
                                HL.GuardiansTable.Pets[key] = nil
                            end
                        end
                        HL.GuardiansTable.ImpCount = 0
                        HL.GuardiansTable.ImpCastsRemaing = 0
                        HL.GuardiansTable.ImpTotalEnergy = 0
					end	
				end
            end
        end
        if TyrantSpawed then TyrantSpawed = false end  
	end
end	
-- Add demon to table
HL:RegisterForSelfCombatEvent(
    function (...)
        --local timestamp,Event,_,_,_,_,_,UnitPetGUID,petName,_,_,SpellID=select(1,...)
		timestamp,Event,_,_,_,_,_,UnitPetGUID,petName,_,_,SpellID=select(1,...)
        -- Add pet
        if (UnitPetGUID ~= UnitGUID("pet") and Event == "SPELL_SUMMON" and PetTypes[petName]) then
            local petTable = {
            ID = UnitPetGUID,
            name = petName,
            spawnTime = GetTime(),
            ImpCasts = 5,
            Duration = PetDurations[petName],
			WildImpFrozenEnd = 0,
            despawnTime = GetTime() + tonumber(PetDurations[petName])
            }
            table.insert(HL.GuardiansTable.Pets,petTable)
		    if petName == "Wild Imp" or petTable.name == "Diablotin sauvage" or petTable.name == "Дикий бес" or petTable.name == "Wildwichtel" then
                HL.GuardiansTable.ImpCount = HL.GuardiansTable.ImpCount + 1
		    	HL.GuardiansTable.ImpCastsRemaing = HL.GuardiansTable.ImpCastsRemaing + 5
                HL.GuardiansTable.WildImpDuration = PetDurations[petName]
                petTable.WildImpFrozenEnd = 0 
		    elseif petName == "Gangregarde" or petTable.name == "Felguard" or petTable.name == "Страж Скверны" or petTable.name == "Teufelswache" then
		        HL.GuardiansTable.FelguardDuration = PetDurations[petName]
		    elseif petName == "Traqueffroi" or petTable.name == "Dreadstalker" or petTable.name == "Зловещий охотник" or petTable.name == "Schreckenspirscher" then
		        HL.GuardiansTable.DreadstalkerDuration = PetDurations[petName]
		    elseif petName == "Tyran démoniaque" or petTable.name == "Demonic Tyrant" or petTable.name == "Демонический тиран" or petTable.name == "Dämonischer Tyrann" then
                if not TyrantSpawed then TyrantSpawed = true  end
                HL.GuardiansTable.DemonicTyrantDuration = PetDurations[petName]
                UpdatePetTable()
		    elseif petName == "Démon abject" or petTable.name == "Vilefiend" or petTable.name == "Мерзотень" or petTable.name == "Finsteres Scheusal" then
                HL.GuardiansTable.VilefiendDuration = PetDurations[petName]   
		    end
        end
		
		
			-- Add 15 seconds and 7 casts to all pets when Tyrant is cast
        --    if petName == "Demonic Tyrant" then
        --        for key, petTable in pairs(HL.GuardiansTable.Pets) do
        --           if petTable then
        --               petTable.despawnTime = petTable.despawnTime + 15
        --               petTable.ImpCasts = petTable.ImpCasts + 7
        --           end
        --       end
        --    end
		
        -- Update the pet table
        UpdatePetTable()
    end
    , "SPELL_SUMMON"
);
	
-- Decrement ImpCasts and Implosion Listener
HL:RegisterForCombatEvent(
    function (...)
      --local timestamp,Event,_,SourceGUID,SourceName,_,_,UnitPetGUID,petName,_,_,SpellID = select(4, ...);
      --local timestamp,Event,_,SourceGUID,SourceName,_,_,UnitPetGUID,petName,_,_,spell,SpellName=select(1,...)
        local SourceGUID,_,_,_,UnitPetGUID,_,_,_,SpellID = select(4, ...);
		
		-- Check for imp bolt casts
        if SpellID == 104318 then
            for key, petTable in pairs(HL.GuardiansTable.Pets) do
                if SourceGUID == petTable.ID then
                    if  petTable.WildImpFrozenEnd < 1 then
                        petTable.ImpCasts = petTable.ImpCasts - 1
                        HL.GuardiansTable.ImpCastsRemaing = HL.GuardiansTable.ImpCastsRemaing - 1
                    end
                end
            end
			HL.GuardiansTable.ImpTotalEnergy =  HL.GuardiansTable.ImpCastsRemaing * 20
        end
        
        -- Clear the imp table upon Implosion cast
        if SpellID == 196277 then
            for key, petTable in pairs(HL.GuardiansTable.Pets) do
                if petTable.name == "Wild Imp" or petTable.name == "Diablotin sauvage" or petTable.name == "Дикий бес" or petTable.name == "Wildwichtel" then
                    HL.GuardiansTable.Pets[key] = nil
                end
            end
            HL.GuardiansTable.ImpCount = 0
            HL.GuardiansTable.ImpCastsRemaing = 0
            HL.GuardiansTable.ImpTotalEnergy = 0
        end
        
        -- Update the imp table
        UpdatePetTable()
      end
    , "SPELL_CAST_SUCCESS"
);
