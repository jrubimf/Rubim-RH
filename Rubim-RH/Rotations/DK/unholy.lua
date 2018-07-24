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

--Items
if not Item.DeathKnight then
    Item.DeathKnight = {};
end
Item.DeathKnight.Unholy = {
    --Legendaries WIP
    ConvergenceofFates = Item(140806, { 13, 14 }),
    InstructorsFourthLesson = Item(132448, { 9 }),
    Taktheritrixs = Item(137075, { 3 }),
    ColdHeart = Item(151796, { 5 }),
};
local I = Item.DeathKnight.Unholy;
--Rotation Var

local T202PC, T204PC = HL.HasTier("T20");
local T212PC, T214PC = HL.HasTier("T21");

local poolingforgargoyle

local function aoe()
    --# AoE rotation
    --actions.aoe=death_and_decay,if=cooldown.apocalypse.remains
    if S.DeathAndDecay:IsReady() and Cache.EnemiesCount[10] >= 1 and RubimRH.lastMoved() >= 0.5 and not S.Apocalypse:CooldownUp() then
        return S.DeathAndDecay:Cast()
    end

    --actions.aoe+=/defile
    if S.Defile:IsReady() and Cache.EnemiesCount[10] >= 1 and RubimRH.lastMoved() >= 0.5 then
        return S.Defile:Cast()
    end

    --actions.aoe+=/epidemic,if=death_and_decay.ticking&rune<2&!variable.pooling_for_gargoyle
    if S.Epidemic:IsReady() and Player:Buff(S.DeathAndDecayBuff) and Player:Runes() < 2 and not poolingforgargoyle then
        return S.Epidemic:Cast()
    end

    --actions.aoe+=/death_coil,if=death_and_decay.ticking&rune<2&!talent.epidemic.enabled&!variable.pooling_for_gargoyle
    if S.DeathCoil:IsReady() and Player:Buff(S.DeathAndDecayBuff) and Player:Runes() < 2 and not S.Epidemic:IsAvailable() and not poolingforgargoyle then
        return S.DeathCoil:Cast()
    end

    --actions.aoe+=/scourge_strike,if=death_and_decay.ticking&cooldown.apocalypse.remains
    if S.ScourgeStrike:IsReady() and Player:Buff(S.DeathAndDecayBuff) and not S.Apocalypse:CooldownUp() then
        return S.ScourgeStrike:Cast()
    end

    --actions.aoe+=/clawing_shadows,if=death_and_decay.ticking&cooldown.apocalypse.remains
    if S.ClawingShadows:IsReady() and Player:Buff(S.DeathAndDecayBuff) and not S.Apocalypse:CooldownUp() then
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
    --actions.cooldowns=call_action_list,name=cold_heart,if=equipped.cold_heart&buff.cold_heart_item.stack>10
    if I.ColdHeart:IsEquipped() and Player:BuffStack(S.ColdHeartItemBuff) > 10 then
        if cold_heart() ~= nil then
            return cold_heart()
        end
    end

    --actions.cooldowns+=/army_of_the_dead
    --actions.cooldowns+=/apocalypse,if=debuff.festering_wound.stack>=4
    if S.Apocalypse:IsReady() and Target:DebuffStack(S.FesteringWounds) >= 4 then
        return S.Apocalypse:Cast()
    end
    --actions.cooldowns+=/dark_transformation,if=(equipped.137075&cooldown.summon_gargoyle.remains>40)|(!equipped.137075|!talent.summon_gargoyle.enabled)
    if S.DarkTransformation:Ready() and ((I.Taktheritrixs:IsEquipped() and (S.SummonGargoyle:CooldownRemains() > 40 or RubimRH.CDsON())) or (not I.Taktheritrixs:IsEquipped() or not S.SummonGargoyle:IsAvailable())) then
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
    if S.UnholyFrenzy:IsReady() and Cache.EnemiesCount[8] >= 2 and ((S.DeathAndDecay:CooldownRemains() < Player:GCD() and not S.Defile:IsAvailable()) or (S.Defile.CooldownRemains() <= Player:GCD() and S.Defile:IsAvailable())) then
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
    --actions.generic=death_coil,if=buff.sudden_doom.react&!variable.pooling_for_gargoyle|pet.gargoyle.active
    if S.DeathCoil:IsReady() and (Player:Buff(S.SuddenDoom) and not poolingforgargoyle or S.SummonGargoyle:TimeSinceLastCast() <= 29) then
        return S.DeathCoil:Cast()
    end

    --actions.generic+=/death_coil,if=runic_power.deficit<14&(cooldown.apocalypse.remains>5|debuff.festering_wound.stack>4)&!variable.pooling_for_gargoyle
    if S.DeathCoil:IsReady() and Player:Buff(S.SuddenDoom) and Player:RunicPowerDeficit() >= 4 then
        return S.DeathCoil:Cast()
    end

    --actions.generic+=/death_and_decay,if=talent.pestilence.enabled&cooldown.apocalypse.remains
    if S.DeathAndDecay:IsReady() and S.Pestilence:IsAvailable() and not S.Apocalypse:CooldownUp() and Cache.EnemiesCount[10] >= 1 and RubimRH.lastMoved() >= 0.5 then
        return S.DeathAndDecay:Cast()
    end

    --actions.generic+=/defile,if=cooldown.apocalypse.remains
    if S.Defile:IsReady() and not S.Apocalypse:CooldownUp() and Cache.EnemiesCount[10] >= 1 and RubimRH.lastMoved() >= 0.5 then
        return S.Defile:Cast()
    end

    --actions.generic+=/scourge_strike,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
    if S.ScourgeStrike:IsReady() and ((Target:Debuff(S.FesteringWounds) and S.Apocalypse:CooldownRemains() > 5) or Target:DebuffStack(S.FesteringWounds) > 4) then
        return S.ScourgeStrike:Cast()
    end

    --actions.generic+=/clawing_shadows,if=((debuff.festering_wound.up&cooldown.apocalypse.remains>5)|debuff.festering_wound.stack>4)&cooldown.army_of_the_dead.remains>5
    if S.ClawingShadows:IsReady() and ((Target:Debuff(S.FesteringWounds) and S.Apocalypse:CooldownRemains() > 5) or Target:DebuffStack(S.FesteringWounds) > 4) then
        return S.ClawingShadows:Cast()
    end

    --actions.generic+=/death_coil,if=runic_power.deficit<20&!variable.pooling_for_gargoyle
    if S.DeathCoil:IsReady() and Player:RunicPowerDeficit() < 20 and not poolingforgargoyle then
        return S.DeathCoil:Cast()
    end

    --actions.generic+=/festering_strike,if=((((debuff.festering_wound.stack<4&!buff.unholy_frenzy.up)|debuff.festering_wound.stack<3)&cooldown.apocalypse.remains<3)|debuff.festering_wound.stack<1)&cooldown.army_of_the_dead.remains>5
    if S.FesteringStrike:IsReady() and ((((Target:DebuffStack(S.FesteringWounds) < 4 and not Player:Buff(S.UnholyFrenzy) or Target:DebuffStack(S.FesteringWounds) < 3) and S.Apocalypse:CooldownRemains() < 3) or Target:DebuffStack(S.FesteringWounds) < 1)) then
        return S.FesteringStrike:Cast()
    end

    --actions.generic+=/death_coil,if=!variable.pooling_for_gargoyle
    if S.DeathCoil:IsReady() and not poolingforgargoyle then
        return S.DeathCoil:Cast()
    end
end

local function APL()
    HL.GetEnemies(8);
    HL.GetEnemies(10);

    if not Player:AffectingCombat() then
        --check if we have our lovely pet with us
        if not Pet:IsActive() and S.SummonPet:IsCastable() then
            return S.SummonPet:Cast()
        end
        return 0, 462338
    end

    --# Executed every time the actor is available.
    --actions=auto_attack
    --actions+=/mind_freeze
    --actions+=/variable,name=pooling_for_gargoyle,value=(cooldown.summon_gargoyle.remains<5&(cooldown.dark_transformation.remains<5|!equipped.137075))&talent.summon_gargoyle.enabled
    poolingforgargoyle = (S.SummonGargoyle:CooldownRemains() < 5 and (S.DarkTransformation:CooldownRemains() < 5 or not I.Taktheritrixs:IsEquipped()) and S.SummonGargoyle:IsAvailable()) and RubimRH.CDsON()
    --# Racials, Items, and other ogcds

    --actions+=/arcane_torrent,if=runic_power.deficit>65&(pet.gargoyle.active|!talent.summon_gargoyle.enabled)&rune.deficit>=5
    --actions+=/blood_fury,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled
    if S.BloodFury:IsReady() and (S.SummonGargoyle:TimeSinceLastCast() <= 39 or not S.SummonGargoyle:IsAvailable()) then
        return S.BloodFury:Cast()
    end

    --actions+=/berserking,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled
    if S.Berserking:IsReady() and (S.SummonGargoyle:TimeSinceLastCast() <= 39 or not S.SummonGargoyle:IsAvailable()) then
        return S.Berserking:Cast()
    end
    --actions+=/use_items
    --actions+=/use_item,name=feloiled_infernal_machine,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled
    --actions+=/use_item,name=ring_of_collapsing_futures,if=(buff.temptation.stack=0&target.time_to_die>60)|target.time_to_die<60
    --actions+=/potion,if=cooldown.army_of_the_dead.ready|pet.gargoyle.active|buff.unholy_frenzy.up
    --# Maintain Virulent Plague
    --actions+=/outbreak,target_if=(dot.virulent_plague.tick_time_remains+tick_time<=dot.virulent_plague.remains)&dot.virulent_plague.remains<=gcd
    if S.Outbreak:IsReady() and (not Target:Debuff(S.VirulentPlagueDebuff) or Target:DebuffRemainsP(S.VirulentPlagueDebuff) < Player:GCD()) then
        return S.Outbreak:Cast()
    end

    --actions+=/call_action_list,name=cooldowns
    if cooldowns() ~= nil then
        return cooldowns()
    end

    --actions+=/call_action_list,name=aoe,if=active_enemies>=2
    if aoe() ~= nil and Cache.EnemiesCount[10] >= 2 then
        return aoe()
    end

    --actions+=/call_action_list,name=generic
    if generic() ~= nil then
        return generic()
    end

    return 0, 975743
end
RubimRH.Rotation.SetAPL(252, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(252, PASSIVE);

--# Executed every time the actor is available.
--actions=auto_attack
--actions+=/mind_freeze
--actions+=/variable,name=pooling_for_gargoyle,value=(cooldown.summon_gargoyle.remains<5&(cooldown.dark_transformation.remains<5|!equipped.137075))&talent.summon_gargoyle.enabled
--# Racials, Items, and other ogcds
--actions+=/arcane_torrent,if=runic_power.deficit>65&(pet.gargoyle.active|!talent.summon_gargoyle.enabled)&rune.deficit>=5
--actions+=/blood_fury,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled
--actions+=/berserking,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled
--actions+=/use_items
--actions+=/use_item,name=feloiled_infernal_machine,if=pet.gargoyle.active|!talent.summon_gargoyle.enabled
--actions+=/use_item,name=ring_of_collapsing_futures,if=(buff.temptation.stack=0&target.time_to_die>60)|target.time_to_die<60
--actions+=/potion,if=cooldown.army_of_the_dead.ready|pet.gargoyle.active|buff.unholy_frenzy.up
--# Maintain Virulent Plague
--actions+=/outbreak,target_if=(dot.virulent_plague.tick_time_remains+tick_time<=dot.virulent_plague.remains)&dot.virulent_plague.remains<=gcd
--actions+=/call_action_list,name=cooldowns
--actions+=/call_action_list,name=aoe,if=active_enemies>=2
--actions+=/call_action_list,name=generic
