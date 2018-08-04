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
local S = RubimRH.Spell[72]

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
        return S.Siegebreaker:Cast()
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
    if S.Bloodthirst:IsReady() and not Player:Buff(S.Enrage) then
        return S.Bloodthirst:Cast()
    end
    -- actions.single_target+=/raging_blow,if=charges=2
    if S.RagingBlow:IsReady() and S.RagingBlow:Charges() == 2 then
        return S.RagingBlow:Cast()
    end
    -- actions.single_target+=/bloodthirst
    if S.Bloodthirst:IsReady() then
        return S.Bloodthirst:Cast()
    end
    -- actions.single_target+=/bladestorm,if=prev_gcd.1.rampage&(debuff.siegebreaker.up|!talent.siegebreaker.enabled)
    if RubimRH.CDsON() and S.Bladestorm:IsReady() and Player:PrevGCDP(1, S.Rampage) and (Target:Debuff(S.SiegebreakerDebuff) or not S.Siegebreaker:IsAvailable()) then
        return S.Bladestorm:Cast()
    end
    -- actions.single_target+=/dragon_roar,if=buff.enrage.up&(debuff.siegebreaker.up|!talent.siegebreaker.enabled)
    if RubimRH.CDsON() and S.DragonRoar:IsReady() and Player:Buff(S.Enrage) and (Target:Debuff(S.SiegebreakerDebuff) or not S.Siegebreaker:IsAvailable()) then
        return S.DragonRoar:Cast()
    end
    -- actions.single_target+=/raging_blow,if=talent.carnage.enabled|(talent.massacre.enabled&rage<80)|(talent.frothing_berserker.enabled&rage<90)
    if S.RagingBlow:IsReady() and (S.Carnage:IsAvailable() or (S.Massacre:IsAvailable() and Player:Rage() < 80) or (S.FrothingBerserker:IsAvailable() and Player:Rage() < 90)) then
        return S.RagingBlow:Cast()
    end
    -- actions.single_target+=/furious_slash,if=talent.furious_slash.enabled
    if S.FuriousSlash:IsReady() and S.FuriousSlash:IsAvailable() then
        return S.FuriousSlash:Cast()
    end
    -- actions.single_target+=/whirlwind
    if S.Whirlwind:IsReady() then
        return S.Whirlwind:Cast()
    end
end
-- APL Main
local function APL()
    -- Unit Update
    HL.GetEnemies(8);
    HL.GetEnemies(10);

    if not Player:AffectingCombat() then
        if not Player:Buff(S.BattleShout) then
            return S.BattleShout:Cast()
        end

        return 0, 462338
    end

    if RubimRH.TargetIsValid() then
        --- In Combat
        -- actions+=/charge
        if RubimRH.config.Spells[1].isActive and S.Charge:IsReady() and Target:IsInRange(S.Charge) then
            return S.Charge:Cast()
        end

        if Player:Buff(S.Victorious) and S.VictoryRush:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[72].victoryrush then
            return S.VictoryRush:Cast()
        end

        if Player:Buff(S.Victorious) and Player:BuffRemains(S.Victorious) <= 2 and S.VictoryRush:IsReady() then
            return S.VictoryRush:Cast()
        end

        if S.DiebytheSword:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[71].diebythesword then
            return S.DiebytheSword:Cast()
        end

        if S.RallyingCry:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[71].rallyingcry then
            return S.RallyingCry:Cast()
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
                return S.LightsJudgment:Cast()
            end
        end
        -- # Action list
        -- actions+=/run_action_list,name=single_target
        if single_target() ~= nil then
            return single_target()
        end
    end
    return 0, 135328
end

RubimRH.Rotation.SetAPL(72, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(72, PASSIVE);