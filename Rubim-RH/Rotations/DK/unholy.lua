--- ============================ HEADER ============================
-- Addon
local addonName, addonTable = ...;
-- HeroLib
local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Pet = Unit.Pet;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;
-- Lua

--- ============================ CONTENT ============================
RubimRH.Spell[252] = {
    RaiseDead = Spell(46584),
    ArmyoftheDead = Spell(42650),
    DeathandDecay = Spell(43265),
    Apocalypse = Spell(275699),
    Defile = Spell(152280),
    Epidemic = Spell(207317),
    DeathCoil = Spell(47541),
    ScourgeStrike = Spell(55090),
    DeathandDecayBuff = Spell(188290),
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

};
local S = RubimRH.Spell[252]
S.ClawingShadows.TextureSpellID = { 241367 }

if not Item.DeathKnight then
    Item.DeathKnight = {}
end
Item.DeathKnight.Unholy = {
    ProlongedPower = Item(142117),
    ColdHeart = Item(151796),
    Taktheritrixs = Item(137075),
    FeloiledInfernalMachine = Item(144482),
    RingofCollapsingFutures = Item(142173)
};
local I = Item.DeathKnight.Unholy;

local T202PC, T204PC = HL.HasTier("T20");
local T212PC, T214PC = HL.HasTier("T21");

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

local EnemyRanges = {"Melee", 5, 8, 30}
local function UpdateRanges()
    for _, i in ipairs(EnemyRanges) do
        HL.GetEnemies(i);
    end
end

local function num(val)
    if val then return 1 else return 0 end
end

local function bool(val)
    return val ~= 0
end

local OffensiveCDs = {
    S.SummonGargoyle,
    S.UnholyFrenzy,
    S.Apocalypse,
    S.DarkTransformation,
    S.ArmyoftheDead,

}

local function UpdateCDs()
    if RubimRH.config.cooldown then
        for i, spell in pairs(OffensiveCDs) do
            if not spell:IsEnabledCD() then
                RubimRH.delSpellDisabledCD(spell:ID())
            end
        end

    end
    if not RubimRH.config.cooldown then
        for i, spell in pairs(OffensiveCDs) do
            if spell:IsEnabledCD() then
                RubimRH.addSpellDisabledCD(spell:ID())
            end
        end
    end
end

local function APL()
    local Precombat, Aoe, ColdHeart, Cooldowns, Generic
    UpdateRanges()
    UpdateCDs()
    Precombat = function()
        -- flask
        -- food
        -- augmentation
        -- snapshot_stats
        -- potion
        if I.ProlongedPower:IsReady() and RubimRH.PotionON() and (true) then
            return I.ProlongedPower:Cast()
        end
        -- raise_dead
        if S.RaiseDead:IsReady() and not Pet:IsActive() then
            return S.RaiseDead:Cast()
        end
        -- army_of_the_dead
        if S.ArmyoftheDead:IsReady() and (true) then
            return S.ArmyoftheDead:Cast()
        end
    end
    Aoe = function()
        -- death_and_decay,if=cooldown.apocalypse.remains
        if S.DeathandDecay:IsReady() and (bool(S.Apocalypse:CooldownRemains())) then
            return S.DeathandDecay:Cast()
        end
        -- defile
        if S.Defile:IsReady() and (true) then
            return S.Defile:Cast()
        end
        -- epidemic,if=death_and_decay.ticking&rune<2&!variable.pooling_for_gargoyle
        if S.Epidemic:IsReady() and (bool(Player:Buff(S.DeathandDecayBuff)) and Player:Runes() < 2 and not bool(VarPoolingForGargoyle)) then
            return S.Epidemic:Cast()
        end
        -- death_coil,if=death_and_decay.ticking&rune<2&!variable.pooling_for_gargoyle
        if S.DeathCoil:IsReady() and (bool(Player:Buff(S.DeathandDecayBuff)) and Player:Runes() < 2 and not bool(VarPoolingForGargoyle)) then
            return S.DeathCoil:Cast()
        end
        -- scourge_strike,if=death_and_decay.ticking&cooldown.apocalypse.remains
        if S.ScourgeStrike:IsReady() and (bool(Player:Buff(S.DeathandDecayBuff)) and bool(S.Apocalypse:CooldownRemains())) then
            return S.ScourgeStrike:Cast()
        end
        -- clawing_shadows,if=death_and_decay.ticking&cooldown.apocalypse.remains
        if S.ClawingShadows:IsReady() and (bool(Player:Buff(S.DeathandDecayBuff)) and bool(S.Apocalypse:CooldownRemains())) then
            return S.ClawingShadows:Cast()
        end
        -- epidemic,if=!variable.pooling_for_gargoyle
        if S.Epidemic:IsReady() and (not bool(VarPoolingForGargoyle)) then
            return S.Epidemic:Cast()
        end
        -- festering_strike,if=talent.bursting_sores.enabled&spell_targets.bursting_sores>=2&debuff.festering_wound.stack<=1
        if S.FesteringStrike:IsReady() and (S.BurstingSores:IsAvailable() and Cache.EnemiesCount[5] >= 2 and Target:DebuffStack(S.FesteringWoundDebuff) <= 1) then
            return S.FesteringStrike:Cast()
        end
        -- death_coil,if=buff.sudden_doom.react&rune.deficit>=4
        if S.DeathCoil:IsReady() and (bool(Player:BuffStack(S.SuddenDoomBuff)) and Player:Runes() <= 2) then
            return S.DeathCoil:Cast()
        end
        -- death_coil,if=buff.sudden_doom.react&!variable.pooling_for_gargoyle|pet.gargoyle.active
        if S.DeathCoil:IsReady() and (bool(Player:BuffStack(S.SuddenDoomBuff)) and not bool(VarPoolingForGargoyle) or bool(Player:GargoyleActive())) then
            return S.DeathCoil:Cast()
        end
        -- death_coil,if=runic_power.deficit<14&(cooldown.apocalypse.remains>5|debuff.festering_wound.stack>4)&!variable.pooling_for_gargoyle
        if S.DeathCoil:IsReady() and (Player:RunicPowerDeficit() < 14 and (S.Apocalypse:CooldownRemains() > 5 or Target:DebuffStack(S.FesteringWoundDebuff) > 4) and not bool(VarPoolingForGargoyle)) then
            return S.DeathCoil:Cast()
        end
        -- scourge_strike,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
        if S.ScourgeStrike:IsReady() and (((Target:Debuff(S.FesteringWoundDebuff) and S.Apocalypse:CooldownRemains() > 5) or Target:DebuffStack(S.FesteringWoundDebuff) > 4) and S.ArmyoftheDead:CooldownRemains() > 5) then
            return S.ScourgeStrike:Cast()
        end
        -- clawing_shadows,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
        if S.ClawingShadows:IsReady() and (((Target:Debuff(S.FesteringWoundDebuff) and S.Apocalypse:CooldownRemains() > 5) or Target:DebuffStack(S.FesteringWoundDebuff) > 4) and S.ArmyoftheDead:CooldownRemains() > 5) then
            return S.ClawingShadows:Cast()
        end
        -- death_coil,if=runic_power.deficit<20&!variable.pooling_for_gargoyle
        if S.DeathCoil:IsReady() and (Player:RunicPowerDeficit() < 20 and not bool(VarPoolingForGargoyle)) then
            return S.DeathCoil:Cast()
        end
        -- festering_strike,if=((((debuff.festering_wound.stack<4&!buff.unholy_frenzy.up)|debuff.festering_wound.stack<3)&cooldown.apocalypse.remains<3)|debuff.festering_wound.stack<1)&cooldown.army_of_the_dead.remains>5
        if S.FesteringStrike:IsReady() and (((((Target:DebuffStack(S.FesteringWoundDebuff) < 4 and not Player:Buff(S.UnholyFrenzyBuff)) or Target:DebuffStack(S.FesteringWoundDebuff) < 3) and S.Apocalypse:CooldownRemains() < 3) or Target:DebuffStack(S.FesteringWoundDebuff) < 1) and S.ArmyoftheDead:CooldownRemains() > 5) then
            return S.FesteringStrike:Cast()
        end
        -- death_coil,if=!variable.pooling_for_gargoyle
        if S.DeathCoil:IsReady() and (not bool(VarPoolingForGargoyle)) then
            return S.DeathCoil:Cast()
        end
        return 0, 135328
    end
    ColdHeart = function()
        -- chains_of_ice,if=buff.unholy_strength.remains<gcd&buff.unholy_strength.react&buff.cold_heart_item.stack>16
        if S.ChainsofIce:IsReady() and (Player:BuffRemains(S.UnholyStrengthBuff) < Player:GCD() and bool(Player:Buff(S.UnholyStrengthBuff)) and Player:BuffStack(S.ColdHeartItemBuff) > 16) then
            return S.ChainsofIce:Cast()
        end
        -- chains_of_ice,if=buff.master_of_ghouls.remains<gcd&buff.master_of_ghouls.up&buff.cold_heart_item.stack>17
        if S.ChainsofIce:IsReady() and (Player:BuffRemains(S.MasterofGhoulsBuff) < Player:GCD() and Player:Buff(S.MasterofGhoulsBuff) and Player:BuffStack(S.ColdHeartItemBuff) > 17) then
            return S.ChainsofIce:Cast()
        end
        -- chains_of_ice,if=buff.cold_heart_item.stack=20&buff.unholy_strength.react
        if S.ChainsofIce:IsReady() and (Player:BuffStack(S.ColdHeartItemBuff) == 20 and bool(Player:Buff(S.UnholyStrengthBuff))) then
            return S.ChainsofIce:Cast()
        end
    end
    Cooldowns = function()
        -- call_action_list,name=cold_heart,if=equipped.cold_heart&buff.cold_heart_item.stack>10
        if (I.ColdHeart:IsEquipped() and Player:BuffStack(S.ColdHeartItemBuff) > 10) then
            if ColdHeart() ~= nil then
                return ColdHeart()
            end
        end
        -- army_of_the_dead
        if S.ArmyoftheDead:IsReady() and (true) then
            return S.ArmyoftheDead:Cast()
        end
        -- apocalypse,if=debuff.festering_wound.stack>=4
        if S.Apocalypse:IsReady() and (Target:DebuffStack(S.FesteringWoundDebuff) >= 4) then
            return S.Apocalypse:Cast()
        end
        -- dark_transformation,if=(equipped.137075&cooldown.summon_gargoyle.remains>40)|(!equipped.137075|!talent.summon_gargoyle.enabled)
        if S.DarkTransformation:IsReady() and ((I.Taktheritrixs:IsEquipped() and S.SummonGargoyle:CooldownRemains() > 40) or (not I.Taktheritrixs:IsEquipped() or not S.SummonGargoyle:IsAvailable())) then
            return S.DarkTransformation:Cast()
        end
        -- summon_gargoyle,if=runic_power.deficit<14
        if S.SummonGargoyle:IsReady() and (Player:RunicPowerDeficit() < 14) then
            return S.SummonGargoyle:Cast()
        end
        -- unholy_frenzy,if=debuff.festering_wound.stack<4
        if S.UnholyFrenzy:IsReady() and (Target:DebuffStack(S.FesteringWoundDebuff) < 4) then
            return S.UnholyFrenzy:Cast()
        end
        -- unholy_frenzy,if=active_enemies>=2&((cooldown.death_and_decay.remains<=gcd&!talent.defile.enabled)|(cooldown.defile.remains<=gcd&talent.defile.enabled))
        if S.UnholyFrenzy:IsReady() and (Cache.EnemiesCount[30] >= 2 and ((S.DeathandDecay:CooldownRemains() <= Player:GCD() and not S.Defile:IsAvailable()) or (S.Defile:CooldownRemains() <= Player:GCD() and S.Defile:IsAvailable()))) then
            return S.UnholyFrenzy:Cast()
        end
        -- soul_reaper,target_if=(target.time_to_die<8|rune<=2)&!buff.unholy_frenzy.up
        if S.SoulReaper:IsReady() and (true) then
            return S.SoulReaper:Cast()
        end
        -- unholy_blight
        if S.UnholyBlight:IsReady() and (true) then
            return S.UnholyBlight:Cast()
        end
    end
    Generic = function()
        -- death_coil,if=buff.sudden_doom.react&!variable.pooling_for_gargoyle|pet.gargoyle.active
        if S.DeathCoil:IsReady() and (bool(Player:BuffStack(S.SuddenDoomBuff)) and not bool(VarPoolingForGargoyle) or bool(Player:GargoyleActive())) then
            return S.DeathCoil:Cast()
        end
        -- death_coil,if=runic_power.deficit<14&(cooldown.apocalypse.remains>5|debuff.festering_wound.stack>4)&!variable.pooling_for_gargoyle
        if S.DeathCoil:IsReady() and (Player:RunicPowerDeficit() < 14 and (S.Apocalypse:CooldownRemains() > 5 or Target:DebuffStack(S.FesteringWoundDebuff) > 4) and not bool(VarPoolingForGargoyle)) then
            return S.DeathCoil:Cast()
        end
        -- death_and_decay,if=talent.pestilence.enabled&cooldown.apocalypse.remains
        if S.DeathandDecay:IsReady() and (S.Pestilence:IsAvailable() and bool(S.Apocalypse:CooldownRemains())) then
            return S.DeathandDecay:Cast()
        end
        -- defile,if=cooldown.apocalypse.remains
        if S.Defile:IsReady() and (bool(S.Apocalypse:CooldownRemains())) then
            return S.Defile:Cast()
        end
        -- scourge_strike,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
        if S.ScourgeStrike:IsReady() and (((Target:Debuff(S.FesteringWoundDebuff) and S.Apocalypse:CooldownRemains() > 5) or Target:DebuffStack(S.FesteringWoundDebuff) > 4) and S.ArmyoftheDead:CooldownRemains() > 5) then
            return S.ScourgeStrike:Cast()
        end
        -- clawing_shadows,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
        if S.ClawingShadows:IsReady() and (((Target:Debuff(S.FesteringWoundDebuff) and S.Apocalypse:CooldownRemains() > 5) or Target:DebuffStack(S.FesteringWoundDebuff) > 4) and S.ArmyoftheDead:CooldownRemains() > 5) then
            return S.ClawingShadows:Cast()
        end
        -- death_coil,if=runic_power.deficit<20&!variable.pooling_for_gargoyle
        if S.DeathCoil:IsReady() and (Player:RunicPowerDeficit() < 20 and not bool(VarPoolingForGargoyle)) then
            return S.DeathCoil:Cast()
        end
        -- festering_strike,if=((((debuff.festering_wound.stack<4&!buff.unholy_frenzy.up)|debuff.festering_wound.stack<3)&cooldown.apocalypse.remains<3)|debuff.festering_wound.stack<1)&cooldown.army_of_the_dead.remains>5
        if S.FesteringStrike:IsReady() and (((((Target:DebuffStack(S.FesteringWoundDebuff) < 4 and not Player:Buff(S.UnholyFrenzyBuff)) or Target:DebuffStack(S.FesteringWoundDebuff) < 3) and S.Apocalypse:CooldownRemains() < 3) or Target:DebuffStack(S.FesteringWoundDebuff) < 1) and S.ArmyoftheDead:CooldownRemains() > 5) then
            return S.FesteringStrike:Cast()
        end
        -- death_coil,if=!variable.pooling_for_gargoyle
        if S.DeathCoil:IsReady() and (not bool(VarPoolingForGargoyle)) then
            return S.DeathCoil:Cast()
        end
    end
    -- call precombat
    if not Player:AffectingCombat() then
        if Precombat() ~= nil then
            return Precombat()
        end
        return 0, 462338
    end
    -- custom
    if Player:Buff(S.DarkSuccor) and S.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= RubimRH.db.profile[251].deathstrike then
        return S.DeathStrike:Cast()
    end

    if Player:Buff(S.DarkSuccor) and S.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= 95 and Player:BuffRemains(S.DarkSuccor) <= 2 then
        return S.DeathStrike:Cast()
    end

    if S.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= RubimRH.db.profile[252].deathstrike then
        if S.DeathStrike:IsUsable() then
            return S.DeathStrike:Cast()
        else
            S.DeathStrike:Queue()
            return 0, 135328
        end
    end

    -- auto_attack
    -- mind_freeze
    if S.MindFreeze:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() and (true) then
        return S.MindFreeze:Cast()
    end
    -- variable,name=pooling_for_gargoyle,value=(cooldown.summon_gargoyle.remains<5&(cooldown.dark_transformation.remains<5|!equipped.137075))&talent.summon_gargoyle.enabled
    if (true) then
        VarPoolingForGargoyle = num((S.SummonGargoyle:CooldownRemains() < 5 and (S.DarkTransformation:CooldownRemains() < 5 or not I.Taktheritrixs:IsEquipped())) and S.SummonGargoyle:IsAvailable())
    end
    -- arcane_torrent,if=runic_power.deficit>65&(pet.gargoyle.active|!talent.summon_gargoyle.enabled)&rune.deficit>=5
    if S.ArcaneTorrent:IsReady() and (Player:RunicPowerDeficit() > 65 and (bool(Player:GargoyleActive()) or not S.SummonGargoyle:IsAvailable()) and Player:Runes() <= 1) then
        return S.ArcaneTorrent:Cast()
    end
    -- blood_fury,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled
    if S.BloodFury:IsReady() and (bool(Player:GargoyleActive()) or not S.SummonGargoyle:IsAvailable()) then
        return S.BloodFury:Cast()
    end
    -- berserking,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled
    if S.Berserking:IsReady() and (bool(Player:GargoyleActive()) or not S.SummonGargoyle:IsAvailable()) then
        return S.Berserking:Cast()
    end
    -- use_items
    -- use_item,name=feloiled_infernal_machine,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled
    if I.FeloiledInfernalMachine:IsReady() and (bool(Player:GargoyleActive()) or not S.SummonGargoyle:IsAvailable()) then
        return I.FeloiledInfernalMachine:Cast()
    end
    -- use_item,name=ring_of_collapsing_futures,if=(buff.temptation.stack=0&target.time_to_die>60)|target.time_to_die<60
    if I.RingofCollapsingFutures:IsReady() and ((Player:BuffStack(S.TemptationBuff) == 0 and Target:TimeToDie() > 60) or Target:TimeToDie() < 60) then
        return I.RingofCollapsingFutures:Cast()
    end
    -- potion,if=cooldown.army_of_the_dead.ready|pet.gargoyle.active|buff.unholy_frenzy.up
    if I.ProlongedPower:IsReady() and RubimRH.PotionON() and (S.ArmyoftheDead:CooldownUp() or bool(Player:GargoyleActive()) or Player:Buff(S.UnholyFrenzyBuff)) then
        return I.ProlongedPower:Cast()
    end
    -- outbreak,target_if=(dot.virulent_plague.tick_time_remains+tick_time<=dot.virulent_plague.remains)&dot.virulent_plague.remains<=gcd
    if S.Outbreak:IsReady() and (not Target:Debuff(S.VirulentPlagueDebuff) or Target:DebuffRemainsP(S.VirulentPlagueDebuff) < Player:GCD()) then
        return S.Outbreak:Cast()
    end
    -- call_action_list,name=cooldowns
    if (true) then
        if Cooldowns() ~= nil then
            return Cooldowns()
        end
    end
    -- run_action_list,name=aoe,if=active_enemies>=2
    if (Cache.EnemiesCount[30] >= 2) then
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
    return RubimRH.Shared()
end
RubimRH.Rotation.SetPASSIVE(252, PASSIVE)
