--- Localize Vars
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
-- Spells

local S = RubimRH.Spell[255]

S.MongooseBite.TextureSpellID = { 224795 } -- Raptor Strikes
S.Butchery.TextureSpellID = { 203673 } -- Carve

-- Items
if not Item.Hunter then
    Item.Hunter = {}
end
Item.Hunter.Survival = {
    ProlongedPower = Item(142117),
    SephuzsSecret = Item(132452)
};

-- Variables
local VarCanGcd = 0;

local EnemyRanges = {8, 40}
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

local I = Item.Hunter.Survival;

--- APL Main
local function APL ()
    UpdateRanges()

    if not Player:AffectingCombat() then
        if RubimRH.TargetIsValid() then
            -- steel_trap
            if S.SteelTrap:IsReady() and Player:DebuffDownP(S.SteelTrapDebuff) then
                return S.SteelTrap:Cast()
            end
            -- harpoon
            if S.Harpoon:IsReady() then
                return S.Harpoon:Cast()
            end
        end
        return 0, 462338
    end
    if Pet:IsActive() and Pet:HealthPercentage() > 0 and Pet:HealthPercentage() <= RubimRH.db.profile[255].mendpet and not Pet:Buff(S.MendPet) then
        return S.MendPet:Cast()
    end

    if S.AspectoftheTurtle:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[255].aspectoftheturtle then
        S.AspectoftheTurtle:Cast()
    end

    if S.Muzzle:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() and (I.SephuzsSecret:IsEquipped() and Target:IsCasting() and S.BuffSephuzsSecret:CooldownUpP() and not Player:BuffP(S.SephuzsSecretBuff)) then
        return S.Muzzle:Cast()
    end
    -- use_items
    -- berserking,if=cooldown.coordinated_assault.remains>30
    if S.Berserking:IsReady() and RubimRH.RacialON() and (S.CoordinatedAssault:CooldownRemainsP() > 30) then
        return S.Berserking:Cast()
    end
    -- blood_fury,if=cooldown.coordinated_assault.remains>30
    if S.BloodFury:IsReady() and RubimRH.RacialON() and (S.CoordinatedAssault:CooldownRemainsP() > 30) then
        return S.BloodFury:Cast()
    end
    -- ancestral_call,if=cooldown.coordinated_assault.remains>30
    if S.AncestralCall:IsReady() and RubimRH.RacialON() and (S.CoordinatedAssault:CooldownRemainsP() > 30) then
        return S.AncestralCall:Cast()
    end
    -- fireblood,if=cooldown.coordinated_assault.remains>30
    if S.Fireblood:IsReady() and RubimRH.RacialON() and (S.CoordinatedAssault:CooldownRemainsP() > 30) then
        return S.Fireblood:Cast()
    end
    -- lights_judgment
    if S.LightsJudgment:IsReady() and RubimRH.RacialON() and RubimRH.CDsON() and (true) then
        return S.LightsJudgment:Cast()
    end
    -- arcane_torrent,if=cooldown.kill_command.remains>gcd.max&focus<=30
    if S.ArcaneTorrent:IsReady() and RubimRH.RacialON() and RubimRH.CDsON() and (S.KillCommand:CooldownRemainsP() > Player:GCD() and Player:Focus() <= 30) then
        return S.ArcaneTorrent:Cast()
    end
    -- potion,if=buff.coordinated_assault.up&(buff.berserking.up|buff.blood_fury.up|!race.troll&!race.orc)
    --if I.ProlongedPower:IsReady() and RubimRH.PotionON() and (Player:BuffP(S.CoordinatedAssaultBuff) and (Player:BuffP(S.BerserkingBuff) or Player:BuffP(S.BloodFuryBuff) or not Player:IsRace("Troll") and not Player:IsRace("Orc"))) then
        --return I.ProlongedPower:Cast()
    --end
    -- variable,name=can_gcd,value=!talent.mongoose_bite.enabled|buff.mongoose_fury.down|(buff.mongoose_fury.remains-(((buff.mongoose_fury.remains*focus.regen+focus)%action.mongoose_bite.cost)*gcd.max)>gcd.max)
    VarCanGcd = num(not S.MongooseBite:IsAvailable() or Player:BuffDownP(S.MongooseFury) or (Player:BuffRemainsP(S.MongooseFury) - (((Player:BuffRemainsP(S.MongooseFury) * Player:FocusRegen() + Player:Focus()) / S.MongooseBite:Cost()) * Player:GCD()) > Player:GCD()))
    -- steel_trap
    if S.SteelTrap:IsReady() then
        return S.SteelTrap:Cast()
    end
    -- a_murder_of_crows
    if S.AMurderofCrows:IsReady() then
        return S.AMurderofCrows:Cast()
    end
    -- coordinated_assault
    if S.CoordinatedAssault:IsReady() and RubimRH.CDsON() then
        return S.CoordinatedAssault:Cast()
    end
    -- chakrams,if=active_enemies>1
    if S.Chakrams:IsReady() and RubimRH.AoEON() and (Cache.EnemiesCount[40] > 1) then
        return S.Chakrams:Cast()
    end
    -- kill_command,target_if=min:bloodseeker.remains,if=focus+cast_regen<focus.max&buff.tip_of_the_spear.stack<3&active_enemies<2
    if S.KillCommand:IsReady() and Pet:IsActive() and Pet:HealthPercentage() > 0 and (Player:Focus() + Player:FocusCastRegen(S.KillCommand:ExecuteTime()) < Player:FocusMax() and Player:BuffStackP(S.TipoftheSpearBuff) < 3 and Cache.EnemiesCount[40] < 2) then
        return S.KillCommand:Cast()
    end
    -- wildfire_bomb,if=(focus+cast_regen<focus.max|active_enemies>1)&(dot.wildfire_bomb.refreshable&buff.mongoose_fury.down|full_recharge_time<gcd)
    if S.WildfireBomb:IsReady() and ((Player:Focus() + Player:FocusCastRegen(S.WildfireBomb:ExecuteTime()) < Player:FocusMax() or Cache.EnemiesCount[40] > 1) and (Target:DebuffRefreshableCP(S.WildfireBombDebuff) and Player:BuffDownP(S.MongooseFury) or S.WildfireBomb:FullRechargeTimeP() < Player:GCD())) then
        return S.WildfireBomb:Cast()
    end
    -- kill_command,target_if=min:bloodseeker.remains,if=focus+cast_regen<focus.max&buff.tip_of_the_spear.stack<3
    if S.KillCommand:IsReady() and Pet:IsActive() and Pet:HealthPercentage() > 0 and (Player:Focus() + Player:FocusCastRegen(S.KillCommand:ExecuteTime()) < Player:FocusMax() and Player:BuffStackP(S.TipoftheSpearBuff) < 3) then
        return S.KillCommand:Cast()
    end
    -- butchery,if=(!talent.wildfire_infusion.enabled|full_recharge_time<gcd)&active_enemies>3|(dot.shrapnel_bomb.ticking&dot.internal_bleeding.stack<3)
    if S.Butchery:IsReady() and ((not S.WildfireInfusion:IsAvailable() or S.Butchery:FullRechargeTimeP() < Player:GCD()) and Cache.EnemiesCount[40] > 3 or (Target:DebuffP(S.ShrapnelBombDebuff) and Target:DebuffStackP(S.InternalBleeding) < 3)) then
        return S.Butchery:Cast()
    end
    -- serpent_sting,if=(active_enemies<2&refreshable&(buff.mongoose_fury.down|(variable.can_gcd&!talent.vipers_venom.enabled)))|buff.vipers_venom.up
    if S.SerpentSting:IsReady() and ((Cache.EnemiesCount[40] < 2 and Target:DebuffRefreshableCP(S.SerpentSting) and (Player:BuffDownP(S.MongooseFury) or (bool(VarCanGcd) and not S.VipersVenom:IsAvailable()))) or Player:BuffP(S.VipersVenomBuff)) then
        return S.SerpentSting:Cast()
    end
    -- carve,if=active_enemies>2&(active_enemies<6&active_enemies+gcd<cooldown.wildfire_bomb.remains|5+gcd<cooldown.wildfire_bomb.remains)
    if S.Carve:IsReady() and RubimRH.AoEON() and (Cache.EnemiesCount[8] > 2 and (Cache.EnemiesCount[8] < 6 and Cache.EnemiesCount[8] + Player:GCD() < S.WildfireBomb:CooldownRemainsP() or 5 + Player:GCD() < S.WildfireBomb:CooldownRemainsP())) then
        return S.Carve:Cast()
    end
    -- harpoon,if=talent.terms_of_engagement.enabled
    if S.Harpoon:IsReady() and (S.TermsofEngagement:IsAvailable()) then
        return S.Harpoon:Cast()
    end
    -- flanking_strike
    if S.FlankingStrike:IsReady() then
        return S.FlankingStrike:Cast()
    end
    -- chakrams
    if S.Chakrams:IsReady() then
        return S.Chakrams:Cast()
    end
    -- serpent_sting,target_if=min:remains,if=refreshable&buff.mongoose_fury.down|buff.vipers_venom.up
    if S.SerpentSting:IsReady() and (Target:DebuffRefreshableCP(S.SerpentSting) and Player:BuffDownP(S.MongooseFury) or Player:BuffP(S.VipersVenomBuff)) then
        return S.SerpentSting:Cast()
    end
    -- aspect_of_the_eagle,if=target.distance>=6
    if S.AspectoftheEagle:IsReady() and (Cache.EnemiesCount[6] == 0) then
        return S.AspectoftheEagle:Cast()
    end
    -- mongoose_bite_eagle,target_if=min:dot.internal_bleeding.stack,if=buff.mongoose_fury.up|focus>60
    if S.MongooseBiteEagle:IsReadyMorph() and (Player:BuffP(S.MongooseFury) or Player:Focus() > 60) then
        return S.MongooseBite:Cast()
    end
    -- mongoose_bite,target_if=min:dot.internal_bleeding.stack,if=buff.mongoose_fury.up|focus>60
    if S.MongooseBite:IsReady("Melee") and (Player:BuffP(S.MongooseFury) or Player:Focus() > 60) then
        return S.MongooseBite:Cast()
    end
    -- raptor_strike_eagle,target_if=min:dot.internal_bleeding.stack
    if S.RaptorStrikeEagle:IsReadyMorph() then
        return S.RaptorStrike:Cast()
    end
    -- raptor_strike,target_if=min:dot.internal_bleeding.stack
    if S.RaptorStrike:IsReady("Melee") then
        return S.RaptorStrike:Cast()
    end
    return 0, 135328
end

RubimRH.Rotation.SetAPL(255, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(255, PASSIVE);
--- Last Update: 07/17/2018

-- # Executed before combat begins. Accepts non-harmful actions only.
-- actions.precombat=flask
-- actions.precombat+=/augmentation
-- actions.precombat+=/food
-- actions.precombat+=/summon_pet
-- # Snapshot raid buffed stats before combat begins and pre-potting is done.
-- actions.precombat+=/snapshot_stats
-- actions.precombat+=/potion
-- actions.precombat+=/aspect_of_the_wild

-- # Executed every time the actor is available.
-- actions=auto_shot
-- actions+=/counter_shot,if=equipped.sephuzs_secret&target.debuff.casting.react&cooldown.buff_sephuzs_secret.up&!buff.sephuzs_secret.up
-- actions+=/use_items
-- actions+=/berserking,if=cooldown.bestial_wrath.remains>30
-- actions+=/blood_fury,if=cooldown.bestial_wrath.remains>30
-- actions+=/ancestral_call,if=cooldown.bestial_wrath.remains>30
-- actions+=/fireblood,if=cooldown.bestial_wrath.remains>30
-- actions+=/lights_judgment
-- actions+=/potion,if=buff.bestial_wrath.up&buff.aspect_of_the_wild.up
-- actions+=/barbed_shot,if=pet.cat.buff.frenzy.up&pet.cat.buff.frenzy.remains<=gcd.max
-- actions+=/a_murder_of_crows
-- actions+=/spitting_cobra
-- actions+=/stampede,if=buff.bestial_wrath.up|cooldown.bestial_wrath.remains<gcd|target.time_to_die<15
-- actions+=/aspect_of_the_wild
-- actions+=/bestial_wrath,if=!buff.bestial_wrath.up
-- actions+=/multishot,if=spell_targets>2&(pet.cat.buff.beast_cleave.remains<gcd.max|pet.cat.buff.beast_cleave.down)
-- actions+=/chimaera_shot
-- actions+=/kill_command
-- actions+=/dire_beast
-- actions+=/barbed_shot,if=pet.cat.buff.frenzy.down&charges_fractional>1.4|full_recharge_time<gcd.max|target.time_to_die<9
-- actions+=/barrage
-- actions+=/multishot,if=spell_targets>1&(pet.cat.buff.beast_cleave.remains<gcd.max|pet.cat.buff.beast_cleave.down)
-- actions+=/cobra_shot,if=(active_enemies<2|cooldown.kill_command.remains>focus.time_to_max)&(buff.bestial_wrath.up&active_enemies>1|cooldown.kill_command.remains>1+gcd&cooldown.bestial_wrath.remains>focus.time_to_max|focus-cost+focus.regen*(cooldown.kill_command.remains-1)>action.kill_command.cost)