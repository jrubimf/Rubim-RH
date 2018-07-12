--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
-- AethysCore
local AC = AethysCore
local Cache = AethysCache
local Unit = AC.Unit
local Player = Unit.Player
local Target = Unit.Target
local Pet = Unit.Pet
local Spell = AC.Spell
local Item = AC.Item

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
if not Spell.Monk then Spell.Monk = {} end
Spell.Monk.Brewmaster = {
    ArcaneTorrent = Spell(50613),
    Berserking = Spell(26297),
    BlackoutCombo = Spell(196736),
    BlackoutComboBuff = Spell(228563),
    BlackoutStrike = Spell(205523),
    BlackOxBrew = Spell(115399),
    BloodFury = Spell(20572),
    BreathofFire = Spell(115181),
    BreathofFireDotDebuff = Spell(123725),
    Brews = Spell(115308),
    ChiBurst = Spell(123986),
    ChiWave = Spell(115098),
    DampenHarm = Spell(122278),
    DampenHarmBuff = Spell(122278),
    ExplodingKeg = Spell(214326),
    FortifyingBrew = Spell(115203),
    FortifyingBrewBuff = Spell(115203),
    InvokeNiuzaotheBlackOx = Spell(132578),
    IronskinBrew = Spell(115308),
    IronskinBrewBuff = Spell(215479),
    KegSmash = Spell(121253),
    LightBrewing = Spell(196721),
    PotentKick = Spell(213047),
    PurifyingBrew = Spell(119582),
    RushingJadeWind = Spell(116847),
    TigerPalm = Spell(100780),
    HeavyStagger = Spell(124273),
    ModerateStagger = Spell(124274),
    LightStagger = Spell(124275),
	SpearHandStrike = Spell(116705),
    -- Misc
    PoolEnergy = Spell(9999000010)
};
local S = Spell.Monk.Brewmaster;

-- Items
if not Item.Monk then Item.Monk = {} end
Item.Monk.Brewmaster = {
    ProlongedPower = Item(142117),
    StormstoutsLastGasp = Item((248044), { 3 }),
};
local I = Item.Monk.Brewmaster;

local ForceOffGCD = { true, false };


-- Variables
local BrewmasterToolsEnabled = BrewmasterTools and true or false;
if not BrewmasterToolsEnabled then
    print("Purifying disabled. You need Brewmaster Tools to enable it.");
end

local function ShouldPurify()
    if not BrewmasterToolsEnabled then
        return false;
    end
    local NormalizedStagger = BrewmasterTools.GetNormalStagger();
    local NextStaggerTick = BrewmasterTools.GetNextTick();
    local NStaggerPct = NextStaggerTick > 0 and NextStaggerTick / Player:MaxHealth() or 0;
    local ProgressPct = NormalizedStagger > 0 and Player:Stagger() / NormalizedStagger or 0;
    if NStaggerPct > 0.015 and ProgressPct > 0 then
        if NStaggerPct <= 0.03 then -- Yellow (> 80%)
            return true and ProgressPct > 0.8 or false;
        elseif NStaggerPct <= 0.05 then -- Orange (> 70%)
            return true and NStaggerPct > 0.7 or false;
        elseif NStaggerPct <= 0.1 then -- Red (> 50%)
            return true and ProgressPct > 0.5 or false;
        else -- Magenta
            return true;
        end
    end
end

--- ======= ACTION LISTS =======
local function APL()
    -- Unit Update
    AC.GetEnemies(8, true);

    -- Misc
    local BrewMaxCharge = 3 + (S.LightBrewing:IsAvailable() and 1 or 0);
    local IronskinDuration = (6 + S.PotentKick:ArtifactRank() * 0.5);
    local IsTanking = Player:IsTankingAoE(8) or Player:IsTanking(Target);

    --- Defensives
    -- purifying_brew,if=stagger.heavy|(stagger.moderate&cooldown.brews.charges_fractional>=cooldown.brews.max_charges-0.5&buff.ironskin_brew.remains>=buff.ironskin_brew.duration*2.5)
    if S.PurifyingBrew:IsCastableP() and ShouldPurify() then
        return S.PurifyingBrew:ID()
    end
    -- ironskin_brew,if=buff.blackout_combo.down&cooldown.brews.charges_fractional>=cooldown.brews.max_charges-0.1-(1+buff.ironskin_brew.remains<=buff.ironskin_brew.duration*0.5)&buff.ironskin_brew.remains<=buff.ironskin_brew.duration*2
    -- Note: Extra handling of the charge management only while tanking.
    --       "- (IsTanking and 1 + (Player:BuffRemains(S.IronskinBrewBuff) <= IronskinDuration * 0.5 and 0.5 or 0) or 0)"
    if S.IronskinBrew:IsCastableP() and Player:BuffDownP(S.BlackoutComboBuff)
            and S.Brews:ChargesFractional() >= BrewMaxCharge - 0.1 - (IsTanking and 1 + (Player:BuffRemains(S.IronskinBrewBuff) <= IronskinDuration * 0.5 and 0.5 or 0) or 0)
            and Player:BuffRemains(S.IronskinBrewBuff) <= IronskinDuration * 2 then
        return S.IronskinBrew:ID()
    end
    -- BlackoutCombo Stagger Pause w/ Ironskin Brew
    if S.IronskinBrew:IsCastableP() and Player:BuffP(S.BlackoutComboBuff) and Player:HealingAbsorbed() and ShouldPurify() then
        return S.IronskinBrew:ID()
    end
    -- black_ox_brew,if=incoming_damage_1500ms&stagger.heavy&cooldown.brews.charges_fractional<=0.75
    if S.BlackOxBrew:IsCastableP() and S.Brews:ChargesFractional() <= 0.75 and (ShouldPurify() or Player:BuffRemains(S.IronskinBrewBuff) <= IronskinDuration) then
        return S.BlackOxBrew:ID()
    end

    --- Out of Combat
    if not Player:AffectingCombat() then
        return 0, 462338
    end
	
	--INTERRUPT
	if S.SpearHandStrike:IsCastable() and ShouldInterrupt() then
		GRInterrupt:Show()
	else
		GRInterrupt:Hide()
	end	
	
    --- In Combat
    -- black_ox_brew,if=(energy+(energy.regen*(cooldown.keg_smash.remains)))<40&buff.blackout_combo.down&cooldown.keg_smash.up
    -- black_ox_brew,if=(energy+(energy.regen*cooldown.keg_smash.remains))<40&buff.blackout_combo.down&cooldown.keg_smash.up
    if S.BlackOxBrew:IsCastableP() and (Player:Energy() + (Player:EnergyRegen() * S.KegSmash:CooldownRemainsP())) < 40 and Player:BuffDownP(S.BlackoutComboBuff) and S.KegSmash:CooldownUpP() then
        return S.BlackOxBrew:ID()
    end
    -- blood_fury
    if RubimRH.CDsON() and S.BloodFury:IsCastable("Melee") and S.BloodFury:IsAvailable() then
        return S.BloodFury:ID()
    end
    -- berserking
    if RubimRH.CDsON() and S.Berserking:IsCastable("Melee") and S.Berserking:IsAvailable() then
        return S.Berserking:ID()
    end
    -- invoke_niuzao_the_black_ox
    if S.InvokeNiuzaotheBlackOx:IsCastableP(40) and RubimRH.CDsON() then
        return S.InvokeNiuzaotheBlackOx:ID()
    end
    -- arcane_torrent,if=energy<31
    if RubimRH.CDsON() and S.ArcaneTorrent:IsCastableP() and Player:Energy() < 31 and Cache.EnemiesCount[8] >= 1 then
        return S.ArcaneTorrent:ID()
    end
    -- keg_smash,if=spell_targets>=3
    if S.KegSmash:IsCastableP(25) and Cache.EnemiesCount[8] >= 3 then
        return S.KegSmash:ID()
    end
    -- tiger_palm,if=buff.blackout_combo.up
    if S.TigerPalm:IsCastableP("Melee") and Player:BuffP(S.BlackoutComboBuff) then
        return S.TigerPalm:ID()
    end
    -- keg_smash
    if S.KegSmash:IsCastableP(25) then
        return S.KegSmash:ID()
    end
    -- blackout_strike
    if S.BlackoutStrike:IsCastableP("Melee") then
        return S.BlackoutStrike:ID()
    end
    -- breath_of_fire,if=buff.blackout_combo.down&(buff.bloodlust.down|(buff.bloodlust.up&&dot.breath_of_fire_dot.refreshable))
    if S.BreathofFire:IsCastableP(10, true) and (Player:BuffDownP(S.BlackoutComboBuff) and (Player:HasNotHeroism() or (Player:HasHeroism() and true and Target:DebuffRefreshableCP(S.BreathofFireDotDebuff)))) then
        return S.BreathofFire:ID()
    end
    -- rushing_jade_wind
    if S.RushingJadeWind:IsCastableP() then
        return S.RushingJadeWind:ID()
    end
    -- chi_burst
    if S.ChiBurst:IsCastableP(10) then
        return S.ChiBurst:ID()
    end
    -- chi_wave
    if S.ChiWave:IsCastableP(25) then
        return S.ChiWave:ID()
    end
    -- tiger_palm,if=!talent.blackout_combo.enabled&cooldown.keg_smash.remains>gcd&(energy+(energy.regen*(cooldown.keg_smash.remains+gcd)))>=55
    if S.TigerPalm:IsCastableP("Melee") and (not S.BlackoutCombo:IsAvailable() and S.KegSmash:CooldownRemainsP() > Player:GCD() and (Player:Energy() + (Player:EnergyRegen() * (S.KegSmash:CooldownRemainsP() + Player:GCD()))) >= 55) then
        return S.TigerPalm:ID()
    end
    -- rjw > ks if SLG
    if S.RushingJadeWind:IsCastableP() and I.StormstoutsLastGasp:IsEquipped() and S.RushingJadeWind:CooldownRemainsP() + 0.5 <= S.KegSmash:CooldownRemainsP() then
        return S.RushingJadeWind:ID()
    end
    -- Keg Smash coming back during the next GCD
    if Target:IsInRange(25) and S.KegSmash:CooldownRemainsP() < Player:GCD() then
        return S.KegSmash:ID()
    end
    -- Trick to take in consideration the Recovery Setting
    return 0, 975743
end
RubimRH.Rotation.SetAPL(268, APL);

local function PASSIVE()
    return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(268, PASSIVE);