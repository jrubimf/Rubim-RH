--- ============================ HEADER ============================
local addonName, addonTable = ...;
local AC = AethysCore;
local Cache = AethysCache;
local Unit = AC.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = AC.Spell;
local Item = AC.Item;

--- -
if not Spell.DeathKnight then
    Spell.DeathKnight = {};
end
Spell.DeathKnight.Blood = {
    -- Racials
    ArcaneTorrent = Spell(50613),
    Berserking = Spell(26297),
    BloodFury = Spell(20572),
    -- Abilities
    BloodBoil = Spell(50842),
    Blooddrinker = Spell(206931),
    BloodMirror = Spell(206977),
    BloodPlague = Spell(55078),
    BloodShield = Spell(77535),
    BoneShield = Spell(195181),
    Bonestorm = Spell(194844),
    Consumption = Spell(205223),
    CrimsonScourge = Spell(81141),
    DancingRuneWeapon = Spell(49028),
    DancingRuneWeaponBuff = Spell(81256),
    DeathandDecay = Spell(43265),
    DeathsCaress = Spell(195292),
    DeathStrike = Spell(49998),
    HeartBreaker = Spell(221536),
    HeartStrike = Spell(206930),
    Marrowrend = Spell(195182),
    MindFreeze = Spell(47528),
    Ossuary = Spell(219786),
    RapidDecomposition = Spell(194662),
    RuneTap = Spell(194679),
    UmbilicusEternus = Spell(193249),
    VampiricBlood = Spell(55233),
    -- Legendaries
    HaemostasisBuff = Spell(235558),
    SephuzBuff = Spell(208052)
};

-- Items
if not Item.DeathKnight then
    Item.DeathKnight = {};
end
Item.DeathKnight.Blood = {
    SephuzSecret = Item(132452, { 11, 12 }), --11/12
}

local S = Spell.DeathKnight.Blood;
local I = Item.DeathKnight.Blood;

--Player:Runes() >= 3
function BloodBurst()
    if S.Consumption:IsCastableP("Melee") and Cache.EnemiesCount[8] > 1 then
        return S.Consumption:ID()
    end

    if S.DeathStrike:IsReady("Melee") and Player:RunicPower() >= 80 then
        return S.DeathStrike:ID()
    end

    if S.BloodBoil:IsCastable() and Cache.EnemiesCount[10] >= 1 then
        return S.BloodBoil:ID()
    end

    if S.HeartStrike:IsCastableP("Melee") then
        return S.HeartStrike:ID()
    end

    if S.DeathStrike:IsReady("Melee") then
        return S.DeathStrike:ID()
    end
end

function DRW()
    if S.Marrowrend:IsCastableP("Melee") and (Player:BuffStack(S.BoneShield) < 6 or Player:BuffRemains(S.BoneShield) <= 3) then
        return S.Marrowrend:ID()
    end

    if S.BloodBoil:IsCastable() and Cache.EnemiesCount[10] >= 1 and S.BloodBoil:ChargesFractional() >= 1.8 then
        return S.BloodBoil:ID()
    end

    if classSpell[1].isActive and S.DeathStrike:IsReady("Melee") and not Player:PrevGCD(1, S.DeathStrike) then
        return S.DeathStrike:ID()
    end

    if S.HeartStrike:IsCastableP("Melee") then
        return S.HeartStrike:ID()
    end

    if classSpell[1].isActive and S.DeathStrike:IsReady("Melee") then
        return S.DeathStrike:ID()
    end
end

function OFF()
    if S.Marrowrend:IsCastableP("Melee") and (Player:BuffStack(S.BoneShield) < 6 or Player:BuffRemains(S.BoneShield) <= 3) then
        return S.Marrowrend:ID()
    end

    if S.DeathStrike:IsReady("Melee") and Player:RunicPower() >= 80 then
        return S.DeathStrike:ID()
    end

    if S.DeathStrike:IsReady("Melee") and Player:BuffRemains(S.BloodShield) > 0 then
        return S.DeathStrike:ID()
    end

    if S.HeartStrike:IsCastableP("Melee") then
        return S.HeartStrike:ID()
    end
end

local function simcraftMode()
    --actions+=/dancing_rune_weapon,if=(!talent.blooddrinker.enabled|!cooldown.blooddrinker.ready)&!cooldown.death_and_decay.ready
--    if S.DancingRuneWeapo:IsReady() and (not S.Blooddrinker:IsAvailable() or not S.Blooddrinker:IsReady()) and not S.DeathandDecay:IsReady() then
--        return S.DancingRuneWeapon()
    --end

    --actions+=/vampiric_blood,if=!equipped.archimondes_hatred_reborn|cooldown.trinket.ready
    --actions+=/tombstone,if=buff.bone_shield.stack>=7
    --actions+=/call_action_list,name=standard

    --actions.standard=death_strike,if=runic_power.deficit<10
    if S.DeathStrike:IsReady("Melee") and Player:RunicPowerDeficit() < 10 then
        return S.DeathStrike:ID()
    end

    --actions.standard+=/death_and_decay,if=talent.rapid_decomposition.enabled&!buff.dancing_rune_weapon.up
    if classSpell[3].isActive and S.DeathandDecay:IsReady(10) and S.RapidDecomposition:IsAvailable() and not Player:Buff(S.DancingRuneWeaponBuff) then
        return S.DeathandDecay:ID()
    end

    --actions.standard+=/blooddrinker,if=!buff.dancing_rune_weapon.up
    if S.Blooddrinker:IsReady() and not Player:Buff(S.DancingRuneWeaponBuff) then
        return S.Blooddrinker:ID()
    end

    --actions.standard+=/marrowrend,if=buff.bone_shield.remains<=gcd*2
    if S.Marrowrend:IsReady("Melee") and Player:BuffRemains(S.BoneShield) <= Player:GCD() * 2 then
        return S.Marrowrend:ID()
    end

    --actions.standard+=/blood_boil,if=charges_fractional>=1.8&buff.haemostasis.stack<5&(buff.haemostasis.stack<3|!buff.dancing_rune_weapon.up)
    if S.BloodBoil:IsReady(10) and (S.BloodBoil:ChargesFractional() >= 1.8 and Player:BuffStack(S.HaemostasisBuff) < 5 and (Player:BuffStack(S.HaemostasisBuff) < 3 or not Player:Buff(S.DancingRuneWeaponBuff))) then
        return S.BloodBoil:ID()
    end

    --actions.standard+=/marrowrend,if=(buff.bone_shield.stack<5&talent.ossuary.enabled)|buff.bone_shield.remains<gcd*3
    if S.Marrowrend:IsReady("Melee") and ((Player:BuffStack(S.BoneShield) < 5 and S.Ossuary:IsAvailable()) or Player:BuffRemains(S.BoneShield) < Player:GCD() * 3) then
        return S.Marrowrend:ID()
    end

    --actions.standard+=/bonestorm,if=runic_power>=100&spell_targets.bonestorm>=3
    --actions.standard+=/death_strike,if=buff.blood_shield.up|(runic_power.deficit<15&(runic_power.deficit<25|!buff.dancing_rune_weapon.up))
    if S.DeathStrike:IsReady("Melee") and (Player:Buff(S.BloodShield) or (Player:RunicPowerDeficit() < 15 and (Player:RunicPowerDeficit() < 25 or not Player:Buff(S.DancingRuneWeaponBuff)))) then
        return S.DeathStrike:ID()
    end

    --actions.standard+=/consumption
    if S.Consumption:IsReady("Melee") and Cache.EnemiesCount[8] >= 1 then
        return S.Consumption:ID()
    end

    --actions.standard+=/heart_strike,if=buff.dancing_rune_weapon.up
    if S.HeartStrike:IsReady("Melee") and Player:Buff(S.DancingRuneWeaponBuff) and not classSpell[2].isActive then
        return S.HeartStrike:ID()
    end

    --actions.standard+=/death_and_decay,if=buff.crimson_scourge.up
    if classSpell[3].isActive and S.DeathandDecay:IsReady(10) and Cache.EnemiesCount[8] >= 1 and Player:Buff(S.CrimsonScourge) and RubimRH.lastMoved() > 0.5 then
        return S.DeathandDecay:ID()
    end

    --actions.standard+=/blood_boil,if=buff.haemostasis.stack<5&(buff.haemostasis.stack<3|!buff.dancing_rune_weapon.up)
    if S.BloodBoil:IsReady(10) and (S.BloodBoil:ChargesFractional() >= 1.8 and Player:BuffStack(S.HaemostasisBuff) < 5 and (Player:BuffStack(S.HaemostasisBuff) < 3 or not Player:Buff(S.DancingRuneWeaponBuff))) then
        return S.BloodBoil:ID()
    end
    --actions.standard+=/death_and_decay
    if classSpell[3].isActive and S.DeathandDecay:IsReady(10) and Cache.EnemiesCount[8] >= 1 and RubimRH.lastMoved() > 0.5 then
        return S.DeathandDecay:ID()
    end

    --actions.standard+=/heart_strike,if=rune.time_to_3<gcd|buff.bone_shield.stack>6
    if S.HeartStrike:IsReady("Melee") and ((Player:RuneTimeToX(3) <= Player:GCD()) or Player:BuffStack(S.BoneShield) >= 6) then
        return S.HeartStrike:ID()
    end
end

function saveDS()
end

function runeTAP()
end


local lastSephuz = 0
local function APL()
    ----RANGE
    AC.GetEnemies("Melee");
    AC.GetEnemies(8, true);
    AC.GetEnemies(10, true);
    AC.GetEnemies(20, true);
    local IsTanking = Player:IsTankingAoE(8) or Player:IsTanking(Target);


    ----CHANNEL BLOOD DRINKER
    if Player:IsChanneling(S.Blooddrinker) then
        return 0, 236353
    end

    --NO COMBAT
    if not Player:AffectingCombat() then
        return 0, 462338
    end

--    if not IsCurrentSpell(6603) and Cache.EnemiesCount[8] >= 1 then
--        return 58984
--    end

    if I.SephuzSecret:IsEquipped() then
        if Player:Buff(S.SephuzBuff) then
            lastSephuz = GetTime()
        end

        --ShowFrame
        if I.SephuzSecret:IsEquipped() and ((GetTime() - lastSephuz) + 9) >= 30 then
            Sephul:Show()
        else
            Sephul:Hide()
        end

        --We Should Iterrupt
        if S.MindFreeze:IsCastable() and Cache.EnemiesCount[8] >= 1 and Target:IsCasting() and Target:IsInterruptible() and (((GetTime() - lastSephuz) + 9) >= 30 or ((GetTime() - lastSephuz) + 9) <= 15) then
            return S.MindFreeze:ID()
        end
    end

    if S.DeathStrike:TimeSinceLastCast() <= Player:GCD() then
        damageInLast3Seconds = 0
    end

    LeftCtrl = IsLeftControlKeyDown();
    LeftShift = IsLeftShiftKeyDown();
    if LeftCtrl and LeftShift and S.DeathStrike:IsReady() then
        return S.DeathStrike:ID()
    end

    -- Units without Blood Plague
    local UnitsWithoutBloodPlague = 0;
    for _, CycleUnit in pairs(Cache.Enemies[10]) do
        if CycleUnit:DebuffRemainsP(S.BloodPlague) <= 3 then
            UnitsWithoutBloodPlague = UnitsWithoutBloodPlague + 1;
        end
    end

    --BloodFury
    if RubimRH.CDsON() and S.BloodFury:IsCastable("Melee") and S.BloodFury:IsAvailable() then
        return S.BloodFury:ID()
    end

    --if not IsTanking and simcraftMode() ~= nil then
--        return simcraftMode()
--    end

    --Needs Marrowrend
    if S.Marrowrend:IsReady("Melee") and (not Player:Buff(S.BoneShield) or Player:BuffRemains(S.BoneShield) <= 3 or  Player:BuffStack(S.BoneShield) <= 5) then
        return S.Marrowrend:ID()
    end

    --DSEmergency
    if RubimRH.lastDamage("percent") > RubimRH.db.profile.dk.blood.smartds and S.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= 85 then
        return S.DeathStrike:ID()
    end

    --Mechanics
    if S.DeathStrike:IsReady("Melee") and Player:ActiveMitigationNeeded() then
        return S.DeathStrike:ID()
    end

    --Overcap
    if S.DeathStrike:IsReady("Melee") and Player:RunicPowerDeficit() < RubimRH.db.profile.dk.blood.deficitds then
        return S.DeathStrike:ID()
    end

    --Overcap Math
    if S.DeathStrike:IsReady("Melee") and (Player:RunicPower() + (5 + math.min(Cache.EnemiesCount[8], 5) * 2)) >= Player:RunicPowerMax() then
        return S.DeathStrike:ID()
    end

    --Heal needed
    if S.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= 85 and not classSpell[1].isActive then
        return S.DeathStrike:ID()
    end

    --actions.standard+=/death_and_decay,if=talent.rapid_decomposition.enabled&!buff.dancing_rune_weapon.up
    if classSpell[3].isActive and S.DeathandDecay:IsReady(10) and S.RapidDecomposition:IsAvailable() and not Player:Buff(S.DancingRuneWeaponBuff) then
        return S.DeathandDecay:ID()
    end

    --actions.standard+=/blooddrinker,if=!buff.dancing_rune_weapon.up
    if S.Blooddrinker:IsReady() and not Player:Buff(S.DancingRuneWeaponBuff) and Player:BuffRemains(S.BoneShield) >= 3 and Player:Runes() >= 2 then
        return S.Blooddrinker:ID()
    end

    --actions.standard+=/marrowrend,if=buff.bone_shield.remains<=gcd*2
    if S.Marrowrend:IsReady("Melee") and Player:BuffRemains(S.BoneShield) <= Player:GCD() * 2 then
        return S.Marrowrend:ID()
    end

    --actions.standard+=/blood_boil,if=charges_fractional>=1.8&buff.haemostasis.stack<5&(buff.haemostasis.stack<3|!buff.dancing_rune_weapon.up)
    if S.BloodBoil:IsReady(10) and (S.BloodBoil:ChargesFractional() >= 1.8 and Player:BuffStack(S.HaemostasisBuff) < 5 and (Player:BuffStack(S.HaemostasisBuff) < 3 or not Player:Buff(S.DancingRuneWeaponBuff))) then
        return S.BloodBoil:ID()
    end

    --actions.standard+=/marrowrend,if=(buff.bone_shield.stack<5&talent.ossuary.enabled)|buff.bone_shield.remains<gcd*3
    if S.Marrowrend:IsReady("Melee") and ((Player:BuffStack(S.BoneShield) < 5 and S.Ossuary:IsAvailable()) or Player:BuffRemains(S.BoneShield) < Player:GCD() * 3) then
        return S.Marrowrend:ID()
    end

    --actions.standard+=/bonestorm,if=runic_power>=100&spell_targets.bonestorm>=3
    --actions.standard+=/death_strike,if=buff.blood_shield.up|(runic_power.deficit<15&(runic_power.deficit<25|!buff.dancing_rune_weapon.up))
    --if S.DeathStrike:IsReady("Melee") and not classSpell[1].isActive and (Player:Buff(S.BloodShield) or (Player:RunicPowerDeficit() < 15 and (Player:RunicPowerDeficit() < 25 or not Player:Buff(S.DancingRuneWeaponBuff)))) then
    --        return S.DeathStrike:ID()
    --end

    --actions.standard+=/consumption
    if S.Consumption:IsReady("Melee") and Cache.EnemiesCount[8] >= 1 then
        return S.Consumption:ID()
    end

    --actions.standard+=/heart_strike,if=buff.dancing_rune_weapon.up
    if S.HeartStrike:IsReady("Melee") and Player:Buff(S.DancingRuneWeaponBuff) and not classSpell[2].isActive then
        return S.HeartStrike:ID()
    end

    if S.HeartStrike:IsReady("Melee") and Player:Buff(S.DancingRuneWeaponBuff) and classSpell[2].isActive and Player:Runes() >= 3 then
        return S.HeartStrike:ID()
    end

    --actions.standard+=/death_and_decay,if=buff.crimson_scourge.up
    if classSpell[3].isActive and S.DeathandDecay:IsReady(10) and Cache.EnemiesCount[8] >= 1 and Player:Buff(S.CrimsonScourge) and RubimRH.lastMoved() > 0.5 then
        return S.DeathandDecay:ID()
    end

    --actions.standard+=/blood_boil,if=buff.haemostasis.stack<5&(buff.haemostasis.stack<3|!buff.dancing_rune_weapon.up)
    if S.BloodBoil:IsReady(10) and (S.BloodBoil:ChargesFractional() >= 1.8 and Player:BuffStack(S.HaemostasisBuff) < 5 and (Player:BuffStack(S.HaemostasisBuff) < 3 or not Player:Buff(S.DancingRuneWeaponBuff))) then
        return S.BloodBoil:ID()
    end
    --actions.standard+=/death_and_decay
    if classSpell[3].isActive and S.DeathandDecay:IsReady(10) and Cache.EnemiesCount[8] >= 1 and RubimRH.lastMoved() > 0.5 and not classSpell[2].isActive then
        return S.DeathandDecay:ID()
    end

    if classSpell[3].isActive and S.DeathandDecay:IsReady(10) and Cache.EnemiesCount[8] >= 1 and RubimRH.lastMoved() > 0.5 and classSpell[2].isActive and Player:Runes() >= 3 then
        return S.DeathandDecay:ID()
    end

    --actions.standard+=/heart_strike,if=rune.time_to_3<gcd|buff.bone_shield.stack>6
    if S.HeartStrike:IsReady("Melee") and ((Player:RuneTimeToX(3) <= Player:GCD()) or Player:BuffStack(S.BoneShield) >= 6) and not classSpell[2].isActive then
        return S.HeartStrike:ID()
    end

    if S.HeartStrike:IsReady("Melee") and ((Player:RuneTimeToX(3) <= Player:GCD()) or (Player:BuffStack(S.BoneShield) >= 6 and Player:Runes() >= 3)) and classSpell[2].isActive then
        return S.HeartStrike:ID()
    end

    return 0, 975743
end

RubimRH.Rotation.SetAPL(250, APL);

local function PASSIVE()
   return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(250, PASSIVE);