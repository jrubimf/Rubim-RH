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
if not Spell.DeathKnight then Spell.DeathKnight = {};
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
	SephuzBuff			  = Spell(208052),
    -- Misc
    Pool = Spell(9999000010)
};

-- Items
if not Item.DeathKnight then Item.DeathKnight = {};
end
Item.DeathKnight.Blood = {
  SephuzSecret 			      = Item(132452, {11,12}), --11/12
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

    if useS1 and S.DeathStrike:IsReady("Melee") and S.DeathStrike:TimeSinceLastCast() > 1.5 then
        return S.DeathStrike:ID()
        
    end

    if S.HeartStrike:IsCastableP("Melee") then
        return S.HeartStrike:ID()
        
    end

    if useS1 and S.DeathStrike:IsReady("Melee") then
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

function saveDS()
end

function runeTAP()
end

local lastSephuz = 0
function BloodRotation()
	----RANGE
    AC.GetEnemies("Melee");
    AC.GetEnemies(8, true);
    AC.GetEnemies(10, true);
    AC.GetEnemies(20, true);
	----
	
	----CHANNEL BLOOD DRINKER
	if Player:IsChanneling(S.Blooddrinker) then
        return "248999"
    end

	--NO COMBAT
    if not Player:AffectingCombat() then
        return "146250"   
    end
	
	--
	--SPELL QUEUE
	if S.RuneTap:IsCastable() and GetQueueSpell() == S.RuneTap:ID() then
		return S.RuneTap:ID()
	end

	if I.SephuzSecret:IsEquipped() and Player:Buff(S.SephuzBuff) then
		lastSephuz = GetTime()
	end
	
	if I.SephuzSecret:IsEquipped() and ((GetTime() - lastSephuz) + 9) >= 30 then
		Sephul:Show()
	else
		Sephul:Hide()
	end	
	
    if S.MindFreeze:IsCastable() and I.SephuzSecret:IsEquipped() and Cache.EnemiesCount[8] >= 1 and Target:IsCasting() and Target:IsInterruptible() and ((GetTime() - lastSephuz) + 9) >= 30 then
		return S.RuneTap:ID()
	end	
	
	if S.MindFreeze:IsCastable() and I.SephuzSecret:IsEquipped() and Cache.EnemiesCount[8] >= 1 and Target:IsCasting() and Target:IsInterruptible() and ((GetTime() - lastSephuz) + 9) >= 30 then
		return S.RuneTap:ID()
	end	
	
	LeftCtrl= IsLeftControlKeyDown();
	LeftShift = IsLeftShiftKeyDown();
	if LeftCtrl and LeftShift and S.DeathandDecay:IsCastable() then
		return S.DeathandDecay:ID()
		
	end

    -- Units without Blood Plague
    local UnitsWithoutBloodPlague = 0;
    for _, CycleUnit in pairs(Cache.Enemies[10]) do
        if CycleUnit:DebuffRemainsP(S.BloodPlague) <= 3 then
            UnitsWithoutBloodPlague = UnitsWithoutBloodPlague + 1;
        end
    end
	
	if useS1 and S.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= 75 and not Player:HealingAbsorbed() then
        return S.DeathStrike:ID()
    end

    if CDsON() and S.BloodFury:IsCastable("Melee") and S.BloodFury:IsAvailable() then
        return S.BloodFury:ID()
    end

    if not Target:IsDummy() and GetMobsDying() >= 70 then
        if BloodBurst() ~= nil then
            return BloodBurst()
        end
    end

    if Player:Buff(S.DancingRuneWeaponBuff) then
        if DRW() ~= nil then
            return DRW()
        end
    end
    --    if not Player:IsTanking("target") then
    --        OFF()
    --        if GetNextAbility() ~= "233159" then
    --            
    --        end
    --    end
	
    if S.DeathStrike:IsReady("Melee") and Player:RunicPowerDeficit() < 20 then
        return S.DeathStrike:ID()
    end

    if S.Marrowrend:IsCastableP("Melee") and (not Player:Buff(S.BoneShield) or Player:BuffRemains(S.BoneShield) <= 3) then
        return S.Marrowrend:ID()
        
    end

    if S.DeathandDecay:IsReady("Melee") and Cache.EnemiesCount[8] >= 1 then
        return S.DeathandDecay:ID()
    end

    if Target:TimeToDie() >= 20 and Player:Runes() <= 5 and Player:RunicPowerDeficit() <= 30 and Player:Buff(S.CrimsonScourge) then
        return S.DeathandDecay:ID()
    end

    if useS1 and S.DeathStrike:IsReady("Melee") and Player:HealthPercentage() <= 90 and not Player:HealingAbsorbed() then
        return S.DeathStrike:ID()
    end

    if S.DeathStrike:IsReady("Melee") and (Player:RunicPower() + (5 + math.min(Cache.EnemiesCount["Melee"], 5) * 2)) >= Player:RunicPowerMax() then
        return S.DeathStrike:ID()
    end

    if S.BloodBoil:IsCastable() and Cache.EnemiesCount[10] >= 1 and UnitsWithoutBloodPlague >= 1 then
        return S.BloodBoil:ID()
    end
	
	if S.Blooddrinker:IsCastable(10) and AC.CombatTime() > 5 and not Player:HealingAbsorbed() and not Player:Buff(S.DancingRuneWeaponBuff) then
		return S.Blooddrinker:ID()
	end

    if S.BloodBoil:IsCastable() and Cache.EnemiesCount[10] >= 1 and S.BloodBoil:ChargesFractional() >= 1.8 then
        return S.BloodBoil:ID()
    end

    if S.DeathandDecay:IsReady("Melee") and Cache.EnemiesCount[8] >= 1 and Player:Buff(S.CrimsonScourge) then
        return S.DeathandDecay:ID()
    end

    if S.Marrowrend:IsCastableP("Melee") and Player:BuffRemainsP(S.BoneShield) <= Player:GCD() * 2 then
        return S.Marrowrend:ID()
    end

    -- actions.standard+=/blood_boil,if=charges_fractional>=1.8&buff.haemostasis.stack<5&(buff.haemostasis.stack<3|!buff.dancing_rune_weapon.up)
    if S.BloodBoil:IsCastable() and Cache.EnemiesCount[10] >= 1 and S.BloodBoil:ChargesFractional() >= 1.8 then
        return S.BloodBoil:ID()
        
    end
    -- actions.standard+=/marrowrend,if=(buff.bone_shield.stack<5&talent.ossuary.enabled)|buff.bone_shield.remains<gcd*3
    if S.Marrowrend:IsCastableP("Melee") and ((Player:BuffStack(S.BoneShield) < 5 and S.Ossuary:IsAvailable()) or (Player:BuffRemainsP(S.BoneShield) <= Player:GCD() * 3)) then
        return S.Marrowrend:ID()
        
    end

    if S.DeathandDecay:IsReady("Melee") and Cache.EnemiesCount[8] >= 1 and ((Player:RuneTimeToX(3) <= Player:GCD()) or Player:Runes() >= 3) then
        return S.DeathandDecay:ID()
        
    end
    -- actions.standard+=/bonestorm,if=runic_power>=100&spell_targets.bonestorm>=3
    if S.Bonestorm:IsReady() and Cache.EnemiesCount[8] >= 3 and Player:RunicPower() >= 90 then
        return S.Bonestorm:ID()
        
    end

    if S.Consumption:IsCastableP("Melee") and Cache.EnemiesCount[8] >= 1 then
        return S.Consumption:ID()
        
    end

    if S.Marrowrend:IsCastableP("Melee") and Player:BuffStack(S.BoneShield) <= 6 then
        return S.Marrowrend:ID()
        
    end

    if S.HeartStrike:IsCastableP("Melee") and ((Player:RuneTimeToX(3) <= Player:GCD()) or Player:Runes() >= 3) then
        return S.HeartStrike:ID()
        
    end

    if S.BloodBoil:IsCastableP() and Cache.EnemiesCount[10] >= 1 then
        return S.BloodBoil:ID()
        
    end

    if S.DeathandDecay:IsReady("Melee") and Cache.EnemiesCount[8] >= 1 and ((Player:RuneTimeToX(3) <= Player:GCD()) or Player:Runes() >= 3) then
        return S.DeathandDecay:ID()
        
    end

    if S.HeartStrike:IsCastableP("Melee") and (((Player:RuneTimeToX(2) <= Player:GCD()) or Player:BuffStack(S.BoneShield) >= 7) and useS2) then
        return S.HeartStrike:ID()
        
    end
    return 233159
end