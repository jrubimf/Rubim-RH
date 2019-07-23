--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
-- HeroLib
local HL     = HeroLib
local Cache  = HeroCache
local Unit   = HL.Unit
local Player = Unit.Player
local Target = Unit.Target
local Pet    = Unit.Pet
local Spell  = HL.Spell
local Item   = HL.Item
local mainAddon = RubimRH

-- Macro Settings
UseBlackOxStatue = false
UseLegSweep = false
UseKick = false

local S = RubimRH.Spell[268]
-- Rotation Var
local ShouldReturn; -- Used to get the return string
-- Items
if not Item.Monk then Item.Monk = {} end
Item.Monk.Brewmaster = {
  BattlePotionOfAgility = Item(163223),
  InvocationOfYulon     = Item(165568),
};
local I = Item.Monk.Brewmaster;

--- Energy Cap -> Returns true if energy will cap in the next GCD
local function EnergyWillCap()
    return (Player:Energy() + (Player:EnergyRegen() * Player:GCD())) >= 100
end

local function AoE()
	-- Leg Sweep
	if S.LegSweep:IsCastableP() and Target:IsInterruptible() and RubimRH.InterruptsON() then
        return S.LegSweep:Cast()
    end
	
    if S.BreathOfFire:IsReady("Melee") then
        return S.BreathOfFire:Cast()
    end

    if S.RushingJadeWind:IsReady(8)
            and not Player:Buff(S.RushingJadeWind) then
        return S.RushingJadeWind:Cast()
    end

    if S.ChiBurst:IsReady(40)
            and RubimRH.lastMoved() >= 1 then
        return S.ChiBurst:Cast()
    end

    if (Player:Buff(S.BlackoutComboBuff) or EnergyWillCap())
            and S.TigerPalm:IsReady("Melee") then
        return S.TigerPalm:Cast()
    end

    if S.BlackoutStrike:IsReady("Melee") then
        return S.BlackoutStrike:Cast()
    end

    if S.ChiWave:IsReady(40) then
        return S.ChiWave:Cast()
    end

    if S.TigerPalm:IsReady("Melee")
            and Player:Energy() >= 55 then
        return S.TigerPalm:Cast()
    end

    if S.RushingJadeWind:IsReady(8) then
        return S.RushingJadeWind:Cast()
    end
	
    return nil
end

local function DetermineEssenceRanks()
  S.BloodOfTheEnemy = S.BloodOfTheEnemy2:IsAvailable() and S.BloodOfTheEnemy2 or S.BloodOfTheEnemy
  S.BloodOfTheEnemy = S.BloodOfTheEnemy3:IsAvailable() and S.BloodOfTheEnemy3 or S.BloodOfTheEnemy
  S.MemoryOfLucidDreams = S.MemoryOfLucidDreams2:IsAvailable() and S.MemoryOfLucidDreams2 or S.MemoryOfLucidDreams
  S.MemoryOfLucidDreams = S.MemoryOfLucidDreams3:IsAvailable() and S.MemoryOfLucidDreams3 or S.MemoryOfLucidDreams
  S.PurifyingBlast = S.PurifyingBlast2:IsAvailable() and S.PurifyingBlast2 or S.PurifyingBlast
  S.PurifyingBlast = S.PurifyingBlast3:IsAvailable() and S.PurifyingBlast3 or S.PurifyingBlast
  S.RippleInSpace = S.RippleInSpace2:IsAvailable() and S.RippleInSpace2 or S.RippleInSpace
  S.RippleInSpace = S.RippleInSpace3:IsAvailable() and S.RippleInSpace3 or S.RippleInSpace
  S.ConcentratedFlame = S.ConcentratedFlame2:IsAvailable() and S.ConcentratedFlame2 or S.ConcentratedFlame
  S.ConcentratedFlame = S.ConcentratedFlame3:IsAvailable() and S.ConcentratedFlame3 or S.ConcentratedFlame
  S.TheUnboundForce = S.TheUnboundForce2:IsAvailable() and S.TheUnboundForce2 or S.TheUnboundForce
  S.TheUnboundForce = S.TheUnboundForce3:IsAvailable() and S.TheUnboundForce3 or S.TheUnboundForce
  S.WorldveinResonance = S.WorldveinResonance2:IsAvailable() and S.WorldveinResonance2 or S.WorldveinResonance
  S.WorldveinResonance = S.WorldveinResonance3:IsAvailable() and S.WorldveinResonance3 or S.WorldveinResonance
  S.FocusedAzeriteBeam = S.FocusedAzeriteBeam2:IsAvailable() and S.FocusedAzeriteBeam2 or S.FocusedAzeriteBeam
  S.FocusedAzeriteBeam = S.FocusedAzeriteBeam3:IsAvailable() and S.FocusedAzeriteBeam3 or S.FocusedAzeriteBeam
end

-- # Essences
local function Essences()
  -- blood_of_the_enemy
  if S.BloodOfTheEnemy:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- concentrated_flame
  if S.ConcentratedFlame:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- guardian_of_azeroth
  if S.GuardianOfAzeroth:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- focused_azerite_beam
  if S.FocusedAzeriteBeam:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- purifying_blast
  if S.PurifyingBlast:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- the_unbound_force
  if S.TheUnboundForce:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- ripple_in_space
  if S.RippleInSpace:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- worldvein_resonance
  if S.WorldveinResonance:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- memory_of_lucid_dreams,if=fury<40&buff.metamorphosis.up
  if S.MemoryOfLucidDreams:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  return false
end

-- Trinket var
local trinket2 = 1030910
local trinket1 = 1030902

-- Trinket Ready
local function trinketReady(trinketPosition)
    local inventoryPosition
    
	if trinketPosition == 1 then
        inventoryPosition = 13
    end
    
	if trinketPosition == 2 then
        inventoryPosition = 14
    end
    
	local start, duration, enable = GetInventoryItemCooldown("Player", inventoryPosition)
    if enable == 0 then
        return false
    end

    if start + duration - GetTime() > 0 then
        return false
    end
	
	if RubimRH.db.profile.mainOption.useTrinkets[1] == false then
	    return false
	end
	
   	if RubimRH.db.profile.mainOption.useTrinkets[2] == false then
	    return false
	end	
	
    if RubimRH.db.profile.mainOption.trinketsUsage == "Everything" then
        return true
    end
	
	if RubimRH.db.profile.mainOption.trinketsUsage == "Boss Only" then
        if not UnitExists("boss1") then
            return false
        end

        if UnitExists("target") and not (UnitClassification("target") == "worldboss" or UnitClassification("target") == "rareelite" or UnitClassification("target") == "rare") then
            return false
        end
    end	
    return true
end

--- Preliminary APL based on Peak of Serenity Rotation Priority for 8.0.1
-- Guide Referenced: http://www.peakofserenity.com/bfa/brewmaster/guide/
local function APL()
local Precombat_DBM, Precombat
    DetermineEssenceRanks()
	Precombat_DBM = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- potion
        -- potion
	    if I.BattlePotionOfAgility:IsReady() and RubimRH.DBM_PullTimer() > Player:GCD() and RubimRH.DBM_PullTimer() <= 2 then
            return 967532
        end		
        -- Tiger Palm
        if S.TigerPalm:IsReady("Melee") and RubimRH.DBM_PullTimer() >= 0.1 and RubimRH.DBM_PullTimer() <= 0.2 then
            return S.TigerPalm:Cast()
        end
    end
	
	Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- potion
    --if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
    --  if I.CastSuggested(I.ProlongedPower) then return "prolonged_power 4"; end
    --end
        -- Tiger Palm
        if S.TigerPalm:IsReady("Melee") then
            return S.TigerPalm:Cast()
        end
    end
      --- Not in combat
  --  if not Player:AffectingCombat() and RubimRH.PrecombatON() then
  --      return 0, 462338
 --   end
    -- call DBM precombat
	if not Player:AffectingCombat() and RubimRH.PrecombatON() and RubimRH.PerfectPullON() and not Target:IsQuestMob() then
        return Precombat_DBM()
	end
    -- call non DBM precombat
	if not Player:AffectingCombat() and RubimRH.PrecombatON() and not RubimRH.PerfectPullON() and not Target:IsQuestMob() then		
        return Precombat()
	end
	
    if QueueSkill() ~= nil then
		return QueueSkill()
    end
	
	-- call_action_list,name=essences
    local ShouldReturn = Essences(); if ShouldReturn and (true) then return ShouldReturn; end

    if Player:IsChanneling() or Player:IsCasting() then
        return 0, 236353
    end
  
    if RubimRH.TargetIsValid() then
	
    -- Unit Update
    HL.GetEnemies(8, true);
    HL.GetEnemies(15, true);
    HL.GetEnemies(40, true);

    -- Misc
    local IsTanking = Player:IsTankingAoE(8) or Player:IsTanking(Target)

    --- Player Macro Options
    -- Paralysis
    if S.Paralysis:IsReadyP() and RubimRH.InterruptsON() then
        return S.Paralysis:Cast()
    end
    -- Leg Sweep
    if S.LegSweep:IsReady()
            and UseLegSweep then
        return S.LegSweep:Cast()
    elseif UseLegSweep and
            (not S.LegSweep:IsReady()) then
        UseLegSweep = false
    end

    -- Black Ox Statue
    if S.BlackOxStatue:IsReady()
            and UseBlackOxStatue then
        return S.BlackOxStatue:Cast()
    elseif UseBlackOxStatue
            and not S.BlackOxStatue:IsReady() then
        UseBlackOxStatue = false
    end
	-- Panda racial kick 2
	if S.QuackingPalm:IsCastableP() and not S.SpearHandStrike:IsReady() and Target:IsInterruptible() and RubimRH.InterruptsON() then
        return S.QuackingPalm:Cast()
    end
    -- Kick
    if S.SpearHandStrike:IsReady() and Target:IsInterruptible() and RubimRH.InterruptsON() then
        return S.SpearHandStrike:Cast()
    elseif UseKick
            and not S.SpearHandStrike:IsReady() then
        UseKick = false
    end
    --- Defensive Rotation
    if S.ExpelHarm:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[268].sk1 then
        return S.ExpelHarm:Cast()
    end

    -- Fortifying Brew
    if S.FortifyingBrew:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[268].sk2 then
        return S.FortifyingBrew:Cast()
    end

    -- Black Ox Brew
    if S.Brews:ChargesFractional() < 1
            and Player:NeedMajorHealing()
            and S.BlackOxBrew:IsAvailable()
            and S.BlackOxBrew:IsReady() then
        return S.BlackOxBrew:Cast()
    end

    -- Ironskin Brew
    if S.Brews:ChargesFractional() >= 1
            and (not Player:Buff(S.IronskinBrewBuff) or (Player:Buff(S.IronskinBrewBuff) and Player:BuffRemains(S.IronskinBrewBuff) <= Player:GCD()))
            and IsTanking then
        return S.IronskinBrew:Cast()
    end

    -- Purifying Brew
    if (Player:Debuff(S.HeavyStagger) or (Player:Debuff(S.ModerateStagger) and Player:HealthPercentage() < 70))
            and S.Brews:ChargesFractional() >= 1
            and Player:NeedMajorHealing()
            and S.PurifyingBrew:IsReady() then
        return S.PurifyingBrew:Cast()
    end

    -- Healing Elixir
    if Player:HealthPercentage() <= 85
            and S.HealingElixir:IsReady() then
        return S.HealingElixir:Cast()
    end

    -- Guard
    if Player:Debuff(S.HeavyStagger)
            and Player:HealthPercentage() <= 80
            and S.Guard:IsReady() then
        return S.Guard:Cast()
    end

    --- Cooldowns

    -- Blood Fury
    if RubimRH.CDsON()
            and S.BloodFury:IsReady("Melee") then
        return S.BloodFury:ID()
    end

    -- Berserking
    if RubimRH.CDsON()
            and S.Berserking:IsReady("Melee") then
        return S.Berserking:ID()
    end

    -- TODO: Handle proper logic for locating distance to statue
    --    if Cache.EnemiesCount[8] >= 3
    --            and BlackOxStatue:IsReady(8)
    --            and (not Pet:IsActive() or Player:FindRange("pet") > 8) then
    --        return BlackOxStatue:Cast()
    --    end

    --- Universal Rotation - Does not change based on targets

    -- Invoke Niuzao: The Black Ox
    if S.InvokeNiuzaotheBlackOx:IsAvailable()
            and S.InvokeNiuzaotheBlackOx:IsReady(40) then
        return S.InvokeNiuzaotheBlackOx:Cast()
    end
	
	-- Blackout Strike
    if S.BlackoutStrike:IsReady("Melee") then
        return S.BlackoutStrike:Cast()
    end

    -- Keg Smash
    if S.KegSmash:IsReady(15) then
        return S.KegSmash:Cast()
    end

    --- AoE Priority
    if Cache.EnemiesCount[8] >= 3
            and AoE() ~= nil then
        return AoE()
    end

    --- Single-Target Priority

    -- Blackout Strike
    if S.BlackoutStrike:IsReady("Melee") and (not Player:Buff(S.BlackoutComboBuff) or not S.BlackoutCombo:IsAvailable()) then
        return S.BlackoutStrike:Cast()
    end

    -- Tiger Palm
    if (Player:Buff(S.BlackoutComboBuff) or EnergyWillCap())
            and S.TigerPalm:IsReady("Melee") then
        return S.TigerPalm:Cast()
    end

    -- Breath of Fire
    if S.BreathOfFire:IsReady("Melee") then
        return S.BreathOfFire:Cast()
    end

    -- Rushing Jade Wind
    if S.RushingJadeWind:IsReady(8)
            and not Player:Buff(S.RushingJadeWind) then
        return S.RushingJadeWind:Cast()
    end

    -- Chi Burst
    if S.ChiBurst:IsReady(40)
            and RubimRH.lastMoved() >= 1 then
        return S.ChiBurst:Cast()
    end

    -- Chi Wave
    if S.ChiWave:IsReady(40) then
        return S.ChiWave:Cast()
    end

    -- Tiger Palm
    if S.TigerPalm:IsReady()
            and Player:Energy() >= 55 then
        return S.TigerPalm:Cast()
    end

    -- Rushing Jade Wind -> Refresh on empty GCD
    if S.RushingJadeWind:IsReady() then
        return S.RushingJadeWind:Cast()
    end
	
	-- Vivify 10%
    --if S.Vivify:IsReady() and Player:HealthPercentage() <= 10 then
    --    return S.Vivify:Cast()
    --end

    end
    return 0, 135328
end
RubimRH.Rotation.SetAPL(268, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(268, PASSIVE);