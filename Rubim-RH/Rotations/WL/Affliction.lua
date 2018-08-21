--- Last Edit: S0latium : 7/25/18
--- BfA Affliction v1.0.0
local addonName, addonTable = ...
-- HeroLib
local HL = HeroLib
local Cache = HeroCache
local Unit = HL.Unit
local Player = Unit.Player
local Target = Unit.Target
local Spell = HL.Spell

RubimRH.Spell[265] = {
    SummonPet = Spell(691),
    GrimoireofSacrificeBuff = Spell(196099),
    GrimoireofSacrifice = Spell(108503),
    SeedofCorruption = Spell(27243),
    HauntDebuff = Spell(48181),
    Haunt = Spell(48181),
    ShadowBolt = Spell(232670),
    SummonDarkglare = Spell(205180),
    UnstableAffliction = Spell(30108),
    UnstableAfflictionDebuff = Spell(30108),
    Agony = Spell(980),
    Deathbolt = Spell(264106),
    SiphonLife = Spell(63106),
    AgonyDebuff = Spell(980),
    Fireblood = Spell(265221),
    BloodFury = Spell(20572),
    DrainSoul = Spell(198590),
    UnstableAffliction1Debuff = Spell(233490),
    UnstableAffliction2Debuff = Spell(233496),
    UnstableAffliction3Debuff = Spell(233497),
    UnstableAffliction4Debuff = Spell(233498),
    UnstableAffliction5Debuff = Spell(233499),
    CorruptionDebuff = Spell(146739),
    DarkSoul = Spell(113860),
    SiphonLifeDebuff = Spell(63106),
    Corruption = Spell(172),
    PhantomSingularity = Spell(205179),
    VileTaint = Spell(278350),
    Berserking = Spell(26297),
    SowtheSeeds = Spell(196226)
};
local S = RubimRH.Spell[265]

local EnemyRanges = { 5, 40 }
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

HL.UnstableAfflictionDebuffsPrev = {
    [S.UnstableAffliction2Debuff] = S.UnstableAffliction1Debuff,
    [S.UnstableAffliction3Debuff] = S.UnstableAffliction2Debuff,
    [S.UnstableAffliction4Debuff] = S.UnstableAffliction3Debuff,
    [S.UnstableAffliction5Debuff] = S.UnstableAffliction4Debuff
};

local function NbAffected (SpellAffected)
    local nbaff = 0
    for Key, Value in pairs(Cache.Enemies[EnemyRanges[2]]) do
        if Value:DebuffRemainsP(SpellAffected) > 0 then
            nbaff = nbaff + 1;
        end
    end
    return nbaff;
end

local function TimeToShard()
    local agony_count = NbAffected(S.Agony)
    if agony_count == 0 then
        return 10000
    end
    return 1 / (0.16 / math.sqrt(agony_count) * (agony_count == 1 and 1.15 or 1) * agony_count / S.Agony:TickTime())
end
--- ======= ACTION LISTS =======
local function APL()
    local Precombat, Aoe, DgSoon, Fillers, Regular, Single
    UpdateRanges()
    local time_to_shard = TimeToShard()
    Precombat = function()
        -- flask
        -- food
        -- augmentation
        -- summon_pet
        if S.SummonPet:IsReady() and (true) then
            return S.Summ
        end
        -- grimoire_of_sacrifice,if=talent.grimoire_of_sacrifice.enabled
        if S.GrimoireofSacrifice:IsReady() and Player:BuffDownP(S.GrimoireofSacrificeBuff) and (S.GrimoireofSacrifice:IsAvailable()) then
            return S.GrimoireofSacrifice:Cast()
        end
        -- snapshot_stats
        -- potion
        -- seed_of_corruption,if=spell_targets.seed_of_corruption_aoe>=3
        if S.SeedofCorruption:IsReady() and (Cache.EnemiesCount[5] >= 3) then
            return S.SeedofCorruption:Cast()
        end
        -- haunt
        if S.Haunt:IsReady() and Player:DebuffDownP(S.HauntDebuff) and (true) then
            return S.Haunt:Cast()
        end
        -- shadow_bolt,if=!talent.haunt.enabled&spell_targets.seed_of_corruption_aoe<3
        if S.ShadowBolt:IsReady() and (not S.Haunt:IsAvailable() and Cache.EnemiesCount[5] < 3) then
            return S.ShadowBolt:Cast()
        end
    end
    Aoe = function()
        -- call_action_list,name=dg_soon,if=(cooldown.summon_darkglare.remains<time_to_shard*(5-soul_shard)|cooldown.summon_darkglare.up)&time_to_die>cooldown.summon_darkglare.remains
        if ((S.SummonDarkglare:CooldownRemainsP() < time_to_shard * (5 - Player:SoulShardsP()) or S.SummonDarkglare:CooldownUpP()) and Target:TimeToDie() > S.SummonDarkglare:CooldownRemainsP()) then
            if DgSoon() ~= nil then
                return DgSoon()
            end
        end
        -- seed_of_corruption
        if S.SeedofCorruption:IsReady() and (true) then
            return S.SeedofCorruption:Cast()
        end
        -- call_action_list,name=fillers
        if (true) then
            if Fillers() ~= nil then
                return Fillers()
            end
        end
    end
    DgSoon = function()
        -- unstable_affliction,if=(cooldown.summon_darkglare.remains<=soul_shard*cast_time)
        if S.UnstableAffliction:IsReady() and ((S.SummonDarkglare:CooldownRemainsP() <= Player:SoulShardsP() * S.UnstableAffliction:CastTime())) then
            return S.UnstableAffliction:Cast()
        end
        -- agony,line_cd=30,if=talent.deathbolt.enabled&(!talent.siphon_life.enabled)&dot.agony.ticks_remain<=10&cooldown.deathbolt.remains<=gcd
        if S.Agony:IsReady() and (S.Deathbolt:IsAvailable() and (not S.SiphonLife:IsAvailable()) and Target:DebuffTicksRemainP(S.AgonyDebuff) <= 10 and S.Deathbolt:CooldownRemainsP() <= Player:GCD()) then
            return S.Agony:Cast()
        end
        -- summon_darkglare
        if S.SummonDarkglare:IsReady() and RubimRH.CDsON() and (true) then
            return S.SummonDarkglare:Cast()
        end
        -- call_action_list,name=fillers
        if (true) then
            if Fillers() ~= nil then
                return Fillers()
            end
        end
    end
    Fillers = function()
        -- fireblood
        if S.Fireblood:IsReady() and RubimRH.CDsON() and (true) then
            return S.Fireblood:Cast()
        end
        -- blood_fury
        if S.BloodFury:IsReady() and RubimRH.CDsON() and (true) then
            return S.BloodFury:Cast()
        end
        -- use_items
        -- deathbolt
        if S.Deathbolt:IsReady() and (true) then
            return S.Deathbolt:Cast()
        end
        -- drain_soul,interrupt_global=1,chain=1,cycle_targets=1,if=target.time_to_die<=gcd
        if S.DrainSoul:IsReadyMorph() and (Target:TimeToDie() <= Player:GCD()) then
            return S.DrainSoul:Cast()
        end
        -- drain_soul,interrupt_global=1,chain=1
        if S.DrainSoul:IsReadyMorph() and (true) then
            return S.DrainSoul:Cast()
        end
        -- shadow_bolt
        if S.ShadowBolt:IsReady() and (true) then
            return S.ShadowBolt:Cast()
        end
    end
    Regular = function()
        -- unstable_affliction,cycle_targets=1,if=((dot.unstable_affliction_1.remains+dot.unstable_affliction_2.remains+dot.unstable_affliction_3.remains+dot.unstable_affliction_4.remains+dot.unstable_affliction_5.remains)<=cast_time|soul_shard>=2)&target.time_to_die>4+cast_time
        if S.UnstableAffliction:IsReady() and (((Target:DebuffRemainsP(S.UnstableAffliction1Debuff) + Target:DebuffRemainsP(S.UnstableAffliction2Debuff) + Target:DebuffRemainsP(S.UnstableAffliction3Debuff) + Target:DebuffRemainsP(S.UnstableAffliction4Debuff) + Target:DebuffRemainsP(S.UnstableAffliction5Debuff)) <= S.UnstableAffliction:CastTime() or Player:SoulShardsP() >= 2) and Target:TimeToDie() > 4 + S.UnstableAffliction:CastTime()) then
            return S.UnstableAffliction:Cast()
        end
        -- agony,line_cd=30,if=talent.deathbolt.enabled&(!talent.siphon_life.enabled)&dot.agony.ticks_remain<=10&cooldown.deathbolt.remains<=gcd
        if S.Agony:IsReady() and (S.Deathbolt:IsAvailable() and (not S.SiphonLife:IsAvailable()) and Target:DebuffTicksRemainP(S.AgonyDebuff) <= 10 and S.Deathbolt:CooldownRemainsP() <= Player:GCD()) then
            return S.Agony:Cast()
        end
        -- call_action_list,name=fillers
        if (true) then
            if Fillers() ~= nil then
                return Fillers()
            end
        end
    end
    Single = function()
        -- unstable_affliction,if=soul_shard=5
        if S.UnstableAffliction:IsReady() and (Player:SoulShardsP() == 5) then
            return S.UnstableAffliction:Cast()
        end
        -- call_action_list,name=dg_soon,if=(cooldown.summon_darkglare.remains<time_to_shard*(5-soul_shard)|cooldown.summon_darkglare.up)&time_to_die>cooldown.summon_darkglare.remains
        if ((S.SummonDarkglare:CooldownRemainsP() < time_to_shard * (5 - Player:SoulShardsP()) or S.SummonDarkglare:CooldownUpP()) and Target:TimeToDie() > S.SummonDarkglare:CooldownRemainsP()) then
            if DgSoon() ~= nil then
                return DgSoon()
            end
        end
        -- call_action_list,name=regular,if=!((cooldown.summon_darkglare.remains<time_to_shard*(5-soul_shard)|time_to_die>cooldown.summon_darkglare.remains)&cooldown.summon_darkglare.up)
        if (not ((S.SummonDarkglare:CooldownRemainsP() < time_to_shard * (5 - Player:SoulShardsP()) or Target:TimeToDie() > S.SummonDarkglare:CooldownRemainsP()) and S.SummonDarkglare:CooldownUpP())) then
            if Regular() ~= nil then
                return Regular();
            end
        end
    end
    -- call precombat
    if not Player:AffectingCombat() and not Player:IsCasting() then
        if Precombat() ~= nil then
            return Precombat()
        end
        return 0, 462338
    end
    -- haunt
    if S.Haunt:IsReady() and (true) then
        return S.Haunt:Cast()
    end
    -- summon_darkglare,if=dot.agony.ticking&dot.corruption.ticking&dot.unstable_affliction_1.ticking&dot.unstable_affliction_2.ticking&dot.unstable_affliction_3.ticking&((dot.unstable_affliction_4.ticking&dot.unstable_affliction_5.ticking)|soul_shard=0)
    if S.SummonDarkglare:IsReady() and RubimRH.CDsON() and (Target:DebuffP(S.AgonyDebuff) and Target:DebuffP(S.CorruptionDebuff) and Target:DebuffP(S.UnstableAffliction1Debuff) and Target:DebuffP(S.UnstableAffliction2Debuff) and Target:DebuffP(S.UnstableAffliction3Debuff) and ((Target:DebuffP(S.UnstableAffliction4Debuff) and Target:DebuffP(S.UnstableAffliction5Debuff)) or Player:SoulShardsP() == 0)) then
        return S.SummonDarkglare:Cast()
    end
    -- agony,cycle_targets=1,max_cycle_targets=5,if=remains<=gcd&active_enemies<=7
    if S.Agony:IsReady() and (Target:DebuffRemainsP(S.AgonyDebuff) <= Player:GCD() and Cache.EnemiesCount[40] <= 7) then
        return S.Agony:Cast()
    end
    -- agony,cycle_targets=1,max_cycle_targets=5,if=refreshable&target.time_to_die>10&(!(cooldown.summon_darkglare.remains<=soul_shard*cast_time)|active_enemies<2)&active_enemies<=7
    if S.Agony:IsReady() and (Target:DebuffRefreshableCP(S.AgonyDebuff) and Target:TimeToDie() > 10 and (not (S.SummonDarkglare:CooldownRemainsP() <= Player:SoulShardsP() * S.Agony:CastTime()) or Cache.EnemiesCount[40] < 2) and Cache.EnemiesCount[40] <= 7) then
        return S.Agony:Cast()
    end
    -- agony,cycle_targets=1,max_cycle_targets=4,if=remains<=gcd&active_enemies>7
    if S.Agony:IsReady() and (Target:DebuffRemainsP(S.AgonyDebuff) <= Player:GCD() and Cache.EnemiesCount[40] > 7) then
        return S.Agony:Cast()
    end
    -- agony,cycle_targets=1,max_cycle_targets=4,if=refreshable&target.time_to_die>10&(!(cooldown.summon_darkglare.remains<=soul_shard*cast_time)|active_enemies<2)&active_enemies>7
    if S.Agony:IsReady() and (Target:DebuffRefreshableCP(S.AgonyDebuff) and Target:TimeToDie() > 10 and (not (S.SummonDarkglare:CooldownRemainsP() <= Player:SoulShardsP() * S.Agony:CastTime()) or Cache.EnemiesCount[40] < 2) and Cache.EnemiesCount[40] > 7) then
        return S.Agony:Cast()
    end
    -- dark_soul
    if S.DarkSoul:IsReady() and RubimRH.CDsON() and (true) then
        return S.DarkSoul:Cast()
    end
    -- siphon_life,cycle_targets=1,max_cycle_targets=1,if=refreshable&target.time_to_die>10&((!(cooldown.summon_darkglare.remains<=soul_shard*cast_time)&active_enemies>4)|active_enemies<2)
    if S.SiphonLife:IsReady() and (Target:DebuffRefreshableCP(S.SiphonLifeDebuff) and Target:TimeToDie() > 10 and ((not (S.SummonDarkglare:CooldownRemainsP() <= Player:SoulShardsP() * S.SiphonLife:CastTime()) and Cache.EnemiesCount[40] > 4) or Cache.EnemiesCount[40] < 2)) then
        return S.SiphonLife:Cast()
    end
    -- siphon_life,cycle_targets=1,max_cycle_targets=2,if=refreshable&target.time_to_die>10&!(cooldown.summon_darkglare.remains<=soul_shard*cast_time)&active_enemies=2
    if S.SiphonLife:IsReady() and (Target:DebuffRefreshableCP(S.SiphonLifeDebuff) and Target:TimeToDie() > 10 and not (S.SummonDarkglare:CooldownRemainsP() <= Player:SoulShardsP() * S.SiphonLife:CastTime()) and Cache.EnemiesCount[40] == 2) then
        return S.SiphonLife:Cast()
    end
    -- siphon_life,cycle_targets=1,max_cycle_targets=3,if=refreshable&target.time_to_die>10&!(cooldown.summon_darkglare.remains<=soul_shard*cast_time)&active_enemies=3
    if S.SiphonLife:IsReady() and (Target:DebuffRefreshableCP(S.SiphonLifeDebuff) and Target:TimeToDie() > 10 and not (S.SummonDarkglare:CooldownRemainsP() <= Player:SoulShardsP() * S.SiphonLife:CastTime()) and Cache.EnemiesCount[40] == 3) then
        return S.SiphonLife:Cast()
    end
    -- corruption,cycle_targets=1,if=active_enemies<3&refreshable&target.time_to_die>10
    if S.Corruption:IsReady() and (Cache.EnemiesCount[40] < 3 and Target:DebuffRefreshableCP(S.CorruptionDebuff) and Target:TimeToDie() > 10) then
        return S.Corruption:Cast()
    end
    -- seed_of_corruption,line_cd=10,if=dot.corruption.ticks_remain<=2&spell_targets.seed_of_corruption_aoe>=3
    if S.SeedofCorruption:IsReady() and (Target:DebuffTicksRemainP(S.CorruptionDebuff) <= 2 and Cache.EnemiesCount[5] >= 3) then
        return S.SeedofCorruption:Cast()
    end
    -- phantom_singularity
    if S.PhantomSingularity:IsReady() and (true) then
        return S.PhantomSingularity:Cast()
    end
    -- vile_taint
    if S.VileTaint:IsReady() and (true) then
        return S.VileTaint:Cast()
    end
    -- berserking
    if S.Berserking:IsReady() and RubimRH.CDsON() and (true) then
        return S.Berserking:Cast()
    end
    -- call_action_list,name=aoe,if=talent.sow_the_seeds.enabled&spell_targets.seed_of_corruption_aoe>=3
    if (S.SowtheSeeds:IsAvailable() and Cache.EnemiesCount[5] >= 3) then
        if Aoe() ~= nil then
            return Aoe()
        end
    end
    -- call_action_list,name=single
    if (true) then
        if Single() ~= nil then
            return Single()
        end
    end
end

RubimRH.Rotation.SetAPL(265, APL)

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(265, PASSIVE)