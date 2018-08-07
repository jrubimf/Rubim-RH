local addonName, addonTable = ...;
local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;
-- Lua
local pairs = pairs;
local tableinsert = table.insert;
local mathmin = math.min;

-- Spells
RubimRH.Spell[261] = {
    Vigor = Spell(14983),
    MasterofShadows = Spell(196976),
    StealthBuff = Spell(1784),
    Stealth = Spell(1784),
    MarkedForDeath = Spell(137619),
    ShadowBladesBuff = Spell(121471),
    ShadowBlades = Spell(121471),
    ShurikenStorm = Spell(197835),
    TheDreadlordsDeceitBuff = Spell(208692),
    Gloomblade = Spell(200758),
    Backstab = Spell(53),
    VanishBuff = Spell(1856),
    BloodFury = Spell(20572),
    Berserking = Spell(26297),
    SymbolsofDeath = Spell(212283),
    NightbladeDebuff = Spell(195452),
    ShurikenTornado = Spell(277925),
    SymbolsofDeathBuff = Spell(212283),
    ShadowDanceBuff = Spell(185313),
    ShadowDance = Spell(185313),
    Subterfuge = Spell(108208),
    Nightblade = Spell(195452),
    DarkShadow = Spell(245687),
    SecretTechnique = Spell(280719),
    Nightstalker = Spell(14062),
    Eviscerate = Spell(196819),
    Vanish = Spell(1856),
    FindWeaknessDebuff = Spell(91021),
    Shadowmeld = Spell(58984),
    Shadowstrike = Spell(185438),
    DeeperStratagem = Spell(193531),
    Alacrity = Spell(193539),
    ShadowFocus = Spell(108209),
    ArcaneTorrent = Spell(50613),
    ArcanePulse = Spell(260364),
    LightsJudgment = Spell(255647),
    Riposte = Spell(199754),
    CloakofShadows = Spell(31224),
    CrimsonVial = Spell(185311),
    Feint = Spell(1966),
};
local S = RubimRH.Spell[261]

local Stealth, VanishBuff

local function CPMaxSpend()
    -- Should work for all 3 specs since they have same Deeper Stratagem Spell ID.
    return RubimRH.Spell[261].DeeperStratagem:IsAvailable() and 6 or 5;
end

-- "cp_spend"
local function CPSpend()
    return mathmin(Player:ComboPoints(), CPMaxSpend());
end

local function num(val)
    if val then
        return 1
    else
        return 0
    end
end

local function Stealth_Threshold()
    return 60 + num(S.Vigor:IsAvailable()) * 35 + num(S.MasterofShadows:IsAvailable()) * 10;
end

local function IsInMeleeRange()
    return Target:IsInRange("Melee") and true or false;
end

local function ShD_Threshold ()
    return S.ShadowDance:ChargesFractional() >= 1.75
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
                    1.33 *
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

-- actions.precombat+=/variable,name=stealth_threshold,value=60+talent.vigor.enabled*35+talent.master_of_shadows.enabled*10
local function Stealth_Threshold ()
    return 60 + num(S.Vigor:IsAvailable()) * 35 + num(S.MasterofShadows:IsAvailable()) * 10;
end
-- actions.stealth_cds=variable,name=shd_threshold,value=cooldown.shadow_dance.charges_fractional>=1.75
local function ShD_Threshold ()
    return S.ShadowDance:ChargesFractional() >= 1.75
end

VarStealthThreshold = 0;
local VarShdThreshold = 0;

local EnemyRanges = { 10, 15 }
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

local function bool(val)
    return val ~= 0
end

local OffensiveCDs = {
    S.ShadowBlades,
    S.Vanish,
}

local function UpdateCDs()
    if RubimRH.config.cooldown then
        for i, spell in pairs(OffensiveCDs) do
            if not spell:IsEnabledCD() then
                RubimRH.delSpellDisabledCD(spell:ID())
            end
        end

    end
    if not RubimRH.config.cooldown then
        for i, spell in pairs(OffensiveCDs) do
            if spell:IsEnabledCD() then
                RubimRH.addSpellDisabledCD(spell:ID())
            end
        end
    end
end

local function APL()
    local Precombat, Build, Cds, Finish, StealthCds, Stealthed
    UpdateRanges()
    UpdateCDs()

    Precombat = function()
        -- flask
        -- augmentation
        -- food
        -- snapshot_stats
        -- variable,name=stealth_threshold,value=60+talent.vigor.enabled*35+talent.master_of_shadows.enabled*10
        if (true) then
            VarStealthThreshold = 60 + num(S.Vigor:IsAvailable()) * 35 + num(S.MasterofShadows:IsAvailable()) * 10
        end
        -- stealth
        if S.Stealth:IsReady() and Player:BuffDownP(S.StealthBuff) and (true) then
            return S.Stealth:Cast()
        end
        -- marked_for_death,precombat_seconds=15
        if S.MarkedForDeath:IsReady() and (true) then
            return S.MarkedForDeath:Cast()
        end
        -- shadow_blades,precombat_seconds=1
        --if S.ShadowBlades:IsReady() and Player:BuffDownP(S.ShadowBladesBuff) and (true) then
            --return S.ShadowBlades:Cast()
        --end

        if IsStealthed() then
            return Stealthed();
        end
    end

    Build = function()
        -- shuriken_storm,if=spell_targets.shuriken_storm>=2|buff.the_dreadlords_deceit.stack>=29
        if S.ShurikenStorm:IsReady() and (Cache.EnemiesCount[10] >= 2 or Player:BuffStack(S.TheDreadlordsDeceitBuff) >= 29) then
            return S.ShurikenStorm:Cast()
        end
        -- gloomblade
        if S.Gloomblade:IsReady() and (true) then
            return S.Gloomblade:Cast()
        end
        -- backstab
        if S.Backstab:IsReady() and (true) then
            return S.Backstab:Cast()
        end
    end
    Cds = function()
        -- potion,if=buff.bloodlust.react|target.time_to_die<=60|(buff.vanish.up&(buff.shadow_blades.up|cooldown.shadow_blades.remains<=30))
        -- blood_fury,if=stealthed.rogue
        if S.BloodFury:IsReady() and RubimRH.CDsON() and (bool(IsStealthed())) then
            return S.BloodFury:Cast()
        end
        -- berserking,if=stealthed.rogue
        if S.Berserking:IsReady() and RubimRH.CDsON() and (bool(IsStealthed())) then
            return S.Berserking:Cast()
        end
        -- symbols_of_death,if=dot.nightblade.ticking
        if S.SymbolsofDeath:IsReady() and (Target:Debuff(S.NightbladeDebuff)) then
            return S.SymbolsofDeath:Cast()
        end
        -- marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit
        if S.MarkedForDeath:IsReady() and (Target:TimeToDie() < Player:ComboPointsDeficit()) then
            return S.MarkedForDeath:Cast()
        end
        -- marked_for_death,if=raid_event.adds.in>30&!stealthed.all&combo_points.deficit>=cp_max_spend
        if not RubimRH.AoEON() and S.MarkedForDeath:IsReady() and (not bool(IsStealthed()) and Player:ComboPointsDeficit() >= CPMaxSpend()) then
            return S.MarkedForDeath:Cast()
        end
        -- shadow_blades,if=combo_points.deficit>=2+stealthed.all
        if S.ShadowBlades:IsReady() and (Player:ComboPointsDeficit() >= 2 + num(IsStealthed())) then
            return S.ShadowBlades:Cast()
        end
        -- shuriken_tornado,if=spell_targets>=3&dot.nightblade.ticking&buff.symbols_of_death.up&buff.shadow_dance.up
        if S.ShurikenTornado:IsReady() and (Cache.EnemiesCount[15] >= 3 and Target:Debuff(S.NightbladeDebuff) and Player:Buff(S.SymbolsofDeathBuff) and Player:Buff(S.ShadowDanceBuff)) then
            return S.ShurikenTornado:Cast()
        end
        -- shadow_dance,if=!buff.shadow_dance.up&target.time_to_die<=5+talent.subterfuge.enabled
        if S.ShadowDance:IsReady() and (not Player:Buff(S.ShadowDanceBuff) and Target:TimeToDie() <= 5 + num(S.Subterfuge:IsAvailable())) then
            return S.ShadowDance:Cast()
        end
    end
    Finish = function()
        -- nightblade,if=(!talent.dark_shadow.enabled|!buff.shadow_dance.up)&target.time_to_die-remains>6&remains<tick_time*2&(spell_targets.shuriken_storm<4|!buff.symbols_of_death.up)
        if S.Nightblade:IsReady() and ((not S.DarkShadow:IsAvailable() or not Player:Buff(S.ShadowDanceBuff)) and Target:TimeToDie() - Target:DebuffRemains(S.NightbladeDebuff) > 6 and Target:DebuffRemains(S.NightbladeDebuff) < S.NightbladeDebuff:TickTime() * 2 and (Cache.EnemiesCount[10] < 4 or not Player:Buff(S.SymbolsofDeathBuff))) then
            return S.Nightblade:Cast()
        end
        -- nightblade,cycle_targets=1,if=spell_targets.shuriken_storm>=2&(spell_targets.shuriken_storm<=5|talent.secret_technique.enabled)&!buff.shadow_dance.up&target.time_to_die>=(5+(2*combo_points))&refreshable
        if S.Nightblade:IsReady() and (Cache.EnemiesCount[10] >= 2 and (Cache.EnemiesCount[10] <= 5 or S.SecretTechnique:IsAvailable()) and not Player:Buff(S.ShadowDanceBuff) and Target:TimeToDie() >= (5 + (2 * Player:ComboPoints())) and Target:DebuffRefreshableC(S.NightbladeDebuff)) then
            return S.Nightblade:Cast()
        end
        -- nightblade,if=remains<cooldown.symbols_of_death.remains+10&cooldown.symbols_of_death.remains<=5&target.time_to_die-remains>cooldown.symbols_of_death.remains+5
        if S.Nightblade:IsReady() and (Target:DebuffRemains(S.NightbladeDebuff) < S.SymbolsofDeath:CooldownRemains() + 10 and S.SymbolsofDeath:CooldownRemains() <= 5 and Target:TimeToDie() - Target:DebuffRemains(S.NightbladeDebuff) > S.SymbolsofDeath:CooldownRemains() + 5) then
            return S.Nightblade:Cast()
        end
        -- secret_technique,if=buff.symbols_of_death.up&(!talent.dark_shadow.enabled|spell_targets.shuriken_storm<2|buff.shadow_dance.up)
        if S.SecretTechnique:IsReady() and (Player:Buff(S.SymbolsofDeathBuff) and (not S.DarkShadow:IsAvailable() or Cache.EnemiesCount[10] < 2 or Player:Buff(S.ShadowDanceBuff))) then
            return S.SecretTechnique:Cast()
        end
        -- secret_technique,if=spell_targets.shuriken_storm>=2+talent.dark_shadow.enabled+talent.nightstalker.enabled
        if S.SecretTechnique:IsReady() and (Cache.EnemiesCount[10] >= 2 + num(S.DarkShadow:IsAvailable()) + num(S.Nightstalker:IsAvailable())) then
            return S.SecretTechnique:Cast()
        end
        -- eviscerate
        if S.Eviscerate:IsReady() and (true) then
            return S.Eviscerate:Cast()
        end
    end
    StealthCds = function()
        -- variable,name=shd_threshold,value=cooldown.shadow_dance.charges_fractional>=1.75
        if (true) then
            VarShdThreshold = num(S.ShadowDance:ChargesFractional() >= 1.75)
        end
        -- vanish,if=!variable.shd_threshold&debuff.find_weakness.remains<1
        if S.Vanish:IsReady() and (not bool(VarShdThreshold) and Target:DebuffRemains(S.FindWeaknessDebuff) < 1) then
            return S.Vanish:Cast()
        end
        -- pool_resource,for_next=1,extra_amount=40
        -- shadowmeld,if=energy>=40&energy.deficit>=10&!variable.shd_threshold&debuff.find_weakness.remains<1
        if S.Shadowmeld:IsReady() and (Player:Energy() >= 40 and Player:EnergyDeficit() >= 10 and not bool(VarShdThreshold) and Target:DebuffRemains(S.FindWeaknessDebuff) < 1) then
            if S.Shadowmeld:IsUsablePPool(40) then
                return S.Shadowmeld:Cast()
            else
                return S.PoolResource:Cast()
            end
        end
        -- shadow_dance,if=(!talent.dark_shadow.enabled|dot.nightblade.remains>=5+talent.subterfuge.enabled)&(variable.shd_threshold|buff.symbols_of_death.remains>=1.2|spell_targets>=4&cooldown.symbols_of_death.remains>10)
        if S.ShadowDance:IsReady() and ((not S.DarkShadow:IsAvailable() or Target:DebuffRemains(S.NightbladeDebuff) >= 5 + num(S.Subterfuge:IsAvailable())) and (bool(VarShdThreshold) or Player:BuffRemains(S.SymbolsofDeathBuff) >= 1.2 or Cache.EnemiesCount[15] >= 4 and S.SymbolsofDeath:CooldownRemains() > 10)) then
            return S.ShadowDance:Cast()
        end
        -- shadow_dance,if=target.time_to_die<cooldown.symbols_of_death.remains
        if S.ShadowDance:IsReady() and (Target:TimeToDie() < S.SymbolsofDeath:CooldownRemains()) then
            return S.ShadowDance:Cast()
        end
    end
    Stealthed = function()
        -- shadowstrike,if=buff.stealth.up
        if S.Shadowstrike:IsReady() and (IsStealthed()) then
            return S.Shadowstrike:Cast()
        end
        -- call_action_list,name=finish,if=combo_points.deficit<=1-(talent.deeper_stratagem.enabled&buff.vanish.up)
        if (Player:ComboPointsDeficit() <= 1 - num((S.DeeperStratagem:IsAvailable() and Player:Buff(S.VanishBuff)))) then
            if Finish() ~= nil then
                return Finish()
            end
        end
        -- shadowstrike,cycle_targets=1,if=talent.secret_technique.enabled&talent.find_weakness.enabled&debuff.find_weakness.remains<1&spell_targets.shuriken_storm=2&target.time_to_die-remains>6
        if S.Shadowstrike:IsReady() and (S.SecretTechnique:IsAvailable() and S.FindWeakness:IsAvailable() and Target:DebuffRemains(S.FindWeaknessDebuff) < 1 and Cache.EnemiesCount[10] == 2 and Target:TimeToDie() - remains > 6) then
            return S.Shadowstrike:Cast()
        end
        -- shuriken_storm,if=spell_targets.shuriken_storm>=3
        if S.ShurikenStorm:IsReady() and (Cache.EnemiesCount[10] >= 3) then
            return S.ShurikenStorm:Cast()
        end
        -- shadowstrike
        if S.Shadowstrike:IsReady() and (true) then
            return S.Shadowstrike:Cast()
        end
    end
    -- call precombat
    if not Player:AffectingCombat() then
        if Precombat() ~= nil then
            return Precombat()
        end
        return 0, 462338
    end
    -- call_action_list,name=cds
    if (true) then
        if Cds() ~= nil then
            return Cds()
        end
    end
    -- run_action_list,name=stealthed,if=stealthed.all
    if IsStealthed() then
        return Stealthed();
    end
    -- nightblade,if=target.time_to_die>6&remains<gcd.max&combo_points>=4-(time<10)*2
    if S.Nightblade:IsReady() and (Target:TimeToDie() > 6 and Target:DebuffRemains(S.NightbladeDebuff) < Player:GCD() and Player:ComboPoints() >= 4 - num((HL.CombatTime() < 10)) * 2) then
        return S.Nightblade:Cast()
    end
    -- call_action_list,name=stealth_cds,if=energy.deficit<=variable.stealth_threshold&combo_points.deficit>=4
    if (Player:EnergyDeficit() <= VarStealthThreshold and Player:ComboPointsDeficit() >= 4) then
        if StealthCds() ~= nil then
            return StealthCds()
        end
    end
    -- call_action_list,name=finish,if=combo_points>=4+talent.deeper_stratagem.enabled|target.time_to_die<=1&combo_points>=3
    if (Player:ComboPoints() >= 4 + num(S.DeeperStratagem:IsAvailable()) or Target:TimeToDie() <= 1 and Player:ComboPoints() >= 3) then
        if Finish() ~= nil then
            return Finish()
        end
    end
    -- call_action_list,name=build,if=energy.deficit<=variable.stealth_threshold-40*!(talent.alacrity.enabled|talent.shadow_focus.enabled|talent.master_of_shadows.enabled)
    if (Player:EnergyDeficit() <= VarStealthThreshold - 40 * num(not (S.Alacrity:IsAvailable() or S.ShadowFocus:IsAvailable() or S.MasterofShadows:IsAvailable()))) then
        if Build() ~= nil then
            return Build()
        end
    end
    -- arcane_torrent,if=energy.deficit>=15+energy.regen
    if S.ArcaneTorrent:IsReady() and RubimRH.CDsON() and (Player:EnergyDeficit() >= 15 + Player:EnergyRegen()) then
        return S.ArcaneTorrent:Cast()
    end
    -- arcane_pulse
    if S.ArcanePulse:IsReady() and (true) then
        return S.ArcanePulse:Cast()
    end
    -- lights_judgment
    if S.LightsJudgment:IsReady() and RubimRH.CDsON() and (true) then
        return S.LightsJudgment:Cast()
    end
    return 0, 135328
end

RubimRH.Rotation.SetAPL(261, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(261, PASSIVE);
--
-- # Cooldowns
-- actions.cds=potion,if=buff.bloodlust.react|target.time_to_die<=60|(buff.vanish.up&(buff.shadow_blades.up|cooldown.shadow_blades.remains<=30))
-- actions.cds+=/blood_fury,if=stealthed.rogue
-- actions.cds+=/berserking,if=stealthed.rogue
-- actions.cds+=/lights_judgment,if=stealthed.rogue
-- actions.cds+=/symbols_of_death,if=dot.nightblade.ticking
-- actions.cds+=/marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit
-- actions.cds+=/marked_for_death,if=raid_event.adds.in>30&!stealthed.all&combo_points.deficit>=cp_max_spend
-- actions.cds+=/shadow_blades,if=combo_points.deficit>=2+stealthed.all
-- actions.cds+=/shuriken_tornado,if=spell_targets>=3&dot.nightblade.ticking&buff.symbols_of_death.up&buff.shadow_dance.up
-- actions.cds+=/shadow_dance,if=!buff.shadow_dance.up&target.time_to_die<=5+talent.subterfuge.enabled
--
-- # Stealth Cooldowns
-- # Helper Variable
-- actions.stealth_cds=variable,name=shd_threshold,value=cooldown.shadow_dance.charges_fractional>=1.75
-- # Vanish unless we are about to cap on Dance charges. Only when Find Weakness is about to run out.
-- actions.stealth_cds+=/vanish,if=!variable.shd_threshold&debuff.find_weakness.remains<1
-- # Pool for Shadowmeld + Shadowstrike unless we are about to cap on Dance charges. Only when Find Weakness is about to run out.
-- actions.stealth_cds+=/pool_resource,for_next=1,extra_amount=40
-- actions.stealth_cds+=/shadowmeld,if=energy>=40&energy.deficit>=10&!variable.shd_threshold&debuff.find_weakness.remains<1
-- # With Dark Shadow only Dance when Nightblade will stay up. Use during Symbols or above threshold.
-- actions.stealth_cds+=/shadow_dance,if=(!talent.dark_shadow.enabled|dot.nightblade.remains>=5+talent.subterfuge.enabled)&(variable.shd_threshold|buff.symbols_of_death.remains>=1.2|spell_targets>=4&-- cooldown.symbols_of_death.remains>10)
-- actions.stealth_cds+=/shadow_dance,if=target.time_to_die<cooldown.symbols_of_death.remains
--
-- # Stealthed Rotation
-- # If stealth is up, we really want to use Shadowstrike to benefits from the passive bonus, even if we are at max cp (from the precombat MfD).
-- actions.stealthed=shadowstrike,if=buff.stealth.up
-- # Finish at 4+ CP without DS, 5+ with DS, and 6 with DS after Vanish
-- actions.stealthed+=/call_action_list,name=finish,if=combo_points.deficit<=1-(talent.deeper_stratagem.enabled&buff.vanish.up)
-- # At 2 targets with Secret Technique keep up Find Weakness by cycling Shadowstrike.
-- actions.stealthed+=/shadowstrike,cycle_targets=1,if=talent.secret_technique.enabled&talent.find_weakness.enabled&debuff.find_weakness.remains<1&spell_targets.shuriken_storm=2&target.time_to_die-remains>6
-- actions.stealthed+=/shuriken_storm,if=spell_targets.shuriken_storm>=3
-- actions.stealthed+=/shadowstrike
--
-- # Finishers
-- # Keep up Nightblade if it is about to run out. Do not use NB during Dance, if talented into Dark Shadow.
-- actions.finish=nightblade,if=(!talent.dark_shadow.enabled|!buff.shadow_dance.up)&target.time_to_die-remains>6&remains<tick_time*2&(spell_targets.shuriken_storm<4|!buff.symbols_of_death.up)
-- # Multidotting outside Dance on targets that will live for the duration of Nightblade with refresh during pandemic.
-- actions.finish+=/nightblade,cycle_targets=1,if=spell_targets.shuriken_storm>=2&!buff.shadow_dance.up&target.time_to_die>=(5+(2*combo_points))&refreshable
-- # Refresh Nightblade early if it will expire during Symbols. Do that refresh if SoD gets ready in the next 5s.
-- actions.finish+=/nightblade,if=remains<cooldown.symbols_of_death.remains+10&cooldown.symbols_of_death.remains<=5&target.time_to_die-remains>cooldown.symbols_of_death.remains+5
-- # Secret Technique during Symbols. With Dark Shadow and multiple targets also only during Shadow Dance (until threshold in next line).
-- actions.finish+=/secret_technique,if=buff.symbols_of_death.up&(!talent.dark_shadow.enabled|spell_targets.shuriken_storm<2|buff.shadow_dance.up)
-- # With enough targets always use SecTec on CD.
-- actions.finish+=/secret_technique,if=spell_targets.shuriken_storm>=2+talent.dark_shadow.enabled+talent.nightstalker.enabled
-- actions.finish+=/eviscerate
--
-- # Builders
-- actions.build=shuriken_storm,if=spell_targets.shuriken_storm>=2
-- #actions.build+=/shuriken_toss,if=buff.sharpened_blades.stack>=39
-- actions.build+=/gloomblade
-- actions.build+=/backstab