--- Localize Vars
local RubimRH = LibStub("AceAddon-3.0"):GetAddon("RubimRH")
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
-- Spells
RubimRH.Spell[72] = {
    RecklessnessBuff = Spell(1719),
    Recklessness = Spell(1719),
    FuriousSlashBuff = Spell(202539),
    FuriousSlash = Spell(100130),
    RecklessAbandon = Spell(202751),
    HeroicLeap = Spell(6544),
    Siegebreaker = Spell(280772),
    Rampage = Spell(184367),
    FrothingBerserker = Spell(215571),
    Carnage = Spell(202922),
    EnrageBuff = Spell(184362),
    Massacre = Spell(206315),
    Execute = Spell(5308),
    Bloodthirst = Spell(23881),
    RagingBlow = Spell(85288),
    Bladestorm = Spell(46924),
    SiegebreakerDebuff = Spell(280773),
    DragonRoar = Spell(118000),
    Whirlwind = Spell(190411),
    WhirlwindBuff = Spell(85739),
    Charge = Spell(100),
    FujiedasFuryBuff = Spell(207775),
    MeatCleaverBuff = Spell(280392),
    BloodFury = Spell(20572),
    Berserking = Spell(26297),
    LightsJudgment = Spell(255647),
    Fireblood = Spell(265221),
    AncestralCall = Spell(274738),

    --CUSTOM
    BattleShout = Spell(6673),
    ImpendingVictory = Spell(202168),
    StormBolt = Spell(107570),
    Victorious = Spell(32216),
    VictoryRush = Spell(34428),
    -- Defensive
    RallyingCry = Spell(97462),
    -- Utility
    Pummel = Spell(6552),
    PiercingHowl = Spell(12323),
    -- Legendaries
    FujiedasFury = Spell(207776),
    StoneHeart = Spell(225947),
    -- Misc
    UmbralMoonglaives = Spell(242553),
    SpellReflection = Spell(216890),
}

local S = RubimRH.Spell[72]

if not Item.Warrior then
    Item.Warrior = {}
end
Item.Warrior.Fury = {
    OldWar = Item(127844),
    KazzalaxFujiedasFury = Item(137053)
};

local I = Item.Warrior.Fury;

local EnemyRanges = { 5, 8 }
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

S.ExecuteDefault = Spell(5308)
S.ExecuteMassacre = Spell(280735)
local function UpdateExecuteID()
    S.Execute = S.Massacre:IsAvailable() and S.ExecuteMassacre or S.ExecuteDefault
end

local OffensiveCDs = {
    S.Avatar,
    S.Bladestorm,
    S.Recklessness,
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

local function APL()
    local Precombat, Movement, SingleTarget, AoE
    UpdateRanges()
    UpdateCDs()
    UpdateExecuteID()
    Precombat = function()
        -- flask
        -- food
        -- augmentation
        -- snapshot_stats
        -- potion
        if S.BattleShout:IsCastable() and not Player:BuffPvP(S.BattleShout) then
            return S.BattleShout:Cast()
        end
    end

    SingleTarget = function()
        -- siegebreaker
        if S.Siegebreaker:IsCastableP() and RubimRH.CDsON() then
            return S.Siegebreaker:Cast()
        end
        -- rampage,if=buff.recklessness.up|(talent.frothing_berserker.enabled|talent.carnage.enabled&(buff.enrage.remains<gcd|rage>90)|talent.massacre.enabled&(buff.enrage.remains<gcd|rage>90))
        if S.Rampage:IsReadyP() and (Player:BuffP(S.RecklessnessBuff) or (S.FrothingBerserker:IsAvailable() or S.Carnage:IsAvailable() and (Player:BuffRemainsP(S.EnrageBuff) < Player:GCD() or Player:Rage() > 90) or S.Massacre:IsAvailable() and (Player:BuffRemainsP(S.EnrageBuff) < Player:GCD() or Player:Rage() > 90))) then
            return S.Rampage:Cast()
        end
        -- execute,if=buff.enrage.up
        if S.Execute:IsCastableP() and (Player:BuffP(S.EnrageBuff)) then
            return S.Execute:Cast()
        end
        -- bloodthirst,if=buff.enrage.down
        if S.Bloodthirst:IsCastableP() and (Player:BuffDownP(S.EnrageBuff)) then
            return S.Bloodthirst:Cast()
        end
        -- raging_blow,if=charges=2
        if S.RagingBlow:IsCastableP() and (S.RagingBlow:ChargesP() == 2) then
            return S.RagingBlow:Cast()
        end
        -- bloodthirst
        if S.Bloodthirst:IsCastableP() then
            return S.Bloodthirst:Cast()
        end
        -- bladestorm,if=prev_gcd.1.rampage&(debuff.siegebreaker.up|!talent.siegebreaker.enabled)
        if S.Bladestorm:IsCastableP() and Cache.EnemiesCount[8] >= 1 and RubimRH.CDsON() and (Player:PrevGCDP(1, S.Rampage) and (Target:DebuffP(S.SiegebreakerDebuff) or not S.Siegebreaker:IsAvailable())) then
            return S.Bladestorm:Cast()
        end
        -- dragon_roar,if=buff.enrage.up
        if S.DragonRoar:IsCastableP() and Cache.EnemiesCount[8] >= 1 and RubimRH.CDsON() and (Player:BuffP(S.EnrageBuff)) then
            return S.DragonRoar:Cast()
        end
        -- raging_blow,if=talent.carnage.enabled|(talent.massacre.enabled&rage<80)|(talent.frothing_berserker.enabled&rage<90)
        if S.RagingBlow:IsCastableP() and (S.Carnage:IsAvailable() or (S.Massacre:IsAvailable() and Player:Rage() < 80) or (S.FrothingBerserker:IsAvailable() and Player:Rage() < 90)) then
            return S.RagingBlow:Cast()
        end
        -- furious_slash,if=talent.furious_slash.enabled
        if S.FuriousSlash:IsCastableP() and (S.FuriousSlash:IsAvailable()) then
            return S.FuriousSlash:Cast()
        end
        -- whirlwind
        if S.Whirlwind:IsCastableP() and Cache.EnemiesCount[8] >= 1 then
            return S.Whirlwind:Cast()
        end
    end
    -- call precombat
    if not Player:AffectingCombat() then
        local ShouldReturn = Precombat();
        if ShouldReturn then
            return ShouldReturn;
        end
    end

    if Target:MinDistanceToPlayer(true) >= 8 and Target:MinDistanceToPlayer(true) <= 40 and S.Charge:IsReady() and Target:IsQuestMob() and S.Charge:TimeSinceLastCast() >= Player:GCD() then
        return S.Charge:Cast()
    end

    -- call precombat
    if not Player:AffectingCombat() then
        if Precombat() ~= nil then
            return Precombat()
        end
        return 0, 462338
    end

    if QueueSkill() ~= nil then
        return QueueSkill()
    end

    if S.Pummel:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.Pummel:Cast()
    end

    if S.Charge:IsReady() and Target:MinDistanceToPlayer(true) >= 8 and Target:MinDistanceToPlayer(true) <= 40 then
        return S.Charge:Cast()
    end

    if S.VictoryRush:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[72].sk1 then
        return S.VictoryRush:Cast()
    end

    if S.ImpendingVictory:IsReadyMorph() and Player:HealthPercentage() <= RubimRH.db.profile[72].sk2 then
        return S.VictoryRush:Cast()
    end

    if S.RallyingCry:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[72].sk3 then
        return S.RallyingCry:Cast()
    end

    if S.Bloodthirst:IsReady() and Player:HealthPercentage() <= 80 and Player:Buff(S.EnragedRegeneration) then
        return S.Bloodthirst:Cast()
    end

    if RubimRH.TargetIsValid() then
        -- auto_attack
        -- charge
        if S.Charge:IsReady() and Target:MinDistanceToPlayer(true) >= 8 and Target:MinDistanceToPlayer(true) <= 40 then
            return S.Charge:Cast()
        end
        -- run_action_list,name=movement,if=movement.distance>5
        -- potion
        -- furious_slash,if=talent.furious_slash.enabled&(buff.furious_slash.stack<3|buff.furious_slash.remains<3|(cooldown.recklessness.remains<3&buff.furious_slash.remains<9))
        if S.FuriousSlash:IsCastableP() and (S.FuriousSlash:IsAvailable() and (Player:BuffStackP(S.FuriousSlashBuff) < 3 or Player:BuffRemainsP(S.FuriousSlashBuff) < 3 or (S.Recklessness:CooldownRemainsP() < 3 and Player:BuffRemainsP(S.FuriousSlashBuff) < 9))) then
            return S.FuriousSlash:Cast()
        end
        -- bloodthirst,if=equipped.kazzalax_fujiedas_fury&(buff.fujiedas_fury.down|remains<2)
        if S.Bloodthirst:IsCastableP() and (I.KazzalaxFujiedasFury:IsEquipped() and (Player:BuffDownP(S.FujiedasFuryBuff) or remains < 2)) then
            return S.Bloodthirst:Cast()
        end
        -- rampage,if=cooldown.recklessness.remains<3
        if S.Rampage:IsReadyP() and (S.Recklessness:CooldownRemainsP() < 3) then
            return S.Rampage:Cast()
        end
        -- recklessness
        if S.Recklessness:IsCastableP() and RubimRH.CDsON() then
            return S.Recklessness:Cast()
        end
        -- whirlwind,if=spell_targets.whirlwind>1&!buff.meat_cleaver.up
        if S.Whirlwind:IsCastableP() and (Cache.EnemiesCount[8] > 1 and S.MeatCleaverBuff:IsAvailable() and not Player:BuffP(S.MeatCleaverBuff)) then
            return S.Whirlwind:Cast()
        end

        if S.Whirlwind:IsCastableP() and (Cache.EnemiesCount[8] > 1 and not S.MeatCleaverBuff:IsAvailable() and not Player:BuffP(S.WhirlwindBuff)) then
            return S.Whirlwind:Cast()
        end

        -- blood_fury,if=buff.recklessness.up
        if S.BloodFury:IsCastableP() and RubimRH.CDsON() and (Player:BuffP(S.RecklessnessBuff)) then
            return S.BloodFury:Cast()
        end
        -- berserking,if=buff.recklessness.up
        if S.Berserking:IsCastableP() and RubimRH.CDsON() and (Player:BuffP(S.RecklessnessBuff)) then
            return S.Berserking:Cast()
        end
        -- lights_judgment,if=buff.recklessness.down
        if S.LightsJudgment:IsCastableP() and RubimRH.CDsON() and (Player:BuffDownP(S.RecklessnessBuff)) then
            return S.LightsJudgment:Cast()
        end
        -- fireblood,if=buff.recklessness.up
        if S.Fireblood:IsCastableP() and RubimRH.CDsON() and (Player:BuffP(S.RecklessnessBuff)) then
            return S.Fireblood:Cast()
        end
        -- ancestral_call,if=buff.recklessness.up
        if S.AncestralCall:IsCastableP() and RubimRH.CDsON() and (Player:BuffP(S.RecklessnessBuff)) then
            return S.AncestralCall:Cast()
        end
        -- run_action_list,name=single_target
        if (true) then
            return SingleTarget();
        end

    end
    return 0, 135328
end

RubimRH.Rotation.SetAPL(72, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(72, PASSIVE);