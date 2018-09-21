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
    -- Racials
    ArcaneTorrent = Spell(80483),
    AncestralCall = Spell(274738),
    Berserking = Spell(26297),
    BloodFury = Spell(20572),
    Fireblood = Spell(265221),
    GiftoftheNaaru = Spell(59547),
    LightsJudgment = Spell(255647),
    -- Abilities
    BattleShout = Spell(6673),
    BerserkerRage = Spell(18499),
    Bloodthirst = Spell(23881),
    Charge = Spell(100),
    Execute = Spell(5308),
    HeroicLeap = Spell(6544),
    HeroicThrow = Spell(57755),
    RagingBlow = Spell(85288),
    Rampage = Spell(184367),
    Recklessness = Spell(1719),
    VictoryRush = Spell(34428),
    Whirlwind = Spell(190411),
    WhirlwindBuff = Spell(85739),
    Enrage = Spell(184362),
    -- Talents
    WarMachine = Spell(262231),
    EndlessRage = Spell(202296),
    FreshMeat = Spell(215568),
    DoubleTime = Spell(103827),
    ImpendingVictory = Spell(202168),
    StormBolt = Spell(107570),
    InnerRage = Spell(215573),
    FuriousSlash = Spell(100130),
    FuriousSlashBuff = Spell(202539),
    Carnage = Spell(202922),
    Massacre = Spell(206315),
    FrothingBerserker = Spell(215571),
    MeatCleaverBuff = Spell(280392),
    DragonRoar = Spell(118000),
    Bladestorm = Spell(46924),
    RecklessAbandon = Spell(202751),
    AngerManagement = Spell(152278),
    Siegebreaker = Spell(280772),
    SiegebreakerDebuff = Spell(280773),
    SuddenDeath = Spell(280721),
    SuddenDeathBuff = Spell(280776),
    SuddenDeathBuffLeg = Spell(225947),
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

    AoE = function()
        --Cast Whirlwind Icon Whirlwind for two stacks of its buff.
        if S.Whirlwind:IsReady() and Player:BuffStackP(S.WhirlwindBuff) < 2 and Cache.EnemiesCount[5] >= 2 then
            return S.Whirlwind:Cast()
        end
        
        --Cast Recklessness Icon Recklessness if able.
        if S.Recklessness:IsReady() then
            return S.Recklessness:Cast()
        end
        
        --Cast Siegebreaker Icon Siegebreaker to debuff multiple targets.
        if S.Siegebreaker:IsReady() and (Player:BuffP(S.Recklessness) or S.Recklessness:CooldownRemainsP() > 20) then
            return S.Siegebreaker:Cast()
        end
        
        --Cast Rampage Icon Rampage for Enrage Icon Enrage.
        if S.Rampage:IsReady() then
            return S.Rampage:Cast()
        end
        
        --Cast Bladestorm Icon Bladestorm or Dragon Roar Icon Dragon Roar as appropriate.
        if S.Bladestorm:IsReady() then
            return S.Bladestorm:Cast()
        end
        -- dragon_roar,if=buff.enrage.up&(debuff.siegebreaker.up|!talent.siegebreaker.enabled)
        if S.DragonRoar:IsReady() and Cache.EnemiesCount[5] >= 1 then
            return S.DragonRoar:Cast()
        end
        
        --Cast Whirlwind Icon Whirlwind to refresh its buff.
        if S.Whirlwind:IsReady() and Player:BuffRemainsP(S.WhirlwindBuff) < Player:GCD() * 2 and Cache.EnemiesCount[5] >= 2 then
            return S.Whirlwind:Cast()
        end
    end

    SingleTarget = function()
        -- siegebreaker,if=buff.recklessness.up|cooldown.recklessness.remains>20
        if S.Siegebreaker:IsReady() and (Player:BuffP(S.Recklessness) or S.Recklessness:CooldownRemainsP() > 20) then
            return S.Siegebreaker:Cast()
        end
        -- rampage,if=buff.recklessness.up|(talent.frothing_berserker.enabled|talent.carnage.enabled&(buff.enrage.remains<gcd|rage>90)|talent.massacre.enabled&(buff.enrage.remains<gcd|rage>90))
        if S.Rampage:IsReady() and (Player:BuffP(S.Recklessness) or (S.FrothingBerserker:IsAvailable() or S.Carnage:IsAvailable() and (Player:BuffRemainsP(S.Enrage) < Player:GCD() or Player:Rage() > 90) or S.Massacre:IsAvailable() and (Player:BuffRemainsP(S.Enrage) < Player:GCD() or Player:Rage() > 90))) then
            return S.Rampage:Cast()
        end
        -- execute,if=buff.enrage.up
        if S.Execute:IsReadyMorph() and (Player:BuffP(S.Enrage)) then
            return S.Execute:Cast()
        end
        -- bloodthirst,if=buff.enrage.down
        if S.Bloodthirst:IsReady() and (Player:BuffDownP(S.Enrage)) then
            return S.Bloodthirst:Cast()
        end
        -- raging_blow,if=charges=2
        if S.RagingBlow:IsReady() and (S.RagingBlow:ChargesP() == 2) then
            return S.RagingBlow:Cast()
        end
        -- bloodthirst
        if S.Bloodthirst:IsReady() then
            return S.Bloodthirst:Cast()
        end
        -- bladestorm,if=prev_gcd.1.rampage&(debuff.siegebreaker.up|!talent.siegebreaker.enabled)
        if S.Bladestorm:IsReady() and (Player:PrevGCDP(1, S.Rampage) and (Target:DebuffP(S.SiegebreakerDebuff) or not S.Siegebreaker:IsAvailable())) then
            return S.Bladestorm:Cast()
        end
        -- dragon_roar,if=buff.enrage.up&(debuff.siegebreaker.up|!talent.siegebreaker.enabled)
        if S.DragonRoar:IsReady() and Cache.EnemiesCount[5] >= 1  and (Player:BuffP(S.Enrage) and (Target:DebuffP(S.SiegebreakerDebuff) or not S.Siegebreaker:IsAvailable())) then
            return S.DragonRoar:Cast()
        end
        -- raging_blow,if=talent.carnage.enabled|(talent.massacre.enabled&rage<80)|(talent.frothing_berserker.enabled&rage<90)
        if S.RagingBlow:IsReady() and (S.Carnage:IsAvailable() or (S.Massacre:IsAvailable() and Player:Rage() < 80) or (S.FrothingBerserker:IsAvailable() and Player:Rage() < 90)) then
            return S.RagingBlow:Cast()
        end
        -- furious_slash,if=talent.furious_slash.enabled
        if S.FuriousSlash:IsReady() and (S.FuriousSlash:IsAvailable()) then
            return S.FuriousSlash:Cast()
        end
        -- whirlwind
        if S.Whirlwind:IsReady() and Cache.EnemiesCount[5] >= 1 then
            return S.Whirlwind:Cast()
        end
        return 0, 135328
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

    if S.Charge:IsReady() and Target:MaxDistanceToPlayer(true) >= 8 then
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

    -- furious_slash,if=talent.furious_slash.enabled&(buff.furious_slash.stack<3|buff.furious_slash.remains<3|(cooldown.recklessness.remains<3&buff.furious_slash.remains<9))
    if S.FuriousSlash:IsReady() and (S.FuriousSlash:IsAvailable() and (Player:BuffStackP(S.FuriousSlashBuff) < 3 or Player:BuffRemainsP(S.FuriousSlashBuff) < 3 or (S.Recklessness:CooldownRemainsP() < 3 and Player:BuffRemainsP(S.FuriousSlashBuff) < 9))) then
        return S.FuriousSlash:Cast()
    end
    -- bloodthirst,if=equipped.kazzalax_fujiedas_fury&(buff.fujiedas_fury.down|remains<2)
    --if S.Bloodthirst:IsReady() and (I.KazzalaxFujiedasFury:IsEquipped() and (Player:BuffDownP(S.FujiedasFuryBuff) or remains < 2)) then
    --   return S.Bloodthirst:Cast()
    --end
    -- rampage,if=cooldown.recklessness.remains<3
    if S.Rampage:IsReady() and (S.Recklessness:CooldownRemainsP() < 3) then
        return S.Rampage:Cast()
    end
    -- recklessness
    if S.Recklessness:IsReady() then
        return S.Recklessness:Cast()
    end
    -- whirlwind,if=spell_targets.whirlwind>1&!buff.meat_cleaver.up
    if S.Whirlwind:IsReady() and (Cache.EnemiesCount[8] > 1 and not Player:BuffP(S.WhirlwindBuff)) then
        return S.Whirlwind:Cast()
    end
    -- blood_fury,if=buff.recklessness.up
    if S.BloodFury:IsReady() and RubimRH.CDsON() and (Player:BuffP(S.Recklessness)) then
        return S.BloodFury:Cast()
    end
    -- berserking,if=buff.recklessness.up
    if S.Berserking:IsReady() and RubimRH.CDsON() and (Player:BuffP(S.Recklessness)) then
        return S.Berserking:Cast()
    end
    -- arcane_torrent,if=rage<40&!buff.recklessness.up
    if S.ArcaneTorrent:IsReady() and RubimRH.CDsON() and (Player:Rage() < 40 and not Player:BuffP(S.Recklessness)) then
        return S.ArcaneTorrent:Cast()
    end
    -- lights_judgment,if=buff.recklessness.down
    if S.LightsJudgment:IsReady() and RubimRH.CDsON() and (Player:BuffDownP(S.Recklessness)) then
        return S.LightsJudgment:Cast()
    end
    -- fireblood,if=buff.recklessness.up
    if S.Fireblood:IsReady() and RubimRH.CDsON() and (Player:BuffP(S.Recklessness)) then
        return S.Fireblood:Cast()
    end
    -- ancestral_call,if=buff.recklessness.up
    if S.AncestralCall:IsReady() and RubimRH.CDsON() and (Player:BuffP(S.Recklessness)) then
        return S.AncestralCall:Cast()
    end

    -- run_action_list,name=single_target
    if (true) then
        return SingleTarget();
    end
    return 0, 135328
end


RubimRH.Rotation.SetAPL(72, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(72, PASSIVE);