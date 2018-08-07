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

--Survival
RubimRH.Spell[255] = {
    --Racials
    AMurderofCrows = Spell(131894),
    AncestralCall = Spell(274738),
    ArcaneTorrent = Spell(50613),
    AspectoftheTurtle = Spell(186265),
    AspectoftheEagle = Spell(186289),
    Berserking = Spell(26297),
    BerserkingBuff = Spell(26297),
    BloodFury = Spell(20572),
    BloodFuryBuff = Spell(20572),
    SephuzsSecretBuff = Spell(208052),
    Butchery = Spell(212436),
    Carve = Spell(187708),
    Chakrams = Spell(259391),
    CoordinatedAssault = Spell(266779),
    CoordinatedAssaultBuff = Spell(266779),
    Fireblood = Spell(265221),
    FlankingStrike = Spell(269751),
    Harpoon = Spell(190925),
    InternalBleedingDebuff = Spell(270343),
    KillCommand = Spell(259489),
    LightsJudgment = Spell(255647),
    MendPetBuff = Spell(136),
    MendPet = Spell(136),
    MongooseBite = Spell(259387),
    MongooseBiteEagle = Spell(265888),
    MongooseFuryBuff = Spell(190931),
    Muzzle = Spell(266779),
    RaptorStrike = Spell(186270),
    RaptorStrikeEagle = Spell(265189),
    SephuzsSecretBuff = Spell(208052),
    SerpentSting = Spell(259491),
    SerpentStingDebuff = Spell(259491),
    ShrapnelBombDebuff = Spell(270339),
    SteelTrap = Spell(162488),
    SteelTrapDebuff = Spell(162487),
    TermsofEngagement = Spell(265895),
    TipoftheSpearBuff = Spell(260286),
    VipersVenom = Spell(268501),
    VipersVenomBuff = Spell(268552),
    WildfireBomb = Spell(259495),
    WildfireBombDebuff = Spell(269747),
    WildfireInfusion = Spell(271014),
    SummonPet = Spell(9),
    Exhilaration = Spell(109304),
    -- PvP
    WingClip = Spell(195645),
};

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

local OffensiveCDs = {
    S.CoordinatedAssault,
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

local function APL ()
    local Precombat
    UpdateRanges()
    UpdateCDs()

    Precombat = function()
        -- flask
        -- augmentation
        -- food
        -- summon_pet
        if not Pet:IsActive() then
            return S.MendPet:Cast()
        end
        -- snapshot_stats
        -- potion
        --if I.ProlongedPower:IsReady() and RubimRH.PotionON() and (true) then
            --return I.ProlongedPower:Cast()
        --end
        -- steel_trap
        if RubimRH.TargetIsValid() then
            if S.SteelTrap:IsReady() and Player:DebuffDownP(S.SteelTrapDebuff) and (true) then
                return S.SteelTrap:Cast()
            end
            -- harpoon
            if S.Harpoon:IsReady() and Target:MaxDistanceToPlayer(true) >= 8 then
                return S.Harpoon:Cast()
            end
        end
        return 0, 462338
    end

    -- call precombat
    if not Player:AffectingCombat() then
        return Precombat()
    end

    if S.MendPet:CooldownUp() and Pet:IsActive() and Pet:HealthPercentage() > 0 and Pet:HealthPercentage() <= RubimRH.db.profile[255].mendpet and not Pet:Buff(S.MendPet) then
        return S.MendPet:Cast()
    end

    if S.Muzzle:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() and (I.SephuzsSecret:IsEquipped() and Target:IsCasting() and S.SephuzsSecretBuff:CooldownUpP() and not Player:BuffP(S.SephuzsSecretBuff)) then
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
    if (true) then
        VarCanGcd = num(not S.MongooseBite:IsAvailable() or Player:BuffDownP(S.MongooseFuryBuff) or (Player:BuffRemainsP(S.MongooseFuryBuff) - (((Player:BuffRemainsP(S.MongooseFuryBuff) * Player:FocusRegen() + Player:Focus()) / S.MongooseBite:Cost()) * Player:GCD()) > Player:GCD()))
    end
    -- steel_trap
    if S.SteelTrap:IsReady() and (true) then
        return S.SteelTrap:Cast()
    end
    -- a_murder_of_crows
    if S.AMurderofCrows:IsReady() and (true) then
        return S.AMurderofCrows:Cast()
    end
    -- coordinated_assault
    if S.CoordinatedAssault:IsReady() and (true) then
        return S.CoordinatedAssault:Cast()
    end
    -- chakrams,if=active_enemies>1
    if S.Chakrams:IsReady() and (Cache.EnemiesCount[8] > 1) then
        return S.Chakrams:Cast()
    end
    -- kill_command,target_if=min:bloodseeker.remains,if=focus+cast_regen<focus.max&buff.tip_of_the_spear.stack<3&active_enemies<2
    if S.KillCommand:IsReady() and (Player:Focus() + Player:FocusCastRegen(S.KillCommand:ExecuteTime()) < Player:FocusMax() and Player:BuffStackP(S.TipoftheSpearBuff) < 3 and Cache.EnemiesCount[8] < 2) then
        return S.KillCommand:Cast()
    end

    -- wildfire_bomb,if=(focus+cast_regen<focus.max|active_enemies>1)&(dot.wildfire_bomb.refreshable&buff.mongoose_fury.down|full_recharge_time<gcd)
    if S.WildfireBomb:IsReady() and ((Player:Focus() + Player:FocusCastRegen(S.WildfireBomb:ExecuteTime()) < Player:FocusMax() or Cache.EnemiesCount[8] > 1) and (Target:DebuffRefreshableCP(S.WildfireBombDebuff) and Player:BuffDownP(S.MongooseFuryBuff) or S.WildfireBomb:FullRechargeTimeP() < Player:GCD())) then
        return S.WildfireBomb:Cast()
    end
    -- kill_command,target_if=min:bloodseeker.remains,if=focus+cast_regen<focus.max&buff.tip_of_the_spear.stack<3
    if S.KillCommand:IsReady() and (Player:Focus() + Player:FocusCastRegen(S.KillCommand:ExecuteTime()) < Player:FocusMax() and Player:BuffStackP(S.TipoftheSpearBuff) < 3) then
        return S.KillCommand:Cast()
    end

    -- butchery,if=(!talent.wildfire_infusion.enabled|full_recharge_time<gcd)&active_enemies>3|(dot.shrapnel_bomb.ticking&dot.internal_bleeding.stack<3)
    if S.Butchery:IsReady() and ((not S.WildfireInfusion:IsAvailable() or S.Butchery:FullRechargeTimeP() < Player:GCD()) and Cache.EnemiesCount[8] > 3 or (Target:DebuffP(S.ShrapnelBombDebuff) and Target:DebuffStackP(S.InternalBleedingDebuff) < 3)) then
        return S.Butchery:Cast()
    end
    -- serpent_sting,if=(active_enemies<2&refreshable&(buff.mongoose_fury.down|(variable.can_gcd&!talent.vipers_venom.enabled)))|buff.vipers_venom.up
    if S.SerpentSting:IsReady() and ((Cache.EnemiesCount[8] < 2 and Target:DebuffRefreshableCP(S.SerpentStingDebuff) and (Player:BuffDownP(S.MongooseFuryBuff) or (bool(VarCanGcd) and not S.VipersVenom:IsAvailable()))) or Player:BuffP(S.VipersVenomBuff)) then
        return S.SerpentSting:Cast()
    end
    -- carve,if=active_enemies>2&(active_enemies<6&active_enemies+gcd<cooldown.wildfire_bomb.remains|5+gcd<cooldown.wildfire_bomb.remains)
    if S.Carve:IsReady() and (Cache.EnemiesCount[8] > 2 and (Cache.EnemiesCount[8] < 6 and Cache.EnemiesCount[8] + Player:GCD() < S.WildfireBomb:CooldownRemainsP() or 5 + Player:GCD() < S.WildfireBomb:CooldownRemainsP())) then
        return S.Carve:Cast()
    end
    -- harpoon,if=talent.terms_of_engagement.enabled
    if S.Harpoon:IsReady() and Target:MaxDistanceToPlayer(true) >= 8 and (S.TermsofEngagement:IsAvailable()) then
        return S.Harpoon:Cast()
    end
    -- flanking_strike
    if S.FlankingStrike:IsReady() and (true) then
        return S.FlankingStrike:Cast()
    end
    -- chakrams
    if S.Chakrams:IsReady() and (true) then
        return S.Chakrams:Cast()
    end
    -- serpent_sting,target_if=min:remains,if=refreshable&buff.mongoose_fury.down|buff.vipers_venom.up
    if S.SerpentSting:IsReady() and (Target:DebuffRefreshableCP(S.SerpentStingDebuff) and Player:BuffDownP(S.MongooseFuryBuff) or Player:BuffP(S.VipersVenomBuff)) then
        return S.SerpentSting:Cast()
    end
    -- aspect_of_the_eagle,if=target.distance>=6
    if S.AspectoftheEagle:IsReady() and (Target:MaxDistanceToPlayer(true) >= 6) then
        return S.AspectoftheEagle:Cast()
    end
    -- mongoose_bite_eagle,target_if=min:dot.internal_bleeding.stack,if=buff.mongoose_fury.up|focus>60
    if S.MongooseBiteEagle:IsReadyMorph() and (Player:BuffP(S.MongooseFuryBuff) or Player:Focus() > 60) then
        return S.MongooseBiteEagle:Cast()
    end
    -- mongoose_bite,target_if=min:dot.internal_bleeding.stack,if=buff.mongoose_fury.up|focus>60
    if S.MongooseBite:IsReady() and (Player:BuffP(S.MongooseFuryBuff) or Player:Focus() > 60) then
        return S.MongooseBite:Cast()
    end
    -- raptor_strike_eagle,target_if=min:dot.internal_bleeding.stack
    if S.RaptorStrikeEagle:IsReadyMorph() and (true) then
        return S.RaptorStrikeEagle:Cast()
    end
    -- raptor_strike,target_if=min:dot.internal_bleeding.stack
    if S.RaptorStrike:IsReady() and (true) then
        return S.RaptorStrike:Cast()
    end
    return 0, 135328
end

RubimRH.Rotation.SetAPL(255, APL);

local function PASSIVE()

    if S.AspectoftheTurtle:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[255].aspectoftheturtle then
        return S.AspectoftheTurtle:Cast()
    end

    if S.Exhilaration:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[255].exhilaration then
        return S.Exhilaration:Cast()
    end

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