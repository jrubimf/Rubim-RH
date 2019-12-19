--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
-- HeroLib
local HL = HeroLib
local Cache = HeroCache
local Unit = HL.Unit
local Player = Unit.Player
local Target = Unit.Target
local Pet = Unit.Pet
local Spell = HL.Spell
local Item = HL.Item

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
RubimRH.Spell[259] = {
    -- Racials
    ArcanePulse = Spell(260364),
    ArcaneTorrent = Spell(25046),
    Berserking = Spell(26297),
    BloodFury = Spell(20572),
    LightsJudgment = Spell(255647),
	-- Racials
    AncestralCall  = Spell(274738),   
    Fireblood = Spell(265221),
    Shadowmeld = Spell(58984),
    -- Abilities
    Envenom = Spell(32645),
    FanofKnives = Spell(51723),
    Garrote = Spell(703),
    KidneyShot = Spell(408),
    Mutilate = Spell(1329),
    PoisonedKnife = Spell(185565),
    Rupture = Spell(1943),
    Stealth = Spell(1784),
    Stealth2 = Spell(115191), -- w/ Subterfuge Talent
    Vanish = Spell(1856),
    VanishBuff = Spell(11327),
    Vendetta = Spell(79140),
    -- Talents
    Blindside = Spell(111240),
    BlindsideBuff = Spell(121153),
    CrimsonTempest = Spell(121411),
    DeeperStratagem = Spell(193531),
    Exsanguinate = Spell(200806),
    HiddenBladesBuff = Spell(270070),
    InternalBleeding = Spell(154953),
    MarkedforDeath = Spell(137619),
    MasterAssassin = Spell(255989),
    Nightstalker = Spell(14062),
    Subterfuge = Spell(108208),
    ToxicBlade = Spell(245388),
    ToxicBladeDebuff = Spell(245389),
    VenomRush = Spell(152152),
    -- Azerite Traits
    SharpenedBladesPower = Spell(272911),
    SharpenedBladesBuff = Spell(272916),
    ShroudedSuffocation = Spell(278666),
    -- Poisons
    CripplingPoison = Spell(3408),
    DeadlyPoison = Spell(2823),
    DeadlyPoisonDebuff = Spell(2818),
    LeechingPoison = Spell(108211),
    WoundPoison = Spell(8679),
    WoundPoisonDebuff = Spell(8680),
    -- DEefnsives
    CrimsonVial = Spell(185311),
    Evasion = Spell(5277),
    CloakofShadows = Spell(31224),
    TheDreadlordsDeceit = Spell(208693),
    Kick = Spell(1766),
	ShadowStep = Spell (36554),
	-- PvP
	Sap = Spell(6770),
	Shiv = Spell(248744),
	SmokeBomb = Spell (212182),
	DFA = Spell (269513),
	Neuro = Spell (206328),
    CheapShot = Spell(1833),	
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
local S = RubimRH.Spell[259];
-- Rotation Var
local ShouldReturn; -- Used to get the return string
-- Items
if not Item.Rogue then
    Item.Rogue = {}
end
Item.Rogue.Assassination = {
    ProlongedPower = Item(142117),
    GalecallersBoon = Item(159614)
};
local I = Item.Rogue.Assassination;

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

-- Variables
local VarEnergyRegenCombined = 0;
local VarUseFiller = 0;

local EnemyRanges = { 10, 15, 50 }
local function UpdateRanges()
    for _, i in ipairs(EnemyRanges) do
        HL.GetEnemies(i);
    end
end

local function num(val)
    if val then
        return 1
    else
        return 0
    end
end

-- Rotation Var
local ShouldReturn; -- Used to get the return string

local function bool(val)
    return val ~= 0
end

local function CanDoTUnit(Unit, HealthThreshold)
    return Unit:Health() >= HealthThreshold or Unit:IsDummy();
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

-- Master Assassin Remains Check
local MasterAssassinBuff, NominalDuration = Spell(256735), 3;
local function MasterAssassinRemains()
    if Player:BuffRemains(MasterAssassinBuff) < 0 then
        return Player:GCDRemains() + NominalDuration;
    else
        return Player:BuffRemainsP(MasterAssassinBuff);
    end
end

local function CPMaxSpend()
    -- Should work for all 3 specs since they have same Deeper Stratagem Spell ID.
    return RubimRH.Spell[261].DeeperStratagem:IsAvailable() and 6 or 5;
end

local function Poisoned (Unit)
    return (Unit:Debuff(RubimRH.Spell[259].DeadlyPoisonDebuff) or Unit:Debuff(RubimRH.Spell[259].WoundPoisonDebuff)) and true or false;
end

local function CPSpend ()
    return math.min(Player:ComboPoints(), CPMaxSpend());
end

-- Spells Damage
S.Envenom:RegisterDamage(
-- Envenom DMG Formula:
--  AP * CP * Env_APCoef * Aura_M * ToxicB_M * DS_M * Mastery_M * Versa_M
        function()
            return
            -- Attack Power
            Player:AttackPowerDamageMod() *
                    -- Combo Points
                    CPSpend() *
                    -- Envenom AP Coef
                    0.16 *
                    -- Aura Multiplier (SpellID: 137037)
                    1.32 *
                    -- Toxic Blade Multiplier
                    (Target:DebuffP(S.ToxicBladeDebuff) and 1.3 or 1) *
                    -- Deeper Stratagem Multiplier
                    (S.DeeperStratagem:IsAvailable() and 1.05 or 1) *
                    -- Mastery Finisher Multiplier
                    (1 + Player:MasteryPct() / 100) *
                    -- Versatility Damage Multiplier
                    (1 + Player:VersatilityDmgPct() / 100);
        end
);
S.Mutilate:RegisterDamage(
        function()
            return
            -- Attack Power (MH Factor + OH Factor)
            (Player:AttackPowerDamageMod() + Player:AttackPowerDamageMod(true)) *
                    -- Mutilate Coefficient
                    0.35 *
                    -- Aura Multiplier (SpellID: 137037)
                    1.32 *
                    -- Versatility Damage Multiplier
                    (1 + Player:VersatilityDmgPct() / 100);
        end
);
local function NighstalkerMultiplier ()
    return S.Nightstalker:IsAvailable() and Player:IsStealthed(true, false) and 1.5 or 1;
end
local function SubterfugeGarroteMultiplier ()
    return S.Subterfuge:IsAvailable() and Player:IsStealthed(true, false) and 2 or 1;
end
S.Garrote:RegisterPMultiplier(
        { NighstalkerMultiplier },
        { SubterfugeGarroteMultiplier }
);
S.Rupture:RegisterPMultiplier(
        { NighstalkerMultiplier }
);

local PoisonedBleedsCount = 0;
local function PoisonedBleeds()
    PoisonedBleedsCount = 0;
    for _, Unit in pairs(Cache.Enemies[50]) do
        if Poisoned(Unit) then
            -- TODO: For loop for this ? Not sure it's worth considering we would have to make 2 times spell object (Assa is init after Commons)
            if Unit:Debuff(S.Garrote) then
                PoisonedBleedsCount = PoisonedBleedsCount + 1;
            end
            if Unit:Debuff(S.InternalBleeding) then
                PoisonedBleedsCount = PoisonedBleedsCount + 1;
            end
            if Unit:Debuff(S.Rupture) then
                PoisonedBleedsCount = PoisonedBleedsCount + 1;
            end
        end
    end
    return PoisonedBleedsCount;
end

-- Arguments Variables
local DestGUID, SpellID;

-- TODO: Register/Unregister Events on SpecChange
HL.BleedTable = {
    Assassination = {
        Garrote = {},
        Rupture = {}
    },
    Subtlety = {
        Nightblade = {},
    }
};
local BleedGUID;
--- Exsanguinated Handler
-- Exsanguinate Expression
local BleedDuration, BleedExpires;
function HL.Exsanguinated (Unit, SpellName)
    BleedGUID = Unit:GUID();
    if BleedGUID then
        if SpellName == "Garrote" then
            if HL.BleedTable.Assassination.Garrote[BleedGUID] then
                return HL.BleedTable.Assassination.Garrote[BleedGUID][3];
            end
        elseif SpellName == "Rupture" then
            if HL.BleedTable.Assassination.Rupture[BleedGUID] then
                return HL.BleedTable.Assassination.Rupture[BleedGUID][3];
            end
        end
    end
    return false;
end
-- Exsanguinate OnCast Listener
HL:RegisterForSelfCombatEvent(
        function(...)
            DestGUID, _, _, _, SpellID = select(8, ...);

            -- Exsanguinate
            if SpellID == 200806 then
                for Key, _ in pairs(HL.BleedTable.Assassination) do
                    for Key2, _ in pairs(HL.BleedTable.Assassination[Key]) do
                        if Key2 == DestGUID then
                            -- Change the Exsanguinate info to true
                            HL.BleedTable.Assassination[Key][Key2][3] = true;
                        end
                    end
                end
            end
        end
, "SPELL_CAST_SUCCESS"
);
-- Bleed infos
local function GetBleedInfos (GUID, SpellID)
    -- Core API is not used since we don't want cached informations
    for i = 1, HL.MAXIMUM do
        local auraInfo = { UnitAura(GUID, i, "HARMFUL|PLAYER") };
        if auraInfo[10] == SpellID then
            return auraInfo[5];
        end
    end
    return nil
end
-- Bleed OnApply/OnRefresh Listener
HL:RegisterForSelfCombatEvent(
        function(...)
            DestGUID, _, _, _, SpellID = select(8, ...);

            --- Record the Bleed Target and its Infos
            -- Garrote
            if SpellID == 703 then
                BleedDuration, BleedExpires = GetBleedInfos(DestGUID, SpellID);
                HL.BleedTable.Assassination.Garrote[DestGUID] = { BleedDuration, BleedExpires, false };
                -- Rupture
            elseif SpellID == 1943 then
                BleedDuration, BleedExpires = GetBleedInfos(DestGUID, SpellID);
                HL.BleedTable.Assassination.Rupture[DestGUID] = { BleedDuration, BleedExpires, false };
            end
        end
, "SPELL_AURA_APPLIED"
, "SPELL_AURA_REFRESH"
);
-- Bleed OnRemove Listener
HL:RegisterForSelfCombatEvent(
        function(...)
            DestGUID, _, _, _, SpellID = select(8, ...);

            -- Removes the Unit from Garrote Table
            if SpellID == 703 then
                if HL.BleedTable.Assassination.Garrote[DestGUID] then
                    HL.BleedTable.Assassination.Garrote[DestGUID] = nil;
                end
                -- Removes the Unit from Rupture Table
            elseif SpellID == 1943 then
                if HL.BleedTable.Assassination.Rupture[DestGUID] then
                    HL.BleedTable.Assassination.Rupture[DestGUID] = nil;
                end
            end
        end
, "SPELL_AURA_REMOVED"
);
-- Bleed OnUnitDeath Listener
HL:RegisterForCombatEvent(
        function(...)
            DestGUID = select(8, ...);

            -- Removes the Unit from Garrote Table
            if HL.BleedTable.Assassination.Garrote[DestGUID] then
                HL.BleedTable.Assassination.Garrote[DestGUID] = nil;
            end
            -- Removes the Unit from Rupture Table
            if HL.BleedTable.Assassination.Rupture[DestGUID] then
                HL.BleedTable.Assassination.Rupture[DestGUID] = nil;
            end
        end
, "UNIT_DIED"
, "UNIT_DESTROYED"
);

local BleedTickTime, ExsanguinatedBleedTickTime = 2 / Player:SpellHaste(), 1 / Player:SpellHaste();
local Stealth;
local RuptureThreshold, CrimsonTempestThreshold, RuptureDMGThreshold, GarroteDMGThreshold;
local ComboPoints, ComboPointsDeficit, Energy_Regen_Combined;

local OffensiveCDs = {
    S.Exsanguinate,
    S.Vanish,
    S.MarkedforDeath,
    S.Vendetta,

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

-- # Essences
local function Essences()
  -- concentrated_flame
  if S.ConcentratedFlame:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- guardian_of_azeroth
  if S.GuardianOfAzeroth:IsCastableP() and RubimRH.CDsON() and Target:IsInRange("Melee") then
  if RubimRH.AoEON() and active_enemies() >= 4 or UnitExists("boss1") and RubimRH.TargetIsValid(true) then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  end

  -- focused_azerite_beam
  if S.FocusedAzeriteBeam:IsCastableP() and RubimRH.CDsON() and Target:IsInRange("Melee") and not Player:IsMoving() then
  if RubimRH.AoEON() and active_enemies() >= 4 or UnitExists("boss1") and RubimRH.TargetIsValid(true) and Player:EnergyPredicted() < 50 then
    return S.UnleashHeartOfAzeroth:Cast()
  end
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
  -- memory_of_lucid_dreams
  if S.MemoryOfLucidDreams:IsCastableP() and RubimRH.CDsON() and Target:IsInRange("Melee") and Player:EnergyPredicted() < 40 then
  if RubimRH.AoEON() and active_enemies() >= 4 or UnitExists("boss1") and RubimRH.TargetIsValid(true) then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  end
  -- Blood of the enemy
  if S.BloodOfTheEnemy:IsCastableP() and RubimRH.CDsON() then
  if RubimRH.AoEON() and active_enemies() >= 4 or UnitExists("boss1") and RubimRH.TargetIsValid(true) and Target:Debuff(S.Vendetta) and Target:IsInRange("Melee") then
    return S.UnleashHeartOfAzeroth:Cast()
	end
	end
  return false
end

local function CDs ()
    if Target:IsInRange("Melee") then
        -- actions.cds=potion,if=buff.bloodlust.react|target.time_to_die<=60|debuff.vendetta.up&cooldown.vanish.remains<5
        
		--actions.cds+=/call_action_list,name=essences,if=!stealthed.all&dot.rupture.ticking&master_assassin_remains=0
        local ShouldReturn = Essences();
		if ShouldReturn and (true) and not Player:IsStealthedP() and Target:DebuffP(S.Rupture) and Player:BuffRemainsP(MasterAssassinBuff) == 0 then
		    return ShouldReturn; 
		end
        
		-- Racials
        if Target:Debuff(S.Vendetta) then
            -- actions.cds+=/blood_fury,if=debuff.vendetta.up
            if S.BloodFury:IsReady() then
                return S.BloodFury:Cast()
            end
            -- actions.cds+=/berserking,if=debuff.vendetta.up
            if S.Berserking:IsReady() then
                return S.Berserking:Cast()
            end

            --actions.cds+=/fireblood,if=debuff.vendetta.up
            if S.Fireblood:IsReady() then
              return S.Fireblood:Cast()
            end
            --actions.cds+=/ancestral_call,if=debuff.vendetta.up
            if S.AncestralCall:IsReady() then
              return S.AncestralCall:Cast()
            end
        end
		
						 	        if Target:IsAPlayer() and not Target:IsDeadOrGhost() and Player:CanAttack(Target) and Target:Exists() then 
					if not Player:IsStealthed() and not Target:IsCC()  and Target:IsInRange("Melee") and Player:ComboPoints() >= 4 then
			       if not Target:IsImmune() and S.KidneyShot:IsReady() and (Target:HealthPercentage() <= 35 or Target:CastingCC()  or Target:IsBursting() or Target:IsTargeting(Player)) then
                               return S.KidneyShot:Cast()
         end
			end
			   end

        -- actions.cds+=/marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit*1.5|(raid_event.adds.in>40&combo_points.deficit>=cp_max_spend)
        if S.MarkedforDeath:IsReady() and ComboPointsDeficit >= CPMaxSpend() then
            return S.MarkedforDeath:Cast()
        end
      -- actions.cds+=/vendetta,if=!stealthed.rogue&dot.rupture.ticking&!debuff.vendetta.up&(!talent.subterfuge.enabled|!azerite.shrouded_suffocation.enabled|dot.garrote.pmultiplier>1&(spell_targets.fan_of_knives<6|!cooldown.vanish.up))&(!talent.nightstalker.enabled|!talent.exsanguinate.enabled|cooldown.exsanguinate.remains<5-2*talent.deeper_stratagem.enabled)
        if S.Vendetta:IsCastable() and not Player:IsStealthedP(true, false) and Target:DebuffP(S.Rupture) and not Target:DebuffP(S.Vendetta)
          and (not S.Subterfuge:IsAvailable() or not S.ShroudedSuffocation:AzeriteEnabled() or Target:PMultiplier(S.Garrote) > 1 and (Cache.EnemiesCount[10] < 6 or not S.Vanish:CooldownUp()))
          and (not S.Nightstalker:IsAvailable() or not S.Exsanguinate:IsAvailable() or S.Exsanguinate:CooldownRemainsP() < 5 - 2 * num(S.DeeperStratagem:IsAvailable())) then
         return S.Vendetta:Cast()
	    end
       
	   if S.Vanish:IsReady() and not Player:IsTanking(Target) and not Target:IsAPlayer() then
            -- actions.cds+=/vanish,if=talent.subterfuge.enabled&!dot.garrote.ticking&variable.single_target
            if S.Subterfuge:IsAvailable() and not Target:IsAPlayer() and not Target:DebuffP(S.Garrote) and Cache.EnemiesCount[10] < 2 then
                return S.Vanish:Cast()
            end
            -- actions.cds+=/vanish,if=talent.exsanguinate.enabled&(talent.nightstalker.enabled|talent.subterfuge.enabled&spell_targets.fan_of_knives<2)&combo_points>=cp_max_spend&cooldown.exsanguinate.remains<1&(!talent.subterfuge.enabled|!azerite.shrouded_suffocation.enabled|dot.garrote.pmultiplier<=1)
            if not Target:IsAPlayer() and S.Exsanguinate:IsAvailable() and (S.Nightstalker:IsAvailable() or S.Subterfuge:IsAvailable() and Cache.EnemiesCount[10] < 2)
                    and ComboPoints >= CPMaxSpend() and S.Exsanguinate:CooldownRemainsP() < 1
                    and (not S.Subterfuge:IsAvailable() or not S.ShroudedSuffocation:AzeriteEnabled() or Target:PMultiplier(S.Garrote) <= 1) then
                return S.Vanish:Cast()
            end
            -- actions.cds+=/vanish,if=talent.nightstalker.enabled&!talent.exsanguinate.enabled&combo_points>=cp_max_spend&debuff.vendetta.up
            if not Target:IsAPlayer() and S.Nightstalker:IsAvailable() and not S.Exsanguinate:IsAvailable() and ComboPoints >= CPMaxSpend() and Target:Debuff(S.Vendetta) then
                return S.Vanish:Cast()
            end
            -- actions.cds+=/vanish,if=talent.subterfuge.enabled&(!talent.exsanguinate.enabled|spell_targets.fan_of_knives>=2)&!stealthed.rogue&cooldown.garrote.up&dot.garrote.refreshable&(spell_targets.fan_of_knives<=3&combo_points.deficit>=1+spell_targets.fan_of_knives|spell_targets.fan_of_knives>=4&combo_points.deficit>=4)
            if not Target:IsAPlayer() and S.Subterfuge:IsAvailable() and (not S.Exsanguinate:IsAvailable() or Cache.EnemiesCount[10] >= 2) and not Player:IsStealthedP(true, false)
                    and S.Garrote:CooldownUp() and Target:DebuffRefreshableP(S.Garrote, 5.4)
                    and ((Cache.EnemiesCount[10] <= 3 and ComboPointsDeficit >= 1 + Cache.EnemiesCount[10]) or (Cache.EnemiesCount[10] >= 4 and ComboPointsDeficit >= 4)) then
                return S.Vanish:Cast()
            end
            -- actions.cds+=/vanish,if=talent.master_assassin.enabled&!stealthed.all&master_assassin_remains<=0&!dot.rupture.refreshable
            if not Target:IsAPlayer() and S.MasterAssassin:IsAvailable() and not Player:IsStealthedP(true, false) and MasterAssassinRemains() <= 0 and not Target:DebuffRefreshableP(S.Rupture, RuptureThreshold) then
                return S.Vanish:Cast()
            end
        end
        if S.Exsanguinate:IsReady() then
            -- actions.cds+=/exsanguinate,if=dot.rupture.remains>4+4*cp_max_spend&!dot.garrote.refreshable
            if Target:DebuffRemainsP(S.Rupture) > 4 + 4 * CPMaxSpend() and not Target:DebuffRefreshableP(S.Garrote, 5.4) then
                return S.Exsanguinate:Cast()
            end
        end
        -- actions.cds+=/toxic_blade,if=dot.rupture.ticking
        if S.ToxicBlade:IsReady("Melee") and Target:DebuffP(S.Rupture) then
            return S.ToxicBlade:Cast()
        end
		-- actions.cds+=/call_action_list,name=essences
        ShouldReturn = Essences();
        if ShouldReturn then return ShouldReturn; end
    end
end

-- # Stealthed
local function Stealthed ()	
	if IsStealthed() then 
		-- actions.stealthed=rupture,if=combo_points>=4&(talent.nightstalker.enabled|talent.subterfuge.enabled&talent.exsanguinate.enabled&cooldown.exsanguinate.remains<=2&spell_targets.fan_of_knives<2|!ticking)&target.time_to_die-remains>6
		if S.Rupture:IsReady("Melee") and ComboPoints >= 4
				and (S.Nightstalker:IsAvailable() or (S.Subterfuge:IsAvailable() and S.Exsanguinate:IsAvailable() and S.Exsanguinate:CooldownRemainsP() <= 2 and Cache.EnemiesCount[10] < 2) or not Target:DebuffP(S.Rupture))
				and (Target:FilteredTimeToDie(">", 6, -Target:DebuffRemainsP(S.Rupture)) or Target:TimeToDieIsNotValid()) then
			return S.Rupture:Cast()
		end
		-- actions.stealthed+=/envenom,if=combo_points>=cp_max_spend
		if S.Envenom:IsReady("Melee") and ComboPoints >= CPMaxSpend() then
			return S.Envenom:Cast()
		end
		if S.Garrote:IsReady("Melee") and S.Subterfuge:IsAvailable() then
			-- actions.stealthed+=/garrote,cycle_targets=1,if=talent.subterfuge.enabled&refreshable&target.time_to_die-remains>2
			local function Evaluate_Garrote_Target_A(TargetUnit)
				return TargetUnit:DebuffRefreshableP(S.Garrote, 5.4)
						and CanDoTUnit(TargetUnit, GarroteDMGThreshold);
			end
			if Target:IsInRange("Melee") and Evaluate_Garrote_Target_A(Target)
					and (Target:FilteredTimeToDie(">", 2, -Target:DebuffRemainsP(S.Garrote)) or Target:TimeToDieIsNotValid()) then
				return S.Garrote:Cast()
			end
			-- actions.stealthed+=/garrote,cycle_targets=1,if=talent.subterfuge.enabled&pmultiplier<=1&target.time_to_die-remains>2
			local function Evaluate_Garrote_Target_B(TargetUnit)
				return TargetUnit:PMultiplier(S.Garrote) <= 1 and CanDoTUnit(TargetUnit, GarroteDMGThreshold);
			end
			if Target:IsInRange("Melee") and Evaluate_Garrote_Target_B(Target)
					and (Target:FilteredTimeToDie(">", 2, -Target:DebuffRemainsP(S.Garrote)) or Target:TimeToDieIsNotValid()) then
				return S.Garrote:Cast()
			end
		end
		-- actions.stealthed+=/rupture,if=talent.subterfuge.enabled&azerite.shrouded_suffocation.enabled&!dot.rupture.ticking
		if S.Rupture:IsReady("Melee") and S.Subterfuge:IsAvailable() and ComboPoints > 0 and S.ShroudedSuffocation:AzeriteEnabled() and not Target:DebuffP(S.Rupture) then
			return S.Rupture:Cast()
		end
		if S.Garrote:IsReady("Melee") and S.Subterfuge:IsAvailable() then
			-- actions.stealthed+=/garrote,cycle_targets=1,if=talent.subterfuge.enabled&azerite.shrouded_suffocation.enabled&target.time_to_die>remains
			local function Evaluate_Garrote_Target_C(TargetUnit)
				return S.ShroudedSuffocation:AzeriteEnabled() and CanDoTUnit(TargetUnit, GarroteDMGThreshold);
			end
			if Target:IsInRange("Melee") and Evaluate_Garrote_Target_C(Target)
					and (Target:FilteredTimeToDie(">", 0, -Target:DebuffRemainsP(S.Garrote)) or Target:TimeToDieIsNotValid()) then
				return S.Garrote:Cast()
			end
			-- actions.stealthed+=/garrote,if=talent.subterfuge.enabled&talent.exsanguinate.enabled&cooldown.exsanguinate.remains<1&prev_gcd.1.rupture&dot.rupture.remains>5+4*cp_max_spend
			if S.Exsanguinate:IsAvailable() and S.Exsanguinate:CooldownRemainsP() < 1 and Player:PrevGCD(1, S.Rupture) and Target:DebuffRemainsP(S.Rupture) > 5 + 4 * CPMaxSpend() then
				-- actions.stealthed+=/pool_resource,for_next=1
				if Player:EnergyPredicted() < 45 then
					S.Garrote:QueueAuto()
					return 0, 135328
				end
				return S.Garrote:Cast()
			end
		end
	end
end

		-- Cheap Shot						  
		if Target:IsAPlayer() and Target:Exists() and not Target:IsCC() and (Player:IsStealthed() or Stealth2) then
			if not Target:IsImmune() and  Target:IsInRange("Melee")  and (Target:HealthPercentage() <= 40 or Target:CastingCC() or Target:IsBursting()) then
			    return S.CheapShot:Cast() 
            end
		end
		
-- # Damage over time abilities
local function Dot ()
    -- actions.dot=rupture,if=talent.exsanguinate.enabled&((combo_points>=cp_max_spend&cooldown.exsanguinate.remains<1)|(!ticking&(time>10|combo_points>=2)))
    if S.Rupture:IsReady("Melee") and ComboPoints > 0 and S.Exsanguinate:IsAvailable()
            and ((ComboPoints >= CPMaxSpend() and S.Exsanguinate:CooldownRemainsP() < 1)
            or (not Target:DebuffP(S.Rupture) and (HL.CombatTime() > 10 or (ComboPoints >= 2)))) then
        return S.Rupture:Cast()
    end
    -- actions.dot+=/garrote,cycle_targets=1,if=(!talent.subterfuge.enabled|!(cooldown.vanish.up&cooldown.vendetta.remains<=4))&combo_points.deficit>=1&refreshable&(pmultiplier<=1|remains<=tick_time&spell_targets.fan_of_knives>=3+azerite.shrouded_suffocation.enabled)&(!exsanguinated|remains<=tick_time*2&spell_targets.fan_of_knives>=3+azerite.shrouded_suffocation.enabled)&(target.time_to_die-remains>4&spell_targets.fan_of_knives<=1|target.time_to_die-remains>12)
    local function EmpoweredDotRefresh()
        return Cache.EnemiesCount[10] >= 3 + num(S.ShroudedSuffocation:AzeriteEnabled())
    end
    if S.Garrote:IsReady() and (not S.Subterfuge:IsAvailable() or not RubimRH.CDsON() or not (S.Vanish:CooldownUp() and S.Vendetta:CooldownRemainsP() <= 4)) and ComboPointsDeficit >= 1 then
        local function Evaluate_Garrote_Target(TargetUnit)
            return TargetUnit:DebuffRefreshableP(S.Garrote, 5.4)
                    and (TargetUnit:PMultiplier(S.Garrote) <= 1 or TargetUnit:DebuffRemainsP(S.Garrote) <= (HL.Exsanguinated(TargetUnit, "Garrote") and ExsanguinatedBleedTickTime or BleedTickTime) and EmpoweredDotRefresh())
                    and (not HL.Exsanguinated(TargetUnit, "Garrote") or TargetUnit:DebuffRemainsP(S.Garrote) <= 1.5 and EmpoweredDotRefresh())
                    and CanDoTUnit(TargetUnit, GarroteDMGThreshold);
        end
        local ttdval = Cache.EnemiesCount[10] <= 1 and 4 or 12;
        if Target:IsInRange("Melee") and Evaluate_Garrote_Target(Target)
                and (Target:FilteredTimeToDie(">", ttdval, -Target:DebuffRemainsP(S.Garrote)) or Target:TimeToDieIsNotValid()) then
            -- actions.maintain+=/pool_resource,for_next=1
            if Player:EnergyPredicted() < 45 then
                return 0, 135328
            end
            return S.Garrote:Cast()
        end
    end
    -- actions.dot+=/crimson_tempest,if=spell_targets>=2&remains<2+(spell_targets>=5)&combo_points>=4
    if RubimRH.AoEON() and S.CrimsonTempest:IsReady("Melee") and ComboPoints >= 4 and active_enemies() >= 2
            and Target:DebuffRemainsP(S.CrimsonTempest) < 2 + num(Cache.EnemiesCount[10] >= 5) then
        return S.CrimsonTempest:Cast()
    end
    -- actions.dot+=/rupture,cycle_targets=1,if=combo_points>=4&refreshable&(pmultiplier<=1|remains<=tick_time&spell_targets.fan_of_knives>=3+azerite.shrouded_suffocation.enabled)&(!exsanguinated|remains<=tick_time*2&spell_targets.fan_of_knives>=3+azerite.shrouded_suffocation.enabled)&target.time_to_die-remains>4
    if ComboPoints >= 4 then
        local function Evaluate_Rupture_Target(TargetUnit)
            return TargetUnit:DebuffRefreshableP(S.Rupture, RuptureThreshold)
                    and (TargetUnit:PMultiplier(S.Rupture) <= 1 or TargetUnit:DebuffRemainsP(S.Rupture) <= (HL.Exsanguinated(TargetUnit, "Rupture") and ExsanguinatedBleedTickTime or BleedTickTime) and EmpoweredDotRefresh())
                    and (not HL.Exsanguinated(TargetUnit, "Rupture") or TargetUnit:DebuffRemainsP(S.Rupture) <= ExsanguinatedBleedTickTime * 2 and EmpoweredDotRefresh())
                    and CanDoTUnit(TargetUnit, RuptureDMGThreshold);
        end
        if S.Rupture:IsReady() and Target:IsInRange("Melee") and Evaluate_Rupture_Target(Target)
                and (Target:FilteredTimeToDie(">", 4, -Target:DebuffRemainsP(S.Rupture)) or Target:TimeToDieIsNotValid()) then
            return S.Rupture:Cast()
        end
    end
end
-- # Direct damage abilities
local function Direct ()
    -- actions.direct=envenom,if=combo_points>=4+talent.deeper_stratagem.enabled&(debuff.vendetta.up|debuff.toxic_blade.up|energy.deficit<=25+variable.energy_regen_combined|spell_targets.fan_of_knives>=2)&(!talent.exsanguinate.enabled|cooldown.exsanguinate.remains>2)
    if S.Envenom:IsReady("Melee") and Player:ComboPoints() >= 4 + num(S.DeeperStratagem:IsAvailable()) and (Target:DebuffP(S.Vendetta) or Target:DebuffP(S.ToxicBladeDebuff) or Player:EnergyDeficit() <= 25 + Energy_Regen_Combined or Cache.EnemiesCount[10] >= 2) and (not S.Exsanguinate:IsAvailable() or S.Exsanguinate:CooldownRemainsP() > 2 or not RubimRH.CDsON()) then
        return S.Envenom:Cast()
    end

    if S.Envenom:IsReady("Melee") and ComboPoints >= 4 + (S.DeeperStratagem:IsAvailable() and 1 or 0)
            and (Target:DebuffP(S.Vendetta) or Target:DebuffP(S.ToxicBladeDebuff) or Player:EnergyDeficitPredicted() <= 25 + Energy_Regen_Combined or Cache.EnemiesCount[10] >= 2)
            and (not S.Exsanguinate:IsAvailable() or S.Exsanguinate:CooldownRemainsP() > 2) then
        return S.Envenom:Cast()
    end
	
		
				if S.Neuro:IsAvailable() and S.Neuro:CooldownUp() and Target:IsAPlayer() and Target:Exists() and not Target:IsCC() and not Player:IsStealthed() and Player:AffectingCombat() then
			 if not Target:IsImmune() and  Target:IsInRange("Melee")  and (Player:HealthPercentage() <= 75 and Target:IsTargeting(Player) or Target:IsBursting()) then
			       return S.Neuro:Cast() 
        end
		end
		
		

				    if S.Shiv:IsAvailable() and S.Shiv:CooldownUp() and Target:IsAPlayer() and Target:Exists() and Target:IsInRange("Melee") and Target:AffectingCombat() then
            if not Target:IsImmuneMagic() and Player:CanAttack(Target) and not Target:IsTargeting(Player)then
            if not Target:IsImmune() and S.Shiv:IsReady() and not Target:IsSnared() and not Target:IsCC() then
                return S.Shiv:Cast()
        end
    end
end

		 		    if S.DFA:IsAvailable() and S.DFA:CooldownUp() and Target:IsAPlayer() and not Target:IsDeadOrGhost() and Player:CanAttack(Target) and Target:Exists() then
					if Player:ComboPoints() >= 5 and Target:IsInRange(15) then
            if not Target:IsImmune() and S.DFA:IsReady()  then
                return S.DFA:Cast()
        end
    end
end

	

    -------------------------------------------------------------------
    -------------------------------------------------------------------
    -- actions.direct+=/variable,name=use_filler,value=combo_points.deficit>1|energy.deficit<=25+variable.energy_regen_combined|spell_targets.fan_of_knives>=2
    -- This is used in all following fillers, so we just return false if not true and won't consider these.
    if not (ComboPointsDeficit > 1 or Player:EnergyDeficitPredicted() <= 25 + Energy_Regen_Combined or Cache.EnemiesCount[10] >= 2) then
    else
        -------------------------------------------------------------------
        -------------------------------------------------------------------

        -- actions.direct+=/poisoned_knife,if=variable.use_filler&buff.sharpened_blades.stack>=29
        if S.PoisonedKnife:IsReady(30) and Player:BuffStack(S.SharpenedBladesBuff) >= 29 then
            return S.PoisonedKnife:Cast()
        end
        -- actions.direct+=/fan_of_knives,if=variable.use_filler&(buff.hidden_blades.stack>=19|spell_targets.fan_of_knives>=2+stealthed.rogue|buff.the_dreadlords_deceit.stack>=29)
        if RubimRH.AoEON() and S.FanofKnives:IsReady("Melee") and (Player:BuffStack(S.HiddenBladesBuff) >= 19 or active_enemies() >= 3 + num(Player:IsStealthedP(true, false)) or Player:BuffStack(S.TheDreadlordsDeceit) >= 29) then
            return S.FanofKnives:Cast()
        end
        -- actions.direct+=/blindside,if=variable.use_filler&(buff.blindside.up|!talent.venom_rush.enabled)
        if S.Blindside:IsReady("Melee") and (Player:BuffP(S.BlindsideBuff) or (not S.VenomRush:IsAvailable() and Target:HealthPercentage() < 30)) then
            return S.Blindside:Cast()
        end
        -- actions.direct+=/mutilate,if=variable.use_filler
        if S.Mutilate:IsReady("Melee") then
            return S.Mutilate:Cast()
        end
    end
end
-- APL Main

local function APL ()
    UpdateCDs()
    -- Spell ID Changes check
    Stealth = S.Subterfuge:IsAvailable() and S.Stealth2 or S.Stealth; -- w/ or w/o Subterfuge Talent

    -- Unit Update
    HL.GetEnemies(50); -- Used for Rogue.PoisonedBleeds()
    HL.GetEnemies(30); -- Used for Poisoned Knife Poison refresh
    HL.GetEnemies(10, true); -- Fan of Knives
    HL.GetEnemies("Melee"); -- Melee

    -- Compute Cache
    ComboPoints = Player:ComboPoints();
    ComboPointsDeficit = Player:ComboPointsMax() - ComboPoints;
    RuptureThreshold = (4 + ComboPoints * 4) * 0.3;
    CrimsonTempestThreshold = (2 + ComboPoints * 2) * 0.3;
    RuptureDMGThreshold = S.Envenom:Damage() * 3; -- Used to check if Rupture is worth to be casted since it's a finisher.
    GarroteDMGThreshold = S.Mutilate:Damage() * 3; -- Used as TTD Not Valid fallback since it's a generator.
   
    --Essences caching
	DetermineEssenceRanks();

    if QueueSkill() ~= nil then
        return QueueSkill()
        end

    -- Defensives
    if S.CrimsonVial:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[259].sk1 then
        return S.CrimsonVial:Cast()
    end
							 	        if S.SmokeBomb:IsAvailable() and S.SmokeBomb:CooldownUp() and Target:IsAPlayer() and Target:Exists() and not Player:IsStealthed() then
								if not Target:IsCC()  and Target:IsInRange("Melee") and Target:AffectingCombat()  then
			       if not Target:IsImmune()  and S.SmokeBomb:IsReady() and (Player:HealthPercentage() <= 40 or RubimRH.CDsON() and Target:IsBursting()) then
                               return S.SmokeBomb:Cast()
         end
			end
			   end
			   	  if S.ShadowStep:IsReady() and Target:IsAPlayer() and not Player:CanAttack(Target) and not Target:IsDeadOrGhost() and Target:Exists()  then
                 if Target:IsInRange(S.ShadowStep) and not Target:IsInRange(15) and Target:IsCC() then
				if Player:IsSnared() or Target:IsCC() or Player:HealthPercentage() <= 55 or Target:HealthPercentage() <= 55 then
               return S.ShadowStep:Cast()
                end
                end
	            end
						 if Target:Exists() and Target:IsAPlayer() and not Target:IsDeadOrGhost() then
			if Player:IsStealthed() and  Target:IsInRange(10) and not Target:AffectingCombat() and (Player:CanAttack(Target) or Target:IsTargeting(Player) or Target:CastingCC()  or Target:IsBursting()) then
					 if not Target:IsImmune() and S.Sap:IsReady() then
			                      return S.Sap:Cast()
								  
								  end
								  end
								  end
    --CUSTOM
    if S.CloakofShadows:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[259].sk2 then
        return S.CloakofShadows:Cast()
    end

    if S.Evasion:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[259].sk3 and Player:LastSwinged() <= 3 then
        return S.Evasion:Cast()
    end


    -- Poisons
    local PoisonRefreshTime = Player:AffectingCombat() and 3 * 60 or 15 * 60;
    -- Lethal Poison
    if Player:BuffRemainsP(S.DeadlyPoison) <= PoisonRefreshTime
            and Player:BuffRemainsP(S.WoundPoison) <= PoisonRefreshTime then
        return S.DeadlyPoison:Cast()
    end
    -- Non-Lethal Poison
    if Player:BuffRemainsP(S.CripplingPoison) <= PoisonRefreshTime then
        return S.CripplingPoison:Cast()
    end

    -- Out of Combat
    if not Player:AffectingCombat() then
        -- Stealth
        -- Precombat CDs
        if S.MarkedforDeath:IsReadyP() and Player:ComboPointsDeficit() >= CPMaxSpend() then
            return S.MarkedforDeath:Cast()
        end
        -- Flask
        -- Food
        -- Rune
        -- PrePot w/ Bossmod Countdown
		
        if RubimRH.TargetIsValid(true) and (S.Vanish:TimeSinceLastCast() <= 10 or RubimRH.db.profile.mainOption.startattack) then
			if not IsStealthed() and (Stealth:IsReady() or Stealth:CooldownRemainsP() <= 0) then 
				return S.Stealth:Cast()			
            elseif Stealthed() ~= nil then
                return Stealthed()
            end
        end

        return 0, 462338
    end

    if S.Kick:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.Kick:Cast()
    end
	
	if RubimRH.AoEON() and RubimRH.AssaAutoAoEON() and Target:DebuffRemainsP(S.Rupture) >= S.Rupture:BaseDuration() * 0.90 and active_enemies() >= 2 and active_enemies() < 5 and CombatTime("player") > 0 and 
( -- Rupture
    not IsSpellInRange(1943, "target") or   
    (
        CombatTime("target") == 0 and
        not Player:InPvP()
    ) 
) and
(
    -- Rupture
    MultiDots(10, S.Rupture, 10, 3) >= 1 or
    (
        CombatTime("target") == 0 and
        not Player:InPvP()
    ) 
) then 
    return 133015 
   end

    -- In Combat
    -- actions=variable,name=energy_regen_combined,value=energy.regen+poisoned_bleeds*7%(2*spell_haste)
    Energy_Regen_Combined = Player:EnergyRegen() + PoisonedBleeds() * 7 / (2 * Player:SpellHaste());

    -- actions+=/call_action_list,name=stealthed,if=stealthed.rogue
    if Player:IsStealthedP(true, false) then
        if Stealthed() ~= nil then
            return Stealthed()
        end
    end
    -- actions+=/call_action_list,name=cds
    if CDs() ~= nil then
        return CDs()
    end
    -- actions+=/call_action_list,name=dot
    if Dot() ~= nil then
        return Dot()
    end
    -- actions+=/call_action_list,name=direct
    if Direct() ~= nil then
        return Direct()
    end
    -- Racials
    if RubimRH.CDsON() then
        -- actions+=/arcane_torrent,if=energy.deficit>=15+variable.energy_regen_combined
        if S.ArcaneTorrent:IsReadyP("Melee") and Player:EnergyDeficitPredicted() > 15 + Energy_Regen_Combined then
            return S.ArcaneTorrent:Cast()
        end
        -- actions+=/arcane_pulse
        if S.ArcanePulse:IsReadyP("Melee") then
            return S.ArcanePulse:Cast()
        end
        -- actions+=/lights_judgment
        if S.LightsJudgment:IsReadyP("Melee") then
            return S.LightsJudgment:Cast()
        end
    end
    -- Poisoned Knife Out of Range [EnergyCap] or [PoisonRefresh]")
    if S.PoisonedKnife:IsReady(30) and not Player:IsStealthedP(true, true)
            and ((not Target:IsInRange(10) and Player:EnergyTimeToMax() <= Player:GCD() * 1.2)
            or (not Target:IsInRange("Melee") and Target:DebuffRefreshableP(S.DeadlyPoisonDebuff, 4))) then
        return S.PoisonedKnife:Cast()
    end
    -- Trick to take in consideration the Recovery Setting
    return 0, 135328
end

RubimRH.Rotation.SetAPL(259, APL)

local function PASSIVE()
    return RubimRH.Shared()
end
RubimRH.Rotation.SetPASSIVE(259, PASSIVE)