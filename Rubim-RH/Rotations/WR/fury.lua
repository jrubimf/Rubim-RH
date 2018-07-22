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
if not Spell.Warrior then
    Spell.Warrior = {};
end
Spell.Warrior.Fury = {
    -- Racials
    ArcaneTorrent                 = Spell(80483),
    AncestralCall                 = Spell(274738),
    Berserking                    = Spell(26297),
    BloodFury                     = Spell(20572),
    Fireblood                     = Spell(265221),
    GiftoftheNaaru                = Spell(59547),
    LightsJudgment                = Spell(255647),
    -- Abilities
    BattleShout                   = Spell(6673),
    BerserkerRage                 = Spell(18499),
    Bloodthirst                   = Spell(23881),
    Charge                        = Spell(100),
    Execute                       = Spell(5308),
    ExecuteMassacre               = Spell(280735),
    HeroicLeap                    = Spell(6544),
    HeroicThrow                   = Spell(57755),
    RagingBlow                    = Spell(85288),
    Rampage                       = Spell(184367),
    Recklessness                  = Spell(1719),
    VictoryRush                   = Spell(34428),
    Whirlwind                     = Spell(190411),
    WhirlwindBuff                 = Spell(85739),
    Enrage                        = Spell(184362),
    -- Talents
    WarMachine                    = Spell(262231),
    EndlessRage                   = Spell(202296),
    FreshMeat                     = Spell(215568),
    DoubleTime                    = Spell(103827),
    ImpendingVictory              = Spell(202168),
    StormBolt                     = Spell(107570),
    InnerRage                     = Spell(215573),
    FuriousSlash                  = Spell(100130),
    FuriousSlashBuff              = Spell(202539),
    Carnage                       = Spell(202922),
    Massacre                      = Spell(206315),
    FrothingBerserker             = Spell(215571),
    MeatCleaver                   = Spell(280392),
    DragonRoar                    = Spell(118000),
    Bladestorm                    = Spell(46924),
    RecklessAbandon               = Spell(202751),
    AngerManagement               = Spell(152278),
    Siegebreaker                  = Spell(280772),
    SiegebreakerDebuff            = Spell(280773),
    SuddenDeath                   = Spell(280721),
    SuddenDeathBuff               = Spell(280776),
    SuddenDeathBuffLeg            = Spell(225947),
    -- Defensive
    -- Utility
    Pummel                         = Spell(6552),
    -- Legendaries
    FujiedasFury                  = Spell(207776),
    StoneHeart                    = Spell(225947),
    -- Misc
    UmbralMoonglaives             = Spell(242553),
};
local S = Spell.Warrior.Fury;

S.SiegeBreaker.TextureSpellID = { 58984 }
-- Items
if not Item.Warrior then
    Item.Warrior = {};
end
Item.Warrior.Fury = {
    -- Legendaries
    KazzalaxFujiedasFury = Item(137053, { 15 }),
    NajentussVertebrae = Item(137087, { 6 }),
    -- Trinkets
    ConvergenceofFates = Item(140806, { 13, 14 }),
    DraughtofSouls = Item(140808, { 13, 14 }),
    UmbralMoonglaives = Item(147012, { 13, 14 }),
    -- Potions
    PotionOfProlongedPower = Item(142117),
    PotionoftheOldWar = Item(127844),
};
local I = Item.Warrior.Fury;
local T202PC, T204PC = HL.HasTier("T20");
local T212PC, T214PC = HL.HasTier("T21");

local function single_target ()
    -- actions.single_target=siegebreaker,if=buff.recklessness.up|cooldown.recklessness.remains>28
    if RubimRH.CDsON() and S.Siegebreaker:IsReady() and S.Siegebreaker:IsAvailable() and (Player:Buff(S.Recklessness) or S.Recklessness:CooldownRemainsP() > 28) then
        return S.SiegeBreaker:Cast()
    end
    -- actions.single_target+=/rampage,if=buff.recklessness.up|(talent.frothing_berserker.enabled|talent.carnage.enabled&(buff.enrage.remains<gcd|rage>90)|talent.massacre.enabled&(buff.enrage.remains<gcd|rage>90))
    if S.Rampage:IsReady() and (Player:Buff(S.Recklessness) or (S.FrothingBerserker:IsAvailable() or S.Carnage:IsAvailable() and (Player:BuffRemainsP(S.Enrage) < Player:GCD() or Player:Rage() > 90) or S.Massacre:IsAvailable() and (Player:BuffRemainsP(S.Enrage) < Player:GCD() or Player:Rage() > 90))) then
        return S.Rampage:Cast()
    end
    -- actions.single_target+=/execute,if=buff.enrage.up
    if S.Execute:IsReady() and Player:Buff(S.Enrage) then
        return S.Execute:Cast()
    end
    if S.ExecuteMassacre:IsReady() and Player:Buff(S.Enrage) then
        return S.Execute:Cast()
    end
    -- actions.single_target+=/bloodthirst,if=buff.enrage.down
    if S.Bloodthirst:IsIsReady() and not Player:Buff(S.Enrage) then
        return S.Bloodthirst:Cast()
    end
    -- actions.single_target+=/raging_blow,if=charges=2
    if S.RagingBlow:IsReady() and S.RagingBlow:Charges() == 2 then
        return S.RagingBlow:Cast()
    end
    -- actions.single_target+=/bloodthirst
    if S.Bloodthirst:IsIsReady() then
        return S.Bloodthirst:Cast()
    end
    -- actions.single_target+=/bladestorm,if=prev_gcd.1.rampage&(debuff.siegebreaker.up|!talent.siegebreaker.enabled)
    if RubimRH.CDsON() and S.Bladestorm:IsIsReady() and Player:PrevGCDP(1, S.Rampage) and (Target:Debuff(S.SiegebreakerDebuff) or not S.Siegebreaker:IsAvailable()) then
        return S.Bladestorm:Cast()
    end
    -- actions.single_target+=/dragon_roar,if=buff.enrage.up&(debuff.siegebreaker.up|!talent.siegebreaker.enabled)
    if RubimRH.CDsON() and S.DragonRoar:IsIsReady() and Player:Buff(S.Enrage) and (Target:Debuff(S.SiegebreakerDebuff) or not S.Siegebreaker:IsAvailable()) then
        return S.DragonRoar:Cast()
    end
    -- actions.single_target+=/raging_blow,if=talent.carnage.enabled|(talent.massacre.enabled&rage<80)|(talent.frothing_berserker.enabled&rage<90)
    if S.RagingBlow:IsReady() and (S.Carnage:IsAvailable() or (S.Massacre:IsAvailable() and Player:Rage() < 80) or (S.FrothingBerserker:IsAvailable() and Player:Rage() < 90)) then
        return S.RagingBlow:Cast()
    end
    -- actions.single_target+=/furious_slash,if=talent.furious_slash.enabled
    if S.FuriousSlash:IsIsReady() and S.FuriousSlash:IsAvailable() then
        return S.FuriousSlash:Cast()
    end
    -- actions.single_target+=/whirlwind
    if S.Whirlwind:IsIsReady() then
        return S.Whirlwind:Cast()
    end
end
-- APL Main
local function APL()
    -- Unit Update
    HL.GetEnemies(8);
    HL.GetEnemies(10);

    if not Player:AffectingCombat() then
        return 0, 462338
    end

    if RubimRH.TargetIsValid() then
        --- In Combat
        -- actions+=/charge
        if RubimRH.config.Spells[1].isActive and S.Charge:IsReady() and Target:IsInRange(S.Charge) then
            return S.Charge:Cast()
        end
        -- actions+=/furious_slash,if=talent.furious_slash.enabled&(buff.furious_slash.stack<3|buff.furious_slash.remains<3|(cooldown.recklessness.remains<3&buff.furious_slash.remains<9))
        if S.FuriousSlash:IsCastable() and S.FuriousSlash:IsAvailable() and (Player:BuffStack(S.FuriousSlashBuff) < 3 or Player:BuffRemainsP(S.FuriousSlashBuff) < 3 or (S.Recklessness:CooldownRemainsP() < 3 and Player:BuffRemainsP(S.FuriousSlashBuff) < 9)) then
            return S.FuriousSlash:Cast()
        end
        -- actions+=/bloodthirst,if=equipped.kazzalax_fujiedas_fury&(buff.fujiedas_fury.down|remains<2)
        if S.Bloodthirst:IsCastable() and I.KazzalaxFujiedasFury:IsEquipped() and (not Player:BuffP(S.FujiedasFury) or Player:BuffRemainsP(S.FujiedasFury) < 2) then
            return S.Bloodthirst:Cast()
        end
        -- actions+=/rampage,if=cooldown.recklessness.remains<3
        if S.Rampage:IsReady() and S.Recklessness:CooldownRemainsP() < 3 then
            return S.Rampage:Cast()
        end
        -- actions+=/recklessness
        if RubimRH.CDsON() and S.Recklessness:IsCastable() then
            return S.Recklessness:Cast()
        end
        -- actions+=/whirlwind,if=spell_targets.whirlwind>1&!buff.meat_cleaver.up
        if RubimRH.AoEON() and S.Whirlwind:IsCastable() and (Cache.EnemiesCount[8] > 1 and not Player:Buff(S.WhirlwindBuff)) then
            return S.Whirlwind:Cast()
        end
        if RubimRH.CDsON() then
            -- actions+=/arcane_torrent,if=rage<40&!buff.recklessness.up
            if S.ArcaneTorrent:IsCastable() and Player:Rage() < 40 and not Player:Buff(S.Recklessness) then
                return S.ArcaneTorrent:Cast()
            end
            -- actions+=/berserking,if=buff.recklessness.up
            if S.Berserking:IsCastable() and Player:Buff(S.Recklessness) then
                return S.Berserking:Cast()
            end
            -- actions+=/blood_fury,if=buff.recklessness.up
            if S.BloodFury:IsCastable() and Player:Buff(S.Recklessness) then
                return S.BloodFury:Cast()
            end
            -- actions+=/ancestral_call,if=buff.recklessness.up
            if S.AncestralCall:IsCastable() and Player:Buff(S.Recklessness) then
                return S.AncestralCall:Cast()
            end
            -- actions+=/fireblood,if=buff.recklessness.up
            if S.Fireblood:IsCastable() and Player:Buff(S.Recklessness) then
                return S.Fireblood:Cast()
            end
            -- actions+=/lights_judgment,if=cooldown.recklessness.remains<3
            if S.LightsJudgment:IsCastable() and S.Recklessness:CooldownRemainsP() < 3 then
                return S.LightsJudgment:cast()
            end
        end
        -- # Action list
        -- actions+=/run_action_list,name=single_target
        if single_target() ~= nil then
            return single_target()
        end
    end
    return 0, 975743
end
    RubimRH.Rotation.SetAPL(72, APL);

    local function PASSIVE()
        return RubimRH.Shared()
    end

    RubimRH.Rotation.SetPASSIVE(72, PASSIVE);