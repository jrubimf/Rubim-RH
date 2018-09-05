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
    Skullsplitter = Spell(260643),
    DeadlyCalm = Spell(262228),
    DeadlyCalmBuff = Spell(262228),
    Bladestorm = Spell(227847),
    ColossusSmash = Spell(167105),
    Warbreaker = Spell(262161),
    Ravager = Spell(152277),
    ColossusSmashDebuff = Spell(208086),
    Cleave = Spell(845),
    Slam = Spell(1464),
    CrushingAssaultBuff = Spell(278826),
    MortalStrike = Spell(12294),
    OverpowerBuff = Spell(7384),
    Dreadnaught = Spell(262150),
    ExecutionersPrecisionBuff = Spell(242188),
    Overpower = Spell(7384),
    Execute = Spell(163201),
    SweepingStrikesBuff = Spell(260708),
    TestofMight = Spell(275529),
    TestofMightBuff = Spell(275540),
    DeepWoundsDebuff = Spell(262115),
    SuddenDeathBuff = Spell(52437),
    StoneHeartBuff = Spell(225947),
    SweepingStrikes = Spell(260708),
    Whirlwind = Spell(1680),
    FervorofBattle = Spell(202316),
    Rend = Spell(772),
    RendDebuff = Spell(772),
    AngerManagement = Spell(152278),
    SeismicWave = Spell(277639),
    Charge = Spell(100),
    BloodFury = Spell(20572),
    Berserking = Spell(26297),
    ArcaneTorrent = Spell(50613),
    LightsJudgment = Spell(255647),
    Fireblood = Spell(265221),
    AncestralCall = Spell(274738),
    Avatar = Spell(107574),
    Massacre = Spell(281001),

    -- Defensive
    RallyingCry = Spell(97462),
    DefensiveStance = Spell(197690),
    DiebytheSword = Spell(118038),
    Victorious = Spell(32216),
    VictoryRush = Spell(34428),
    ImpendingVictory = Spell(202168),

    -- Utility
    HeroicLeap = Spell(6544), -- Unused
    Disarm = Spell(236077),
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

    -- Azeriet
    TestofMight = Spell(275529),
    TestofMightBuff = Spell(275540),
    SeismicWave = Spell(277639),

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

S.ExecuteDefault = Spell(163201)
S.ExecuteMassacre = Spell(281000)

local function UpdateExecuteID()
    S.Execute = S.Massacre:IsAvailable() and S.ExecuteMassacre or S.ExecuteDefault
end

local function APL()
    local Precombat, Execute, FiveTarget, Hac, SingleTarget
    UpdateRanges()
    UpdateCDs()
    UpdateExecuteID()
    print(S.Execute:IsReadyMorph())
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
        -- skullsplitter,if=rage<60&((cooldown.deadly_calm.remains>3&!buff.deadly_calm.up)|!talent.deadly_calm.enabled)
        if S.Skullsplitter:IsReady() and (Player:Rage() < 60 and ((S.DeadlyCalm:CooldownRemainsP() > 3 and not Player:BuffP(S.DeadlyCalmBuff)) or not S.DeadlyCalm:IsAvailable())) then
            return S.Skullsplitter:Cast()
        end
        -- deadly_calm,if=cooldown.bladestorm.remains>6&(cooldown.colossus_smash.remains<2|(talent.warbreaker.enabled&cooldown.warbreaker.remains<2))
        if S.DeadlyCalm:IsReady() and (S.Bladestorm:CooldownRemainsP() > 6 and (S.ColossusSmash:CooldownRemainsP() < 2 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemainsP() < 2))) then
            return S.DeadlyCalm:Cast()
        end
        -- ravager,if=!buff.deadly_calm.up&(cooldown.colossus_smash.remains<2|(talent.warbreaker.enabled&cooldown.warbreaker.remains<2))
        if S.Ravager:IsReadyMorph() and (not Player:BuffP(S.DeadlyCalmBuff) and (S.ColossusSmash:CooldownRemainsP() < 2 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemainsP() < 2))) then
            return S.Ravager:Cast()
        end
        -- colossus_smash,if=debuff.colossus_smash.down
        if S.ColossusSmash:IsReady() and (Target:DebuffDownP(S.ColossusSmashDebuff)) then
            return S.ColossusSmash:Cast()
        end
        -- warbreaker,if=debuff.colossus_smash.down
        if S.Warbreaker:IsReadyMorph() and (Target:DebuffDownP(S.ColossusSmashDebuff)) then
            return S.Warbreaker:Cast()
        end
        -- bladestorm,if=rage<30&!buff.deadly_calm.up
        if S.Bladestorm:IsReady() and (Player:Rage() < 30 and not Player:BuffP(S.DeadlyCalmBuff)) then
            return S.Bladestorm:Cast()
        end
        -- cleave,if=spell_targets.whirlwind>2
        if S.Cleave:IsReady() and (Cache.EnemiesCount[8] > 2) then
            return S.Cleave:Cast()
        end
        -- slam,if=buff.crushing_assault.up
        if S.Slam:IsReady() and (Player:BuffP(S.CrushingAssaultBuff)) then
            return S.Slam:Cast()
        end
        -- mortal_strike,if=debuff.colossus_smash.up&buff.overpower.stack=2&(talent.dreadnaught.enabled|buff.executioners_precision.stack=2)
        if S.MortalStrike:IsReady() and (Target:DebuffP(S.ColossusSmashDebuff) and Player:BuffStackP(S.OverpowerBuff) == 2 and (S.Dreadnaught:IsAvailable() or Player:BuffStackP(S.ExecutionersPrecisionBuff) == 2)) then
            return S.MortalStrike:Cast()
        end
        -- overpower
        if S.Overpower:IsReady() then
            return S.Overpower:Cast()
        end
        -- execute
        if S.Execute:IsReadyMorph() then
            return S.Execute:Cast()
        end
        return 0, 135328
    end
    FiveTarget = function()
        -- skullsplitter,if=rage<60&(cooldown.deadly_calm.remains>3|!talent.deadly_calm.enabled)
        if S.Skullsplitter:IsReady() and (Player:Rage() < 60 and (S.DeadlyCalm:CooldownRemainsP() > 3 or not S.DeadlyCalm:IsAvailable())) then
            return S.Skullsplitter:Cast()
        end
        -- deadly_calm,if=cooldown.bladestorm.remains>6&(cooldown.colossus_smash.remains<2|(talent.warbreaker.enabled&cooldown.warbreaker.remains<2))
        if S.DeadlyCalm:IsReady() and (S.Bladestorm:CooldownRemainsP() > 6 and (S.ColossusSmash:CooldownRemainsP() < 2 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemainsP() < 2))) then
            return S.DeadlyCalm:Cast()
        end
        -- ravager,if=!buff.deadly_calm.up&(cooldown.colossus_smash.remains<2|(talent.warbreaker.enabled&cooldown.warbreaker.remains<2))
        if S.Ravager:IsReadyMorph() and (not Player:BuffP(S.DeadlyCalmBuff) and (S.ColossusSmash:CooldownRemainsP() < 2 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemainsP() < 2))) then
            return S.Ravager:Cast()
        end
        -- colossus_smash,if=debuff.colossus_smash.down
        if S.ColossusSmash:IsReady() and (Target:DebuffDownP(S.ColossusSmashDebuff)) then
            return S.ColossusSmash:Cast()
        end
        -- warbreaker,if=debuff.colossus_smash.down
        if S.Warbreaker:IsReadyMorph() and (Target:DebuffDownP(S.ColossusSmashDebuff)) then
            return S.Warbreaker:Cast()
        end
        -- bladestorm,if=buff.sweeping_strikes.down&!buff.deadly_calm.up&((debuff.colossus_smash.remains>4.5&!azerite.test_of_might.enabled)|buff.test_of_might.up)
        if S.Bladestorm:IsReady() and (Player:BuffDownP(S.SweepingStrikesBuff) and not Player:BuffP(S.DeadlyCalmBuff) and ((Target:DebuffRemainsP(S.ColossusSmashDebuff) > 4.5 and not S.TestofMight:AzeriteEnabled()) or Player:BuffP(S.TestofMightBuff))) then
            return S.Bladestorm:Cast()
        end
        -- cleave
        if S.Cleave:IsReady() then
            return S.Cleave:Cast()
        end
        -- execute,if=(!talent.cleave.enabled&dot.deep_wounds.remains<2)|(buff.sudden_death.react|buff.stone_heart.react)&(buff.sweeping_strikes.up|cooldown.sweeping_strikes.remains>8)
        if S.Execute:IsReadyMorph() and ((not S.Cleave:IsAvailable() and Target:DebuffRemainsP(S.DeepWoundsDebuff) < 2) or (bool(Player:Buff(S.SuddenDeathBuff)) or bool(Player:Buff(S.StoneHeartBuff))) and (Player:BuffP(S.SweepingStrikesBuff) or S.SweepingStrikes:CooldownRemainsP() > 8)) then
            return S.Execute:Cast()
        end
        -- mortal_strike,if=(!talent.cleave.enabled&dot.deep_wounds.remains<2)|buff.sweeping_strikes.up&buff.overpower.stack=2&(talent.dreadnaught.enabled|buff.executioners_precision.stack=2)
        if S.MortalStrike:IsReady() and ((not S.Cleave:IsAvailable() and Target:DebuffRemainsP(S.DeepWoundsDebuff) < 2) or Player:BuffP(S.SweepingStrikesBuff) and Player:BuffStackP(S.OverpowerBuff) == 2 and (S.Dreadnaught:IsAvailable() or Player:BuffStackP(S.ExecutionersPrecisionBuff) == 2)) then
            return S.MortalStrike:Cast()
        end
        -- whirlwind,if=debuff.colossus_smash.up|(buff.crushing_assault.up&talent.fervor_of_battle.enabled)
        if S.Whirlwind:IsReady() and (Target:DebuffP(S.ColossusSmashDebuff) or (Player:BuffP(S.CrushingAssaultBuff) and S.FervorofBattle:IsAvailable())) then
            return S.Whirlwind:Cast()
        end
        -- overpower
        if S.Overpower:IsReady() then
            return S.Overpower:Cast()
        end
        -- whirlwind
        if S.Whirlwind:IsReady() then
            return S.Whirlwind:Cast()
        end
        return 0, 135328
    end
    Hac = function()
        -- rend,if=remains<=duration*0.3&(!raid_event.adds.up|buff.sweeping_strikes.up)
        if S.Rend:IsReady() and (Target:DebuffRemainsP(S.RendDebuff) <= S.RendDebuff:BaseDuration() * 0.3 and (not (Cache.EnemiesCount[8] > 1) or Player:BuffP(S.SweepingStrikesBuff))) then
            return S.Rend:Cast()
        end
        -- skullsplitter,if=rage<60&(cooldown.deadly_calm.remains>3|!talent.deadly_calm.enabled)
        if S.Skullsplitter:IsReady() and (Player:Rage() < 60 and (S.DeadlyCalm:CooldownRemainsP() > 3 or not S.DeadlyCalm:IsAvailable())) then
            return S.Skullsplitter:Cast()
        end
        -- deadly_calm,if=(cooldown.bladestorm.remains>6|talent.ravager.enabled&cooldown.ravager.remains>6)&(cooldown.colossus_smash.remains<2|(talent.warbreaker.enabled&cooldown.warbreaker.remains<2))
        if S.DeadlyCalm:IsReady() and ((S.Bladestorm:CooldownRemainsP() > 6 or S.Ravager:IsAvailable() and S.Ravager:CooldownRemainsP() > 6) and (S.ColossusSmash:CooldownRemainsP() < 2 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemainsP() < 2))) then
            return S.DeadlyCalm:Cast()
        end
        -- ravager,if=(raid_event.adds.up|raid_event.adds.in>target.time_to_die)&(cooldown.colossus_smash.remains<2|(talent.warbreaker.enabled&cooldown.warbreaker.remains<2))
        if S.Ravager:IsReadyMorph() and (((Cache.EnemiesCount[8] > 1) or 10000000000 > Target:TimeToDie()) and (S.ColossusSmash:CooldownRemainsP() < 2 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemainsP() < 2))) then
            return S.Ravager:Cast()
        end
        -- colossus_smash,if=raid_event.adds.up|raid_event.adds.in>40|(raid_event.adds.in>20&talent.anger_management.enabled)
        if S.ColossusSmash:IsReady() and ((Cache.EnemiesCount[8] > 1) or 10000000000 > 40 or (10000000000 > 20 and S.AngerManagement:IsAvailable())) then
            return S.ColossusSmash:Cast()
        end
        -- warbreaker,if=raid_event.adds.up|raid_event.adds.in>40|(raid_event.adds.in>20&talent.anger_management.enabled)
        if S.Warbreaker:IsReadyMorph() and ((Cache.EnemiesCount[8] > 1) or 10000000000 > 40 or (10000000000 > 20 and S.AngerManagement:IsAvailable())) then
            return S.Warbreaker:Cast()
        end
        -- bladestorm,if=(debuff.colossus_smash.up&raid_event.adds.in>target.time_to_die)|raid_event.adds.up&((debuff.colossus_smash.remains>4.5&!azerite.test_of_might.enabled)|buff.test_of_might.up)
        if S.Bladestorm:IsReady() and ((Target:DebuffP(S.ColossusSmashDebuff) and 10000000000 > Target:TimeToDie()) or (Cache.EnemiesCount[8] > 1) and ((Target:DebuffRemainsP(S.ColossusSmashDebuff) > 4.5 and not S.TestofMight:AzeriteEnabled()) or Player:BuffP(S.TestofMightBuff))) then
            return S.Bladestorm:Cast()
        end
        -- overpower,if=!raid_event.adds.up|(raid_event.adds.up&azerite.seismic_wave.enabled)
        if S.Overpower:IsReady() and (not (Cache.EnemiesCount[8] > 1) or ((Cache.EnemiesCount[8] > 1) and S.SeismicWave:AzeriteEnabled())) then
            return S.Overpower:Cast()
        end
        -- cleave,if=spell_targets.whirlwind>2
        if S.Cleave:IsReady() and (Cache.EnemiesCount[8] > 2) then
            return S.Cleave:Cast()
        end
        -- execute,if=!raid_event.adds.up|(!talent.cleave.enabled&dot.deep_wounds.remains<2)|buff.sudden_death.react
        if S.Execute:IsReadyMorph() and (not (Cache.EnemiesCount[8] > 1) or (not S.Cleave:IsAvailable() and Target:DebuffRemainsP(S.DeepWoundsDebuff) < 2) or bool(Player:Buff(S.SuddenDeathBuff))) then
            return S.Execute:Cast()
        end
        -- mortal_strike,if=!raid_event.adds.up|(!talent.cleave.enabled&dot.deep_wounds.remains<2)
        if S.MortalStrike:IsReady() and (not (Cache.EnemiesCount[8] > 1) or (not S.Cleave:IsAvailable() and Target:DebuffRemainsP(S.DeepWoundsDebuff) < 2)) then
            return S.MortalStrike:Cast()
        end
        -- whirlwind,if=raid_event.adds.up
        if S.Whirlwind:IsReady() and ((Cache.EnemiesCount[8] > 1)) then
            return S.Whirlwind:Cast()
        end
        -- overpower
        if S.Overpower:IsReady() then
            return S.Overpower:Cast()
        end
        -- whirlwind,if=talent.fervor_of_battle.enabled
        if S.Whirlwind:IsReady() and (S.FervorofBattle:IsAvailable()) then
            return S.Whirlwind:Cast()
        end
        -- slam,if=!talent.fervor_of_battle.enabled&!raid_event.adds.up
        if S.Slam:IsReady() and (not S.FervorofBattle:IsAvailable() and not (Cache.EnemiesCount[8] > 1)) then
            return S.Slam:Cast()
        end
    end
    SingleTarget = function()
        -- rend,if=remains<=duration*0.3&debuff.colossus_smash.down
        if S.Rend:IsReady() and (Target:DebuffRemainsP(S.RendDebuff) <= S.RendDebuff:BaseDuration() * 0.3 and Target:DebuffDownP(S.ColossusSmashDebuff)) then
            return S.Rend:Cast()
        end
        -- skullsplitter,if=rage<60&(cooldown.deadly_calm.remains>3|!talent.deadly_calm.enabled)
        if S.Skullsplitter:IsReady() and (Player:Rage() < 60 and (S.DeadlyCalm:CooldownRemainsP() > 3 or not S.DeadlyCalm:IsAvailable())) then
            return S.Skullsplitter:Cast()
        end
        -- deadly_calm,if=(cooldown.bladestorm.remains>6|talent.ravager.enabled&cooldown.ravager.remains>6)&(cooldown.colossus_smash.remains<2|(talent.warbreaker.enabled&cooldown.warbreaker.remains<2))
        if S.DeadlyCalm:IsReady() and ((S.Bladestorm:CooldownRemainsP() > 6 or S.Ravager:IsAvailable() and S.Ravager:CooldownRemainsP() > 6) and (S.ColossusSmash:CooldownRemainsP() < 2 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemainsP() < 2))) then
            return S.DeadlyCalm:Cast()
        end
        -- ravager,if=!buff.deadly_calm.up&(cooldown.colossus_smash.remains<2|(talent.warbreaker.enabled&cooldown.warbreaker.remains<2))
        if S.Ravager:IsReadyMorph() and (not Player:BuffP(S.DeadlyCalmBuff) and (S.ColossusSmash:CooldownRemainsP() < 2 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemainsP() < 2))) then
            return S.Ravager:Cast()
        end
        -- colossus_smash,if=debuff.colossus_smash.down
        if S.ColossusSmash:IsReady() and (Target:DebuffDownP(S.ColossusSmashDebuff)) then
            return S.ColossusSmash:Cast()
        end
        -- warbreaker,if=debuff.colossus_smash.down
        if S.Warbreaker:IsReadyMorph() and (Target:DebuffDownP(S.ColossusSmashDebuff)) then
            return S.Warbreaker:Cast()
        end
        -- execute,if=buff.sudden_death.react
        if S.Execute:IsReadyMorph() and (bool(Player:Buff(S.SuddenDeathBuff))) then
            return S.Execute:Cast()
        end
        -- bladestorm,if=cooldown.mortal_strike.remains&((debuff.colossus_smash.up&!azerite.test_of_might.enabled)|buff.test_of_might.up)
        if S.Bladestorm:IsReady() and (bool(S.MortalStrike:CooldownRemainsP()) and ((Target:DebuffP(S.ColossusSmashDebuff) and not S.TestofMight:AzeriteEnabled()) or Player:BuffP(S.TestofMightBuff))) then
            return S.Bladestorm:Cast()
        end
        -- cleave,if=spell_targets.whirlwind>2
        if S.Cleave:IsReady() and (Cache.EnemiesCount[8] > 2) then
            return S.Cleave:Cast()
        end
        -- overpower,if=azerite.seismic_wave.rank=3
        if S.Overpower:IsReady() and (S.SeismicWave:AzeriteRank() == 3) then
            return S.Overpower:Cast()
        end
        -- mortal_strike
        if S.MortalStrike:IsReady() then
            return S.MortalStrike:Cast()
        end
        -- overpower
        if S.Overpower:IsReady() then
            return S.Overpower:Cast()
        end
        -- whirlwind,if=talent.fervor_of_battle.enabled&(!azerite.test_of_might.enabled|(rage>=60|debuff.colossus_smash.up|buff.deadly_calm.up))
        if S.Whirlwind:IsReady() and (S.FervorofBattle:IsAvailable() and (not S.TestofMight:AzeriteEnabled() or (Player:Rage() >= 60 or Target:DebuffP(S.ColossusSmashDebuff) or Player:BuffP(S.DeadlyCalmBuff)))) then
            return S.Whirlwind:Cast()
        end
        -- slam,if=!talent.fervor_of_battle.enabled&(!azerite.test_of_might.enabled|(rage>=60|debuff.colossus_smash.up|buff.deadly_calm.up))
        if S.Slam:IsReady() and (not S.FervorofBattle:IsAvailable() and (not S.TestofMight:AzeriteEnabled() or (Player:Rage() >= 60 or Target:DebuffP(S.ColossusSmashDebuff) or Player:BuffP(S.DeadlyCalmBuff)))) then
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

    if S.VictoryRush:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[71].sk1 then
        return S.VictoryRush:Cast()
    end

    if S.ImpendingVictory:IsReadyMorph() and Player:HealthPercentage() <= RubimRH.db.profile[71].sk2 then
        return S.VictoryRush:Cast()
    end

    if S.RallyingCry:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[71].sk4 then
        return S.RallyingCry:Cast()
    end

    if S.Pummel:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() then
        return S.Pummel:Cast()
    end

    if S.BloodFury:IsReady() and RubimRH.CDsON() and (Target:Debuff(S.ColossusSmashDebuff)) then
        return S.BloodFury:Cast()
    end

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
    -- fireblood,if=debuff.colossus_smash.up
    if S.Fireblood:IsReady() and RubimRH.CDsON() and (Target:DebuffP(S.ColossusSmashDebuff)) then
        return S.Fireblood:Cast()
    end
    -- ancestral_call,if=debuff.colossus_smash.up
    if S.AncestralCall:IsReady() and RubimRH.CDsON() and (Target:DebuffP(S.ColossusSmashDebuff)) then
        return S.AncestralCall:Cast()
    end
    -- avatar,if=cooldown.colossus_smash.remains<8|(talent.warbreaker.enabled&cooldown.warbreaker.remains<8)
    if S.Avatar:IsReady() and RubimRH.CDsON() and (S.ColossusSmash:CooldownRemainsP() < 8 or (S.Warbreaker:IsAvailable() and S.Warbreaker:CooldownRemainsP() < 8)) then
        return S.Avatar:Cast()
    end
    -- sweeping_strikes,if=spell_targets.whirlwind>1&(cooldown.bladestorm.remains>10|cooldown.colossus_smash.remains>8|azerite.test_of_might.enabled)
    if S.SweepingStrikes:IsReady() and (Cache.EnemiesCount[8] > 1 and (S.Bladestorm:CooldownRemainsP() > 10 or S.ColossusSmash:CooldownRemainsP() > 8 or S.TestofMight:AzeriteEnabled())) then
        return S.SweepingStrikes:Cast()
    end
    -- run_action_list,name=five_target,if=spell_targets.whirlwind>4
    if (Cache.EnemiesCount[8] > 4) then
        return FiveTarget();
    end

    --TODO: WHATS IS THIS??
    -- run_action_list,name=hac,if=raid_event.adds.exists
    if ((Cache.EnemiesCount[8] > 1)) then
        return Hac();
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
    if S.DiebytheSword:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[71].sk3 then
        return S.DiebytheSword:Cast()
    end

    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(71, PASSIVE);