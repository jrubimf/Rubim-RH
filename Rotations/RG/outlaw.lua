--- Localize Vars
-- Addon
local addonName, addonTable = ...;
-- AethysCore
local AC = AethysCore;
local Cache = AethysCache;
local Unit = AC.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = AC.Spell;
local Item = AC.Item;
-- Lua
local pairs = pairs;
local tableconcat = table.concat;
local tostring = tostring;

-- Spells
if not Spell.Rogue then Spell.Rogue = {}; end
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
};
local S = Spell.Rogue.Outlaw;
-- Choose a persistent PistolShot icon to avoid Blunderbuss icon
S.PistolShot.TextureSpellID = 242277;
-- Items
if not Item.Rogue then Item.Rogue = {}; end
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

local function CPMaxSpend ()
    -- Should work for all 3 specs since they have same Deeper Stratagem Spell ID.
    return Spell.Rogue.Subtlety.DeeperStratagem:IsAvailable() and 6 or 5;
end

-- "cp_spend"
local function CPSpend ()
    return mathmin(Player:ComboPoints(), CPMaxSpend());
end

-- mantle_duration
--[[ Original SimC Code
  if ( buffs.mantle_of_the_master_assassin_aura -> check() )
  {
    timespan_t nominal_master_assassin_duration = timespan_t::from_seconds( spell.master_assassins_initiative -> effectN( 1 ).base_value() );
    timespan_t gcd_remains = timespan_t::from_seconds( std::max( ( gcd_ready - sim -> current_time() ).total_seconds(), 0.0 ) );
    return gcd_remains + nominal_master_assassin_duration;
  }
  else if ( buffs.mantle_of_the_master_assassin -> check() )
    return buffs.mantle_of_the_master_assassin -> remains();
  else
    return timespan_t::from_seconds( 0.0 );
]]
local MasterAssassinsInitiative, NominalDuration = Spell(235027), 6;
local function MantleDuration ()
    if Player:BuffRemains(MasterAssassinsInitiative) < 0 then
        return Player:GCDRemains() + NominalDuration;
    else
        return Player:BuffRemainsP(MasterAssassinsInitiative);
    end
end


-- Rotation Var
local RTIdentifier, SSIdentifier = tostring(S.RunThrough:ID()), tostring(S.SaberSlash:ID());
local BFTimer, BFReset = 0, nil; -- Blade Flurry Expiration Offset

-- APL Action Lists (and Variables)
local RtB_BuffsList = {
    S.Broadsides,
    S.BuriedTreasure,
    S.GrandMelee,
    S.JollyRoger,
    S.SharkInfestedWaters,
    S.TrueBearing
};
local function RtB_List(Type, List)
    if not Cache.APLVar.RtB_List then Cache.APLVar.RtB_List = {}; end
    if not Cache.APLVar.RtB_List[Type] then Cache.APLVar.RtB_List[Type] = {}; end
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
                    break;
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
                break;
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
    if not Cache.APLVar.RtB_Reroll then
        Cache.APLVar.RtB_Reroll = (not S.SliceandDice:IsAvailable() and Player:BuffP(S.LoadedDice) and
                (RtB_Buffs() < 2 or (RtB_Buffs() < 4 and not Player:BuffP(S.TrueBearing)))) and true or false;
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
    return math.floor(Player:EnergyTimeToMaxPredicted() * 10 + 0.5) / 10;
end

local function BladeFlurry()
    -- Blade Flurry Expiration Offset
    if Cache.EnemiesCount[RTIdentifier] == 1 and BFReset then
        BFTimer, BFReset = AC.GetTime(), false;
    elseif Cache.EnemiesCount[RTIdentifier] > 1 then
        BFReset = true;
    end

    if Player:Buff(S.BladeFlurry) then
        -- actions.bf=cancel_buff,name=blade_flurry,if=spell_targets.blade_flurry<2&buff.blade_flurry.up
        if Cache.EnemiesCount[RTIdentifier] < 2 and AC.GetTime() > BFTimer then
            SetNextAbility(S.BladeFlurry2:ID())
            return
        end
        -- actions.bf+=/cancel_buff,name=blade_flurry,if=equipped.shivarran_symmetry&cooldown.blade_flurry.up&buff.blade_flurry.up&spell_targets.blade_flurry>=2
        if I.ShivarranSymmetry:IsEquipped() and S.BladeFlurry:CooldownUp() and Cache.EnemiesCount[RTIdentifier] >= 2 then
            SetNextAbility(S.BladeFlurry2:ID())
            return
        end
    else
        -- actions.bf+=/blade_flurry,if=spell_targets.blade_flurry>=2&!buff.blade_flurry.up
        if S.BladeFlurry:IsCastable() and Cache.EnemiesCount[RTIdentifier] >= 2 then
            SetNextAbility(S.BladeFlurry:ID())
            return
        end
    end
end

local function CDs()
    if CDsON() then
        -- actions.cds=potion,if=buff.bloodlust.react|target.time_to_die<=60|buff.adrenaline_rush.up
        -- TODO: Add Potion
        -- actions.cds+=/use_item,if=buff.bloodlust.react|target.time_to_die<=20|combo_points.deficit<=2
        -- TODO: Add Items
        -- actions.cds+=/cannonball_barrage,if=spell_targets.cannonball_barrage>=1
        if AoEON() and S.CannonballBarrage:IsCastable() and Cache.EnemiesCount[8] >= 1 then
            SetNextAbility(S.CannonballBarrage:ID())
            return
        end
    end
    if Target:IsInRange(S.SaberSlash) then
        if CDsON() then
            -- actions.cds+=/blood_fury
            if S.BloodFury:IsCastable() then
                SetNextAbility(S.BloodFury:ID())
                return
            end
            -- actions.cds+=/berserking
            if S.Berserking:IsCastable() then
                SetNextAbility(S.Berserking:ID())
                return
            end
            -- actions.cds+=/arcane_torrent,if=energy.deficit>40
            if S.ArcaneTorrent:IsCastable() and Player:EnergyDeficitPredicted() > 40 then
                SetNextAbility(S.ArcaneTorrent:ID())
                return
            end
            -- actions.cds+=/adrenaline_rush,if=!buff.adrenaline_rush.up&energy.deficit>0
            if S.AdrenalineRush:IsCastable() and not Player:BuffP(S.AdrenalineRush) and Player:EnergyDeficitPredicted() > 0 then
                SetNextAbility(S.AdrenalineRush:ID())
                return
            end
        end
        -- actions.cds+=/marked_for_death,target_if=min:target.time_to_die,if=target.time_to_die<combo_points.deficit|((raid_event.adds.in>40|buff.true_bearing.remains>15-buff.adrenaline_rush.up*5)&!stealthed.rogue&combo_points.deficit>=cp_max_spend-1)
        if S.MarkedforDeath:IsCastable() then
            -- Note: Increased the SimC condition by 50% since we are slower.
            if Target:FilteredTimeToDie("<", Player:ComboPointsDeficit() * 1.5) or (Target:FilteredTimeToDie("<", 2) and Player:ComboPointsDeficit() > 0)
                    or (((Cache.EnemiesCount[30] == 1 and Player:BuffRemainsP(S.TrueBearing) > 15 - (Player:BuffP(S.AdrenalineRush) and 5 or 0))
                    or Target:IsDummy()) and not Player:IsStealthed(true, true) and Player:ComboPointsDeficit() >= CPMaxSpend() - 1) then
                SetNextAbility(S.MarkedforDeath:ID())
                return
            elseif not Player:IsStealthed(true, true) and Player:ComboPointsDeficit() >= CPMaxSpend() - 1 then
                SetNextAbility(S.MarkedforDeath:ID())
                return
            end
        end
        if CDsON() then
            if I.ThraxisTricksyTreads:IsEquipped() and not SS_Useable() then
                -- actions.cds+=/sprint,if=!talent.death_from_above.enabled&equipped.thraxis_tricksy_treads&!variable.ss_useable
                if S.Sprint:IsCastable() and not S.DeathfromAbove:IsAvailable() then
                    SetNextAbility(S.Sprint:ID())
                end
                -- actions.cds+=/darkflight,if=equipped.thraxis_tricksy_treads&!variable.ss_useable&buff.sprint.down
                if S.Darkflight:IsCastable() and not Player:BuffP(S.Sprint) then
                    SetNextAbility(S.Darkflight:ID())
                end
            end
            -- actions.cds+=/curse_of_the_dreadblades,if=combo_points.deficit>=4&(buff.true_bearing.up|buff.adrenaline_rush.up|time_to_die<20)
            if S.CurseoftheDreadblades:IsCastable() and Player:ComboPointsDeficit() >= 4 and
                    (Player:BuffP(S.TrueBearing) or Player:BuffP(S.AdrenalineRush) or Target:FilteredTimeToDie("<", 20)) then
                SetNextAbility(S.CurseoftheDreadblades:ID())
                return
            end
        end
    end
end

local function Stealth()
    if Target:IsInRange(S.SaberSlash) then
        -- actions.stealth=variable,name=ambush_condition,value=combo_points.deficit>=2+2*(talent.ghostly_strike.enabled&!debuff.ghostly_strike.up)+buff.broadsides.up&energy>60&!buff.jolly_roger.up&!buff.hidden_blade.up
        local Ambush_Condition = (Player:ComboPointsDeficit() >= 2 + 2 * ((S.GhostlyStrike:IsAvailable() and not Target:Debuff(S.GhostlyStrike)) and 1 or 0)
                + (Player:Buff(S.Broadsides) and 1 or 0) and Player:EnergyPredicted() > 60 and not Player:Buff(S.JollyRoger) and not Player:Buff(S.HiddenBlade)) and true or false;
        -- actions.stealth+=/ambush,if=variable.ambush_condition
        if Player:IsStealthed(true, true) and S.Ambush:IsCastable() and Ambush_Condition then
            SetNextAbility(S.Ambush:ID())
            return
        else
            if CDsON() and not Player:IsTanking(Target) then
                -- actions.stealth+=/vanish,if=(variable.ambush_condition|equipped.mantle_of_the_master_assassin&!variable.rtb_reroll&!variable.ss_useable)&mantle_duration=0
                if S.Vanish:IsCastable() and (Ambush_Condition or (I.MantleoftheMasterAssassin:IsEquipped() and not RtB_Reroll() and not SS_Useable()))
                        and MantleDuration() == 0 then
                    SetNextAbility(S.Vanish:ID())
                    return
                end
                -- actions.stealth+=/shadowmeld,if=variable.ambush_condition
                if S.Shadowmeld:IsCastable() and Ambush_Condition then
                    SetNextAbility(S.Shadowmeld:ID())
                    return
                end
            end
        end
    end
end

local function Build()
    -- actions.build=ghostly_strike,if=combo_points.deficit>=1+buff.broadsides.up&refreshable
    if S.GhostlyStrike:IsCastable(S.SaberSlash)
            and Player:ComboPointsDeficit() >= (1 + (Player:BuffP(S.Broadsides) and 1 or 0)) and Target:DebuffRefreshableP(S.GhostlyStrike, 4.5) then
        SetNextAbility(S.GhostlyStrike:ID())
        return
    end
    -- actions.build+=/pistol_shot,if=combo_points.deficit>=1+buff.broadsides.up+talent.quick_draw.enabled&buff.opportunity.up&(energy.time_to_max>2-talent.quick_draw.enabled|(buff.greenskins_waterlogged_wristcuffs.up&(buff.blunderbuss.up|buff.greenskins_waterlogged_wristcuffs.remains<2)))
    if (S.PistolShot:IsCastable(20) or S.Blunderbuss:IsCastable(20))
            and Player:ComboPointsDeficit() >= (1 + (Player:BuffP(S.Broadsides) and 1 or 0) + (S.QuickDraw:IsAvailable() and 1 or 0))
            and Player:BuffP(S.Opportunity) and (EnergyTimeToMaxRounded() > (2 - (S.QuickDraw:IsAvailable() and 1 or 0))
            or (Player:BuffP(S.GreenskinsWaterloggedWristcuffs) and (S.Blunderbuss:IsCastable() or Player:BuffRemainsP(S.GreenskinsWaterloggedWristcuffs) < 2))) then
        SetNextAbility(S.PistolShot:ID())
        return
    end
    -- actions.build+=/saber_slash,if=variable.ss_useable
    if S.SaberSlash:IsCastable(S.SaberSlash) and SS_Useable() then
        SetNextAbility(S.SaberSlash:ID())
        return
    end
end

local function Finish()
    -- # BTE in mantle used to be DPS neutral but is a loss due to t21
    -- actions.finish=between_the_eyes,if=equipped.greenskins_waterlogged_wristcuffs&!buff.greenskins_waterlogged_wristcuffs.up
    if S.BetweentheEyes:IsCastable(20) and I.GreenskinsWaterloggedWristcuffs:IsEquipped() and not Player:BuffP(S.GreenskinsWaterloggedWristcuffs) then
        SetNextAbility(S.BetweentheEyes:ID())
        return
    end
    -- actions.finish+=/run_through,if=!talent.death_from_above.enabled|energy.time_to_max<cooldown.death_from_above.remains+3.5
    if S.RunThrough:IsCastable(S.RunThrough) and (not S.DeathfromAbove:IsAvailable()
            or EnergyTimeToMaxRounded() < S.DeathfromAbove:CooldownRemainsP() + 3.5) then
        SetNextAbility(S.RunThrough:ID())
        return
    end
    -- OutofRange BtE
    if S.BetweentheEyes:IsCastable(20) and not Target:IsInRange(10) then
        SetNextAbility(S.BetweentheEyes:ID())
        return
    end
end

-- APL Main
function OutlawRotation()
    -- Unit Update
    AC.GetEnemies(8); -- Cannonball Barrage
    AC.GetEnemies(S.RunThrough); -- Blade Flurry
    AC.GetEnemies(S.SaberSlash); -- Melee

    -- Out of Combat
    if not Player:AffectingCombat() then
        SetNextAbility("146250")
        -- Stealth
        -- Flask
        -- Food
        -- Rune
        -- PrePot w/ Bossmod Countdown
        -- Opener
        if TargetIsValid() and Target:IsInRange(S.SaberSlash) then
            if Player:ComboPoints() >= 5 then
                if S.RunThrough:IsCastable() then
                    SetNextAbility(S.RunThrough:ID())
                    return
                end
            else
                -- actions.precombat+=/curse_of_the_dreadblades,if=combo_points.deficit>=4
                if CDsON() and S.CurseoftheDreadblades:IsCastable() and Player:ComboPointsDeficit() >= 4 then
                    SetNextAbility(S.CurseoftheDreadblades:ID())
                    return
                end
            end
            if Player:IsStealthed(true, true) and S.Ambush:IsCastable() then
                SetNextAbility(S.Ambush:ID())
                return
            elseif S.SaberSlash:IsCastable() then
                SetNextAbility(S.SaberSlash:ID())
                return
            end
        end
    end
    SetNextAbility("233159")

    if TargetIsValid() then
        -- actions+=/call_action_list,name=bf
        BladeFlurry();
        if GetNextAbility() ~= "233159" then
            return
        end

        -- actions+=/call_action_list,name=cds
        CDs();
        if GetNextAbility() ~= "233159" then
            return
        end
        -- # Conditions are here to avoid worthless check if nothing is available
        -- actions+=/call_action_list,name=stealth,if=stealthed|cooldown.vanish.up|cooldown.shadowmeld.up
        if Player:IsStealthed(true, true) or S.Vanish:IsCastable() or S.Shadowmeld:IsCastable() then
            Stealth();
            if GetNextAbility() ~= "233159" then
                return
            end
        end
        -- actions+=/death_from_above,if=energy.time_to_max>2&!variable.ss_useable_noreroll
        if S.DeathfromAbove:IsCastable(15) and not SS_Useable_NoReroll() and EnergyTimeToMaxRounded() > 2 then
            SetNextAbility(S.DeathfromAbove:ID())
            return
        end
        -- Note: DfA execute time is 1.475s, the buff is modeled to lasts 1.475s on SimC, while it's 1s in-game. So we retrieve it from TimeSinceLastCast.
        if S.DeathfromAbove:TimeSinceLastCast() <= 1.325 then
            -- actions+=/sprint,if=equipped.thraxis_tricksy_treads&buff.death_from_above.up&buff.death_from_above.remains<=0.15
            if S.Sprint:IsCastable() and I.ThraxisTricksyTreads:IsEquipped() then
                SetNextAbility(S.Sprint:ID())
                return
            end
        end
        -- actions+=/adrenaline_rush,if=buff.death_from_above.up&buff.death_from_above.remains<=0.15
        if S.AdrenalineRush:IsCastable() then
            SetNextAbility(S.AdrenalineRush:ID())
            return
        end


        if S.SliceandDice:IsAvailable() and S.SliceandDice:IsCastable() then
            -- actions+=/slice_and_dice,if=!variable.ss_useable&buff.slice_and_dice.remains<target.time_to_die&buff.slice_and_dice.remains<(1+combo_points)*1.8&!buff.slice_and_dice.improved&!buff.loaded_dice.up
            -- Note: Added Player:BuffRemainsP(S.SliceandDice) == 0 to maintain the buff while TTD is invalid (it's mainly for Solo, not an issue in raids)
            if not SS_Useable() and (Target:FilteredTimeToDie(">", Player:BuffRemainsP(S.SliceandDice)) or Player:BuffRemainsP(S.SliceandDice) == 0)
                    and Player:BuffRemainsP(S.SliceandDice) < (1 + Player:ComboPoints()) * 1.8 and not ImprovedSliceAndDice() and not Player:Buff(S.LoadedDice) then
                SetNextAbility(S.SliceandDice:ID())
                return
            end
            -- actions+=/slice_and_dice,if=buff.loaded_dice.up&combo_points>=cp_max_spend&(!buff.slice_and_dice.improved|buff.slice_and_dice.remains<4)
            if Player:Buff(S.LoadedDice) and Player:ComboPoints() >= CPMaxSpend()
                    and (not ImprovedSliceAndDice() or Player:BuffRemainsP(S.SliceandDice) < 4) then
                SetNextAbility(S.SliceandDice:ID())
                return
            end
            -- actions+=/slice_and_dice,if=buff.slice_and_dice.improved&buff.slice_and_dice.remains<=2&combo_points>=2&!buff.loaded_dice.up
            if ImprovedSliceAndDice() and Player:BuffRemainsP(S.SliceandDice) <= 2 and Player:ComboPoints() >= 2 and not Player:Buff(S.LoadedDice) then
                SetNextAbility(S.SliceandDice:ID())
                return
            end
        end
        -- actions+=/roll_the_bones,if=!variable.ss_useable&(target.time_to_die>20|buff.roll_the_bones.remains<target.time_to_die)&(buff.roll_the_bones.remains<=3|variable.rtb_reroll)
        -- Note: Added RtB_BuffRemains() == 0 to maintain the buff while TTD is invalid (it's mainly for Solo, not an issue in raids)
        if S.RolltheBones:IsCastable() and not SS_Useable() and (Target:FilteredTimeToDie(">", 20)
                or Target:FilteredTimeToDie(">", RtB_BuffRemains()) or RtB_BuffRemains() == 0) and (RtB_BuffRemains() <= 3 or RtB_Reroll()) then
            SetNextAbility(S.RolltheBones:ID())
            return
        end
        -- actions+=/killing_spree,if=energy.time_to_max>5|energy<15
        if CDsON() and S.KillingSpree:IsCastable(10) and (EnergyTimeToMaxRounded() > 5 or Player:EnergyPredicted() < 15) then
            SetNextAbility(S.KillingSpree:ID())
            return
        end
        -- actions+=/call_action_list,name=build
        ShouldReturn = Build();
        if ShouldReturn then return "Build: " .. ShouldReturn;
        end
        -- actions+=/call_action_list,name=finish,if=!variable.ss_useable
        if not SS_Useable() then
            ShouldReturn = Finish();
            if ShouldReturn then return "Finish: " .. ShouldReturn;
            end
        end
        -- # Gouge is used as a CP Generator while nothing else is available and you have Dirty Tricks talent. It's unlikely that you'll be able to do this optimally in-game since it requires to move in front of the target, but it's here so you can quantifiy its value.
        -- actions+=/gouge,if=talent.dirty_tricks.enabled&combo_points.deficit>=1
        -- OutofRange Pistol Shot
        if not Target:IsInRange(10) and (S.PistolShot:IsCastable(20) or S.Blunderbuss:IsCastable(20)) and not Player:IsStealthed(true, true)
                and Player:EnergyDeficitPredicted() < 25 and (Player:ComboPointsDeficit() >= 1 or EnergyTimeToMaxRounded() <= 1.2) then
            SetNextAbility(S.PistolShot:ID())
            return
        end
    end
end