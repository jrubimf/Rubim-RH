--- ============================ HEADER ============================
local RubimRH = LibStub("AceAddon-3.0"):GetAddon("RubimRH")
local addonName, addonTable = ...;
local AC = AethysCore;
local Cache = AethysCache;
local Unit = AC.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = AC.Spell;
local Item = AC.Item;


local activeUnitPlates = {}

-- Spells
if not Spell.Rogue then
    Spell.Rogue = {};
end
Spell.Rogue.Assassination = {
    -- Racials
    ArcaneTorrent = Spell(25046),
    Berserking = Spell(26297),
    Blindside = Spell(22339),
    BloodFury = Spell(20572),
    GiftoftheNaaru = Spell(59547),
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
    Alacrity = Spell(193539),
    AlacrityBuff = Spell(193538),
    Anticipation = Spell(114015),
    CrimsonTempest = Spell(23174),
    DeathfromAbove = Spell(152150),
    DeeperStratagem = Spell(193531),
    ElaboratePlanning = Spell(193640),
    ElaboratePlanningBuff = Spell(193641),
    Exsanguinate = Spell(200806),
    HiddenBlades = Spell(22133),
    Hemorrhage = Spell(16511),
    InternalBleeding = Spell(154953),
    MarkedforDeath = Spell(137619),
    MasterPoisoner = Spell(196864),
    Nightstalker = Spell(14062),
    ShadowFocus = Spell(108209),
    Subterfuge = Spell(108208),
    ToxicBlade = Spell(245388),
    ToxicBladeDebuff = Spell(245389),
    VenomRush = Spell(152152),
    Vigor = Spell(14983),
    -- Artifact
    AssassinsBlades = Spell(214368),
    Kingsbane = Spell(192759),
    MasterAssassin = Spell(192349),
    PoisonKnives = Spell(192376),
    SilenceoftheUncrowned = Spell(241152),
    SinisterCirculation = Spell(238138),
    SlayersPrecision = Spell(214928),
    SurgeofToxins = Spell(192425),
    ToxicBlades = Spell(192310),
    UrgetoKill = Spell(192384),
    -- Defensive
    CrimsonVial = Spell(185311),
    Feint = Spell(1966),
    -- Utility
    Blind = Spell(2094),
    Kick = Spell(1766),
    PickPocket = Spell(921),
    Sprint = Spell(2983),
    -- Poisons
    CripplingPoison = Spell(3408),
    DeadlyPoison = Spell(2823),
    DeadlyPoisonDebuff = Spell(2818),
    LeechingPoison = Spell(108211),
    WoundPoison = Spell(8679),
    WoundPoisonDebuff = Spell(8680),
    -- Legendaries
    DreadlordsDeceit = Spell(228224),
    -- Tier
    MutilatedFlesh = Spell(211672),
    VirulentPoisons = Spell(252277),
    -- Misc
    PoolEnergy = Spell(9999000010)
};
local S = Spell.Rogue.Assassination;

if not Item.Rogue then
    Item.Rogue = {};
end
Item.Rogue.Assassination = {
    -- Legendaries
    DuskwalkersFootpads = Item(137030, { 8 }),
    InsigniaofRavenholdt = Item(137049, { 11, 12 }),
    MantleoftheMasterAssassin = Item(144236, { 3 }),
    ZoldyckFamilyTrainingShackles = Item(137098, { 9 }),
    -- Trinkets
    ConvergenceofFates = Item(140806, { 13, 14 }),
    DraughtofSouls = Item(140808, { 13, 14 }),
    KiljaedensBurningWish = Item(144259, { 13, 14 }),
    SpecterofBetrayal = Item(151190, { 13, 14 }),
    UmbralMoonglaives = Item(147012, { 13, 14 }),
    VialofCeaselessToxins = Item(147011, { 13, 14 }),
};
local I = Item.Rogue.Assassination;

local T202PC, T204PC = AC.HasTier("T20");
local T212PC, T214PC = AC.HasTier("T21");
local Stealth
local energyCombined
local poisonedBleedCount
local BleedTickTime, ExsanguinatedBleedTickTime = 2, 2 / (1 + 1.5);

S.Mutilate:RegisterDamage(
        function ()
            -- TODO: Implement most of those thing in the core.
            local minDamage, maxDamage, minOffHandDamage, maxOffHandDamage, physicalBonusPos, physicalBonusNeg, percent = UnitDamage("player");
            local speed, offhandSpeed = UnitAttackSpeed("player");
            local wSpeed = speed * (1 + Player:HastePct()/100);
            local AvgWpnDmg = (minDamage + maxDamage) / 2 / wSpeed / percent - (Player:AttackPower() / 3.5);
            return
            -- (Average Weapon Damage [Weapon DPS * Swing Speed] + (Attack Power * NormalizedWeaponSpeed / 3.5)) * (MH Factor +OH Factor)
            (AvgWpnDmg * wSpeed + (Player:AttackPower() * 1.7 / 3.5)) * 1.5 *
                    -- Mutilate Coefficient
                    3.6 *
                    -- Assassin's Resolve (SpellID: 84601)
                    1.17 *
                    -- Aura Multiplier (SpellID: 137037)
                    1.28 *
                    -- Assassin's Blades Multiplier
                    (S.AssassinsBlades:ArtifactEnabled() and 1.15 or 1) *
                    -- Versatility Damage Multiplier
                    (1 + Player:VersatilityDmgPct()/100) *
                    -- Slayer's Precision Multiplier
                    (S.SlayersPrecision:ArtifactEnabled() and 1.05 or 1) *
                    -- Silence of the Uncrowned Multiplier
                    (S.SilenceoftheUncrowned:ArtifactEnabled() and 1.1 or 1) *
                    -- Insignia of Ravenholdt Effect
                    (I.InsigniaofRavenholdt:IsEquipped() and 1.3 or 1);
        end
);
local function NighstalkerMultiplier ()
    return S.Nightstalker:IsAvailable() and Player:IsStealthed(true, false) and 1.5 or 1;
end
S.Garrote:RegisterPMultiplier(
        {NighstalkerMultiplier},
        {function ()
            return S.Subterfuge:IsAvailable() and Player:IsStealthed(true, false) and 2.25 or 1;
        end}
);
S.Rupture:RegisterPMultiplier(
        {NighstalkerMultiplier}
);

local function Poisoned (Unit)
    return (Unit:Debuff(Spell.Rogue.Assassination.DeadlyPoisonDebuff) or Unit:Debuff(Spell.Rogue.Assassination.WoundPoisonDebuff)) and true or false;
end

-- poison_remains
--[[ Original SimC Code
  if ( dots.deadly_poison -> is_ticking() ) {
    return dots.deadly_poison -> remains();
  } else if ( debuffs.wound_poison -> check() ) {
    return debuffs.wound_poison -> remains();
  } else {
    return timespan_t::from_seconds( 0.0 );
  }
]]
local function PoisonRemains (Unit)
    return (Unit:Debuff(Spell.Rogue.Assassination.DeadlyPoisonDebuff) and Unit:DebuffRemainsP(Spell.Rogue.Assassination.DeadlyPoisonDebuff))
            or (Unit:Debuff(Spell.Rogue.Assassination.WoundPoisonDebuff) and Unit:DebuffRemainsP(Spell.Rogue.Assassination.WoundPoisonDebuff))
            or 0;
end

local function Bleeds ()
    return (Target:Debuff(Spell.Rogue.Assassination.Garrote) and 1 or 0) + (Target:Debuff(Spell.Rogue.Assassination.Rupture) and 1 or 0) + (Target:Debuff(Spell.Rogue.Assassination.InternalBleeding) and 1 or 0);
end

local function PoisonedBleeds ()
    poisonedBleedCount = 0;
    -- Get Units up to 50y (not really worth the potential performance loss to go higher).
    AC.GetEnemies(50);
    for _, Unit in pairs(Cache.Enemies[50]) do
        if Poisoned(Unit) then
            -- TODO: For loop for this ? Not sure it's worth considering we would have to make 2 times spell object (Assa is init after Commons)
            if Unit:Debuff(Spell.Rogue.Assassination.Garrote) then
                poisonedBleedCount = poisonedBleedCount + 1;
            end
            if Unit:Debuff(Spell.Rogue.Assassination.InternalBleeding) then
                poisonedBleedCount = poisonedBleedCount + 1;
            end
            if Unit:Debuff(Spell.Rogue.Assassination.Rupture) then
                poisonedBleedCount = poisonedBleedCount + 1;
            end
        end
    end
    return poisonedBleedCount;
end

local function CPMaxSpend()
    -- Should work for all 3 specs since they have same Deeper Stratagem Spell ID.
    return Spell.Rogue.Subtlety.DeeperStratagem:IsAvailable() and 6 or 5;
end

-- "cp_spend"
local function CPSpend()
    return mathmin(Player:ComboPoints(), CPMaxSpend());
end

local function CDs()
    --# Cooldowns
    --actions.cds=potion,if=buff.bloodlust.react|target.time_to_die<=60|debuff.vendetta.up&cooldown.vanish.remains<5
    --actions.cds+=/use_item,name=faulty_countermeasure
    --actions.cds+=/use_item,name=tirathons_betrayal
    --actions.cds+=/blood_fury,if=debuff.vendetta.up
    if S.BloodFury:IsReady("Melee") and Target:Debuff(S.Vendetta) then
        return S.BloodFury:ID()
    end

    --actions.cds+=/berserking,if=debuff.vendetta.up
    if S.Berserking:IsReady("Melee") and Target:Debuff(S.Vendetta) then
        return S.BloodFury:ID()
    end

    --actions.cds+=/lights_judgment,if=debuff.vendetta.up

    --actions.cds+=/marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit*1.5|(raid_event.adds.in>40&combo_points.deficit>=cp_max_spend)
    if S.MarkedforDeath:IsCastable() and Player:ComboPointsDeficit() >= CPMaxSpend() then
        return S.MarkedforDeath:ID()
    end

    --actions.cds+=/vendetta,if=dot.rupture.ticking
    if S.Vendetta:IsReady("Melee") and Target:Debuff(S.Rupture) then
        return S.Vendetta:ID()
    end

    --# Vanish with Nightstalker + Exsg: Maximum CP and Exsg ready for next GCD
    --actions.cds+=/vanish,if=talent.nightstalker.enabled&talent.exsanguinate.enabled&combo_points>=cp_max_spend&cooldown.exsanguinate.remains<1
    if S.Vanish:IsReady() and S.Nightstalker:IsAvailable() and S.Exsanguinate:IsAvailable() and Player:ComboPoints() >= CPMaxSpend()() and S.Exsanguinate:CooldownRemains() < 1 then
        return S.Vanish:ID()
    end

    --# Vanish with Nightstalker + No Exsg: Maximum CP and Vendetta up
    --actions.cds+=/vanish,if=talent.nightstalker.enabled&!talent.exsanguinate.enabled&combo_points>=cp_max_spend&debuff.vendetta.up
    if S.Vanish:IsReady() and S.Nightstalker:IsAvailable() and not S.Exsanguinate:IsAvailable() and Player:ComboPoints() >= CPMaxSpend() and Target:Debuff(S.Vendetta) then
        return S.Vanish:ID()
    end

    --# Vanish with Subterfuge: No stealth/subterfuge, Garrote Refreshable, enough space for incoming Garrote CP
    --actions.cds+=/vanish,if=talent.subterfuge.enabled&!stealthed.rogue&dot.garrote.refreshable&(spell_targets.fan_of_knives<=3&combo_points.deficit>=1+spell_targets.fan_of_knives|spell_targets.fan_of_knives>=4&combo_points.deficit>=4)
    if S.Vanish:IsReady() and Target:DebuffRefreshableP(S.Garrote, 5.4) and ((Cache.EnemiesCount[10] <= 3 and Player:ComboPointsDeficit() >= 1 + Cache.EnemiesCount[10]) or (Cache.EnemiesCount[10] >= 4 and Player:ComboPointsDeficit() >= 4)) then
        return S.Vanish:ID()
    end

    --# Vanish with Master Assasin: No stealth and no active MA buff, Rupture not in refresh range
    --actions.cds+=/vanish,if=talent.master_assassin.enabled&!stealthed.all&master_assassin_remains<=0&!dot.rupture.refreshable
    if S.Vanish:IsReady() and S.MasterAssassin:IsAvailable() and not Player:IsStealthed(true, false) and not Player:Buff(S.MasterAssassin) and not Target:DebuffRefreshableP(S.Rupture) then
        return S.Vanish:ID()
    end

    --# Exsanguinate after a full duration Rupture or a snaphot Garrote during subterfuge
    --actions.cds+=/exsanguinate,if=prev_gcd.1.rupture&dot.rupture.remains>4+4*cp_max_spend&!stealthed.rogue|dot.garrote.pmultiplier>1&!cooldown.vanish.up&buff.subterfuge.up
    if S.Exsanguinate:IsReady() and Player:PrevGCD(1, S.Rupture) and Target:DebuffRemainsP(S.Rupture) > 4 + 4 * CPMaxSpend() and not Player:IsStealthed(true, false)
            or Target:PMultiplier(S.Garrote) > 1 and not S.Vanish:CooldownUp() and Player:BuffP(S.Subterfuge) then
        return S.Exsanguinate:ID()
    end

    --actions.cds+=/toxic_blade,if=dot.rupture.ticking
    if S.ToxicBlade:IsReady() and not Target.Debuff(S.Rupture) then
        return S.ToxicBlade:ID()
    end
end

local function Stealthed()
    --Stealthed Actions
    --# Subterfuge: Apply or Refresh buffed Garrotes
    --actions.stealthed=garrote,cycle_targets=1,if=talent.subterfuge.enabled&refreshable&(!exsanguinated|remains<=tick_time*2)&target.time_to_die-remains>2
    if S.Garrote:IsReady("Melee") and S.Subterfuge:IsAvailable() and not Target:Debuff(S.Garrote) and (Target:DebuffRemainsP(S.Garrote) <= ExsanguinatedBleedTickTime * 2) and (Target:FilteredTimeToDie(">", 2, -Target:DebuffRemainsP(S.Garrote)) or Target:TimeToDieIsNotValid()) then

        --# Subterfuge: Override normal Garrotes with snapshot versions if there's time
        --actions.stealthed+=/garrote,cycle_targets=1,if=talent.subterfuge.enabled&remains<=10&pmultiplier<=1&!exsanguinated&target.time_to_die-remains>2
        if S.Garrote:IsReady("Melee") and S.Subterfuge:IsAvailable() and Target:DebuffRemainsP(S.Garrote) <= 10 and Target:PMultiplier(S.Garrote) <= 1 and (Target:FilteredTimeToDie(">", 2, -Target:DebuffRemainsP(S.Garrote)) or Target:TimeToDieIsNotValid()) then
            return S.Garrote:ID()
        end

        --# Nighstalker: Snapshot Rupture
        --actions.stealthed+=/rupture,if=talent.nightstalker.enabled&target.time_to_die-remains>6
        if S.Rupture:IsReady("Melee") and S.Nightstalker:IsAvailable()
                and (Target:FilteredTimeToDie(">", 6, -Target:DebuffRemainsP(S.Rupture)) or Target:TimeToDieIsNotValid()) then
            return S.Rupture:ID()
        end

        --actions.stealthed+=/envenom,if=combo_points>=cp_max_spend
        if S.Envenom:IsReady("Melee") and Player:ComboPoints() >= CPMaxSpend() then
            return S.Envenom:ID()
        end

        --actions.stealthed+=/garrote,if=!talent.subterfuge.enabled&target.time_to_die-remains>4
        if S.Garrote:IsReady("Melee") and not S.Subterfuge:IsAvailable()
                and (Target:FilteredTimeToDie(">", 4, -Target:DebuffRemainsP(S.Garrote)) or Target:TimeToDieIsNotValid()) then
            return S.Garrote:ID()
        end

        --actions.stealthed+=/mutilate
        if S.Mutilate:IsReady("Melee") then
            return S.Mutilate:ID()
        end
    end
end

local function Dot()
    --# Damage over time abilities
    --# Special Rupture setup for Exsg
    --actions.dot=rupture,if=talent.exsanguinate.enabled&((combo_points>=cp_max_spend&cooldown.exsanguinate.remains<1)|(!ticking&(time>10|combo_points>=2)))
    if S.Rupture:IsReady("Melee") and S.Exsanguinate:IsAvailable()
            and ((Player:ComboPoints() >= CPMaxSpend() and S.Exsanguinate:CooldownRemainsP() < 1)
            or (not Target:DebuffP(S.Rupture) and (AC.CombatTime() > 10 or (Player:ComboPoints() >= 2)))) then
        return S.Rupture:ID()
    end

    --# Garrote upkeep, also tries to use it as a special generator for the last CP before a finisher
    --actions.dot+=/pool_resource,for_next=1

    --actions.dot+=/garrote,cycle_targets=1,if=(!talent.subterfuge.enabled|!(cooldown.vanish.up&cooldown.vendetta.remains<=4))&combo_points.deficit>=1&refreshable&(pmultiplier<=1|remains<=tick_time)&(!exsanguinated|remains<=tick_time*2)&(target.time_to_die-remains>4&spell_targets.fan_of_knives<=1|target.time_to_die-remains>12)
    if S.Garrote:IsReady("Melee") and ((not S.Subterfuge:IsAvailable() or not RubimRH.CDsON() or not (S.Vanish:CooldownUp() and S.Vendetta:CooldownRemainsP() <= 4)) and Player:ComboPointsDeficit() >= 1 and not Target:Debuff(S.Garrote) and (Target:PMultiplier(S.Garrote) <= 1 or Target:DebuffRemainsP(S.Garrote) <= ExsanguinatedBleedTickTime * 2) and (Target:FilteredTimeToDie(">", 4, -Target:DebuffRemainsP(S.Garrote)) or Target:TimeToDieIsNotValid()) and Cache.EnemiesCount[10] <= 1 or (Target:FilteredTimeToDie(">", 12, -Target:DebuffRemainsP(S.Garrote)) or Target:TimeToDieIsNotValid())) then
        return S.Garrote:ID()
    end

    --# Crimson Tempest only on multiple targets at 4+ CP when running out in 2s (up to 4 targets) or 3s (5+ targets)
    --actions.dot+=/crimson_tempest,if=spell_targets>=2&remains<2+(spell_targets>=5)&combo_points>=4
    if S.CrimsonTempest:IsReady() and Cache.EnemiesCount[10] >= 2 and Player:ComboPoints() >= 4 and Target:DebuffRemains(S.CrimsonTempest) < 2 then
        return S.CrimsonTempestID()
    end

    --# Keep up Rupture at 4+ on all targets (when living long enough and not snapshot)
    --actions.dot+=/rupture,cycle_targets=1,if=combo_points>=4&refreshable&(pmultiplier<=1|remains<=tick_time)&(!exsanguinated|remains<=tick_time*2)&target.time_to_die-remains>4
    if S.Rupture:IsReady("Melee") and Player:ComboPoints() >= 4 and Target:DebuffRefreshableP(S.Rupture) and (Target:PMultiplier(S.Rupture) <= 1 or Target:DebuffRemainsP(S.Rupture) <= ExsanguinatedBleedTickTime or BleedTickTime) or Target:DebuffRemainsP(S.Rupture) <= ExsanguinatedBleedTickTime * 2 and (Target:FilteredTimeToDie(">", 6, Target:DebuffRemainsP(S.Rupture)) or Target:TimeToDieIsNotValid()) then
        return S.Rupture:ID()
    end
end

local useFiller
local function Direct()
    --# Direct damage abilities
    --# Envenom at 4+ (5+ with DS) CP. Immediately on 2+ targets, with Vendetta, or with TB; otherwise wait for some energy. Also wait if Exsg combo is coming up.
    --actions.direct=envenom,if=combo_points>=4+talent.deeper_stratagem.enabled&(debuff.vendetta.up|debuff.toxic_blade.up|energy.deficit<=25+variable.energy_regen_combined|spell_targets.fan_of_knives>=2)&(!talent.exsanguinate.enabled|cooldown.exsanguinate.remains>2)
    --actions.direct+=/variable,name=use_filler,value=combo_points.deficit>1|energy.deficit<=25+variable.energy_regen_combined|spell_targets.fan_of_knives>=2
    useFiller = Player:ComboPointsDeficit() > 1 or Player:EnergyDeficit() <= 25 + energyCombined or Cache.EnemiesCount[10] >= 2

    --actions.direct+=/fan_of_knives,if=variable.use_filler&(buff.hidden_blades.stack>=19|spell_targets.fan_of_knives>=2)
    if S.FanofKnives:IsReady("Melee") and useFiller and (Player:BuffStack(S.HiddenBlades) >= 19 or Cache.EnemiesCount[10] >= 2) then
        return S.FanofKnives:ID()
    end

    --actions.direct+=/blindside,if=variable.use_filler&(buff.blindside.up|!talent.venom_rush.enabled)
    if S.Blindside:IsReady("Melee") and useFiller and (Player:Buff(S.Blindside) and not Player.VenomRush:IsAvailable()) then
        return S.Blindside:ID()
    end

    --actions.direct+=/mutilate,if=variable.use_filler
    if S.Mutilate:IsReady("Melee") and useFiller then
        return S.Mutilate:ID()
    end

end

local function APL()
    Stealth = S.Subterfuge:IsAvailable() and S.Stealth2 or S.Stealth; -- w/ or w/o Subterfuge Talent
    AC.GetEnemies("Melee");
    AC.GetEnemies(8, true);
    AC.GetEnemies(10, true);

    if not Player:AffectingCombat() then
        --actions.precombat+=/stealth
        if RubimRH.config.stealthOOC and Stealth:IsCastable() and not Player:IsStealthed() then
            return Stealth:ID()
        end

        --actions.precombat+=/marked_for_death,precombat_seconds=5,if=raid_event.adds.in>40

        return 0, 462338
    end

    --# Executed every time the actor is available.
    --actions=variable,name=energy_regen_combined,value=energy.regen+poisoned_bleeds*7%(2*spell_haste)
    energyCombined = Player:EnergyRegen() + PoisonedBleeds() * (7 + (S.VenomRush:IsAvailable() and 3 or 0)) / 2;

    --actions+=/call_action_list,name=cds
    --if CDs ~= nil then
--        return CDs()
--    end

    --actions+=/run_action_list,name=stealthed,if=stealthed.rogue
  --  if Player:IsStealthed(true, false) and Stealthed() ~= nil then
--        return Stealthed()
--    end

    --actions+=/call_action_list,name=dot
    if Dot() ~= nil then
        return Dot()
    end

    --actions+=/call_action_list,name=direct
    if Direct() ~= nil then
        return Direct()
    end

    --actions+=/arcane_torrent,if=energy.deficit>=15+variable.energy_regen_combined
    if S.ArcaneTorrent:IsReady() and Player:EnergyDeficit() >= 15 + energyCombined then
        return S.ArcaneTorrent:ID()
    end

    --actions+=/arcane_pulse
    return 0, 975743
end
RubimRH.Rotation.SetAPL(259, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(259, PASSIVE);