local addonName, addonTable = ...;
local AC = AethysCore;
local Cache = AethysCache;
local Unit = AC.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = AC.Spell;
local Item = AC.Item;
-- AethysRotation
-- Lua
local pairs = pairs;
local tableinsert = table.insert;

-- Spells
if not Spell.Rogue then
    Spell.Rogue = {};
end
Spell.Rogue.Subtlety = {
    -- Racials
    ArcanePulse = Spell(260364),
    ArcaneTorrent = Spell(50613),
    Berserking = Spell(26297),
    BloodFury = Spell(20572),
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
    SharpenedBladesBuff = Spell(272916),
    -- Defensive
    CrimsonVial = Spell(185311),
    Feint = Spell(1966),
    -- Utility
    Blind = Spell(2094),
    CheapShot = Spell(1833),
    Kick = Spell(1766),
    KidneyShot = Spell(408),
    Sprint = Spell(2983),
};
local S = Spell.Rogue.Subtlety;

local Stealth, VanishBuff

-- cp_max_spend
local function CPMaxSpend()
    -- Should work for all 3 specs since they have same Deeper Stratagem Spell ID.
    return Spell.Rogue.Subtlety.DeeperStratagem:IsAvailable() and 6 or 5;
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

local function CPMaxSpend()
    -- Should work for all 3 specs since they have same Deeper Stratagem Spell ID.
    return Spell.Rogue.Subtlety.DeeperStratagem:IsAvailable() and 6 or 5;
end

local function IsInMeleeRange()
    return Target:IsInRange("Melee") and true or false;
end

local function ShD_Threshold ()
    return S.ShadowDance:ChargesFractional() >= 1.75
end

local function CDs()
    if IsInMeleeRange() then
        if RubimRH.CDsON() then
            -- Racials
            if Player:IsStealthed(true, false) then
                -- actions.cds+=/blood_fury,if=stealthed.rogue
                if S.BloodFury:IsCastable() then
                    return RubimRH.nS
                end
                -- actions.cds+=/berserking,if=stealthed.rogue
                if S.Berserking:IsCastable() then
                    return RubimRH.nS
                end
            end
        end

        -- actions.cds+=/symbols_of_death
        if S.SymbolsofDeath:IsCastable() then
            return S.SymbolsofDeath:ID()
        end
        if RubimRH.CDsON() then
            -- actions.cds+=/marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit
            -- Note: Done at the start of the Rotation (Rogue Commmon)
            -- actions.cds+=/marked_for_death,if=raid_event.adds.in>30&!stealthed.all&combo_points.deficit>=cp_max_spend
            if S.MarkedforDeath:IsCastable() and not Player:IsStealthed(true, true) and Player:ComboPointsDeficit() >= CPMaxSpend() then
                return S.MarkedforDeath:ID()
            end
            -- actions.cds+=/shadow_blades,if=combo_points.deficit>=2+stealthed.all
            if S.ShadowBlades:IsCastable() and not Player:Buff(S.ShadowBlades)
                    and Player:ComboPointsDeficit() >= 2 + num(Player:IsStealthed(true, true)) then
                return S.ShadowBlades:ID()
            end
            -- actions.cds+=/shuriken_tornado,if=spell_targets>=3&dot.nightblade.ticking&buff.symbols_of_death.up&buff.shadow_dance.up
            if S.ShurikenTornado:IsCastableP() and Cache.EnemiesCount[10] >= 3 and Target:DebuffP(S.Nightblade) and Player:BuffP(S.SymbolsofDeath) and Player:BuffP(S.ShadowDanceBuff) then
                return S.ShurikenTornado:ID()
            end
            -- actions.cds+=/shadow_dance,if=!buff.shadow_dance.up&target.time_to_die<=5+talent.subterfuge.enabled
            if S.ShadowDance:IsReady() and not Player:BuffP(S.ShadowDanceBuff) and Target:FilteredTimeToDie("<=", 5 + num(S.Subterfuge:IsAvailable())) then
                return S.ShadowDance:ID()
            end
        end
    end
end

local function stealth_cds()
    -- actions.stealth_cds+=/vanish,if=!variable.shd_threshold&debuff.find_weakness.remains<1
    if RubimRH.CDsON() and S.Vanish:IsCastable() and S.ShadowDance:TimeSinceLastDisplay() > 0.3 and S.Shadowmeld:TimeSinceLastDisplay() > 0.3 and not Player:IsTanking(Target)
            and not ShD_Threshold() and Target:DebuffRemainsP(S.FindWeaknessDebuff) < 1 then
        return S.Vanish:ID()
    end

    -- actions.stealth_cds+=/pool_resource,for_next=1,extra_amount=40
    -- actions.stealth_cds+=/shadowmeld,if=energy>=40&energy.deficit>=10&!variable.shd_threshold&debuff.find_weakness.remains<1
    -- # With Dark Shadow only Dance when Nightblade will stay up. Use during Symbols or above threshold.
    -- actions.stealth_cds+=/shadow_dance,if=(!talent.dark_shadow.enabled|dot.nightblade.remains>=5+talent.subterfuge.enabled)&(variable.shd_threshold|buff.symbols_of_death.remains>=1.2|spell_targets>=4&-- cooldown.symbols_of_death.remains>10)
    if (RubimRH.CDsON() and S.ShadowDance:IsReady()) and (S.Vanish:TimeSinceLastDisplay() > 0.3
            and S.ShadowDance:TimeSinceLastDisplay() ~= 0 and S.Shadowmeld:TimeSinceLastDisplay() > 0.3 and S.ShadowDance:Charges() >= 1
            and (not S.DarkShadow:IsAvailable() or Target:DebuffRemainsP(S.Nightblade) >= 5 + num(S.Subterfuge:IsAvailable()))
            and (ShD_Threshold() or Player:BuffRemainsP(S.SymbolsofDeath) >= 1.2 or (Cache.EnemiesCount[10] >= 4 and S.SymbolsofDeath:CooldownRemainsP() > 10))) then
        return S.ShadowDance:ID()
    end
    -- actions.stealth_cds+=/shadow_dance,if=target.time_to_die<cooldown.symbols_of_death.remains
    if (RubimRH.CDsON() and S.ShadowDance:IsReady()) and (S.Vanish:TimeSinceLastDisplay() > 0.3
            and S.ShadowDance:TimeSinceLastDisplay() ~= 0 and S.Shadowmeld:TimeSinceLastDisplay() > 0.3 and S.ShadowDance:Charges() >= 1
            and Target:TimeToDie() < S.SymbolsofDeath:CooldownRemainsP()) then
        return S.ShadowDance:ID()
    end
end

local function build()
    -- actions.build=shuriken_storm,if=spell_targets.shuriken_storm>=2
    if RubimRH.AoEON() and S.ShurikenStorm:IsCastableP() and Cache.EnemiesCount[10] >= 2 then
        return S.ShurikenStorm:ID()
    end
    -- actions.build=shuriken_toss,if=buff.sharpened_blades.stack>=19
    if S.ShurikenToss:IsCastableP() and (Player:BuffStackP(S.SharpenedBladesBuff) >= 19) then
        return S.ShurikenToss:ID()
    end
    if IsInMeleeRange() then
        -- actions.build+=/gloomblade
        if S.Gloomblade:IsCastable() then
            return 68971
            -- actions.build+=/backstab
        elseif S.Backstab:IsCastable() then
            return S.Backstab:ID()
        end
    end
end

local function finish()
    local ShadowDanceBuff = Player:BuffP(S.ShadowDanceBuff)
    -- actions.finish=nightblade,if=(!talent.dark_shadow.enabled|!buff.shadow_dance.up)&target.time_to_die-remains>6&remains<tick_time*2&(spell_targets.shuriken_storm<4|!buff.symbols_of_death.up)
    if IsInMeleeRange() and (not S.DarkShadow:IsAvailable() or not ShadowDanceBuff)
            and (Target:FilteredTimeToDie(">", 6, -Target:DebuffRemainsP(S.Nightblade)) or Target:TimeToDieIsNotValid())
            and Target:DebuffRemainsP(S.Nightblade) < 4
            and (Cache.EnemiesCount[10] < 4 or not Player:BuffP(S.SymbolsofDeath)) then
        return S.Nightblade:ID()
    end

    -- # Multidotting outside Dance on targets that will live for the duration of Nightblade with refresh during pandemic.
    -- actions.finish+=/nightblade,cycle_targets=1,if=spell_targets.shuriken_storm>=2&!buff.shadow_dance.up&target.time_to_die>=(5+(2*combo_points))&refreshable
    -- # Refresh Nightblade early if it will expire during Symbols. Do that refresh if SoD gets ready in the next 5s.
    -- actions.finish+=/nightblade,if=remains<cooldown.symbols_of_death.remains+10&cooldown.symbols_of_death.remains<=5&target.time_to_die-remains>cooldown.symbols_of_death.remains+5
    if IsInMeleeRange() and Target:DebuffRemainsP(S.Nightblade) < S.SymbolsofDeath:CooldownRemainsP() + 10
            and S.SymbolsofDeath:CooldownRemainsP() <= 5
            and (Target:FilteredTimeToDie(">", 5 + S.SymbolsofDeath:CooldownRemainsP(), -Target:DebuffRemainsP(S.Nightblade)) or Target:TimeToDieIsNotValid()) then
        return S.Nightblade:ID()

    end

    -- # Secret Technique during Symbols. With Dark Shadow and multiple targets also only during Shadow Dance (until threshold in next line).
    -- actions.finish+=/secret_technique,if=buff.symbols_of_death.up&(!talent.dark_shadow.enabled|spell_targets.shuriken_storm<2|buff.shadow_dance.up)
    if S.SecretTechnique:IsCastable() and Player:BuffP(S.SymbolsofDeath) and (not S.DarkShadow:IsAvailable() or Cache.EnemiesCount[10] < 2 or Player:BuffP(S.ShadowDanceBuff)) then
        return S.SecretTechnique:ID()
    end

    -- # With enough targets always use SecTec on CD.
    -- actions.finish+=/secret_technique,if=spell_targets.shuriken_storm>=2+talent.dark_shadow.enabled+talent.nightstalker.enabled
    if S.SecretTechnique:IsCastable() and Cache.EnemiesCount[10] >= 2 + num(S.DarkShadow:IsAvailable()) + num(S.Nightstalker:IsAvailable()) then
        return S.SecretTechnique:ID()

    end

    -- actions.finish+=/eviscerate
    if S.Eviscerate:IsCastable() and IsInMeleeRange() then
        return S.Eviscerate:ID()
    end

end

local function stealthed (ReturnSpellOnly, StealthSpell)
    local StealthBuff = Player:Buff(Stealth) or (StealthSpell and StealthSpell:ID() == Stealth:ID())
    -- # If stealth is up, we really want to use Shadowstrike to benefits from the passive bonus, even if we are at max cp (from the precombat MfD).
    -- actions.stealthed=shadowstrike,if=buff.stealth.up
    if StealthBuff and S.Shadowstrike:IsCastable() and (Target:IsInRange(S.Shadowstrike) or IsInMeleeRange()) then
        return S.Shadowstrike:ID()
    end
    -- actions.stealthed+=/call_action_list,name=finish,if=combo_points.deficit<=1-(talent.deeper_stratagem.enabled&buff.vanish.up)
    if finish() ~= nil and Player:ComboPointsDeficit() <= 1 - num(S.DeeperStratagem:IsAvailable() and Player:BuffP(VanishBuff)) then
        return finish()
    end
    -- actions.stealthed+=/shadowstrike,cycle_targets=1,if=talent.secret_technique.enabled&talent.find_weakness.enabled&debuff.find_weakness.remains<1&spell_targets.shuriken_storm=2&target.time_to_die-remains>6
    -- !!!NYI!!! (Is this worth it? How do we want to display it in an understandable way?)
    -- actions.stealthed+=/shuriken_storm,if=spell_targets.shuriken_storm>=3
    if RubimRH.AoEON() and S.ShurikenStorm:IsCastable() and Cache.EnemiesCount[10] >= 3 then
        return S.ShurikenStorm:ID()
    end
    -- actions.stealthed+=/shadowstrike
    if S.Shadowstrike:IsCastable() and (Target:IsInRange(S.Shadowstrike) or IsInMeleeRange()) then
        return S.Shadowstrike:ID()
    end
end

local function APL()
    AC.GetEnemies(10, true); -- Shuriken Storm & Death from Above
    AC.GetEnemies("Melee"); -- Melee

    if S.Subterfuge:IsAvailable() then
        Stealth = S.Stealth2;
        VanishBuff = S.VanishBuff2;
    else
        Stealth = S.Stealth;
        VanishBuff = S.VanishBuff;
    end

    if not Player:AffectingCombat() then

        --actions.precombat+=/variable,name=stealth_threshold,value=60+talent.vigor.enabled*35+talent.master_of_shadows.enabled*10
        -- actions.precombat+=/stealth
        if RubimRH.config.stealthOOC and Stealth:IsCastable() and not Player:IsStealthed() then
            return Stealth:ID()
        end

        -- actions.precombat+=/marked_for_death,precombat_seconds=15
        -- actions.precombat+=/shadow_blades,precombat_seconds=1
        -- actions.precombat+=/potion

        if RubimRH.TargetIsValid() and (Target:IsInRange(S.Shadowstrike) or IsInMeleeRange()) then
            if Player:IsStealthed(true, true) and stealthed ~= nil then
                return stealthed()
            elseif Player:ComboPoints() >= 5 and finish() ~= nil then
                return finish()()
            elseif S.Backstab:IsCastable() then
                return S.Backstab:ID()
            end
        end

        return 0, 462338
    end

    -- # Check CDs at first
    -- actions=call_action_list,name=cds
    if RubimRH.CDsON() and CDs() ~= nil then
        return CDs()
    end

    -- actions+=/run_action_list,name=stealthed,if=stealthed.all
    if Player:IsStealthed(true, true) then
        if stealthed() ~= nil then
            return stealthed()
        end
    end

    -- actions+=/nightblade,if=target.time_to_die>6&remains<gcd.max&combo_points>=4-(time<10)*2
    if S.Nightblade:IsCastableP() and IsInMeleeRange()
            and (Target:FilteredTimeToDie(">", 6) or Target:TimeToDieIsNotValid())
            and Target:DebuffRemainsP(S.Nightblade) < Player:GCD() and Player:ComboPoints() >= 4 - (AC.CombatTime() < 10 and 2 or 0) then
        return RubimRH.nS
    end

    -- actions+=/call_action_list,name=stealth_cds,if=energy.deficit<=variable.stealth_threshold&combo_points.deficit>=4
    if (Player:EnergyDeficit() <= Stealth_Threshold() and Player:ComboPointsDeficit() >= 4) and stealth_cds() ~= nil then
            return stealth_cds()
    end

    -- actions+=/call_action_list,name=finish,if=combo_points>=4+talent.deeper_stratagem.enabled|target.time_to_die<=1&combo_points>=3
    if finish() ~= nil and Player:ComboPoints() >= 4 + num(S.DeeperStratagem:IsAvailable())
            or (Target:FilteredTimeToDie("<=", 1) and Player:ComboPoints() >= 3) then
        return finish()
    end

    -- actions+=/call_action_list,name=build,if=energy.deficit<=variable.stealth_threshold-40*!(talent.alacrity.enabled|talent.shadow_focus.enabled|talent.master_of_shadows.enabled)
    if build() ~= nil and Player:EnergyDeficitPredicted() <= Stealth_Threshold() - 40 * num(not (S.Alacrity:IsAvailable() or S.ShadowFocus:IsAvailable() or S.MasterofShadows:IsAvailable())) then
        return build()
    end

    -- actions+=/arcane_torrent,if=energy.deficit>=15+energy.regen
    if S.ArcaneTorrent:IsCastable() and Player:EnergyDeficitPredicted() > 15 + Player:EnergyRegen() then
        return RubimRH.nS
    end
    -- actions+=/arcane_pulse
    if S.ArcanePulse:IsCastableP() and IsInMeleeRange() then
        return RubimRH.nS
    end
    return 0, 975743
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
