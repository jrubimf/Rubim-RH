--- ============================ HEADER ============================
local RubimRH = LibStub("AceAddon-3.0"):GetAddon("RubimRH")
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
-- Spells
if not Spell.DeathKnight then
    Spell.DeathKnight = {};
end
Spell.DeathKnight.Unholy = {
    -- Racials
    ArcaneTorrent = Spell(50613),
    Berserking = Spell(26297),
    BloodFury = Spell(20572),
    GiftoftheNaaru = Spell(59547),
    -- Artifact
    Apocalypse = Spell(275699),
    --Abilities
    ArmyOfDead = Spell(42650),
    ChainsOfIce = Spell(45524),
    ScourgeStrike = Spell(55090),
    DarkTransformation = Spell(63560),
    DeathAndDecay = Spell(43265),
    DeathCoil = Spell(47541),
    DeathStrike = Spell(49998),
    FesteringStrike = Spell(85948),
    Outbreak = Spell(77575),
    SummonPet = Spell(46584),
    --Talents
    InfectedClaws = Spell(207272),
    AllWillServe = Spell(194916),
    ClawingShadows = Spell(207311),
    PestilentPustules = Spell(194917),
    InevitableDoom = Spell(276023),
    SoulReaper = Spell(130736),
    BurstingSores = Spell(207264),
    EbonFever = Spell(207269),
    UnholyBlight = Spell(115989),
    CorpseExplosion = Spell(276049),
    Defile = Spell(152280),
    Epidemic = Spell(207317),
    DarkInfusion = Spell(198943),
    UnholyFrenzy = Spell(207289),
    SummonGargoyle = Spell(49206),
    --Necrosis                      = Spell(207346), not on beta atm
    --Buffs/Procs
    --MasterOfGhouls                = Spell(246995), not on beta atm
    SuddenDoom = Spell(81340),
    UnholyStrength = Spell(53365),
    --NecrosisBuff                  = Spell(216974), not on beta atm
    DeathAndDecayBuff = Spell(188290),
    --Debuffs
    SoulReaperDebuff = Spell(130736),
    FesteringWounds = Spell(194310), --max 8 stacks
    VirulentPlagueDebuff = Spell(191587), -- 13s debuff from Outbreak
    --Defensives
    AntiMagicShell = Spell(48707),
    IcebornFortitute = Spell(48792),
    -- Utility
    ControlUndead = Spell(45524),
    DeathGrip = Spell(49576),
    MindFreeze = Spell(47528),
    PathOfFrost = Spell(3714),
    WraithWalk = Spell(212552),
    --Legendaries Buffs/SpellIds
    ColdHeartItemBuff = Spell(235599),
    InstructorsFourthLesson = Spell(208713),
    KiljaedensBurningWish = Spell(144259),
    --SummonGargoyle HiddenAura
    SummonGargoyleActive = Spell(212412), --tbc
    -- Misc
    PoolForArmy = Spell(9999000010)
};

local S = Spell.DeathKnight.Unholy;

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

local function aoe()
    --# AoE rotation
    --actions.aoe=death_and_decay,if=spell_targets.death_and_decay>=2
    --actions.aoe+=/epidemic,if=spell_targets.epidemic>4
    --actions.aoe+=/scourge_strike,if=spell_targets.scourge_strike>=2&(death_and_decay.ticking|defile.ticking)
    --actions.aoe+=/clawing_shadows,if=spell_targets.clawing_shadows>=2&(death_and_decay.ticking|defile.ticking)
    --actions.aoe+=/epidemic,if=spell_targets.epidemic>2
    if S.DeathAndDecay:IsReady() and Cache.EnemiesCount[10] >= 2 then
        return S.DeathAndDecay:ID()
    end

    if S.Epidemic:IsReady() and Cache.EnemiesCount[10] > 4 then
        return S.Epidemic:ID()
    end

    if S.ScourgeStrike:IsReady("Melee") and Cache.EnemiesCount[8] >= 2 and Player:Buff(S.DeathAndDecayBuff) then
        return S.ScourgeStrike:ID()
    end

    if S.ClawingShadows:IsReady() and Cache.EnemiesCount[8] >= 2 and Player:Buff(S.DeathAndDecayBuff) then
        return 241367
    end

    if S.Epidemic:IsReady() and Cache.EnemiesCount[10] > 2 then
        return S.Epidemic:ID()
    end

end

local function cold_heart()
    --# Cold Heart legendary
    --actions.cold_heart=chains_of_ice,if=buff.unholy_strength.remains<gcd&buff.unholy_strength.react&buff.cold_heart_item.stack>16
    --actions.cold_heart+=/chains_of_ice,if=buff.master_of_ghouls.remains<gcd&buff.master_of_ghouls.up&buff.cold_heart_item.stack>17
    --actions.cold_heart+=/chains_of_ice,if=buff.cold_heart_item.stack=20&buff.unholy_strength.react
    --actions.cold_heart=chains_of_ice,if=buff.unholy_strength.remains<gcd&buff.unholy_strength.react&buff.cold_heart.stack>16
    if S.ChainsOfIce:IsReady() and Player:BuffRemainsP(S.UnholyStrength) < Player:GCD() and Player:Buff(S.UnholyStrength) and Player:BuffStack(S.ColdHeartItemBuff) > 16 then
        return S.ChainsOfIce:ID()
    end
    --actions.cold_heart+=/chains_of_ice,if=buff.master_of_ghouls.remains<gcd&buff.master_of_ghouls.up&buff.cold_heart.stack>17
    --actions.cold_heart+=/chains_of_ice,if=buff.cold_heart.stack=20&buff.unholy_strength.react
    if S.ChainsOfIce:IsReady() and Player:BuffStack(S.ColdHeartItemBuff) == 20 and Player:Buff(S.UnholyStrength) then
        return S.ChainsOfIce:ID()
    end
end

local function cooldowns()
    --# Cold heart and other on-gcd cooldowns
    --actions.cooldowns=call_action_list,name=cold_heart,if=equipped.cold_heart&buff.cold_heart_item.stack>10
    --actions.cooldowns+=/army_of_the_dead
    --actions.cooldowns+=/soul_reaper,if=debuff.festering_wound.stack>=3&rune>=3
    --actions.cooldowns+=/dark_transformation,if=rune.time_to_4>=gcd
    if I.ColdHeart:IsEquipped() and Player:BuffStack(S.ColdHeartItemBuff) > 10 then
        if cold_heart() ~= nil then
            return cold_heart()
        end
    end

    if S.SoulReaper:IsReady() and Target:DebuffStack(S.FesteringWounds) >= 3 and Player:Runes() >= 3 then
        return S.SoulReaper:ID()
    end

    if RubimRH.CDsON() and S.DarkTransformation:IsReady() and Player:RuneTimeToX(4) >= Player:GCD() then
        return S.DarkTransformation:ID()
    end
end

local function generic()
    --actions.generic=death_coil,if=runic_power.deficit<22
    --actions.generic+=/defile
    --# Switch to aoe
    --actions.generic+=/call_action_list,name=aoe,if=active_enemies>=2
    --# Wounds management
    --actions.generic+=/festering_strike,if=debuff.festering_wound.stack<=2|rune.time_to_4<=gcd
    --actions.generic+=/scourge_strike,if=(buff.unholy_strength.react|rune>=2)&debuff.festering_wound.stack>=1&debuff.festering_wound.stack>=3|(cooldown.army_of_the_dead.remains>5|rune.time_to_4<=gcd)
    --actions.generic+=/clawing_shadows,if=(buff.unholy_strength.react|rune>=2)&debuff.festering_wound.stack>=1&debuff.festering_wound.stack>=3|(cooldown.army_of_the_dead.remains>5|rune.time_to_4<=gcd)
    if S.DeathCoil:IsReady() and Player:RunicPowerDeficit() < 22 then
        return S.DeathCoil:ID()
    end

    if S.Defile:IsReady() and Cache.EnemiesCount[10] >= 1 then
        return S.Defile:ID()
    end

    if Cache.EnemiesCount[10] >= 2 and aoe() ~= nil then
        return aoe()
    end

    if S.FesteringStrike:IsReady("Melee") and Target:DebuffStack(S.FesteringWounds) >= 2 or Player:RuneTimeToX(4) <= Player:GCD() then
        return S.FesteringStrike:ID()
    end

    if S.ScourgeStrike:IsReady("Melee") and (Player:Buff(S.UnholyStrength) or Player:Runes() >= 2) and Target:DebuffStack(S.FesteringWounds) >= 3 or (Player:RuneTimeToX(4) >= Player:GCD()) then
        return S.ScourgeStrike:ID()
    end

    if S.ClawingShadows:IsReady("Melee") and (Player:Buff(S.UnholyStrength) or Player:Runes() >= 2) and Target:DebuffStack(S.FesteringWounds) >= 3 or (Player:RuneTimeToX(4) >= Player:GCD()) then
        return 241367
    end
end

local function APL()
    --UnitUpdate
    HL.GetEnemies(8);
    HL.GetEnemies(10);
    --Defensives
    --OutOf Combat
    -- Reset Combat Variables
    -- Flask
    -- Food
    -- Rune
    -- Army w/ Bossmod Countdown
    -- Volley toggle
    -- Opener

    if not Player:AffectingCombat() then
        --check if we have our lovely pet with us
        if not Pet:IsActive() and S.SummonPet:IsCastable() then
            return S.SummonPet:ID()
        end
        return 0, 462338
    end

    --actions+=/arcane_torrent,if=runic_power.deficit>20
    --actions+=/blood_fury
    if S.BloodFury:IsReady("Melee") and RubimRH.CDsON() then
        return S.BloodFury:ID()
    end

    --actions+=/berserking
    if S.Berserking:IsReady("Melee") and RubimRH.CDsON() then
        return S.Berserking:ID()
    end

    --actions+=/use_items
    --actions+=/use_item,name=ring_of_collapsing_futures,if=(buff.temptation.stack=0&target.time_to_die>60)|target.time_to_die<60
    --actions+=/potion,if=buff.unholy_strength.react
    --# Maintain Virulent Plague

    --GOTTA DO SIMCRAFT
    --actions+=/outbreak,target_if=(dot.virulent_plague.tick_time_remains+tick_time<=dot.virulent_plague.remains)&dot.virulent_plague.remains<=gcd
    if S.Outbreak:IsReady() and Target:DebuffRemains(S.VirulentPlagueDebuff) <= Player:GCD() * 2 then
        return S.Outbreak:ID()
    end

    --actions+=/call_action_list,name=cooldowns
    if cooldowns() ~= nil then
        return cooldowns()
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
--# Racials, Items, and other ogcds
--actions+=/arcane_torrent,if=runic_power.deficit>20
--actions+=/blood_fury
--actions+=/berserking
--actions+=/use_items
--actions+=/use_item,name=ring_of_collapsing_futures,if=(buff.temptation.stack=0&target.time_to_die>60)|target.time_to_die<60
--actions+=/potion,if=buff.unholy_strength.react
--# Maintain Virulent Plague
--actions+=/outbreak,target_if=(dot.virulent_plague.tick_time_remains+tick_time<=dot.virulent_plague.remains)&dot.virulent_plague.remains<=gcd
--actions+=/call_action_list,name=cooldowns
--actions+=/call_action_list,name=generic

--# AoE rotation
--actions.aoe=death_and_decay,if=spell_targets.death_and_decay>=2
--actions.aoe+=/epidemic,if=spell_targets.epidemic>4
--actions.aoe+=/scourge_strike,if=spell_targets.scourge_strike>=2&(death_and_decay.ticking|defile.ticking)
--actions.aoe+=/clawing_shadows,if=spell_targets.clawing_shadows>=2&(death_and_decay.ticking|defile.ticking)
--actions.aoe+=/epidemic,if=spell_targets.epidemic>2

--# Cold Heart legendary
--actions.cold_heart=chains_of_ice,if=buff.unholy_strength.remains<gcd&buff.unholy_strength.react&buff.cold_heart_item.stack>16
--actions.cold_heart+=/chains_of_ice,if=buff.master_of_ghouls.remains<gcd&buff.master_of_ghouls.up&buff.cold_heart_item.stack>17
--actions.cold_heart+=/chains_of_ice,if=buff.cold_heart_item.stack=20&buff.unholy_strength.react

--# Cold heart and other on-gcd cooldowns
--actions.cooldowns=call_action_list,name=cold_heart,if=equipped.cold_heart&buff.cold_heart_item.stack>10
--actions.cooldowns+=/army_of_the_dead
--actions.cooldowns+=/soul_reaper,if=debuff.festering_wound.stack>=3&rune>=3
--actions.cooldowns+=/dark_transformation,if=rune.time_to_4>=gcd

--actions.generic=death_coil,if=runic_power.deficit<22
--actions.generic+=/defile
--# Switch to aoe
--actions.generic+=/call_action_list,name=aoe,if=active_enemies>=2
--# Wounds management
--actions.generic+=/festering_strike,if=debuff.festering_wound.stack<=2|rune.time_to_4<=gcd
--actions.generic+=/scourge_strike,if=(buff.unholy_strength.react|rune>=2)&debuff.festering_wound.stack>=1&debuff.festering_wound.stack>=3|(cooldown.army_of_the_dead.remains>5|rune.time_to_4<=gcd)
--actions.generic+=/clawing_shadows,if=(buff.unholy_strength.react|rune>=2)&debuff.festering_wound.stack>=1&debuff.festering_wound.stack>=3|(cooldown.army_of_the_dead.remains>5|rune.time_to_4<=gcd)