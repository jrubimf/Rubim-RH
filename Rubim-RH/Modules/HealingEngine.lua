local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;

members = {}

local function CalculateHP(t)
    incomingheals = UnitGetIncomingHeals(t) and UnitGetIncomingHeals(t) or 0
    local PercentWithIncoming = 100 * (UnitHealth(t) + incomingheals) / UnitHealthMax(t)
    local ActualWithIncoming = (UnitHealthMax(t) - (UnitHealth(t) + incomingheals))
    return PercentWithIncoming, ActualWithIncoming
end

local function CanHeal(t)
    if UnitInRange(t)
            --Missing LOS Check
            and UnitCanCooperate("player", t)
            and not UnitIsCharmed(t)
            and not UnitIsDeadOrGhost(t)
            and UnitIsConnected(t)
    --          and UnitDebuffID(t,104451) == nil -- Ice Tomb
    --          and UnitDebuffID(t,76577) == nil -- Smoke Bomb
    then
        return true
    else
        return false
    end
end

local function Grouped(t)
    if  CheckInteractDistance(t, 3)
    then
        return true
    else
        return false
    end
end

--dump GroupedMed(90)
function GroupedBelow(HP)
    local total = #R_Stacked
    local totalMed = 0

    if Player:HealthPercentage() <= HP then
        totalMed = totalMed + 1
    end

    for i, unit in pairs(R_Stacked) do
        if unit.HP <= HP then
            totalMed = totalMed + 1
        end
    end

    if totalMed == 0 then
        return 0
    end

    return totalMed
end


local function HealingEngine(MO, ACTUALHP)
    R_Tanks = {}
    R_DPS = {}
    R_Heal = {}
    R_Stacked = {}

    local MouseoverCheck = MO or false
    local ActualHP = ACTUALHP or false
    members = { { Unit = "player", HP = CalculateHP("player"), GUID = UnitGUID("player"), AHP = select(2, CalculateHP("player")) } }

    -- Check if the Player is apart of the Custom Table
    for i = 1, #R_CustomT do
        if UnitGUID("player") == R_CustomT[i].GUID then
            R_CustomT[i].Unit = "player"
            R_CustomT[i].HP = CalculateHP("player")
            R_CustomT[i].AHP = select(2, CalculateHP("player"))
        end
    end

    if IsInRaid() then
        group = "raid"
    elseif IsInGroup() then
        group = "party"
    end

    for i = 1, GetNumGroupMembers() do
        local member, memberhp = group .. i, CalculateHP(group .. i)

        -- Checking all Party/Raid Members for Range/Health
        if CanHeal(member) then

            if Grouped(member) then
                table.insert(R_Stacked, { Unit = member, HP = memberhp, AHP = select(2, CalculateHP(member)) })
            end

            -- Checking if Member has threat
            if UnitThreatSituation(member) == 3 then
                memberhp = memberhp - 3
            end
            -- Checking if Member has Beacon on them
            --if UnitAura(member, GetSpellInfo(53563)) then
            --  memberhp = memberhp + 3
            --end
            -- Searing Plasma Check
            --          if UnitDebuffID(member, 109379) then memberhp = memberhp - 9 end
            -- Checking if Member isa tank
            if UnitGroupRolesAssigned(member) == "TANK" then
                memberhp = memberhp - 2
                table.insert(R_Tanks, { Unit = member, HP = memberhp, AHP = select(2, CalculateHP(member)) })
            end

            if UnitGroupRolesAssigned(member) == "DPS" then
                memberhp = memberhp - 1
                table.insert(R_DPS, { Unit = member, HP = memberhp, AHP = select(2, CalculateHP(member)) })
            end

            if UnitGroupRolesAssigned(member) == "HEAL" then
                memberhp = memberhp - 1
                table.insert(R_DPS, { Unit = member, HP = memberhp, AHP = select(2, CalculateHP(member)) })
            end
            -- If they are in the Custom Table add their info in
            for i = 1, #R_CustomT do
                if UnitGUID(member) == R_CustomT[i].GUID then
                    R_CustomT[i].Unit = member
                    R_CustomT[i].HP = memberhp
                    R_CustomT[i].AHP = select(2, CalculateHP(member))
                end
            end
            table.insert(members, { Unit = group .. i, HP = memberhp, GUID = UnitGUID(group .. i), AHP = select(2, CalculateHP(group .. i)) })
        end

        -- Checking Pets in the group
        if CanHeal(group .. i .. "pet") then
            local memberpet, memberpethp = nil, nil
            if UnitAffectingCombat("player") then
                memberpet = group .. i .. "pet"
                memberpethp = CalculateHP(group .. i .. "pet") * 2
            else
                memberpet = group .. i .. "pet"
                memberpethp = CalculateHP(group .. i .. "pet")
            end

            -- Checking if Pet is apart of the CustomTable
            for i = 1, #R_CustomT do
                if UnitGUID(memberpet) == R_CustomT[i].GUID then
                    R_CustomT[i].Unit = memberpet
                    R_CustomT[i].HP = memberpethp
                    R_CustomT[i].AHP = select(2, CalculateHP(memberpet))
                end
            end
            table.insert(members, { Unit = memberpet, HP = memberpethp, GUID = UnitGUID(memberpet), AHP = select(2, CalculateHP(memberpet)) })
        end
    end

    -- So if we pass that ActualHP is true, then we will sort by most health missing. If not, we sort by lowest % of health.
    if not ActualHP then
        table.sort(members, function(x, y)
            return x.HP < y.HP
        end)
        if #R_Tanks > 0 then
            table.sort(R_Tanks, function(x, y)
                return x.HP < y.HP
            end)
        end
    elseif ActualHP then
        table.sort(members, function(x, y)
            return x.AHP > y.AHP
        end)
        if #R_Tanks > 0 then
            table.sort(R_Tanks, function(x, y)
                return x.AHP > y.AHP
            end)
        end
    end
end

R_CustomT = { }
local t = GetTime()
if t - GetTime() <= 0.2 then
    t = GetTime()
end

function LowestTank(option)
    if #R_Tanks == 0 then
        if option == "GUID" then
            return "NoGuid"
        end

        if option == 'HP' then
            return 1000
        end

        if option == 'UnitID' then
            return "NoUnit"
        end
    end

    if option == "GUID" then
        return R_Tanks[1].GUID or "NoGuid"
    end

    if option == 'HP' then
        return R_Tanks[1].HP or 1000
    end

    if option == 'UnitID' then
        return R_Tanks[1].Unit or "NoUnit"
    end
end

function LowestHeal(option)
    if #R_Heal == 0 then
        if option == "GUID" then
            return "NoGuid"
        end

        if option == 'HP' then
            return 1000
        end

        if option == 'UnitID' then
            return "NoUnit"
        end
    end

    if option == "GUID" then
        return R_Heal[1].GUID or "NoGuid"
    end

    if option == 'HP' then
        return R_Heal[1].HP or 1000
    end

    if option == 'UnitID' then
        return R_Heal[1].Unit or "NoUnit"
    end
end

function LowestDPS(option)
    if #R_DPS == 0 then
        if option == "GUID" then
            return "NoGuid"
        end

        if option == 'HP' then
            return 1000
        end

        if option == 'UnitID' then
            return "NoUnit"
        end
    end

    if option == "GUID" then
        return R_DPS[1].GUID or "NoGuid"
    end

    if option == 'HP' then
        return R_DPS[1].HP or 1000
    end

    if option == 'UnitID' then
        return R_DPS[1].Unit or "NoUnit"
    end
end

function LowestAll(option)
    if #members == 0 then
        if option == "GUID" then
            return "NoGuid"
        end

        if option == 'HP' then
            return 1000
        end

        if option == 'UnitID' then
            return "NoUnit"
        end
    end

    if option == "GUID" then
        return members[1].GUID or "NoGUID"
    end

    if option == 'HP' then
        return members[1].HP or 1000
    end

    if option == 'UnitID' then
        return members[1].Unit or "NoUnit"
    end
end

function LowestAlly(target, option)
    if target == "TANK" then
        return LowestTank(option)
    end

    if target == "DPS" then
        return LowestDPS(option)
    end

    if target == "HEAL" then
        return LowestHeal(option)
    end

    if target == "ALL" then
        return LowestAll(option)
    end
end

healingTarget = "None"
healingTargetG = "None"
function ForceHealingTarget(TARGET)
    local target = TARGET or nil
    healingTarget = "None"
    healingTargetG = "None"
    showHealingColor(healingTarget)

    if TARGET == "TANK" then
        healingTarget = R_Tanks[1].Unit
        healingTargetG = R_Tanks[1].GUID
        showHealingColor(healingTarget)
        return
    end

    if TARGET == "DPS" and R_DPS[1].HP < hp then
        healingTarget = R_DPS[1].Unit
        healingTargetG = R_DPS[1].GUID
        showHealingColor(healingTarget)
        return
    end

    if TARGET == "HEAL" and R_HEAL[1].HP < hp then
        healingTarget = R_HEAL[1].Unit
        healingTargetG = R_HEAL[1].GUID
        showHealingColor(healingTarget)
        return
    end

    if TARGET == "ALL" and members[1].HP < 99 then
        healingTarget = members[1].Unit
        healingTargetG = members[1].GUID
        showHealingColor(healingTarget)
        return
    end
end

function setHealingTarget(TARGET, HP)
    local target = TARGET or nil

    if TARGET == "TANK" then
        healingTarget = R_Tanks[1].Unit
        healingTargetG = R_Tanks[1].GUID
        return
    end

    if TARGET == "DPS" and R_DPS[1].HP < hp then
        healingTarget = R_DPS[1].Unit
        healingTargetG = R_DPS[1].GUID
        return
    end

    if TARGET == "HEAL" and R_HEAL[1].HP < hp then
        healingTarget = R_HEAL[1].Unit
        healingTargetG = R_HEAL[1].GUID
        return
    end

    if TARGET == nil and members[1].HP < 99 then
        healingTarget = members[1].Unit
        healingTargetG = members[1].GUID
        return
    end
    healingTarget = "None"
    healingTargetG = "None"
end

function showHealingColor(healingTarget)
    --Default START COLOR
    TargetColor.texture:SetColorTexture(0, 0, 0, 1.0)
    if healingTarget == "None" then
        TargetColor.texture:SetColorTexture(0, 0, 0, 1.0)
    end

    --Party
    if healingTarget == "party1" then
        TargetColor.texture:SetColorTexture(0.345098, 0.239216, 0.741176, 1.0)
        return
    end
    if healingTarget == "party2" then
        TargetColor.texture:SetColorTexture(0.407843, 0.501961, 0.086275, 1.0)
        return
    end
    if healingTarget == "party3" then
        TargetColor.texture:SetColorTexture(0.160784, 0.470588, 0.164706, 1.0)
        return
    end
    if healingTarget == "party4" then
        TargetColor.texture:SetColorTexture(0.725490, 0.572549, 0.647059, 1.0)
        return
    end

    --PartyPET
    if healingTarget == "partypet1" then
        TargetColor.texture:SetColorTexture(0.486275, 0.176471, 1.000000, 1.0)
        return
    end
    if healingTarget == "partypet2" then
        TargetColor.texture:SetColorTexture(0.031373, 0.572549, 0.152941, 1.0)
        return
    end
    if healingTarget == "partypet3" then
        TargetColor.texture:SetColorTexture(0.874510, 0.239216, 0.239216, 1.0)
        return
    end
    if healingTarget == "partypet4" then
        TargetColor.texture:SetColorTexture(0.117647, 0.870588, 0.635294, 1.0)
        return
    end

    --Raid
    if healingTarget == "raid1" then
        TargetColor.texture:SetColorTexture(0.192157, 0.878431, 0.015686, 1.0)
        return
    end
    if healingTarget == "raid2" then
        TargetColor.texture:SetColorTexture(0.780392, 0.788235, 0.745098, 1.0)
        return
    end
    if healingTarget == "raid3" then
        TargetColor.texture:SetColorTexture(0.498039, 0.184314, 0.521569, 1.0)
        return
    end
    if healingTarget == "raid4" then
        TargetColor.texture:SetColorTexture(0.627451, 0.905882, 0.882353, 1.0)
        return
    end
    if healingTarget == "raid5" then
        TargetColor.texture:SetColorTexture(0.145098, 0.658824, 0.121569, 1.0)
        return
    end
    if healingTarget == "raid6" then
        TargetColor.texture:SetColorTexture(0.639216, 0.490196, 0.921569, 1.0)
        return
    end
    if healingTarget == "raid7" then
        TargetColor.texture:SetColorTexture(0.172549, 0.368627, 0.427451, 1.0)
        return
    end
    if healingTarget == "raid8" then
        TargetColor.texture:SetColorTexture(0.949020, 0.333333, 0.980392, 1.0)
        return
    end
    if healingTarget == "raid9" then
        TargetColor.texture:SetColorTexture(0.109804, 0.388235, 0.980392, 1.0)
        return
    end
    if healingTarget == "raid10" then
        TargetColor.texture:SetColorTexture(0.615686, 0.694118, 0.435294, 1.0)
        return
    end
    if healingTarget == "raid11" then
        TargetColor.texture:SetColorTexture(0.066667, 0.243137, 0.572549, 1.0)
        return
    end
    if healingTarget == "raid12" then
        TargetColor.texture:SetColorTexture(0.113725, 0.129412, 1.000000, 1.0)
        return
    end
    if healingTarget == "raid13" then
        TargetColor.texture:SetColorTexture(0.592157, 0.023529, 0.235294, 1.0)
        return
    end
    if healingTarget == "raid14" then
        TargetColor.texture:SetColorTexture(0.545098, 0.439216, 1.000000, 1.0)
        return
    end
    if healingTarget == "raid15" then
        TargetColor.texture:SetColorTexture(0.890196, 0.800000, 0.854902, 1.0)
        return
    end
    if healingTarget == "raid16" then
        TargetColor.texture:SetColorTexture(0.513725, 0.854902, 0.639216, 1.0)
        return
    end
    if healingTarget == "raid17" then
        TargetColor.texture:SetColorTexture(0.078431, 0.541176, 0.815686, 1.0)
        return
    end
    if healingTarget == "raid18" then
        TargetColor.texture:SetColorTexture(0.109804, 0.184314, 0.666667, 1.0)
        return
    end
    if healingTarget == "raid19" then
        TargetColor.texture:SetColorTexture(0.650980, 0.572549, 0.098039, 1.0)
        return
    end
    if healingTarget == "raid20" then
        TargetColor.texture:SetColorTexture(0.541176, 0.466667, 0.027451, 1.0)
        return
    end
    if healingTarget == "raid21" then
        TargetColor.texture:SetColorTexture(0.000000, 0.988235, 0.462745, 1.0)
        return
    end
    if healingTarget == "raid22" then
        TargetColor.texture:SetColorTexture(0.211765, 0.443137, 0.858824, 1.0)
        return
    end
    if healingTarget == "raid23" then
        TargetColor.texture:SetColorTexture(0.949020, 0.949020, 0.576471, 1.0)
        return
    end
    if healingTarget == "raid24" then
        TargetColor.texture:SetColorTexture(0.972549, 0.800000, 0.682353, 1.0)
        return
    end
    if healingTarget == "raid25" then
        TargetColor.texture:SetColorTexture(0.031373, 0.619608, 0.596078, 1.0)
        return
    end
    if healingTarget == "raid26" then
        TargetColor.texture:SetColorTexture(0.670588, 0.925490, 0.513725, 1.0)
        return
    end
    if healingTarget == "raid27" then
        TargetColor.texture:SetColorTexture(0.647059, 0.945098, 0.031373, 1.0)
        return
    end
    if healingTarget == "raid28" then
        TargetColor.texture:SetColorTexture(0.058824, 0.490196, 0.054902, 1.0)
        return
    end
    if healingTarget == "raid29" then
        TargetColor.texture:SetColorTexture(0.050980, 0.992157, 0.239216, 1.0)
        return
    end
    if healingTarget == "raid30" then
        TargetColor.texture:SetColorTexture(0.949020, 0.721569, 0.388235, 1.0)
        return
    end
    if healingTarget == "raid31" then
        TargetColor.texture:SetColorTexture(0.254902, 0.749020, 0.627451, 1.0)
        return
    end
    if healingTarget == "raid32" then
        TargetColor.texture:SetColorTexture(0.470588, 0.454902, 0.603922, 1.0)
        return
    end
    if healingTarget == "raid33" then
        TargetColor.texture:SetColorTexture(0.384314, 0.062745, 0.266667, 1.0)
        return
    end
    if healingTarget == "raid34" then
        TargetColor.texture:SetColorTexture(0.639216, 0.168627, 0.447059, 1.0)
        return
    end
    if healingTarget == "raid35" then
        TargetColor.texture:SetColorTexture(0.874510, 0.058824, 0.400000, 1.0)
        return
    end
    if healingTarget == "raid36" then
        TargetColor.texture:SetColorTexture(0.925490, 0.070588, 0.713725, 1.0)
        return
    end
    if healingTarget == "raid37" then
        TargetColor.texture:SetColorTexture(0.098039, 0.803922, 0.905882, 1.0)
        return
    end
    if healingTarget == "raid38" then
        TargetColor.texture:SetColorTexture(0.243137, 0.015686, 0.325490, 1.0)
        return
    end
    if healingTarget == "raid39" then
        TargetColor.texture:SetColorTexture(0.847059, 0.376471, 0.921569, 1.0)
        return
    end
    if healingTarget == "raid40" then
        TargetColor.texture:SetColorTexture(0.341176, 0.533333, 0.231373, 1.0)
        return
    end
    if healingTarget == "raidpet1" then
        TargetColor.texture:SetColorTexture(0.458824, 0.945098, 0.784314, 1.0)
        return
    end
    if healingTarget == "raidpet2" then
        TargetColor.texture:SetColorTexture(0.239216, 0.654902, 0.278431, 1.0)
        return
    end
    if healingTarget == "raidpet3" then
        TargetColor.texture:SetColorTexture(0.537255, 0.066667, 0.905882, 1.0)
        return
    end
    if healingTarget == "raidpet4" then
        TargetColor.texture:SetColorTexture(0.333333, 0.415686, 0.627451, 1.0)
        return
    end
    if healingTarget == "raidpet5" then
        TargetColor.texture:SetColorTexture(0.576471, 0.811765, 0.011765, 1.0)
        return
    end
    if healingTarget == "raidpet6" then
        TargetColor.texture:SetColorTexture(0.517647, 0.164706, 0.627451, 1.0)
        return
    end
    if healingTarget == "raidpet7" then
        TargetColor.texture:SetColorTexture(0.439216, 0.074510, 0.941176, 1.0)
        return
    end
    if healingTarget == "raidpet8" then
        TargetColor.texture:SetColorTexture(0.984314, 0.854902, 0.376471, 1.0)
        return
    end
    if healingTarget == "raidpet9" then
        TargetColor.texture:SetColorTexture(0.082353, 0.286275, 0.890196, 1.0)
        return
    end
    if healingTarget == "raidpet10" then
        TargetColor.texture:SetColorTexture(0.058824, 0.003922, 0.964706, 1.0)
        return
    end
    if healingTarget == "raidpet11" then
        TargetColor.texture:SetColorTexture(0.956863, 0.509804, 0.949020, 1.0)
        return
    end
    if healingTarget == "raidpet12" then
        TargetColor.texture:SetColorTexture(0.474510, 0.858824, 0.031373, 1.0)
        return
    end
    if healingTarget == "raidpet13" then
        TargetColor.texture:SetColorTexture(0.509804, 0.882353, 0.423529, 1.0)
        return
    end
    if healingTarget == "raidpet14" then
        TargetColor.texture:SetColorTexture(0.337255, 0.647059, 0.427451, 1.0)
        return
    end
    if healingTarget == "raidpet15" then
        TargetColor.texture:SetColorTexture(0.611765, 0.525490, 0.352941, 1.0)
        return
    end
    if healingTarget == "raidpet16" then
        TargetColor.texture:SetColorTexture(0.921569, 0.129412, 0.913725, 1.0)
        return
    end
    if healingTarget == "raidpet17" then
        TargetColor.texture:SetColorTexture(0.117647, 0.933333, 0.862745, 1.0)
        return
    end
    if healingTarget == "raidpet18" then
        TargetColor.texture:SetColorTexture(0.733333, 0.015686, 0.937255, 1.0)
        return
    end
    if healingTarget == "raidpet19" then
        TargetColor.texture:SetColorTexture(0.819608, 0.392157, 0.686275, 1.0)
        return
    end
    if healingTarget == "raidpet20" then
        TargetColor.texture:SetColorTexture(0.823529, 0.976471, 0.541176, 1.0)
        return
    end
    if healingTarget == "raidpet21" then
        TargetColor.texture:SetColorTexture(0.043137, 0.305882, 0.800000, 1.0)
        return
    end
    if healingTarget == "raidpet22" then
        TargetColor.texture:SetColorTexture(0.737255, 0.270588, 0.760784, 1.0)
        return
    end
    if healingTarget == "raidpet23" then
        TargetColor.texture:SetColorTexture(0.807843, 0.368627, 0.058824, 1.0)
        return
    end
    if healingTarget == "raidpet24" then
        TargetColor.texture:SetColorTexture(0.364706, 0.078431, 0.078431, 1.0)
        return
    end
    if healingTarget == "raidpet25" then
        TargetColor.texture:SetColorTexture(0.094118, 0.901961, 1.000000, 1.0)
        return
    end
    if healingTarget == "raidpet26" then
        TargetColor.texture:SetColorTexture(0.772549, 0.690196, 0.047059, 1.0)
        return
    end
    if healingTarget == "raidpet27" then
        TargetColor.texture:SetColorTexture(0.415686, 0.784314, 0.854902, 1.0)
        return
    end
    if healingTarget == "raidpet28" then
        TargetColor.texture:SetColorTexture(0.470588, 0.733333, 0.047059, 1.0)
        return
    end
    if healingTarget == "raidpet29" then
        TargetColor.texture:SetColorTexture(0.619608, 0.086275, 0.572549, 1.0)
        return
    end
    if healingTarget == "raidpet30" then
        TargetColor.texture:SetColorTexture(0.517647, 0.352941, 0.678431, 1.0)
        return
    end
    if healingTarget == "raidpet31" then
        TargetColor.texture:SetColorTexture(0.003922, 0.149020, 0.694118, 1.0)
        return
    end
    if healingTarget == "raidpet32" then
        TargetColor.texture:SetColorTexture(0.454902, 0.619608, 0.831373, 1.0)
        return
    end
    if healingTarget == "raidpet33" then
        TargetColor.texture:SetColorTexture(0.674510, 0.741176, 0.050980, 1.0)
        return
    end
    if healingTarget == "raidpet34" then
        TargetColor.texture:SetColorTexture(0.560784, 0.713725, 0.784314, 1.0)
        return
    end
    if healingTarget == "raidpet35" then
        TargetColor.texture:SetColorTexture(0.400000, 0.721569, 0.737255, 1.0)
        return
    end
    if healingTarget == "raidpet36" then
        TargetColor.texture:SetColorTexture(0.094118, 0.274510, 0.392157, 1.0)
        return
    end
    if healingTarget == "raidpet37" then
        TargetColor.texture:SetColorTexture(0.298039, 0.498039, 0.462745, 1.0)
        return
    end
    if healingTarget == "raidpet38" then
        TargetColor.texture:SetColorTexture(0.125490, 0.196078, 0.027451, 1.0)
        return
    end
    if healingTarget == "raidpet39" then
        TargetColor.texture:SetColorTexture(0.937255, 0.564706, 0.368627, 1.0)
        return
    end
    if healingTarget == "raidpet40" then
        TargetColor.texture:SetColorTexture(0.929412, 0.592157, 0.501961, 1.0)
        return
    end

    --Stuff
    if healingTarget == "player" then
        TargetColor.texture:SetColorTexture(0.788235, 0.470588, 0.858824, 1.0)
        return
    end
    if healingTarget == "focus" then
        TargetColor.texture:SetColorTexture(0.615686, 0.227451, 0.988235, 1.0)
        return
    end
    if healingTarget == PLACEHOLDER then
        TargetColor.texture:SetColorTexture(0.411765, 0.760784, 0.176471, 1.0)
        return
    end
    if healingTarget == PLACEHOLDER then
        TargetColor.texture:SetColorTexture(0.780392, 0.286275, 0.415686, 1.0)
        return
    end
    if healingTarget == PLACEHOLDER then
        TargetColor.texture:SetColorTexture(0.584314, 0.811765, 0.956863, 1.0)
        return
    end
    if healingTarget == PLACEHOLDER then
        TargetColor.texture:SetColorTexture(0.513725, 0.658824, 0.650980, 1.0)
        return
    end
    if healingTarget == PLACEHOLDER then
        TargetColor.texture:SetColorTexture(0.913725, 0.180392, 0.737255, 1.0)
        return
    end
    if healingTarget == PLACEHOLDER then
        TargetColor.texture:SetColorTexture(0.576471, 0.250980, 0.160784, 1.0)
        return
    end
    if healingTarget == PLACEHOLDER then
        TargetColor.texture:SetColorTexture(0.803922, 0.741176, 0.874510, 1.0)
        return
    end
    if healingTarget == PLACEHOLDER then
        TargetColor.texture:SetColorTexture(0.647059, 0.874510, 0.713725, 1.0)
        return
    end
    if healingTarget == PLACEHOLDER then
        --was party5
        TargetColor.texture:SetColorTexture(0.007843, 0.301961, 0.388235, 1.0)
        return
    end
    if healingTarget == PLACEHOLDER then
        --was party5pet
        TargetColor.texture:SetColorTexture(0.572549, 0.705882, 0.984314, 1.0)
        return
    end
end

function setColorTarget()
    if TargetColor == nil then
        return
    end

    --Default START COLOR
    TargetColor.texture:SetColorTexture(0, 0, 0, 1.0)

    --If we have a mouseover target, stop healing (kinda of dangerous)
    if CanHeal("mouseover") and GetMouseFocus() ~= WorldFrame and MouseoverCheck then
        TargetColor.texture:SetColorTexture(0, 0, 0, 1.0)
        return
    end

    --If we have a target do nothing.
    if UnitExists("target") and healingTargetG == UnitGUID("target") then
        TargetColor.texture:SetColorTexture(0, 0, 0, 1.0)
        return
    end

    --If we have no one to heal then do nothing.
    healing_toggle = true
    if healingTarget == nil or healingTargetG == nil or not healing_toggle then
        return
    end

    --Party
    if healingTarget == "party1" then
        TargetColor.texture:SetColorTexture(0.345098, 0.239216, 0.741176, 1.0)
        return
    end
    if healingTarget == "party2" then
        TargetColor.texture:SetColorTexture(0.407843, 0.501961, 0.086275, 1.0)
        return
    end
    if healingTarget == "party3" then
        TargetColor.texture:SetColorTexture(0.160784, 0.470588, 0.164706, 1.0)
        return
    end
    if healingTarget == "party4" then
        TargetColor.texture:SetColorTexture(0.725490, 0.572549, 0.647059, 1.0)
        return
    end

    --PartyPET
    if healingTarget == "partypet1" then
        TargetColor.texture:SetColorTexture(0.486275, 0.176471, 1.000000, 1.0)
        return
    end
    if healingTarget == "partypet2" then
        TargetColor.texture:SetColorTexture(0.031373, 0.572549, 0.152941, 1.0)
        return
    end
    if healingTarget == "partypet3" then
        TargetColor.texture:SetColorTexture(0.874510, 0.239216, 0.239216, 1.0)
        return
    end
    if healingTarget == "partypet4" then
        TargetColor.texture:SetColorTexture(0.117647, 0.870588, 0.635294, 1.0)
        return
    end

    --Raid
    if healingTarget == "raid1" then
        TargetColor.texture:SetColorTexture(0.192157, 0.878431, 0.015686, 1.0)
        return
    end
    if healingTarget == "raid2" then
        TargetColor.texture:SetColorTexture(0.780392, 0.788235, 0.745098, 1.0)
        return
    end
    if healingTarget == "raid3" then
        TargetColor.texture:SetColorTexture(0.498039, 0.184314, 0.521569, 1.0)
        return
    end
    if healingTarget == "raid4" then
        TargetColor.texture:SetColorTexture(0.627451, 0.905882, 0.882353, 1.0)
        return
    end
    if healingTarget == "raid5" then
        TargetColor.texture:SetColorTexture(0.145098, 0.658824, 0.121569, 1.0)
        return
    end
    if healingTarget == "raid6" then
        TargetColor.texture:SetColorTexture(0.639216, 0.490196, 0.921569, 1.0)
        return
    end
    if healingTarget == "raid7" then
        TargetColor.texture:SetColorTexture(0.172549, 0.368627, 0.427451, 1.0)
        return
    end
    if healingTarget == "raid8" then
        TargetColor.texture:SetColorTexture(0.949020, 0.333333, 0.980392, 1.0)
        return
    end
    if healingTarget == "raid9" then
        TargetColor.texture:SetColorTexture(0.109804, 0.388235, 0.980392, 1.0)
        return
    end
    if healingTarget == "raid10" then
        TargetColor.texture:SetColorTexture(0.615686, 0.694118, 0.435294, 1.0)
        return
    end
    if healingTarget == "raid11" then
        TargetColor.texture:SetColorTexture(0.066667, 0.243137, 0.572549, 1.0)
        return
    end
    if healingTarget == "raid12" then
        TargetColor.texture:SetColorTexture(0.113725, 0.129412, 1.000000, 1.0)
        return
    end
    if healingTarget == "raid13" then
        TargetColor.texture:SetColorTexture(0.592157, 0.023529, 0.235294, 1.0)
        return
    end
    if healingTarget == "raid14" then
        TargetColor.texture:SetColorTexture(0.545098, 0.439216, 1.000000, 1.0)
        return
    end
    if healingTarget == "raid15" then
        TargetColor.texture:SetColorTexture(0.890196, 0.800000, 0.854902, 1.0)
        return
    end
    if healingTarget == "raid16" then
        TargetColor.texture:SetColorTexture(0.513725, 0.854902, 0.639216, 1.0)
        return
    end
    if healingTarget == "raid17" then
        TargetColor.texture:SetColorTexture(0.078431, 0.541176, 0.815686, 1.0)
        return
    end
    if healingTarget == "raid18" then
        TargetColor.texture:SetColorTexture(0.109804, 0.184314, 0.666667, 1.0)
        return
    end
    if healingTarget == "raid19" then
        TargetColor.texture:SetColorTexture(0.650980, 0.572549, 0.098039, 1.0)
        return
    end
    if healingTarget == "raid20" then
        TargetColor.texture:SetColorTexture(0.541176, 0.466667, 0.027451, 1.0)
        return
    end
    if healingTarget == "raid21" then
        TargetColor.texture:SetColorTexture(0.000000, 0.988235, 0.462745, 1.0)
        return
    end
    if healingTarget == "raid22" then
        TargetColor.texture:SetColorTexture(0.211765, 0.443137, 0.858824, 1.0)
        return
    end
    if healingTarget == "raid23" then
        TargetColor.texture:SetColorTexture(0.949020, 0.949020, 0.576471, 1.0)
        return
    end
    if healingTarget == "raid24" then
        TargetColor.texture:SetColorTexture(0.972549, 0.800000, 0.682353, 1.0)
        return
    end
    if healingTarget == "raid25" then
        TargetColor.texture:SetColorTexture(0.031373, 0.619608, 0.596078, 1.0)
        return
    end
    if healingTarget == "raid26" then
        TargetColor.texture:SetColorTexture(0.670588, 0.925490, 0.513725, 1.0)
        return
    end
    if healingTarget == "raid27" then
        TargetColor.texture:SetColorTexture(0.647059, 0.945098, 0.031373, 1.0)
        return
    end
    if healingTarget == "raid28" then
        TargetColor.texture:SetColorTexture(0.058824, 0.490196, 0.054902, 1.0)
        return
    end
    if healingTarget == "raid29" then
        TargetColor.texture:SetColorTexture(0.050980, 0.992157, 0.239216, 1.0)
        return
    end
    if healingTarget == "raid30" then
        TargetColor.texture:SetColorTexture(0.949020, 0.721569, 0.388235, 1.0)
        return
    end
    if healingTarget == "raid31" then
        TargetColor.texture:SetColorTexture(0.254902, 0.749020, 0.627451, 1.0)
        return
    end
    if healingTarget == "raid32" then
        TargetColor.texture:SetColorTexture(0.470588, 0.454902, 0.603922, 1.0)
        return
    end
    if healingTarget == "raid33" then
        TargetColor.texture:SetColorTexture(0.384314, 0.062745, 0.266667, 1.0)
        return
    end
    if healingTarget == "raid34" then
        TargetColor.texture:SetColorTexture(0.639216, 0.168627, 0.447059, 1.0)
        return
    end
    if healingTarget == "raid35" then
        TargetColor.texture:SetColorTexture(0.874510, 0.058824, 0.400000, 1.0)
        return
    end
    if healingTarget == "raid36" then
        TargetColor.texture:SetColorTexture(0.925490, 0.070588, 0.713725, 1.0)
        return
    end
    if healingTarget == "raid37" then
        TargetColor.texture:SetColorTexture(0.098039, 0.803922, 0.905882, 1.0)
        return
    end
    if healingTarget == "raid38" then
        TargetColor.texture:SetColorTexture(0.243137, 0.015686, 0.325490, 1.0)
        return
    end
    if healingTarget == "raid39" then
        TargetColor.texture:SetColorTexture(0.847059, 0.376471, 0.921569, 1.0)
        return
    end
    if healingTarget == "raid40" then
        TargetColor.texture:SetColorTexture(0.341176, 0.533333, 0.231373, 1.0)
        return
    end
    if healingTarget == "raidpet1" then
        TargetColor.texture:SetColorTexture(0.458824, 0.945098, 0.784314, 1.0)
        return
    end
    if healingTarget == "raidpet2" then
        TargetColor.texture:SetColorTexture(0.239216, 0.654902, 0.278431, 1.0)
        return
    end
    if healingTarget == "raidpet3" then
        TargetColor.texture:SetColorTexture(0.537255, 0.066667, 0.905882, 1.0)
        return
    end
    if healingTarget == "raidpet4" then
        TargetColor.texture:SetColorTexture(0.333333, 0.415686, 0.627451, 1.0)
        return
    end
    if healingTarget == "raidpet5" then
        TargetColor.texture:SetColorTexture(0.576471, 0.811765, 0.011765, 1.0)
        return
    end
    if healingTarget == "raidpet6" then
        TargetColor.texture:SetColorTexture(0.517647, 0.164706, 0.627451, 1.0)
        return
    end
    if healingTarget == "raidpet7" then
        TargetColor.texture:SetColorTexture(0.439216, 0.074510, 0.941176, 1.0)
        return
    end
    if healingTarget == "raidpet8" then
        TargetColor.texture:SetColorTexture(0.984314, 0.854902, 0.376471, 1.0)
        return
    end
    if healingTarget == "raidpet9" then
        TargetColor.texture:SetColorTexture(0.082353, 0.286275, 0.890196, 1.0)
        return
    end
    if healingTarget == "raidpet10" then
        TargetColor.texture:SetColorTexture(0.058824, 0.003922, 0.964706, 1.0)
        return
    end
    if healingTarget == "raidpet11" then
        TargetColor.texture:SetColorTexture(0.956863, 0.509804, 0.949020, 1.0)
        return
    end
    if healingTarget == "raidpet12" then
        TargetColor.texture:SetColorTexture(0.474510, 0.858824, 0.031373, 1.0)
        return
    end
    if healingTarget == "raidpet13" then
        TargetColor.texture:SetColorTexture(0.509804, 0.882353, 0.423529, 1.0)
        return
    end
    if healingTarget == "raidpet14" then
        TargetColor.texture:SetColorTexture(0.337255, 0.647059, 0.427451, 1.0)
        return
    end
    if healingTarget == "raidpet15" then
        TargetColor.texture:SetColorTexture(0.611765, 0.525490, 0.352941, 1.0)
        return
    end
    if healingTarget == "raidpet16" then
        TargetColor.texture:SetColorTexture(0.921569, 0.129412, 0.913725, 1.0)
        return
    end
    if healingTarget == "raidpet17" then
        TargetColor.texture:SetColorTexture(0.117647, 0.933333, 0.862745, 1.0)
        return
    end
    if healingTarget == "raidpet18" then
        TargetColor.texture:SetColorTexture(0.733333, 0.015686, 0.937255, 1.0)
        return
    end
    if healingTarget == "raidpet19" then
        TargetColor.texture:SetColorTexture(0.819608, 0.392157, 0.686275, 1.0)
        return
    end
    if healingTarget == "raidpet20" then
        TargetColor.texture:SetColorTexture(0.823529, 0.976471, 0.541176, 1.0)
        return
    end
    if healingTarget == "raidpet21" then
        TargetColor.texture:SetColorTexture(0.043137, 0.305882, 0.800000, 1.0)
        return
    end
    if healingTarget == "raidpet22" then
        TargetColor.texture:SetColorTexture(0.737255, 0.270588, 0.760784, 1.0)
        return
    end
    if healingTarget == "raidpet23" then
        TargetColor.texture:SetColorTexture(0.807843, 0.368627, 0.058824, 1.0)
        return
    end
    if healingTarget == "raidpet24" then
        TargetColor.texture:SetColorTexture(0.364706, 0.078431, 0.078431, 1.0)
        return
    end
    if healingTarget == "raidpet25" then
        TargetColor.texture:SetColorTexture(0.094118, 0.901961, 1.000000, 1.0)
        return
    end
    if healingTarget == "raidpet26" then
        TargetColor.texture:SetColorTexture(0.772549, 0.690196, 0.047059, 1.0)
        return
    end
    if healingTarget == "raidpet27" then
        TargetColor.texture:SetColorTexture(0.415686, 0.784314, 0.854902, 1.0)
        return
    end
    if healingTarget == "raidpet28" then
        TargetColor.texture:SetColorTexture(0.470588, 0.733333, 0.047059, 1.0)
        return
    end
    if healingTarget == "raidpet29" then
        TargetColor.texture:SetColorTexture(0.619608, 0.086275, 0.572549, 1.0)
        return
    end
    if healingTarget == "raidpet30" then
        TargetColor.texture:SetColorTexture(0.517647, 0.352941, 0.678431, 1.0)
        return
    end
    if healingTarget == "raidpet31" then
        TargetColor.texture:SetColorTexture(0.003922, 0.149020, 0.694118, 1.0)
        return
    end
    if healingTarget == "raidpet32" then
        TargetColor.texture:SetColorTexture(0.454902, 0.619608, 0.831373, 1.0)
        return
    end
    if healingTarget == "raidpet33" then
        TargetColor.texture:SetColorTexture(0.674510, 0.741176, 0.050980, 1.0)
        return
    end
    if healingTarget == "raidpet34" then
        TargetColor.texture:SetColorTexture(0.560784, 0.713725, 0.784314, 1.0)
        return
    end
    if healingTarget == "raidpet35" then
        TargetColor.texture:SetColorTexture(0.400000, 0.721569, 0.737255, 1.0)
        return
    end
    if healingTarget == "raidpet36" then
        TargetColor.texture:SetColorTexture(0.094118, 0.274510, 0.392157, 1.0)
        return
    end
    if healingTarget == "raidpet37" then
        TargetColor.texture:SetColorTexture(0.298039, 0.498039, 0.462745, 1.0)
        return
    end
    if healingTarget == "raidpet38" then
        TargetColor.texture:SetColorTexture(0.125490, 0.196078, 0.027451, 1.0)
        return
    end
    if healingTarget == "raidpet39" then
        TargetColor.texture:SetColorTexture(0.937255, 0.564706, 0.368627, 1.0)
        return
    end
    if healingTarget == "raidpet40" then
        TargetColor.texture:SetColorTexture(0.929412, 0.592157, 0.501961, 1.0)
        return
    end

    --Stuff
    if healingTarget == "player" then
        TargetColor.texture:SetColorTexture(0.788235, 0.470588, 0.858824, 1.0)
        return
    end

    if healingTarget == "focus" then
        TargetColor.texture:SetColorTexture(0.615686, 0.227451, 0.988235, 1.0)
        return
    end
    if healingTarget == PLACEHOLDER then
        TargetColor.texture:SetColorTexture(0.411765, 0.760784, 0.176471, 1.0)
        return
    end
    if healingTarget == PLACEHOLDER then
        TargetColor.texture:SetColorTexture(0.780392, 0.286275, 0.415686, 1.0)
        return
    end
    if healingTarget == PLACEHOLDER then
        TargetColor.texture:SetColorTexture(0.584314, 0.811765, 0.956863, 1.0)
        return
    end
    if healingTarget == PLACEHOLDER then
        TargetColor.texture:SetColorTexture(0.513725, 0.658824, 0.650980, 1.0)
        return
    end
    if healingTarget == PLACEHOLDER then
        TargetColor.texture:SetColorTexture(0.913725, 0.180392, 0.737255, 1.0)
        return
    end
    if healingTarget == PLACEHOLDER then
        TargetColor.texture:SetColorTexture(0.576471, 0.250980, 0.160784, 1.0)
        return
    end
    if healingTarget == PLACEHOLDER then
        TargetColor.texture:SetColorTexture(0.803922, 0.741176, 0.874510, 1.0)
        return
    end
    if healingTarget == PLACEHOLDER then
        TargetColor.texture:SetColorTexture(0.647059, 0.874510, 0.713725, 1.0)
        return
    end
    if healingTarget == PLACEHOLDER then
        --was party5
        TargetColor.texture:SetColorTexture(0.007843, 0.301961, 0.388235, 1.0)
        return
    end
    if healingTarget == PLACEHOLDER then
        --was party5pet
        TargetColor.texture:SetColorTexture(0.572549, 0.705882, 0.984314, 1.0)
        return
    end
end

local function refreshColor()
    if TargetColor == nil then
        return
    else
        HealingEngine() -- Updates Arrays/Table
        --setHealingTarget() -- Who to heal?
        --setColorTarget() -- Show Pixels
    end
end

--Not usable.
local function checkTarget()
    local castName, _, _, _, castStartTime, castEndTime, _, _, notInterruptable, spellID = UnitCastingInfo("target")
    if castName == nil then
        local castName, nameSubtext, text, texture, startTimeMS, endTimeMS, isTradeSkill, notInterruptible = UnitChannelInfo("unit")
    end
    if castName ~= nil then
        return false
    end
    if UnitGUID("target") == healingTargetG then
        return true
    end
    return false
end

local function targetOverride()
    if disableTarget then
        disableTarget = false
        print("Auto-Target ON")
    else
        disableTarget = true
        print("Auto-Target OFF")
    end
end

local healingEnable = false
local total = 0
local function onUpdate(self, elapsed)
    total = total + elapsed
    if total >= 0.2 then
        showHealingColor("None")
        refreshColor()
        total = 0
    end
end
local updateHealing = CreateFrame("frame")
updateHealing:SetScript("OnUpdate", onUpdate)

--[[ no need
local purgeTable = CreateFrame("Frame")

purgeTable:RegisterEvent("PLAYER_REGEN_DISABLED")
purgeTable:RegisterEvent("PLAYER_REGEN_ENABLED")

purgeTable:SetScript("OnEvent", function(self,event, ...)
        if event == "PLAYER_REGEN_DISABLED" then
            if RubimExtra then
            end
        end
        
        if event == "PLAYER_REGEN_ENABLED" then 
            if RubimExtra then
                
            end
        end
end) ]]

function AoETTD(range, seconds)
    local totalMembersDying = 0
    for i = 1, #members do
        if not UnitIsDeadOrGhost(members[i].Unit) and TimeToDie(members[i].Unit) <= seconds and RangeUnit(unit) <= range and DeBuffs(members[i].Unit, 33786) == 0 then
            totalMembersDying = totalMembersDying + 1
        end
    end
    return totalMembersDying or 0
end

-- Setting Low HP Members variable for AoE Healing
function AoEHealing(HP, range, predictName)
    local lowhpmembers = 0
    for i = 1, #members do
        local missedHP = UnitHealthMax(members[i].Unit) - UnitHealth(members[i].Unit)
        if not UnitIsDeadOrGhost(members[i].Unit) and members[i].HP < HP and SpellInteract(members[i].Unit, range) and DeBuffs(members[i].Unit, 33786) == 0 and (not predictName or predictHeal(predictName, members[i].Unit) <= missedHP) then
            lowhpmembers = lowhpmembers + 1
        end
    end
    return lowhpmembers or 0
end
-- Prediction Heal
function predictHeal(SPELLID, UNIT, VARIATION)
    local variation = VARIATION or 1
    local dmgpersec, total = incdmg(UNIT), 0
    -- Exception penalty for low level units (beta)     
    if UnitLevel(UNIT) < UnitLevel("player") or CombatTime("player") == 0 then
        return 0
    end
    if SPELLID == "HolyShock" then
        total = UnitStat("player", 4) * 4 * ((100 + GetMasteryEffect()) / 100) * ((100 + GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)) / 100) * ((100 + (at_probably / (GetCritChance() * 2 / 100))) / 100)
        -- Talent 5/2 +30% Karatel
        if Buffs("player", 105809, "player") > 0 then
            total = total * 1.30
        end
    end

    if SPELLID == "FlashofLight" then
        local castTime = select(4, GetSpellInfo(19750)) / 1000
        total = UnitStat("player", 4) * 4.5 * ((100 + GetMasteryEffect()) / 100) * ((100 + GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)) / 100) * ((100 + (at_probably / (GetCritChance() / 100))) / 100)
        -- Infusion of Light Buff +50% by HolyShock
        if Buffs("player", 54149, "player") > 0 then
            total = total * 1.50
        end
        -- PvP talent Buff +100%
        if Buffs("player", 210294, "player") > 0 then
            total = total * 2
        end
        -- Artefact Buff +20%
        if (not Mouseover("friendly") and Buffs("target", 200654, "player") > castTime) or (Mouseover("friendly") and Buffs("mouseover", 200654, "player") > castTime) then
            total = total * 1.2
        end
        if dmgpersec > 0 and castTime ~= nil then
            total = total - (dmgpersec * castTime)
        end
    end

    if SPELLID == "HolyLight" then
        local castTime = select(4, GetSpellInfo(82326)) / 1000
        total = UnitStat("player", 4) * 4.25 * ((100 + GetMasteryEffect()) / 100) * ((100 + GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)) / 100) * ((100 + (at_probably / (GetCritChance() / 100))) / 100)
        -- PvP talent Buff +100%
        if Buffs("player", 210294, "player") > 0 then
            total = total * 2
        end
        -- Artefact Buff +20%
        if (not Mouseover("friendly") and Buffs("target", 200654, "player") > castTime) or (Mouseover("friendly") and Buffs("mouseover", 200654, "player") > castTime) then
            total = total * 1.2
        end
        if dmgpersec > 0 and castTime ~= nil then
            total = total - (dmgpersec * castTime)
        end
    end

    if SPELLID == "LightofMartyr" then
        total = UnitStat("player", 4) * 5 * ((100 + GetMasteryEffect()) / 100) * ((100 + GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)) / 100) * ((100 + (at_probably / (GetCritChance() / 100))) / 100)
    end

    if SPELLID == "LightofDawn" then
        total = UnitStat("player", 4) * 1.8 * ((100 + GetMasteryEffect()) / 100) * ((100 + GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)) / 100) * ((100 + (at_probably / (GetCritChance() / 100))) / 100)
    end

    if SPELLID == "HolyPrism" then
        total = UnitStat("player", 4) * 4 * ((100 + GetMasteryEffect()) / 100) * ((100 + GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)) / 100) * ((100 + (at_probably / (GetCritChance() / 100))) / 100)
    end

    if SPELLID == "BestowFaith" then
        total = (UnitStat("player", 4) * 6 * ((100 + GetMasteryEffect()) / 100) * ((100 + GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)) / 100) * ((100 + (at_probably / (GetCritChance() / 100))) / 100)) + (getHEAL(UNIT) * 5) + UnitGetIncomingHeals(UNIT) - (incdmg(UNIT) * 5)
    end

    -- AW +35%
    if Buffs("player", 31842, "player") > 0 and total > 0 then
        total = total * 1.35
    end

    -- These spells doesn't relative for increasing heal buffs
    if SPELLID == "LayonHands" then
        total = UnitHealthMax("player")
    end

    if SPELLID == "GiftofNaaru" then
        total = UnitHealthMax("player") * 0.2 + (getHEAL(UNIT) * 5) + UnitGetIncomingHeals(UNIT) - (incdmg(UNIT) * 5)
    end

    return total + (total * variation) / 100 or 0
end