--- Localize Vars
-- Addon
local addonName, addonTable = ...;
-- HeroLib
local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;
local CombatIcon = 135328
local OutCombatIcon = 462338
-- Lua
local pairs = pairs;
local tableinsert = table.insert;

--- APL Local Vars
-- Commons
-- Spells
RubimRH.Spell[261] = {
    -- Racials
    ArcanePulse = Spell(260364),
    ArcaneTorrent = Spell(25046),
    Berserking = Spell(26297),
    BloodFury = Spell(20572),
    LightsJudgment = Spell(255647),
    Shadowmeld = Spell(58984),
    -- Abilities
    Backstab = Spell(53),
    Eviscerate = Spell(196819),
    Nightblade = Spell(195452),
    ShadowBlades = Spell(121471),
    ShurikenComboBuff = Spell(245640),
    ShadowDance = Spell(185313),
    ShadowDanceBuff = Spell(185422),
    Shadowstrike = Spell(185438),
    ShurikenStorm = Spell(197835),
    ShurikenToss = Spell(114014),
    Stealth = Spell(1784),
    Stealth2 = Spell(115191), -- w/ Subterfuge Talent
    SymbolsofDeath = Spell(212283),
    Vanish = Spell(1856),
    VanishBuff = Spell(11327),
    VanishBuff2 = Spell(115193), -- w/ Subterfuge Talent
    -- Talents
    Alacrity = Spell(193539),
    DarkShadow = Spell(245687),
    DeeperStratagem = Spell(193531),
    EnvelopingShadows = Spell(238104),
    FindWeaknessDebuff = Spell(91021),
    Gloomblade = Spell(200758),
    MarkedforDeath = Spell(137619),
    MasterofShadows = Spell(196976),
    Nightstalker = Spell(14062),
    SecretTechnique = Spell(280719),
    ShadowFocus = Spell(108209),
    ShurikenTornado = Spell(277925),
    Subterfuge = Spell(108208),
    Vigor = Spell(14983),
    -- Azerite Traits
    BladeInTheShadows = Spell(275896),
    NightsVengeancePower = Spell(273418),
    NightsVengeanceBuff = Spell(273424),
    SharpenedBladesPower = Spell(272911),
    SharpenedBladesBuff = Spell(272916),
    -- Defensive
    Feint = Spell(1966),
    -- Utility
    Blind = Spell(2094),
    CheapShot = Spell(1833),
    Kick = Spell(1766),
    KidneyShot = Spell(408),
    Sprint = Spell(2983),
	Sap = Spell(6770),
	ColdBlood = Spell(213981),
	Shiv = Spell(248744),
	SmokeBomb = Spell (212182),
	DFA = Spell (269513),
	Duel = Spell (207736),
    -- Misc
    TheDreadlordsDeceit = Spell(228224),
    CloakofShadows = Spell(31224),
    CrimsonVial = Spell(185311),
    Feint = Spell(1966),
    Evasion = Spell(5277),
	ReplicatingShadows                    = Spell(286121),
	
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
local S = RubimRH.Spell[261]

local function CPMaxSpend()
    -- Should work for all 3 specs since they have same Deeper Stratagem Spell ID.
    return S.DeeperStratagem:IsAvailable() and 6 or 5;
end

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- "cp_spend"
local function CPSpend()
    return math.min(Player:ComboPoints(), CPMaxSpend());
end

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

S.Eviscerate:RegisterDamage(
-- Eviscerate DMG Formula (Pre-Mitigation):
--- Player Modifier
-- AP * CP * EviscR1_APCoef * EviscR2_M * Aura_M * NS_M * DS_M * DSh_M * SoD_M * ShC_M * Mastery_M * Versa_M
--- Target Modifier
-- NB_M
        function()
            return
            --- Player Modifier
            -- Attack Power
            Player:AttackPowerDamageMod() *
                    -- Combo Points
                    CPSpend() *
                    -- Eviscerate R1 AP Coef
                    0.16074 *
                    -- Eviscerate R2 Multiplier
                    1.5 *
                    -- Aura Multiplier (SpellID: 137035)
                    1.28 *
                    -- Nightstalker Multiplier
                    (S.Nightstalker:IsAvailable() and Player:IsStealthed(true) and 1.12 or 1) *
                    -- Deeper Stratagem Multiplier
                    (S.DeeperStratagem:IsAvailable() and 1.05 or 1) *
                    -- Dark Shadow Multiplier
                    (S.DarkShadow:IsAvailable() and Player:BuffP(S.ShadowDanceBuff) and 1.25 or 1) *
                    -- Symbols of Death Multiplier
                    (Player:BuffP(S.SymbolsofDeath) and 1.15 or 1) *
                    -- Shuriken Combo Multiplier
                    (Player:BuffP(S.ShurikenComboBuff) and (1 + Player:Buff(S.ShurikenComboBuff, 16) / 100) or 1) *
                    -- Mastery Finisher Multiplier
                    (1 + Player:MasteryPct() / 100) *
                    -- Versatility Damage Multiplier
                    (1 + Player:VersatilityDmgPct() / 100) *
                    --- Target Modifier
                    -- Nightblade Multiplier
                    (Target:DebuffP(S.Nightblade) and 1.15 or 1);
        end
);
S.Nightblade:RegisterPMultiplier(
        { function()
            return S.Nightstalker:IsAvailable() and Player:IsStealthed(true, false) and 1.12 or 1;
        end }
);
-- Items
if not Item.Rogue then
    Item.Rogue = {};
end
Item.Rogue.Subtlety = {
    -- Nothing here yet
};
local I = Item.Rogue.Subtlety;
local AoETrinkets = { };

local Stealth, VanishBuff;
-- GUI Settings

-- Melee Is In Range Handler
local function IsInMeleeRange ()
    return Target:IsInRange("Melee") and true or false;
end

local function CanDoTUnit(Unit, HealthThreshold)
    return Unit:Health() >= HealthThreshold or Unit:IsDummy();
end

local function num(val)
    if val then
        return 1
    else
        return 0
    end
end

-- APL Action Lists (and Variables)
-- actions+=/variable,name=stealth_threshold,value=25+talent.vigor.enabled*35+talent.master_of_shadows.enabled*25+talent.shadow_focus.enabled*20+talent.alacrity.enabled*10+15*(spell_targets.shuriken_storm>=3)
local function Stealth_Threshold ()
    return 25 + num(S.Vigor:IsAvailable()) * 35 + num(S.MasterofShadows:IsAvailable()) * 25 + num(S.ShadowFocus:IsAvailable()) * 20 + num(S.Alacrity:IsAvailable()) * 10 + num(Cache.EnemiesCount[10] >= 3) * 15;
end
-- actions.stealth_cds=variable,name=shd_threshold,value=cooldown.shadow_dance.charges_fractional>=1.75
local function ShD_Threshold ()
    return S.ShadowDance:ChargesFractional() >= 1.75
end

-- # Finishers
-- ReturnSpellOnly and StealthSpell parameters are to Predict Finisher in case of Stealth Macros
local function Finish()
    local ShadowDanceBuff = Player:BuffP(S.ShadowDanceBuff)

		 		    if S.DFA:IsAvailable() and S.DFA:CooldownUp() and Target:IsAPlayer() and not Target:IsDeadOrGhost() and Player:CanAttack(Target) and Target:Exists() then
					if Player:ComboPoints() >= 5 and Target:IsInRange(15) and ShadowDanceBuff then
            if not Target:IsImmune() and S.DFA:IsReady()  then
                return S.DFA:Cast()
        end
    end
end

		 	        if Target:IsAPlayer() and not Target:IsDeadOrGhost() and Player:CanAttack(Target) and Target:Exists() then 
					if not Player:IsStealthed() and not Target:IsCC()  and IsInMeleeRange() and Player:ComboPoints() >= 4 then
			       if not Target:IsImmune() and S.KidneyShot:IsReady() and (Target:HealthPercentage() <= 35 or Target:CastingCC()  or Target:IsBursting() or Target:IsTargeting(Player)) then
                               return S.KidneyShot:Cast()
         end
			end
			   end

    -- actions.finish=eviscerate,if=talent.shadow_focus.enabled&buff.nights_vengeance.up&spell_targets.shuriken_storm>=2+3*talent.secret_technique.enabled
    if S.Eviscerate:IsReady() and IsInMeleeRange() and S.ShadowFocus:IsAvailable() and Player:BuffP(S.NightsVengeanceBuff)
            and Cache.EnemiesCount[10] >= 2 + 3 * num(S.SecretTechnique:IsAvailable()) then
        return S.Eviscerate:Cast()
    end

    if S.Nightblade:IsReady() then
        local NightbladeThreshold = (6 + CPSpend() * 2) * 0.3;
        -- actions.finish=nightblade,if=(!talent.dark_shadow.enabled|!buff.shadow_dance.up)&target.time_to_die-remains>6&remains<tick_time*2&(spell_targets.shuriken_storm<4|!buff.symbols_of_death.up)
        if IsInMeleeRange() and  Player:AffectingCombat() and (not S.DarkShadow:IsAvailable() or not ShadowDanceBuff) 
                and (Target:FilteredTimeToDie(">", 6, -Target:DebuffRemainsP(S.Nightblade)) or Target:TimeToDieIsNotValid())
                and CanDoTUnit(Target, S.Eviscerate:Damage() * 3)
                and Target:DebuffRemainsP(S.Nightblade) < 4
                and (Cache.EnemiesCount[10] < 4 or not Player:BuffP(S.SymbolsofDeath)) then
            return S.Nightblade:Cast()
        end
        -- actions.finish+=/nightblade,cycle_targets=1,if=spell_targets.shuriken_storm>=2&(talent.secret_technique.enabled|azerite.nights_vengeance.enabled|spell_targets.shuriken_storm<=5)&!buff.shadow_dance.up&target.time_to_die>=(5+(2*combo_points))&refreshable
        if S.Nightblade:IsReady() and  Player:AffectingCombat() and (Cache.EnemiesCount[10] >= 2 and (S.SecretTechnique:IsAvailable() or S.NightsVengeancePower:AzeriteEnabled() or Cache.EnemiesCount[10] <= 5) and not Player:BuffP(S.ShadowDanceBuff) and Target:TimeToDie() >= (5 + (2 * Player:ComboPoints())) and Target:DebuffRefreshableC(S.Nightblade)) then
            return S.Nightblade:Cast()
        end
        -- actions.finish+=/nightblade,if=remains<cooldown.symbols_of_death.remains+10&cooldown.symbols_of_death.remains<=5&target.time_to_die-remains>cooldown.symbols_of_death.remains+5
        if IsInMeleeRange() and  Player:AffectingCombat() and Target:DebuffRemainsP(S.Nightblade) < S.SymbolsofDeath:CooldownRemainsP() + 10
                and S.SymbolsofDeath:CooldownRemainsP() <= 5
                and CanDoTUnit(Target, S.Eviscerate:Damage() * 3)
                and (Target:FilteredTimeToDie(">", 5 + S.SymbolsofDeath:CooldownRemainsP(), -Target:DebuffRemainsP(S.Nightblade)) or Target:TimeToDieIsNotValid()) then
            return S.Nightblade:Cast()
        end
    end
    -- actions.finish+=/secret_technique,if=buff.symbols_of_death.up&(!talent.dark_shadow.enabled|buff.shadow_dance.up)
    if S.SecretTechnique:IsReady() and Player:BuffP(S.SymbolsofDeath) and (not S.DarkShadow:IsAvailable() or ShadowDanceBuff) then
        return S.SecretTechnique:Cast()
    end
    -- actions.finish+=/secret_technique,if=spell_targets.shuriken_storm>=2+talent.dark_shadow.enabled+talent.nightstalker.enabled
    if S.SecretTechnique:IsReady() and Cache.EnemiesCount[10] >= 2 + num(S.DarkShadow:IsAvailable()) + num(S.Nightstalker:IsAvailable()) then
        return S.SecretTechnique:Cast()
    end
    -- actions.finish+=/eviscerate
    if S.Eviscerate:IsReady() and IsInMeleeRange() then
        return S.Eviscerate:Cast()

    end
end

-- # Stealthed Rotation
-- ReturnSpellOnly and StealthSpell parameters are to Predict Finisher in case of Stealth Macros
local function Stealthed ()
    local StealthBuff = Player:Buff(Stealth)
    -- # If stealth is up, we really want to use Shadowstrike to benefits from the passive bonus, even if we are at max cp (from the precombat MfD).
    -- actions.stealthed=shadowstrike,if=buff.stealth.up
    if Player:AffectingCombat() and S.Shadowstrike:IsReady() and (Target:IsInRange(S.Shadowstrike) or IsInMeleeRange()) then
        return S.Shadowstrike:Cast()
    end
    -- actions.stealthed+=/call_action_list,name=finish,if=combo_points.deficit<=1-(talent.deeper_stratagem.enabled&buff.vanish.up)
    if Player:ComboPointsDeficit() <= 1 - num(S.DeeperStratagem:IsAvailable() and Player:BuffP(VanishBuff)) then
        if Finish() ~= nil then
            return Finish()
        end
    end
    -- actions.stealthed+=/shuriken_toss,if=buff.sharpened_blades.stack>=29
    if S.ShurikenToss:IsReadyP() and Player:BuffStackP(S.SharpenedBladesBuff) >= 29 then
        return S.ShurikenToss:Cast()
    end
    -- actions.stealthed+=/shadowstrike,cycle_targets=1,if=talent.secret_technique.enabled&talent.find_weakness.enabled&debuff.find_weakness.remains<1&spell_targets.shuriken_storm=2&target.time_to_die-remains>6
    -- !!!NYI!!! (Is this worth it? How do we want to display it in an understandable way?)
    -- actions.stealthed+=/shadowstrike,if=!talent.deeper_stratagem.enabled&azerite.blade_in_the_shadows.rank=3&spell_targets.shuriken_storm=3
    if S.Shadowstrike:IsReadyP() and Player:AffectingCombat() and not S.DeeperStratagem:IsAvailable() and S.BladeInTheShadows:AzeriteRank() == 3 and Cache.EnemiesCount[10] == 3 then
        return S.Shadowstrike:Cast()
    end
    -- actions.stealthed+=/shuriken_storm,if=spell_targets>=3
    if RubimRH.AoEON() and S.ShurikenStorm:IsReady() and Target:AffectingCombat() and active_enemies() >= 3 then
        return S.ShurikenStorm:Cast()
    end
    -- actions.stealthed+=/shadowstrike
    if S.Shadowstrike:IsReady() and Target:AffectingCombat() and (Target:IsInRange(S.Shadowstrike) or IsInMeleeRange()) then
        return S.Shadowstrike:Cast()
    end
    return 0, CombatIcon
end

-- # Stealth Macros
-- This returns a table with the original Stealth spell and the result of the Stealthed action list as if the applicable buff was present

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
  -- memory_of_lucid_dreams,if=energy<40&buff.symbols_of_death.up
  if S.MemoryOfLucidDreams:IsCastableP() and Player:EnergyPredicted() < 40 and Player:BuffP(S.SymbolsofDeath) then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  return false
end

-- # Cooldowns
local function CDs ()
    if IsInMeleeRange() then
        if RubimRH.CDsON() then
            -- actions.cds=potion,if=buff.bloodlust.react|target.time_to_die<=60|(buff.vanish.up&(buff.shadow_blades.up|cooldown.shadow_blades.remains<=30))
            -- TODO: Add Potion Suggestion
			
    -- actions.cds+=/call_action_list,name=essences,if=!stealthed.all&dot.nightblade.ticking
    local ShouldReturn = Essences(); 
	if ShouldReturn and (true) and not Player:IsStealthedP(true, true) and Target:DebuffP(S.Nightblade) then 
	    return ShouldReturn; 
	end

            -- Racials
            if Player:IsStealthedP(true, false) then
                -- actions.cds+=/blood_fury,if=stealthed.rogue
                if S.BloodFury:IsReady() then
                    return S.BloodFury:Cast()
                end
                -- actions.cds+=/berserking,if=stealthed.rogue
                if S.Berserking:IsReady() then
                    return S.Berserking:Cast()
                end
            end
        end
		
						if  S.Duel:IsAvailable() and S.Duel:CooldownUp() and Target:IsAPlayer()  and not Target:IsDeadOrGhost() and Player:CanAttack(Target) and S.Duel:IsReady() and  Target:Exists() then
				if not Target:IsCC() and not Player:IsStealthed() and not  ShadowDanceBuff then
			 if not Target:IsImmune() and  IsInMeleeRange()  and Target:HealthPercentage() <= 35 then
	       if S.ShadowDance:IsReady() and not Player:BuffP(S.ShadowDanceBuff) then
			       return S.Duel:Cast() 
        end
		end
		end 
		end

        -- actions.cds+=/symbols_of_death,if=dot.nightblade.ticking
        if S.SymbolsofDeath:IsReady() and  Player:AffectingCombat() and Target:DebuffP(S.Nightblade) then
            return S.SymbolsofDeath:Cast()
        end
            -- actions.cds+=/marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit
            -- Note: Done at the start of the Rotation (Rogue Commmon)
            -- actions.cds+=/marked_for_death,if=raid_event.adds.in>30&!stealthed.all&combo_points.deficit>=cp_max_spend
            if S.MarkedforDeath:IsReady() then
                if Target:FilteredTimeToDie("<", Player:ComboPointsDeficit()) or (false and not Player:IsStealthedP(true, true) and Player:ComboPointsDeficit() >= CPMaxSpend()) then
                    return S.MarkedforDeath:Cast()
                elseif not Player:IsStealthedP(true, true) and Player:ComboPointsDeficit() >= CPMaxSpend() then
                    return S.MarkedforDeath:Cast()
                end
            end
			if RubimRH.CDsON() then
            -- actions.cds+=/shadow_blades,if=combo_points.deficit>=2+stealthed.all
            if S.ShadowBlades:IsReady() and not Player:Buff(S.ShadowBlades)
                    and Player:ComboPointsDeficit() >= 2 + num(Player:IsStealthedP(true, true)) then
                return S.ShadowBlades:Cast()
            end
            -- actions.cds+=/shuriken_tornado,if=spell_targets>=3&dot.nightblade.ticking&buff.symbols_of_death.up&buff.shadow_dance.up
            if S.ShurikenTornado:IsReadyP() and  Player:AffectingCombat() and Cache.EnemiesCount[10] >= 3 and Target:DebuffP(S.Nightblade) and Player:BuffP(S.SymbolsofDeath) and Player:BuffP(S.ShadowDanceBuff) then
                return S.ShurikenTornado:Cast()
            end
            -- actions.cds+=/shadow_dance,if=!buff.shadow_dance.up&target.time_to_die<=5+talent.subterfuge.enabled
            if S.ShadowDance:IsReady() and not Player:BuffP(S.ShadowDanceBuff) and Target:FilteredTimeToDie("<=", 5 + num(S.Subterfuge:IsAvailable())) then
                return S.ShadowDance:Cast()
            end
			-- actions.cds+=/call_action_list,name=essences
            ShouldReturn = Essences();
            if ShouldReturn and (true) then return ShouldReturn; end
        end
    end
end



-- # Stealth Cooldowns
local function Stealth_CDs ()
    if IsInMeleeRange() then
        -- actions.stealth_cds+=/vanish,if=!variable.shd_threshold&debuff.find_weakness.remains<1&combo_points.deficit>1
        if RubimRH.CDsON() and S.Vanish:IsReady() and S.ShadowDance:TimeSinceLastDisplay() > 0.3 and S.Shadowmeld:TimeSinceLastDisplay() > 0.3 and not Player:IsTanking(Target)
                and not ShD_Threshold() and Target:DebuffRemainsP(S.FindWeaknessDebuff) < 1 and Player:ComboPointsDeficit() > 1 then
            return S.Vanish:Cast()
        end
        -- actions.stealth_cds+=/shadowmeld,if=energy>=40&energy.deficit>=10&!variable.shd_threshold&debuff.find_weakness.remains<1&combo_points.deficit>1
        -- actions.stealth_cds+=/shadow_dance,if=(!talent.dark_shadow.enabled|dot.nightblade.remains>=5+talent.subterfuge.enabled)&(variable.shd_threshold|buff.symbols_of_death.remains>=1.2|spell_targets.shuriken_storm>=4&cooldown.symbols_of_death.remains>10)
        if (RubimRH.CDsON() or (S.ShadowDance:ChargesFractional() >= 2.55 - (S.DarkShadow:IsAvailable() and 0.75 or 0)))
                and S.ShadowDance:IsReady() and S.Vanish:TimeSinceLastDisplay() > 0.3
                and S.ShadowDance:TimeSinceLastDisplay() ~= 0 and S.Shadowmeld:TimeSinceLastDisplay() > 0.3 and S.ShadowDance:Charges() >= 1
                and (not S.DarkShadow:IsAvailable() or Target:DebuffRemainsP(S.Nightblade) >= 5 + num(S.Subterfuge:IsAvailable()))
                and (ShD_Threshold() or Player:BuffRemainsP(S.SymbolsofDeath) >= 1.2 or (Cache.EnemiesCount[10] >= 4 and S.SymbolsofDeath:CooldownRemainsP() > 10))
				and (S.NightsVengeancePower:AzeriteRank() < 3 or Player:BuffP(S.NightsVengeanceBuff)) then
            return S.ShadowDance:Cast()
        end
        -- actions.stealth_cds+=/shadow_dance,if=target.time_to_die<cooldown.symbols_of_death.remains
        if (RubimRH.CDsON() or (S.ShadowDance:ChargesFractional() >= 2.55 - (S.DarkShadow:IsAvailable() and 0.75 or 0)))
                and S.ShadowDance:IsReady() and S.Vanish:TimeSinceLastDisplay() > 0.3
                and S.ShadowDance:TimeSinceLastDisplay() ~= 0 and S.Shadowmeld:TimeSinceLastDisplay() > 0.3 and S.ShadowDance:Charges() >= 1
                and Target:TimeToDie() < S.SymbolsofDeath:CooldownRemainsP() then
            return S.ShadowDance:Cast()
        end
    end
end

-- # Builders
local function Build ()

		if Target:IsAPlayer() and Target:Exists() and not Target:IsCC() and (Player:IsStealthed() or ShadowDanceBuff) then
			 if not Target:IsImmune() and  IsInMeleeRange()  and (Target:HealthPercentage() <= 40 or Target:CastingCC()  or Target:IsBursting()) then
			       return S.CheapShot:Cast() 
        end
		end
    -- actions.build=shuriken_toss,if=!talent.nightstalker.enabled&(!talent.dark_shadow.enabled|cooldown.symbols_of_death.remains>10)&buff.sharpened_blades.stack>=29&spell_targets.shuriken_storm<=(3*azerite.sharpened_blades.rank)
    if S.ShurikenToss:IsReadyP() and not S.Nightstalker:IsAvailable()
            and (not S.DarkShadow:IsAvailable() or S.SymbolsofDeath:CooldownRemainsP() > 10)
            and Player:BuffStackP(S.SharpenedBladesBuff) >= 29
            and Cache.EnemiesCount[10] <= 3 * S.SharpenedBladesPower:AzeriteRank() then
        return S.ShurikenToss:Cast()
    end
    -- actions.build=shuriken_storm,if=spell_targets>=2|buff.the_dreadlords_deceit.stack>=29
    if RubimRH.AoEON() and S.ShurikenStorm:IsReadyP() and (Cache.EnemiesCount[10] >= 3 or Player:BuffStackP(S.TheDreadlordsDeceit) >= 29) then
        return S.ShurikenStorm:Cast()
    end
    if IsInMeleeRange() then
        -- actions.build+=/gloomblade
        if S.Gloomblade:IsReady() then
            return S.Gloomblade:Cast()
            -- actions.build+=/backstab
        elseif S.Backstab:IsReady() then
            return S.Backstab:Cast()
        end
    end
end


		



local function Custom()
    -- Crimson Vial
    if S.CrimsonVial:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[261].sk1 then
        return S.CrimsonVial:Cast()
    end

    --Custom
    if S.Kick:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.Kick:Cast()
    end

    -- In Combat
    if S.CloakofShadows:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[261].sk2 then
        return S.CloakofShadows:Cast()
    end

    if S.Evasion:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[261].sk3 and Player:LastSwinged() <= 3 then
        return S.Evasion:Cast()
    end
end

-- APL Main
local function APL ()
    -- Spell ID Changes check
    if S.Subterfuge:IsAvailable() then
        Stealth = S.Stealth2;
        VanishBuff = S.VanishBuff2;
    else
        Stealth = S.Stealth;
        VanishBuff = S.VanishBuff;
    end
	-- Essences
	DetermineEssenceRanks()
	
    -- Unit Update
    HL.GetEnemies(10, true); -- Shuriken Storm & Death from Above
    HL.GetEnemies("Melee"); -- Melee
    --- Defensives
    -- Crimson Vial
    if S.CrimsonVial:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[261].sk1 then
        return S.CrimsonVial:Cast()
    end
    --- Out of Combat
   if not Player:AffectingCombat() then
        -- Stealth
        -- Note: Since 7.2.5, Blizzard disallowed Stealth cast under ShD (workaround to prevent the Extended Stealth bug)
        -- Flask
        -- Food
        -- Rune
        -- PrePot w/ Bossmod Countdown
        -- Opener
        -- Precombat CDs
          --  if S.MarkedforDeath:IsReadyP() and Player:ComboPointsDeficit() >= CPMaxSpend() then
               -- return S.MarkedforDeath:Cast()
         --   end
		 if Target:Exists() and Target:IsAPlayer() and not Target:IsDeadOrGhost() and Player:CanAttack(Target) then
			if Player:IsStealthed()  and  Target:IsInRange(10) and not Target:AffectingCombat() and (Target:IsTargeting(Player) or Target:CastingCC()  or Target:IsBursting()) then
					 if not Target:IsImmune()  and S.Sap:IsReady() then
			                      return S.Sap:Cast()
								  
								  end
								  end
								  end


			            if S.MarkedforDeath:IsReadyP() and Player:ComboPointsDeficit() >= CPMaxSpend() and Target:AffectingCombat() then
                return S.MarkedforDeath:Cast()
            end
            if S.ShadowBlades:IsReady() and Target:AffectingCombat() and not Player:Buff(S.ShadowBlades) then
               return S.ShadowBlades:Cast()
           end
		if (S.Vanish:TimeSinceLastCast() <= 10 or RubimRH.db.profile.mainOption.startattack) then
			if not IsStealthed() and (Stealth:IsReady() or Stealth:CooldownRemainsP() <= 0) then 
				return S.Stealth:Cast()			
            elseif Stealthed() ~= nil then
                return Stealthed()
			elseif Player:EnergyPredicted() < 30 then
                return 0, 135328
            end
        
    --  if Player:IsStealthedP(true, true) and S.Vanish:TimeSinceLastCast() <= 10 or RubimRH.db.profile.mainOption.startattack then
    --      if Stealthed() ~= nil then
    --          return Stealthed()
    --      end
    --      if Player:EnergyPredicted() < 30 then
    --          return 0, 135328
    --      end
        elseif Player:ComboPoints() >= 5 and S.Vanish:TimeSinceLastCast() <= 10 or RubimRH.db.profile.mainOption.startattack then
            if Finish() ~= nil then
                return Finish()
            end
        elseif S.Backstab:IsReady() and S.Vanish:TimeSinceLastCast() <= 10 or RubimRH.db.profile.mainOption.startattack then
            return S.Backstab:Cast()
        end
        return 0, 462338
    end

    -- In Combat
	if QueueSkill() ~= nil then
        return QueueSkill()
    end
	  
    if S.Kick:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.Kick:Cast()
    end
		
		    if S.Shiv:IsAvailable() and S.Shiv:CooldownUp() and Target:IsAPlayer() and Target:Exists() and IsInMeleeRange() and Target:AffectingCombat() then
            if not Target:IsImmuneMagic() and Player:CanAttack(Target)then
            if not Target:IsImmune() and S.Shiv:IsReady() and not Target:IsSnared() and not Target:IsCC() then
                return S.Shiv:Cast()
        end
    end
end

    -- # Check CDs at first
    -- actions=call_action_list,name=cds
    if CDs() ~= nil then
        return CDs()
    end

    -- # Run fully switches to the Stealthed Rotation (by doing so, it forces pooling if nothing is available).
    -- actions+=/run_action_list,name=stealthed,if=stealthed.all
    if Player:IsStealthedP(true, true) then
        return Stealthed()
    end

    -- # Apply Nightblade at 2+ CP during the first 10 seconds, after that 4+ CP if it expires within the next GCD or is not up
    -- actions+=/nightblade,if=target.time_to_die>6&remains<gcd.max&combo_points>=4-(time<10)*2
    if S.Nightblade:IsReadyP() and IsInMeleeRange() and Target:AffectingCombat()
            and (Target:FilteredTimeToDie(">", 6) or Target:TimeToDieIsNotValid())
            and CanDoTUnit(Target, S.Eviscerate:Damage() * 3)
            and Target:DebuffRemainsP(S.Nightblade) < Player:GCD() and Player:ComboPoints() >= 4 - (HL.CombatTime() < 10 and 2 or 0) then
        return S.Nightblade:Cast()
    end

    -- # Consider using a Stealth CD when reaching the energy threshold and having space for at least 4 CP
    -- actions+=/call_action_list,name=stealth_cds,if=energy.deficit<=variable.stealth_threshold&(talent.dark_shadow.enabled&cooldown.secret_technique.up|combo_points.deficit>=4)
    if (Player:EnergyDeficit() <= Stealth_Threshold() and (S.DarkShadow:IsAvailable() and S.SecretTechnique:CooldownUp() or Player:ComboPointsDeficit() >= 4)) then
        if Stealth_CDs() ~= nil then
            return Stealth_CDs()
        end
    end
	
	 -- actions+=/nightblade,if=azerite.nights_vengeance.enabled&spell_targets.shuriken_storm<2&(cooldown.symbols_of_death.remains<=3|(buff.symbols_of_death.up&!stealthed.all&azerite.nights_vengeance.rank>=3))&!buff.nights_vengeance.up&combo_points>=2
    if S.Nightblade:IsCastableP() and IsInMeleeRange() and S.NightsVengeancePower:AzeriteEnabled() and Cache.EnemiesCount[10] < 2
        and (S.SymbolsofDeath:CooldownRemainsP() <= 3 or (Player:BuffP(S.SymbolsofDeath) and not Player:IsStealthedP(true, true) and S.NightsVengeancePower:AzeriteRank() >= 3 ))
        and not Player:BuffP(S.NightsVengeanceBuff) and Player:ComboPoints() >= 2 then
        return S.Nightblade:Cast()
    end

    -- # Finish at 4+ without DS, 5+ with DS (outside stealth)
    -- actions+=/call_action_list,name=finish,if=combo_points.deficit<=1|target.time_to_die<=1&combo_points>=3
    if Player:ComboPointsDeficit() <= 1 or (Target:FilteredTimeToDie("<=", 1) and Player:ComboPoints() >= 3) then
        if Finish() ~= nil then
            return Finish()
        end
    end

    -- actions+=/call_action_list,name=finish,if=spell_targets.shuriken_storm=4&combo_points>=4
    if Cache.EnemiesCount[10] == 4 and Player:ComboPoints() >= 4 then
        if Finish() ~= nil then
            return Finish()
        end
    end

    -- # Use a builder when reaching the energy threshold
    -- actions+=/call_action_list,name=build,if=energy.deficit<=variable.stealth_threshold
    if Player:EnergyDeficitPredicted() <= Stealth_Threshold() then
        if Build() ~= nil then
            return Build()
        end
    end
		if S.ColdBlood:IsAvailable() and S.ColdBlood:CooldownUp() and Target:IsAPlayer() and not Target:IsDeadOrGhost() and Player:CanAttack(Target) and S.ColdBlood:IsReady() then
		if (Player:IsStealthed() or ShadowDanceBuff) then
			 if  not Target:IsImmune() and (Target:HealthPercentage() <= 35 or RubimRH.CDsON()) then
			       return S.ColdBlood:Cast()
        end
		end
		end
		
							 	        if S.SmokeBomb:IsAvailable() and S.SmokeBomb:CooldownUp() and Target:IsAPlayer() and Target:Exists() and not Player:IsStealthed() then
								if not Target:IsCC()  and IsInMeleeRange() and Target:AffectingCombat()  then
			       if not Target:IsImmune()  and S.SmokeBomb:IsReady() and (Player:HealthPercentage() <= 40 or RubimRH.CDsON() and Target:IsBursting()) then
                               return S.SmokeBomb:Cast()
         end
			end
			   end
    -- # Lowest priority in all of the APL because it causes a GCD
    -- actions+=/arcane_torrent,if=energy.deficit>=15+energy.regen
    if S.ArcaneTorrent:IsReadyP("Melee") and Player:EnergyDeficitPredicted() > 15 + Player:EnergyRegen() then
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

    -- Shuriken Toss Out of Range
    if S.ShurikenToss:IsReady(30) and not Target:IsInRange(10) and not Player:IsStealthedP(true, true) and not Player:BuffP(S.Sprint)
            and Player:EnergyDeficitPredicted() < 20 and (Player:ComboPointsDeficit() >= 1 or Player:EnergyTimeToMax() <= 1.2) then
        return S.ShurikenToss:Cast()
    end
    -- Trick to take in consideration the Recovery Setting
    return 0, 135328
end
			
			       --if not Target:IsImmune() and Target:IsBursting() and Target:IsDisarmable() and WRArms.Disarm:IsReady("Melee") then
           -- return Disarm:Cast()
      -- end



RubimRH.Rotation.SetAPL(261, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(261, PASSIVE);
