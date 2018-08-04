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
        if active == true and textureId == 458967 then
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

local EnemyRanges = { "Melee", 5, 8, 30 }
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

local function aoe()
    --# AoE rotation
    --actions.aoe=death_and_decay,if=cooldown.apocalypse.remains
    if S.DeathandDecay:IsReady() and Cache.EnemiesCount[10] >= 1 and RubimRH.lastMoved() >= 0.5 and not S.Apocalypse:CooldownUp() then
        return S.DeathandDecay:Cast()
    end

    --actions.aoe+=/defile
    if S.Defile:IsReady() and Cache.EnemiesCount[10] >= 1 and RubimRH.lastMoved() >= 0.5 then
        return S.Defile:Cast()
    end

    --actions.aoe+=/epidemic,if=death_and_decay.ticking&rune<2&!variable.pooling_for_gargoyle
    if S.Epidemic:IsReady() and Player:Buff(S.DeathandDecayBuff) and Player:Runes() < 2 and not poolingforgargoyle then
        return S.Epidemic:Cast()
    end

    -- death_coil,if=death_and_decay.ticking&rune<2&!variable.pooling_for_gargoyle
    if S.DeathCoil:IsReady() and Player:Buff(S.DeathandDecayBuff) and Player:Runes() < 2 and not poolingforgargoyle then
        return S.DeathCoil:Cast()
    end

    --actions.aoe+=/scourge_strike,if=death_and_decay.ticking&cooldown.apocalypse.remains
    if S.ScourgeStrike:IsReady() and Player:Buff(S.DeathandDecayBuff) and not S.Apocalypse:CooldownUp() then
        return S.ScourgeStrike:Cast()
    end

    --actions.aoe+=/clawing_shadows,if=death_and_decay.ticking&cooldown.apocalypse.remains
    if S.ClawingShadows:IsReady() and Player:Buff(S.DeathandDecayBuff) and not S.Apocalypse:CooldownUp() then
        return S.ClawingShadows:Cast()
    end

    --actions.aoe+=/epidemic,if=!variable.pooling_for_gargoyle
    if S.Epidemic:IsReady() and not poolingforgargoyle then
        return S.Epidemic:Cast()
    end

    --actions.aoe+=/festering_strike,if=talent.bursting_sores.enabled&spell_targets.bursting_sores>=2&debuff.festering_wound.stack<=1
    if S.FesteringStrike:IsReady() and S.BurstingSores:IsAvailable() and Cache.EnemiesCount[8] >= 2 and Target:DebuffStack(S.FesteringWounds) <= 1 then
        return S.FesteringStrike:Cast()
    end

    --actions.aoe+=/death_coil,if=buff.sudden_doom.react&rune.deficit>=4
    if S.DeathCoil:IsReady() and Player:Buff(S.SuddenDoom) and Player:RunicPowerDeficit() >= 4 then
        return S.DeathCoil:Cast()
    end

    -- death_coil,if=buff.sudden_doom.react&!variable.pooling_for_gargoyle|pet.gargoyle.active
    if S.DeathCoil:IsReady() and Player:BuffStackP(S.SuddenDoom) and not poolingforgargoyle or Player:GargoyleActive() then
        return S.DeathCoil:Cast()
    end
    -- death_coil,if=runic_power.deficit<14&(cooldown.apocalypse.remains>5|debuff.festering_wound.stack>4)&!variable.pooling_for_gargoyle
    if S.DeathCoil:IsReady() and (Player:RunicPowerDeficit() < 14 and (S.Apocalypse:CooldownRemainsP() > 5 or Target:DebuffStackP(S.FesteringWounds) > 4) and not poolingforgargoyle) then
        return S.DeathCoil:Cast()
    end
    -- scourge_strike,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
    if S.ScourgeStrike:IsReady() and (((Target:DebuffP(S.FesteringWounds) and S.Apocalypse:CooldownRemainsP() > 5) or Target:DebuffStackP(S.FesteringWounds) > 4) and S.ArmyoftheDead:CooldownRemainsP() > 5) then
        return S.ScourgeStrike:Cast()
    end
    -- clawing_shadows,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
    if S.ClawingShadows:IsReady() and (((Target:DebuffP(S.FesteringWounds) and S.Apocalypse:CooldownRemainsP() > 5) or Target:DebuffStackP(S.FesteringWounds) > 4) and S.ArmyoftheDead:CooldownRemainsP() > 5) then
        return S.ClawingShadows:Cast()
    end
    -- death_coil,if=runic_power.deficit<20&!variable.pooling_for_gargoyle
    if S.DeathCoil:IsReady() and (Player:RunicPowerDeficit() < 20 and not poolingforgargoyle) then
        return S.DeathCoil:Cast()
    end
    -- festering_strike,if=((((debuff.festering_wound.stack<4&!buff.unholy_frenzy.up)|debuff.festering_wound.stack<3)&cooldown.apocalypse.remains<3)|debuff.festering_wound.stack<1)&cooldown.army_of_the_dead.remains>5
    if S.FesteringStrike:IsReady() and (((((Target:DebuffStackP(S.FesteringWounds) < 4 and not Player:BuffP(S.UnholyFrenzy)) or Target:DebuffStackP(S.FesteringWounds) < 3) and S.Apocalypse:CooldownRemainsP() < 3) or Target:DebuffStackP(S.FesteringWounds) < 1) and S.ArmyoftheDead:CooldownRemainsP() > 5) then
        return S.FesteringStrike:Cast()
    end
    -- death_coil,if=!variable.pooling_for_gargoyle
    if S.DeathCoil:IsReady() and poolingforgargoyle then
        return S.DeathCoil:Cast()
    end
    return 0, 135328
end

local function cold_heart()
    --# Cold Heart legendary
    --actions.cold_heart=chains_of_ice,if=buff.unholy_strength.remains<gcd&buff.unholy_strength.react&buff.cold_heart.stack>16
    if S.ChainsOfIce:IsCastable() and Player:BuffRemainsP(S.UnholyStrength) < Player:GCD() and Player:Buff(S.UnholyStrength) and Player:BuffStack(S.ColdHeartItemBuff) > 16 then
        return S.ChainsOfIce:Cast()
    end
    --actions.cold_heart+=/chains_of_ice,if=buff.master_of_ghouls.remains<gcd&buff.master_of_ghouls.up&buff.cold_heart.stack>17
    --if S.ChainsOfIce:IsCastable() and Player:BuffRemainsP(S.MasterOfGhouls) < Player:GCD() and Player:Buff(S.MasterOfGhouls) and Player:BuffStack(S.ColdHeartItemBuff) > 17 then
    --  return S.ChainsOfIce:Cast()
    --end
    --actions.cold_heart+=/chains_of_ice,if=buff.cold_heart.stack=20&buff.unholy_strength.react
    if S.ChainsOfIce:IsCastable() and Player:BuffStack(S.ColdHeartItemBuff) == 20 and Player:Buff(S.UnholyStrength) then
        return S.ChainsOfIce:Cast()
    end
end

local function cooldowns()
    -- call_action_list,name=cold_heart,if=equipped.cold_heart&buff.cold_heart_item.stack>10
    if (I.ColdHeart:IsEquipped() and Player:BuffStackP(S.ColdHeartItemBuff) > 10) then
        if cold_heart() ~= nil then
            return cold_heart()
        end
    end
    -- army_of_the_dead
    --if S.ArmyoftheDead:IsReady() then
    --return S.ArmyoftheDead:Cast()
    --end
    -- apocalypse,if=debuff.festering_wound.stack>=4
    if RubimRH.CDsON() and S.Apocalypse:IsReady() and (Target:DebuffStackP(S.FesteringWounds) >= 4) then
        return S.Apocalypse:Cast()
    end
    -- dark_transformation,if=(equipped.137075&cooldown.summon_gargoyle.remains>40)|(!equipped.137075|!talent.summon_gargoyle.enabled)
    if RubimRH.CDsON() and S.DarkTransformation:IsReady() and ((I.Taktheritrixs:IsEquipped() and S.SummonGargoyle:CooldownRemainsP() > 40) or (not I.Taktheritrixs:IsEquipped() or not S.SummonGargoyle:IsAvailable())) then
        return S.DarkTransformation:Cast()
    end
    -- summon_gargoyle,if=runic_power.deficit<14
    if RubimRH.CDsON() and S.SummonGargoyle:IsReady() and (Player:RunicPowerDeficit() < 14) then
        return S.SummonGargoyle:Cast()
    end
    -- unholy_frenzy,if=debuff.festering_wound.stack<4
    if RubimRH.CDsON() and S.UnholyFrenzy:IsReady() and (Target:DebuffStackP(S.FesteringWounds) < 4) then
        return S.UnholyFrenzy:Cast()
    end
    -- unholy_frenzy,if=active_enemies>=2&((cooldown.death_and_decay.remains<=gcd&!talent.defile.enabled)|(cooldown.defile.remains<=gcd&talent.defile.enabled))
    if RubimRH.CDsON() and S.UnholyFrenzy:IsReady() and (Cache.EnemiesCount[30] >= 2 and ((S.DeathandDecay:CooldownRemainsP() <= Player:GCD() and not S.Defile:IsAvailable()) or (S.Defile:CooldownRemainsP() <= Player:GCD() and S.Defile:IsAvailable()))) then
        return S.UnholyFrenzy:Cast()
    end
    -- soul_reaper,target_if=(target.time_to_die<8|rune<=2)&!buff.unholy_frenzy.up
    if RubimRH.CDsON() and S.SoulReaper:IsReady() then
        return S.SoulReaper:Cast()
    end
    -- unholy_blight
    if RubimRH.CDsON() and S.UnholyBlight:IsReady() then
        return S.UnholyBlight:Cast()
    end

    --actions.cooldowns=call_action_list,name=cold_heart,if=equipped.cold_heart&buff.cold_heart_item.stack>10
    if I.ColdHeart:IsEquipped() and Player:BuffStack(S.ColdHeartItemBuff) > 10 then
        if cold_heart() ~= nil then
            return cold_heart()
        end
    end

    --actions.cooldowns+=/army_of_the_dead

    --actions.cooldowns+=/apocalypse,if=debuff.festering_wound.stack>=4
    if RubimRH.CDsON() and S.Apocalypse:IsReady() and Target:DebuffStack(S.FesteringWounds) >= 4 then
        return S.Apocalypse:Cast()
    end
    --actions.cooldowns+=/dark_transformation,if=(equipped.137075&cooldown.summon_gargoyle.remains>40)|(!equipped.137075|!talent.summon_gargoyle.enabled)
    if RubimRH.CDsON() and S.DarkTransformation:IsReady() and ((I.Taktheritrixs:IsEquipped() and (S.SummonGargoyle:CooldownRemains() > 40 or RubimRH.CDsON())) or (not I.Taktheritrixs:IsEquipped() or not S.SummonGargoyle:IsAvailable())) then
        return S.DarkTransformation:Cast()
    end

    --actions.cooldowns+=/summon_gargoyle,if=runic_power.deficit<14
    if RubimRH.CDsON() and S.SummonGargoyle:IsReady() and Player:RunicPowerDeficit() < 14 then
        return S.SummonGargoyle:Cast()
    end

    --actions.cooldowns+=/unholy_frenzy,if=debuff.festering_wound.stack<4
    if S.UnholyFrenzy:IsReady() and Target:DebuffStack(S.FesteringWounds) < 4 then
        return S.UnholyFrenzy:Cast()
    end

    --actions.cooldowns+=/unholy_frenzy,if=active_enemies>=2&((cooldown.death_and_decay.remains<=gcd&!talent.defile.enabled)|(cooldown.defile.remains<=gcd&talent.defile.enabled))
    if S.UnholyFrenzy:IsReady() and Cache.EnemiesCount[8] >= 2 and ((S.DeathandDecay:CooldownRemains() < Player:GCD() and not S.Defile:IsAvailable()) or (S.Defile.CooldownRemains() <= Player:GCD() and S.Defile:IsAvailable())) then
        return S.UnholyFrenzy:Cast()
    end

    --actions.cooldowns+=/soul_reaper,target_if=(target.time_to_die<8|rune<=2)&!buff.unholy_frenzy.up
    if S.SoulReaper:IsReady() and ((Target:TimeToDie() < 8 or Player:Runes() <= 2) and not Player:Buff(S.UnholyFrenzy)) then
        return S.SoulReaper:Cast()
    end

    --actions.cooldowns+=/unholy_blight
    if S.UnholyBlight:IsReady() and Cache.EnemiesCount[10] >= 1 then
        return S.UnholyBlight:Cast()
    end
end

local function generic()
    -- death_coil,if=buff.sudden_doom.react&!variable.pooling_for_gargoyle|pet.gargoyle.active
    if S.DeathCoil:IsReady() and (bool(Player:BuffStackP(S.SuddenDoom)) and not poolingforgargoyle or Player:GargoyleActive()) then
        return S.DeathCoil:Cast()
    end
    -- death_coil,if=runic_power.deficit<14&(cooldown.apocalypse.remains>5|debuff.festering_wound.stack>4)&!variable.pooling_for_gargoyle
    if S.DeathCoil:IsReady() and (Player:RunicPowerDeficit() < 14 and (S.Apocalypse:CooldownRemainsP() > 5 or Target:DebuffStackP(S.FesteringWounds) > 4) and not poolingforgargoyle) then
        return S.DeathCoil:Cast()
    end
    -- death_and_decay,if=talent.pestilence.enabled&cooldown.apocalypse.remains
    if S.DeathandDecay:IsReady() and (S.Pestilence:IsAvailable() and bool(S.Apocalypse:CooldownRemainsP())) then
        return S.DeathandDecay:Cast()
    end
    -- defile,if=cooldown.apocalypse.remains
    if S.Defile:IsReady() and (bool(S.Apocalypse:CooldownRemainsP())) then
        return S.Defile:Cast()
    end
    -- scourge_strike,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
    if S.ScourgeStrike:IsReady() and (((Target:DebuffP(S.FesteringWounds) and S.Apocalypse:CooldownRemainsP() > 5) or Target:DebuffStackP(S.FesteringWounds) > 4) and S.ArmyoftheDead:CooldownRemainsP() > 5) then
        return S.ScourgeStrike:Cast()
    end
    -- clawing_shadows,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
    if S.ClawingShadows:IsReady() and (((Target:DebuffP(S.FesteringWounds) and S.Apocalypse:CooldownRemainsP() > 5) or Target:DebuffStackP(S.FesteringWounds) > 4) and S.ArmyoftheDead:CooldownRemainsP() > 5) then
        return S.ClawingShadows:Cast()
    end
    -- death_coil,if=runic_power.deficit<20&!variable.pooling_for_gargoyle
    if S.DeathCoil:IsReady() and (Player:RunicPowerDeficit() < 20 and not poolingforgargoyle) then
        return S.DeathCoil:Cast()
    end
    -- festering_strike,if=((((debuff.festering_wound.stack<4&!buff.unholy_frenzy.up)|debuff.festering_wound.stack<3)&cooldown.apocalypse.remains<3)|debuff.festering_wound.stack<1)&cooldown.army_of_the_dead.remains>5
    if S.FesteringStrike:IsReady() and (((((Target:DebuffStackP(S.FesteringWounds) < 4 and not Player:BuffP(S.UnholyFrenzy)) or Target:DebuffStackP(S.FesteringWounds) < 3) and S.Apocalypse:CooldownRemainsP() < 3) or Target:DebuffStackP(S.FesteringWounds) < 1) and S.ArmyoftheDead:CooldownRemainsP() > 5) then
        return S.FesteringStrike:Cast()
    end
    -- death_coil,if=!variable.pooling_for_gargoyle
    if S.DeathCoil:IsReady() and not poolingforgargoyle then
        return S.DeathCoil:Cast()
    end
end

local function APL()
    UpdateRanges()

    if not Player:AffectingCombat() then
        --check if we have our lovely pet with us
        if not Pet:IsActive() and S.SummonPet:IsCastable() then
            return S.SummonPet:Cast()
        end
        return 0, 462338
    end

    --CUSTOM
    if RubimRH.config.Spells[1].isActive and Player:Buff(S.DarkSuccor) and S.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= RubimRH.db.profile[251].deathstrike then
        S.DeathStrike:Queue()
        return S.DeathStrike:Cast()
    end

    if RubimRH.config.Spells[1].isActive and Player:Buff(S.DarkSuccor) and S.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= 95 and Player:BuffRemains(S.DarkSuccor) <= 2 then
        S.DeathStrike:Queue()
        return S.DeathStrike:Cast()
    end
    --END OF CUSTOM

    -- variable,name=pooling_for_gargoyle,value=(cooldown.summon_gargoyle.remains<5&(cooldown.dark_transformation.remains<5|!equipped.137075))&talent.summon_gargoyle.enabled
    poolingforgargoyle = (S.SummonGargoyle:CooldownRemains() < 5 and (S.DarkTransformation:CooldownRemains() < 5 or not I.Taktheritrixs:IsEquipped()) and S.SummonGargoyle:IsAvailable()) and RubimRH.CDsON()
    -- arcane_torrent,if=runic_power.deficit>65&(pet.gargoyle.active|!talent.summon_gargoyle.enabled)&rune.deficit>=5
    if RubimRH.CDsON() and RubimRH.RacialON() and S.ArcaneTorrent:IsReady() and (Player:RunicPowerDeficit() > 65 and (Player:GargoyleActive() or not S.SummonGargoyle:IsAvailable()) and Player:RuneDeficit() >= 5) then
        return S.ArcaneTorrent:Cast()
    end
    -- blood_fury,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled
    if RubimRH.CDsON() and RubimRH.RacialON() and S.BloodFury:IsReady() and (Player:GargoyleActive() or not S.SummonGargoyle:IsAvailable()) then
        return S.BloodFury:Cast()
    end
    -- berserking,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled
    if RubimRH.CDsON() and RubimRH.RacialON() and S.Berserking:IsReady() and (Player:GargoyleActive() or not S.SummonGargoyle:IsAvailable()) then
        return S.Berserking:Cast()
    end
    -- use_items
    -- use_item,name=feloiled_infernal_machine,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled
    --    if I.FeloiledInfernalMachine:IsReady() and (Player:GargoyleActive() or not S.SummonGargoyle:IsAvailable()) then
    --        todo
    --    end
    -- use_item,name=ring_of_collapsing_futures,if=(buff.temptation.stack=0&target.time_to_die>60)|target.time_to_die<60
    --    if I.RingofCollapsingFutures:IsReady() and ((Player:BuffStackP(S.TemptationBuff) == 0 and Target:TimeToDie() > 60) or Target:TimeToDie() < 60) then
    --        todo
    --  end
    -- potion,if=cooldown.army_of_the_dead.ready|pet.gargoyle.active|buff.unholy_frenzy.up
    --    if I.ProlongedPower:IsReady() and Settings.Commons.UsePotions and (S.ArmyoftheDead:CooldownUpP() or Player:GargoyleActive() or Player:BuffP(S.UnholyFrenzyBuff)) then
    --        todo
    --end
    -- outbreak,target_if=(dot.virulent_plague.tick_time_remains+tick_time<=dot.virulent_plague.remains)&dot.virulent_plague.remains<=gcd
    if S.Outbreak:IsReady() and (not Target:Debuff(S.VirulentPlagueDebuff) or Target:DebuffRemainsP(S.VirulentPlagueDebuff) < Player:GCD()) then
        return S.Outbreak:Cast()
    end
    -- call_action_list,name=cooldowns
    if cooldowns() ~= nil then
        return cooldowns()
    end
    -- run_action_list,name=aoe,if=active_enemies>=2
    if (Cache.EnemiesCount[30] >= 2) then
        return aoe();
    end
    -- call_action_list,name=generic
    if generic() ~= nil then
        return generic()
    end

    return 0, 135328

end
RubimRH.Rotation.SetAPL(252, APL);

local function PASSIVE()
    if S.IceboundFortitude:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[252].icebound then
        return S.IceboundFortitude:Cast()
    end
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(252, PASSIVE);