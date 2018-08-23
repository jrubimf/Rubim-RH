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

RubimRH.Spell[71] = {
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
    BattleCry = Spell(1719),
    BattleCryBuff = Spell(1719),
    ColossusSmash = Spell(167105),
    ColossusSmashDebuff = Spell(208086),
    Execute = Spell(163201),
    ExecutionersPrecisionDebuff = Spell(242188),
    Cleave = Spell(845),
    CleaveBuff = Spell(231833),
    Charge = Spell(100),
    Bladestorm = Spell(227847),
    MortalStrike = Spell(12294),
    Whirlwind = Spell(1680),
    HeroicThrow = Spell(57755),
    Slam = Spell(1464),
    Massacre = Spell(206315),
    ExecuteMassacre = Spell(281000),
    Dreadnaught = Spell(262150),

    -- Talents
    SuddenDeathBuff = Spell(52437),
    Dauntless = Spell(202297),
    Avatar = Spell(107574),
    AvatarBuff = Spell(107574),
    FocusedRage = Spell(207982),
    FocusedRageBuff = Spell(207982),
    Rend = Spell(772),
    RendDebuff = Spell(772),
    Overpower = Spell(7384),
    OverpowerBuff = Spell(7384),
    Ravager = Spell(152277),
    StormBolt = Spell(107570),
    DeadlyCalm = Spell(227266),
    DeadlyCalmBuff = Spell(227266),
    FervorofBattle = Spell(202316),
    SweepingStrikes = Spell(260708),
    SweepingStrikesBuff = Spell(260708),
    AngerManagement = Spell(152278),
    InForTheKill = Spell(248621),
    InForTheKillBuff = Spell(248622),
    DeepWoundsDebuff = Spell(262111),
    -- Talents
    Skullsplitter = Spell(260643),
    Warbreaker = Spell(262161),

    -- Defensive
    RallyingCry = Spell(97462),
    DefensiveStance = Spell(197690),
    DiebytheSword = Spell(118038),
    Victorious = Spell(32216),
    VictoryRush = Spell(34428),

    -- Utility
    HeroicLeap = Spell(6544), -- Unused
    Pummel = Spell(6552),
    Hamstring = Spell(1715),
    SharpenBlade = Spell(198817),
    SpellReflection = Spell(216890),
    Shockwave = Spell(46968),
    ShatteredDefensesBuff = Spell(248625),
    PreciseStrikesBuff = Spell(209492),

    -- Legendaries
    StoneHeartBuff = Spell(225947),

    -- Misc
    WeightedBlade = Spell(253383),

};

local S = RubimRH.Spell[71]

if not Item.Warrior then
    Item.Warrior = {}
end
Item.Warrior.Arms = {
    ProlongedPower = Item(142117),
    WeightoftheEarth = Item(137077),
    ArchavonsHeavyHand = Item(137060)
};
local I = Item.Warrior.Arms;

local EnemyRanges = { "Melee", 8 }
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
    S.Avatar,
    S.Bladestorm,

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
    local Precombat, Execute, FiveTarget, SingleTarget
    UpdateRanges()
    UpdateCDs()
    Precombat = function()
        -- flask
        -- food
        -- augmentation
        -- snapshot_stats
        -- potion
        if S.BattleShout:IsReady() and not Player:Buff(S.BattleShout) then
            return S.BattleShout:Cast()
        end
    end
    Execute = function()
        -- rend,if=remains<=duration*0.3&debuff.colossus_smash.down
        if S.Rend:IsReady() and (Target:DebuffRemains(S.RendDebuff) <= S.RendDebuff:BaseDuration() * 0.3 and Target:DebuffDownP(S.ColossusSmashDebuff)) then
            return S.Rend:Cast()
        end
        -- skullsplitter,if=rage<70&((cooldown.deadly_calm.remains>3&!buff.deadly_calm.up)|!talent.deadly_calm.enabled)
        if S.Skullsplitter:IsReady() and (Player:Rage() < 70 and ((S.DeadlyCalm:CooldownRemains() > 3 and not Player:BuffP(S.DeadlyCalmBuff)) or not S.DeadlyCalm:IsAvailable())) then
            return S.Skullsplitter:Cast()
        end
        -- deadly_calm,if=cooldown.bladestorm.remains>6&((cooldown.colossus_smash.remains<2|(talent.warbreaker.enabled&cooldown.warbreaker.remains<2))|(equipped.weight_of_the_earth&cooldown.heroic_leap.remains<2))
        if S.DeadlyCalm:IsReady() and (S.Bladestorm:CooldownRemains() > 6 and ((S.ColossusSmash:CooldownRemains() < 2 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemains() < 2)) or (I.WeightoftheEarth:IsEquipped() and S.HeroicLeap:CooldownRemains() < 2))) then
            return S.DeadlyCalm:Cast()
        end
        -- colossus_smash,if=debuff.colossus_smash.down
        if S.ColossusSmash:IsReady() and (Target:DebuffDownP(S.ColossusSmashDebuff)) then
            return S.ColossusSmash:Cast()
        end
        -- warbreaker,if=debuff.colossus_smash.down
        if S.Warbreaker:IsReadyMorph() and (Target:DebuffDownP(S.ColossusSmashDebuff)) and Cache.EnemiesCount["Melee"] >= 1 then
            return S.Warbreaker:Cast()
        end
        -- heroic_leap,if=equipped.weight_of_the_earth&debuff.colossus_smash.down&((cooldown.colossus_smash.remains>8&!prev_gcd.1.colossus_smash)|(talent.warbreaker.enabled&cooldown.warbreaker.remains>8&!prev_gcd.1.warbreaker))
        if S.HeroicLeap:IsReady() and (I.WeightoftheEarth:IsEquipped() and Target:DebuffDownP(S.ColossusSmashDebuff) and ((S.ColossusSmash:CooldownRemains() > 8 and not Player:PrevGCD(1, S.ColossusSmash)) or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemains() > 8 and not Player:PrevGCD(1, S.Warbreaker)))) then
            return S.HeroicLeap:Cast()
        end
        -- bladestorm,if=debuff.colossus_smash.remains>4.5&rage<70&(!buff.deadly_calm.up|!talent.deadly_calm.enabled)
        if S.Bladestorm:IsReady() and (Target:DebuffRemains(S.ColossusSmashDebuff) > 4.5 and Player:Rage() < 70 and (not Player:BuffP(S.DeadlyCalmBuff) or not S.DeadlyCalm:IsAvailable())) then
            return S.Bladestorm:Cast()
        end
        -- ravager,if=debuff.colossus_smash.up&(cooldown.deadly_calm.remains>6|!talent.deadly_calm.enabled)
        if S.Ravager:IsReadyMorph() and (Target:Debuff(S.ColossusSmashDebuff) and (S.DeadlyCalm:CooldownRemains() > 6 or not S.DeadlyCalm:IsAvailable())) then
            return S.Ravager:Cast()
        end
        -- cleave,if=spell_targets.whirlwind>2
        if S.Cleave:IsReady() and (Cache.EnemiesCount[8] > 2) then
            return S.Cleave:Cast()
        end
        -- mortal_strike,if=buff.overpower.stack=2&(talent.dreadnaught.enabled|equipped.archavons_heavy_hand)
        if S.MortalStrike:IsReady() and (Player:BuffStackP(S.OverpowerBuff) == 2 and (S.Dreadnaught:IsAvailable() or I.ArchavonsHeavyHand:IsEquipped())) then
            return S.MortalStrike:Cast()
        end
        -- overpower
        if S.Overpower:IsReady() and (true) then
            return S.Overpower:Cast()
        end
        -- execute,if=rage>=40|debuff.colossus_smash.up|buff.sudden_death.react|buff.stone_heart.react
        if S.Execute:IsReadyMorph() and (Player:Rage() >= 40 or Target:Debuff(S.ColossusSmashDebuff) or Player:Buff(S.SuddenDeathBuff) or Player:Buff(S.StoneHeartBuff)) then
            return S.Execute:Cast()
        end

        if S.ExecuteMassacre:IsReadyMorph() and (Player:Rage() >= 40 or Target:Debuff(S.ColossusSmashDebuff) or Player:Buff(S.SuddenDeathBuff) or Player:Buff(S.StoneHeartBuff)) then
            return S.Execute:Cast()
        end
        return 0, 135328
    end
    FiveTarget = function()
        -- skullsplitter,if=rage<70&(cooldown.deadly_calm.remains>3|!talent.deadly_calm.enabled)
        if S.Skullsplitter:IsReady() and (Player:Rage() < 70 and (S.DeadlyCalm:CooldownRemains() > 3 or not S.DeadlyCalm:IsAvailable())) then
            return S.Skullsplitter:Cast()
        end
        -- deadly_calm,if=cooldown.bladestorm.remains>6&((cooldown.colossus_smash.remains<2|(talent.warbreaker.enabled&cooldown.warbreaker.remains<2))|(equipped.weight_of_the_earth&cooldown.heroic_leap.remains<2))
        if S.DeadlyCalm:IsReady() and (S.Bladestorm:CooldownRemains() > 6 and ((S.ColossusSmash:CooldownRemains() < 2 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemains() < 2)) or (I.WeightoftheEarth:IsEquipped() and S.HeroicLeap:CooldownRemains() < 2))) then
            return S.DeadlyCalm:Cast()
        end
        -- colossus_smash,if=debuff.colossus_smash.down
        if S.ColossusSmash:IsReady() and (Target:DebuffDownP(S.ColossusSmashDebuff)) then
            return S.ColossusSmash:Cast()
        end
        -- warbreaker,if=debuff.colossus_smash.down
        if S.Warbreaker:IsReadyMorph() and (Target:DebuffDownP(S.ColossusSmashDebuff)) and Cache.EnemiesCount["Melee"] >= 1 then
            return S.Warbreaker:Cast()
        end
        -- heroic_leap,if=equipped.weight_of_the_earth&debuff.colossus_smash.down&((cooldown.colossus_smash.remains>8&!prev_gcd.1.colossus_smash)|(talent.warbreaker.enabled&cooldown.warbreaker.remains>8&!prev_gcd.1.warbreaker))
        if S.HeroicLeap:IsReady() and (I.WeightoftheEarth:IsEquipped() and Target:DebuffDownP(S.ColossusSmashDebuff) and ((S.ColossusSmash:CooldownRemains() > 8 and not Player:PrevGCD(1, S.ColossusSmash)) or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemains() > 8 and not Player:PrevGCD(1, S.Warbreaker)))) then
            return S.HeroicLeap:Cast()
        end
        -- bladestorm,if=buff.sweeping_strikes.down&debuff.colossus_smash.remains>4.5&(prev_gcd.1.mortal_strike|spell_targets.whirlwind>1)&(!buff.deadly_calm.up|!talent.deadly_calm.enabled)
        if S.Bladestorm:IsReady() and (Player:BuffDownP(S.SweepingStrikesBuff) and Target:DebuffRemains(S.ColossusSmashDebuff) > 4.5 and (Player:PrevGCD(1, S.MortalStrike) or Cache.EnemiesCount[8] > 1) and (not Player:BuffP(S.DeadlyCalmBuff) or not S.DeadlyCalm:IsAvailable())) then
            return S.Bladestorm:Cast()
        end
        -- ravager,if=debuff.colossus_smash.up&(cooldown.deadly_calm.remains>6|!talent.deadly_calm.enabled)
        if S.Ravager:IsReadyMorph() and (Target:Debuff(S.ColossusSmashDebuff) and (S.DeadlyCalm:CooldownRemains() > 6 or not S.DeadlyCalm:IsAvailable())) then
            return S.Ravager:Cast()
        end
        -- cleave
        if S.Cleave:IsReady() and Cache.EnemiesCount[8] >= 1 then
            return S.Cleave:Cast()
        end
        -- execute,if=(!talent.cleave.enabled&dot.deep_wounds.remains<2)|(buff.sudden_death.react|buff.stone_heart.react)&(buff.sweeping_strikes.up|cooldown.sweeping_strikes.remains>8)
        if S.Execute:IsReadyMorph() and ((not S.Cleave:IsAvailable() and Target:DebuffRemains(S.DeepWoundsDebuff) < 2) or (Player:Buff(S.SuddenDeathBuff) or Player:Buff(S.StoneHeartBuff)) and (Player:BuffP(S.SweepingStrikesBuff) or S.SweepingStrikes:CooldownRemains() > 8)) then
            return S.Execute:Cast()
        end
        if S.ExecuteMassacre:IsReadyMorph() and ((not S.Cleave:IsAvailable() and Target:DebuffRemains(S.DeepWoundsDebuff) < 2) or (Player:Buff(S.SuddenDeathBuff) or Player:Buff(S.StoneHeartBuff)) and (Player:BuffP(S.SweepingStrikesBuff) or S.SweepingStrikes:CooldownRemains() > 8)) then
            return S.Execute:Cast()
        end
        -- mortal_strike,if=(!talent.cleave.enabled&dot.deep_wounds.remains<2)|buff.sweeping_strikes.up&buff.overpower.stack=2&(talent.dreadnaught.enabled|equipped.archavons_heavy_hand)
        if S.MortalStrike:IsReady() and ((not S.Cleave:IsAvailable() and Target:DebuffRemains(S.DeepWoundsDebuff) < 2) or Player:BuffP(S.SweepingStrikesBuff) and Player:BuffStackP(S.OverpowerBuff) == 2 and (S.Dreadnaught:IsAvailable() or I.ArchavonsHeavyHand:IsEquipped())) then
            return S.MortalStrike:Cast()
        end
        -- whirlwind,if=debuff.colossus_smash.up
        if S.Whirlwind:IsReady() and (Target:Debuff(S.ColossusSmashDebuff)) then
            return S.Whirlwind:Cast()
        end
        -- overpower
        if S.Overpower:IsReady() and (true) then
            return S.Overpower:Cast()
        end
        -- whirlwind
        if S.Whirlwind:IsReady() and (true) then
            return S.Whirlwind:Cast()
        end
        return 0, 135328
    end
    SingleTarget = function()
        -- rend,if=remains<=duration*0.3&debuff.colossus_smash.down
        if S.Rend:IsReady() and (Target:DebuffRemains(S.RendDebuff) <= S.RendDebuff:BaseDuration() * 0.3 and Target:DebuffDownP(S.ColossusSmashDebuff)) then
            return S.Rend:Cast()
        end
        -- skullsplitter,if=rage<70&(cooldown.deadly_calm.remains>3|!talent.deadly_calm.enabled)
        if S.Skullsplitter:IsReady() and (Player:Rage() < 70 and (S.DeadlyCalm:CooldownRemains() > 3 or not S.DeadlyCalm:IsAvailable())) then
            return S.Skullsplitter:Cast()
        end
        -- deadly_calm,if=cooldown.bladestorm.remains>6&((cooldown.colossus_smash.remains<2|(talent.warbreaker.enabled&cooldown.warbreaker.remains<2))|(equipped.weight_of_the_earth&cooldown.heroic_leap.remains<2))
        if S.DeadlyCalm:IsReady() and (S.Bladestorm:CooldownRemains() > 6 and ((S.ColossusSmash:CooldownRemains() < 2 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemains() < 2)) or (I.WeightoftheEarth:IsEquipped() and S.HeroicLeap:CooldownRemains() < 2))) then
            return S.DeadlyCalm:Cast()
        end
        -- colossus_smash,if=debuff.colossus_smash.down
        if S.ColossusSmash:IsReady() and (Target:DebuffDownP(S.ColossusSmashDebuff)) then
            return S.ColossusSmash:Cast()
        end
        -- warbreaker,if=debuff.colossus_smash.down
        if S.Warbreaker:IsReadyMorph() and (Target:DebuffDownP(S.ColossusSmashDebuff)) and Cache.EnemiesCount["Melee"] >= 1 then
            return S.Warbreaker:Cast()
        end
        -- heroic_leap,if=equipped.weight_of_the_earth&debuff.colossus_smash.down&((cooldown.colossus_smash.remains>8&!prev_gcd.1.colossus_smash)|(talent.warbreaker.enabled&cooldown.warbreaker.remains>8&!prev_gcd.1.warbreaker))
        if S.HeroicLeap:IsReady() and (I.WeightoftheEarth:IsEquipped() and Target:DebuffDownP(S.ColossusSmashDebuff) and ((S.ColossusSmash:CooldownRemains() > 8 and not Player:PrevGCD(1, S.ColossusSmash)) or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemains() > 8 and not Player:PrevGCD(1, S.Warbreaker)))) then
            return S.HeroicLeap:Cast()
        end

        -- execute,if=buff.sudden_death.react|buff.stone_heart.react
        if S.Execute:IsReadyMorph() and (Player:Buff(S.SuddenDeathBuff) or Player:Buff(S.StoneHeartBuff)) then
            return S.Execute:Cast()
        end
        if S.ExecuteMassacre:IsReadyMorph() and (Player:Buff(S.SuddenDeathBuff) or Player:Buff(S.StoneHeartBuff)) then
            return S.Execute:Cast()
        end

        -- bladestorm,if=buff.sweeping_strikes.down&debuff.colossus_smash.remains>4.5&(prev_gcd.1.mortal_strike|spell_targets.whirlwind>1)&(!buff.deadly_calm.up|!talent.deadly_calm.enabled)
        if S.Bladestorm:IsReady() and (Player:BuffDownP(S.SweepingStrikesBuff) and Target:DebuffRemains(S.ColossusSmashDebuff) > 4.5 and (Player:PrevGCD(1, S.MortalStrike) or Cache.EnemiesCount[8] > 1) and (not Player:BuffP(S.DeadlyCalmBuff) or not S.DeadlyCalm:IsAvailable())) then
            return S.Bladestorm:Cast()
        end
        -- ravager,if=debuff.colossus_smash.up&(cooldown.deadly_calm.remains>6|!talent.deadly_calm.enabled)
        if S.Ravager:IsReadyMorph() and (Target:Debuff(S.ColossusSmashDebuff) and (S.DeadlyCalm:CooldownRemains() > 6 or not S.DeadlyCalm:IsAvailable())) then
            return S.Ravager:Cast()
        end
        -- cleave,if=spell_targets.whirlwind>2
        if S.Cleave:IsReady() and (Cache.EnemiesCount[8] > 2) then
            return S.Cleave:Cast()
        end
        -- mortal_strike
        if S.MortalStrike:IsReady() and (true) then
            return S.MortalStrike:Cast()
        end
        -- overpower
        if S.Overpower:IsReady() and (true) then
            return S.Overpower:Cast()
        end
        -- whirlwind,if=talent.fervor_of_battle.enabled&(rage>=50|debuff.colossus_smash.up)
        if S.Whirlwind:IsReady() and (S.FervorofBattle:IsAvailable() and (Player:Rage() >= 50 or Target:Debuff(S.ColossusSmashDebuff))) then
            return S.Whirlwind:Cast()
        end
        -- slam,if=!talent.fervor_of_battle.enabled&(rage>=40|debuff.colossus_smash.up)
        if S.Slam:IsReady() and (not S.FervorofBattle:IsAvailable() and (Player:Rage() >= 40 or Target:Debuff(S.ColossusSmashDebuff))) then
            return S.Slam:Cast()
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

    -- charge
    if S.Charge:IsReady() and Target:MaxDistanceToPlayer(true) >= 8 then
        return S.Charge:Cast()
    end
    -- auto_attack
    -- potion
    -- blood_fury,if=debuff.colossus_smash.up
    -- In Combat

    if Player:Buff(S.Victorious) and S.VictoryRush:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[71].victoryrush then
        return S.VictoryRush:Cast()
    end

    if Player:Buff(S.Victorious) and Player:BuffRemains(S.Victorious) <= 2 and S.VictoryRush:IsReady() then
        return S.VictoryRush:Cast()
    end

    if S.RallyingCry:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[71].rallyingcry then
        return S.RallyingCry:Cast()
    end

    if S.BloodFury:IsReady() and RubimRH.CDsON() and (Target:Debuff(S.ColossusSmashDebuff)) then
        return S.BloodFury:Cast()
    end
    -- berserking,if=debuff.colossus_smash.up
    if S.Berserking:IsReady() and RubimRH.CDsON() and (Target:Debuff(S.ColossusSmashDebuff)) then
        return S.Berserking:Cast()
    end
    -- arcane_torrent,if=debuff.colossus_smash.down&cooldown.mortal_strike.remains>1.5&rage<50
    if S.ArcaneTorrent:IsReady() and RubimRH.CDsON() and (Target:DebuffDownP(S.ColossusSmashDebuff) and S.MortalStrike:CooldownRemains() > 1.5 and Player:Rage() < 50) then
        return S.ArcaneTorrent:Cast()
    end
    -- lights_judgment,if=debuff.colossus_smash.down
    if S.LightsJudgment:IsReady() and RubimRH.CDsON() and (Target:DebuffDownP(S.ColossusSmashDebuff)) then
        return S.LightsJudgment:Cast()
    end
    -- fireblood,if=debuff.colossus_smash.up
    if S.Fireblood:IsReady() and RubimRH.CDsON() and (Target:Debuff(S.ColossusSmashDebuff)) then
        return S.Fireblood:Cast()
    end
    -- ancestral_call,if=debuff.colossus_smash.up
    if S.AncestralCall:IsReady() and (Target:Debuff(S.ColossusSmashDebuff)) then
        return S.AncestralCall:Cast()
    end
    -- avatar,if=cooldown.colossus_smash.remains<8|(talent.warbreaker.enabled&cooldown.warbreaker.remains<8)
    if S.Avatar:IsReady() and (S.ColossusSmash:CooldownRemains() < 8 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemains() < 8)) then
        return S.Avatar:Cast()
    end
    -- sweeping_strikes,if=spell_targets.whirlwind>1
    if S.SweepingStrikes:IsReady() and (Cache.EnemiesCount[8] > 1) then
        return S.SweepingStrikes:Cast()
    end
    -- run_action_list,name=five_target,if=spell_targets.whirlwind>4
    if (Cache.EnemiesCount[8] > 4) then
        return FiveTarget();
    end
    -- run_action_list,name=execute,if=(talent.massacre.enabled&target.health.pct<35)|target.health.pct<20
    if ((S.Massacre:IsAvailable() and Target:HealthPercentage() < 35) or Target:HealthPercentage() < 20) then
        return Execute();
    end
    -- run_action_list,name=single_target
    if (true) then
        return SingleTarget();
    end
    return 0, 135328
end

RubimRH.Rotation.SetAPL(71, APL);

local function PASSIVE()
    if S.DiebytheSword:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[71].diebythesword then
        return S.DiebytheSword:Cast()
    end

    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(71, PASSIVE);