--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
-- HeroLib
local HL     = HeroLib
local Cache  = HeroCache
local Unit   = HL.Unit
local Player = Unit.Player
local Target = Unit.Target
local Pet    = Unit.Pet
local Spell  = HL.Spell
local Item   = HL.Item

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
RubimRH.Spell[63] = {
    ArcaneIntellectBuff                   = Spell(1459),
    ArcaneIntellect                       = Spell(1459),
    MirrorImage                           = Spell(55342),
    Pyroblast                             = Spell(11366),
    BlastWave                             = Spell(157981),
    CombustionBuff                        = Spell(190319),
    FireBlast                             = Spell(108853),
    Meteor                                = Spell(153561),
    Combustion                            = Spell(190319),
    RuneofPowerBuff                       = Spell(116014),
    DragonsBreath                         = Spell(31661),
    AlexstraszasFury                      = Spell(235870),
    HotStreakBuff                         = Spell(48108),
    LivingBomb                            = Spell(44457),
    LightsJudgment                        = Spell(255647),
    RuneofPower                           = Spell(116011),
    BloodFury                             = Spell(20572),
    Berserking                            = Spell(26297),
    Flamestrike                           = Spell(2120),
    FlamePatch                            = Spell(205037),
    KaelthasUltimateAbilityBuff           = Spell(209455),
    PyroclasmBuff                         = Spell(269651),
    HeatingUpBuff                         = Spell(48107),
    PhoenixFlames                         = Spell(257541),
    Scorch                                = Spell(2948),
    SearingTouch                          = Spell(269644),
    Fireball                              = Spell(133),
    Kindling                              = Spell(155148),
    IncantersFlowBuff                     = Spell(1463),
    Counterspell                          = Spell(2139),
    EruptingInfernalCoreBuff              = Spell(248147),
    Firestarter                           = Spell(205026)
};
local S = RubimRH.Spell[63];

-- Items
if not Item.Mage then Item.Mage = {} end
Item.Mage.Fire = {
    ProlongedPower                   = Item(142117),
    Item132863                       = Item(132863),
    Item132454                       = Item(132454)
};
local I = Item.Mage.Fire;


-- Variables

local EnemyRanges = {12, 40}
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

S.PhoenixFlames:RegisterInFlight();
S.Pyroblast:RegisterInFlight(S.CombustionBuff);
S.Fireball:RegisterInFlight(S.CombustionBuff);

function S.Firestarter:ActiveStatus()
    return (S.Firestarter:IsAvailable() and (Target:HealthPercentage() > 90)) and 1 or 0
end

function S.Firestarter:ActiveRemains()
    return S.Firestarter:IsAvailable() and ((Target:HealthPercentage() > 90) and Target:TimeToX(90, 3) or 0)
end
--- ======= ACTION LISTS =======
local function APL()
    local Precombat, ActiveTalents, CombustionPhase, RopPhase, StandardRotation
    UpdateRanges()
    Precombat = function()
        -- flask
        -- food
        -- augmentation
        -- arcane_intellect
        if S.ArcaneIntellect:IsReady() and Player:BuffDownP(S.ArcaneIntellectBuff) and (true) then
            return S.ArcaneIntellect:Cast()
        end
        -- snapshot_stats
        -- mirror_image
        if S.MirrorImage:IsReady() and (true) then
            return S.MirrorImage:Cast()
        end
        -- potion
        if I.ProlongedPower:IsReady() and RubimRH.PotionON() and (true) then
            return S.ProlongedPower:Cast()
        end
        -- pyroblast
        if S.Pyroblast:IsReady() and (true) then
            return S.Pyroblast:Cast()
        end
    end
    ActiveTalents = function()
        -- blast_wave,if=(buff.combustion.down)|(buff.combustion.up&action.fire_blast.charges<1)
        if S.BlastWave:IsReady() and ((Player:BuffDown(S.CombustionBuff)) or (Player:Buff(S.CombustionBuff) and S.FireBlast:Charges() < 1)) then
            return S.BlastWave:Cast()
        end
        -- meteor,if=cooldown.combustion.remains>40|(cooldown.combustion.remains>target.time_to_die)|buff.rune_of_power.up|firestarter.active
        if S.Meteor:IsReady() and (S.Combustion:CooldownRemains() > 40 or (S.Combustion:CooldownRemains() > Target:TimeToDie()) or Player:Buff(S.RuneofPowerBuff) or bool(S.Firestarter:ActiveStatus())) then
            return S.Meteor:Cast()
        end
        -- dragons_breath,if=equipped.132863|(talent.alexstraszas_fury.enabled&!buff.hot_streak.react)
        if S.DragonsBreath:IsReady() and (I.Item132863:IsEquipped() or (S.AlexstraszasFury:IsAvailable() and not bool(Player:Buff(S.HotStreakBuff)))) then
            return S.DragonsBreath:Cast()
        end
        -- living_bomb,if=active_enemies>1&buff.combustion.down
        if S.LivingBomb:IsReady() and (Cache.EnemiesCount[40] > 1 and Player:BuffDown(S.CombustionBuff)) then
            return S.LivingBomb:Cast()
        end
    end
    CombustionPhase = function()
        -- lights_judgment,if=buff.combustion.down
        if S.LightsJudgment:IsReady() and RubimRH.CDsON() and (Player:BuffDown(S.CombustionBuff)) then
            return S.LightsJudgment:Cast()
        end
        -- rune_of_power,if=buff.combustion.down
        if S.RuneofPower:IsReady() and (Player:BuffDown(S.CombustionBuff)) then
            return S.RuneofPower:Cast()
        end
        -- call_action_list,name=active_talents
        if (true) then
            if ActiveTalents() ~= nil then
                return ActiveTalents()
            end
        end
        -- combustion
        if S.Combustion:IsReady() and RubimRH.CDsON() and (true) then
            return S.Combustion:Cast()
        end
        -- potion
        if I.ProlongedPower:IsReady() and RubimRH.PotionON() and (true) then
            return S.ProlongedPower:Cast()
        end
        -- blood_fury
        if S.BloodFury:IsReady() and RubimRH.CDsON() and (true) then
            return S.BloodFury:Cast()
        end
        -- berserking
        if S.Berserking:IsReady() and RubimRH.CDsON() and (true) then
            return S.Berserking:Cast()
        end
        -- use_items
        -- flamestrike,if=((talent.flame_patch.enabled&active_enemies>2)|active_enemies>6)&buff.hot_streak.react
        if S.Flamestrike:IsReady() and (((S.FlamePatch:IsAvailable() and Cache.EnemiesCount[40] > 2) or Cache.EnemiesCount[40] > 6) and bool(Player:Buff(S.HotStreakBuff))) then
            return S.Flamestrike:Cast()
        end
        -- pyroblast,if=(buff.kaelthas_ultimate_ability.react|buff.pyroclasm.react)&buff.combustion.remains>execute_time
        if S.Pyroblast:IsReady() and ((bool(Player:Buff(S.KaelthasUltimateAbilityBuff)) or bool(Player:Buff(S.PyroclasmBuff))) and Player:BuffRemains(S.CombustionBuff) > S.Pyroblast:ExecuteTime()) then
            return S.Pyroblast:Cast()
        end
        -- pyroblast,if=buff.hot_streak.react
        if S.Pyroblast:IsReady() and (bool(Player:Buff(S.HotStreakBuff))) then
            return S.Pyroblast:Cast()
        end
        -- fire_blast,if=buff.heating_up.react
        if S.FireBlast:IsReady() and (bool(Player:Buff(S.HeatingUpBuff))) then
            return S.FireBlast:Cast()
        end
        -- phoenix_flames
        if S.PhoenixFlames:IsReady() and (true) then
            return S.PhoenixFlames:Cast()
        end
        -- scorch,if=buff.combustion.remains>cast_time
        if S.Scorch:IsReady() and (Player:BuffRemains(S.CombustionBuff) > S.Scorch:CastTime()) then
            return S.Scorch:Cast()
        end
        -- dragons_breath,if=!buff.hot_streak.react&action.fire_blast.charges<1
        if S.DragonsBreath:IsReady() and (not bool(Player:Buff(S.HotStreakBuff)) and S.FireBlast:Charges() < 1) then
            return S.DragonsBreath:Cast()
        end
        -- scorch,if=target.health.pct<=30&(equipped.132454|talent.searing_touch.enabled)
        if S.Scorch:IsReady() and (Target:HealthPercentage() <= 30 and (I.Item132454:IsEquipped() or S.SearingTouch:IsAvailable())) then
            return S.Scorch:Cast()
        end
    end
    RopPhase = function()
        -- rune_of_power
        if S.RuneofPower:IsReady() and (true) then
            return S.RuneofPower:Cast()
        end
        -- flamestrike,if=((talent.flame_patch.enabled&active_enemies>1)|active_enemies>4)&buff.hot_streak.react
        if S.Flamestrike:IsReady() and (((S.FlamePatch:IsAvailable() and Cache.EnemiesCount[40] > 1) or Cache.EnemiesCount[40] > 4) and bool(Player:Buff(S.HotStreakBuff))) then
            return S.Flamestrike:Cast()
        end
        -- pyroblast,if=buff.hot_streak.react
        if S.Pyroblast:IsReady() and (bool(Player:Buff(S.HotStreakBuff))) then
            return S.Pyroblast:Cast()
        end
        -- call_action_list,name=active_talents
        if (true) then
            if ActiveTalents() ~= nil then
                return ActiveTalents()
            end
        end
        -- pyroblast,if=buff.kaelthas_ultimate_ability.react&execute_time<buff.kaelthas_ultimate_ability.remains&buff.rune_of_power.remains>cast_time
        if S.Pyroblast:IsReady() and (bool(Player:Buff(S.KaelthasUltimateAbilityBuff)) and S.Pyroblast:ExecuteTime() < Player:BuffRemains(S.KaelthasUltimateAbilityBuff) and Player:BuffRemains(S.RuneofPowerBuff) > S.Pyroblast:CastTime()) then
            return S.Pyroblast:Cast()
        end
        -- pyroblast,if=buff.pyroclasm.react&execute_time<buff.pyroclasm.remains&buff.rune_of_power.remains>cast_time
        if S.Pyroblast:IsReady() and (bool(Player:Buff(S.PyroclasmBuff)) and S.Pyroblast:ExecuteTime() < Player:BuffRemains(S.PyroclasmBuff) and Player:BuffRemains(S.RuneofPowerBuff) > S.Pyroblast:CastTime()) then
            return S.Pyroblast:Cast()
        end
        -- fire_blast,if=!prev_off_gcd.fire_blast&buff.heating_up.react&firestarter.active&charges_fractional>1.7
        if S.FireBlast:IsReady() and (not Player:PrevOffGCD(1, S.FireBlast) and bool(Player:Buff(S.HeatingUpBuff)) and bool(S.Firestarter:ActiveStatus()) and S.FireBlast:ChargesFractional() > 1.7) then
            return S.FireBlast:Cast()
        end
        -- phoenix_flames,if=!prev_gcd.1.phoenix_flames&charges_fractional>2.7&firestarter.active
        if S.PhoenixFlames:IsReady() and (not Player:PrevGCD(1, S.PhoenixFlames) and S.PhoenixFlames:ChargesFractional() > 2.7 and bool(S.Firestarter:ActiveStatus())) then
            return S.PhoenixFlames:Cast()
        end
        -- fire_blast,if=!prev_off_gcd.fire_blast&!firestarter.active
        if S.FireBlast:IsReady() and (not Player:PrevOffGCD(1, S.FireBlast) and not bool(S.Firestarter:ActiveStatus())) then
            return S.FireBlast:Cast()
        end
        -- phoenix_flames,if=!prev_gcd.1.phoenix_flames
        if S.PhoenixFlames:IsReady() and (not Player:PrevGCD(1, S.PhoenixFlames)) then
            return S.PhoenixFlames:Cast()
        end
        -- scorch,if=target.health.pct<=30&(equipped.132454|talent.searing_touch.enabled)
        if S.Scorch:IsReady() and (Target:HealthPercentage() <= 30 and (I.Item132454:IsEquipped() or S.SearingTouch:IsAvailable())) then
            return S.Scorch:Cast()
        end
        -- dragons_breath,if=active_enemies>2
        if S.DragonsBreath:IsReady() and (Cache.EnemiesCount[12] > 2) then
            return S.DragonsBreath:Cast()
        end
        -- flamestrike,if=(talent.flame_patch.enabled&active_enemies>2)|active_enemies>5
        if S.Flamestrike:IsReady() and ((S.FlamePatch:IsAvailable() and Cache.EnemiesCount[40] > 2) or Cache.EnemiesCount[40] > 5) then
            return S.Flamestrike:Cast()
        end
        -- fireball
        if S.Fireball:IsReady() and (true) then
            return S.Fireball:Cast()
        end
    end
    StandardRotation = function()
        -- flamestrike,if=((talent.flame_patch.enabled&active_enemies>1)|active_enemies>4)&buff.hot_streak.react
        if S.Flamestrike:IsReady() and (((S.FlamePatch:IsAvailable() and Cache.EnemiesCount[40] > 1) or Cache.EnemiesCount[40] > 4) and bool(Player:Buff(S.HotStreakBuff))) then
            return S.Flamestrike:Cast()
        end
        -- pyroblast,if=buff.hot_streak.react&buff.hot_streak.remains<action.fireball.execute_time
        if S.Pyroblast:IsReady() and (bool(Player:Buff(S.HotStreakBuff)) and Player:BuffRemains(S.HotStreakBuff) < S.Fireball:ExecuteTime()) then
            return S.Pyroblast:Cast()
        end
        -- pyroblast,if=buff.hot_streak.react&firestarter.active&!talent.rune_of_power.enabled
        if S.Pyroblast:IsReady() and (bool(Player:Buff(S.HotStreakBuff)) and bool(S.Firestarter:ActiveStatus()) and not S.RuneofPower:IsAvailable()) then
            return S.Pyroblast:Cast()
        end
        -- phoenix_flames,if=charges_fractional>2.7&active_enemies>2
        if S.PhoenixFlames:IsReady() and (S.PhoenixFlames:ChargesFractional() > 2.7 and Cache.EnemiesCount[40] > 2) then
            return S.PhoenixFlames:Cast()
        end
        -- pyroblast,if=buff.hot_streak.react&(!prev_gcd.1.pyroblast|action.pyroblast.in_flight)
        if S.Pyroblast:IsReady() and (bool(Player:Buff(S.HotStreakBuff)) and (not Player:PrevGCD(1, S.Pyroblast) or S.Pyroblast:InFlight())) then
            return S.Pyroblast:Cast()
        end
        -- pyroblast,if=buff.hot_streak.react&target.health.pct<=30&equipped.132454
        if S.Pyroblast:IsReady() and (bool(Player:Buff(S.HotStreakBuff)) and Target:HealthPercentage() <= 30 and I.Item132454:IsEquipped()) then
            return S.Pyroblast:Cast()
        end
        -- pyroblast,if=buff.kaelthas_ultimate_ability.react&execute_time<buff.kaelthas_ultimate_ability.remains
        if S.Pyroblast:IsReady() and (bool(Player:Buff(S.KaelthasUltimateAbilityBuff)) and S.Pyroblast:ExecuteTime() < Player:BuffRemains(S.KaelthasUltimateAbilityBuff)) then
            return S.Pyroblast:Cast()
        end
        -- pyroblast,if=buff.pyroclasm.react&execute_time<buff.pyroclasm.remains
        if S.Pyroblast:IsReady() and (bool(Player:Buff(S.PyroclasmBuff)) and S.Pyroblast:ExecuteTime() < Player:BuffRemains(S.PyroclasmBuff)) then
            return S.Pyroblast:Cast()
        end
        -- call_action_list,name=active_talents
        if (true) then
            if ActiveTalents() ~= nil then
                return ActiveTalents()
            end
        end
        -- fire_blast,if=!talent.kindling.enabled&buff.heating_up.react&(!talent.rune_of_power.enabled|charges_fractional>1.4|cooldown.combustion.remains<40)&(3-charges_fractional)*(12*spell_haste)<cooldown.combustion.remains+3|target.time_to_die<4
        if S.FireBlast:IsReady() and (not S.Kindling:IsAvailable() and bool(Player:Buff(S.HeatingUpBuff)) and (not S.RuneofPower:IsAvailable() or S.FireBlast:ChargesFractional() > 1.4 or S.Combustion:CooldownRemains() < 40) and (3 - S.FireBlast:ChargesFractional()) * (12 * Player:SpellHaste()) < S.Combustion:CooldownRemains() + 3 or Target:TimeToDie() < 4) then
            return S.FireBlast:Cast()
        end
        -- fire_blast,if=talent.kindling.enabled&buff.heating_up.react&(!talent.rune_of_power.enabled|charges_fractional>1.5|cooldown.combustion.remains<40)&(3-charges_fractional)*(18*spell_haste)<cooldown.combustion.remains+3|target.time_to_die<4
        if S.FireBlast:IsReady() and (S.Kindling:IsAvailable() and bool(Player:Buff(S.HeatingUpBuff)) and (not S.RuneofPower:IsAvailable() or S.FireBlast:ChargesFractional() > 1.5 or S.Combustion:CooldownRemains() < 40) and (3 - S.FireBlast:ChargesFractional()) * (18 * Player:SpellHaste()) < S.Combustion:CooldownRemains() + 3 or Target:TimeToDie() < 4) then
            return S.FireBlast:Cast()
        end
        -- phoenix_flames,if=(buff.combustion.up|buff.rune_of_power.up|buff.incanters_flow.stack>3|talent.mirror_image.enabled)&(4-charges_fractional)*13<cooldown.combustion.remains+5|target.time_to_die<10
        if S.PhoenixFlames:IsReady() and ((Player:Buff(S.CombustionBuff) or Player:Buff(S.RuneofPowerBuff) or Player:BuffStack(S.IncantersFlowBuff) > 3 or S.MirrorImage:IsAvailable()) and (4 - S.PhoenixFlames:ChargesFractional()) * 13 < S.Combustion:CooldownRemains() + 5 or Target:TimeToDie() < 10) then
            return S.PhoenixFlames:Cast()
        end
        -- phoenix_flames,if=(buff.combustion.up|buff.rune_of_power.up)&(4-charges_fractional)*30<cooldown.combustion.remains+5
        if S.PhoenixFlames:IsReady() and ((Player:Buff(S.CombustionBuff) or Player:Buff(S.RuneofPowerBuff)) and (4 - S.PhoenixFlames:ChargesFractional()) * 30 < S.Combustion:CooldownRemains() + 5) then
            return S.PhoenixFlames:Cast()
        end
        -- phoenix_flames,if=charges_fractional>2.5&cooldown.combustion.remains>23
        if S.PhoenixFlames:IsReady() and (S.PhoenixFlames:ChargesFractional() > 2.5 and S.Combustion:CooldownRemains() > 23) then
            return S.PhoenixFlames:Cast()
        end
        -- scorch,if=target.health.pct<=30&(equipped.132454|talent.searing_touch.enabled)
        if S.Scorch:IsReady() and (Target:HealthPercentage() <= 30 and (I.Item132454:IsEquipped() or S.SearingTouch:IsAvailable())) then
            return S.Scorch:Cast()
        end
        -- fireball
        if S.Fireball:IsReady() and (true) then
            return S.Fireball:Cast()
        end
        -- scorch
        if S.Scorch:IsReady() and (true) then
            return S.Scorch:Cast()
        end
    end
    -- call precombat
    if not Player:AffectingCombat() and not Player:IsCasting() then
        if Precombat() ~= nil then
            return Precombat()
        end
        return 0, 462338
    end
    -- call_action_list,name=standard_rotation
    if (true) then
        if StandardRotation() ~= nil then
            return StandardRotation()
        end
    end
    return 0, 135328
end

RubimRH.Rotation.SetAPL(63, APL)

local function PASSIVE()
    return RubimRH.Shared()
end
RubimRH.Rotation.SetPASSIVE(63, PASSIVE)