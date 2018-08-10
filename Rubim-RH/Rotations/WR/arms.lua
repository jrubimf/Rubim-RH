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

local S = RubimRH.Spell[71]

if not Item.Warrior then Item.Warrior = {} end
Item.Warrior.Arms = {
    ProlongedPower                   = Item(142117),
    WeightoftheEarth                 = Item(137077),
    ArchavonsHeavyHand               = Item(137060)
};
local I = Item.Warrior.Arms;


-- APL Variables
local function battle_cry_deadly_calm()
    if Player:Buff(S.BattleCryBuff) and S.DeadlyCalm:IsAvailable() then
        return true
    else
        return false
    end
end

local T202PC, T204PC = HL.HasTier("T20");
local T212PC, T214PC = HL.HasTier("T21");

local function five_target()
    --	actions.cleave=bladestorm,if=buff.battle_cry.up&!talent.ravager.enabled
    if S.Bladestorm:IsReady() and Player:Buff(S.BattleCry) and not S.Ravager:IsAvailable() then
        return S.Bladestorm:Cast()
    end

    --	actions.cleave+=/ravager,if=talent.ravager.enabled&cooldown.battle_cry.remains<=gcd&debuff.colossus_smash.remains>6
    if RubimRH.config.Spells[2].isActive and S.Ravager:IsReady() and (S.BattleCry:CooldownRemainsP() <= Player:GCD() and Target:DebuffRemainsP(S.ColossusSmashDebuff) > 6) then
        return S.Ravager:Cast()
    end

    --	actions.cleave+=/colossus_smash,cycle_targets=1,if=debuff.colossus_smash.down
    if S.ColossusSmash:IsReady("Melee") and not Target:Debuff(S.ColossusSmashDebuff) then
        return S.ColossusSmash:Cast()
    end

    --	actions.cleave+=/warbreaker,if=raid_event.adds.in>90&buff.shattered_defenses.down
    if Cache.EnemiesCount[8] >= 1 and RubimRH.config.Spells[1].isActive and S.Warbreaker:IsAvailable() and S.Warbreaker:IsReady() and (not Player:Buff(S.ShatteredDefensesBuff)) then
        return S.Warbreaker:Cast()
    end

    --	actions.cleave+=/focused_rage,if=rage.deficit<35&buff.focused_rage.stack<3
    if S.FocusedRage:IsReady() and Player:BuffStack(S.FocusedRageBuff) < 3 and Player:RageDeficit() < 35 then
        return S.FocusedRage:Cast()
    end

    --	actions.cleave+=/rend,cycle_targets=1,if=remains<=duration*0.3
    if S.Rend:IsReady("Melee") and (Target:DebuffRemainsP(S.RendDebuff) <= Target:DebuffDuration(S.RendDebuff) * 0.3) then
        return S.Rend:Cast()
    end

    --	actions.cleave+=/mortal_strike
    if S.MortalStrike:IsReady("Melee") then
        return S.MortalStrike:Cast()
    end

    --	actions.cleave+=/execute
    if S.Execute:IsReady("Melee") then
        return S.Execute:Cast()
    end

    if S.ExecuteMassacre:IsReady("Melee") then
        return S.Execute:Cast()
    end

    --	actions.cleave+=/cleave
    if S.Cleave:IsReady("Melee") then
        return S.Cleave:Cast()
    end

    --	actions.cleave+=/Whirlwind
    if S.Whirlwind:IsReady("Melee") then
        return S.Whirlwind:Cast()
    end
    return 0, 135328
end

local function Execute()
    -- rend,if=remains<=duration*0.3&debuff.colossus_smash.down
    if S.Rend:IsReady() and (Target:DebuffRemainsP(S.RendDebuff) <= S.RendDebuff:BaseDuration() * 0.3 and Target:DebuffDownP(S.ColossusSmashDebuff)) then
        return S.Rend:Cast()
    end
    -- skullsplitter,if=rage<70&((cooldown.deadly_calm.remains>3&!buff.deadly_calm.up)|!talent.deadly_calm.enabled)
    if S.Skullsplitter:IsReady() and (Player:Rage() < 70 and ((S.DeadlyCalm:CooldownRemainsP() > 3 and not Player:BuffP(S.DeadlyCalm)) or not S.DeadlyCalm:IsAvailable())) then
        return S.Skullsplitter:Cast()
    end
    -- deadly_calm,if=cooldown.bladestorm.remains>6&((cooldown.colossus_smash.remains<2|(talent.warbreaker.enabled&cooldown.warbreaker.remains<2))|(equipped.weight_of_the_earth&cooldown.heroic_leap.remains<2))
    if S.DeadlyCalm:IsReady() and (S.Bladestorm:CooldownRemainsP() > 6 and ((S.ColossusSmash:CooldownRemainsP() < 2 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemainsP() < 2)) or (I.WeightoftheEarth:IsEquipped() and S.HeroicLeap:CooldownRemainsP() < 2))) then
        return S.DeadlyCalm:Cast()
    end
    -- colossus_smash,if=debuff.colossus_smash.down
    if S.ColossusSmash:IsReady() and (Target:DebuffDownP(S.ColossusSmashDebuff)) then
        return S.ColossusSmash:Cast()
    end
    -- warbreaker,if=debuff.colossus_smash.down
    if S.Warbreaker:IsReady() and (Target:DebuffDownP(S.ColossusSmashDebuff)) then
        return S.Warbreaker:Cast()
    end
    -- heroic_leap,if=equipped.weight_of_the_earth&debuff.colossus_smash.down&((cooldown.colossus_smash.remains>8&!prev_gcd.1.colossus_smash)|(talent.warbreaker.enabled&cooldown.warbreaker.remains>8&!prev_gcd.1.warbreaker))
    if S.HeroicLeap:IsReady() and (I.WeightoftheEarth:IsEquipped() and Target:DebuffDownP(S.ColossusSmashDebuff) and ((S.ColossusSmash:CooldownRemainsP() > 8 and not Player:PrevGCDP(1, S.ColossusSmash)) or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemainsP() > 8 and not Player:PrevGCDP(1, S.Warbreaker)))) then
        return S.HeroicLeap:Cast()
    end
    -- bladestorm,if=debuff.colossus_smash.remains>4.5&rage<70&(!buff.deadly_calm.up|!talent.deadly_calm.enabled)
    if S.Bladestorm:IsReady() and (Target:DebuffRemainsP(S.ColossusSmashDebuff) > 4.5 and Player:Rage() < 70 and (not Player:BuffP(S.DeadlyCalm) or not S.DeadlyCalm:IsAvailable())) then
        return S.Bladestorm:Cast()
    end
    -- ravager,if=debuff.colossus_smash.up&(cooldown.deadly_calm.remains>6|!talent.deadly_calm.enabled)
    if S.Ravager:IsReady() and (Target:DebuffP(S.ColossusSmashDebuff) and (S.DeadlyCalm:CooldownRemainsP() > 6 or not S.DeadlyCalm:IsAvailable())) then
        return S.Ravager:Cast()
    end
    -- mortal_strike,if=buff.overpower.stack=2&(talent.dreadnaught.enabled|equipped.archavons_heavy_hand)
    if S.MortalStrike:IsReady() and (Player:BuffStackP(S.OverpowerBuff) == 2 and (S.Dreadnaught:IsAvailable() or I.ArchavonsHeavyHand:IsEquipped())) then
        return S.MortalStrike:Cast()
    end
    -- overpower
    if S.Overpower:IsReady() then
        return S.Overpower:Cast()
    end
    -- execute,if=rage>=40|debuff.colossus_smash.up|buff.sudden_death.react|buff.stone_heart.react
    if S.Execute:IsReady() and (Player:Rage() >= 40 or Target:DebuffP(S.ColossusSmashDebuff) or Player:Buff(S.SuddenDeathBuff) or Player:Buff(S.StoneHeartBuff)) then
        return S.Execute:Cast()
    end

    if S.ExecuteMassacre:IsReadyMorph() and (Player:Rage() >= 40 or Target:DebuffP(S.ColossusSmashDebuff) or Player:Buff(S.SuddenDeathBuff) or Player:Buff(S.StoneHeartBuff)) then
        return S.Execute:Cast()
    end
    return 0, 135328
end

local function single_target()
    -- rend,if=remains<=duration*0.3&debuff.colossus_smash.down
    if S.Rend:IsReady() and (Target:DebuffRemainsP(S.RendDebuff) <= S.RendDebuff:BaseDuration() * 0.3 and Target:DebuffDownP(S.ColossusSmashDebuff)) then
        return S.Rend:Cast()
    end
    -- skullsplitter,if=rage<70&(cooldown.deadly_calm.remains>3|!talent.deadly_calm.enabled)
    if S.Skullsplitter:IsReady() and (Player:Rage() < 70 and (S.DeadlyCalm:CooldownRemainsP() > 3 or not S.DeadlyCalm:IsAvailable())) then
        return S.Skullsplitter:Cast()
    end
    -- deadly_calm,if=cooldown.bladestorm.remains>6&((cooldown.colossus_smash.remains<2|(talent.warbreaker.enabled&cooldown.warbreaker.remains<2))|(equipped.weight_of_the_earth&cooldown.heroic_leap.remains<2))
    if S.DeadlyCalm:IsReady() and (S.Bladestorm:CooldownRemainsP() > 6 and ((S.ColossusSmash:CooldownRemainsP() < 2 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemainsP() < 2)) or (I.WeightoftheEarth:IsEquipped() and S.HeroicLeap:CooldownRemainsP() < 2))) then
        return S.DeadlyCalm:Cast()
    end
    -- colossus_smash,if=debuff.colossus_smash.down
    if S.ColossusSmash:IsReady() and (Target:DebuffDownP(S.ColossusSmashDebuff)) then
        return S.ColossusSmash:Cast()
    end
    -- warbreaker,if=debuff.colossus_smash.down
    if S.Warbreaker:IsReady() and (Target:DebuffDownP(S.ColossusSmashDebuff)) then
        return S.Warbreaker:Cast()
    end
    -- heroic_leap,if=equipped.weight_of_the_earth&debuff.colossus_smash.down&((cooldown.colossus_smash.remains>8&!prev_gcd.1.colossus_smash)|(talent.warbreaker.enabled&cooldown.warbreaker.remains>8&!prev_gcd.1.warbreaker))
    if S.HeroicLeap:IsReady() and (I.WeightoftheEarth:IsEquipped() and Target:DebuffDownP(S.ColossusSmashDebuff) and ((S.ColossusSmash:CooldownRemainsP() > 8 and not Player:PrevGCDP(1, S.ColossusSmash)) or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemainsP() > 8 and not Player:PrevGCDP(1, S.Warbreaker)))) then
        return S.HeroicLeap:Cast()
    end
    -- execute,if=buff.sudden_death.react|buff.stone_heart.react
    if S.Execute:IsReady() and (Player:Buff(S.SuddenDeathBuff) or Player:Buff(S.StoneHeartBuff)) then
        return S.Execute:Cast()
    end

    if S.ExecuteMassacre:IsReadyMorph() and (Player:Buff(S.SuddenDeathBuff) or Player:Buff(S.StoneHeartBuff)) then
        return S.Execute:Cast()
    end

    -- bladestorm,if=buff.sweeping_strikes.down&debuff.colossus_smash.remains>4.5&(prev_gcd.1.mortal_strike|spell_targets.whirlwind>1)&(!buff.deadly_calm.up|!talent.deadly_calm.enabled)
    if S.Bladestorm:IsReady() and (Player:BuffDownP(S.SweepingStrikes) and Target:DebuffRemainsP(S.ColossusSmashDebuff) > 4.5 and (Player:PrevGCDP(1, S.MortalStrike) or Cache.EnemiesCount[8] > 1) and (not Player:BuffP(S.DeadlyCalm) or not S.DeadlyCalm:IsAvailable())) then
        return S.Bladestorm:Cast()
    end
    -- ravager,if=debuff.colossus_smash.up&(cooldown.deadly_calm.remains>6|!talent.deadly_calm.enabled)
    if S.Ravager:IsReady() and (Target:DebuffP(S.ColossusSmashDebuff) and (S.DeadlyCalm:CooldownRemainsP() > 6 or not S.DeadlyCalm:IsAvailable())) then
        return S.Ravager:Cast()
    end
    -- mortal_strike
    if S.MortalStrike:IsReady() then
        return S.MortalStrike:Cast()
    end
    -- overpower
    if S.Overpower:IsReady() then
        return S.Overpower:Cast()
    end
    -- whirlwind,if=talent.fervor_of_battle.enabled&(rage>=50|debuff.colossus_smash.up)
    if S.Whirlwind:IsReady() and (S.FervorofBattle:IsAvailable() and (Player:Rage() >= 50 or Target:DebuffP(S.ColossusSmashDebuff))) then
        return S.Whirlwind:Cast()
    end
    -- slam,if=!talent.fervor_of_battle.enabled&(rage>=40|debuff.colossus_smash.up)
    if S.Slam:IsReady() and (not S.FervorofBattle:IsAvailable() and (Player:Rage() >= 40 or Target:DebuffP(S.ColossusSmashDebuff))) then
        return S.Slam:Cast()
    end
    return 0, 135328
end

local function APL()
    -- Unit Update
    HL.GetEnemies(8); -- Whirlwind
    -- Out of Combat

    if not Player:AffectingCombat() then

        if S.BattleShout:IsReady() and not Player:Buff(S.BattleShout) then
            return S.BattleShout:Cast()
        end

        return 0, 462338
    end

    -- In Combat
    if RubimRH.config.Spells[3].isActive and S.Charge:IsReady() and Target:IsInRange(S.Charge) then
        return S.Charge:Cast()
    end

    if Player:Buff(S.Victorious) and S.VictoryRush:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[71].victoryrush then
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

    -- Racial
    -- actions+=/blood_fury,if=buff.battle_cry.up|target.time_to_die<=16
    -- blood_fury,if=debuff.colossus_smash.up
    if S.BloodFury:IsReady() and RubimRH.CDsON() and (Target:DebuffP(S.ColossusSmashDebuff)) then
        return S.BloodFury:Cast()
    end
    -- berserking,if=debuff.colossus_smash.up
    if S.Berserking:IsReady() and RubimRH.CDsON() and (Target:DebuffP(S.ColossusSmashDebuff)) then
        return S.Berserking:Cast()
    end
    -- arcane_torrent,if=debuff.colossus_smash.down&cooldown.mortal_strike.remains>1.5&rage<50
    if S.ArcaneTorrent:IsReady() and RubimRH.CDsON() and (Target:DebuffDownP(S.ColossusSmashDebuff) and S.MortalStrike:CooldownRemainsP() > 1.5 and Player:Rage() < 50) then
        return S.ArcaneTorrent:Cast()
    end
    -- lights_judgment,if=debuff.colossus_smash.down
    if S.LightsJudgment:IsReady() and RubimRH.CDsON() and (Target:DebuffDownP(S.ColossusSmashDebuff)) then
        return S.LightsJudgment:Cast()
    end
    -- avatar,if=cooldown.colossus_smash.remains<8|(talent.warbreaker.enabled&cooldown.warbreaker.remains<8)
    if S.Avatar:IsReady() and (S.ColossusSmash:CooldownRemainsP() < 8 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemainsP() < 8)) then
        return S.Avatar:Cast()
    end
    -- sweeping_strikes,if=spell_targets.whirlwind>1
    if S.SweepingStrikes:IsReady() and (Cache.EnemiesCount[8] > 1) then
        return S.SweepingStrikes:Cast()
    end
    -- run_action_list,name=five_target,if=spell_targets.whirlwind>4
    if (Cache.EnemiesCount[8] > 4) then
        return five_target();
    end
    -- run_action_list,name=execute,if=(talent.massacre.enabled&target.health.pct<35)|target.health.pct<20
    if ((S.Massacre:IsAvailable() and Target:HealthPercentage() < 35) or Target:HealthPercentage() < 20) then
        return Execute();
    end
    -- run_action_list,name=single_target
    return single_target()
end
RubimRH.Rotation.SetAPL(71, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(71, PASSIVE);