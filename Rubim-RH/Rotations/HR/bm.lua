--- Localize Vars
-- Addon
local addonName, addonTable = ...;
-- HeroLib
local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Pet = Unit.Pet;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;

local mainAddon = RubimRH

-- Spells
RubimRH.Spell[253] = {

    -- Racials
    ArcaneTorrent = Spell(80483),
    AncestralCall = Spell(274738),
    Berserking = Spell(26297),
    BerserkingBuff = Spell(26297),
    BloodFury = Spell(20572),
    BloodFuryBuff = Spell(20572),
    Fireblood = Spell(265221),
    GiftoftheNaaru = Spell(59547),
    LightsJudgment = Spell(255647),
    Shadowmeld = Spell(58984),
    -- Pet
    CallPet = Spell(883),
    MendPet = Spell(136),
    RevivePet = Spell(982),
    -- Abilities
    AspectoftheWild = Spell(193530),
    AspectoftheWildBuff = Spell(193530),
    BarbedShot = Spell(217200),
    Frenzy = Spell(272790),
    FrenzyBuff = Spell(272790),
    BeastCleave = Spell(115939),
    BeastCleaveBuff = Spell(118455),
    BestialWrath = Spell(19574),
    BestialWrathBuff = Spell(19574),
    CobraShot = Spell(193455),
    KillCommand = Spell(34026),
    Multishot = Spell(2643),
    -- Talents
    AMurderofCrows = Spell(131894),
    AnimalCompanion = Spell(267116),
    AspectoftheBeast = Spell(191384),
    Barrage = Spell(120360),
    BindingShot = Spell(109248),
    ChimaeraShot = Spell(53209),
    DireBeast = Spell(120679),
    KillerInstinct = Spell(273887),
    OnewiththePack = Spell(199528),
    ScentofBlood = Spell(193532),
    SpittingCobra = Spell(194407),
    Stampede = Spell(201430),
    ThrilloftheHunt = Spell(257944),
    VenomousBite = Spell(257891),
    -- Defensive
    AspectoftheTurtle = Spell(186265),
    Exhilaration = Spell(109304),
    -- Utility
    AspectoftheCheetah = Spell(186257),
    CounterShot = Spell(147362),
    Disengage = Spell(781),
    FreezingTrap = Spell(187650),
    FeignDeath = Spell(5384),
    TarTrap = Spell(187698),
    -- Legendaries
    ParselsTongueBuff = Spell(248084),
    -- AzeriteEnabled
    PrimalInstincts = Spell(279806),
    FeedingFrenzy = Spell(278529),
    -- Misc
    PotionOfProlongedPowerBuff = Spell(229206),
    SephuzBuff = Spell(208052),
    ConcusiveShot = Spell(5116),
    Intimidation = Spell(19577),
	
		  --8.2 Essences
  UnleashHeartOfAzeroth = Spell(280431),
  BloodOfTheEnemy       = Spell(297108),
  BloodOfTheEnemy2      = Spell(298273),
  BloodOfTheEnemy3      = Spell(298277),
  ConcentratedFlame     = Spell(295373),
  ConcentratedFlame2    = Spell(299349),
  ConcentratedFlame3    = Spell(299353),
  GuardianOfAzeroth     = Spell(295840),
  GuardianOfAzeroth2    = Spell(299355),
  GuardianOfAzeroth3    = Spell(299358),
  FocusedAzeriteBeam    = Spell(295258),
  FocusedAzeriteBeam2   = Spell(299336),
  FocusedAzeriteBeam3   = Spell(299338),
  PurifyingBlast        = Spell(295337),
  PurifyingBlast2       = Spell(299345),
  PurifyingBlast3       = Spell(299347),
  TheUnboundForce       = Spell(298452),
  TheUnboundForce2      = Spell(299376),
  TheUnboundForce3      = Spell(299378),
  RippleInSpace         = Spell(302731),
  RippleInSpace2        = Spell(302982),
  RippleInSpace3        = Spell(302983),
  WorldveinResonance    = Spell(295186),
  WorldveinResonance2   = Spell(298628),
  WorldveinResonance3   = Spell(299334),
  MemoryOfLucidDreams   = Spell(298357),
  MemoryOfLucidDreams2  = Spell(299372),
  MemoryOfLucidDreams3  = Spell(299374),

}

local S = RubimRH.Spell[253]

S.CallPet.TextureSpellID = { S.MendPet:ID() }
S.RevivePet.TextureSpellID = { S.MendPet:ID() }

-- Rotation Var
local ShouldReturn; -- Used to get the return string
-- Items
if not Item.Hunter then Item.Hunter = {} end
Item.Hunter.BeastMastery = {
  BattlePotionofAgility            = Item(163223)
};
local I = Item.Hunter.BeastMastery;

local function PetActive()
    local petActive = false
    if Pet:Exists() then
        petActive = true
    end

    if Pet:IsActive() then
        petActive = true
    end

    if Pet:IsDeadOrGhost() then
        petActive = false
    end

    return petActive
end

-- Rotation Var
local ShouldReturn;

local EnemyRanges = {40}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    HL.GetEnemies(i);
  end
end

local OffensiveCDs = {
    S.AspectoftheWild,
    S.SpittingCobra,
    S.Stampede,

    -- Racial

    S.AncestralCall,
    S.Fireblood,
    S.Berserking,
    S.BloodFury,
    S.LightsJudgment
}

local function UpdateCDs()
    if RubimRH.CDsON() then
        for i, spell in pairs(OffensiveCDs) do
            if not spell:IsEnabledCD() then
                RubimRH.delSpellDisabledCD(spell:ID())
            end
        end

    end
    if not RubimRH.CDsON() then
        for i, spell in pairs(OffensiveCDs) do
            if spell:IsEnabledCD() then
                RubimRH.addSpellDisabledCD(spell:ID())
            end
        end
    end
end

local function num(val)
    if val then
        return 1
    else
        return 0
    end
end

local function bool(val)
    return val ~= 0
end

local function cacheOverwrite()
    Cache.Persistent.SpellLearned.Player[S.MendPet.SpellID] = true
end

local function GetEnemiesCount()
  if RubimRH.AoEON() then
    if RubimRH.db.profile[253].useSplashData == "Enabled" then
      RubimRH.UpdateSplashCount(Target, 10)
      return RubimRH.GetSplashCount(Target, 10)
    else
      UpdateRanges()
      --return GetEnemiesCount()
	  return active_enemies()
    end
  else
    return 1
  end
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

--- APL Main
local function APL()
    local Precombat, Cds, Cleave, St
    UpdateCDs()
    UpdateRanges()
    cacheOverwrite()
    if Player:BuffP(S.FeignDeath) or Player:BuffP(S.Shadowmeld) then
        return 0, "Interface\\Addons\\Rubim-RH\\Media\\channel.tga"
    end
    Precombat = function()
        -- mendpet
        if S.MendPet:IsCastable() and Pet:IsActive() and Pet:HealthPercentage() > 0 and Pet:HealthPercentage() <= RubimRH.db.profile[253].sk1 and not Pet:Buff(S.MendPet) then
            return S.MendPet:Cast()
        end
      
        -- flask
      -- augmentation
      -- food
      -- summon_pet
        if Pet:IsDeadOrGhost() then
            return S.MendPet:Cast()
        elseif not Pet:IsActive() then
            return S.CallPet:Cast()
        end
      -- snapshot_stats
      -- potion
	  	-- pre potion no haunt
        --if I.BattlePotionOfIntellect:IsReady() and not S.Haunt:IsAvailable() and RubimRH.DBM_PullTimer() > S.Haunt:CastTime() + 1 and RubimRH.DBM_PullTimer() <= S.ShadowBolt:CastTime() + 2 then
        --    return 967532
       --end
      -- cobra_shot,if=cooldown.kill_command.remains>focus.time_to_max
      if S.CobraShot:IsReady() and Target:Exists() then
        return S.CobraShot:Cast()
      end
      -- aspect_of_the_wild,precast_time=1.1,if=!azerite.primal_instincts.enabled
      --if S.AspectoftheWild:IsCastableP() and Player:BuffDownP(S.AspectoftheWildBuff) and (not S.PrimalInstincts:AzeriteEnabled()) then
      --  return S.AspectoftheWild:Cast()
      --end
      -- bestial_wrath,precast_time=1.5,if=azerite.primal_instincts.enabled
      --if S.BestialWrath:IsCastableP() and Player:BuffDownP(S.BestialWrathBuff) and (S.PrimalInstincts:AzeriteEnabled()) then
      --  return S.BestialWrath:Cast()
      --end
    end
    Cds = function()
-- call_action_list,name=essences
    local ShouldReturn = Essences(); if ShouldReturn then return ShouldReturn; end
      -- ancestral_call,if=cooldown.bestial_wrath.remains>30
      if S.AncestralCall:IsReady() and (S.BestialWrath:CooldownRemainsP() > 30) then
        return S.AncestralCall:Cast()
      end
      -- fireblood,if=cooldown.bestial_wrath.remains>30
      if S.Fireblood:IsReady() and (S.BestialWrath:CooldownRemainsP() > 30) then
       return S.Fireblood:Cast()
      end
      -- berserking,if=buff.aspect_of_the_wild.up&(target.time_to_die>cooldown.berserking.duration+duration|(target.health.pct<35|!talent.killer_instinct.enabled))|target.time_to_die<13
      if S.Berserking:IsReady()  and (Player:BuffP(S.AspectoftheWildBuff) and (Target:TimeToDie() > S.Berserking:BaseDuration() + S.BerserkingBuff:BaseDuration() or (Target:HealthPercentage() < 35 or not S.KillerInstinct:IsAvailable())) or Target:TimeToDie() < 13) then
        return S.Berserking:Cast()
      end
      -- blood_fury,if=buff.aspect_of_the_wild.up&(target.time_to_die>cooldown.blood_fury.duration+duration|(target.health.pct<35|!talent.killer_instinct.enabled))|target.time_to_die<16
      if S.BloodFury:IsReady() and (Player:BuffP(S.AspectoftheWildBuff) and (Target:TimeToDie() > S.BloodFury:BaseDuration() + S.BloodFuryBuff:BaseDuration() or (Target:HealthPercentage() < 35 or not S.KillerInstinct:IsAvailable())) or Target:TimeToDie() < 16) then
        return S.BloodFury:Cast()
      end
      -- lights_judgment,if=pet.cat.buff.frenzy.up&pet.cat.buff.frenzy.remains>gcd.max|!pet.cat.buff.frenzy.up
      if S.LightsJudgment:IsReady() and (Pet:BuffP(S.FrenzyBuff) and Pet:BuffRemainsP(S.FrenzyBuff) > Player:GCD() or not Pet:BuffP(S.FrenzyBuff)) then
        return S.LightsJudgment:Cast() 
      end
      -- potion,if=buff.bestial_wrath.up&buff.aspect_of_the_wild.up&(target.health.pct<35|!talent.killer_instinct.enabled)|target.time_to_die<25
    end
    Cleave = function()
      -- barbed_shot,if=pet.cat.buff.frenzy.up&pet.cat.buff.frenzy.remains<=gcd.max
      if S.BarbedShot:IsReady() and (Pet:BuffP(S.FrenzyBuff) and Pet:BuffRemainsP(S.FrenzyBuff) <= Player:GCD() * 1.5) then
        return S.BarbedShot:Cast()
      end
      -- multishot,if=gcd.max-pet.cat.buff.beast_cleave.remains>0.25
      if S.Multishot:IsReady() and (Player:GCD() - Pet:BuffRemainsP(S.BeastCleaveBuff) > 0.25) then
        return S.Multishot:Cast()
      end
      -- barbed_shboolot,if=full_recharge_time<gcd.max&cooldown.bestial_wrath.remains
      if S.BarbedShot:IsReady() and (S.BarbedShot:FullRechargeTimeP() < Player:GCD() and bool(S.BestialWrath:CooldownRemainsP())) then
        return S.BarbedShot:Cast()
      end
      -- aspect_of_the_wild
      if S.AspectoftheWild:IsReady() and RubimRH.CDsON() then
        return S.AspectoftheWild:Cast()
      end
      -- stampede,if=buff.aspect_of_the_wild.up&buff.bestial_wrath.up|target.time_to_die<15
      if S.Stampede:IsReady() and (Player:BuffP(S.AspectoftheWildBuff) and Player:BuffP(S.BestialWrathBuff) or Target:TimeToDie() < 15) then
        return S.Stampede:Cast()
      end
      -- bestial_wrath,if=cooldown.aspect_of_the_wild.remains>20|target.time_to_die<15
      if S.BestialWrath:IsReady() and (S.AspectoftheWild:CooldownRemainsP() > 20 or Target:TimeToDie() < 15) then
        return S.BestialWrath:Cast()
      end
      -- chimaera_shot
      if S.ChimaeraShot:IsReady() then
        return S.ChimaeraShot:Cast()
      end
      -- a_murder_of_crows
      if S.AMurderofCrows:IsReady() then
        return S.AMurderofCrows:Cast()
      end
      -- barrage,if=active_enemies>1
      if S.Barrage:IsReadyP() and (not Player:IsMoving() and GetEnemiesCount() > 1) then
        return S.Barrage:Cast()
      end
      -- kill_command
      if S.KillCommand:IsReady() then
        return S.KillCommand:Cast()
      end
      -- dire_beast
      if S.DireBeast:IsReady() then
        return S.DireBeast:Cast()
      end
      -- barbed_shot,if=pet.cat.buff.frenzy.down&(charges_fractional>1.8|buff.bestial_wrath.up)|cooldown.aspect_of_the_wild.remains<pet.cat.buff.frenzy.duration-gcd&azerite.primal_instincts.enabled|target.time_to_die<9
      if S.BarbedShot:IsReady() and (Pet:BuffDownP(S.FrenzyBuff) and (S.BarbedShot:ChargesFractionalP() > 1.8 or Player:BuffP(S.BestialWrathBuff)) or S.AspectoftheWild:CooldownRemainsP() < S.FrenzyBuff:BaseDuration() - Player:GCD() and S.PrimalInstincts:AzeriteEnabled() or Target:TimeToDie() < 9) then
        return S.BarbedShot:Cast()
      end
      -- cobra_shot,if=cooldown.kill_command.remains>focus.time_to_max
      if S.CobraShot:IsReady() and (S.KillCommand:CooldownRemainsP() > Player:FocusTimeToMaxPredicted()) then
        return S.CobraShot:Cast()
      end
      -- spitting_cobra
      if S.SpittingCobra:IsReady()  then
        return S.SpittingCobra:Cast()
      end
    end
    
    St = function()
      -- barbed_shot,if=pet.cat.buff.frenzy.up&pet.cat.buff.frenzy.remains<=gcd.max|full_recharge_time<gcd.max&cooldown.bestial_wrath.remains|azerite.primal_instincts.enabled&cooldown.aspect_of_the_wild.remains<gcd
      if S.BarbedShot:IsReady() and (Pet:BuffP(S.FrenzyBuff) and Pet:BuffRemainsP(S.FrenzyBuff) <= Player:GCD() * 1.5 or S.BarbedShot:FullRechargeTimeP() < Player:GCD() and (S.BestialWrath:CooldownRemainsP()) or S.PrimalInstincts:AzeriteEnabled() and S.AspectoftheWild:CooldownRemainsP() < Player:GCD()) then
        return S.BarbedShot:Cast()
      end
      -- aspect_of_the_wild
      if S.AspectoftheWild:IsReady() and RubimRH.CDsON() then
        return S.AspectoftheWild:Cast()
      end
      -- a_murder_of_crows
      if S.AMurderofCrows:IsReady()  then
        return S.AMurderofCrows:Cast()
      end
      -- stampede,if=buff.aspect_of_the_wild.up&buff.bestial_wrath.up|target.time_to_die<15
      if S.Stampede:IsReady()  and (Player:BuffP(S.AspectoftheWildBuff) and Player:BuffP(S.BestialWrathBuff) or Target:TimeToDie() < 15) then
        return S.Stampede:Cast()
      end
      -- bestial_wrath,if=cooldown.aspect_of_the_wild.remains>20|target.time_to_die<15
      if S.BestialWrath:IsReady() and RubimRH.CDsON() and (S.AspectoftheWild:CooldownRemainsP() > 20 or Target:TimeToDie() < 15) then
        return S.BestialWrath:Cast()
      end
      -- kill_command
      if S.KillCommand:IsReady() then
        return S.KillCommand:Cast()
      end
      -- chimaera_shot
      if S.ChimaeraShot:IsReady() then
        return S.ChimaeraShot:Cast()
      end
      -- dire_beast
      if S.DireBeast:IsReady() then
        return S.DireBeast:Cast()
      end
      -- barbed_shot,if=pet.cat.buff.frenzy.down&(charges_fractional>1.8|buff.bestial_wrath.up)|cooldown.aspect_of_the_wild.remains<pet.cat.buff.frenzy.duration-gcd&azerite.primal_instincts.enabled|target.time_to_die<9
      if S.BarbedShot:IsReady() and (Pet:BuffDownP(S.FrenzyBuff) and (S.BarbedShot:ChargesFractionalP() > 1.8 or Player:BuffP(S.BestialWrathBuff)) or S.AspectoftheWild:CooldownRemainsP() < S.FrenzyBuff:BaseDuration() - Player:GCD() and S.PrimalInstincts:AzeriteEnabled() or Target:TimeToDie() < 9) then
        return S.BarbedShot:Cast()
      end
      -- barrage
      if S.Barrage:IsReadyP() and (not Player:IsMoving()) then
          return S.Barrage:Cast()
      end
      -- cobra_shot,if=(focus-cost+focus.regen*(cooldown.kill_command.remains-1)>action.kill_command.cost|cooldown.kill_command.remains>1+gcd)&cooldown.kill_command.remains>1
      if S.CobraShot:IsReady() and ((Player:Focus() - S.CobraShot:Cost() + Player:FocusRegen() * (S.KillCommand:CooldownRemainsP() - 1) > S.KillCommand:Cost() or S.KillCommand:CooldownRemainsP() > 1 + Player:GCD()) and S.KillCommand:CooldownRemainsP() > 1) then
        return S.CobraShot:Cast()
      end
      -- spitting_cobra
      if S.SpittingCobra:IsReady() then
        return S.SpittingCobra:Cast()
      end
    end
    -- call precombat
    
    if not Player:AffectingCombat() and RubimRH.PrecombatON() then
      local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
    end

    if RubimRH.TargetIsValid() then
	-- countershot in combat
	if S.CounterShot:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.CounterShot:Cast()
    end
	  if QueueSkill() ~= nil then
        return QueueSkill()
      end
      -- auto_shot
      -- use_items
        -- mendpet
        if S.MendPet:IsCastable() and Pet:IsActive() and Pet:HealthPercentage() > 0 and Pet:HealthPercentage() <= RubimRH.db.profile[253].sk1 and not Pet:Buff(S.MendPet) then
            return S.MendPet:Cast()
        end
	  -- summon_pet
      if Pet:IsDeadOrGhost() then
          return S.MendPet:Cast()
      elseif not Pet:IsActive() then
          return S.CallPet:Cast()
      end

      -- call_action_list,name=cds
      if (true) then
        local ShouldReturn = Cds(); if ShouldReturn then return ShouldReturn; end
      end
      -- call_action_list,name=st,if=active_enemies<2
      if (GetEnemiesCount() < 2) or not RubimRH.AoEON() then
        local ShouldReturn = St(); if ShouldReturn then return ShouldReturn; end
      end
      -- call_action_list,name=cleave,if=active_enemies>1
      if (GetEnemiesCount() > 1 and RubimRH.AoEON()) then
        local ShouldReturn = Cleave(); if ShouldReturn then return ShouldReturn; end
      end
    end
    return 0, 135328
end

RubimRH.Rotation.SetAPL(253, APL);

local function PASSIVE()
	  if S.AspectoftheTurtle:IsCastable() and Player:HealthPercentage() <= RubimRH.db.profile[253].sk2 then
        return S.AspectoftheTurtle:Cast()
      end

      if S.Exhilaration:IsCastable() and Player:HealthPercentage() <= RubimRH.db.profile[253].sk3 then
        return S.Exhilaration:Cast()
      end
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(253, PASSIVE);