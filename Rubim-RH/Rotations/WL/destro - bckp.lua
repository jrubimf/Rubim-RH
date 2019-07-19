--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
-- HeroLib
local mainAddon = RubimRH
local HL     = HeroLib
local Cache  = HeroCache
local Unit   = HL.Unit
local Player = Unit.Player
local Target = Unit.Target
local Pet    = Unit.Pet
local Spell  = HL.Spell
local Item   = HL.Item

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
RubimRH.Spell[267] = {  
  
  SummonPet                             = Spell(688),
  GrimoireofSacrifice                   = Spell(108503),
  SoulFire                              = Spell(6353),
  Incinerate                            = Spell(29722),
  RainofFire                            = Spell(5740),
  Cataclysm                             = Spell(152108),
  Immolate                              = Spell(348),
  ChannelDemonfire                      = Spell(196447),
  ImmolateDebuff                        = Spell(157736),
  ChaosBolt                             = Spell(116858),
  ActiveHavocBuff                       = Spell(80240),
  Havoc                                 = Spell(80240),
  GrimoireofSupremacy                   = Spell(266086),
  HavocDebuff                           = Spell(80240),
  GrimoireofSupremacyBuff               = Spell(266091),
  Conflagrate                           = Spell(17962),
  Shadowburn                            = Spell(17877),
  ShadowburnDebuff                      = Spell(17877),
  BackdraftBuff                         = Spell(117828),
  SummonInfernal                        = Spell(1122),
  DarkSoulInstability                   = Spell(113858),
  Berserking                            = Spell(26297),
  BloodFury                             = Spell(20572),
  Fireblood                             = Spell(265221),
  Flashover                             = Spell(267115),
  RoaringBlaze                          = Spell(205184),
  InternalCombustion                    = Spell(266134),
  Eradication                           = Spell(196412),
  FireandBrimstone                      = Spell(196408),
  Inferno                               = Spell(270545),
  EradicationDebuff                     = Spell(196414),
  DarkSoulInstabilityBuff               = Spell(113858),
  -- Pet abilities
  CauterizeMaster                       = Spell(119905),--imp
  Suffering                             = Spell(119907),--voidwalker
  Whiplash                              = Spell(119909),--Bitch
  ShadowLock                            = Spell(171140),--doomguard
  MeteorStrike                          = Spell(171152),--infernal
  SingeMagic                            = Spell(119905),--imp
  SpellLock 							= Spell(119898),
  Shadowfury                            = Spell(30283),
  -- Defensive
  UnendingResolve                       = Spell(104773),
  SummonDoomGuard                       = Spell(18540),
  SummonDoomGuardSuppremacy             = Spell(157757),
  SummonInfernal                        = Spell(1122),
  SummonInfernalSuppremacy              = Spell(157898),
  SummonImp                             = Spell(688),
  GrimoireImp                           = Spell(111859),
  
  		  --8.2 Essences
  UnleashHeartOfAzeroth = Spell(280431),
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

 };
local S = RubimRH.Spell[267]

-- Items
if not Item.Warlock then
    Item.Warlock = {}
end
Item.Warlock.Destruction = {
  BattlePotionOfIntellect               = Item(163222)
};
local I = Item.Warlock.Destruction;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

local BestUnit, BestUnitTTD, BestUnitSpellToCast, DebuffRemains; -- Used for cycling
local range = 40
local CastIncinerate, CastImmolate, CastConflagrate, CastRainOfFire
local PetSpells={[S.Suffering:ID()] = true, [S.SpellLock:ID()] = true, [S.Whiplash:ID()] = true, [S.CauterizeMaster:ID()] = true}

local EnemyRanges = {40, 35, 5}
local function UpdateRanges()
    for _, i in ipairs(EnemyRanges) do
        HL.GetEnemies(i);
    end
end

S.ChaosBolt:RegisterInFlight()

local function num(val)
    if val then return 1 else return 0 end
end

local function bool(val)
    return val ~= 0
end

local function IsPetInvoked (testBigPets)
    testBigPets = testBigPets or false
    return S.Suffering:IsLearned() or S.SpellLock:IsLearned() or S.Whiplash:IsLearned() or S.CauterizeMaster:IsLearned() or (testBigPets and (S.ShadowLock:IsLearned() or S.MeteorStrike:IsLearned()))
end
  
local function GetImmolateStack(target)
    if not S.RoaringBlaze:IsAvailable() then  
        return 0
    end
    if not target then 
      return 0
    end
    return HL.ImmolationTable.Destruction.ImmolationDebuff[target:GUID()] or 0;
end
  
local function EnemyHasHavoc ()
    for _, Value in pairs(Cache.Enemies[range]) do
        if Value:Debuff(S.Havoc) then
            return Value:DebuffRemainsP(S.Havoc)
        end
    end
    return 0
end

local PetType = {
  [89] = {"Infernal", 30},
};

HL.DestroGuardiansTable = {
    --{PetType,petID,dateEvent,UnitPetGUID,CastsLeft}
    Pets = {
    },
    PetList={
    [89]="Infernal",
}
};
    
HL:RegisterForSelfCombatEvent(
function (...)
    local dateEvent,_,_,_,_,_,_,UnitPetGUID=select(1,...)
    local t={} ; i=1
  
    for str in string.gmatch(UnitPetGUID, "([^-]+)") do
        t[i] = str
        i = i + 1
    end
    local PetType=HL.DestroGuardiansTable.PetList[tonumber(t[6])]
    if PetType then
        table.insert(HL.DestroGuardiansTable.Pets,{PetType,tonumber(t[6]),GetTime(),UnitPetGUID,5})
    end
end
    , "SPELL_SUMMON"
);
        
-- Summoned pet duration
local function PetDuration(PetType)
    if not PetType then 
        return 0 
    end
    local PetsInfo = {
        [89] = {"Infernal", 30},
    }
    local maxduration = 0
    for key, Value in pairs(HL.DestroGuardiansTable.Pets) do
        if HL.DestroGuardiansTable.Pets[key][1] == PetType then
            if (PetsInfo[HL.DestroGuardiansTable.Pets[key][2]][2] - (GetTime() - HL.DestroGuardiansTable.Pets[key][3])) > maxduration then
                maxduration = HL.OffsetRemains((PetsInfo[HL.DestroGuardiansTable.Pets[key][2]][2] - (GetTime() - HL.DestroGuardiansTable.Pets[key][3])), "Auto" );
            end
        end
    end
    return maxduration
end

local function InfernalIsActive()
    if PetDuration("Infernal") > 1 then
        return true
   else
        return false
    end
end

local function handleSettings()
    --auto
    if RubimRH.db.profile[267].color == 1 then 
        CastIncinerate = S.IncinerateAuto
        CastImmolate = S.ImmolateAuto
        CastConflagrate = S.ConflagrateAuto
        CastRainOfFire = S.RainOfFireAuto
    --green
    elseif RubimRH.db.profile[267].color == 2 then 
        CastIncinerate = S.IncinerateGreen
        CastImmolate = S.ImmolateGreen
        CastConflagrate = S.ConflagrateGreen
        CastRainOfFire = S.RainOfFireGreen
    --orange
    else 
        CastIncinerate = S.IncinerateOrange
        CastImmolate = S.ImmolateOrange
        CastConflagrate = S.ConflagrateOrange
        CastRainOfFire = S.RainOfFireOrange
    end
end

local function FutureShard ()
    local Shard = Player:SoulShards()
    if not Player:IsCasting() then
        return Shard
    else
        if Player:IsCasting(S.ChaosBolt) then
            return Shard - 2
        elseif Player:IsCasting(S.SummonDoomGuard) or Player:IsCasting(S.SummonDoomGuardSuppremacy) or Player:IsCasting(S.SummonInfernalSuppremacy) or Player:IsCasting(S.GrimoireImp) or Player:IsCasting(S.SummonImp) then
            return Shard - 1
        elseif Player:IsCasting(S.Incinerate) then
            return Shard + 0.2
        else
            return Shard
        end
    end
end  

local function Cds()
        -- summon_infernal,if=target.time_to_die>=210|!cooldown.dark_soul_instability.remains|target.time_to_die<=30+gcd|!talent.dark_soul_instability.enabled
        if S.SummonInfernal:IsReadyP() and RubimRH.CDsON() and Player:SoulShardsP() >= 3 then
            return S.SummonInfernal:Cast()
        end
        -- dark_soul_instability,if=target.time_to_die>=140|pet.infernal.active|target.time_to_die<=20+gcd
        if S.DarkSoulInstability:IsReadyP() and RubimRH.CDsON() and (S.SummonInfernal:CooldownRemainsP() <= 171 or S.SummonInfernal:CooldownRemainsP() >= 45)   then
            return S.DarkSoulInstability:Cast()
        end
        -- berserking
        if S.Berserking:IsCastableP() and RubimRH.CDsON() then
            return S.Berserking:Cast()
        end
        -- blood_fury
        if S.BloodFury:IsCastableP() and RubimRH.CDsON() then
            return S.BloodFury:Cast()
        end
        -- fireblood
        if S.Fireblood:IsCastableP() and RubimRH.CDsON() then
            return S.Fireblood:Cast()
        end
end

local function Cata()
    -- call_action_list,name=cds
    if RubimRH.CDsON() then
            if Cds() ~= nil then
                return Cds()
            end
    end
        -- rain_of_fire,if=soul_shard>=4.5
        if S.RainofFire:IsCastableP() and RubimRH.AoEON() and Cache.EnemiesCount[35] > 5 and (Player:SoulShardsP() >= 4.5) then
            return S.RainofFire:Cast()
        end
        -- cataclysm
        if S.Cataclysm:IsCastableP() then
            return S.Cataclysm:Cast()
        end
        -- immolate,if=talent.channel_demonfire.enabled&!remains&cooldown.channel_demonfire.remains<=action.chaos_bolt.execute_time
        if S.Immolate:IsCastableP() and not Player:IsCasting(S.Immolate) and S.ChannelDemonfire:IsAvailable() and not bool(Target:DebuffRemainsP(S.ImmolateDebuff)) and S.ChannelDemonfire:CooldownRemainsP() <= S.ChaosBolt:ExecuteTime() then
            return S.Immolate:Cast()
        end
        -- channel_demonfire,if=!buff.active_havoc.remains
        if S.ChannelDemonfire:IsCastableP() and (not bool(Player:BuffRemainsP(S.ActiveHavocBuff))) then
            return S.ChannelDemonfire:Cast()
        end
        -- havoc,if=!(target=sim.target)&target.time_to_die>10&spell_targets.rain_of_fire<=8+raid_event.invulnerable.up&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
        if S.Havoc:IsCastableP() and Player:SoulShardsP() >= 2 and RubimRH.AoEON() and Target:TimeToDie() > 10 and Cache.EnemiesCount[35] <= 8  and S.GrimoireofSupremacy:IsAvailable() and InfernalIsActive() and PetDuration("Infernal") <= 10 then
            return S.Havoc:Cast()
        end
        -- havoc,if=spell_targets.rain_of_fire<=8+raid_event.invulnerable.up&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
        if S.Havoc:IsCastableP() and Player:SoulShardsP() >= 2 and RubimRH.AoEON() and Cache.EnemiesCount[35] <= 8  and S.GrimoireofSupremacy:IsAvailable() and InfernalIsActive() and PetDuration("Infernal") <= 10 then
            return S.Havoc:Cast()
        end
        -- chaos_bolt,if=!debuff.havoc.remains&talent.grimoire_of_supremacy.enabled&pet.infernal.remains>execute_time&active_enemies<=8+raid_event.invulnerable.up&((108*(spell_targets.rain_of_fire+raid_event.invulnerable.up)%3)<(240*(1+0.08*buff.grimoire_of_supremacy.stack)%2*(1+buff.active_havoc.remains>execute_time)))
        if S.ChaosBolt:IsCastableP() and (FutureShard() >= 2) and not bool(Target:DebuffRemainsP(S.HavocDebuff)) and S.GrimoireofSupremacy:IsAvailable() and PetDuration("Infernal") > S.ChaosBolt:ExecuteTime() and Cache.EnemiesCount[40] <= 8  and ((108 * (Cache.EnemiesCount[35] ) / 3) < (240 * (1 + 0.08 * Player:BuffStackP(S.GrimoireofSupremacyBuff)) / 2 * num((1 + Player:BuffRemainsP(S.ActiveHavocBuff) > S.ChaosBolt:ExecuteTime())))) then
            return S.ChaosBolt:Cast()
        end
        -- havoc,if=!(target=sim.target)&target.time_to_die>10&spell_targets.rain_of_fire<=4+raid_event.invulnerable.up
        if S.Havoc:IsCastableP() and Player:SoulShardsP() >= 2 and RubimRH.AoEON() and (Target:TimeToDie() > 10 and Cache.EnemiesCount[35] <= 4 ) then
            return S.Havoc:Cast()
        end
        -- havoc,if=spell_targets.rain_of_fire<=4+raid_event.invulnerable.up
        if S.Havoc:IsCastableP() and Player:SoulShardsP() >= 2 and RubimRH.AoEON() and (Cache.EnemiesCount[35] <= 4 ) then
            return S.Havoc:Cast()
        end
        -- chaos_bolt,if=!debuff.havoc.remains&buff.active_havoc.remains>execute_time&spell_targets.rain_of_fire<=4+raid_event.invulnerable.up
        if S.ChaosBolt:IsCastableP() and (FutureShard() >= 2) and not bool(Target:DebuffRemainsP(S.HavocDebuff)) and Player:BuffRemainsP(S.ActiveHavocBuff) > S.ChaosBolt:ExecuteTime() and Cache.EnemiesCount[35] <= 4 then
            return S.ChaosBolt:Cast()
        end
        -- immolate,if=!debuff.havoc.remains&refreshable&remains<=cooldown.cataclysm.remains
        if S.Immolate:IsCastableP() and not Player:IsCasting(S.Immolate) and not bool(Target:DebuffRemainsP(S.HavocDebuff)) and Target:DebuffRefreshableCP(S.ImmolateDebuff) and Target:DebuffRemainsP(S.ImmolateDebuff) <= S.Cataclysm:CooldownRemainsP() then
            return S.Immolate:Cast()
        end
        -- rain_of_fire
        if S.RainofFire:IsCastableP() and RubimRH.AoEON() and Cache.EnemiesCount[35] > 5 and (FutureShard() > 3) then
            return S.RainofFire:Cast()
        end
        -- soul_fire,if=!debuff.havoc.remains
        if S.SoulFire:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff))) then
            return S.SoulFire:Cast()
        end
        -- conflagrate,if=!debuff.havoc.remains
        if S.Conflagrate:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff))) then
            return S.Conflagrate:Cast()
        end
        -- shadowburn,if=!debuff.havoc.remains&((charges=2|!buff.backdraft.remains|buff.backdraft.remains>buff.backdraft.stack*action.incinerate.execute_time))
        if S.Shadowburn:IsCastableP() and not bool(Target:DebuffRemainsP(S.HavocDebuff)) and ((S.Shadowburn:ChargesP() == 2 or not bool(Player:BuffRemainsP(S.BackdraftBuff)) or Player:BuffRemainsP(S.BackdraftBuff) > Player:BuffStackP(S.BackdraftBuff) * S.Incinerate:ExecuteTime())) then
            return S.Shadowburn:Cast()
        end
        -- incinerate,if=!debuff.havoc.remains
        if S.Incinerate:IsCastableP() and Player:SoulShardsP() < 4.5 and (not bool(Target:DebuffRemainsP(S.HavocDebuff))) then
            return S.Incinerate:Cast()
        end
    end
    
    local function Fnb()
        -- call_action_list,name=cds
        if RubimRH.CDsON() then
            if Cds() ~= nil then
                return Cds()
            end
        end
        -- rain_of_fire,if=soul_shard>=4.5
        if S.RainofFire:IsCastableP() and RubimRH.AoEON() and active_enemies() > 5 and (Player:SoulShardsP() >= 4.5) then
            return S.RainofFire:Cast()
        end
        -- immolate,if=talent.channel_demonfire.enabled&!remains&cooldown.channel_demonfire.remains<=action.chaos_bolt.execute_time
        if S.Immolate:IsCastableP() and not Player:IsCasting(S.Immolate) and  S.ChannelDemonfire:IsAvailable() and not bool(Target:DebuffRemainsP(S.ImmolateDebuff)) and S.ChannelDemonfire:CooldownRemainsP() <= S.ChaosBolt:ExecuteTime() then
            return S.Immolate:Cast()
        end
        -- channel_demonfire,if=!buff.active_havoc.remains
        if S.ChannelDemonfire:IsCastableP() and (not bool(Player:BuffRemainsP(S.ActiveHavocBuff))) then
            return S.ChannelDemonfire:Cast()
        end
        -- havoc,if=!(target=sim.target)&target.time_to_die>10&spell_targets.rain_of_fire<=4+raid_event.invulnerable.up&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
        if S.Havoc:IsCastableP() and Player:SoulShardsP() >= 2 and RubimRH.AoEON() and Target:TimeToDie() > 10 and active_enemies() <= 4  and S.GrimoireofSupremacy:IsAvailable() and InfernalIsActive() and Target:DebuffRemainsP(S.HavocDebuff) <= 10 then
            return S.Havoc:Cast()
        end
        -- havoc,if=spell_targets.rain_of_fire<=4+raid_event.invulnerable.up&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
        if S.Havoc:IsCastableP() and Player:SoulShardsP() >= 2 and RubimRH.AoEON() and active_enemies() <= 4  and S.GrimoireofSupremacy:IsAvailable() and InfernalIsActive() and PetDuration("Infernal") <= 10 then
            return S.Havoc:Cast()
        end
        -- chaos_bolt,if=!debuff.havoc.remains&talent.grimoire_of_supremacy.enabled&pet.infernal.remains>execute_time&active_enemies<=4+raid_event.invulnerable.up&((108*(spell_targets.rain_of_fire+raid_event.invulnerable.up)%3)<(240*(1+0.08*buff.grimoire_of_supremacy.stack)%2*(1+buff.active_havoc.remains>execute_time)))
        if S.ChaosBolt:IsCastableP() and (FutureShard() >= 2) and not bool(Target:DebuffRemainsP(S.HavocDebuff)) and S.GrimoireofSupremacy:IsAvailable() and PetDuration("Infernal") > S.ChaosBolt:ExecuteTime() and active_enemies() <= 4  and ((108 * (Cache.EnemiesCount[35] ) / 3) < (240 * (1 + 0.08 * Player:BuffStackP(S.GrimoireofSupremacyBuff)) / 2 * num((1 + Player:BuffRemainsP(S.ActiveHavocBuff) > S.ChaosBolt:ExecuteTime())))) then
            return S.ChaosBolt:Cast()
        end
        -- havoc,if=!(target=sim.target)&target.time_to_die>10&spell_targets.rain_of_fire<=4+raid_event.invulnerable.up
        if S.Havoc:IsCastableP() and Player:SoulShardsP() >= 2 and RubimRH.AoEON() and Target:TimeToDie() > 10 and active_enemies() <= 4 then
            return S.Havoc:Cast()
        end
        -- havoc,if=spell_targets.rain_of_fire<=4+raid_event.invulnerable.up
        if S.Havoc:IsCastableP() and Player:SoulShardsP() >= 2 and RubimRH.AoEON() and (active_enemies() <= 4 ) then
            return S.Havoc:Cast()
        end
        -- chaos_bolt,if=!debuff.havoc.remains&buff.active_havoc.remains>execute_time&spell_targets.rain_of_fire<=4+raid_event.invulnerable.up
        if S.ChaosBolt:IsCastableP() and (FutureShard() >= 2) and not bool(Target:DebuffRemainsP(S.HavocDebuff)) and Player:BuffRemainsP(S.ActiveHavocBuff) > S.ChaosBolt:ExecuteTime() and active_enemies() <= 4  then
            return S.ChaosBolt:Cast()
        end
        -- immolate,if=!debuff.havoc.remains&refreshable&spell_targets.incinerate<=8+raid_event.invulnerable.up
        if S.Immolate:IsCastableP() and not Player:IsCasting(S.Immolate) and  not bool(Target:DebuffRemainsP(S.HavocDebuff)) and Target:DebuffRefreshableCP(S.ImmolateDebuff) and active_enemies() <= 8  then
            return S.Immolate:Cast()
        end
        -- rain_of_fire
        if S.RainofFire:IsCastableP() and RubimRH.AoEON() and active_enemies() > 5 and (FutureShard() > 3) then
            return S.RainofFire:Cast()
        end
        -- soul_fire,if=!debuff.havoc.remains&spell_targets.incinerate<=3+raid_event.invulnerable.up
        if S.SoulFire:IsCastableP() and not bool(Target:DebuffRemainsP(S.HavocDebuff)) and active_enemies() <= 3 then
            return S.SoulFire:Cast()
        end
        -- conflagrate,if=!debuff.havoc.remains&(talent.flashover.enabled&buff.backdraft.stack<=2|spell_targets.incinerate<=7+raid_event.invulnerable.up|talent.roaring_blaze.enabled&spell_targets.incinerate<=9+raid_event.invulnerable.up)
        if S.Conflagrate:IsCastableP() and not bool(Target:DebuffRemainsP(S.HavocDebuff)) and S.Flashover:IsAvailable() and Player:BuffStackP(S.BackdraftBuff) <= 2 then
            return S.Conflagrate:Cast()
        end
        -- incinerate,if=!debuff.havoc.remains
        if S.Incinerate:IsCastableP() and Player:SoulShardsP() < 4.5  and (not bool(Target:DebuffRemainsP(S.HavocDebuff))) then
            return S.Incinerate:Cast()
        end
    end
    
    local function Inf()
        -- call_action_list,name=cds
        if RubimRH.CDsON() then
            if Cds() ~= nil then
                return Cds()
            end
        end
        -- rain_of_fire,if=soul_shard>=4.5
        if S.RainofFire:IsCastableP() and RubimRH.AoEON() and active_enemies() > 5 and (FutureShard() > 4) then
            return S.RainofFire:Cast()
        end
        -- cataclysm
        if S.Cataclysm:IsCastableP() then
            return S.Cataclysm:Cast()
        end
        -- immolate,if=talent.channel_demonfire.enabled&!remains&cooldown.channel_demonfire.remains<=action.chaos_bolt.execute_time
        if S.Immolate:IsCastableP() and not Player:IsCasting(S.Immolate) and S.ChannelDemonfire:IsAvailable() and not bool(Target:DebuffRemainsP(S.ImmolateDebuff)) and S.ChannelDemonfire:CooldownRemainsP() <= S.ChaosBolt:ExecuteTime() then
            return S.Immolate:Cast()
        end
        -- channel_demonfire,if=!buff.active_havoc.remains
        if S.ChannelDemonfire:IsCastableP() and (not bool(Player:BuffRemainsP(S.ActiveHavocBuff))) then
            return S.ChannelDemonfire:Cast()
        end
        -- havoc,if=!(target=sim.target)&target.time_to_die>10&spell_targets.rain_of_fire<=4+raid_event.invulnerable.up+talent.internal_combustion.enabled&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
        if S.Havoc:IsCastableP() and Player:SoulShardsP() >= 2 and RubimRH.AoEON() and Target:TimeToDie() > 10 and active_enemies() <= 4  + num(S.InternalCombustion:IsAvailable()) and S.GrimoireofSupremacy:IsAvailable() and InfernalIsActive() and PetDuration("Infernal") <= 10 then
            return S.Havoc:Cast()
        end
        -- havoc,if=spell_targets.rain_of_fire<=4+raid_event.invulnerable.up+talent.internal_combustion.enabled&talent.grimoire_of_supremacy.enabled&pet.infernal.active&pet.infernal.remains<=10
        if S.Havoc:IsCastableP() and Player:SoulShardsP() >= 2 and RubimRH.AoEON() and active_enemies() <= 4  + num(S.InternalCombustion:IsAvailable()) and S.GrimoireofSupremacy:IsAvailable() and InfernalIsActive() and PetDuration("Infernal") <= 10 then
            return S.Havoc:Cast()
        end
        -- chaos_bolt,if=!debuff.havoc.remains&talent.grimoire_of_supremacy.enabled&pet.infernal.remains>execute_time&spell_targets.rain_of_fire<=4+raid_event.invulnerable.up+talent.internal_combustion.enabled&((108*(spell_targets.rain_of_fire+raid_event.invulnerable.up)%(3-0.16*(spell_targets.rain_of_fire+raid_event.invulnerable.up)))<(240*(1+0.08*buff.grimoire_of_supremacy.stack)%2*(1+buff.active_havoc.remains>execute_time)))
        if S.ChaosBolt:IsCastableP() and (FutureShard() >= 2) and not bool(Target:DebuffRemainsP(S.HavocDebuff)) and S.GrimoireofSupremacy:IsAvailable() and PetDuration("Infernal") > S.ChaosBolt:ExecuteTime() and active_enemies() <= 4  + num(S.InternalCombustion:IsAvailable()) and ((108 * (Cache.EnemiesCount[35] ) / (3 - 0.16 * (Cache.EnemiesCount[35] ))) < (240 * (1 + 0.08 * Player:BuffStackP(S.GrimoireofSupremacyBuff)) / 2 * num((1 + Player:BuffRemainsP(S.ActiveHavocBuff) > S.ChaosBolt:ExecuteTime())))) then
            return S.ChaosBolt:Cast()
        end
        -- havoc,if=!(target=sim.target)&target.time_to_die>10&spell_targets.rain_of_fire<=3+raid_event.invulnerable.up&(talent.eradication.enabled|talent.internal_combustion.enabled)
        if S.Havoc:IsCastableP() and Player:SoulShardsP() >= 2 and RubimRH.AoEON() and Target:TimeToDie() > 10 and active_enemies() <= 3  and (S.Eradication:IsAvailable() or S.InternalCombustion:IsAvailable()) then
            return S.Havoc:Cast()
        end
        -- havoc,if=spell_targets.rain_of_fire<=3+raid_event.invulnerable.up&(talent.eradication.enabled|talent.internal_combustion.enabled)
        if S.Havoc:IsCastableP() and Player:SoulShardsP() >= 2 and RubimRH.AoEON() and active_enemies() <= 3  and (S.Eradication:IsAvailable() or S.InternalCombustion:IsAvailable()) then
            return S.Havoc:Cast()
        end
        -- chaos_bolt,if=!debuff.havoc.remains&buff.active_havoc.remains>execute_time&spell_targets.rain_of_fire<=3+raid_event.invulnerable.up&(talent.eradication.enabled|talent.internal_combustion.enabled)
        if S.ChaosBolt:IsCastableP() and (FutureShard() >= 2) and not bool(Target:DebuffRemainsP(S.HavocDebuff)) and Player:BuffRemainsP(S.ActiveHavocBuff) > S.ChaosBolt:ExecuteTime() and active_enemies() <= 3  and (S.Eradication:IsAvailable() or S.InternalCombustion:IsAvailable()) then
            return S.ChaosBolt:Cast()
        end
        -- immolate,if=!debuff.havoc.remains&refreshable
        if S.Immolate:IsCastableP() and not Player:IsCasting(S.Immolate) and  not bool(Target:DebuffRemainsP(S.HavocDebuff)) and Target:DebuffRefreshableCP(S.ImmolateDebuff) then
            return S.Immolate:Cast()
        end
        -- rain_of_fire
        if S.RainofFire:IsCastableP() and RubimRH.AoEON() and active_enemies() > 5 and (FutureShard() > 3) then
            return S.RainofFire:Cast()
        end
        -- soul_fire,if=!debuff.havoc.remains
        if S.SoulFire:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff))) then
            return S.SoulFire:Cast()
        end
        -- conflagrate,if=!debuff.havoc.remains
        if S.Conflagrate:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff))) then
            return S.Conflagrate:Cast()
        end
        -- shadowburn,if=!debuff.havoc.remains&((charges=2|!buff.backdraft.remains|buff.backdraft.remains>buff.backdraft.stack*action.incinerate.execute_time))
        if S.Shadowburn:IsCastableP() and not bool(Target:DebuffRemainsP(S.HavocDebuff)) and ((S.Shadowburn:ChargesP() == 2 or not bool(Player:BuffRemainsP(S.BackdraftBuff)) or Player:BuffRemainsP(S.BackdraftBuff) > Player:BuffStackP(S.BackdraftBuff) * S.Incinerate:ExecuteTime())) then
            return S.Shadowburn:Cast()
        end
        -- incinerate,if=!debuff.havoc.remains
        if S.Incinerate:IsCastableP() and Player:SoulShardsP() < 4.5 and (not bool(Target:DebuffRemainsP(S.HavocDebuff))) then
            return S.Incinerate:Cast()
        end
    end
	
local function DetermineEssenceRanks()
  S.BloodOfTheEnemy = S.BloodOfTheEnemy2:IsAvailable() and S.BloodOfTheEnemy2 or S.BloodOfTheEnemy
  S.BloodOfTheEnemy = S.BloodOfTheEnemy3:IsAvailable() and S.BloodOfTheEnemy3 or S.BloodOfTheEnemy
  S.MemoryOfLucidDreams = S.MemoryOfLucidDreams2:IsAvailable() and S.MemoryOfLucidDreams2 or S.MemoryOfLucidDreams
  S.MemoryOfLucidDreams = S.MemoryOfLucidDreams3:IsAvailable() and S.MemoryOfLucidDreams3 or S.MemoryOfLucidDreams
  S.PurifyingBlast = S.PurifyingBlast2:IsAvailable() and S.PurifyingBlast2 or S.PurifyingBlast
  S.PurifyingBlast = S.PurifyingBlast3:IsAvailable() and S.PurifyingBlast3 or S.PurifyingBlast
  S.RippleInSpace = S.RippleInSpace2:IsAvailable() and S.RippleInSpace2 or S.RippleInSpace
  S.RippleInSpace = S.RippleInSpace3:IsAvailable() and S.RippleInSpace3 or S.RippleInSpace
  S.ConcentratedFlame = S.ConcentratedFlame2:IsAvailable() and S.ConcentratedFlame2 or S.ConcentratedFlame
  S.ConcentratedFlame = S.ConcentratedFlame3:IsAvailable() and S.ConcentratedFlame3 or S.ConcentratedFlame
  S.TheUnboundForce = S.TheUnboundForce2:IsAvailable() and S.TheUnboundForce2 or S.TheUnboundForce
  S.TheUnboundForce = S.TheUnboundForce3:IsAvailable() and S.TheUnboundForce3 or S.TheUnboundForce
  S.WorldveinResonance = S.WorldveinResonance2:IsAvailable() and S.WorldveinResonance2 or S.WorldveinResonance
  S.WorldveinResonance = S.WorldveinResonance3:IsAvailable() and S.WorldveinResonance3 or S.WorldveinResonance
  S.FocusedAzeriteBeam = S.FocusedAzeriteBeam2:IsAvailable() and S.FocusedAzeriteBeam2 or S.FocusedAzeriteBeam
  S.FocusedAzeriteBeam = S.FocusedAzeriteBeam3:IsAvailable() and S.FocusedAzeriteBeam3 or S.FocusedAzeriteBeam
end
	
	-- # Essences
local function Essences()
  -- blood_of_the_enemy
  if S.BloodOfTheEnemy:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- concentrated_flame
  if S.ConcentratedFlame:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- guardian_of_azeroth
  if S.GuardianOfAzeroth:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- focused_azerite_beam
  if S.FocusedAzeriteBeam:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- purifying_blast
  if S.PurifyingBlast:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- the_unbound_force
  if S.TheUnboundForce:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- ripple_in_space
  if S.RippleInSpace:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- worldvein_resonance
  if S.WorldveinResonance:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  -- memory_of_lucid_dreams,if=fury<40&buff.metamorphosis.up
  if S.MemoryOfLucidDreams:IsCastableP() then
    return S.UnleashHeartOfAzeroth:Cast()
  end
  return false
end

--- ======= ACTION LISTS =======
local function APL()
    --local Precombat, Cata, Cds, Fnb, Inf
    UpdateRanges()
    DetermineEssenceRanks()
	Precombat_DBM = function()
        -- flask
        -- food
        -- augmentation
        -- summon_pet
        if S.SummonPet:IsCastableP() and not IsPetInvoked() then
            return S.SummonPet:Cast()
        end
        -- grimoire_of_sacrifice,if=talent.grimoire_of_sacrifice.enabled
        if S.GrimoireofSacrifice:IsCastableP() and (S.GrimoireofSacrifice:IsAvailable()) then
            return S.GrimoireofSacrifice:Cast()
        end
        -- snapshot_stats
	    -- potion
        if I.BattlePotionOfIntellect:IsReady() and RubimRH.DBM_PullTimer() >= S.Incinerate:CastTime() + 1 and RubimRH.DBM_PullTimer() <= S.Incinerate:CastTime() + 2 then
            return 967532
        end
        -- soul_fire
        --if S.SoulFire:IsCastableP() and RubimRH.DBM_PullTimer() > 1 and RubimRH.DBM_PullTimer() <= S.SoulFire:CastTime() then
        --    return S.SoulFire:Cast()
        --end
        -- incinerate,if=!talent.soul_fire.enabled
        if S.Incinerate:IsCastableP() and Player:SoulShardsP() < 4.5 and (not S.SoulFire:IsAvailable()) and RubimRH.DBM_PullTimer() > 0.1 and RubimRH.DBM_PullTimer() <= S.Incinerate:CastTime() + S.Incinerate:TravelTime() then
            return S.Incinerate:Cast()
        end
    end
	
	Precombat = function()
        -- flask
        -- food
        -- augmentation
        -- summon_pet
        if S.SummonPet:IsCastableP() and not IsPetInvoked() then
            return S.SummonPet:Cast()
        end
        -- grimoire_of_sacrifice,if=talent.grimoire_of_sacrifice.enabled
        if S.GrimoireofSacrifice:IsCastableP() and (S.GrimoireofSacrifice:IsAvailable()) then
            return S.GrimoireofSacrifice:Cast()
        end
        -- snapshot_stats
        -- potion
        --if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions then
        --    HR.CastSuggested(I.ProlongedPower):Cast()
        --end
        -- soul_fire
        if S.SoulFire:IsCastableP() then
            return S.SoulFire:Cast()
        end
        -- incinerate,if=!talent.soul_fire.enabled
        if S.Incinerate:IsCastableP() and Player:SoulShardsP() < 4.5 and (not S.SoulFire:IsAvailable()) then
            return S.Incinerate:Cast()
        end
    end

    -- call precombat DBM
    if not Player:AffectingCombat() and RubimRH.PrecombatON() and RubimRH.PerfectPullON() and not Player:IsCasting() then
            if Precombat_DBM() ~= nil then
                return Precombat_DBM()
            end
    end
	-- call precombat
    if not Player:AffectingCombat() and RubimRH.PrecombatON() and not RubimRH.PerfectPullON() and not Player:IsCasting() then
            if Precombat() ~= nil then
                return Precombat()
            end
    end
    
    if Player:IsChanneling() then
        return 0, 236353
    end
	
    -- combat
    if RubimRH.TargetIsValid() then
		if QueueSkill() ~= nil then
            return QueueSkill()
        end
-- call_action_list,name=essences
    local ShouldReturn = Essences(); if ShouldReturn and (true) then return ShouldReturn; end
        -- run_action_list,name=cata,if=spell_targets.infernal_awakening>=3+raid_event.invulnerable.up&talent.cataclysm.enabled
        if active_enemies() >= 3 and S.Cataclysm:IsAvailable() then
            if Cata() ~= nil then
                return Cata()
            end
        end
        -- run_action_list,name=fnb,if=spell_targets.infernal_awakening>=3+raid_event.invulnerable.up&talent.fire_and_brimstone.enabled
        if active_enemies() >= 3 and S.FireandBrimstone:IsAvailable() then
            if Fnb() ~= nil then
                return Fnb()
            end
        end
        -- run_action_list,name=inf,if=spell_targets.infernal_awakening>=3+raid_event.invulnerable.up&talent.inferno.enabled
        if active_enemies() >= 3 and S.Inferno:IsAvailable() then
            if Inf() ~= nil then
                return Inf()
            end
        end
        -- auto switch target on havoc cast and not player tabbing
        if S.Havoc:CooldownRemainsP() > 1 and bool(Target:DebuffRemainsP(S.HavocDebuff)) and RubimRH.AoEON() then
            return 133015
        end
    	-- unending resolve,defensive,player.health<=40
       if S.UnendingResolve:IsCastableP() and Player:HealthPercentage() <= mainAddon.db.profile[266].sk1 then
            return S.UnendingResolve:Cast()
        end  
	    -- Mythic+ - interrupt2 (command demon)
	    if S.SpellLock:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() then
	    	return 0, "Interface\\Addons\\Rubim-RH\\Media\\wl_lock_red.tga"
	    end
	    -- Mythic+ - Shadowfury aoe stun test
        if S.Shadowfury:IsCastableP() and (not Player:IsMoving()) and not Player:ShouldStopCasting() and RubimRH.InterruptsON() and active_enemies() >= 3 and Target:IsInterruptible() then
	    	return S.Shadowfury:Cast()
        end	
        -- cataclysm
        if S.Cataclysm:IsCastableP() then
            return S.Cataclysm:Cast()
        end
        -- immolate,if=!debuff.havoc.remains&(refreshable|talent.internal_combustion.enabled&action.chaos_bolt.in_flight&remains-action.chaos_bolt.travel_time-5<duration*0.3)
        if S.Immolate:IsCastableP() and not Player:IsCasting(S.Immolate) and not bool(Target:DebuffRemainsP(S.HavocDebuff)) and (Target:DebuffRefreshableCP(S.ImmolateDebuff) or S.InternalCombustion:IsAvailable() and S.ChaosBolt:InFlight() and Target:DebuffRemainsP(S.ImmolateDebuff) - S.ChaosBolt:TravelTime() - 5 < S.ImmolateDebuff:BaseDuration() * 0.3) then
            return S.Immolate:Cast()
        end
        -- call_action_list,name=cds
        if RubimRH.CDsON() then
            if Cds() ~= nil then
                return Cds()
            end
        end
        -- channel_demonfire,if=!buff.active_havoc.remains
        if S.ChannelDemonfire:IsCastableP() and (not bool(Player:BuffRemainsP(S.ActiveHavocBuff))) then
            return S.ChannelDemonfire:Cast()
        end
        -- havoc,if=!(target=sim.target)&target.time_to_die>10&active_enemies>1+raid_event.invulnerable.up
        if S.Havoc:IsCastableP() and Player:SoulShardsP() >= 2 and RubimRH.AoEON() and (Target:TimeToDie() > 10 and active_enemies() > 1 ) then
            return S.Havoc:Cast()
        end
        -- havoc,if=active_enemies>1+raid_event.invulnerable.up
        if S.Havoc:IsCastableP() and Player:SoulShardsP() >= 2 and RubimRH.AoEON() and (active_enemies() > 1 ) then
            return S.Havoc:Cast()
        end
        -- soul_fire,if=!debuff.havoc.remains
        if S.SoulFire:IsCastableP() and (not bool(Target:DebuffRemainsP(S.HavocDebuff))) then
            return S.SoulFire:Cast()
        end
        -- chaos_bolt,if=!debuff.havoc.remains&execute_time+travel_time<target.time_to_die&(cooldown.summon_infernal.remains>=20|!talent.grimoire_of_supremacy.enabled)&(cooldown.dark_soul_instability.remains>=20|!talent.dark_soul_instability.enabled)&(talent.eradication.enabled&debuff.eradication.remains<=cast_time|buff.backdraft.remains|talent.internal_combustion.enabled) 
		-- removed and S.ChaosBolt:ExecuteTime() + S.ChaosBolt:TravelTime() < Target:TimeToDie()
        if S.ChaosBolt:IsCastableP() and FutureShard() >= 2 and not bool(Target:DebuffRemainsP(S.HavocDebuff)) and (S.SummonInfernal:CooldownRemainsP() >= 20 or not S.GrimoireofSupremacy:IsAvailable()) and (S.DarkSoulInstability:CooldownRemainsP() >= 20 or not S.DarkSoulInstability:IsAvailable()) and (S.Eradication:IsAvailable() and Target:DebuffRemainsP(S.EradicationDebuff) <= S.ChaosBolt:CastTime() or bool(Player:BuffRemainsP(S.BackdraftBuff)) or S.InternalCombustion:IsAvailable()) then
            return S.ChaosBolt:Cast()
        end
        -- chaos_bolt,if=!debuff.havoc.remains&execute_time+travel_time<target.time_to_die&(soul_shard>=4|buff.dark_soul_instability.remains>cast_time|pet.infernal.active|buff.active_havoc.remains>cast_time)
		-- removed and S.ChaosBolt:ExecuteTime() + S.ChaosBolt:TravelTime() < Target:TimeToDie()
        if S.ChaosBolt:IsCastableP() and FutureShard() >= 2 and not bool(Target:DebuffRemainsP(S.HavocDebuff)) and (Player:SoulShardsP() >= 4 or Player:BuffRemainsP(S.DarkSoulInstabilityBuff) > S.ChaosBolt:CastTime() or InfernalIsActive() or Player:BuffRemainsP(S.ActiveHavocBuff) > S.ChaosBolt:CastTime()) then
            return S.ChaosBolt:Cast()
        end
		-- conflagrate,if=!debuff.havoc.remains&((talent.flashover.enabled&buff.backdraft.stack<=2)|(!talent.flashover.enabled&buff.backdraft.stack<2))
        if S.Conflagrate:IsCastableP() and not bool(Target:DebuffRemainsP(S.HavocDebuff)) and ((S.Flashover:IsAvailable() and Player:BuffStackP(S.BackdraftBuff) <= 2) or (not S.Flashover:IsAvailable() and Player:BuffStackP(S.BackdraftBuff) < 2)) then
            return S.Conflagrate:Cast()
        end
        -- shadowburn,if=!debuff.havoc.remains&((charges=2|!buff.backdraft.remains|buff.backdraft.remains>buff.backdraft.stack*action.incinerate.execute_time))
        if S.Shadowburn:IsCastableP() and not bool(Target:DebuffRemainsP(S.HavocDebuff)) and ((S.Shadowburn:ChargesP() == 2 or not bool(Player:BuffRemainsP(S.BackdraftBuff)) or Player:BuffRemainsP(S.BackdraftBuff) > Player:BuffStackP(S.BackdraftBuff) * S.Incinerate:ExecuteTime())) then
            return S.Shadowburn:Cast()
        end
        -- incinerate,if=!debuff.havoc.remains
        if S.Incinerate:IsCastableP() and not bool(Target:DebuffRemainsP(S.HavocDebuff)) then
        return S.Incinerate:Cast()
        end
    end
    return 0, 135328
end

RubimRH.Rotation.SetAPL(267, APL)

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(267, PASSIVE)