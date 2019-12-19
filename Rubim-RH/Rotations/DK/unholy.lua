--- ============================ HEADER ============================
-- Addon
local addonName, addonTable = ...;
-- HeroLib
local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local MouseOver = Unit.MouseOver
local Pet = Unit.Pet;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;

-- Lua

--- ============================ CONTENT ============================
RubimRH.Spell[252] = {
    RaiseDead = Spell(46584),
    ArmyoftheDead = Spell(42650),
    DeathAndDecay = Spell(43265),
    DeathAndDecayBuff = Spell(188290),
    Apocalypse = Spell(275699),
    Defile = Spell(152280),
    Epidemic = Spell(207317),
    DeathCoil = Spell(47541),
    ScourgeStrike = Spell(55090),
    ClawingShadows = Spell(207311),
    FesteringStrike = Spell(85948),
    BurstingSores = Spell(207264),
    FesteringWoundDebuff = Spell(194310),
    SuddenDoomBuff = Spell(81340),
    UnholyFrenzyBuff = Spell(207289),
    ChainsofIce = Spell(45524),
    UnholyStrengthBuff = Spell(53365),
    ColdHeartItemBuff = Spell(235599),
    MasterofGhoulsBuff = Spell(246995),
    DarkTransformation = Spell(63560),
    SummonGargoyle = Spell(49206),
    UnholyFrenzy = Spell(207289),
    SoulReaper = Spell(130736),
    UnholyBlight = Spell(115989),
    Pestilence = Spell(277234),
    MindFreeze = Spell(47528),
    ArcaneTorrent = Spell(50613),
    BloodFury = Spell(20572),
    Berserking = Spell(26297),
    TemptationBuff = Spell(234143),
    Outbreak = Spell(77575),
    VirulentPlagueDebuff = Spell(191587),
    DarkSuccor = Spell(101568),
    DeathStrike = Spell(49998),
    DeathsAdvance = Spell(48265),
    DeathGrip = Spell(49576),
    DeathPact = Spell(48743),
    IceboundFortitude = Spell(48792),
    NecroticStrike = Spell(223829),
    RaiseAlly = Spell(61999),
    DarkSimulacrum = Spell(77606),
    Asphyxiate = Spell(108194),
    AntiMagicShell = Spell(48707),
    MagusoftheDead = Spell(288417),
	
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
          RecklessForceCounterBuff2     = Spell(298409),
          RecklessForceCounterBuff  = Spell(302917),
          RecklessForceBuff     = Spell(302932),
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
local S = RubimRH.Spell[252]
S.ClawingShadows.TextureSpellID = { 241367 }

if not Item.DeathKnight then
    Item.DeathKnight = {}
end
-- Items
if not Item.DeathKnight then Item.DeathKnight = {} end
Item.DeathKnight.Unholy = {
  BattlePotionofStrength           = Item(163224),
  RampingAmplitudeGigavoltEngine   = Item(165580),
  BygoneBeeAlmanac                 = Item(163936),
  JesHowler                        = Item(159627),
  GalecallersBeak                  = Item(161379),
  GrongsPrimalRage                 = Item(165574)
};
local I = Item.DeathKnight.Unholy;

local T202PC, T204PC = HL.HasTier("T20");
local T212PC, T214PC = HL.HasTier("T21");
-- Rotation Var
local ShouldReturn; -- Used to get the return string
local poolingforgargoyle

local function GargoyleDuration()
    local gargoyleDuration = 0
    for i = 1, 5 do
        local active, totemName, startTime, duration, textureId = GetTotemInfo(i)
        if active == true and textureId == 458967 and startTime ~= nil and duration ~= nil then
            gargoyleDuration = startTime + duration - GetTime()
        end
    end
    return gargoyleDuration
end

function Unit:GargoyleActive()
    if GargoyleDuration() > 0 then
        return true
    else
        return false
    end
end

-- Variables
local VarPoolingForGargoyle = 0;

local EnemyRanges = { "Melee", 5, 8, 10, 30 }
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
    S.DarkTransformation,
    S.UnholyFrenzy,
    S.Apocalypse,
    S.ArmyoftheDead,
    S.DeathAndDecay,
    

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
    S.RecklessForceCounterBuff = S.RecklessForceCounterBuff2:IsAvailable() and S.RecklessForceCounterBuff2 or S.RecklessForceCounterBuff
end

local function APL()
    local Precombat, Aoe, ColdHeart, Cooldowns, Generic
    UpdateRanges()
    UpdateCDs()
    if QueueSkill() ~= nil then
        return QueueSkill()
    end
    Precombat = function()
        -- flask
        -- food
        -- augmentation
        -- snapshot_stats
        -- potion
        -- raise_dead
        if S.RaiseDead:IsReady() and not Pet:IsActive() then
            return S.RaiseDead:Cast()
        end
        -- army_of_the_dead
        --if S.ArmyoftheDead:IsReady() and HL.BMPullTime() <= select(2, GetRuneCooldown(1)) - 1 then
            --return S.ArmyoftheDead:Cast()
        --end
        -- use_item,name=azsharas_font_of_power
    end
    
	Aoe = function()
        -- death_and_decay,if=cooldown.apocalypse.remains
        if S.DeathAndDecay:IsReady('Melee') and (bool(S.Apocalypse:CooldownRemainsP())) then
            return S.DeathAndDecay:Cast()
        end
        -- defile
        if S.Defile:IsReady('Melee') and Cache.EnemiesCount['Melee'] >= 1 then
            return S.Defile:Cast()
        end
        -- epidemic,if=death_and_decay.ticking&rune<2&!variable.pooling_for_gargoyle
        if S.Epidemic:IsAvailable(30) and S.Epidemic:IsReady() and Player:BuffP(S.DeathAndDecayBuff) and Player:Rune() < 2 and not bool(VarPoolingForGargoyle) then
            return S.Epidemic:Cast()
        end
        -- death_coil,if=death_and_decay.ticking&rune<2&!variable.pooling_for_gargoyle
        if S.DeathCoil:IsReady(30) and Player:BuffP(S.DeathAndDecayBuff) and Player:Rune() < 2 and not bool(VarPoolingForGargoyle) then
            return S.DeathCoil:Cast()
        end
        -- scourge_strike,if=death_and_decay.ticking&cooldown.apocalypse.remains
        if S.ScourgeStrike:IsReady('Melee') and (Player:BuffP(S.DeathAndDecayBuff) and bool(S.Apocalypse:CooldownRemainsP())) then
            return S.ScourgeStrike:Cast()
        end
        -- clawing_shadows,if=death_and_decay.ticking&cooldown.apocalypse.remains
        if S.ClawingShadows:IsReadyMorph(30) and (Player:BuffP(S.DeathAndDecayBuff) and bool(S.Apocalypse:CooldownRemainsP())) then
            return S.ClawingShadows:Cast()
        end
        -- epidemic,if=!variable.pooling_for_gargoyle
        if S.Epidemic:IsAvailable(30) and S.Epidemic:IsReady() and not bool(VarPoolingForGargoyle) then
            return S.Epidemic:Cast()
        end
        -- festering_strike,target_if=debuff.festering_wound.stack<=1&cooldown.death_and_decay.remains
        if S.FesteringStrike:IsReady('Melee') and Target:DebuffStackP(S.FesteringWoundDebuff) <= 1 and bool(S.DeathAndDecay:CooldownRemainsP()) then
            return S.FesteringStrike:Cast()
        end
         -- festering_strike,if=talent.bursting_sores.enabled&spell_targets.bursting_sores>=2&debuff.festering_wound.stack<=1
         if S.FesteringStrike:IsReady('Melee') and (S.BurstingSores:IsAvailable() and Cache.EnemiesCount[5] >= 2 and Target:DebuffStackP(S.FesteringWoundDebuff) <= 1) then
            return S.FesteringStrike:Cast()
        end
        -- death_coil,if=buff.sudden_doom.react&rune.deficit>=4
        if S.DeathCoil:IsReady(30) and (bool(Player:BuffStackP(S.SuddenDoomBuff)) and Player:Rune() <= 2) then
            return S.DeathCoil:Cast()
        end
        -- death_coil,if=buff.sudden_doom.react&!variable.pooling_for_gargoyle|pet.gargoyle.active
        if S.DeathCoil:IsReady(30) and (bool(Player:BuffStackP(S.SuddenDoomBuff)) and not bool(VarPoolingForGargoyle) or Player:GargoyleActive()) then
            return S.DeathCoil:Cast()
        end
        -- death_coil,if=runic_power.deficit<14&(cooldown.apocalypse.remains>5|debuff.festering_wound.stack>4)&!variable.pooling_for_gargoyle
        if S.DeathCoil:IsReady(30) and (Player:RunicPowerDeficit() < 14 and (S.Apocalypse:CooldownRemainsP() > 5 or Target:DebuffStackP(S.FesteringWoundDebuff) > 4) and not bool(VarPoolingForGargoyle)) then
            return S.DeathCoil:Cast()
        end
        -- scourge_strike,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
        if S.ScourgeStrike:IsReady('Melee') and (((Target:DebuffP(S.FesteringWoundDebuff) and S.Apocalypse:CooldownRemainsP() > 5) or Target:DebuffStackP(S.FesteringWoundDebuff) > 4) and (S.ArmyoftheDead:CooldownRemainsP() > 5 or not Player:HasHeroism()))  then
            return S.ScourgeStrike:Cast()
        end
        -- clawing_shadows,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
        if S.ClawingShadows:IsReadyMorph(30) and (((Target:DebuffP(S.FesteringWoundDebuff) and S.Apocalypse:CooldownRemainsP() > 5) or Target:DebuffStackP(S.FesteringWoundDebuff) > 4) and (S.ArmyoftheDead:CooldownRemainsP() > 5 or not Player:HasHeroism())) then
            return S.ClawingShadows:Cast()
        end
        -- death_coil,if=runic_power.deficit<20&!variable.pooling_for_gargoyle
        if S.DeathCoil:IsReady(30) and Player:RunicPowerDeficit() < 20 and not bool(VarPoolingForGargoyle) then
            return S.DeathCoil:Cast()
        end
        -- festering_strike,if=((((debuff.festering_wound.stack<4&!buff.unholy_frenzy.up)|debuff.festering_wound.stack<3)&cooldown.apocalypse.remains<3)|debuff.festering_wound.stack<1)&cooldown.army_of_the_dead.remains>5
        if S.FesteringStrike:IsReady('Melee') and (((((Target:DebuffStackP(S.FesteringWoundDebuff) < 4 and not Player:BuffP(S.UnholyFrenzyBuff)) or Target:DebuffStackP(S.FesteringWoundDebuff) < 3) and S.Apocalypse:CooldownRemainsP() < 3) or Target:DebuffStackP(S.FesteringWoundDebuff) < 1) and (S.ArmyoftheDead:CooldownRemainsP() > 5 or not Player:HasHeroism())) then
            return S.FesteringStrike:Cast()
        end
        -- death_coil,if=!variable.pooling_for_gargoyle
        if S.DeathCoil:IsReady(30) and not bool(VarPoolingForGargoyle) then
            return S.DeathCoil:Cast()
        end
        return 0, "Interface\\Addons\\Rubim-RH\\Media\\pool.tga"
    end
	
    Cooldowns = function()
        -- army_of_the_dead
        if S.ArmyoftheDead:IsCastableP(30) and Player:HasHeroism() then
            return S.ArmyoftheDead:Cast()
        end
        -- apocalypse,if=debuff.festering_wound.stack>=4
        if S.Apocalypse:IsReady('Melee') and (Target:DebuffStackP(S.FesteringWoundDebuff) >= 4) then
            return S.Apocalypse:Cast()
        end
        -- dark_transformation,if=!raid_event.adds.exists|raid_event.adds.in>15
        if S.DarkTransformation:IsReady() and (not (Cache.EnemiesCount[30] > 1) or 10000000000 > 15) then
            return S.DarkTransformation:Cast()
        end
        -- summon_gargoyle,if=runic_power.deficit<14
        if S.SummonGargoyle:IsReady(30) and (Player:RunicPowerDeficit() < 14) then
            return S.SummonGargoyle:Cast()
        end
        -- unholy_frenzy,if=debuff.festering_wound.stack<4&!(equipped.ramping_amplitude_gigavolt_engine|azerite.magus_of_the_dead.enabled)
        if S.UnholyFrenzy:IsReady('Melee') and (Target:DebuffStackP(S.FesteringWoundDebuff) < 4 and not (I.RampingAmplitudeGigavoltEngine:IsEquipped() or S.MagusoftheDead:AzeriteEnabled())) then
            return S.UnholyFrenzy:Cast()
        end
        -- unholy_frenzy,if=cooldown.apocalypse.remains<2&(equipped.ramping_amplitude_gigavolt_engine|azerite.magus_of_the_dead.enabled)
        if S.UnholyFrenzy:IsReady('Melee') and (S.Apocalypse:CooldownRemainsP() < 2 and (I.RampingAmplitudeGigavoltEngine:IsEquipped() or S.MagusoftheDead:AzeriteEnabled())) then
            return S.UnholyFrenzy:Cast()
        end
        -- unholy_frenzy,if=active_enemies>=2&((cooldown.death_and_decay.remains<=gcd&!talent.defile.enabled)|(cooldown.defile.remains<=gcd&talent.defile.enabled))
        if S.UnholyFrenzy:IsReady('Melee') and (Cache.EnemiesCount[30] >= 2 and ((S.DeathAndDecay:CooldownRemainsP() <= Player:GCD() and not S.Defile:IsAvailable()) or (S.Defile:CooldownRemainsP() <= Player:GCD() and S.Defile:IsAvailable()))) then
            return S.UnholyFrenzy:Cast()
        end
        -- soul_reaper,target_if=target.time_to_die<8&target.time_to_die>4
        if S.SoulReaper:IsReady('Melee') and Target:TimeToDie() < 8 and Target:TimeToDie() > 4 then
            return S.SoulReaper:Cast()
        end
        -- soul_reaper,if=(!raid_event.adds.exists|raid_event.adds.in>20)&rune<=(1-buff.unholy_frenzy.up)
        if S.SoulReaper:IsReady('Melee') and ((not (Cache.EnemiesCount[30] > 1) or 10000000000 > 20) and Player:Rune() <= (1 - num(Player:BuffP(S.UnholyFrenzyBuff)))) then
            return S.SoulReaper:Cast()
        end
        -- unholy_blight
        if S.UnholyBlight:IsReady('Melee') and (true) then
            return S.UnholyBlight:Cast()
        end
    end
    Essences = function()
        -- memory_of_lucid_dreams,if=rune.time_to_1>gcd&runic_power<40
        if S.MemoryOfLucidDreams:IsReady('Melee') and (Player:RuneTimeToX(1) > Player:GCD() and Player:RunicPower() < 40) then
            return S.UnleashHeartOfAzeroth:Cast()
        end
        -- blood_of_the_enemy,if=(cooldown.death_and_decay.remains&spell_targets.death_and_decay>1)|(cooldown.defile.remains&spell_targets.defile>1)|(cooldown.apocalypse.remains&cooldown.death_and_decay.ready)
        if S.BloodOfTheEnemy:IsReady('Melee') and ((bool(S.DeathAndDecay:CooldownRemainsP()) and Cache.EnemiesCount[8] > 1) or (bool(S.Defile:CooldownRemainsP()) and Cache.EnemiesCount[8] > 1) or (bool(S.Apocalypse:CooldownRemainsP()) and S.DeathAndDecay:IsReady())) then
            return S.UnleashHeartOfAzeroth:Cast()
        end
        -- guardian_of_azeroth,if=cooldown.apocalypse.ready
        if S.GuardianOfAzeroth:IsReady() and (S.Apocalypse:IsReady()) then
            return S.UnleashHeartOfAzeroth:Cast()
        end
        -- the_unbound_force,if=buff.reckless_force.up|buff.reckless_force_counter.stack<11
        if S.TheUnboundForce:IsCastableP() and (Player:BuffP(S.RecklessForceBuff) or Player:BuffStackP(S.RecklessForceCounterBuff) < 11) then
            return S.UnleashHeartOfAzeroth:Cast()
        end
        -- focused_azerite_beam,if=!death_and_decay.ticking
        if S.FocusedAzeriteBeam:IsReady(30) and (not Player:BuffP(S.DeathAndDecayBuff)) then
            return S.UnleashHeartOfAzeroth:Cast()
        end
        -- concentrated_flame,if=dot.concentrated_flame_burn.remains=0
        if S.ConcentratedFlame:IsReady('Melee') then
            return S.UnleashHeartOfAzeroth:Cast()
        end
        -- purifying_blast,if=!death_and_decay.ticking
        if S.PurifyingBlast:IsReady() and (not Player:BuffP(S.DeathAndDecayBuff)) then
            return S.UnleashHeartOfAzeroth:Cast()
        end
        -- worldvein_resonance,if=!death_and_decay.ticking
        if S.WorldveinResonance:IsReady() and (not Player:BuffP(S.DeathAndDecayBuff)) then
            return S.UnleashHeartOfAzeroth:Cast()
        end
        -- ripple_in_space,if=!death_and_decay.ticking
        if S.RippleInSpace:IsReady() and (not Player:BuffP(S.DeathAndDecayBuff)) then
            return S.UnleashHeartOfAzeroth:Cast()
        end

    end
    
    Generic = function()
        -- death_coil,if=buff.sudden_doom.react&!variable.pooling_for_gargoyle|pet.gargoyle.active
        if S.DeathCoil:IsReady(30) and (Player:BuffP(S.SuddenDoomBuff) and not bool(VarPoolingForGargoyle) or Player:GargoyleActive()) then
            return S.DeathCoil:Cast()
        end
        -- death_coil,if=runic_power.deficit<14&(cooldown.apocalypse.remains>5|debuff.festering_wound.stack>4)&!variable.pooling_for_gargoyle
        if S.DeathCoil:IsReady(30) and (Player:RunicPowerDeficit() < 14 and (S.Apocalypse:CooldownRemainsP() > 5 or Target:DebuffStackP(S.FesteringWoundDebuff) > 4) and not bool(VarPoolingForGargoyle)) then
            return S.DeathCoil:Cast()
        end
        -- death_and_decay,if=talent.pestilence.enabled&cooldown.apocalypse.remains
        if S.DeathAndDecay:IsReady('Melee') and Cache.EnemiesCount[8] >= 1 and (S.Pestilence:IsAvailable() and S.Apocalypse:CooldownDown()) then
            return S.DeathAndDecay:Cast()
        end
        -- defile,if=cooldown.apocalypse.remains
        if S.Defile:IsReady('Melee') and S.Apocalypse:CooldownDown() and Cache.EnemiesCount[8] >= 1 then
            return S.Defile:Cast()
        end
        -- scourge_strike,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
        if S.ScourgeStrike:IsReady(30) and (((Target:DebuffP(S.FesteringWoundDebuff) and S.Apocalypse:CooldownRemainsP() > 5) or Target:DebuffStackP(S.FesteringWoundDebuff) > 4) and (S.ArmyoftheDead:CooldownRemainsP() > 5 or not Player:HasHeroism())) then
            return S.ScourgeStrike:Cast()
        end
        -- clawing_shadows,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
        if S.ClawingShadows:IsReadyMorph(30) and (((Target:DebuffP(S.FesteringWoundDebuff) and S.Apocalypse:CooldownRemainsP() > 5) or Target:DebuffStackP(S.FesteringWoundDebuff) > 4) and (S.ArmyoftheDead:CooldownRemainsP() > 5 or not Player:HasHeroism())) then
            return S.ClawingShadows:Cast()
        end
        -- death_coil,if=runic_power.deficit<20&!variable.pooling_for_gargoyle
        if S.DeathCoil:IsReady(30) and (Player:RunicPowerDeficit() < 20 and not bool(VarPoolingForGargoyle)) then
            return S.DeathCoil:Cast()
        end
        -- festering_strike,if=((((debuff.festering_wound.stack<4&!buff.unholy_frenzy.up)|debuff.festering_wound.stack<3)&cooldown.apocalypse.remains<3)|debuff.festering_wound.stack<1)&cooldown.army_of_the_dead.remains>5
        if S.FesteringStrike:IsReady('Melee') and (((((Target:DebuffStackP(S.FesteringWoundDebuff) < 4 and not Player:BuffP(S.UnholyFrenzyBuff)) or Target:DebuffStackP(S.FesteringWoundDebuff) < 3) and (S.Apocalypse:CooldownRemainsP() < 3 or not Player:HasHeroism())) or Target:DebuffStackP(S.FesteringWoundDebuff) < 1) and (S.ArmyoftheDead:CooldownRemainsP() > 5 or not Player:HasHeroism())) then
            return S.FesteringStrike:Cast()
        end
        -- death_coil,if=!variable.pooling_for_gargoyle
        if S.DeathCoil:IsReady(30) and (not bool(VarPoolingForGargoyle)) then
            return S.DeathCoil:Cast()
        end
    end
    
    if Player:IsCasting() and Player:CastRemains() >= ((select(4, GetNetStats()) / 1000) * 2) or Player:IsChanneling() then
        return 0, "Interface\\Addons\\Rubim-RH\\Media\\channel.tga"
    end 
    -- call precombat
    if not Player:AffectingCombat() and RubimRH.PrecombatON() then
        if Precombat() ~= nil then
            return Precombat()
        end
        return 0, 462338
    end
   
   
    -- Antimagic Shell
	if S.AntiMagicShell:IsAvailable() and S.AntiMagicShell:CooldownRemainsP() < 0.1 and Player:HealthPercentage() <= RubimRH.db.profile[252].sk5 then
        return S.AntiMagicShell:Cast()
    end
	

    --Mov Speed
    if Player:MovingFor() >= 1 and S.DeathsAdvance:IsReadyMorph() then
        return S.DeathsAdvance:Cast()
    end

    -- custom
    if Player:BuffP(S.DarkSuccor) and S.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= RubimRH.db.profile[252].sk1 then
        return S.DeathStrike:Cast()
    end

    if Player:BuffP(S.DarkSuccor) and S.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= 95 and Player:BuffRemains(S.DarkSuccor) <= 2 then
        return S.DeathStrike:Cast()
    end

    if S.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= RubimRH.db.profile[252].sk3 then
        if S.DeathStrike:IsReady() then
            return S.DeathStrike:Cast()
        else
            S.DeathStrike:Queue()
            return 0, "Interface\\Addons\\Rubim-RH\\Media\\pool.tga"
        end
    end

    if S.DeathPact:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[252].sk4 then
        return S.DeathPact:Cast()
    end

    -- auto_attack
    -- mind_freeze
    if S.MindFreeze:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() and (true) then
        return S.MindFreeze:Cast()
    end

    if S.RaiseDead:IsReady() and not Pet:IsActive() then
        return S.RaiseDead:Cast()
    end
    -- variable,name=pooling_for_gargoyle,value=cooldown.summon_gargoyle.remains<5&talent.summon_gargoyle.enabled
    if (true) then
        VarPoolingForGargoyle = num(S.SummonGargoyle:CooldownRemainsP() < 5 and S.SummonGargoyle:IsAvailable())
    end
    -- arcane_torrent,if=runic_power.deficit>65&(pet.gargoyle.active|!talent.summon_gargoyle.enabled)&rune.deficit>=5
    if S.ArcaneTorrent:IsReady() and (Player:RunicPowerDeficit() > 65 and (Player:GargoyleActive() or not S.SummonGargoyle:IsAvailable()) and Player:Rune() <= 1) then
        return S.ArcaneTorrent:Cast()
    end
    -- blood_fury,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled
    if S.BloodFury:IsReady() and RubimRH.CDsON() and (Player:GargoyleActive() or not S.SummonGargoyle:IsAvailable()) then
        return S.BloodFury:Cast()
    end
    -- berserking,if=buff.unholy_frenzy.up|pet.gargoyle.active|!talent.summon_gargoyle.enabled
    if S.Berserking:IsReady() and RubimRH.CDsON() and (Player:GargoyleActive() or not S.SummonGargoyle:IsAvailable()) then
        return S.Berserking:Cast()
    end
    -- use_items,if=time>20|!equipped.ramping_amplitude_gigavolt_engine|!equipped.vision_of_demise
    -- name=ashvanes_razor_coral,if=debuff.razor_coral_debuff.stack<1
    -- name=ashvanes_razor_coral,if=(cooldown.apocalypse.ready&debuff.festering_wound.stack>=4&debuff.razor_coral_debuff.stack>=1)|buff.unholy_frenzy.up
    -- use_item,name=vision_of_demise,if=(cooldown.apocalypse.ready&debuff.festering_wound.stack>=4&essence.vision_of_perfection.enabled)|buff.unholy_frenzy.up|pet.gargoyle.active
    -- use_item,name=ramping_amplitude_gigavolt_engine,if=cooldown.apocalypse.remains<2|talent.army_of_the_damned.enabled|raid_event.adds.in<5
    -- use_item,name=bygone_bee_almanac,if=cooldown.summon_gargoyle.remains>60|!talent.summon_gargoyle.enabled&time>20|!equipped.ramping_amplitude_gigavolt_engine
    -- use_item,name=jes_howler,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled&time>20|!equipped.ramping_amplitude_gigavolt_engine
    -- use_item,name=galecallers_beak,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled&time>20|!equipped.ramping_amplitude_gigavolt_engine
    -- use_item,name=grongs_primal_rage,if=rune<=3&(time>20|!equipped.ramping_amplitude_gigavolt_engine)
    -- potion,if=cooldown.army_of_the_dead.ready|pet.gargoyle.active|buff.unholy_frenzy.up
    -- outbreak,target_if=dot.virulent_plague.remains<=gcd
    if S.Outbreak:IsReady(30) and (not Target:Debuff(S.VirulentPlagueDebuff) or Target:DebuffRemainsP(S.VirulentPlagueDebuff) < Player:GCD()) then
        return S.Outbreak:Cast()
    end
    -- call_action_list,name=essences
    if (true) then
        if Essences() ~= nil and RubimRH.CDsON() then
            return Essences()
        end
    end
    -- call_action_list,name=cooldowns
    if (true) then
        if Cooldowns() ~= nil then
            return Cooldowns()
        end
    end
    -- run_action_list,name=aoe,if=active_enemies>=2
    if (Cache.EnemiesCount['Melee'] >= 2)then
        return Aoe();
    end
    -- call_action_list,name=generic
    if (true) then
        if Generic() ~= nil then
            return Generic()
        end
    end
   return 0, 135328
end

RubimRH.Rotation.SetAPL(252, APL)

local function PASSIVE()
    if S.IceboundFortitude:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[252].sk2 then
        return S.IceboundFortitude:Cast()
    end

    return RubimRH.Shared()
end
RubimRH.Rotation.SetPASSIVE(252, PASSIVE)
