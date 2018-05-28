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

--- APL Local Vars
-- Spells
if not Spell.Warrior then Spell.Warrior = {}; end
Spell.Warrior.Protection = {
    -- Racials
    ArcaneTorrent = Spell(69179),
    Berserking = Spell(26297),
    BloodFury = Spell(20572),
    Shadowmeld = Spell(58984),
    -- Abilities
    BattleCry = Spell(1719),
    BerserkerRage = Spell(18499),
    Charge = Spell(100),
    DemoralizingShout = Spell(1160),
    Devastate = Spell(20243),
    FuriousSlash = Spell(100130),
    HeroicLeap = Spell(6544),
    HeroicThrow = Spell(57755),
    Revenge = Spell(6572),
    RevengeB = Spell(5302),
    ShieldSlam = Spell(23922),
    ThunderClap = Spell(6343),
    VictoryRush = Spell(34428),
    Victorious = Spell(32216),
    -- Talents
    ImpendingVictory = Spell(202168),
    Shockwave = Spell(46968),
    Vengeance = Spell(202572),
    VegeanceIP = Spell(202574),
    VegeanceRV = Spell(202573),
    -- Artifact
    NeltharionsFury = Spell(203524),
    -- Defensive
    IgnorePain = Spell(190456),
    LastStand = Spell(12975),
    Pummel = Spell(6552),
    ShieldBlock = Spell(2565),
    ShieldBlockB = Spell(132404),
};
local S = Spell.Warrior.Protection;
-- Items
if not Item.Warrior then Item.Warrior = {}; end
Item.Warrior.Portection = {};
local I = Item.Warrior.Protection;


function AoE()
    if S.IgnorePain:IsCastable() and Player:RageDeficit() <= 50 and not Player:Buff(S.IgnorePain) and S.IgnorePain:TimeSinceLastCast() >= 1.5 and IsTanking then
        return S.IgnorePain:ID()
    end

    if S.Revenge:IsCastable() and S.Revenge:IsReady() and Player:RageDeficit() <= 30 then
        return S.Revenge:ID()
    end

    if S.ThunderClap:IsCastableP() and Cache.EnemiesCount[12] >= 1 then
        return S.ThunderClap:ID()
    end

    if S.ShieldSlam:IsCastableP("Melee") then
        return S.ShieldSlam:ID()
    end

    if S.Devastate:IsCastableP() then
        return S.Devastate:ID()
    end
end

function ProtRotation()
    if not Player:AffectingCombat() then
        return "146250"
    end

	--INTERRUPT
	if S.Pummel:IsCastable() and ShouldInterrupt() then
		GRInterrupt:Show()
	else
		GRInterrupt:Hide()
	end	
	
    AC.GetEnemies("Melee");
    AC.GetEnemies(8, true);
    AC.GetEnemies(10, true);
    AC.GetEnemies(12, true);

    local IsTanking = Player:IsTankingAoE(8) or Player:IsTanking(Target);
    LeftCtrl = IsLeftControlKeyDown();
    LeftShift = IsLeftShiftKeyDown();
    if LeftCtrl and LeftShift and S.Shockwave:IsCastable() then
        return S.Shockwave:ID()
    end

    if S.BattleCry:IsCastable() and Cache.EnemiesCount[8] >= 1 then
        return S.BattleCry:ID()
    end

    if S.IgnorePain:IsCastable() and Player:RageDeficit() <= 50 and not Player:Buff(S.IgnorePain) and S.IgnorePain:TimeSinceLastCast() >= 1.5 and IsTanking then
        return S.IgnorePain:ID()
    end

    if S.ShieldBlock:IsCastable("Melee") and Player:Rage() >= 15 and not Player:Buff(S.ShieldBlockB) and IsTanking and S.ShieldBlock:ChargesFractional() >= 1.8 then
        return S.ShieldBlock:ID()
    end

    if S.ImpendingVictory:IsCastable() and Player:HealthPercentage() <= 85 then
        return S.VictoryRush:ID()
    end

    if Player:Buff(S.Victorious) and S.VictoryRush:IsCastable() and Player:HealthPercentage() <= 85 then
        return S.VictoryRush:ID()
    end

    if Player:Buff(S.Victorious) and Player:BuffRemains(S.Victorious) <= 2 and S.VictoryRush:IsCastable() then
        return S.VictoryRush:ID()
    end

    if Player:Buff(S.Victorious) and S.ImpendingVictory:IsCastable() and Player:HealthPercentage() <= 85 then
        return S.VictoryRush:ID()
    end

    if Player:Buff(S.Victorious) and Player:BuffRemains(S.Victorious) <= 2 and S.ImpendingVictory:IsCastable() then
        return S.VictoryRush:ID()
    end

    if S.Revenge:IsCastable() and Player:RageDeficit() <= 30 and Cache.EnemiesCount[8] >= 1 then
        return S.Revenge:ID()
    end

    if Cache.EnemiesCount[12] >= 3 and useAoE then
        if AoE() ~= nil then
            return AoE()
        end
    end

    if S.ShieldSlam:IsCastableP("Melee") then
        return S.ShieldSlam:ID()
    end

    if S.ThunderClap:IsCastableP() and Cache.EnemiesCount[12] >= 1 then
        return S.ThunderClap:ID()
    end

    if not S.Vengeance:IsAvailable() and S.Revenge:IsCastableP() and Player:Buff(S.RevengeB) and Cache.EnemiesCount[8] >= 1 then
        return S.Revenge:ID()
    end

    if S.Devastate:IsCastableP() then
        return S.Devastate:ID()
    end
    return "233159"
end