--- Localize Vars
-- Addon
local RubimRH = LibStub("AceAddon-3.0"):GetAddon("RubimRH")
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

local mainAddon = RubimRH

RubimRH.Spell[73] = {
    ArcaneTorrent = Spell(69179),
    Berserking = Spell(26297),
    BloodFury = Spell(20572),
    Shadowmeld = Spell(58984),
    BloodFury  = Spell(20572),
    Berserking = Spell(26297),
    ArcaneTorrent = Spell(50613),
    LightsJudgment = Spell(255647),
    Fireblood = Spell(265221),
    AncestralCall = Spell(274738),
    -- Abilities
    BerserkerRage = Spell(18499),
    Charge = Spell(100), -- Unused
    DemoralizingShout = Spell(1160),
    Devastate = Spell(20243),
    HeroicLeap = Spell(6544), -- Unused
    HeroicThrow = Spell(57755), -- Unused
    Revenge = Spell(6572),
    RevengeBuff = Spell(5302),
    ShieldSlam = Spell(23922),
    ThunderClap = Spell(6343),
    VictoryRush = Spell(34428),
    Victorious = Spell(32216),
    LastStand = Spell(12975),
    Avatar = Spell(107574),
    BattleShout = Spell(6673),
    -- Talents
    BoomingVoice = Spell(202743),
    ImpendingVictory = Spell(202168),
    Shockwave = Spell(46968),
    CracklingThunder = Spell(203201),
    Vengeance = Spell(202572),
    VegeanceIP = Spell(202574),
    VegeanceRV = Spell(202573),
    UnstoppableForce = Spell(275336),
    Ravager = Spell(228920),
    Bolster = Spell(280001),
    DragonRoar = Spell(118000),
    -- PVP Talents
    ShieldBash = Spell(198912),
    -- Defensive
    IgnorePain = Spell(190456),
    Pummel = Spell(6552),
    ShieldBlock = Spell(2565),
    ShieldBlockBuff = Spell(132404),
    ShieldWall = Spell(871),
    Taunt = Spell(355),
    Opressor = Spell(205800),
    Intimidated = Spell(206891),
}


local S = RubimRH.Spell[73]


local ShouldReturn;


local EnemyRanges = {}
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

local function APL()
    local Precombat, Prot
    UpdateRanges()
    Precombat = function()
        -- flask
        -- food
        -- augmentation
        -- snapshot_stats
        -- potion
        -- Battleshout
        if S.BattleShout:IsCastable() and not Player:BuffPvP(S.BattleShout) then
            return S.BattleShout:Cast()
        end
    end
    Prot = function()
        -- potion,if=buff.avatar.up|target.time_to_die<25
        -- avatar
        if S.Avatar:IsReady() and RubimRH.CDsON() and ((S.DemoralizingShout:CooldownUpP() or S.DemoralizingShout:CooldownRemainsP() > 2)) then
            return S.Avatar:Cast()
        end
        -- thunder_clap,if=(talent.unstoppable_force.enabled&buff.avatar.up)
        if S.ThunderClap:IsReady() and (S.UnstoppableForce:IsAvailable() and Player:BuffP(S.Avatar)) then
            return S.ThunderClap:Cast()
        end
        -- shield_block,if=cooldown.shield_slam.ready&buff.shield_block.down&buff.last_stand.down&talent.bolster.enabled
        if S.ShieldBlock:IsReady() and S.ShieldSlam:IsReady() and Player:BuffDownP(S.ShieldBlockBuff) and Player:BuffDownP(S.LastStand) and S.Bolster:IsAvailable() then
            return S.ShieldBlock:Cast()
        end
        -- last_stand,if=cooldown.shield_slam.ready&cooldown.shield_block.charges_fractional<1&buff.shield_block.down&talent.bolster.enabled
        if S.LastStand:IsReady() and S.ShieldSlam:IsReady() and S.ShieldBlock:ChargesFractional() < 1 and Player:BuffDownP(S.ShieldBlockBuff) and S.Bolster:IsAvailable() then
            return S.LastStand:Cast()
        end
        -- ignore_pain,if=rage.deficit<25+20*talent.booming_voice.enabled*cooldown.demoralizing_shout.ready
        if S.IgnorePain:IsReady() and Player:RageDeficit() < 25 + 20 and S.BoomingVoice:IsAvailable() and S.DemoralizingShout:IsReady() then
            return S.IgnorePain:Cast()
        end
        -- shield_slam
        if S.ShieldSlam:IsReady() then
            return S.ShieldSlam:Cast()
        end
        if S.ThunderClap:IsReady() then
            return S.ThunderClap:Cast()
        end
        -- demoralizing_shout,if=talent.booming_voice.enabled
        if S.DemoralizingShout:IsReady() and S.BoomingVoice:IsAvailable() then
            return S.DemoralizingShout:Cast()
        end
        -- ravager
        if S.Ravager:IsReady() then
            return S.Ravager:Cast()
        end
        -- dragon_roar
        if S.DragonRoar:IsReady() then
            return S.DragonRoar:Cast()
        end
        -- revenge
        if S.Revenge:IsReady() then
            return S.Revenge:Cast()
        end
        if S.Devastate:IsReady() then
            return S.Devastate:Cast()
        end

    end
    -- call precombat
    if not Player:AffectingCombat() then
        local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
    end
    if RubimRH.TargetIsValid() then
        -- Pummel
        if S.Pummel:IsReady() and Target:IsInterruptible() and RubimRH.InterruptsON() then
            return S.Pummel:Cast()
        end
        -- Shield Wall
        if S.ShieldWall:IsCastableP() and Player:HealthPercentage() <= 30 then
            return S.ShieldWall:Cast()
        end
		-- Impending Victory -> Cast when < 85% HP
        if S.ImpendingVictory:IsReady("Melee") and Player:HealthPercentage() <= 85 then
            return S.VictoryRush:Cast()
        end
		-- Victory Rush -> Buff about to expire
        if Player:Buff(S.Victorious) and Player:BuffRemains(S.Victorious) <= 2 and S.VictoryRush:IsReady("Melee") then
            return S.VictoryRush:Cast()
        end
        -- auto_attack
        -- intercept
        -- use_item,name=ramping_amplitude_gigavolt_engine
        -- blood_fury
        if S.BloodFury:IsCastableP() and RubimRH.CDsON() then
            return S.BloodFury:Cast()
        end
        -- berserking
        if S.Berserking:IsCastableP() and RubimRH.CDsON() then
            return S.Berserking:Cast()
        end
        -- arcane_torrent
        if S.ArcaneTorrent:IsCastableP() and RubimRH.CDsON() then
            return S.ArcaneTorrent:Cast()
        end
        -- lights_judgment
        if S.LightsJudgment:IsCastableP() and RubimRH.CDsON() then
            return S.LightsJudgment:Cast()
        end
        -- fireblood
        if S.Fireblood:IsCastableP() and RubimRH.CDsON() then
            return S.Fireblood:Cast()
        end
        -- ancestral_call
        if S.AncestralCall:IsCastableP() and RubimRH.CDsON() then
            return S.AncestralCall:Cast()
        end
        -- call_action_list,name=prot
        if (true) then
            local ShouldReturn = Prot(); if ShouldReturn then return ShouldReturn; end
        end
    end
    return 0, 135328
end
RubimRH.Rotation.SetAPL(73, APL);

local function PASSIVE()
    if S.ShieldWall:IsCastable() and Player:HealthPercentage() <= 30 then
        return S.ShieldWall:Cast()
    end
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(73, PASSIVE);
