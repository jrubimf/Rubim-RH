local function round2(num, idp)
    mult = 10 ^ (idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function ttd(unit)
    unit = unit or "target";
    if thpcurr == nil then
        thpcurr = 0
    end
    if thpstart == nil then
        thpstart = 0
    end
    if timestart == nil then
        timestart = 0
    end
    if UnitExists(unit) and not UnitIsDeadOrGhost(unit) then
        if currtar ~= UnitGUID(unit) then
            priortar = currtar
            currtar = UnitGUID(unit)
        end
        if thpstart == 0 and timestart == 0 then
            thpstart = UnitHealth(unit)
            timestart = GetTime()
        else
            thpcurr = UnitHealth(unit)
            timecurr = GetTime()
            if thpcurr >= thpstart then
                thpstart = thpcurr
                timeToDie = 999
            else
                if ((timecurr - timestart) == 0) or ((thpstart - thpcurr) == 0) then
                    timeToDie = 999
                else
                    timeToDie = round2(thpcurr / ((thpstart - thpcurr) / (timecurr - timestart)), 2)
                end
            end
        end
    elseif not UnitExists(unit) or currtar ~= UnitGUID(unit) then
        currtar = 0
        priortar = 0
        thpstart = 0
        timestart = 0
        timeToDie = 9999999999999999
    end
    if timeToDie == nil then
        return 99999999
    else
        return timeToDie
    end
end

local members = GetNumGroupMembers() - 1
local group = ""
if IsInRaid then
    group = "raid"
else
    group = "party"
end

function TMW.CNDT.Env.partyDying(players, seconds)
    local totalMembersDying = 0
    local member = group .. tostring(i)
    if UnitExists(member) and not UnitIsCorpse(member) and UnitInRange(member) then
        if ttd(member) <= seconds then
            totalMembersDying = totalMembersDying + 1
        end
    end
    if players == totalMembersDying then
        return true
    else
        return false
    end
end

function partyBuffs(spellid, distance)
    local memberBuffs = 0
    local member = group .. tostring(i)
    if UnitExists(member) and not UnitIsCorpse(member) and UnitInRange(member) and UnitAura(member, GetSpellInfo(spellid)) then
        memberBuffs = memberBuffs + 1
    end
    return memberBuffs
end

local customTarget = "target"
local castName, _, _, _, castStartTime, castEndTime, _, _, cantcastInterruptable = UnitCastingInfo(customTarget)
local channelName, _, _, _, channelStartTime, channelEndTime, _, cantchannelInterruptable = UnitChannelInfo(customTarget)

if channelName ~= nil then
    castName = channelName
    castStartTime = channelStartTime
    castEndTime = channelEndTime
    cantcastInterruptable = cantchannelInterruptable
end

if castName ~= nil and cantcastInterruptable == false then
    return true
end

--/dump BuffDuration("pet", 214303)
function BuffDuration(target, spellid)
    local expirationTime = select(7, UnitBuff(target, GetSpellInfo(spellid)));
    if expirationTime == nil then return 0 else
        return expirationTime - GetTime()
    end
end

local gcd = 1.5 / (1 + GetHaste() / 100)
--actions+=/kill_command,target_if=min:bestial_ferocity.remains,if=!talent.dire_frenzy.enabled|(pet.cat.buff.dire_frenzy.remains>gcd.max*1.2|(!pet.cat.buff.dire_frenzy.up&!talent.one_with_the_pack.enabled))(
if GetTalentInfo(2, 2) == false or (BuffDuration("pet", 217200) > gcd or BuffDuration("pet", 217200) == 0 and GetTalentInfo(4, 1) == false) then
    return true
end

--/dump SpellChargesFrac("Fel Rush")
function SpellChargesFrac(spellID)
    local charges, maxCharges, start, duration = GetSpellCharges(spellID)
    if duration and charges ~= maxCharges then
        charges = charges + ((GetTime() - start) / duration)
    end
    --    print(select(2, GetSpellCharges("Fel Rush") - charges * select(1,GetSpellCharges("Fel Rush"))))
    return select(2, GetSpellCharges("Fel Rush")) - charges * select(1, GetSpellCharges("Fel Rush"))
end

local QuestionMark = 212812
local DeathStrike = 49998
local Bonestorm = 194844
ClassSpell1 = QuestionMark
ClassSpell2 = QuestionMark
if select(3, UnitClass("player")) == 6 then
    if GetSpecialization() == 1 then
        ClassSpell1 = DeathStrike
        ClassSpell2 = Bonestorm
    elseif GetSpecialization() == 2 then

    elseif GetSpecialization() == 3 then
    end
end

icon:SetInfo("texture",     GetSpellTexture(ClassSpell1))
print(GetSpellInfo(ClassSpell1) .. ": " ..  tostring(useS1))

print("|cFF69CCF0 ".. GetSpellInfo(ClassSpell1) .. "|r: |cFF00FF00" ..  tostring(useS1))

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
-- Lua
local pairs = pairs;

-- Spell
if not Spell.DemonHunter then Spell.DemonHunter = {}; end
Spell.DemonHunter.Vengeance = {
    -- Abilities
    Felblade = Spell(232893),
    FelDevastation = Spell(212084),
    Fracture = Spell(209795),
    Frailty = Spell(247456),
    ImmolationAura = Spell(178740),
    Sever = Spell(235964),
    Shear = Spell(203782),
    SigilofFlame = Spell(204596),
    SpiritBomb = Spell(247454),
    SoulCleave = Spell(228477),
    SoulFragments = Spell(203981),
    ThrowGlaive = Spell(204157),
    -- Offensive
    SoulCarver = Spell(207407),
    -- Defensive
    FieryBrand = Spell(204021),
    DemonSpikes = Spell(203720),
    DemonSpikesBuff = Spell(203819),
    -- Utility
    ConsumeMagic = Spell(183752),
    InfernalStrike = Spell(189110)
};
local S = Spell.DemonHunter.Vengeance;

-- APL Main
function VengRotation()
    if not Player:AffectingCombat() then
        SetNextAbility("146250")
        return
    end
    SetNextAbility("233159")
    -- Unit Update
    AC.GetEnemies(20, true); -- Fel Devastation (I think it's 20 thp)
    AC.GetEnemies(8, true); -- Sigil of Flame & Spirit Bomb

    -- Misc
    local SoulFragments = Player:BuffStack(S.SoulFragments);
    local IsTanking = Player:IsTankingAoE(8) or Player:IsTanking(Target);

    --- Defensives
    -- Demon Spikes
    if S.DemonSpikes:IsCastable("Melee") and Player:Pain() >= 20 and not Player:Buff(S.DemonSpikesBuff) and (Player:ActiveMitigationNeeded() or Player:HealthPercentage() <= 85) and (IsTanking or not Player:HealingAbsorbed()) then
        SetNextAbility(S.DemonSpikes:ID())
        return
    end

    if S.DemonSpikes:IsCastable("Melee") and Player:Pain() >= 20 and not Player:Buff(S.DemonSpikesBuff) and IsTanking and not Player:HealingAbsorbed() and S.DemonSpikes:ChargesFractional() >= 1.8 then
        SetNextAbility(S.DemonSpikes:ID())
        return
    end
    if S.InfernalStrike:IsCastable("Melee") and S.InfernalStrike:ChargesFractional() > 1.8 then
        SetNextAbility(S.InfernalStrike:ID())
        return
    end
    -- actions+=/spirit_bomb,if=soul_fragments=5|debuff.frailty.down
    -- Note: Looks like the debuff takes time to refresh so we add TimeSinceLastCast to offset that.
    if S.SpiritBomb:IsCastable() and S.SpiritBomb:TimeSinceLastCast() > Player:GCD() * 2 and Cache.EnemiesCount[8] >= 1 and (SoulFragments >= 4 or (Target:DebuffDownP(S.Frailty) and SoulFragments >= 1)) then
        SetNextAbility(S.SpiritBomb:ID())
        return
    end

    if S.FieryBrand:IsCastable("Melee") then
        SetNextAbility(S.FieryBrand:ID())
        return
    end
    -- actions+=/soul_carver
    if S.SoulCarver:IsCastable("Melee") then
        SetNextAbility(S.SoulCarver:ID())
        return
    end
    -- actions+=/immolation_aura,if=pain<=80
    if S.ImmolationAura:IsCastable() and Cache.EnemiesCount[8] >= 1 and not Player:Buff(S.ImmolationAura) and Player:Pain() <= 80 then
        SetNextAbility(S.ImmolationAura:ID())
        return
    end
    -- actions+=/felblade,if=pain<=70
    if S.Felblade:IsCastable(15) and Player:Pain() <= 75 then
        SetNextAbility(S.Felblade:ID())
        return
    end
    -- actions+=/fel_devastation
    if CDsON() and S.FelDevastation:IsCastable(20, true) and GetUnitSpeed("player") == 0 and Player:Pain() >= 30 then
        SetNextAbility(S.FelDevastation:ID())
        return
    end
    -- actions+=/sigil_of_flame
    if S.SigilofFlame:IsCastable() and Cache.EnemiesCount[8] >= 1 then
        SetNextAbility(S.SigilofFlame:ID())
        return
    end
    if Target:IsInRange("Melee") then
        -- actions+=/fracture,if=pain>=60
        if S.Fracture:IsCastable() and Player:Pain() >= 60 then
            SetNextAbility(S.Fracture:ID())
            return
        end
        -- actions+=/soul_cleave,if=pain>=80
        if S.SoulCleave:IsCastable() and not S.SpiritBomb:IsAvailable() and (Player:Pain() >= 80 or SoulFragments >= 5) then
            SetNextAbility(S.SoulCleave:ID())
            return
        end
        -- actions+=/sever
        if S.Sever:IsCastable() then
            --Hacky Stuff
            SetNextAbility(203783)
            return
        end
        -- actions+=/shear
        if S.Shear:IsCastable() then
            SetNextAbility(S.Shear:ID())
            return
        end
    end
    if Target:IsInRange(30) and S.ThrowGlaive:IsCastable() then
        SetNextAbility(S.ThrowGlaive:ID())
        return
    end
    return
end

local f=CreateFrame("Frame")
f:SetScript("OnEvent",function(self,event,...)
    if event=="CHAT_MSG_OPENING" then
        print("OPENING CHAT")
    end

    if event =="TAXIMAP_OPENED" then
        print("TAXI")
    end

end)
f:RegisterEvent("CHAT_MSG_OPENING")
f:RegisterEvent("TAXIMAP_OPENED")