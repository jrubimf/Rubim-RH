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
RubimRH.Spell[62] = {
    ArcaneIntellectBuff = Spell(1459),
    ArcaneIntellect = Spell(1459),
    SummonArcaneFamiliarBuff = Spell(210126),
    SummonArcaneFamiliar = Spell(205022),
    Overpowered = Spell(155147),
    MirrorImage = Spell(55342),
    ArcaneBlast = Spell(30451),
    Evocation = Spell(12051),
    ChargedUp = Spell(205032),
    ArcaneChargeBuff = Spell(36032),
    PresenceofMind = Spell(205025),
    NetherTempest = Spell(114923),
    NetherTempestDebuff = Spell(114923),
    RuneofPowerBuff = Spell(116014),
    ArcanePowerBuff = Spell(12042),
    LightsJudgment = Spell(255647),
    RuneofPower = Spell(116011),
    ArcanePower = Spell(12042),
    BloodFury = Spell(20572),
    Berserking = Spell(26297),
    ArcaneOrb = Spell(153626),
    Resonance = Spell(205028),
    PresenceofMindBuff = Spell(205025),
    ArcaneBarrage = Spell(44425),
    ArcaneExplosion = Spell(1449),
    ArcaneMissiles = Spell(5143),
    ClearcastingBuff = Spell(263725),
    RuleofThreesBuff = Spell(264774),
    RhoninsAssaultingArmwrapsBuff = Spell(208081),
    Supernova = Spell(157980),
    ArcaneTorrent = Spell(50613),
    Shimmer = Spell(212653),
    Blink = Spell(1953),
    Counterspell = Spell(2139)
};
local S = RubimRH.Spell[62];

-- Items
if not Item.Mage then
    Item.Mage = {}
end
Item.Mage.Arcane = {
    DeadlyGrace = Item(127843),
    GravitySpiral = Item(144274),
    MysticKiltoftheRuneMaster = Item(209280)
};
local I = Item.Mage.Arcane;


-- Variables
local VarBurnPhase = 0;
local VarBurnPhaseStart = 0;
local VarBurnPhaseDuration = 0;
local VarConserveMana = 0;
local VarTotalBurns = 0;
local VarAverageBurnLength = 0;

local EnemyRanges = { 10, 40 }
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

local function PresenceOfMindMax ()
    return 2
end

local function ArcaneMissilesProcMax ()
    return 3
end

local function StartBurnPhase ()
    varBurnPhase = 1
    varBurnPhaseStart = HL.GetTime()
end

local function StopBurnPhase ()
    varBurnPhase = 0
end

--- ======= ACTION LISTS =======
local function APL()
    local Precombat, Burn, Conserve, Movement
    UpdateRanges()
    Precombat = function()
        -- flask
        -- food
        -- augmentation
        -- arcane_intellect
        if S.ArcaneIntellect:IsReady() and Player:BuffDownP(S.ArcaneIntellectBuff) and (true) then
            return S.ArcaneIntellect:Cast()
        end
        -- summon_arcane_familiar
        if S.SummonArcaneFamiliar:IsReady() and Player:BuffDownP(S.SummonArcaneFamiliarBuff) and (true) then
            return S.SummonArcaneFamiliar:Cast()
        end
        -- variable,name=conserve_mana,op=set,value=35,if=talent.overpowered.enabled
        if (S.Overpowered:IsAvailable()) then
            VarConserveMana = 35
        end
        -- variable,name=conserve_mana,op=set,value=45,if=!talent.overpowered.enabled
        if (not S.Overpowered:IsAvailable()) then
            VarConserveMana = 45
        end
        -- snapshot_stats
        -- mirror_image
        if S.MirrorImage:IsReady() and (true) then
            return S.MirrorImage:Cast()
        end
        -- potion
        if I.DeadlyGrace:IsReady() and RubimRH.PotionON() and (true) then
            return S.DeadlyGrace:Cast()
        end
        -- arcane_blast
        if S.ArcaneBlast:IsReady() and (true) then
            return S.ArcaneBlast:Cast()
        end
    end
    Burn = function()
        -- variable,name=total_burns,op=add,value=1,if=!burn_phase
        if (not bool(VarBurnPhase)) then
            VarTotalBurns = VarTotalBurns + 1
        end
        -- start_burn_phase,if=!burn_phase
        if (not bool(VarBurnPhase)) then
            StartBurnPhase()
        end
        -- stop_burn_phase,if=burn_phase&(prev_gcd.1.evocation|(equipped.gravity_spiral&cooldown.evocation.charges=0&prev_gcd.1.evocation))&target.time_to_die>variable.average_burn_length&burn_phase_duration>0
        if (bool(VarBurnPhase) and (Player:PrevGCD(1, S.Evocation) or (I.GravitySpiral:IsEquipped() and S.Evocation:Charges() == 0 and Player:PrevGCD(1, S.Evocation))) and Target:TimeToDie() > VarAverageBurnLength and VarBurnPhaseDuration > 0) then
            StopBurnPhase()
        end
        -- mirror_image
        if S.MirrorImage:IsReady() and (true) then
            return S.MirrorImage:Cast()
        end
        -- charged_up,if=buff.arcane_charge.stack<=1&(!set_bonus.tier20_2pc|cooldown.presence_of_mind.remains>5)
        if S.ChargedUp:IsReady() and (Player:BuffStack(S.ArcaneChargeBuff) <= 1 and (not HL.Tier20_2Pc or S.PresenceofMind:CooldownRemains() > 5)) then
            return S.ChargedUp:Cast()
        end
        -- nether_tempest,if=(refreshable|!ticking)&buff.arcane_charge.stack=buff.arcane_charge.max_stack&buff.rune_of_power.down&buff.arcane_power.down
        if S.NetherTempest:IsReady() and ((Target:DebuffRefreshableC(S.NetherTempestDebuff) or not Target:Debuff(S.NetherTempestDebuff)) and Player:BuffStack(S.ArcaneChargeBuff) == Player:ArcaneChargesMax() and Player:BuffDown(S.RuneofPowerBuff) and Player:BuffDown(S.ArcanePowerBuff)) then
            return S.NetherTempest:Cast()
        end
        -- time_warp,if=buff.bloodlust.down&((buff.arcane_power.down&cooldown.arcane_power.remains=0)|(target.time_to_die<=buff.bloodlust.duration))
        -- lights_judgment,if=buff.arcane_power.down
        if S.LightsJudgment:IsReady() and RubimRH.CDsON() and (Player:BuffDown(S.ArcanePowerBuff)) then
            return S.LightsJudgment:Cast()
        end
        -- rune_of_power,if=!buff.arcane_power.up&(mana.pct>=50|cooldown.arcane_power.remains=0)&(buff.arcane_charge.stack=buff.arcane_charge.max_stack)
        if S.RuneofPower:IsReady() and (not Player:Buff(S.ArcanePowerBuff) and (Player:ManaPercentage() >= 50 or S.ArcanePower:CooldownRemains() == 0) and (Player:BuffStack(S.ArcaneChargeBuff) == Player:ArcaneChargesMax())) then
            return S.RuneofPower:Cast()
        end
        -- arcane_power
        if S.ArcanePower:IsReady() and (true) then
            return S.ArcanePower:Cast()
        end
        -- use_items,if=buff.arcane_power.up|target.time_to_die<cooldown.arcane_power.remains
        -- blood_fury
        if S.BloodFury:IsReady() and RubimRH.CDsON() and (true) then
            return S.BloodFury:Cast()
        end
        -- berserking
        if S.Berserking:IsReady() and RubimRH.CDsON() and (true) then
            return S.Berserking:Cast()
        end
        -- presence_of_mind
        if S.PresenceofMind:IsReady() and (true) then
            return S.PresenceofMind:Cast()
        end
        -- arcane_orb,if=buff.arcane_charge.stack=0|(active_enemies<3|(active_enemies<2&talent.resonance.enabled))
        if S.ArcaneOrb:IsReady() and (Player:BuffStack(S.ArcaneChargeBuff) == 0 or (Cache.EnemiesCount[40] < 3 or (Cache.EnemiesCount[40] < 2 and S.Resonance:IsAvailable()))) then
            return S.ArcaneOrb:Cast()
        end
        -- arcane_blast,if=buff.presence_of_mind.up&set_bonus.tier20_2pc&talent.overpowered.enabled&buff.arcane_power.up
        if S.ArcaneBlast:IsReady() and (Player:Buff(S.PresenceofMindBuff) and HL.Tier20_2Pc and S.Overpowered:IsAvailable() and Player:Buff(S.ArcanePowerBuff)) then
            return S.ArcaneBlast:Cast()
        end
        -- arcane_barrage,if=(active_enemies>=3|(active_enemies>=2&talent.resonance.enabled))&(buff.arcane_charge.stack=buff.arcane_charge.max_stack)
        if S.ArcaneBarrage:IsReady() and ((Cache.EnemiesCount[40] >= 3 or (Cache.EnemiesCount[40] >= 2 and S.Resonance:IsAvailable())) and (Player:BuffStack(S.ArcaneChargeBuff) == Player:ArcaneChargesMax())) then
            return S.ArcaneBarrage:Cast()
        end
        -- arcane_explosion,if=active_enemies>=3|(active_enemies>=2&talent.resonance.enabled)
        if S.ArcaneExplosion:IsReady() and (Cache.EnemiesCount[10] >= 3 or (Cache.EnemiesCount[10] >= 2 and S.Resonance:IsAvailable())) then
            return S.ArcaneExplosion:Cast()
        end
        -- arcane_missiles,if=(buff.clearcasting.react&mana.pct<=95),chain=1
        if S.ArcaneMissiles:IsReady() and ((bool(Player:BuffStack(S.ClearcastingBuff)) and Player:ManaPercentage() <= 95)) then
            return S.ArcaneMissiles:Cast()
        end
        -- arcane_blast
        if S.ArcaneBlast:IsReady() and (true) then
            return S.ArcaneBlast:Cast()
        end
        -- variable,name=average_burn_length,op=set,value=(variable.average_burn_length*variable.total_burns-variable.average_burn_length+(burn_phase_duration))%variable.total_burns
        if (true) then
            VarAverageBurnLength = (VarAverageBurnLength * VarTotalBurns - VarAverageBurnLength + (VarBurnPhaseDuration)) / VarTotalBurns
        end
        -- evocation,interrupt_if=mana.pct>=97|(buff.clearcasting.react&mana.pct>=92)
        if S.Evocation:IsReady() and (true) then
            return S.Evocation:Cast()
        end
        -- arcane_barrage
        if S.ArcaneBarrage:IsReady() and (true) then
            return S.ArcaneBarrage:Cast()
        end
    end
    Conserve = function()
        -- mirror_image
        if S.MirrorImage:IsReady() and (true) then
            return S.MirrorImage:Cast()
        end
        -- charged_up,if=buff.arcane_charge.stack=0
        if S.ChargedUp:IsReady() and (Player:BuffStack(S.ArcaneChargeBuff) == 0) then
            return S.ChargedUp:Cast()
        end
        -- presence_of_mind,if=set_bonus.tier20_2pc&buff.arcane_charge.stack=0
        if S.PresenceofMind:IsReady() and (HL.Tier20_2Pc and Player:BuffStack(S.ArcaneChargeBuff) == 0) then
            return S.PresenceofMind:Cast()
        end
        -- nether_tempest,if=(refreshable|!ticking)&buff.arcane_charge.stack=buff.arcane_charge.max_stack&buff.rune_of_power.down&buff.arcane_power.down
        if S.NetherTempest:IsReady() and ((Target:DebuffRefreshableC(S.NetherTempestDebuff) or not Target:Debuff(S.NetherTempestDebuff)) and Player:BuffStack(S.ArcaneChargeBuff) == Player:ArcaneChargesMax() and Player:BuffDown(S.RuneofPowerBuff) and Player:BuffDown(S.ArcanePowerBuff)) then
            return S.NetherTempest:Cast()
        end
        -- arcane_blast,if=(buff.rule_of_threes.up|buff.rhonins_assaulting_armwraps.react)&buff.arcane_charge.stack>=3
        if S.ArcaneBlast:IsReady() and ((Player:Buff(S.RuleofThreesBuff) or bool(Player:BuffStack(S.RhoninsAssaultingArmwrapsBuff))) and Player:BuffStack(S.ArcaneChargeBuff) >= 3) then
            return S.ArcaneBlast:Cast()
        end
        -- rune_of_power,if=buff.arcane_charge.stack=buff.arcane_charge.max_stack&(full_recharge_time<=execute_time|recharge_time<=cooldown.arcane_power.remains|target.time_to_die<=cooldown.arcane_power.remains)
        if S.RuneofPower:IsReady() and (Player:BuffStack(S.ArcaneChargeBuff) == Player:ArcaneChargesMax() and (S.RuneofPower:FullRechargeTime() <= S.RuneofPower:ExecuteTime() or S.RuneofPower:Recharge() <= S.ArcanePower:CooldownRemains() or Target:TimeToDie() <= S.ArcanePower:CooldownRemains())) then
            return S.RuneofPower:Cast()
        end
        -- arcane_missiles,if=mana.pct<=95&buff.clearcasting.react,chain=1
        if S.ArcaneMissiles:IsReady() and (Player:ManaPercentage() <= 95 and bool(Player:BuffStack(S.ClearcastingBuff))) then
            return S.ArcaneMissiles:Cast()
        end
        -- arcane_blast,if=equipped.mystic_kilt_of_the_rune_master&buff.arcane_charge.stack=0
        if S.ArcaneBlast:IsReady() and (I.MysticKiltoftheRuneMaster:IsEquipped() and Player:BuffStack(S.ArcaneChargeBuff) == 0) then
            return S.ArcaneBlast:Cast()
        end
        -- arcane_barrage,if=((buff.arcane_charge.stack=buff.arcane_charge.max_stack)&(mana.pct<=variable.conserve_mana)|(talent.arcane_orb.enabled&cooldown.arcane_orb.remains<=gcd))|mana.pct<=(variable.conserve_mana-10)
        if S.ArcaneBarrage:IsReady() and (((Player:BuffStack(S.ArcaneChargeBuff) == Player:ArcaneChargesMax()) and (Player:ManaPercentage() <= VarConserveMana) or (S.ArcaneOrb:IsAvailable() and S.ArcaneOrb:CooldownRemains() <= Player:GCD())) or Player:ManaPercentage() <= (VarConserveMana - 10)) then
            return S.ArcaneBarrage:Cast()
        end
        -- supernova,if=mana.pct<=95
        if S.Supernova:IsReady() and (Player:ManaPercentage() <= 95) then
            return S.Supernova:Cast()
        end
        -- arcane_explosion,if=active_enemies>=3&(mana.pct>=variable.conserve_mana|buff.arcane_charge.stack=3)
        if S.ArcaneExplosion:IsReady() and (Cache.EnemiesCount[10] >= 3 and (Player:ManaPercentage() >= VarConserveMana or Player:BuffStack(S.ArcaneChargeBuff) == 3)) then
            return S.ArcaneExplosion:Cast()
        end
        -- arcane_torrent
        if S.ArcaneTorrent:IsReady() and RubimRH.CDsON() and (true) then
            return S.ArcaneTorrent:Cast()
        end
        -- arcane_blast
        if S.ArcaneBlast:IsReady() and (true) then
            return S.ArcaneBlast:Cast()
        end
        -- arcane_barrage
        if S.ArcaneBarrage:IsReady() and (true) then
            return S.ArcaneBarrage:Cast()
        end
    end
    Movement = function()
        -- shimmer,if=movement.distance>=10
        if S.Shimmer:IsReady() then
            return S.Shimmer:Cast()
        end
        -- blink,if=movement.distance>=10
        if S.Blink:IsReady() then
            return S.Blink:Cast()
        end
        -- presence_of_mind
        if S.PresenceofMind:IsReady() and (true) then
            return S.PresenceofMind:Cast()
        end
        -- arcane_missiles
        if S.ArcaneMissiles:IsReady() and (true) then
            return S.ArcaneMissiles:Cast()
        end
        -- arcane_orb
        if S.ArcaneOrb:IsReady() and (true) then
            return S.ArcaneOrb:Cast()
        end
        -- supernova
        if S.Supernova:IsReady() and (true) then
            return S.Supernova:Cast()
        end
    end
    -- call precombat
    if not Player:AffectingCombat() then
        if Precombat() ~= nil then
            return Precombat()
        end
        return 0, 462338
    end
    -- counterspell,if=target.debuff.casting.react
    if S.Counterspell:IsReady() and RubimRH.InterruptsON() and Target:IsInterruptible() and (Target:IsCasting()) then
        return S.Counterspell:Cast()
    end
    -- time_warp,if=time=0&buff.bloodlust.down
    -- call_action_list,name=burn,if=burn_phase|target.time_to_die<variable.average_burn_length|(cooldown.arcane_power.remains=0&cooldown.evocation.remains<=variable.average_burn_length&(buff.arcane_charge.stack=buff.arcane_charge.max_stack|(talent.charged_up.enabled&cooldown.charged_up.remains=0)))
    if (bool(VarBurnPhase) or Target:TimeToDie() < VarAverageBurnLength or (S.ArcanePower:CooldownRemains() == 0 and S.Evocation:CooldownRemains() <= VarAverageBurnLength and (Player:BuffStack(S.ArcaneChargeBuff) == Player:ArcaneChargesMax() or (S.ChargedUp:IsAvailable() and S.ChargedUp:CooldownRemains() == 0)))) then
        if Burn() ~= nil then
            return Burn()
        end
    end
    -- call_action_list,name=conserve,if=!burn_phase
    if (not bool(VarBurnPhase)) then
        if Conserve() ~= nil then
            return Conserve()
        end
    end
    -- call_action_list,name=movement
    if (true) then
        if Movement() ~= nil then
            return Movement()
        end
    end
    return 0, 135328
end

RubimRH.Rotation.SetAPL(62, APL)

local function PASSIVE()
    return RubimRH.Shared()
end
RubimRH.Rotation.SetPASSIVE(62, PASSIVE)