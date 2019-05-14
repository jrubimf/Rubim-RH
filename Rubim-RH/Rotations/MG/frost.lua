local mainAddon = RubimRH

--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
-- HeroLib
local HL = HeroLib
local Cache = HeroCache
local Unit = HL.Unit
local Player = Unit.Player
local Target = Unit.Target
local Pet = Unit.Pet
local Spell = HL.Spell
local Item = HL.Item

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
RubimRH.Spell[MFrost] = {
    ArcaneIntellectBuff = Spell(1459),
    ArcaneIntellect = Spell(1459),
    WaterElemental = Spell(31687),
    MirrorImage = Spell(55342),
    Frostbolt = Spell(116),
    FrozenOrb = Spell(84714),
    Blizzard = Spell(190356),
    CometStorm = Spell(153595),
    IceNova = Spell(157997),
    Flurry = Spell(44614),
    Ebonbolt = Spell(257537),
    BrainFreezeBuff = Spell(190446),
    IciclesBuff = Spell(205473),
    GlacialSpike = Spell(199786),
    IceLance = Spell(30455),
    FingersofFrostBuff = Spell(44544),
    RayofFrost = Spell(205021),
    ConeofCold = Spell(120),
    IcyVeins = Spell(12472),
    RuneofPower = Spell(116011),
    RuneofPowerBuff = Spell(116014),
    BloodFury = Spell(20572),
    Berserking = Spell(26297),
    LightsJudgment = Spell(255647),
    Fireblood = Spell(265221),
    AncestralCall = Spell(274738),
    Blink = Spell(1953),
    IceFloes = Spell(108839),
    IceFloesBuff = Spell(108839),
    WintersChillDebuff = Spell(228358),
    GlacialSpikeBuff = Spell(199844),
    SplittingIce = Spell(56377),
    WintersReach = Spell(273346),
    WintersReachBuff = Spell(273347),
    FreezingRain = Spell(240555),
    IceBlock = Spell(45438),
    Quake = Spell(240447),
    Counterspell = Spell(2139),
    IceBarrier = Spell(11426),
    Invisibility = Spell(66),

};
HL.Spell[MFrost] = RubimRH.Spell[MFrost]
--Remove Watersomething
local S = RubimRH.Spell[MFrost]

-- Items
if not Item.Mage then
    Item.Mage = {}
end
Item.Mage.Frost = {
    ProlongedPower = Item(142117)
};
local I = Item.Mage.Frost;

-- Variables

local EnemyRanges = { 35 }
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

S.FrozenOrb.EffectID = 84721
S.FrozenOrb:RegisterInFlight()
S.Frostbolt:RegisterInFlight()
-- S.Flurry:RegisterPMultiplier(
--   S.WintersChillDebuff,
--   {S.BrainFreezeBuff, 2}
-- )
-- S.Flurry.EffectID = S.WintersChillDebuff.SpellID
-- S.Flurry:RegisterInFlight(S.BrainFreezeBuff)
--- ======= ACTION LISTS =======

--Player:FilterTriggerGCD(RubimRH.playerSpec)

local function FuckWaterBolt()
    HL.Enum.TriggerGCD[31707] = nil
    HL.Enum.TriggerGCD[33395] = nil
end

local brainFreezewasActive = 9999999999
local function APL()
    FuckWaterBolt()
    local Precombat, Aoe, Cooldowns, Movement, Single, TalentRop
    UpdateRanges()

    if Player:Buff(S.Invisibility) then
        return 0, 236390
    end

    Precombat = function()
        -- flask
        -- food
        -- augmentation
        -- arcane_intellect
        if S.ArcaneIntellect:IsReadyP() and Player:BuffDownP(S.ArcaneIntellectBuff, true) then
            return S.ArcaneIntellect:Cast()
        end
        -- water_elemental
        if S.WaterElemental:IsReadyP() and not Pet:Exists() then
            return S.WaterElemental:Cast()
        end
        -- snapshot_stats
        -- mirror_image
        if S.MirrorImage:IsReadyP() and RubimRH.CDsON() then
            return S.MirrorImage:Cast()
        end
        -- frostbolt
        if S.Frostbolt:IsReadyP() and not Player:IsMoving() and RubimRH.TargetIsValid() then
            return S.Frostbolt:Cast()
        end
    end
    Aoe = function()
        -- frozen_orb
        if S.FrozenOrb:IsReadyP() and Target:TimeToDie() > 15 then
            return S.FrozenOrb:Cast()
        end
        -- blizzard
        if S.Blizzard:IsReadyP() then
            return S.Blizzard:Cast()
        end
        -- comet_storm
        if S.CometStorm:IsReadyP() then
            return S.CometStorm:Cast()
        end
        -- ice_nova
        if S.IceNova:IsReadyP() then
            return S.IceNova:Cast()
        end
        -- flurry,if=prev_gcd.1.ebonbolt|buff.brain_freeze.react&(prev_gcd.1.frostbolt&(buff.icicles.stack<4|!talent.glacial_spike.enabled)|prev_gcd.1.glacial_spike)
        if S.Flurry:IsReadyP() and (Player:PrevGCDP(1, S.Ebonbolt) or (Player:Buff(S.BrainFreezeBuff)) and (Player:PrevGCDP(1, S.Frostbolt) and (Player:BuffStackP(S.IciclesBuff) < 4 or not S.GlacialSpike:IsAvailable()) or Player:PrevGCDP(1, S.GlacialSpike))) then
            return S.Flurry:Cast()
        end
        -- ice_lance,if=buff.fingers_of_frost.react
        if S.IceLance:IsReadyP() and ((Player:Buff(S.FingersofFrostBuff))) then
            return S.IceLance:Cast()
        end
        -- ray_of_frost
        if S.RayofFrost:IsReadyP() then
            return S.RayofFrost:Cast()
        end
        -- ebonbolt
        if S.Ebonbolt:IsReadyP() then
            return S.Ebonbolt:Cast()
        end
        -- glacial_spike
        if S.GlacialSpike:IsReadyP() and Player:BuffStackP(S.IciclesBuff) == 5 then
            return S.GlacialSpike:Cast()
        end
        -- cone_of_cold
        if S.ConeofCold:IsReadyP() then
            return S.ConeofCold:Cast()
        end
        -- frostbolt
        if S.Frostbolt:IsReadyP() and not Player:IsMoving() then
            return S.Frostbolt:Cast()
        end
        -- call_action_list,name=movement
        if Movement() ~= nil and Player:IsMoving() then
            return Movement()
        end
        -- ice_lance
        if S.IceLance:IsReadyP() then
            return S.IceLance:Cast()
        end
    end
    Cooldowns = function()
        -- time_warp
        -- icy_veins
        if S.IcyVeins:IsReadyP() and RubimRH.CDsON() then
            return S.IcyVeins:Cast()
        end
        -- mirror_image
        if S.MirrorImage:IsReadyP() and RubimRH.CDsON() then
            return S.MirrorImage:Cast()
        end
        -- rune_of_power,if=prev_gcd.1.frozen_orb|time_to_die>10+cast_time&time_to_die<20
        if S.RuneofPower:IsReadyP() and (Player:PrevGCDP(1, S.FrozenOrb) or Target:TimeToDie() > 10 + S.RuneofPower:CastTime() and Target:TimeToDie() < 20) then
            return S.RuneofPower:Cast()
        end
        -- call_action_list,name=talent_rop,if=talent.rune_of_power.enabled&active_enemies=1&cooldown.rune_of_power.full_recharge_time<cooldown.frozen_orb.remains
        if (S.RuneofPower:IsAvailable() and Player:EnemiesAround(35) == 1 and S.RuneofPower:FullRechargeTime() < S.FrozenOrb:CooldownRemainsP()) then
            if TalentRop() ~= nil then
                return TalentRop()
            end
        end
        -- potion,if=prev_gcd.1.icy_veins|target.time_to_die<70
        -- use_items
        -- blood_fury
        if S.BloodFury:IsReadyP() and RubimRH.CDsON() then
            return S.BloodFury:Cast()
        end
        -- berserking
        if S.Berserking:IsReadyP() and RubimRH.CDsON() then
            return S.Berserking:Cast()
        end
        -- lights_judgment
        if S.LightsJudgment:IsReadyP() and RubimRH.CDsON() then
            return S.LightsJudgment:Cast()
        end
        -- fireblood
        if S.Fireblood:IsReadyP() and RubimRH.CDsON() then
            return S.Fireblood:Cast()
        end
        -- ancestral_call
        if S.AncestralCall:IsReadyP() and RubimRH.CDsON() then
            return S.AncestralCall:Cast()
        end
    end
    Movement = function()
        -- blink,if=movement.distance>10
        -- ice_floes,if=buff.ice_floes.down
        if S.IceFloes:IsReadyP() and (Player:BuffDownP(S.IceFloesBuff)) then
            return S.IceFloes:Cast()
        end
    end
    Single = function()
        -- ice_nova,if=cooldown.ice_nova.ready&debuff.winters_chill.up
        if S.IceNova:IsReadyP() and Target:DebuffP(S.WintersChillDebuff) then
            return S.IceNova:Cast()
        end
        -- flurry,if=!talent.glacial_spike.enabled&(prev_gcd.1.ebonbolt|buff.brain_freeze.react&prev_gcd.1.frostbolt)
        if S.Flurry:IsReadyP() and (not S.GlacialSpike:IsAvailable() and (Player:PrevGCDP(1, S.Ebonbolt) or (Player:Buff(S.BrainFreezeBuff)) and Player:PrevGCDP(1, S.Frostbolt))) then
            return S.Flurry:Cast()
        end
        --flurry,if=talent.glacial_spike.enabled&buff.brain_freeze.react&(prev_gcd.1.frostbolt&buff.icicles.stack<4|prev_gcd.1.glacial_spike|prev_gcd.1.ebonbolt)
        if S.Flurry:IsReadyP() and (S.GlacialSpike:IsAvailable() and Player:BuffP(S.BrainFreezeBuff) and (Player:PrevGCDP(1, S.Frostbolt) and Player:BuffStackP(S.IciclesBuff) < 4 or Player:PrevGCDP(1, S.GlacialSpike) or (Player:PrevGCDP(1, S.Ebonbolt) and S.GlacialSpike:CooldownRemainsP() > 0))) then
            return S.Flurry:Cast()
        end
        -- frozen_orb
        if S.FrozenOrb:IsReadyP() then
            return S.FrozenOrb:Cast()
        end
        -- blizzard,if=active_enemies>2|active_enemies>1&cast_time=0&buff.fingers_of_frost.react<2
        if S.Blizzard:IsReadyP() and (Player:EnemiesAround(35) > 2 or Player:EnemiesAround(35) > 1 and S.Blizzard:CastTime() == 0 and Player:BuffStackP(S.FingersofFrostBuff) < 2) then
            return S.Blizzard:Cast()
        end
        -- ice_lance,if=buff.fingers_of_frost.react
        if S.IceLance:IsReadyP() and ((Player:Buff(S.FingersofFrostBuff))) then
            return S.IceLance:Cast()
        end
        -- comet_storm
        if S.CometStorm:IsReadyP() then
            return S.CometStorm:Cast()
        end
        -- ebonbolt,if=!talent.glacial_spike.enabled|buff.icicles.stack=5&!buff.brain_freeze.react
        if S.Ebonbolt:IsReadyP() and (not S.GlacialSpike:IsAvailable() or Player:BuffStackP(S.IciclesBuff) == 5 and not Player:Buff(S.BrainFreezeBuff)) then
            return S.Ebonbolt:Cast()
        end
        -- ray_of_frost,if=!action.frozen_orb.in_flight&ground_aoe.frozen_orb.remains=0
        if S.RayofFrost:IsReadyP() and (not S.FrozenOrb:InFlight() and Player:FrozenOrbGroundAoeRemains() == 0) then
            return S.RayofFrost:Cast()
        end
        -- blizzard,if=cast_time=0|active_enemies>1
        if S.Blizzard:IsReadyP() and (S.Blizzard:CastTime() == 0 or Player:EnemiesAround(35) > 1) then
            return S.Blizzard:Cast()
        end
        -- glacial_spike,if=buff.brain_freeze.react|prev_gcd.1.ebonbolt|active_enemies>1&talent.splitting_ice.enabled
        if S.GlacialSpike:IsReadyP() and Player:BuffStackP(S.IciclesBuff) == 5 and (Player:Buff(S.BrainFreezeBuff) or Player:PrevGCDP(1, S.Ebonbolt) or Player:EnemiesAround(35) > 1 and S.SplittingIce:IsAvailable()) then
            return S.GlacialSpike:Cast()
        end
        -- ice_nova
        if S.IceNova:IsReadyP() then
            return S.IceNova:Cast()
        end
        -- flurry,if=azerite.winters_reach.enabled&!buff.brain_freeze.react&buff.winters_reach.react
        if S.Flurry:IsReadyP() and (S.WintersReach:AzeriteEnabled() and not Player:Buff(S.BrainFreezeBuff) and Player:Buff(S.WintersReachBuff)) then
            return S.Flurry:Cast()
        end
        -- frostbolt
        if S.Frostbolt:IsReadyP() and not Player:IsMoving() then
            return S.Frostbolt:Cast()
        end
        -- call_action_list,name=movement
        if Movement() ~= nil and Player:IsMoving() then
            return Movement()
        end
        -- ice_lance
        if S.IceLance:IsReadyP() then
            return S.IceLance:Cast()
        end
    end
    TalentRop = function()
        -- rune_of_power,if=talent.glacial_spike.enabled&buff.icicles.stack=5&(buff.brain_freeze.react|talent.ebonbolt.enabled&cooldown.ebonbolt.remains<cast_time)
        if S.RuneofPower:IsReadyP() and (S.GlacialSpike:IsAvailable() and Player:BuffStackP(S.IciclesBuff) == 5 and ((Player:Buff(S.BrainFreezeBuff)) or S.Ebonbolt:IsAvailable() and S.Ebonbolt:CooldownRemainsP() < S.RuneofPower:CastTime())) then
            return S.RuneofPower:Cast()
        end
        -- rune_of_power,if=!talent.glacial_spike.enabled&(talent.ebonbolt.enabled&cooldown.ebonbolt.remains<cast_time|talent.comet_storm.enabled&cooldown.comet_storm.remains<cast_time|talent.ray_of_frost.enabled&cooldown.ray_of_frost.remains<cast_time|charges_fractional>1.9)
        if S.RuneofPower:IsReadyP() and (not S.GlacialSpike:IsAvailable() and (S.Ebonbolt:IsAvailable() and S.Ebonbolt:CooldownRemainsP() < S.RuneofPower:CastTime() or S.CometStorm:IsAvailable() and S.CometStorm:CooldownRemainsP() < S.RuneofPower:CastTime() or S.RayofFrost:IsAvailable() and S.RayofFrost:CooldownRemainsP() < S.RuneofPower:CastTime() or S.RuneofPower:ChargesFractional() > 1.9)) then
            return S.RuneofPower:Cast()
        end
    end
    -- call precombat
    if not Player:AffectingCombat() and RubimRH.PrecombatON() and (not Player:IsCasting() or Player:IsCasting(S.WaterElemental)) then
        if Precombat() ~= nil then
            return Precombat()
        end
        return 0, 462338
    end

    if Player:Buff(S.BrainFreezeBuff) then
        brainFreezewasActive = GetTime()
    end
    if RubimRH.TargetIsValid() then
	  
	  if QueueSkill() ~= nil then
        return QueueSkill()
      end
        -- counterspell
        -- ice_lance,if=prev_gcd.1.flurry&brain_freeze_active&!buff.fingers_of_frost.react
        if S.IceLance:IsReadyP() and (Player:PrevGCDP(1, S.Flurry) and GetTime() - brainFreezewasActive <= S.Flurry:CastTime() and not (Player:Buff(S.FingersofFrostBuff))) then
            return S.IceLance:Cast()
        end
        -- call_action_list,name=cooldowns
        if RubimRH.CDsON() then
            if Cooldowns() ~= nil then
                return Cooldowns()
            end
        end
        -- call_action_list,name=aoe,if=active_enemies>3&talent.freezing_rain.enabled|active_enemies>4
        if (Player:EnemiesAround(35) > 3 and S.FreezingRain:IsAvailable() or Player:EnemiesAround(35) > 4) then
            if Aoe() ~= nil then
                return Aoe()
            end
        end
        -- call_action_list,name=single
        if (true) then
            if Single() ~= nil then
                return Single()
            end
        end
    end
    return 0, 135328
end

RubimRH.Rotation.SetAPL(64, APL)

local function PASSIVE()
    if S.IceBlock:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[64].sk1 then
        return S.IceBlock:Cast()
    end

    if S.IceBarrier:IsReady() and not Player:Buff(S.IceBarrier) and  Player:HealthPercentage() <= RubimRH.db.profile[64].sk2 then
        return S.IceBarrier:Cast()
    end

    return RubimRH.Shared()
end
RubimRH.Rotation.SetPASSIVE(64, PASSIVE)