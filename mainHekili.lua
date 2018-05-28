--- ============================              ============================
local nextAbility
function GetNextAbility()
    return nextAbility
end

function SetNextAbility(skill)
    if skill == nil then
        print("ERROR, NIL SKILL")
        return 0
    else
        nextAbility = skill
    end
end

--- ============================   MAIN_ROT   ============================
function MainRotation()
    if IsMounted() then
        return 155142
    end
    return GetNextAbility()
end