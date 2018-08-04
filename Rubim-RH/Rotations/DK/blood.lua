--- ============================ HEADER ============================
local addonName, addonTable = ...;
local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;

-- Items
if not Item.DeathKnight then
    Item.DeathKnight = { };
end
Item.DeathKnight.Blood = {
    SephuzSecret = Item(132452, { 11, 12 }), --11/12
}

local S = RubimRH.Spell[250]
S.RuneStrike.TextureSpellID = { S.Blooddrinker:ID() }
local I = Item.DeathKnight.Blood;

--Player:Runes() >= 3
function BloodBurst()
    if S.Consumption:IsReady("Melee") and Cache.EnemiesCount["Melee"] > 1 then
        return S.Consumption:Cast()
    end

    if S.DeathStrike:IsReady("Melee") and Player:RunicPower() >= 80 then
        return S.DeathStrike:Cast()
    end

    if S.BloodBoil:IsReady() and Cache.EnemiesCount[8] >= 1 then
        return S.BloodBoil:Cast()
    end

    if S.HeartStrike:IsReady("Melee") then
        return S.HeartStrike:Cast()
    end

    if S.DeathStrike:IsReady("Melee") then
        return S.DeathStrike:Cast()
    end
end

function DRW()
    if S.Marrowrend:IsReady("Melee") and (Player:BuffStack(S.BoneShield) < 6 or Player:BuffRemains(S.BoneShield) <= 3) then
        return S.Marrowrend:Cast()
    end

    if S.BloodBoil:IsReady() and Cache.EnemiesCount[8] >= 1 and S.BloodBoil:ChargesFractional() >= 1.8 then
        return S.BloodBoil:Cast()
    end

    if RubimRH.config.Spells[1].isActive and S.DeathStrike:IsReady("Melee") and not Player:PrevGCD(1, S.DeathStrike) then
        return S.DeathStrike:Cast()
    end

    if S.HeartStrike:IsReady("Melee") then
        return S.HeartStrike:Cast()
    end

    if RubimRH.config.Spells[1].isActive and S.DeathStrike:IsReady("Melee") then
        return S.DeathStrike:Cast()
    end
end

function saveDS()
end

function runeTAP()
end

local lastSephuz = 0
local function APL()
    ----RANGE
    HL.GetEnemies("Melee");
    HL.GetEnemies(8, true);
    HL.GetEnemies(10, true);
    HL.GetEnemies(20, true);
    local IsTanking = Player:IsTankingAoE(8) or Player:IsTanking(Target);

    if IsTanking and Target:IsCasting(Spell(248499)) and S.RuneTap:IsReady() and S.RuneTap:TimeSinceLastCast() >= 2 then
        return S.RuneTap:Cast()
    end

    ----CHANNEL BLOOD DRINKER
    if Player:IsChanneling(S.Blooddrinker) then
        return 0, 236353
    end

    --NO COMBAT
    if not Player:AffectingCombat() then
        return 0, 462338
    end

    if I.SephuzSecret:IsEquipped() then
        if Player:Buff(S.SephuzBuff) then
            lastSephuz = GetTime()
        end

        --We Should Iterrupt
        if S.MindFreeze:IsReady() and Cache.EnemiesCount[8] >= 1 and Target:IsCasting() and Target:IsInterruptible() and (((GetTime() - lastSephuz) + 9) >= 30 or ((GetTime() - lastSephuz) + 9) <= 15) then
            return S.MindFreeze:Cast()
        end
    end

    --if S.DeathStrike:TimeSinceLastCast() <= Player:GCD() then
    --damageInLast3Seconds = 0
    --end

    LeftCtrl = IsLeftControlKeyDown();
    LeftShift = IsLeftShiftKeyDown();
    LeftAlt = IsLeftAltKeyDown();
    if LeftAlt and S.DeathStrike:IsReady() then
        return S.DeathStrike:Cast()
    end

    -- Units without Blood Plague
    local UnitsWithoutBloodPlague = 0;
    for _, CycleUnit in pairs(Cache.Enemies[10]) do
        if CycleUnit:DebuffRemainsP(S.BloodPlague) <= 3 then
            UnitsWithoutBloodPlague = UnitsWithoutBloodPlague + 1;
        end
    end

    --BloodFury
    if RubimRH.CDsON() and S.BloodFury:IsReady("Melee") and S.BloodFury:IsAvailable() then
        return S.BloodFury:Cast()
    end

    --if not IsTanking and simcraftMode() ~= nil then
    --        return simcraftMode()
    --    end

    --Get Runes
    if S.RuneStrike:IsAvailable() and S.RuneStrike:IsReady("Melee") and Player:Runes() <= 4 then
        return S.RuneStrike:Cast()
    end

    --Needs Marrowrend
    if S.Marrowrend:IsReady("Melee") and (not Player:Buff(S.BoneShield) or Player:BuffRemains(S.BoneShield) <= 3 or Player:BuffStack(S.BoneShield) <= 5) then
        return S.Marrowrend:Cast()
    end

    --Aggro
    if Player:NeedThreat() and S.BloodBoil:IsReady() and Cache.EnemiesCount[8] >=1 then
        return S.BloodBoil:Cast()
    end

    --DSEmergency
    if Player:IncDmgPercentage() > RubimRH.db.profile[250].smartds and S.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= 85 and S.DeathStrike:TimeSinceLastCast() >= Player:GCD() * 2 then
        return S.DeathStrike:Cast()
    end

    --Mechanics
    if S.DeathStrike:IsReady("Melee") and Player:ActiveMitigationNeeded() then
        return S.DeathStrike:Cast()
    end

    --Overcap
    if S.DeathStrike:IsReady("Melee") and Player:RunicPowerDeficit() < RubimRH.db.profile[250].deficitds then
        return S.DeathStrike:Cast()
    end

    --DnD AoE
    if RubimRH.config.Spells[3].isActive and S.DeathandDecay:IsReady(10) and Cache.EnemiesCount[10] >= 3 and Player:IsTankingAoE() then
        return S.DeathandDecay:Cast()
    end

    --BloodBoil
    if Player:IsTankingAoE() and S.BloodBoil:IsReady(10) and Cache.EnemiesCount[10] >= 3 then
        return S.BloodBoil:Cast()
    end

    --Overcap Math
    if S.DeathStrike:IsReady("Melee") and (Player:RunicPower() + (5 + math.min(Cache.EnemiesCount[8], 5) * 2)) >= Player:RunicPowerMax() then
        return S.DeathStrike:Cast()
    end

    --Heal needed
    if S.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= 85 and not RubimRH.config.Spells[1].isActive then
        return S.DeathStrike:Cast()
    end

    --actions.standard+=/death_and_decay,if=talent.rapid_decomposition.enabled&!buff.dancing_rune_weapon.up
    if RubimRH.config.Spells[3].isActive and S.DeathandDecay:IsReady(10) and S.RapidDecomposition:IsAvailable() and not Player:Buff(S.DancingRuneWeaponBuff) then
        return S.DeathandDecay:Cast()
    end

    --actions.standard+=/blooddrinker,if=!buff.dancing_rune_weapon.up
    if S.Blooddrinker:IsReady() and S.Blooddrinker:IsReady() and not Player:Buff(S.DancingRuneWeaponBuff) and Player:BuffRemains(S.BoneShield) >= 3 and Player:Runes() >= 2 then
        return S.Blooddrinker:Cast()
    end

    --actions.standard+=/marrowrend,if=buff.bone_shield.remains<=gcd*2
    if S.Marrowrend:IsReady("Melee") and Player:BuffRemains(S.BoneShield) <= Player:GCD() * 2 then
        return S.Marrowrend:Cast()
    end

    --actions.standard+=/blood_boil,if=charges_fractional>=1.8&buff.haemostasis.stack<5&(buff.haemostasis.stack<3|!buff.dancing_rune_weapon.up)
    if S.BloodBoil:IsReady(10) and (S.BloodBoil:ChargesFractional() >= 1.8 and Player:BuffStack(S.HaemostasisBuff) < 5 and (Player:BuffStack(S.HaemostasisBuff) < 3 or not Player:Buff(S.DancingRuneWeaponBuff))) then
        return S.BloodBoil:Cast()
    end

    --actions.standard+=/marrowrend,if=(buff.bone_shield.stack<5&talent.ossuary.enabled)|buff.bone_shield.remains<gcd*3
    if S.Marrowrend:IsReady("Melee") and ((Player:BuffStack(S.BoneShield) < 5 and S.Ossuary:IsAvailable()) or Player:BuffRemains(S.BoneShield) < Player:GCD() * 3) then
        return S.Marrowrend:Cast()
    end

    --actions.standard+=/bonestorm,if=runic_power>=100&spell_targets.bonestorm>=3
    --actions.standard+=/death_strike,if=buff.blood_shield.up|(runic_power.deficit<15&(runic_power.deficit<25|!buff.dancing_rune_weapon.up))
    --if S.DeathStrike:IsReady("Melee") and not RubimRH.config.Spells[1].isActive and (Player:Buff(S.BloodShield) or (Player:RunicPowerDeficit() < 15 and (Player:RunicPowerDeficit() < 25 or not Player:Buff(S.DancingRuneWeaponBuff)))) then
    --        return S.DeathStrike:Cast()
    --end

    --actions.standard+=/consumption
    if S.Consumption:IsAvailable() and S.Consumption:IsReady("Melee") and Cache.EnemiesCount["Melee"] >= 1 then
        return S.Consumption:Cast()
    end

    --actions.standard+=/heart_strike,if=buff.dancing_rune_weapon.up
    if S.HeartStrike:IsReady("Melee") and Player:Buff(S.DancingRuneWeaponBuff) and not RubimRH.config.Spells[2].isActive then
        return S.HeartStrike:Cast()
    end

    if S.HeartStrike:IsReady("Melee") and Player:Buff(S.DancingRuneWeaponBuff) and RubimRH.config.Spells[2].isActive and Player:Runes() >= 3 then
        return S.HeartStrike:Cast()
    end

    --actions.standard+=/death_and_decay,if=buff.crimson_scourge.up
    if RubimRH.config.Spells[3].isActive and S.DeathandDecay:IsReady(10) and Cache.EnemiesCount[8] >= 1 and Player:Buff(S.CrimsonScourge) and RubimRH.lastMoved() > 0.5 then
        return S.DeathandDecay:Cast()
    end

    --actions.standard+=/blood_boil,if=buff.haemostasis.stack<5&(buff.haemostasis.stack<3|!buff.dancing_rune_weapon.up)
    if S.BloodBoil:IsReady(10) and (S.BloodBoil:ChargesFractional() >= 1.8 and Player:BuffStack(S.HaemostasisBuff) < 5 and (Player:BuffStack(S.HaemostasisBuff) < 3 or not Player:Buff(S.DancingRuneWeaponBuff))) then
        return S.BloodBoil:Cast()
    end
    --actions.standard+=/death_and_decay
    if RubimRH.config.Spells[3].isActive and S.DeathandDecay:IsReady(10) and Cache.EnemiesCount[8] >= 1 and RubimRH.lastMoved() > 0.5 and not RubimRH.config.Spells[2].isActive then
        return S.DeathandDecay:Cast()
    end

    if RubimRH.config.Spells[3].isActive and S.DeathandDecay:IsReady(10) and Cache.EnemiesCount[8] >= 1 and RubimRH.lastMoved() > 0.5 and RubimRH.config.Spells[2].isActive and Player:Runes() >= 3 then
        return S.DeathandDecay:Cast()
    end

    --actions.standard+=/heart_strike,if=rune.time_to_3<gcd|buff.bone_shield.stack>6
    if S.HeartStrike:IsReady("Melee") and ((Player:RuneTimeToX(3) <= Player:GCD()) or Player:BuffStack(S.BoneShield) >= 6) and not RubimRH.config.Spells[2].isActive then
        return S.HeartStrike:Cast()
    end

    if S.HeartStrike:IsReady("Melee") and ((Player:RuneTimeToX(3) <= Player:GCD()) or (Player:BuffStack(S.BoneShield) >= 6 and Player:Runes() >= 3)) and RubimRH.config.Spells[2].isActive then
        return S.HeartStrike:Cast()
    end

    return 0, 135328
end

RubimRH.Rotation.SetAPL(250, APL);

local function PASSIVE()
    if Player:AffectingCombat() then
        if S.IceboundFortitude:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[250].icebound then
            return S.IceboundFortitude:Cast()
        end

        if S.RuneTap:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[250].runetap then
            return S.RuneTap:Cast()
        end

        if S.VampiricBlood:IsReady() and Player:HealthPercentage() <= RubimRH.db.profile[250].vampiricblood then
            return S.VampiricBlood:Cast()
        end

        if RubimRH.Shared() ~= nil then
            return RubimRH.Shared()
        end
    end
end

RubimRH.Rotation.SetPASSIVE(250, PASSIVE);
