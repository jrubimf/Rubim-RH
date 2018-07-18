--- Localize Vars
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
local MouseOver = Unit.MouseOver;
-- Lua
local pairs = pairs;
local tableconcat = table.concat;
local tostring = tostring;


--- APL Local Vars
-- Spells
if not Spell.Rogue then
    Spell.Rogue = {};
end
Spell.Rogue.Outlaw = {
    -- Racials
    ArcaneTorrent = Spell(25046),
    Berserking = Spell(26297),
    BloodFury = Spell(20572),
    Darkflight = Spell(68992),
    GiftoftheNaaru = Spell(59547),
    Shadowmeld = Spell(58984),
    -- Abilities
    AdrenalineRush = Spell(13750),
    Ambush = Spell(8676),
    BetweentheEyes = Spell(199804),
    BladeFlurry = Spell(13877),
    BladeFlurry2 = Spell(103828), -- Icon: Prot. Warrior Warbringer
    DeeperStratagem = Spell(193531),
    Opportunity = Spell(195627),
    PistolShot = Spell(185763),
    RolltheBones = Spell(193316),
    RunThrough = Spell(2098),
    SaberSlash = Spell(193315),
    Stealth = Spell(1784),
    Vanish = Spell(1856),
    VanishBuff = Spell(11327),
    -- Talents
    Alacrity = Spell(193539),
    AlacrityBuff = Spell(193538),
    Anticipation = Spell(114015),
    CannonballBarrage = Spell(185767),
    DeathfromAbove = Spell(152150),
    DeeperStratagem = Spell(193531),
    DirtyTricks = Spell(108216),
    GhostlyStrike = Spell(196937),
    KillingSpree = Spell(51690),
    MarkedforDeath = Spell(137619),
    QuickDraw = Spell(196938),
    SliceandDice = Spell(5171),
    Vigor = Spell(14983),
    -- Artifact
    Blunderbuss = Spell(202895),
    CurseoftheDreadblades = Spell(202665),
    HiddenBlade = Spell(202754),
    LoadedDice = Spell(240837),
    -- Defensive
    CrimsonVial = Spell(185311),
    Feint = Spell(1966),
    -- Utility
    Gouge = Spell(1776),
    Kick = Spell(1766),
    Sprint = Spell(2983),
    -- Roll the Bones
    Broadsides = Spell(193356),
    BuriedTreasure = Spell(199600),
    GrandMelee = Spell(193358),
    JollyRoger = Spell(199603),
    SharkInfestedWaters = Spell(193357),
    TrueBearing = Spell(193359),
    -- Legendaries
    GreenskinsWaterloggedWristcuffs = Spell(209423)
}
local S = Spell.Rogue.Outlaw;
--
-- User: Rubim
-- Date: 28/05/2018
-- Time: 16:50
--

-- Stealth
local function Stealth(Stealth, Setting)
    if Stealth:IsReady() and not Player:IsStealthed() then
        return false --stealth
    end
    return false;
end

-- Crimson Vial
local function CrimsonVial(CrimsonVial)
    if CrimsonVial:IsReady() and Player:HealthPercentage() <= 80 then
        return false --defensives
    end
    return false;
end

-- Feint
local function Feint(Feint)
    if Feint:IsReady() and not Player:Buff(Feint) and Player:HealthPercentage() <= 80 then
        return false --feint
    end
end

-- Marked for Death Sniping
local BestUnit, BestUnitTTD;
local function MfDSniping(MarkedforDeath)
    if MarkedforDeath:IsReady() then
        -- Get Units up to 30y for MfD.
        HL.GetEnemies(30);

        BestUnit, BestUnitTTD = nil, 60;
        local MOTTD = MouseOver:IsInRange(30) and MouseOver:TimeToDie() or 11111;
        local TTD;
        for _, Unit in pairs(Cache.Enemies[30]) do
            TTD = Unit:TimeToDie();
            -- Note: Increased the SimC condition by 50% since we are slower.
            if not Unit:IsMfdBlacklisted() and TTD < Player:ComboPointsDeficit() * 1.5 and TTD < BestUnitTTD then
                if MOTTD - TTD > 1 then
                    BestUnit, BestUnitTTD = Unit, TTD;
                else
                    BestUnit, BestUnitTTD = MouseOver, MOTTD;
                end
            end
        end
        if BestUnit then
            print(BestUnit)
        end
    end
end

-- Everyone CanDotUnit override to account for Mantle
-- Is it worth to DoT the unit ?
local function CanDoTUnit(Unit, HealthThreshold)
    return Everyone.CanDoTUnit(Unit, HealthThreshold * (Commons.MantleDuration() > 0 and Settings.EDMGMantleOffset or 1));
end

--- ======= SIMC CUSTOM FUNCTION / EXPRESSION =======
-- cp_max_spend
local function CPMaxSpend ()
    -- Should work for all 3 specs since they have same Deeper Stratagem Spell ID.
    return S.DeeperStratagem:IsAvailable() and 6 or 5;
end
-- "cp_spend"
local function CPSpend()
    return mathmin(Player:ComboPoints(), CPMaxSpend());
end

local MasterAssassinsInitiative, NominalDuration = Spell(235027), 6;
local function MantleDuration()
    if Player:BuffRemains(MasterAssassinsInitiative) < 0 then
        return Player:GCDRemains() + NominalDuration;
    else
        return Player:BuffRemainsP(MasterAssassinsInitiative);
    end
end

-- Choose a persistent PistolShot icon to avoid Blunderbuss icon
S.PistolShot.TextureSpellID = 242277;
-- Items
if not Item.Rogue then
    Item.Rogue = {};
end
Item.Rogue.Outlaw = {
    -- Legendaries
    GreenskinsWaterloggedWristcuffs = Item(137099, { 9 }),
    MantleoftheMasterAssassin = Item(144236, { 3 }),
    ShivarranSymmetry = Item(141321, { 10 }),
    ThraxisTricksyTreads = Item(137031, { 8 })
};
local I = Item.Rogue.Outlaw;
-- Spells Damage / PMultiplier
local function ImprovedSliceAndDice()
    return Player:Buff(S.SliceandDice) and Player:Buff(S.SliceandDice, 17) > 125;
end



-- Rotation Var
local ShouldReturn; -- Used to get the return string
local RTIdentifier, SSIdentifier = tostring(S.RunThrough:ID()), tostring(S.SaberSlash:ID());
local BFTimer, BFReset = 0, nil; -- Blade Flurry Expiration Offset
local RtB_BuffsList = {
    S.Broadsides,
    S.BuriedTreasure,
    S.GrandMelee,
    S.JollyRoger,
    S.SharkInfestedWaters,
    S.TrueBearing
};
local function RtB_List(Type, List)
    if not Cache.APLVar.RtB_List then
        Cache.APLVar.RtB_List = {};
    end
    if not Cache.APLVar.RtB_List[Type] then
        Cache.APLVar.RtB_List[Type] = {};
    end
    local Sequence = table.concat(List);
    -- All
    if Type == "All" then
        if not Cache.APLVar.RtB_List[Type][Sequence] then
            local Count = 0;
            for i = 1, #List do
                if Player:Buff(RtB_BuffsList[List[i]]) then
                    Count = Count + 1;
                end
            end
            Cache.APLVar.RtB_List[Type][Sequence] = Count == #List and true or false;
        end
        -- Any
    else
        if not Cache.APLVar.RtB_List[Type][Sequence] then
            Cache.APLVar.RtB_List[Type][Sequence] = false;
            for i = 1, #List do
                if Player:Buff(RtB_BuffsList[List[i]]) then
                    Cache.APLVar.RtB_List[Type][Sequence] = true;
                    break ;
                end
            end
        end
    end
    return Cache.APLVar.RtB_List[Type][Sequence];
end

local function RtB_BuffRemains()
    if not Cache.APLVar.RtB_BuffRemains then
        Cache.APLVar.RtB_BuffRemains = 0;
        for i = 1, #RtB_BuffsList do
            if Player:Buff(RtB_BuffsList[i]) then
                Cache.APLVar.RtB_BuffRemains = Player:BuffRemainsP(RtB_BuffsList[i]);
                break ;
            end
        end
    end
    return Cache.APLVar.RtB_BuffRemains;
end

-- Get the number of Roll the Bones buffs currently on
local function RtB_Buffs()
    if not Cache.APLVar.RtB_Buffs then
        Cache.APLVar.RtB_Buffs = 0;
        for i = 1, #RtB_BuffsList do
            if Player:BuffP(RtB_BuffsList[i]) then
                Cache.APLVar.RtB_Buffs = Cache.APLVar.RtB_Buffs + 1;
            end
        end
    end
    return Cache.APLVar.RtB_Buffs;
end

-- # Reroll when Loaded Dice is up and if you have less than 2 buffs or less than 4 and no True Bearing. With SnD, consider that we never have to reroll.
local function RtB_Reroll()
    Cache.APLVar.RtB_Reroll = (not S.SliceandDice:IsAvailable() and not Player:BuffP(S.GrandMelee)) and true or false;
    if not Cache.APLVar.RtB_Reroll then
        --        -- Defensive Override : Grand Melee if HP < 60
        if selectedBuff == "SoloMode" and Player:HealthPercentage() < 50 then
            Cache.APLVar.RtB_Reroll = (not S.SliceandDice:IsAvailable() and not Player:BuffP(S.GrandMelee)) and true or false;
            --            -- 1+ Buff
        elseif selectedBuff == "1+ Buff" then
            Cache.APLVar.RtB_Reroll = (not S.SliceandDice:IsAvailable() and RtB_Buffs() <= 0) and true or false;
            --            -- Broadsides
        elseif selectedBuff == "Broadsides" then
            Cache.APLVar.RtB_Reroll = (not S.SliceandDice:IsAvailable() and not Player:BuffP(S.Broadsides)) and true or false;
            --            -- Buried Treasure
        elseif selectedBuff == "Buried Treasure" then
            Cache.APLVar.RtB_Reroll = (not S.SliceandDice:IsAvailable() and not Player:BuffP(S.BuriedTreasure)) and true or false;
            --            -- Grand Melee
        elseif selectedBuff == "Grand Melee" then
            Cache.APLVar.RtB_Reroll = (not S.SliceandDice:IsAvailable() and not Player:BuffP(S.GrandMelee)) and true or false;
            --            -- Jolly Roger
        elseif selectedBuff == "Jolly Roger" then
            Cache.APLVar.RtB_Reroll = (not S.SliceandDice:IsAvailable() and not Player:BuffP(S.JollyRoger)) and true or false;
            --            -- Shark Infested Waters
        elseif selectedBuff == "Shark Infested Waters" then
            Cache.APLVar.RtB_Reroll = (not S.SliceandDice:IsAvailable() and not Player:BuffP(S.SharkInfestedWaters)) and true or false;
            --            -- True Bearing
        elseif selectedBuff == "True Bearing" then
            Cache.APLVar.RtB_Reroll = (not S.SliceandDice:IsAvailable() and not Player:BuffP(S.TrueBearing)) and true or false;
            --            -- SimC Default
            -- actions=variable,name=rtb_reroll,value=!talent.slice_and_dice.enabled&buff.loaded_dice.up&(rtb_buffs<2|(rtb_buffs<4&!buff.true_bearing.up))
        else
            Cache.APLVar.RtB_Reroll = (not S.SliceandDice:IsAvailable() and Player:BuffP(S.LoadedDice) and (RtB_Buffs() < 2 or (RtB_Buffs() < 4 and not Player:BuffP(S.TrueBearing)))) and true or false;
        end
    end
    return Cache.APLVar.RtB_Reroll;

end

-- # Condition to use Saber Slash when not rerolling RtB or when using SnD
local function SS_Useable_NoReroll()
    -- actions+=/variable,name=ss_useable_noreroll,value=(combo_points<4+talent.deeper_stratagem.enabled)
    if not Cache.APLVar.SS_Useable_NoReroll then
        Cache.APLVar.SS_Useable_NoReroll = (Player:ComboPoints() < (4 + (S.DeeperStratagem:IsAvailable() and 1 or 0))) and true or false;
    end
    return Cache.APLVar.SS_Useable_NoReroll;
end

-- # Condition to use Saber Slash, when you have RtB or not
local function SS_Useable()
    -- actions+=/variable,name=ss_useable,value=(talent.anticipation.enabled&combo_points<5)|(!talent.anticipation.enabled&((variable.rtb_reroll&combo_points<4+talent.deeper_stratagem.enabled)|(!variable.rtb_reroll&variable.ss_useable_noreroll)))
    if not Cache.APLVar.SS_Useable then
        Cache.APLVar.SS_Useable = ((S.Anticipation:IsAvailable() and Player:ComboPoints() < 5)
                or (not S.Anticipation:IsAvailable() and ((RtB_Reroll() and Player:ComboPoints() < 4 + (S.DeeperStratagem:IsAvailable() and 1 or 0))
                or (not RtB_Reroll() and SS_Useable_NoReroll())))) and true or false;
    end
    return Cache.APLVar.SS_Useable;
end

local function EnergyTimeToMaxRounded()
    -- Round to the nearesth 10th to reduce prediction instability on very high regen rates
    return math.floor(Player:EnergyTimeToMaxHeroLib() * 10 + 0.5) / 10;
end

local function BladeFlurry()
    -- Blade Flurry Expiration Offset
    if Cache.EnemiesCount[RTIdentifier] == 1 and BFReset then
        BFTimer, BFReset = HL.GetTime(), false;
    elseif Cache.EnemiesCount[RTIdentifier] > 1 then
        BFReset = true;
    end

    if Player:Buff(S.BladeFlurry) then
        -- actions.bf=cancel_buff,name=blade_flurry,if=spell_targets.blade_flurry<2&buff.blade_flurry.up
        if Cache.EnemiesCount[RTIdentifier] < 2 and HL.GetTime() > BFTimer then
            return S.BladeFlurry:ID()
        end
        -- actions.bf+=/cancel_buff,name=blade_flurry,if=equipped.shivarran_symmetry&cooldown.blade_flurry.up&buff.blade_flurry.up&spell_targets.blade_flurry>=2
        if I.ShivarranSymmetry:IsEquipped() and S.BladeFlurry:CooldownUp() and Cache.EnemiesCount[RTIdentifier] >= 2 then
            return S.BladeFlurry:ID()
        end
    else
        -- actions.bf+=/blade_flurry,if=spell_targets.blade_flurry>=2&!buff.blade_flurry.up
        if S.BladeFlurry:IsReady() and Cache.EnemiesCount[RTIdentifier] >= 2 then
            return S.BladeFlurry:ID()
        end
    end
end

local function CDs()
    if RubimRH.CDsON() then
        -- actions.cds=potion,if=buff.bloodlust.react|target.time_to_die<=60|buff.adrenaline_rush.up
        -- TODO: Add Potion
        -- actions.cds+=/use_item,if=buff.bloodlust.react|target.time_to_die<=20|combo_points.deficit<=2
        -- TODO: Add Items
        -- actions.cds+=/cannonball_barrage,if=spell_targets.cannonball_barrage>=1
        if RubimRH.AoEON() and S.CannonballBarrage:IsReady() and Cache.EnemiesCount[8] >= 1 then
            return S.CannonballBarrage:ID()
        end
    end
    if Target:IsInRange(S.SaberSlash) then
        if RubimRH.CDsON() then
            -- actions.cds+=/blood_fury
            if S.BloodFury:IsReady() then
                return S.BloodFury:ID()
            end
            -- actions.cds+=/berserking
            if S.Berserking:IsReady() then
                return S.Berserking:ID()
            end
            -- actions.cds+=/arcane_torrent,if=energy.deficit>40
            if S.ArcaneTorrent:IsReady() and Player:EnergyDeficitHeroLib() > 40 then
                return S.ArcaneTorrent:ID()
            end
            -- actions.cds+=/adrenaline_rush,if=!buff.adrenaline_rush.up&energy.deficit>0
            if S.AdrenalineRush:IsReady() and not Player:BuffP(S.AdrenalineRush) and Player:EnergyDeficitHeroLib() > 0 then
                return S.AdrenalineRush:ID()
            end
        end
        -- actions.cds+=/marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit|((raid_event.adds.in>40|buff.true_bearing.remains>15-buff.adrenaline_rush.up*5)&!stealthed.rogue&combo_points.deficit>=cp_max_spend-1)
        if S.MarkedforDeath:IsReady() then
            -- Note: Increased the SimC condition by 50% since we are slower.
            if Target:FilteredTimeToDie("<", Player:ComboPointsDeficit() * 1.5) or (Target:FilteredTimeToDie("<", 2) and Player:ComboPointsDeficit() > 0)
                    or (((Cache.EnemiesCount[30] == 1 and Player:BuffRemainsP(S.TrueBearing) > 15 - (Player:BuffP(S.AdrenalineRush) and 5 or 0))
                    or Target:IsDummy()) and not Player:IsStealthed(true, true) and Player:ComboPointsDeficit() >= CPMaxSpend() - 1) then
                return S.MarkedforDeath:ID()
            elseif not Player:IsStealthed(true, true) and Player:ComboPointsDeficit() >= CPMaxSpend() - 1 then
                return S.MarkedforDeath:ID()
            end
        end
        if RubimRH.CDsON() then
            if I.ThraxisTricksyTreads:IsEquipped() and not SS_Useable() then
                -- actions.cds+=/sprint,if=!talent.death_from_above.enabled&equipped.thraxis_tricksy_treads&!variable.ss_useable
                if S.Sprint:IsReady() and not S.DeathfromAbove:IsAvailable() then
                    return S.Sprint:ID()
                end
                -- actions.cds+=/darkflight,if=equipped.thraxis_tricksy_treads&!variable.ss_useable&buff.sprint.down
                if S.Darkflight:IsReady() and not Player:BuffP(S.Sprint) then
                    return S.Darkflight:ID()
                end
            end
            -- actions.cds+=/curse_of_the_dreadblades,if=combo_points.deficit>=4&(buff.true_bearing.up|buff.adrenaline_rush.up|time_to_die<20)
            if S.CurseoftheDreadblades:IsReady() and Player:ComboPointsDeficit() >= 4 and
                    (Player:BuffP(S.TrueBearing) or Player:BuffP(S.AdrenalineRush) or Target:FilteredTimeToDie("<", 20)) then
                return S.CurseoftheDreadblades:ID()
            end
        end
    end
end

local function Stealth()
    if Target:IsInRange(S.SaberSlash) then
        -- actions.stealth=variable,name=ambush_condition,value=combo_points.deficit>=2+2*(talent.ghostly_strike.enabled&!debuff.ghostly_strike.up)+buff.broadsides.up&energy>60&!buff.jolly_roger.up&!buff.hidden_blade.up
        local Ambush_Condition = (Player:ComboPointsDeficit() >= 2 + 2 * ((S.GhostlyStrike:IsAvailable() and not Target:Debuff(S.GhostlyStrike)) and 1 or 0)
                + (Player:Buff(S.Broadsides) and 1 or 0) and Player:EnergyHeroLib() > 60 and not Player:Buff(S.JollyRoger) and not Player:Buff(S.HiddenBlade)) and true or false;
        -- actions.stealth+=/ambush,if=variable.ambush_condition
        if Player:IsStealthed(true, true) and S.Ambush:IsReady() and Ambush_Condition then
            return S.Ambush:ID()
        else
            if RubimRH.CDsON() and not Player:IsTanking(Target) then
                -- actions.stealth+=/vanish,if=(variable.ambush_condition|equipped.mantle_of_the_master_assassin&!variable.rtb_reroll&!variable.ss_useable)&mantle_duration=0
                if S.Vanish:IsReady() and (Ambush_Condition or (I.MantleoftheMasterAssassin:IsEquipped() and not RtB_Reroll() and not SS_Useable()))
                        and MantleDuration() == 0 then
                    return S.Vanish:ID()
                end
                -- actions.stealth+=/shadowmeld,if=variable.ambush_condition
                if S.Shadowmeld:IsReady() and Ambush_Condition then
                    return S.Shadowmeld:ID()
                end
            end
        end
    end
end

local function Build()
    -- actions.build=ghostly_strike,if=combo_points.deficit>=1+buff.broadsides.up&refreshable
    if S.GhostlyStrike:IsReady(S.SaberSlash)
            and Player:ComboPointsDeficit() >= (1 + (Player:BuffP(S.Broadsides) and 1 or 0)) and Target:DebuffRefreshableP(S.GhostlyStrike, 4.5) then
        return S.GhostlyStrike:ID()
    end
    -- actions.build+=/pistol_shot,if=combo_points.deficit>=1+buff.broadsides.up+talent.quick_draw.enabled&buff.opportunity.up&(energy.time_to_max>2-talent.quick_draw.enabled|(buff.greenskins_waterlogged_wristcuffs.up&(buff.blunderbuss.up|buff.greenskins_waterlogged_wristcuffs.remains<2)))
    if (S.PistolShot:IsReady(20) or S.Blunderbuss:IsReady(20))
            and Player:ComboPointsDeficit() >= (1 + (Player:BuffP(S.Broadsides) and 1 or 0) + (S.QuickDraw:IsAvailable() and 1 or 0))
            and Player:BuffP(S.Opportunity) and (EnergyTimeToMaxRounded() > (2 - (S.QuickDraw:IsAvailable() and 1 or 0))
            or (Player:BuffP(S.GreenskinsWaterloggedWristcuffs) and (S.Blunderbuss:IsReady() or Player:BuffRemainsP(S.GreenskinsWaterloggedWristcuffs) < 2))) then
        return 242277
    end
    -- actions.build+=/saber_slash,if=variable.ss_useable
    if S.SaberSlash:IsReady("Melee") and SS_Useable() then
        return S.SaberSlash:ID()
    end
end

local function Finish()
    -- # BTE in mantle used to be DPS neutral but is a loss due to t21
    -- actions.finish=between_the_eyes,if=equipped.greenskins_waterlogged_wristcuffs&!buff.greenskins_waterlogged_wristcuffs.up
    if S.BetweentheEyes:IsReady(20) and I.GreenskinsWaterloggedWristcuffs:IsEquipped() and not Player:BuffP(S.GreenskinsWaterloggedWristcuffs) then
        return S.BetweentheEyes:ID()
    end
    -- actions.finish+=/run_through,if=!talent.death_from_above.enabled|energy.time_to_max<cooldown.death_from_above.remains+3.5
    if S.RunThrough:IsReady("Melee") and (not S.DeathfromAbove:IsAvailable()
            or EnergyTimeToMaxRounded() < S.DeathfromAbove:CooldownRemainsP() + 3.5) then
        return S.RunThrough:ID()
    end
    -- OutofRange BtE
    if S.BetweentheEyes:IsReady(20) and not Target:IsInRange(10) then
        return S.BetweentheEyes:ID()
    end
end

-- APL Main
local function APL()
    -- Unit Update
    HL.GetEnemies(8); -- Cannonball Barrage
    HL.GetEnemies(S.RunThrough); -- Blade Flurry
    HL.GetEnemies(S.SaberSlash); -- Melee

    -- Defensives
    -- Crimson Vial
    if UnitName("player") == "Saberslash" and S.CrimsonVial:IsReady() and Player:HealthPercentage() <= 80 then
        return 20594
    end

    -- Out of Combat
    if not Player:AffectingCombat() then
        -- Stealth
        if not Player:Buff(S.VanishBuff) then

        end
        -- Flask
        -- Food
        -- Rune
        -- PrePot w/ Bossmod Countdown
        -- Opener
        if RubimRH.TargetIsValid() and Target:IsInRange(S.SaberSlash) then
            if Player:ComboPoints() >= 5 then
                if S.RunThrough:IsReady("Melee") then
                    return S.RunThrough:ID()
                end
            else
                -- actions.precombat+=/curse_of_the_dreadblades,if=combo_points.deficit>=4
                if RubimRH.CDsON() and S.CurseoftheDreadblades:IsReady() and Player:ComboPointsDeficit() >= 4 then
                    return S.CurseoftheDreadblades:ID()
                end
                if Player:IsStealthed(true, true) and S.Ambush:IsReady() then
                    return S.Ambush:ID()
                elseif S.SaberSlash:IsReady() then
                    return S.SaberSlash:ID()
                end
            end
        end
        return 0, 462338
    end

    -- In Combat
    -- MfD Sniping
    --MfDSniping(S.MarkedforDeath);
    if RubimRH.TargetIsValid() then
        -- Mythic Dungeon
        -- actions+=/call_action_list,name=bf
        if RubimRH.AoEON() and BladeFlurry() ~= nil then
            return BladeFlurry()
        end

        -- actions+=/call_action_list,name=cds
        if CDs() ~= nil then
            return CDs()
        end
        -- # Conditions are here to avoid worthless check if nothing is available
        -- actions+=/call_action_list,name=stealth,if=stealthed|cooldown.vanish.up|cooldown.shadowmeld.up
        if Player:IsStealthed(true, true) or S.Vanish:IsReady() or S.Shadowmeld:IsReady() then
            if Stealth() ~= nil then
                return Stealth()
            end
        end
        -- actions+=/death_from_above,if=energy.time_to_max>2&!variable.ss_useable_noreroll
        if S.DeathfromAbove:IsReady(15) and not SS_Useable_NoReroll() and EnergyTimeToMaxRounded() > 2 then
            return S.DeathfromAbove:ID()
        end
        -- Note: DfA execute time is 1.475s, the buff is modeled to lasts 1.475s on SimC, while it's 1s in-game. So we retrieve it from TimeSinceLastCast.
        if S.DeathfromAbove:TimeSinceLastCast() <= 1.325 then
            -- actions+=/sprint,if=equipped.thraxis_tricksy_treads&buff.death_from_above.up&buff.death_from_above.remains<=0.15
            if S.Sprint:IsReady() and I.ThraxisTricksyTreads:IsEquipped() then
                return S.Sprint:ID()
            end
            -- actions+=/adrenaline_rush,if=buff.death_from_above.up&buff.death_from_above.remains<=0.15
            if S.AdrenalineRush:IsReady() then
            end
        end
        if S.SliceandDice:IsAvailable() and S.SliceandDice:IsReady("Melee") then
            -- actions+=/slice_and_dice,if=!variable.ss_useable&buff.slice_and_dice.remains<target.time_to_die&buff.slice_and_dice.remains<(1+combo_points)*1.8&!buff.slice_and_dice.improved&!buff.loaded_dice.up
            -- Note: Added Player:BuffRemainsP(S.SliceandDice) == 0 to maintain the buff while TTD is invalid (it's mainly for Solo, not an issue in raids)
            if not SS_Useable() and (Target:FilteredTimeToDie(">", Player:BuffRemainsP(S.SliceandDice)) or Player:BuffRemainsP(S.SliceandDice) == 0)
                    and Player:BuffRemainsP(S.SliceandDice) < (1 + Player:ComboPoints()) * 1.8 and not ImprovedSliceAndDice() and not Player:Buff(S.LoadedDice) then
                return S.SliceandDice:ID()
            end
            -- actions+=/slice_and_dice,if=buff.loaded_dice.up&combo_points>=cp_max_spend&(!buff.slice_and_dice.improved|buff.slice_and_dice.remains<4)
            if Player:Buff(S.LoadedDice) and Player:ComboPoints() >= CPMaxSpend()
                    and (not ImprovedSliceAndDice() or Player:BuffRemainsP(S.SliceandDice) < 4) then
                return S.SliceandDice:ID()
            end
            -- actions+=/slice_and_dice,if=buff.slice_and_dice.improved&buff.slice_and_dice.remains<=2&combo_points>=2&!buff.loaded_dice.up
            if ImprovedSliceAndDice() and Player:BuffRemainsP(S.SliceandDice) <= 2 and Player:ComboPoints() >= 2 and not Player:Buff(S.LoadedDice) then
                return S.SliceandDice:ID()
            end
        end
        -- actions+=/roll_the_bones,if=!variable.ss_useable&(target.time_to_die>20|buff.roll_the_bones.remains<target.time_to_die)&(buff.roll_the_bones.remains<=3|variable.rtb_reroll)
        -- Note: Added RtB_BuffRemains() == 0 to maintain the buff while TTD is invalid (it's mainly for Solo, not an issue in raids)
        if S.RolltheBones:IsReady() and not SS_Useable() and (Target:FilteredTimeToDie(">", 20)
                or Target:FilteredTimeToDie(">", RtB_BuffRemains()) or RtB_BuffRemains() == 0) and (RtB_BuffRemains() <= 3 or RtB_Reroll()) then
            return S.RolltheBones:ID()
        end
        -- actions+=/killing_spree,if=energy.time_to_max>5|energy<15
        if RubimRH.CDsON() and S.KillingSpree:IsReady(10) and (EnergyTimeToMaxRounded() > 5 or Player:EnergyHeroLib() < 15) then
            return S.KillingSpree:ID()
        end
        -- actions+=/call_action_list,name=build
        if Build() ~= nil then
            return Build()
        end
        -- actions+=/call_action_list,name=finish,if=!variable.ss_useable
        if not SS_Useable() and Finish() ~= nil then
            return Finish()
        end
        -- # Gouge is used as a CP Generator while nothing else is available and you have Dirty Tricks talent. It's unlikely that you'll be able to do this optimally in-game since it requires to move in front of the target, but it's here so you can quantifiy its value.
        -- actions+=/gouge,if=talent.dirty_tricks.enabled&combo_points.deficit>=1
        if S.Gouge:IsReady(S.SaberSlash) and S.DirtyTricks:IsAvailable() and Player:ComboPointsDeficit() >= 1 then
            return S.Gouge:ID()
        end
        -- OutofRange Pistol Shot
        if not Target:IsInRange(10) and (S.PistolShot:IsReady(20) or S.Blunderbuss:IsReady(20)) and not Player:IsStealthed(true, true)
                and Player:EnergyDeficitHeroLib() < 25 and (Player:ComboPointsDeficit() >= 1 or EnergyTimeToMaxRounded() <= 1.2) then
            return 242277
        end
    end
    return 0, 975743
end
RubimRH.Rotation.SetAPL(260, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(260, PASSIVE);