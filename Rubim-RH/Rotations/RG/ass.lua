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
    Stealth = Spell(1784),
    MarkedForDeath = Spell(137619),
    VendettaDebuff = Spell(79140),
    Vanish = Spell(1856),
    BloodFury = Spell(20572),
    Berserking = Spell(26297),
    Vendetta = Spell(79140),
    RuptureDebuff = Spell(1943),
    Exsanguinate = Spell(200806),
    Nightstalker = Spell(14062),
    Subterfuge = Spell(108208),
    Garrote = Spell(703),
    GarroteDebuff = Spell(703),
    MasterAssassin = Spell(255989),
    ToxicBlade = Spell(245388),
    Envenom = Spell(32645),
    DeeperStratagem = Spell(193531),
    ToxicBladeDebuff = Spell(245389),
    FanofKnives = Spell(51723),
    HiddenBladesBuff = Spell(270070),
    TheDreadlordsDeceitBuff = Spell(208692),
    Blindside = Spell(111240),
    BlindsideBuff = Spell(121153),
    VenomRush = Spell(152152),
    Mutilate = Spell(1329),
    Rupture = Spell(1943),
    CrimsonTempest = Spell(121411),
    CrimsonTempestBuff = Spell(121411),
    ArcaneTorrent = Spell(50613),
    ArcanePulse = Spell(260364),
    LightsJudgment = Spell(255647),
    InternalBleeding = Spell(154904),
    -- Poisons
    CripplingPoison = Spell(3408),
    DeadlyPoison = Spell(2823),
    DeadlyPoisonDebuff = Spell(2818),
    LeechingPoison = Spell(108211),
    WoundPoison = Spell(8679),
    WoundPoisonDebuff = Spell(8680),
};
local S = RubimRH.Spell[259];

-- Items
if not Item.Rogue then
    Item.Rogue = {}
end
Item.Rogue.Assassination = {
    ProlongedPower = Item(142117),
    GalecallersBoon = Item(159614)
};
local I = Item.Rogue.Assassination;



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

local function bool(val)
    return val ~= 0
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
    return mathmin(Player:ComboPoints(), CPMaxSpend());
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
            if Unit:Debuff(S.GarroteDebuff) then
                PoisonedBleedsCount = PoisonedBleedsCount + 1;
            end
            if Unit:Debuff(S.InternalBleeding) then
                PoisonedBleedsCount = PoisonedBleedsCount + 1;
            end
            if Unit:Debuff(S.RuptureDebuff) then
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

--- ======= ACTION LISTS =======
local function APL()
    local Precombat, Cds, Direct, Dot, Stealthed
    UpdateRanges()
    Precombat = function()
        -- flask
        -- augmentation
        -- food
        -- snapshot_stats
        -- stealth
        if S.Stealth:IsReady() and (true) then
            return S.Stealth:Cast()
        end
        -- potion
        -- marked_for_death,precombat_seconds=5,if=raid_event.adds.in>40
        if RubimRH.TargetIsValid() then
            if S.MarkedForDeath:IsReady() then
                return S.MarkedForDeath:Cast()
            end
        end
    end
    Cds = function()
        -- potion,if=buff.bloodlust.react|target.time_to_die<=60|debuff.vendetta.up&cooldown.vanish.remains<5
        -- use_item,name=galecallers_boon
        -- blood_fury,if=debuff.vendetta.up
        if S.BloodFury:IsReady() and RubimRH.CDsON() and (Target:Debuff(S.VendettaDebuff)) then
            return S.BloodFury:Cast()
        end
        -- berserking,if=debuff.vendetta.up
        if S.Berserking:IsReady() and RubimRH.CDsON() and (Target:Debuff(S.VendettaDebuff)) then
            return S.Berserking:Cast()
        end
        -- marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit*1.5|(raid_event.adds.in>40&combo_points.deficit>=CPMaxSpend())
        if S.MarkedForDeath:IsReady() and (Target:TimeToDie() < Player:ComboPointsDeficit() * 1.5) then
            return S.MarkedForDeath:Cast()
        end
        -- vendetta,if=dot.rupture.ticking
        if S.Vendetta:IsReady() and (Target:Debuff(S.RuptureDebuff)) then
            return S.Vendetta:Cast()
        end
        -- vanish,if=talent.exsanguinate.enabled&(talent.nightstalker.enabled|talent.subterfuge.enabled&spell_targets.fan_of_knives<2)&combo_points>=CPMaxSpend()&cooldown.exsanguinate.remains<1
        if S.Vanish:IsReady() and (S.Exsanguinate:IsAvailable() and (S.Nightstalker:IsAvailable() or S.Subterfuge:IsAvailable() and Cache.EnemiesCount[10] < 2) and Player:ComboPoints() >= CPMaxSpend() and S.Exsanguinate:CooldownRemains() < 1) then
            return S.Vanish:Cast()
        end
        -- vanish,if=talent.nightstalker.enabled&!talent.exsanguinate.enabled&combo_points>=CPMaxSpend()&debuff.vendetta.up
        if S.Vanish:IsReady() and (S.Nightstalker:IsAvailable() and not S.Exsanguinate:IsAvailable() and Player:ComboPoints() >= CPMaxSpend() and Target:Debuff(S.VendettaDebuff)) then
            return S.Vanish:Cast()
        end
        -- vanish,if=talent.subterfuge.enabled&(!talent.exsanguinate.enabled|spell_targets.fan_of_knives>=2)&!stealthed.rogue&cooldown.garrote.up&dot.garrote.refreshable&(spell_targets.fan_of_knives<=3&combo_points.deficit>=1+spell_targets.fan_of_knives|spell_targets.fan_of_knives>=4&combo_points.deficit>=4)
        if S.Vanish:IsReady() and (S.Subterfuge:IsAvailable() and (not S.Exsanguinate:IsAvailable() or Cache.EnemiesCount[10] >= 2) and not bool(IsStealthed()) and S.Garrote:CooldownUp() and Target:DebuffRefreshableC(S.GarroteDebuff) and (Cache.EnemiesCount[10] <= 3 and Player:ComboPointsDeficit() >= 1 + Cache.EnemiesCount[10] or Cache.EnemiesCount[10] >= 4 and Player:ComboPointsDeficit() >= 4)) then
            return S.Vanish:Cast()
        end

        -- vanish,if=talent.master_assassin.enabled&!stealthed.all&MasterAssassinRemains()<=0&!dot.rupture.refreshable
        if S.Vanish:IsReady() and (S.MasterAssassin:IsAvailable() and not bool(IsStealthed()) and MasterAssassinRemains() <= 0 and not Target:DebuffRefreshableC(S.RuptureDebuff)) then
            return S.Vanish:Cast()
        end
        -- exsanguinate,if=dot.rupture.remains>4+4*CPMaxSpend()&!dot.garrote.refreshable
        if S.Exsanguinate:IsReady() and (Target:DebuffRemains(S.RuptureDebuff) > 4 + 4 * CPMaxSpend() and not Target:DebuffRefreshableC(S.GarroteDebuff)) then
            return S.Exsanguinate:Cast()
        end
        -- toxic_blade,if=dot.rupture.ticking
        if S.ToxicBlade:IsReady() and (Target:Debuff(S.RuptureDebuff)) then
            return S.ToxicBlade:Cast()
        end
    end
    Direct = function()
        -- envenom,if=combo_points>=4+talent.deeper_stratagem.enabled&(debuff.vendetta.up|debuff.toxic_blade.up|energy.deficit<=25+variable.energy_regen_combined|spell_targets.fan_of_knives>=2)&(!talent.exsanguinate.enabled|cooldown.exsanguinate.remains>2)
        if S.Envenom:IsReady() and (Player:ComboPoints() >= 4 + num(S.DeeperStratagem:IsAvailable()) and (Target:Debuff(S.VendettaDebuff) or Target:Debuff(S.ToxicBladeDebuff) or Player:EnergyDeficit() <= 25 + VarEnergyRegenCombined or Cache.EnemiesCount[10] >= 2) and (not S.Exsanguinate:IsAvailable() or S.Exsanguinate:CooldownRemains() > 2)) then
            return S.Envenom:Cast()
        end
        -- variable,name=use_filler,value=combo_points.deficit>1|energy.deficit<=25+variable.energy_regen_combined|spell_targets.fan_of_knives>=2
        if (true) then
            VarUseFiller = num(Player:ComboPointsDeficit() > 1 or Player:EnergyDeficit() <= 25 + VarEnergyRegenCombined or Cache.EnemiesCount[10] >= 2)
        end
        -- fan_of_knives,if=variable.use_filler&(buff.hidden_blades.stack>=19|spell_targets.fan_of_knives>=2+stealthed.rogue|buff.the_dreadlords_deceit.stack>=29)
        if S.FanofKnives:IsReady() and (bool(VarUseFiller) and (Player:BuffStack(S.HiddenBladesBuff) >= 19 or Cache.EnemiesCount[10] >= 2 + num(IsStealthed()) or Player:BuffStack(S.TheDreadlordsDeceitBuff) >= 29)) then
            return S.FanofKnives:Cast()
        end
        -- blindside,if=variable.use_filler&(buff.blindside.up|!talent.venom_rush.enabled)
        if S.Blindside:IsReady() and (bool(VarUseFiller) and (Player:Buff(S.BlindsideBuff) or not S.VenomRush:IsAvailable())) then
            return S.Blindside:Cast()
        end
        -- mutilate,if=variable.use_filler
        if S.Mutilate:IsReady() and (bool(VarUseFiller)) then
            return S.Mutilate:Cast()
        end
    end
    Dot = function()
        -- rupture,if=talent.exsanguinate.enabled&((combo_points>=CPMaxSpend()&cooldown.exsanguinate.remains<1)|(!ticking&(time>10|combo_points>=2)))
        if S.Rupture:IsReady() and (S.Exsanguinate:IsAvailable() and ((Player:ComboPoints() >= CPMaxSpend() and S.Exsanguinate:CooldownRemains() < 1) or (not Target:Debuff(S.RuptureDebuff) and (HL.CombatTime() > 10 or Player:ComboPoints() >= 2)))) then
            return S.Rupture:Cast()
        end
        -- pool_resource,for_next=1
        -- garrote,cycle_targets=1,if=(!talent.subterfuge.enabled|!(cooldown.vanish.up&cooldown.vendetta.remains<=4))&combo_points.deficit>=1&refreshable&(pmultiplier<=1|remains<=tick_time)&(!exsanguinated|remains<=tick_time*2)&(target.time_to_die-remains>4&spell_targets.fan_of_knives<=1|target.time_to_die-remains>12)
        if S.Garrote:IsReady() and ((not S.Subterfuge:IsAvailable() or not (S.Vanish:CooldownUp() and S.Vendetta:CooldownRemains() <= 4)) and Player:ComboPointsDeficit() >= 1 and Target:DebuffRefreshableC(S.GarroteDebuff) and (Target:PMultiplier(S.Garrote) <= 1 or Target:DebuffRemains(S.GarroteDebuff) <= S.GarroteDebuff:TickTime()) and (not bool(HL.Exsanguinated(Target, "Garrote")) or Target:DebuffRemains(S.GarroteDebuff) <= S.GarroteDebuff:TickTime() * 2) and (Target:TimeToDie() - Target:DebuffRemains(S.GarroteDebuff) > 4 and Cache.EnemiesCount[10] <= 1 or Target:TimeToDie() - Target:DebuffRemains(S.GarroteDebuff) > 12)) then
            if S.Garrote:IsUsablePPool() then
                return S.Garrote:Cast()
            else
                return S.PoolResource:Cast()
            end
        end
        -- crimson_tempest,if=spell_targets>=2&remains<2+(spell_targets>=5)&combo_points>=4
        if S.CrimsonTempest:IsReady() and (Cache.EnemiesCount[15] >= 2 and Player:BuffRemains(S.CrimsonTempestBuff) < 2 + num((Cache.EnemiesCount[15] >= 5)) and Player:ComboPoints() >= 4) then
            return S.CrimsonTempest:Cast()
        end
        -- rupture,cycle_targets=1,if=combo_points>=4&refreshable&(pmultiplier<=1|remains<=tick_time)&(!exsanguinated|remains<=tick_time*2)&target.time_to_die-remains>4
        if S.Rupture:IsReady() and (Player:ComboPoints() >= 4 and Target:DebuffRefreshableC(S.RuptureDebuff) and (Target:PMultiplier(S.Rupture) <= 1 or Target:DebuffRemains(S.RuptureDebuff) <= S.RuptureDebuff:TickTime()) and (not bool(HL.Exsanguinated(Target, "Garrote")) or Target:DebuffRemains(S.RuptureDebuff) <= S.RuptureDebuff:TickTime() * 2) and Target:TimeToDie() - Target:DebuffRemains(S.RuptureDebuff) > 4) then
            return S.Rupture:Cast()
        end
    end
    Stealthed = function()
        -- rupture,if=combo_points>=4&(talent.nightstalker.enabled|talent.subterfuge.enabled&talent.exsanguinate.enabled&spell_targets.fan_of_knives<2|!ticking)&target.time_to_die-remains>6
        if S.Rupture:IsReady() and (Player:ComboPoints() >= 4 and (S.Nightstalker:IsAvailable() or S.Subterfuge:IsAvailable() and S.Exsanguinate:IsAvailable() and Cache.EnemiesCount[10] < 2 or not Target:Debuff(S.RuptureDebuff)) and Target:TimeToDie() - Target:DebuffRemains(S.RuptureDebuff) > 6) then
            return S.Rupture:Cast()
        end
        -- envenom,if=combo_points>=CPMaxSpend()
        if S.Envenom:IsReady() and (Player:ComboPoints() >= CPMaxSpend()) then
            return S.Envenom:Cast()
        end
        -- garrote,cycle_targets=1,if=talent.subterfuge.enabled&refreshable&(!exsanguinated|remains<=tick_time*2)&target.time_to_die-remains>2
        if S.Garrote:IsReady() and (S.Subterfuge:IsAvailable() and Target:DebuffRefreshableC(S.GarroteDebuff) and (not bool(HL.Exsanguinated(Target, "Garrote")) or Target:DebuffRemains(S.GarroteDebuff) <= S.GarroteDebuff:TickTime() * 2) and Target:TimeToDie() - Target:DebuffRemains(S.GarroteDebuff) > 2) then
            return S.Garrote:Cast()
        end
        -- garrote,cycle_targets=1,if=talent.subterfuge.enabled&remains<=10&pmultiplier<=1&!exsanguinated&target.time_to_die-remains>2
        if S.Garrote:IsReady() and (S.Subterfuge:IsAvailable() and Target:DebuffRemains(S.GarroteDebuff) <= 10 and Target:PMultiplier(S.Garrote) <= 1 and not bool(HL.Exsanguinated(Target, "Garrote")) and Target:TimeToDie() - Target:DebuffRemains(S.GarroteDebuff) > 2) then
            return S.Garrote:Cast()
        end
        -- pool_resource,for_next=1
        -- garrote,if=talent.subterfuge.enabled&talent.exsanguinate.enabled&cooldown.exsanguinate.remains<1&prev_gcd.1.rupture
        if S.Garrote:IsReady() and (S.Subterfuge:IsAvailable() and S.Exsanguinate:IsAvailable() and S.Exsanguinate:CooldownRemains() < 1 and Player:PrevGCD(1, S.Rupture)) then
            if S.Garrote:IsUsablePPool() then
                return S.Garrote:Cast()
            else
                return S.PoolResource:Cast()
            end
        end
    end
    -- call precombat
    if IsStealthed() and RubimRH.db.profile[259].vanishattack and Player:PrevGCD(1, S.Vanish) then
        return Stealthed();
    end

    if not Player:AffectingCombat() then
        if Precombat() ~= nil then
            return Precombat()
        end
        return 0, 462338
    end
    -- variable,name=energy_regen_combined,value=energy.regen+poisoned_bleeds*7%(2*spell_haste)
    if (true) then
        VarEnergyRegenCombined = Player:EnergyRegen() + PoisonedBleeds() * 7 / (2 * Player:SpellHaste())
    end
    -- call_action_list,name=stealthed,if=stealthed.rogue
    if (bool(IsStealthed())) then
        if Stealthed() ~= nil then
            return Stealthed()
        end
    end
    -- call_action_list,name=cds
    if (true) then
        if Cds() ~= nil then
            return Cds()
        end
    end
    -- call_action_list,name=dot
    if (true) then
        if Dot() ~= nil then
            return Dot()
        end
    end
    -- call_action_list,name=direct
    if (true) then
        if Direct() ~= nil then
            return Direct()
        end
    end
    -- arcane_torrent,if=energy.deficit>=15+variable.energy_regen_combined
    if S.ArcaneTorrent:IsReady() and RubimRH.CDsON() and (Player:EnergyDeficit() >= 15 + VarEnergyRegenCombined) then
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

RubimRH.Rotation.SetAPL(259, APL)

local function PASSIVE()
    return RubimRH.Shared()
end
RubimRH.Rotation.SetPASSIVE(259, PASSIVE)