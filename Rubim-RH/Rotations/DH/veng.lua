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
-- Lua
local pairs = pairs;

RubimRH.Spell[581] = {
    -- Abilities
    Felblade = Spell(232893),
    FelDevastation = Spell(212084),
    Fracture = Spell(263642),
    FractureTalent = Spell(227700),
    Frailty = Spell(247456),
    ImmolationAura = Spell(178740),
    Sever = Spell(235964),
    Shear = Spell(203782),
    SigilofFlame = Spell(204596),
    SigilofFlame2 = Spell(204513),
    SpiritBomb = Spell(247454),
    SoulCleave = Spell(228477),
    SoulFragments = Spell(203981),
    ThrowGlaive = Spell(204157),
    -- Offensive
    SoulCarver = Spell(207407),
    -- Defensive
    FieryBrand = Spell(204021),
    DemonSpikes = Spell(203720),
    DemonSpikesBuff = Spell(203819),
    Metamorphosis = Spell(187827),
    SoulBarrier = Spell(263648),
    -- Utility
    ConsumeMagic = Spell(278326),
    InfernalStrike = Spell(189110),
    Disrupt = Spell(183752),
    CharredFlesh = Spell(264002),
    SigilofSilence = Spell(202137),
    SigilofMisery = Spell(207684),
    SigilofChains = Spell(202138),
    ArcaneTorrent = Spell(202719),
    ConcentratedSigils = Spell(207666),
    FallOut = Spell(22766),

    --8.2 Essences
    HoA                   = Spell(280431),
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

local S = RubimRH.Spell[581]

S.Fracture.TextureSpellID = { 279450 }
S.Sever.TextureSpellID = { 279450 }
--S.ImmolationAura.TextureSpellID = { 202137 }

local T202PC, T204PC = HL.HasTier("T20");
local T212PC, T214PC = HL.HasTier("T21");
-- APL Main

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

local EnemyRanges = { "Melee", 8, 10, 20, 30, 40 }
local function UpdateRanges()
    for _, i in ipairs(EnemyRanges) do
        HL.GetEnemies(i);
    end
end

local OffensiveCDs = {
    S.ConcentratedFlame,
    S.MemoryOfLucidDreams,
    S.RippleInSpace,
    S.WorldveinResonance,

}

local function UpdateCDs()
    RubimRH.db.profile.mainOption.disabledSpellsCD = {}
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


local function APL()
    local Precombat, Brand, Defensives, Normal
    UpdateRanges()
    UpdateCDs()
    DetermineEssenceRanks()
    -- It helps not to waste SoulFragment
    local DelayAction =
        S.Fracture:TimeSinceLastCast() > Player:GCD()
    and S.Shear:TimeSinceLastCast() > Player:GCD() 
    and S.InfernalStrike:TimeSinceLastCast() > Player:GCD()
    and S.FelDevastation:TimeSinceLastCast() > Player:GCD()
    and S.Felblade:TimeSinceLastCast() > Player:GCD()
    and S.ImmolationAura:TimeSinceLastCast() > Player:GCD()
    and S.FieryBrand:TimeSinceLastCast() > Player:GCD()
    and S.ThrowGlaive:TimeSinceLastCast() > Player:GCD()
    and S.SoulBarrier:TimeSinceLastCast() > Player:GCD()
    and S.SigilofFlame:TimeSinceLastCast() > Player:GCD()
    and S.SigilofFlame2:TimeSinceLastCast() > Player:GCD();

    local SoulFragments = Player:BuffStack(S.SoulFragments);
    local IsTanking = Player:IsTankingAoE(8) or Player:IsTanking(Target);
    Precombat = function()
        -- flask
        -- augmentation
        -- food
        -- snapshot_stats
        -- potion
        --if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (true) then
        --return S.ProlongedPower:Cast()
        --end
        -- metamorphosis
        --if S.Metamorphosis:IsReady() and Player:BuffDownP(S.MetamorphosisBuff) then
        --return S.Metamorphosis:Cast()
        --end
        return 0, 462338
    end

    Brand = function()
        --actions.brand=sigil_of_flame,if=cooldown.fiery_brand.remains<2
        if S.SigilofFlame:IsReadyMorph() and Cache.EnemiesCount[8] >= 1 and S.FieryBrand:CooldownRemains() < 2 then
            return S.SigilofFlame:Cast()
        end

        --actions.brand+=/infernal_strike,if=cooldown.fiery_brand.remains=0
        if S.InfernalStrike:TimeSinceLastCast() > 1 and Cache.EnemiesCount[8] >= 1 and S.InfernalStrike:IsReady() and S.FieryBrand:CooldownRemains() == 0 and S.InfernalStrike:TimeSinceLastCast() > 2 and S.InfernalStrike:IsReady("Melee") and S.InfernalStrike:ChargesFractional() >= 2.0 - Player:GCD()/10 then
            return S.InfernalStrike:Cast()
        end

        --actions.brand+=/fiery_brandF
        if S.FieryBrand:IsReady('Melee') then
            return S.FieryBrand:Cast()
        end

        --actions.brand+=/immolation_aura,if=dot.fiery_brand.ticking
        if S.ImmolationAura:IsReady() and Cache.EnemiesCount[8] >= 1 and Target:Debuff(S.FieryBrand) then
            return S.ImmolationAura:Cast()
        end

        --actions.brand+=/fel_devastation,if=dot.fiery_brand.ticking
        if S.FelDevastation:IsReady() and Target:Debuff(S.FieryBrand) then
            return S.FelDevastation:Cast()
        end

        --actions.brand+=/infernal_strike,if=dot.fiery_brand.ticking
        if S.InfernalStrike:TimeSinceLastCast() > 1  and S.InfernalStrike:IsReady() and Cache.EnemiesCount[8] >= 1 and Target:Debuff(S.FieryBrand) then
            return S.InfernalStrike:Cast()
        end

        --actions.brand+=/sigil_of_flame,if=dot.fiery_brand.ticking
        if S.SigilofFlame:IsReadyMorph() and Target:Debuff(S.FieryBrand) then
            return S.SigilofFlame:Cast()
        end
    end

    Defensives = function()
        --# Defensives
        --actions.defensives=demon_spikes
        if S.DemonSpikes:IsReady() and not Player:Buff(S.DemonSpikesBuff) and IsTanking and Player:HealthPercentage() < 70 and Player:BuffDownP(S.Metamorphosis) then
            return S.DemonSpikes:Cast()
        end

        --actions.defensives+=/metamorphosis
        --actions.defensives+=/fiery_brand
        if S.FieryBrand:IsReady('Melee') then
            return S.FieryBrand:Cast()
        end
    end

    Normal = function()
        --# Normal Rotation
        --actions.normal=infernal_strike
        if Cache.EnemiesCount[8] > 0 and S.InfernalStrike:TimeSinceLastCast() > 1 and S.InfernalStrike:IsReady() and S.InfernalStrike:ChargesFractional() >= 2.0 - Player:GCD()/10 then
            return S.InfernalStrike:Cast()
        end

        --actions.normal+=/spirit_bomb,if=soul_fragments>=4
        if Cache.EnemiesCount[8] > 0 and S.SpiritBomb:IsReady() and SoulFragments >= 4 then
            return S.SpiritBomb:Cast()
        end

        --actions.normal+=/soul_cleave,if=!talent.spirit_bomb.enabled
        if S.SoulCleave:IsReady("Melee") and not S.SpiritBomb:IsAvailable() then
            return S.SoulCleave:Cast()
        end

        --actions.normal+=/soul_cleave,if=talent.spirit_bomb.enabled&soul_fragments=0
        if S.SoulCleave:IsReady("Melee") and S.SpiritBomb:IsAvailable() and SoulFragments == 0 
            and DelayAction then
            return S.SoulCleave:Cast()
        end
        --actions.normal+=/immolation_aura,if=pain<=90
        if Cache.EnemiesCount[8] > 0 and S.ImmolationAura:IsReady() and Player:Pain() <= 90 then
            return S.ImmolationAura:Cast()
        end

        -- concentrated_flame
        if S.ConcentratedFlame:IsReady() then
            return S.HoA:Cast()
        end
        -- ripple_in_space
        if S.RippleInSpace:IsReady() then
            return S.HoA:Cast()
        end
        -- worldvein_resonance
        if S.WorldveinResonance:IsReady() then
            return S.HoA:Cast()
        end
        -- memory_of_lucid_dreams
        if S.MemoryOfLucidDreams:IsReady() then
            return S.HoA:Cast()
        end

        --actions.normal+=/felblade,if=pain<=70
        if S.Felblade:IsReady(15) and Player:Pain() <= 70 then
            return S.Felblade:Cast()
        end

        --actions.normal+=/fracture,if=soul_fragments<=3
        if S.Shear:IsReady("Melee") and SoulFragments <= 3 then
            return S.Fracture:Cast()
        end

        --actions.normal+=/fel_devastation
        if S.FelDevastation:IsReady(20) then
            return S.FelDevastation:Cast()
        end

        --actions.normal+=/sigil_of_flame
        if Cache.EnemiesCount[8] > 0 and S.SigilofFlame:IsReadyMorph() then
            return S.SigilofFlame:Cast()
        end

        --actions.normal+=/shear
        if S.Fracture:IsReady("Melee") then
            return S.Shear:Cast()
        end

        --actions.normal+=/throw_glaive
        if S.ThrowGlaive:IsReady('Melee') then
            return S.ThrowGlaive:Cast()
        end
    end

    if not Player:AffectingCombat() and RubimRH.PrecombatON() and not Target:IsQuestMob() then
        return 0, 462338
    end

    if S.Disrupt:IsReady(10) and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.Disrupt:Cast()
    end
    if S.ConsumeMagic:IsReadyP() and Target:HasStealableBuff() then
        return S.ConsumeMagic:Cast()
    end

    if QueueSkill() ~= nil then
        return QueueSkill()
    end

    --- Defensives
    if S.Metamorphosis:IsReady() and S.DemonSpikes:Charges() == 0 and Player:HealthPercentage() <= RubimRH.db.profile[581].sk1 then
        return S.Metamorphosis:Cast()
    end

    if S.SoulBarrier:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[581].sk2 then
        return S.SoulBarrier:Cast()
    end

    --# Executed every time the actor is available.
    --actions=auto_attack
    --actions+=/consume_magic
    --# ,if=!raid_event.adds.exists|active_enemies>1
    --actions+=/use_item,slot=trinket1
    --# ,if=!raid_event.adds.exists|active_enemies>1
    --actions+=/use_item,slot=trinket2
    --actions+=/call_action_list,name=brand,if=talent.charred_flesh.enabled
    if Brand() ~= nil and S.CharredFlesh:IsAvailable() then
        return Brand()
    end

    --actions+=/call_action_list,name=defensives
    if Defensives() ~= nil then
        return Defensives()
    end

    --actions+=/call_action_list,name=normal
    if Normal() ~= nil then
        return Normal()
    end
    return 0, 135328
end
RubimRH.Rotation.SetAPL(581, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(581, PASSIVE);
