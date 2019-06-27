local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item
-- Lua
local pairs = pairs;
local tableconcat = table.concat;
local tostring = tostring;



--Outlaw
RubimRH.Spell[260] = {
    -- Racials
    AncestralCall  = Spell(274738),
    ArcanePulse = Spell(260364),
    ArcaneTorrent = Spell(25046),
    Fireblood = Spell(265221),
    Berserking = Spell(26297),
    BloodFury = Spell(20572),
    LightsJudgment = Spell(255647),
    Shadowmeld = Spell(58984),
    -- Abilities
    AdrenalineRush = Spell(13750),
    Ambush = Spell(8676),
    BetweentheEyes = Spell(199804),
    BladeFlurry = Spell(13877),
    Opportunity = Spell(195627),
    PistolShot = Spell(185763),
    RolltheBones = Spell(193316),
    Dispatch = Spell(2098),
    SinisterStrike = Spell(193315),
    Stealth = Spell(1784),
    Vanish = Spell(1856),
    VanishBuff = Spell(11327),
    -- Talents
    AcrobaticStrikes = Spell(196924),
    BladeRush = Spell(271877),
    DeeperStratagem = Spell(193531),
    GhostlyStrike = Spell(196937),
    KillingSpree = Spell(51690),
    LoadedDiceBuff = Spell(256171),
    MarkedforDeath = Spell(137619),
    QuickDraw = Spell(196938),
    SliceandDice = Spell(5171),
    -- Azerite Traits
    AceUpYourSleeve                = Spell(278676),
  Deadshot                        = Spell(272935),
  DeadshotBuff                    = Spell(272940),
  SnakeEyesPower                  = Spell(275846),
  SnakeEyesBuff                   = Spell(275863),
  KeepYourWitsBuff                = Spell(288988),
    -- Defensive
    Riposte = Spell(199754),
    CloakofShadows = Spell(31224),
    CrimsonVial = Spell(185311),
    Feint = Spell(1966),
    -- Utility
    
    Gouge = Spell(1776),
    Kick = Spell(1766),
	DFA = Spell (269513),
	Shiv = Spell (248744),
	SmokeBomb = Spell (212182),
	CheapShot = Spell(1833),
    Sap = Spell (6770),
    Dismantle = Spell (207777),
    -- Roll the Bones
    Broadside = Spell(193356),
    BuriedTreasure = Spell(199600),
    GrandMelee = Spell(193358),
    RuthlessPrecision = Spell(193357),
    SkullandCrossbones = Spell(199603),
    TrueBearing = Spell(193359),
	
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
};

local S = RubimRH.Spell[260]

local BladeFlurryRange = 6;
-- Rotation Var
local ShouldReturn; -- Used to get the return string
local function num(val)
    if val then
        return 1
    else
        return 0
    end
end

-- Rotation Var
local ShouldReturn; -- Used to get the return string

local function DetermineEssenceRanks()
  S.BloodOfTheEnemy = S.BloodOfTheEnemy2:IsAvailable() and S.BloodOfTheEnemy2 or S.BloodOfTheEnemy;
  S.BloodOfTheEnemy = S.BloodOfTheEnemy3:IsAvailable() and S.BloodOfTheEnemy3 or S.BloodOfTheEnemy;
  S.MemoryOfLucidDreams = S.MemoryOfLucidDreams2:IsAvailable() and S.MemoryOfLucidDreams2 or S.MemoryOfLucidDreams;
  S.MemoryOfLucidDreams = S.MemoryOfLucidDreams3:IsAvailable() and S.MemoryOfLucidDreams3 or S.MemoryOfLucidDreams;
  S.PurifyingBlast = S.PurifyingBlast2:IsAvailable() and S.PurifyingBlast2 or S.PurifyingBlast;
  S.PurifyingBlast = S.PurifyingBlast3:IsAvailable() and S.PurifyingBlast3 or S.PurifyingBlast;
  S.RippleInSpace = S.RippleInSpace2:IsAvailable() and S.RippleInSpace2 or S.RippleInSpace;
  S.RippleInSpace = S.RippleInSpace3:IsAvailable() and S.RippleInSpace3 or S.RippleInSpace;
  S.ConcentratedFlame = S.ConcentratedFlame2:IsAvailable() and S.ConcentratedFlame2 or S.ConcentratedFlame;
  S.ConcentratedFlame = S.ConcentratedFlame3:IsAvailable() and S.ConcentratedFlame3 or S.ConcentratedFlame;
  S.TheUnboundForce = S.TheUnboundForce2:IsAvailable() and S.TheUnboundForce2 or S.TheUnboundForce;
  S.TheUnboundForce = S.TheUnboundForce3:IsAvailable() and S.TheUnboundForce3 or S.TheUnboundForce;
  S.WorldveinResonance = S.WorldveinResonance2:IsAvailable() and S.WorldveinResonance2 or S.WorldveinResonance;
  S.WorldveinResonance = S.WorldveinResonance3:IsAvailable() and S.WorldveinResonance3 or S.WorldveinResonance;
  S.FocusedAzeriteBeam = S.FocusedAzeriteBeam2:IsAvailable() and S.FocusedAzeriteBeam2 or S.FocusedAzeriteBeam;
  S.FocusedAzeriteBeam = S.FocusedAzeriteBeam3:IsAvailable() and S.FocusedAzeriteBeam3 or S.FocusedAzeriteBeam;
  S.GuardianOfAzeroth = S.GuardianOfAzeroth2:IsAvailable() and S.GuardianOfAzeroth2 or S.GuardianOfAzeroth;
  S.GuardianOfAzeroth = S.GuardianOfAzeroth3:IsAvailable() and S.GuardianOfAzeroth3 or S.GuardianOfAzeroth;
end

-- APL Action Lists (and Variables)
local RtB_BuffsList = {
    S.Broadside,
    S.BuriedTreasure,
    S.GrandMelee,
    S.RuthlessPrecision,
    S.SkullandCrossbones,
    S.TrueBearing
};
local function RtB_List (Type, List)
    if not Cache.APLVar.RtB_List then Cache.APLVar.RtB_List = {}; end
    if not Cache.APLVar.RtB_List[Type] then Cache.APLVar.RtB_List[Type] = {}; end
    local Sequence = table.concat(List);
    -- All
    if Type == "All" then
      if not Cache.APLVar.RtB_List[Type][Sequence] then
        local Count = 0;
        for i = 1, #List do
          if Player:Buff(RtB_BuffsList[List[i]]) then
            Count = Count + 1;
          end
        end
        Cache.APLVar.RtB_List[Type][Sequence] = Count == #List and true or false;
      end
    -- Any
    else
      if not Cache.APLVar.RtB_List[Type][Sequence] then
        Cache.APLVar.RtB_List[Type][Sequence] = false;
        for i = 1, #List do
          if Player:Buff(RtB_BuffsList[List[i]]) then
            Cache.APLVar.RtB_List[Type][Sequence] = true;
            break;
          end
        end
      end
    end
    return Cache.APLVar.RtB_List[Type][Sequence];
  end
  local function RtB_BuffRemains ()
    if not Cache.APLVar.RtB_BuffRemains then
      Cache.APLVar.RtB_BuffRemains = 0;
      for i = 1, #RtB_BuffsList do
        if Player:Buff(RtB_BuffsList[i]) then
          Cache.APLVar.RtB_BuffRemains = Player:BuffRemainsP(RtB_BuffsList[i]);
          break;
        end
      end
    end
    return Cache.APLVar.RtB_BuffRemains;
  end
  -- Get the number of Roll the Bones buffs currently on
  local function RtB_Buffs ()
    if not Cache.APLVar.RtB_Buffs then
      Cache.APLVar.RtB_Buffs = 0;
      for i = 1, #RtB_BuffsList do
        if Player:BuffP(RtB_BuffsList[i]) then
          Cache.APLVar.RtB_Buffs = Cache.APLVar.RtB_Buffs + 1;
        end
      end
    end
    return Cache.APLVar.RtB_Buffs;
  end
-- RtB rerolling strategy, return true if we should reroll
local function RtB_Reroll ()
    if not Cache.APLVar.RtB_Reroll then
        -- Defensive Override : Grand Melee if HP < 60
            -- 1+ Buff
        if RubimRH.db.profile[260].dice == "1+ Buff" then
            Cache.APLVar.RtB_Reroll = (not S.SliceandDice:IsAvailable() and RtB_Buffs() <= 0) and true or false;
         -- Mythic+
        elseif RubimRH.db.profile[260].dice == "Mythic +" then
            Cache.APLVar.RtB_Reroll = (not S.SliceandDice:IsAvailable() and (not Player:BuffP(S.RuthlessPrecision) and not Player:BuffP(S.GrandMelee) and not Player:BuffP(S.Broadside)) and not (RtB_Buffs () >= 2)) and true or false;
            -- Broadside
        elseif RubimRH.db.profile[260].dice == "AoE Strat" and Cache.EnemiesCount[BladeFlurryRange] >= 2 or (not Target:IsInBossList()) then
            Cache.APLVar.RtB_Reroll = (not S.SliceandDice:IsAvailable() and (not Player:BuffP(S.RuthlessPrecision) and not Player:BuffP(S.GrandMelee) and not Player:BuffP(S.Broadside)) and not (RtB_Buffs () >= 2)) and true or false;
            -- SimC Default
        else
            -- # Reroll for 2+ buffs with Loaded Dice up. Otherwise reroll for 2+ or Grand Melee or Ruthless Precision.
            -- actions=variable,name=rtb_reroll,value=rtb_buffs<2&(buff.loaded_dice.up|!buff.grand_melee.up&!buff.ruthless_precision.up)
            -- # Reroll for 2+ buffs or Ruthless Precision with Deadshot or Ace up your Sleeve.
            -- actions+=/variable,name=rtb_reroll,op=set,if=azerite.deadshot.enabled|azerite.ace_up_your_sleeve.enabled,value=rtb_buffs<2&(buff.loaded_dice.up|buff.ruthless_precision.remains<=cooldown.between_the_eyes.remains)
            -- # Always reroll for 2+ buffs with Snake Eyes.
            -- actions+=/variable,name=rtb_reroll,op=set,if=azerite.snake_eyes.rank>=2,value=rtb_buffs<2
            if S.SnakeEyesPower:AzeriteRank() >= 2 then
              Cache.APLVar.RtB_Reroll = (RtB_Buffs() < 2) and true or false; 
              -- # Do not reroll if Snake Eyes is at 2+ stacks of the buff (1+ stack with Broadside up)
              -- actions+=/variable,name=rtb_reroll,op=reset,if=azerite.snake_eyes.rank>=2&buff.snake_eyes.stack>=2-buff.broadside.up
              if Player:BuffStackP(S.SnakeEyesBuff) >= 2 - num(Player:BuffP(S.Broadside)) then
                Cache.APLVar.RtB_Reroll = false;
              end
            elseif S.Deadshot:AzeriteEnabled() or S.AceUpYourSleeve:AzeriteEnabled() then
              Cache.APLVar.RtB_Reroll = (RtB_Buffs() < 2 and (Player:BuffP(S.LoadedDiceBuff) or
                Player:BuffRemainsP(S.RuthlessPrecision) <= S.BetweentheEyes:CooldownRemainsP())) and true or false;
            else
              Cache.APLVar.RtB_Reroll = (RtB_Buffs() < 2 and (Player:BuffP(S.LoadedDiceBuff) or
                (not Player:BuffP(S.GrandMelee) and not Player:BuffP(S.RuthlessPrecision)))) and true or false;
            end
        end
    end
    return Cache.APLVar.RtB_Reroll;
end
-- # Condition to use Stealth cooldowns for Ambush
local function Ambush_Condition ()
    -- actions+=/variable,name=ambush_condition,value=combo_points.deficit>=2+2*(talent.ghostly_strike.enabled&cooldown.ghostly_strike.remains<1)+buff.broadside.up&energy>60&!buff.skull_and_crossbones.up
    return Player:ComboPointsDeficit() >= 2 + 2 * ((S.GhostlyStrike:IsAvailable() and S.GhostlyStrike:CooldownRemainsP() < 1) and 1 or 0)
            + (Player:Buff(S.Broadside) and 1 or 0) and Player:EnergyPredicted() > 60 and not Player:Buff(S.SkullandCrossbones);
end
-- # With multiple targets, this variable is checked to decide whether some CDs should be synced with Blade Flurry
-- actions+=/variable,name=blade_flurry_sync,value=spell_targets.blade_flurry<2&raid_event.adds.in>20|buff.blade_flurry.up
local function Blade_Flurry_Sync ()
    return not RubimRH.AoEON() or Cache.EnemiesCount[BladeFlurryRange] < 2 or Player:BuffP(S.BladeFlurry)
  end

local function EnergyTimeToMaxRounded ()
    -- Round to the nearesth 10th to reduce prediction instability on very high regen rates
    return math.floor(Player:EnergyTimeToMaxPredicted() * 10 + 0.5) / 10;
end

local function CPMaxSpend ()
    -- Should work for all 3 specs since they have same Deeper Stratagem Spell ID.
    return RubimRH.Spell[261].DeeperStratagem:IsAvailable() and 6 or 5;
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

local function CDs ()


-- call_action_list,name=essences
    local ShouldReturn = Essences(); if ShouldReturn then return ShouldReturn; end
    
    if S.Dismantle:IsAvailable() and S.Dismantle:CooldownUp() and not Target:IsDeadOrGhost() and Player:CanAttack(Target) and Target:Exists() and Target:IsBursting() then
        if Target:IsInRange(15) and not Player:IsStealthed() then
    if not Target:IsImmune() and S.Dismantle:IsReady()  then
    return S.Dismantle:Cast()
    end
    end
    end

    


    -- actions.cds=potion,if=buff.bloodlust.react|target.time_to_die<=60|buff.adrenaline_rush.up
    -- TODO: Add Potion
    -- actions.cds+=/use_item,if=buff.bloodlust.react|target.time_to_die<=20|combo_points.deficit<=2
    -- TODO: Add Items




                             if S.SmokeBomb:IsAvailable() and S.SmokeBomb:CooldownUp() and Target:IsAPlayer() and Target:Exists() and not Player:IsStealthed() then
                    if not Target:IsCC()  and Target:IsInRange("Melee") and Player:AffectingCombat()  then
       if not Target:IsImmune()  and S.SmokeBomb:IsReady() and (Player:HealthPercentage() <= 40 or RubimRH.CDsON() and Target:IsBursting()) then
                   return S.SmokeBomb:Cast()
end
end
   end

    if Target:IsInRange(S.SinisterStrike) then
        if RubimRH.CDsON() then
            -- actions.cds+=/blood_fury
            if S.BloodFury:IsReady() then
                return S.BloodFury:Cast()
            end
            -- actions.cds+=/berserking
            if S.Berserking:IsReady() then
                return S.Berserking:Cast()
            end
            -- actions.cds+=/fireblood
            if S.Fireblood:IsReady() then
                return S.Fireblood:Cast()
            end
            -- actions.cds+=/ancestral_call
            if S.AncestralCall:IsCastable() then
                return S.AncestralCall:Cast()
            end
            -- actions.cds+=/adrenaline_rush,if=!buff.adrenaline_rush.up&energy.time_to_max>1
            if S.AdrenalineRush:IsReady() and not Player:BuffP(S.AdrenalineRush) and EnergyTimeToMaxRounded() > 1 then
                return S.AdrenalineRush:Cast()
            end
        end
        -- actions.cds+=/marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit|((raid_event.adds.in>40|buff.true_bearing.remains>15-buff.adrenaline_rush.up*5)&!stealthed.rogue&combo_points.deficit>=cp_max_spend-1)
        if S.MarkedforDeath:IsReady() then
            -- Note: Increased the SimC condition by 50% since we are slower.
            if Target:FilteredTimeToDie("<", Player:ComboPointsDeficit()*1) or (Target:FilteredTimeToDie("<", 2) and Player:ComboPointsDeficit() > 0)
            or (((Player:BuffRemainsP(S.TrueBearing) > 15 - (Player:BuffP(S.AdrenalineRush) and 5 or 0)) or Target:IsDummy())
              and not Player:IsStealthedP(true, true) and Player:ComboPointsDeficit() >= CPMaxSpend() - 1) then
            return S.MarkedforDeath:Cast()
          elseif not Player:IsStealthedP(true, true) and Player:ComboPointsDeficit() >= CPMaxSpend() - 1 then
            S.MarkedforDeath:Cast()
          end
        end
        -- actions.cds+=/blade_flurry,if=spell_targets.blade_flurry>=2&!buff.blade_flurry.up
        if RubimRH.AoEON() and RubimRH.CDsON() and S.BladeFlurry:IsReady() and Cache.EnemiesCount[BladeFlurryRange] >= 2 and not Player:BuffP(S.BladeFlurry) then
            return S.BladeFlurry:Cast()
        end

        if RubimRH.AoEON() and S.BladeFlurry:IsReady() and S.BladeFlurry:ChargesFractional() >= 1.5 and Cache.EnemiesCount[BladeFlurryRange] >= 2 and not Player:BuffP(S.BladeFlurry) then
            return S.BladeFlurry:Cast()
        end
       
        -- actions.cds+=/ghostly_strike,if=variable.blade_flurry_sync&combo_points.deficit>=1+buff.broadside.up
        if S.GhostlyStrike:IsReady(S.SinisterStrike) and Blade_Flurry_Sync() and Player:ComboPointsDeficit() >= (1 + (Player:BuffP(S.Broadside) and 1 or 0)) then
            return S.GhostlyStrike:Cast()
        end
        -- actions.cds+=/killing_spree,if=variable.blade_flurry_sync&(energy.time_to_max>5|energy<15)
        if S.KillingSpree:IsReady(10) and Blade_Flurry_Sync() and (EnergyTimeToMaxRounded() > 5 or Player:EnergyPredicted() < 15) then
            return S.KillingSpree:Cast()
        end
        -- actions.cds+=/blade_rush,if=variable.blade_flurry_sync&energy.time_to_max>1
        if S.BladeRush:IsReady(S.SinisterStrike) and Blade_Flurry_Sync() and EnergyTimeToMaxRounded() > 1 then
            return S.BladeRush:Cast()
        end
        if not Player:IsStealthed(true, true) then
            -- # Using Vanish/Ambush is only a very tiny increase, so in reality, you're absolutely fine to use it as a utility spell.
            -- actions.cds+=/vanish,if=!stealthed.all&variable.ambush_condition
            --if S.Vanish:IsReady() and Ambush_Condition() then
                --return S.Vanish:Cast()
            --end
            -- actions.cds+=/shadowmeld,if=!stealthed.all&variable.ambush_condition
            --if S.Shadowmeld:IsReady() and Ambush_Condition() then
                --return S.Shadowmeld:Cast()
            --end
        end
		-- actions.cds+=/call_action_list,name=essences
        ShouldReturn = Essences();
        if ShouldReturn then return ShouldReturn; end
    end
end

local function Stealth ()

    if RubimRH.AoEON() and RubimRH.CDsON() and S.BladeFlurry:IsReady() and Cache.EnemiesCount[BladeFlurryRange] >= 2 and not Player:BuffP(S.BladeFlurry) then
        return S.BladeFlurry:Cast()
    end

    if RubimRH.AoEON() and S.BladeFlurry:IsReady() and S.BladeFlurry:ChargesFractional() >= 1.5 and Cache.EnemiesCount[BladeFlurryRange] >= 2 and not Player:BuffP(S.BladeFlurry) then
        return S.BladeFlurry:Cast()
    end


    if Target:IsInRange(BladeFlurryRange) then
        -- actions.stealth=ambush
        if S.Ambush:IsReady(BladeFlurryRange) then
            return S.Ambush:Cast()
        end
    end
end


local function Finish ()
    
    
    if S.DFA:IsAvailable() and S.DFA:CooldownUp() and not Target:IsDeadOrGhost() and Player:CanAttack(Target) and Target:Exists() and RtB_Buffs() >= 1 then
        if Target:IsInRange(15) and not Player:IsStealthed() then
            if not Target:IsImmune() and S.DFA:IsReady()  then
                return S.DFA:Cast()
            end
	    end
    end    
    
    -- # BtE over RtB rerolls with Deadshot/Ace traits or Ruthless Precision.
    -- actions.finish=between_the_eyes,if=buff.ruthless_precision.up|(azerite.deadshot.enabled|azerite.ace_up_your_sleeve.enabled)&buff.roll_the_bones.up
    if S.BetweentheEyes:IsReady(20) and (Player:BuffP(S.RuthlessPrecision) or (S.Deadshot:AzeriteEnabled() or S.AceUpYourSleeve:AzeriteEnabled()) and RtB_Buffs() >= 1) then
      return S.BetweentheEyes:Cast()
    end
    -- actions.finish=slice_and_dice,if=buff.slice_and_dice.remains<target.time_to_die&buff.slice_and_dice.remains<(1+combo_points)*1.8
    -- Note: Added Player:BuffRemainsP(S.SliceandDice) == 0 to maintain the buff while TTD is invalid (it's mainly for Solo, not an issue in raids)
    if S.SliceandDice:IsAvailable() and S.SliceandDice:IsReady()
      and (Target:FilteredTimeToDie(">", Player:BuffRemainsP(S.SliceandDice)) or Target:TimeToDieIsNotValid() or Player:BuffRemainsP(S.SliceandDice) == 0)
      and Player:BuffRemainsP(S.SliceandDice) < (1 + Player:ComboPoints()) * 1.8 then
      return S.SliceandDice:Cast()
    end
    -- actions.finish+=/roll_the_bones,if=buff.roll_the_bones.remains<=3|variable.rtb_reroll
    if S.RolltheBones:IsCastable() and (RtB_BuffRemains() <= 3 or RtB_Reroll()) then
      return S.RolltheBones:Cast()
    end
    -- # BtE with the Ace Up Your Sleeve or Deadshot traits.
    -- actions.finish+=/between_the_eyes,if=azerite.ace_up_your_sleeve.enabled|azerite.deadshot.enabled
    if S.BetweentheEyes:IsCastableP(20) and (S.AceUpYourSleeve:AzeriteEnabled() or S.Deadshot:AzeriteEnabled()) then
      return S.BetweentheEyes:Cast()
    end
    -- actions.finish+=/dispatch
    if S.Dispatch:IsCastable(BladeFlurryRange) then
      return S.Dispatch:Cast()
    end
    -- OutofRange BtE
    if S.BetweentheEyes:IsReady(20) and not Target:IsInRange(10) then
      return S.BetweentheEyes:Cast()
    end
  end

local function Build ()
    -- actions.build=pistol_shot,if=buff.opportunity.up&(buff.keep_your_wits_about_you.stack<25|buff.deadshot.up|energy<45)
    if S.PistolShot:IsCastable(20) and Player:BuffP(S.Opportunity) and (Player:BuffStackP(S.KeepYourWitsBuff) < 10 or Player:BuffP(S.DeadshotBuff) or Player:EnergyPredicted() < 45) then
        return S.PistolShot:Cast()
    end
    -- actions.build+=/sinister_strike
    if S.SinisterStrike:IsReady(BladeFlurryRange) then
        return S.SinisterStrike:Cast()
    end
end

local OffensiveCDs = {
    S.AdrenalineRush,
    S.Vanish,
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



-- APL Main
local function APL ()
    UpdateCDs()
	DetermineEssenceRanks()
    -- Unit Update
    BladeFlurryRange = S.AcrobaticStrikes:IsAvailable() and 9 or 6;
    HL.GetEnemies(8); -- Cannonball Barrage
    HL.GetEnemies(BladeFlurryRange); -- Blade Flurry
    HL.GetEnemies(S.SinisterStrike); -- Melee
    if S.Kick:IsReady(BladeFlurryRange) and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.Kick:Cast()
    end
    if S.CrimsonVial:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[260].sk1 then
        return S.CrimsonVial:Cast()
    end
    if QueueSkill() ~= nil then
        return QueueSkill()
    end
    -- Out of Combat
    if not Player:AffectingCombat() then
       
        -- Stealth
        if IsStealthed() == false and S.Stealth:TimeSinceLastCast() >= 2 and Player:IsMoving() then
            return S.Stealth:Cast()
        end
        -- Flask
        -- Food
        -- Rune
        -- PrePot w/ Bossmod Countdown
        if Target:Exists() and Target:IsAPlayer() and not Target:IsDeadOrGhost() and Player:CanAttack(Target) then
            if Player:IsStealthed()  and  Target:IsInRange(10) and not Target:AffectingCombat() and (Target:IsTargeting(Player) or Target:CastingCC() or Target:IsBursting()) then
                if not Target:IsImmune()  and S.Sap:IsReady() then
                    return S.Sap:Cast()								  
                end
            end
        end
       
        if RubimRH.AoEON() and RubimRH.CDsON() and S.BladeFlurry:IsReady() and Cache.EnemiesCount[BladeFlurryRange] >= 2 and not Player:BuffP(S.BladeFlurry) then
            return S.BladeFlurry:Cast()
        end

        if RubimRH.AoEON() and S.BladeFlurry:IsReady() and S.BladeFlurry:ChargesFractional() >= 1.5 and Cache.EnemiesCount[BladeFlurryRange] >= 2 and not Player:BuffP(S.BladeFlurry) then
            return S.BladeFlurry:Cast()
        end
       
        if  Target:Exists() and Target:IsAPlayer() and not Target:IsCC() and Player:IsStealthed() and not Target:IsDeadOrGhost() and Player:CanAttack(Target)  then
            if not Target:IsImmune() and Target:IsInRange(BladeFlurryRange) then
                return S.CheapShot:Cast() 
            end
        end
        
        
        
        -- Opener
        if RubimRH.TargetIsValid(true) and Target:IsInRange(BladeFlurryRange) and (S.Vanish:TimeSinceLastCast() <= 10 or RubimRH.db.profile.mainOption.startattack) then
            if Player:ComboPoints() >= 5 then
                if S.Dispatch:IsReady() then
                    return S.Dispatch:Cast()
                end
            else
                if Player:IsStealthed(true, true) and S.Ambush:IsReady(BladeFlurryRange) then
                    return S.Ambush:Cast()
                elseif S.SinisterStrike:IsReady() then
                    return S.SinisterStrike:Cast()
                end
            end
        end
        return 0, 462338
    end
    
    --Custom

    if S.CloakofShadows:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[260].sk2 then
        return S.CloakofShadows:Cast()
    end

    if S.Riposte:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[260].sk3 and Player:LastSwinged() <= 3 then
        return S.Riposte:Cast()
    end


    -- In Combat
    -- actions+=/call_action_list,name=stealth,if=stealthed.all
    if IsStealthed() == true then
        if Stealth() ~= nil  then
            return Stealth()
        end
    end

    -- actions+=/call_action_list,name=cds
    if CDs() ~= nil then
        return CDs()
    end
    -- actions+=/run_action_list,name=finish,if=combo_points>=cp_max_spend-(buff.broadside.up+buff.opportunity.up)*(talent.quick_draw.enabled&(!talent.marked_for_death.enabled|cooldown.marked_for_death.remains>1))
    if Player:ComboPoints() >= CPMaxSpend() - (num(Player:BuffP(S.Broadside)) + num(Player:BuffP(S.Opportunity))) * num(S.QuickDraw:IsAvailable() and (not S.MarkedforDeath:IsAvailable() or S.MarkedforDeath:CooldownRemainsP() > 1)) then
        if Finish() ~= nil  then
            return Finish()
        end
    end
    -- actions+=/call_action_list,name=build
    if Build() ~= nil  then
        return Build()
    end
    -- actions+=/arcane_torrent,if=energy.deficit>=15+energy.regen
    if S.ArcaneTorrent:IsReady(S.SinisterStrike) and Player:EnergyDeficitPredicted() > 15 + Player:EnergyRegen() then
        return S.ArcaneTorrent:Cast()
    end
    -- actions+=/arcane_pulse
    if S.ArcanePulse:IsReady(BladeFlurryRange) then
        return S.ArcanePulse:Cast()
    end
    -- actions+=/lights_judgment
    if S.LightsJudgment:IsReady(BladeFlurryRange) then
        return S.LightsJudgment:Cast()
    end
    
    
    
    
    if Target:IsAPlayer() and S.Shiv:IsAvailable() and S.Shiv:CooldownUp() and not Target:IsDeadOrGhost() and Target:Exists() and Target:IsInRange(10) and Target:AffectingCombat() then
        if not Target:IsImmuneMagic() then
        if not Target:IsImmune() and S.Shiv:IsReady() and not Target:IsSnared() and not Target:IsCC() then
            return S.Shiv:Cast()
        end
        end
        end
    
    
    
    
    -- OutofRange Pistol Shot
    if not Target:IsInRange(10) and S.PistolShot:IsReady(20) and not Player:IsStealthed(true, true)
            and Player:EnergyDeficitPredicted() < 25 and (Player:ComboPointsDeficit() >= 1 or EnergyTimeToMaxRounded() <= 1.2) and Target:AffectingCombat() then
        return S.PistolShot:Cast()
    end
    return 0, 135328
end

RubimRH.Rotation.SetAPL(260, APL)

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(260, PASSIVE)
