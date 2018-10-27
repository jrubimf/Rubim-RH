--Edit: Taste#0124

local addonName, addonTable = ...
-- HeroLib
local HL = HeroLib
local Cache = HeroCache
local Unit = HL.Unit
local Player = Unit.Player
local Target = Unit.Target
local Pet = Unit.Pet
local Spell = HL.Spell

RubimRH.Spell[265] = {
    SummonPet = Spell(688),
    GrimoireofSacrificeBuff = Spell(196099),
    GrimoireofSacrifice = Spell(108503),
    SeedofCorruption = Spell(27243),
    Haunt = Spell(48181),
    ShadowBolt = Spell(232670),
    Deathbolt = Spell(264106),
    SummonDarkglare = Spell(205180),
    BurningRushBuff = Spell(111400),
    NightfallBuff = Spell(264571),
    Agony = Spell(980),
    SiphonLife = Spell(63106),
    Corruption = Spell(172),
    AbsoluteCorruption = Spell(196103),
    DrainLife = Spell(234153),
    InevitableDemiseBuff = Spell(273525),
    PhantomSingularity = Spell(205179),
    DarkSoul = Spell(113860),
    DarkSoulMisery = Spell(113860),
    VileTaint = Spell(278350),
    DrainSoul = Spell(198590),
    ShadowEmbrace = Spell(32388),
    ShadowEmbraceDebuff = Spell(32390),
    SowtheSeeds = Spell(196226),
    CascadingCalamity = Spell(275378),
	SuddenOnSet = Spell(278721),
    Fireblood = Spell(265221),
    BloodFury = Spell(20572),
    AgonyDebuff = Spell(980),
    CorruptionDebuff = Spell(146739),
    ActiveUasBuff = Spell(30108),
    CreepingDeath = Spell(264000),
    WritheInAgony = Spell(196102),
    UnstableAffliction = Spell(30108),
    UnstableAfflictionDebuff = Spell(30108),
    Berserking = Spell(26297),
	-- UA Debuffs facility
	UnstableAfflictionDebuff1 = Spell(233490),
    UnstableAfflictionDebuff2 = Spell(233496),
    UnstableAfflictionDebuff3 = Spell(233497),
    UnstableAfflictionDebuff4 = Spell(233498),
    UnstableAfflictionDebuff5 = Spell(233499)
};
local S = RubimRH.Spell[265]

-- Variables

--actions+=/variable,name=padding,op=set,value=action.shadow_bolt.execute_time*azerite.cascading_calamity.enabled
--actions+=/variable,name=padding,op=reset,value=gcd,if=azerite.cascading_calamity.enabled&(talent.drain_soul.enabled|talent.deathbolt.enabled&cooldown.deathbolt.remains<=gcd)
local UseSeed = 0;
local VarPadding = 0;

local EnemyRanges = { 35, 5 }
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

local UnstableAfflictionDebuffs = {
    Spell(233490),
    Spell(233496),
    Spell(233497),
    Spell(233498),
    Spell(233499)
};

local function bool(PoolReburstPhase)    
	if  (S.SummonDarkglare:CooldownRemainsP() <= 45) and RubimRH.CDsON() then
        return true
    elseif (S.SummonDarkglare:CooldownRemainsP() <= 3) and RubimRH.CDsON() then 
		return false
	elseif S.SummonDarkglare:IsCastableP() and RubimRH.CDsON() then 
		return false
	else 
		return false
	end
    return PoolReburstPhase
end

local function bool(ShouldPool)
	if (Player:SoulShardsP() < 1) then 
		return true
	else
		return false
	end	
    return ShouldPool
end

local function ActiveUAs()
    local UAcount = 0
    for _, v in pairs(UnstableAfflictionDebuffs) do
        if Target:DebuffRemainsP(v) > 0 then
            UAcount = UAcount + 1
        end
    end
    return UAcount
end

HL.UnstableAfflictionDebuffsPrev = {
    [UnstableAfflictionDebuffs[2]] = UnstableAfflictionDebuffs[1],
    [UnstableAfflictionDebuffs[3]] = UnstableAfflictionDebuffs[2],
    [UnstableAfflictionDebuffs[4]] = UnstableAfflictionDebuffs[3],
    [UnstableAfflictionDebuffs[5]] = UnstableAfflictionDebuffs[4]
};

local function NbAffected (SpellAffected)
    local nbaff = 0
    for Key, Value in pairs(Cache.Enemies[35]) do
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

S.ShadowBolt:RegisterInFlight()
S.SeedofCorruption:RegisterInFlight()
-- Added Haunt registered in flight
S.Haunt:RegisterInFlight()

--- ======= ACTION LISTS =======
local function APL()
    local Precombat, Fillers
    UpdateRanges()
    Precombat = function()
        -- flask
        -- food
        -- augmentation
        -- summon_pet
        if S.SummonPet:IsCastableP() and (not Player:IsMoving()) and not Pet:IsActive() and (not bool(Player:BuffRemainsP(S.GrimoireofSacrificeBuff))) then
            return S.SummonPet:Cast()
        end
        -- grimoire_of_sacrifice,if=talent.grimoire_of_sacrifice.enabled
        if S.GrimoireofSacrifice:IsCastableP() and Player:BuffDownP(S.GrimoireofSacrificeBuff) and (S.GrimoireofSacrifice:IsAvailable()) then
            return S.GrimoireofSacrifice:Cast()
        end
        -- snapshot_stats
        if RubimRH.TargetIsValid() then
            -- seed_of_corruption,if=spell_targets.seed_of_corruption_aoe>=3
            if S.SeedofCorruption:IsCastableP() and (not Player:IsMoving()) and bool(UseSeed) and (Cache.EnemiesCount[35] >= 4) then
                return S.SeedofCorruption:Cast()
            end
            -- haunt
            if S.Haunt:IsCastableP() and (not Player:IsMoving()) and Player:DebuffDownP(S.Haunt) then
                return S.Haunt:Cast()
            end
            -- shadow_bolt,if=!talent.haunt.enabled&spell_targets.seed_of_corruption_aoe<3
            if S.ShadowBolt:IsCastableP() and (not Player:IsMoving()) and (not S.Haunt:IsAvailable() and Cache.EnemiesCount[35] < 3) then
                return S.ShadowBolt:Cast()
            end
        end
        return 0, 462338
    end
    Fillers = function()
		-- agony,if=talent.deathbolt.enabled&cooldown.summon_darkglare.remains>=30+gcd&cooldown.deathbolt.remains<=gcd&!prev_gcd.1.summon_darkglare&!prev_gcd.1.agony&talent.writhe_in_agony.enabled&azerite.sudden_onset.enabled&remains<duration*0.5
		if S.Agony:IsCastableP() and (S.Deathbolt:IsAvailable()) and (S.SummonDarkglare:CooldownRemainsP() >= 30 + Player:GCD()) and (S.Deathbolt:CooldownRemainsP() <= Player:GCD()) and not (Player:PrevGCDP(1, S.SummonDarkglare)) and not (Player:PrevGCDP(1, S.Agony)) and (S.WritheInAgony:IsAvailable()) and (S.SuddenOnSet:AzeriteEnabled()) and (Target:DebuffRemainsP(S.AgonyDebuff) < 18 * 0.5)  then
            return S.Agony:Cast()
        end
        -- deathbolt,if=player.soulshards<=1&!phantomsingularity
        if S.Deathbolt:IsCastableP() and (not RubimRH.CDsON()) and (S.PhantomSingularity:CooldownRemainsP()>5) and (Player:SoulShardsP() <= 1) and (ActiveUAs() >= 1) then
            return S.Deathbolt:Cast()
        end
        -- deathbolt,if=cooldown.summon_darkglare.remains>=30+gcd|cooldown.summon_darkglare.remains>140
        if S.Deathbolt:IsCastableP() and RubimRH.CDsON() and (S.PhantomSingularity:CooldownRemainsP()>5) and (Player:SoulShardsP() <= 1) and (ActiveUAs() >= 1) and (S.SummonDarkglare:CooldownRemainsP() >= 30 + Player:GCD() or S.SummonDarkglare:CooldownRemainsP() > 140) then
            return S.Deathbolt:Cast()
        end
        -- shadow_bolt,if=buff.movement.up&buff.nightfall.remains
        if S.ShadowBolt:IsCastableP() and (Player:IsMoving() and bool(Player:BuffRemainsP(S.NightfallBuff))) then
            return S.ShadowBolt:Cast()
        end
        -- agony,if=buff.movement.up&!(talent.siphon_life.enabled&(prev_gcd.1.agony&prev_gcd.2.agony&prev_gcd.3.agony)|prev_gcd.1.agony)
        if S.Agony:IsCastableP() and (Player:IsMoving() and not (S.SiphonLife:IsAvailable() and (Player:PrevGCDP(1, S.Agony) and Player:PrevGCDP(2, S.Agony) and Player:PrevGCDP(3, S.Agony)) or Player:PrevGCDP(1, S.Agony))) then
            return S.Agony:Cast()
        end
        -- siphon_life,if=buff.movement.up&!(prev_gcd.1.siphon_life&prev_gcd.2.siphon_life&prev_gcd.3.siphon_life)
        if S.SiphonLife:IsCastableP() and (Player:IsMoving() and not (Player:PrevGCDP(1, S.SiphonLife) and Player:PrevGCDP(2, S.SiphonLife) and Player:PrevGCDP(3, S.SiphonLife))) then
            return S.SiphonLife:Cast()
        end
        -- corruption,if=buff.movement.up&!prev_gcd.1.corruption&!talent.absolute_corruption.enabled
        if S.Corruption:IsCastableP() and (Player:IsMoving() and not Player:PrevGCDP(1, S.Corruption) and not S.AbsoluteCorruption:IsAvailable()) then
            return S.Corruption:Cast()
        end
        -- drain_life,if=(buff.inevitable_demise.stack>=90&(cooldown.deathbolt.remains>execute_time|!talent.deathbolt.enabled)&(cooldown.phantom_singularity.remains>execute_time|!talent.phantom_singularity.enabled)&(cooldown.dark_soul.remains>execute_time|!talent.dark_soul_misery.enabled)&(cooldown.vile_taint.remains>execute_time|!talent.vile_taint.enabled)&cooldown.summon_darkglare.remains>execute_time+10|buff.inevitable_demise.stack>30&target.time_to_die<=10)
        if S.DrainLife:IsCastableP() and (not Player:IsMoving()) and ((Player:BuffStackP(S.InevitableDemiseBuff) >= 90 and (S.Deathbolt:CooldownRemainsP() > S.DrainLife:ExecuteTime() or not S.Deathbolt:IsAvailable()) and (S.PhantomSingularity:CooldownRemainsP() > S.DrainLife:ExecuteTime() or not S.PhantomSingularity:IsAvailable()) and (S.DarkSoul:CooldownRemainsP() > S.DrainLife:ExecuteTime() or not S.DarkSoulMisery:IsAvailable()) and (S.VileTaint:CooldownRemainsP() > S.DrainLife:ExecuteTime() or not S.VileTaint:IsAvailable()) and S.SummonDarkglare:CooldownRemainsP() > S.DrainLife:ExecuteTime() + 10 or Player:BuffStackP(S.InevitableDemiseBuff) > 30 and Target:TimeToDie() <= 10)) then
            return S.DrainLife:Cast()
        end
        -- haunt NEW APL UPDATED
        if S.Haunt:IsCastableP() and (not Player:IsMoving()) and (Target:DebuffRemainsP(S.Haunt) > (S.Haunt:CastTime() + Player:GCD())) then
            return S.Haunt:Cast()
        end
        -- drain_soul,interrupt_global=1,chain=1,cycle_targets=1,if=target.time_to_die<=gcd
        if S.DrainSoul:IsCastableP() and (not Player:IsMoving()) and (Target:TimeToDie() <= Player:GCD()) then
            return S.DrainSoul:Cast()
        end
        -- drain_soul,interrupt_global=1,chain=1
        if S.DrainSoul:IsCastableP() and (not Player:IsMoving()) then
            return S.DrainSoul:Cast()
        end
        -- shadow_bolt,cycle_targets=1,if=talent.shadow_embrace.enabled&talent.absolute_corruption.enabled&active_enemies=2&!debuff.shadow_embrace.remains&!action.shadow_bolt.in_flight
        if S.ShadowBolt:IsCastableP() and (not Player:IsMoving()) and (S.ShadowEmbrace:IsAvailable() and S.AbsoluteCorruption:IsAvailable() and Cache.EnemiesCount[35] == 2 and not bool(Target:DebuffRemainsP(S.ShadowEmbraceDebuff)) and not S.ShadowBolt:InFlight()) then
            return S.ShadowBolt:Cast()
        end
        -- shadow_bolt,target_if=min:debuff.shadow_embrace.remains,if=talent.shadow_embrace.enabled&talent.absolute_corruption.enabled&active_enemies=2
        if S.ShadowBolt:IsCastableP() and (not Player:IsMoving()) and bool(Target:DebuffRemainsP(S.ShadowEmbraceDebuff)) and (S.ShadowEmbrace:IsAvailable() and S.AbsoluteCorruption:IsAvailable() and Cache.EnemiesCount[35] == 2) then
            return S.ShadowBolt:Cast()
        end
	    -- shadow_bolt
        if S.ShadowBolt:IsCastableP() and (not Player:IsMoving()) then
            return S.ShadowBolt:Cast()
        end
    end
	
	-- Cooldown here
	Cooldowns = function()
		-- potion,if=(talent.dark_soul_misery.enabled&cooldown.summon_darkglare.up&cooldown.dark_soul.up)|cooldown.summon_darkglare.up|target.time_to_die<30
        -- use_items,if=!cooldown.summon_darkglare.up
        -- fireblood,if=!cooldown.summon_darkglare.up
        if S.Fireblood:IsCastableP() and RubimRH.CDsON() and (not S.SummonDarkglare:CooldownUpP()) then
            return S.Fireblood:Cast()
        end
        -- blood_fury,if=!cooldown.summon_darkglare.up
        if S.BloodFury:IsCastableP() and RubimRH.CDsON() and (not S.SummonDarkglare:CooldownUpP()) then
            return S.BloodFury:Cast()
        end
    end
	
	-- Dots here
	Dots = function()
		-- NEW DOTS Rotation
		-- seed_of_corruption,if=dot.corruption.remains<=action.seed_of_corruption.cast_time+time_to_shard+4.2*(1-talent.creeping_death.enabled*0.15)&spell_targets.seed_of_corruption_aoe>=3+talent.writhe_in_agony.enabled&!dot.seed_of_corruption.remains&!action.seed_of_corruption.in_flight
		if S.SeedofCorruption:IsCastableP() and (not Player:IsMoving()) and (Target:DebuffRemainsP(S.CorruptionDebuff) <= S.SeedofCorruption:CastTime() + TimeToShard() + 4.2 * (1 - num(S.CreepingDeath:IsAvailable()) * 0.15) and Cache.EnemiesCount[35] >= 3 + num(S.WritheInAgony:IsAvailable()) and not bool(Target:DebuffRemainsP(S.SeedofCorruption)) and not S.SeedofCorruption:InFlight()) then
            return S.SeedofCorruption:Cast()
        end		
		-- agony,target_if=min:remains,if=talent.creeping_death.enabled&active_dot.agony<6&target.time_to_die>10&(remains<=gcd|cooldown.summon_darkglare.remains>10&refreshable)
	--	if S.Agony:IsCastableP() and S.CreepingDeath:IsAvailable() and (Target:DebuffRemainsP(S.AgonyDebuff) < 6) and (Target:TimeToDie() > 10) and ((Target:DebuffRemainsP(S.AgonyDebuff) <= Player:GCD()) or (S.SummonDarkglare:CooldownRemainsP() > 10 and Target:DebuffRefreshableCP(S.AgonyDebuff))) then
     --       return S.Agony:Cast()
      --  end
		-- agony,target_if=min:remains,if=!talent.creeping_death.enabled&active_dot.agony<8&target.time_to_die>10&(remains<=gcd|cooldown.summon_darkglare.remains>10&refreshable)
--		if S.Agony:IsCastableP() and not (S.CreepingDeath:IsAvailable()) and (Target:DebuffRemainsP(S.AgonyDebuff) < 8) and (Target:TimeToDie() > 10) and ((Target:DebuffRemainsP(S.AgonyDebuff) <= Player:GCD()) or (S.SummonDarkglare:CooldownRemainsP() > 10 and Target:DebuffRefreshableCP(S.AgonyDebuff))) then
 --           return S.Agony:Cast()
  --      end
		-- siphon_life,target_if=min:remains,if=-spell_targets.sow_the_seeds_aoe<5&target.time_to_die>10&refreshable&!(cooldown.summon_darkglare.remains<=soul_shard*action.unstable_affliction.execute_time)
--		if S.SiphonLife:IsCastableP() and (Cache.EnemiesCount[35] < 5) and (Target:TimeToDie() > 10) and Target:DebuffRefreshableCP(S.SiphonLife) and not (S.SummonDarkglare:CooldownRemainsP() <= Player:SoulShardsP() * S.UnstableAffliction:ExecuteTime()) then
 --           return S.SiphonLife:Cast()
  --      end
		-- siphon_life,target_if=min:remains,if=(active_dot.siphon_life<8-talent.creeping_death.enabled-spell_targets.sow_the_seeds_aoe)&target.time_to_die>10&refreshable&!(cooldown.summon_darkglare.remains<=soul_shard*action.unstable_affliction.execute_time)
--		if S.SiphonLife:IsCastableP() and (Target:DebuffRemainsP(S.SiphonLife) < 8 - num(S.CreepingDeath:IsAvailable()) and (Target:TimeToDie() > 10) and Target:DebuffRefreshableCP(S.SiphonLife) and not (S.SummonDarkglare:CooldownRemainsP() <= Player:SoulShardsP() * S.UnstableAffliction:ExecuteTime())) then
 --           return S.SiphonLife:Cast()
  --      end
		
		-- corruption,cycle_targets=1,if=active_enemies<3+talent.writhe_in_agony.enabled&(remains<=gcd|cooldown.summon_darkglare.remains>10&refreshable)&target.time_to_die>10
	--	if S.Corruption:IsCastableP() and (Cache.EnemiesCount[35] < 3 + num(S.WritheInAgony:IsAvailable()) and ((Target:DebuffRemainsP(S.Corruption) < Player:GCD()) or (S.SummonDarkglare:CooldownRemainsP() > 10 and Target:DebuffRefreshableCP(S.Corruption))) and (Target:TimeToDie() > 10)) then
    --        return S.Corruption:Cast()
    --    end
		-- END NEW DOTS ROTATION
		        -- OLD DOTS START
		-- agony,cycle_targets=1,max_cycle_targets=8,if=(!talent.creeping_death.enabled)&target.time_to_die>10&refreshable
        if S.Agony:IsCastableP() and ((not S.CreepingDeath:IsAvailable()) and Target:TimeToDie() > 10 and Target:DebuffRefreshableCP(S.AgonyDebuff)) then
            return S.Agony:Cast()
        end
		
        -- siphon_life,cycle_targets=1,max_cycle_targets=1,if=refreshable&target.time_to_die>10&((!(cooldown.summon_darkglare.remains<=soul_shard*action.unstable_affliction.execute_time)&active_enemies>=8)|active_enemies=1)
        if S.SiphonLife:IsCastableP() and (Target:DebuffRefreshableCP(S.SiphonLife) and Target:TimeToDie() > 10 and ((not (S.SummonDarkglare:CooldownRemainsP() <= Player:SoulShardsP() * S.UnstableAffliction:ExecuteTime()) and Cache.EnemiesCount[35] >= 8) or Cache.EnemiesCount[35] == 1)) then
            return S.SiphonLife:Cast()
        end
        -- siphon_life,cycle_targets=1,max_cycle_targets=2,if=refreshable&target.time_to_die>10&((!(cooldown.summon_darkglare.remains<=soul_shard*action.unstable_affliction.execute_time)&active_enemies=7)|active_enemies=2)
        if S.SiphonLife:IsCastableP() and (Target:DebuffRefreshableCP(S.SiphonLife) and Target:TimeToDie() > 10 and ((not (S.SummonDarkglare:CooldownRemainsP() <= Player:SoulShardsP() * S.UnstableAffliction:ExecuteTime()) and Cache.EnemiesCount[35] == 7) or Cache.EnemiesCount[35] == 2)) then
            return S.SiphonLife:Cast()
        end
        -- siphon_life,cycle_targets=1,max_cycle_targets=3,if=refreshable&target.time_to_die>10&((!(cooldown.summon_darkglare.remains<=soul_shard*action.unstable_affliction.execute_time)&active_enemies=6)|active_enemies=3)
        if S.SiphonLife:IsCastableP() and (Target:DebuffRefreshableCP(S.SiphonLife) and Target:TimeToDie() > 10 and ((not (S.SummonDarkglare:CooldownRemainsP() <= Player:SoulShardsP() * S.UnstableAffliction:ExecuteTime()) and Cache.EnemiesCount[35] == 6) or Cache.EnemiesCount[35] == 3)) then
            return S.SiphonLife:Cast()
        end
     --   -- siphon_life,cycle_targets=1,max_cycle_targets=4,if=refreshable&target.time_to_die>10&((!(cooldown.summon_darkglare.remains<=soul_shard*action.unstable_affliction.execute_time)&active_enemies=5)|active_enemies=4)
        if S.SiphonLife:IsCastableP() and (Target:DebuffRefreshableCP(S.SiphonLife) and Target:TimeToDie() > 10 and ((not (S.SummonDarkglare:CooldownRemainsP() <= Player:SoulShardsP() * S.UnstableAffliction:ExecuteTime()) and Cache.EnemiesCount[35] == 5) or Cache.EnemiesCount[35] == 4)) then
            return S.SiphonLife:Cast()
        end
        -- corruption,cycle_targets=1,if=active_enemies<3+talent.writhe_in_agony.enabled&refreshable&target.time_to_die>10
        if S.Corruption:IsCastableP() and (Cache.EnemiesCount[35] < 3 + num(S.WritheInAgony:IsAvailable()) and (Target:DebuffRefreshableCP(S.CorruptionDebuff) and (S.AbsoluteCorruption:IsAvailable() and not Target:Debuff(S.CorruptionDebuff) or not S.AbsoluteCorruption:IsAvailable())) and Target:TimeToDie() > 10) then
            return S.Corruption:Cast()
        end
		-- OLD DOTS END
    end
	
	-- Shards spenders here
	Spenders = function()
		-- unstable_affliction,cd off cycle
	    if S.UnstableAffliction:IsReadyP() and (not Player:PrevGCDP(1, S.UnstableAffliction)) and (not RubimRH.CDsON()) and (not Player:IsMoving()) and Player:SoulShardsP() >= 2 then
	           return S.UnstableAffliction:Cast()
	    end
		-- unstable_affliction,opener
	    if S.UnstableAffliction:IsReadyP() and (not Player:IsMoving()) and HL.CombatTime() <= 18 then
	           return S.UnstableAffliction:Cast()
	    end
		-- unstable_affliction,if shard >=3&cooldown.summon_darkglare>=45
	    if S.UnstableAffliction:IsReadyP() and (not Player:IsMoving()) and (S.SummonDarkglare:CooldownRemainsP() >= 45) and Player:SoulShardsP() >= 3 then
	           return S.UnstableAffliction:Cast()
	    end
		-- unstable_affliction,if=cooldown.summon_darkglare.remains<=soul_shard*execute_time
        if S.UnstableAffliction:IsReadyP() and RubimRH.CDsON() and (not Player:IsMoving()) and (S.SummonDarkglare:CooldownRemainsP() <= Player:SoulShardsP() * S.UnstableAffliction:ExecuteTime()) then
            return S.UnstableAffliction:Cast()
        end
        -- call_action_list,name=fillers,if=(cooldown.summon_darkglare.remains<TimeToShard()*(5-soul_shard)|cooldown.summon_darkglare.up)&time_to_die>cooldown.summon_darkglare.remains
        --if ((S.SummonDarkglare:CooldownRemainsP() < TimeToShard() * (5 - Player:SoulShardsP())) or (S.SummonDarkglare:CooldownUpP() and Target:TimeToDie() > S.SummonDarkglare:CooldownRemainsP())) then
          if (S.SummonDarkglare:CooldownRemainsP() < 45) then  
			local ShouldReturn = Fillers();
            if ShouldReturn then
                return ShouldReturn;
            end
        end
        -- seed_of_corruption,if=variable.spammable_seed
        if S.SeedofCorruption:IsCastableP() and (not Player:IsMoving()) and bool(UseSeed) and Cache.EnemiesCount[35] >= 5 then
            return S.SeedofCorruption:Cast()
        end
        -- unstable_affliction,if=!prev_gcd.1.summon_darkglare&!variable.spammable_seed&(talent.deathbolt.enabled&cooldown.deathbolt.remains<=execute_time&!azerite.cascading_calamity.enabled|soul_shard>=2&target.time_to_die>4+execute_time&active_enemies=1|target.time_to_die<=8+execute_time*soul_shard)
        if S.UnstableAffliction:IsReadyP() and (S.SummonDarkglare:CooldownRemainsP() >= 45) and (not Player:PrevGCDP(1, S.UnstableAffliction)) and Target:DebuffRemainsP(S.UnstableAfflictionDebuff1) <= 1.3 and (not Player:IsMoving()) and (not Player:PrevGCDP(1, S.SummonDarkglare) and not bool(UseSeed) and (S.Deathbolt:IsAvailable() and S.Deathbolt:CooldownRemainsP() <= S.UnstableAffliction:ExecuteTime() and not S.CascadingCalamity:AzeriteEnabled() or Player:SoulShardsP() >= 2 and Target:TimeToDie() > 4 + S.UnstableAffliction:ExecuteTime() and Cache.EnemiesCount[35] == 1 or Target:TimeToDie() <= 8 + S.UnstableAffliction:ExecuteTime() * Player:SoulShardsP())) then
            return S.UnstableAffliction:Cast()
        end
        -- unstable_affliction,if=!variable.spammable_seed&contagion<=cast_time+variable.padding
       if S.UnstableAffliction:IsReadyP() and (S.SummonDarkglare:CooldownRemainsP() >= 45) and (not Player:PrevGCDP(1, S.UnstableAffliction)) and Target:DebuffRemainsP(S.UnstableAfflictionDebuff1) <= 1.3 and (not Player:IsMoving()) and (not bool(UseSeed) and Target:DebuffRemainsP(S.UnstableAfflictionDebuff)) then
            return S.UnstableAffliction:Cast()
       end
        -- unstable_affliction,cycle_targets=1,if=!variable.spammable_seed&(!talent.deathbolt.enabled|cooldown.deathbolt.remains>TimeToShard()|soul_shard>1)&contagion<=cast_time+variable.padding
        if S.UnstableAffliction:IsReadyP() and (S.SummonDarkglare:CooldownRemainsP() >= 45) and (not Player:PrevGCDP(1, S.UnstableAffliction)) and Target:DebuffRemainsP(S.UnstableAfflictionDebuff1) <= 1.3 and (not Player:IsMoving()) and (not bool(UseSeed) and (not S.Deathbolt:IsAvailable() or S.Deathbolt:CooldownRemainsP() > TimeToShard() or Player:SoulShardsP() > 1) and contagion <= S.UnstableAffliction:CastTime() + VarPadding) then
            return S.UnstableAffliction:Cast()
        end
    end
	
	-- ACTION LIST START HERE
    
	-- call precombat
    if not Player:AffectingCombat() and not Player:IsCasting() then
        if Precombat() ~= nil then
            return Precombat()
        end
    end
	
    if Player:IsChanneling() then
        return 0, 236353
    end
	-- combat started
    if RubimRH.TargetIsValid() then
        -- variable,name=spammable_seed,value=talent.sow_the_seeds.enabled&spell_targets.seed_of_corruption_aoe>=3|talent.siphon_life.enabled&spell_targets.seed_of_corruption>=5|spell_targets.seed_of_corruption>=8
        if (true) then
            UseSeed = num(S.SowtheSeeds:IsAvailable() and Cache.EnemiesCount[35] >= 3 or S.SiphonLife:IsAvailable() and Cache.EnemiesCount[35] >= 5 or Cache.EnemiesCount[35] >= 8)
        end
        -- variable,name=padding,op=set,value=action.shadow_bolt.execute_time*azerite.cascading_calamity.enabled
        if (true) then
            VarPadding = S.ShadowBolt:ExecuteTime() * num(S.CascadingCalamity:AzeriteEnabled())
        end
        -- variable,name=padding,op=reset,value=gcd,if=azerite.cascading_calamity.enabled&(talent.drain_soul.enabled|talent.deathbolt.enabled&cooldown.deathbolt.remains<=gcd)
        if (S.CascadingCalamity:AzeriteEnabled() and (S.DrainSoul:IsAvailable() or S.Deathbolt:IsAvailable() and S.Deathbolt:CooldownRemainsP() <= Player:GCD())) then
            VarPadding = 0
        end
		-- call_action_list,name=cooldowns
        if Cooldowns() ~= nil then
            return Cooldowns()
        end			
        -- drain_soul,interrupt_global=1,chain=1,cycle_targets=1,if=target.time_to_die<=gcd&soul_shard<5
        if S.DrainSoul:IsCastableP() and (not Player:IsMoving()) and (Target:TimeToDie() <= Player:GCD() and Player:SoulShardsP() < 5) then
            return S.DrainSoul:Cast()
        end
        -- APL UPDATED - haunt,if=spell_targets.seed_of_corruption_aoe<=2
        if S.Haunt:IsCastableP() and (not Player:IsMoving()) and Cache.EnemiesCount[35] <= 2 then
            return S.Haunt:Cast()
        end
        -- summon_darkglare,if=dot.agony.ticking&dot.corruption.ticking&(buff.active_uas.stack=5|soul_shard=0)&(!talent.phantom_singularity.enabled|cooldown.phantom_singularity.remains)
        if S.SummonDarkglare:IsCastableP() and RubimRH.CDsON() and (Target:DebuffP(S.AgonyDebuff) and Target:DebuffP(S.CorruptionDebuff) and (ActiveUAs() == 5 or Player:SoulShardsP() == 0) and (not S.PhantomSingularity:IsAvailable() or bool(S.PhantomSingularity:CooldownRemainsP()))) then
            return S.SummonDarkglare:Cast()
        end
		-- APL UPDATED - agony,target_if=min:dot.agony.remains,if=remains<=gcd+action.shadow_bolt.execute_time&target.time_to_die>8
		if S.Agony:IsCastableP() and (Target:DebuffRemainsP(S.AgonyDebuff) <= Player:GCD() + (S.ShadowBolt:ExecuteTime())) and Target:TimeToDie() > 8 then
            return S.Agony:Cast()
        end
        -- agony,cycle_targets=1,if=remains<=gcd
       --if S.Agony:IsCastableP() and (Target:DebuffRemainsP(S.AgonyDebuff) <= Player:GCD()) then
        --    return S.Agony:Cast()
      --  end
		-- APL UPDATED - unstable_affliction,target_if=!contagion&target.time_to_die<=8
	--	if S.UnstableAffliction:IsReadyP() and (not Player:IsMoving()) and bool(UARefresh) and (Target:TimeToDie() <= 8) then
    --        return S.UnstableAffliction:Cast()
    --    end
        -- shadow_bolt,target_if=min:debuff.shadow_embrace.remains,if=talent.shadow_embrace.enabled&talent.absolute_corruption.enabled&active_enemies=2&debuff.shadow_embrace.remains&debuff.shadow_embrace.remains<=execute_time*2+travel_time&!action.shadow_bolt.in_flight
        if S.ShadowBolt:IsCastableP() and (not Player:IsMoving()) and bool(Target:DebuffRemainsP(S.ShadowEmbraceDebuff)) and (S.ShadowEmbrace:IsAvailable() and S.AbsoluteCorruption:IsAvailable() and Cache.EnemiesCount[35] == 2 and bool(Target:DebuffRemainsP(S.ShadowEmbraceDebuff)) and Target:DebuffRemainsP(S.ShadowEmbraceDebuff) <= S.ShadowBolt:ExecuteTime() * 2 + S.ShadowBolt:TravelTime() and not S.ShadowBolt:InFlight()) then
            return S.ShadowBolt:Cast()
        end
        -- phantom_singularity,if=time>40&(cooldown.summon_darkglare.remains>=45|cooldown.summon_darkglare.remains<8)
       -- if S.PhantomSingularity:IsCastableP() and (HL.CombatTime() > 40 and (S.SummonDarkglare:CooldownRemainsP() >= 45 or S.SummonDarkglare:CooldownRemainsP() < 8)) then
       --     return S.PhantomSingularity:Cast()
       -- end
		-- APL UPDATED - phantom_singularity,target_if=max:target.time_to_die,if=time>35&(cooldown.summon_darkglare.remains>=45|cooldown.summon_darkglare.remains<8)&target.time_to_die>16*spell_haste
		if S.PhantomSingularity:IsCastableP() and (Player:SoulShardsP() <= 1) and (HL.CombatTime() > 35) and (S.SummonDarkglare:CooldownRemainsP() >= 45 or S.SummonDarkglare:CooldownRemainsP() < 8) and Target:TimeToDie() > (16 * Player:SpellHaste()) then
            return S.PhantomSingularity:Cast()
        end
        -- vile_taint,if=time>20
        --if S.VileTaint:IsCastableP() and (HL.CombatTime() > 20) then
        --    return S.VileTaint:Cast()
        --end
		-- APL UPDATED - vile_taint,target_if=max:target.time_to_die,if=time>15&target.time_to_die>=10
		if S.VileTaint:IsCastableP() and (HL.CombatTime() > 15) and Target:TimeToDie() >= 10 then
            return S.VileTaint:Cast()
        end
		-- APL UPDATED - unstable_affliction,if=!variable.use_seed&soul_shard=5
		if S.UnstableAffliction:IsReadyP() and (not Player:IsMoving()) and (not Player:PrevGCDP(1, S.UnstableAffliction)) and (not bool(UseSeed)) and (Player:SoulShardsP() == 5) then
            return S.UnstableAffliction:Cast()
        end			
		-- APL UPDATED - seed_of_corruption,if=variable.use_seed&soul_shard=5
		if S.SeedofCorruption:IsCastableP() and (not Player:IsMoving()) and (bool(UseSeed)) and (Player:SoulShardsP() == 5) then
            return S.SeedofCorruption:Cast()
        end			
        -- call_action_list,name=dots
        if Dots() ~= nil then
            return Dots()
        end		
		-- NEW PHANTOM HERE mm+
        -- APL UPDATED - phantom_singularity,if=time<=35
        if S.PhantomSingularity:IsCastableP() and (HL.CombatTime() <= 35) and Cache.EnemiesCount[35] >= 5 then
            return S.PhantomSingularity:Cast()
        end
		-- OPENING - phantom_singularity,if=time<=35
        if S.PhantomSingularity:IsCastableP() and (HL.CombatTime() <= 35) and (Player:SoulShardsP() <= 1) then
            return S.PhantomSingularity:Cast()
        end
        -- vile_taint
        if S.VileTaint:IsCastableP() and (HL.CombatTime() <= 15) then
            return S.VileTaint:Cast()
        end
        -- dark_soul
        if S.DarkSoul:IsCastableP() and RubimRH.CDsON() then
            return S.DarkSoul:Cast()
        end
        -- berserking
        if S.Berserking:IsCastableP() and RubimRH.CDsON() then
            return S.Berserking:Cast()
        end
		-- unstable_affliction,refresh CD OFF
	    if S.UnstableAffliction:IsReadyP() and (not RubimRH.CDsON()) and (not Player:PrevGCDP(1, S.UnstableAffliction)) and (not Player:IsMoving()) and Target:DebuffRemainsP(S.UnstableAfflictionDebuff1) <= 1.3 then
	           return S.UnstableAffliction:Cast()
	    end
		-- call_action_list,name=spenders
        if Spenders() ~= nil then
            return Spenders()
        end

		-- unstable_affliction,refresh CD ON
	    if S.UnstableAffliction:IsReadyP() and RubimRH.CDsON() and (S.SummonDarkglare:CooldownRemainsP() >= 45) and (not Player:PrevGCDP(1, S.UnstableAffliction)) and (not Player:IsMoving()) and Target:DebuffRemainsP(S.UnstableAfflictionDebuff1) <= 1.3 then
	           return S.UnstableAffliction:Cast()
	    end
        -- call_action_list,name=fillers
        if Fillers() ~= nil then
            return Fillers()
        end
    end
    return 0, 135328
end

RubimRH.Rotation.SetAPL(265, APL)

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(265, PASSIVE)