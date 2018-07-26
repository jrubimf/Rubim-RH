--- Last Edit: S0latium : 7/25/18
--- BfA Affliction v1.0.0
local addonName, addonTable = ...
-- HeroLib
local HL = HeroLib
local Cache = HeroCache
local Unit = HL.Unit
local Player = Unit.Player
local Target = Unit.Target
local Spell = HL.Spell

local ISpells = RubimRH.Spell[265]

-- TODO: Test GroupBuffed
function Spell:GroupBuffed()
  if GetNumGroupMembers() ~= 0 then
      local GroupPrefix = (GetNumGroupMembers() > 5) and "raid" or "party"
      for i=1,GetNumGroupMembers() do
        if not HeroLib.Unit(UnitId(tostring('"' .. GroupPrefix .. i .. '"'))):Buff(self) then return false end
      end
  else
    return HeroLib.Unit("player"):Buff(self)
  end
  return true
end

-- TODO: AOE
local function AoE()
  
  return nil  
end

local function ShouldDB()
  local DoTs = {
    Agony = ISpells.Agony,
    Corruption = ISpells.Corruption,
    UnstableAffliction = ISpells.Corruption,
    SiphonLife = (ISpells.SiphonLife:IsAvailable()) and ISpells.SiphonLife or nil,
  }
  
  local DoTCount = 0
  for i=1,4 do
    if DoTs[i] ~= nil then
      if Target:Debuff(DoTs[i]) then DoTCount = DoTCount + 1 end
    end
  end
  
  return (DoTCount >= 2) and true or false
end

--- Preliminary APL based on Icy-Veins Affliction Warlock for 8.0.1
-- Guide Referenced: https://www.icy-veins.com/wow/affliction-warlock-pve-dps-rotation-cooldowns-abilities
local function APL()

  --- Not in combat
  if not Player:AffectingCombat() then
    return 0, 462338
  end

  -- All Spells: 40 yard range
  HL.GetEnemies(40, true);
  
  -- Primary AoE Rotation
  if Cache.EnemiesCount[40] >= 2 
  and AoE() ~= nil then
    return AoE()
  end
  
  -- Get remaining debuff duration to refresh DoTs for Pandemic including offset for remaining GCD
  local DoTRefresh = {
    Agony = ((ISpells.CreepingDeath:IsAvailable()) and ((5.4 + Player:GCDRemains()) * 0.85)) or 5.4 + Player:GCDRemains(),
    Corruption = ((ISpells.AbsoluteCorruption:IsAvailable()) and (not Target:IsAPlayer())) and 100 or 4.2 + Player:GCDRemains(),
    SiphonLife = (ISpells.CreepingDeath:IsAvailable()) and ((4.5 + Player:GCDRemains()) * 0.85) or 4.5 + Player:GCDRemains()
  }
  DoTRefresh.Corruption = (ISpells.CreepingDeath:IsAvailable()) and DoTRefresh.Corruption * 0.85 or DoTRefresh.Corruption
    
  local PlayerStill = (not Player:IsMoving()) and true or false
  local UARefreshForDeathbolt = (ISpells.Deathbolt:IsAvailable() 
                                and (not ISpells.Deathbolt:CoolodwnUp() 
                                    and ISpells.Deathbolt:CooldownRemains() <= 4 
                                    and Target:DebuffRemains(ISpells.UnstableAffliction) < 6)) and true or false
  
  -- Primary Single Target Rotation

  -- Summon Darkglare - use with all DoTs up and Target:TimeToDie() > 15
  if ISpells.SummonDarkglare:IsReady(40)
  and Target:Debuff(ISpells.Agony)
  and Target:Debuff(ISpells.Corruption)
  and Target:Debuff(ISpells.UnstableAffliction)
  and ((not ISpells.SiphonLife:IsAvailable()) or Target:Debuff(ISpells.SiphonLife))
  and Target:TimeToDie() >= 15 then
    return ISpells.SummonDarkglare:Cast()
  end
  
  -- Deathbolt
  if ISpells.Deathbolt:IsAvailable()
  and ISpells.Deathbolt:IsReady(40) then
    return ISpells.Deathbolt:Cast()
  end
  
  -- Agony
  local AgonyRefreshDuration = 5.4 + Player:GCDRemains()
  if ISpells.Agony:IsReady(40) 
  and Target:DebuffRemains(ISpells.Agony) <= DoTRefresh.Agony then
    return ISpells.Agony:Cast()
  end

  -- Corruption
  if ISpells.Corruption:IsReady(40)
  and Target:DebuffRemains(ISpells.Corruption) ~= nil
  and Target:DebuffRemains(ISpells.Corruption) <= DoTRefresh.Corruption then
    return ISpells.Corruption:Cast()
  end

  -- Siphon Life
  if ISpells.SiphonLife:IsReady(40)
  and ISpells.SiphonLife:IsAvailable()
  and Target:DebuffRemains(ISpells.SiphonLife) <= DoTRefresh.SiphonLife then
    return ISpells.SiphonLife:Cast()
  end
  
  -- Unstable Affliction - stack it if 4-5 Soul Shards
  if ISpells.UnstableAffliction:IsReady(40)
  and (Player:SoulShards() >= 4 or UARefreshForDeathbolt)
  and PlayerStill then
    return ISpells.UnstableAffliction:Cast()
  end
    
  -- Instant-Cast Shadow Bolt
  if ISpells.ShadowBolt:IsReady(40)
  and Player:Buff(ISpells.Nightfall) then
    return ISpells.ShadowBolt:Cast()
  end
  
  -- Haunt
  if ISpells.Haunt:IsReady(40) 
  and PlayerStill then
    return ISpells.Haunt:Cast()
  end
  
  -- Phantom Singularity
  if ISpells.PhantomSingularity:IsAvailable()
  and ISpells.PhantomSingularity:IsReady(40) then
    return ISpells.PhantomSingularity:Cast()
  end
  
  -- Unstable Affliction - maintain DoT at all times
  if ISpells.UnstableAffliction:IsReady(40)
  and Player:SoulShards() >= 1
  and Target:DebuffRemains(ISpells.UnstableAffliction) <= Player:GCD()
  and PlayerStill then
    return ISpells.UnstableAffliction:Cast()
  end
  
  return 0, 975743
end

RubimRH.Rotation.SetAPL(265, APL);

local function PASSIVE()
  return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(265, PASSIVE);