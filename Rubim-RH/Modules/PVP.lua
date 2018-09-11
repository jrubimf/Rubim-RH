local Nothing = nil

local function WarProtPvP()
    if RubimRH.TargetIsValid() and (Target:IsAPlayer() or Target:IsPvPDummy()) then
        --Interrupt Healing
        if RubimRH.InterruptHeal(Target) and WarProt.Pummel:IsReady("Melee") then
            return WarProt.Pummel:Cast()
        end

        --Interrupt CC
        if RubimRH.InterruptHex(Target) and WarProt.Pummel:IsReady("Melee") then
            return WarProt.Pummel:Cast()
        end

    end

    if Player:IsInWarMode() then
        if WarProt.Opressor:IsReadyMorph(10) and Target:DebuffRemains(WarProt.Intimidated) < 1 then
            return WarProt.Taunt:Cast()
        end
    end
end

local function ArmsArenaPvP2()
    if not Arena.arena1:IsImmune() and Arena.arena1:CastingCC() and Arena.arena1:Interruptable() and Arena.arena1:IsTargeting(Player) and Arms.SpellReflection:IsReady() then
        return Arms.SpellReflection:Cast()
    end

    if not Arena.arena2:IsImmune() and Arena.arena2:CastingCC() and Arena.arena2:Interruptable() and Arena.arena2:IsTargeting(Player) and Arms.SpellReflection:IsReady() then
        return Arms.SpellReflection:Cast()
    end

    if not Arena.arena3:IsImmune() and Arena.arena3:CastingCC() and Arena.arena3:Interruptable() and Arena.arena3:IsTargeting(Player) and Arms.SpellReflection:IsReady() then
        return Arms.SpellReflection:Cast()
    end
end

local function ArmsPvP2()
    local inInstance, instanceType = IsInInstance()
    local Ar, St, Utility

    Ar = function()
        if not Arena.arena1:IsImmune() and Arms.Rend:IsReady() and Arena.arena1:MinDistanceToPlayer(true) <= 5 then
            RubimRH.Arena1Icon(Arms.Rend:Cast())
        end

        if not Arena.arena2:IsImmune() and Arms.Rend:IsReady() and Arena.arena2:MinDistanceToPlayer(true) <= 5 then
            RubimRH.Arena2Icon(Arms.Rend:Cast())
        end

        if not Arena.arena3:IsImmune() and Arms.Rend:IsReady() and Arena.arena3:MinDistanceToPlayer(true) <= 5 then
            RubimRH.Arena3Icon(Arms.Rend:Cast())
        end

        if not Arena.arena1:IsImmune() and Arms.Disarm:IsReady() and Arena.arena1:MinDistanceToPlayer(true) <= 5 then
            RubimRH.Arena1Icon(Arms.Disarm:Cast())
        end

        if not Arena.arena2:IsImmune() and Arms.Disarm:IsReady() and Arena.arena2:MinDistanceToPlayer(true) <= 5 then
            RubimRH.Arena2Icon(Arms.Disarm:Cast())
        end

        if not Arena.arena3:IsImmune() and Arms.Disarm:IsReady() and Arena.arena3:MinDistanceToPlayer(true) <= 5 then
            RubimRH.Arena3Icon(Arms.Disarm:Cast())
        end
    end
    RubimRH.Arena1Icon(nil)
    RubimRH.Arena1Icon(nil)
    RubimRH.Arena3Icon(nil)

    St = function()
        --Interrupt Healing
        if not Target:IsImmune() and Target:IsInterruptibleHeal() and Arms.Pummel:IsReady() and Target:HealthPercentage() <= 50 then
            return Arms.Pummel:Cast()
        end

        --Interrupt CC
        if not Target:IsImmune() and Target:IsInterruptibleHeal() and Arms.Pummel:IsReady() then
            return Arms.Pummel:Cast()
        end

        --Keep Slow
        if not Target:IsImmune() and Arms.Hamstring:IsReady() and not Target:IsSnared() and Target:HealthPercentage() <= 50 then
            return Arms.Hamstring:Cast()
        end

        if not Target:IsImmune() and Arms.Hamstring:IsReady() and not Target:IsSnared() and isRanged(Target) then
            return Arms.Hamstring:Cast()
        end

        if not Target:IsImmune() and Arms.SharpenBlade:IsReady() and not Target:IsSnared() and Target:HealthPercentage() <= 50 then
            return Arms.SharpenBlade:Cast()
        end

    end

    local inInstance, instanceType = IsInInstance()
    if instanceType == "arena" then
        Ar()
        if not Arena.arena1:IsImmune() and Arena.arena1:ShouldReflect() and Arena.arena1:IsTargeting(Player) and Arms.SpellReflection:IsReady() then
            return Arms.SpellReflection:Cast()
        end

        if not Arena.arena2:IsImmune() and Arena.arena2:ShouldReflect() and Arena.arena2:IsTargeting(Player) and Arms.SpellReflection:IsReady() then
            return Arms.SpellReflection:Cast()
        end

        if not Arena.arena3:IsImmune() and Arena.arena3:ShouldReflect() and Arena.arena3:IsTargeting(Player) and Arms.SpellReflection:IsReady() then
            return Arms.SpellReflection:Cast()
        end
    end

    if St() ~= nil then
        return St()
    end
end

local function FuryPvP2()
    if RubimRH.TargetIsValid() and (Target:IsAPlayer() or Target:IsPvPDummy() or Player:IsInWarMode()) then
        --Interrupt Healing
        if not Target:IsImmune() and RubimRH.InterruptHeal(Target) and Fury.Pummel:IsReady() then
            return Fury.Pummel:Cast()
        end

        --Interrupt CC
        if not Target:IsImmune() and RubimRH.InterruptHex(Target) and Fury.Pummel:IsReady() then
            return Fury.Pummel:Cast()
        end

        --Keep Slow
        if not Target:IsImmune() and Fury.PiercingHowl:IsReady() and not Target:IsSnared() and Target:HealthPercentage() <= 50 then
            return Fury.PiercingHowl:Cast()
        end

        if not Target:IsImmune() and Fury.PiercingHowl:IsReady() and not Target:IsSnared() and isRanged(Target) then
            return Fury.PiercingHowl:Cast()
        end
    end
end

local function BloodPvP()
    local inInstance, instanceType = IsInInstance()
    local Ar, St, Utility

    Ar = function()

    end
    RubimRH.Arena1Icon(nil)
    RubimRH.Arena1Icon(nil)
    RubimRH.Arena3Icon(nil)

    St = function()
        if RubimRH.TargetIsValid() and (Target:IsAPlayer() or Target:IsPvPDummy()) then
            --Interrupt Healing
            if Target:IsInterruptibleHeal() and Blood.MindFreeze:IsReady() and Target:HealthPercentage() <= 50 then
                return Blood.MindFreeze:Cast()
            end

            --Interrupt CC
            if Target:IsInterruptibleHeal() and Blood.MindFreeze:IsReady() then
                return Blood.MindFreeze:Cast()
            end

            --Keep Slow
            if not Target:IsImmune() and Blood.HeartStrike:IsReady() and not Target:IsSnared() and Target:HealthPercentage() <= 50 then
                return Blood.HeartStrike:Cast()
            end

            if not Target:IsImmune() and Blood.HeartStrike:IsReady() and not Target:IsSnared() and isRanged(Target) then
                return Blood.HeartStrike:Cast()
            end
        end

        if Player:IsInWarMode() and RubimRH.TargetIsValid() then
            if Blood.MurderousIntent:IsReady(10) and Target:DebuffRemains(Blood.Intimidated) < 1 then
                return Blood.MurderousIntent:Cast()
            end

            if Blood.DeathChain:IsReady() and Cache.EnemiesCount[10] >= 2 then
                return Blood.DeathChain:Cast()
            end
        end
    end

    local inInstance, instanceType = IsInInstance()
    if instanceType == "arena" then
        Ar()
    end

    if St() ~= nil then
        return St()
    end
end

local function BloodPvP2()
    if RubimRH.TargetIsValid() and (Target:IsAPlayer() or Target:IsPvPDummy()) then
        --Interrupt Healing
        if RubimRH.InterruptHeal(Target) and Blood.MindFreeze:IsReady("Melee") then
            return Blood.MindFreeze:Cast()
        end

        --Interrupt CC
        if RubimRH.InterruptHex(Target) and Blood.MindFreeze:IsReady("Melee") then
            return Blood.MindFreeze:Cast()
        end

        --Keep Slow
        if Blood.HeartStrike:IsReady("Melee") and Target:DebuffRemains(Blood.HeartStrike) < 3 and Target:HealthPercentage() <= 50 then
            return Blood.HeartStrike:Cast()
        end

        if Blood.HeartStrike:IsReady("Melee") and Target:DebuffRemains(Blood.HeartStrike) < 3 and isRanged(Target) then
            return Blood.HeartStrike:Cast()
        end
    end

    if Player:IsInWarMode() and RubimRH.TargetIsValid() then
        if Blood.MurderousIntent:IsReady(10) and Target:DebuffRemains(Blood.Intimidated) < 1 then
            return Blood.MurderousIntent:Cast()
        end

        if Blood.DeathChain:IsReady() and Cache.EnemiesCount[10] >= 2 then
            return Blood.DeathChain:Cast()
        end
    end
end

local function FrostArenaPvP()
    if not Arena.arena1:IsImmune() and Arena.arena1:CastingHealing() and Arena.arena1:Interruptable() and Frost.MindFreeze:IsReady() and Target:HealthPercentage() <= 40 then
        RubimRH.arena1.texture:SetColorTexture(0, 0.56, 0, 1)
    end

    if not Arena.arena2:IsImmune() and Arena.arena2:CastingHealing() and Arena.arena2:Interruptable() and Frost.MindFreeze:IsReady() and Target:HealthPercentage() <= 40 then
        RubimRH.arena2.texture:SetColorTexture(0, 0.56, 0, 1)
    end

    if not Arena.arena3:IsImmune() and Arena.arena3:CastingHealing() and Arena.arena3:Interruptable() and Frost.MindFreeze:IsReady() and Target:HealthPercentage() <= 40 then
        RubimRH.arena3.texture:SetColorTexture(0, 0.56, 0, 1)
    end

    if not Arena.arena1:IsImmune() and Arena.arena1:CastingCC() and Arena.arena1:Interruptable() and Frost.MindFreeze:IsReady() then
        RubimRH.arena1.texture:SetColorTexture(0, 0.56, 0, 1)
    end

    if not Arena.arena2:IsImmune() and Arena.arena2:CastingCC() and Arena.arena2:Interruptable() and Frost.MindFreeze:IsReady() then
        RubimRH.arena2.texture:SetColorTexture(0, 0.56, 0, 1)
    end

    if not Arena.arena3:IsImmune() and Arena.arena3:CastingCC() and Arena.arena3:Interruptable() and Frost.MindFreeze:IsReady() then
        RubimRH.arena3.texture:SetColorTexture(0, 0.56, 0, 1)
    end
end

local function FrostPvP()
    if RubimRH.TargetIsValid() and (Target:IsAPlayer() or Target:IsPvPDummy() or Player:IsInWarMode()) then
        --Interrupt Healing
        if not Target:IsImmune() and RubimRH.InterruptHeal(Target) and Frost.MindFreeze:IsReady() then
            return Frost.MindFreeze:Cast()
        end

        --Interrupt CC
        if not Target:IsImmune() and RubimRH.InterruptHex(Target) and Frost.MindFreeze:IsReady() then
            return Frost.MindFreeze:Cast()
        end

        --Keep Slow
        if RubimRH.TargetIsValid() and (Target:IsAPlayer() or Target:IsPvPDummy()) and not Target:IsImmune() and Frost.ChainsofIce:IsReady() and not Target:IsSnared() then
            return Frost.ChainsofIce:Cast()
        end

        if not Target:IsImmune() and Frost.ChillStreak:IsReady() then
            return Frost.ChillStreak:Cast()
        end
    end
end

local function RetPvP()
    --Interrupt Healing
    if RubimRH.TargetIsValid() and (Target:IsAPlayer() or Target:IsPvPDummy()) then
        if RubimRH.InterruptHeal(Target) and Blood.Rebuke:IsReady("Melee") then
            return Ret.Rebuke:Cast()
        end

        --Interrupt CC
        if RubimRH.InterruptHex(Target) and Blood.Rebuke:IsReady("Melee") then
            return Ret.Rebuke:Cast()
        end

        --Keep Slow
        if Ret.HandOfHidrance:IsReady() and Target:HealthPercentage() <= 50 and not Target:IsSnared() then
            return Ret.HandOfHidrance:Cast()
        end

        if Ret.HandOfHidrance:IsReady() and isRanged(Target) and not Target:IsSnared() then
            return Ret.HandOfHidrance:Cast()
        end
    end
end

local function SurvPvP()
    local Utility, SingleTarget, Burst

    Utility = function()
        if RubimRH.TargetIsValid() and (Target:IsAPlayer() or Target:IsPvPDummy()) then
            if RubimRH.InterruptHeal(Target) and Surv.Muzzle:IsReady("Melee") then
                return Surv.Muzzle:Cast()
            end

            --Interrupt CC
            if RubimRH.InterruptHex(Target) and Surv.Muzzle:IsReady("Melee") then
                return Surv.Muzzle:Cast()
            end

            --Keep Slow
            if Surv.WingClip:IsReady() and Target:HealthPercentage() <= 50 and not Target:IsSnared() then
                return Surv.WingClip:Cast()
            end

            if Surv.WingClip:IsReady() and isRanged(Target) and not Target:IsSnared() and isRanged(Target) then
                return Surv.WingClip:Cast()
            end
        end
    end

    SingleTarget = function()
        --1. Kill Command(259489) if we are <85 focus
        if Surv.KillCommand:IsReady() and Player:Focus() < 85 then
            return Surv.KillCommand:Cast()
        end

        --2. Mongoose Bite(259387) (IF WE HAVE 4> STACKS OF MONGOOSE FURY(259388)
        --3. Wildfire Infusion x1 !!CC CHECK!!! SMALL FRONTAL CONE (Use if we have 2 charges OR <2s left until we get our second charge again).
        --^^When our freezing trap is off CD or <17s then HOLD Wildfire Bomb usage.^^
        --4. Viper's Venom procs(268552) use Serpent Sting ASAP UNLESS we have Mongoose Fury up.
        --5. Serpent Sting(259491) (if serpent sting debuff is not on the target OR has <3s left.)
        --6. Mongoose Bite

    end


end

local function SurvArenaPvP()
    if not Arena.arena1:IsImmune() and Arena.arena1:CastingHealing() and Arena.arena1:Interruptable() and Surv.Muzzle:IsReady() and Target:HealthPercentage() <= 40 then
        RubimRH.arena1.texture:SetColorTexture(0, 0.56, 0, 1)
    end

    if not Arena.arena2:IsImmune() and Arena.arena2:CastingHealing() and Arena.arena2:Interruptable() and Surv.Muzzle:IsReady() and Target:HealthPercentage() <= 40 then
        RubimRH.arena2.texture:SetColorTexture(0, 0.56, 0, 1)
    end

    if not Arena.arena3:IsImmune() and Arena.arena3:CastingHealing() and Arena.arena3:Interruptable() and Surv.Muzzle:IsReady() and Target:HealthPercentage() <= 40 then
        RubimRH.arena3.texture:SetColorTexture(0, 0.56, 0, 1)
    end

    if not Arena.arena1:IsImmune() and Arena.arena1:CastingCC() and Arena.arena1:Interruptable() and Surv.Muzzle:IsReady() then
        RubimRH.arena1.texture:SetColorTexture(0, 0.56, 0, 1)
    end

    if not Arena.arena2:IsImmune() and Arena.arena2:CastingCC() and Arena.arena2:Interruptable() and Surv.Muzzle:IsReady() then
        RubimRH.arena2.texture:SetColorTexture(0, 0.56, 0, 1)
    end

    if not Arena.arena3:IsImmune() and Arena.arena3:CastingCC() and Arena.arena3:Interruptable() and Surv.Muzzle:IsReady() then
        RubimRH.arena3.texture:SetColorTexture(0, 0.56, 0, 1)
    end
end

local function WindwalkerPvP()
    if RubimRH.TargetIsValid() and (Target:IsAPlayer() or Target:IsPvPDummy()) then
        if RubimRH.InterruptHeal(Target) and Wind.SpearHandStrike:IsReady("Melee") then
            return Wind.SpearHandStrike:Cast()
        end

        --Interrupt CC
        if RubimRH.InterruptHex(Target) and Wind.SpearHandStrike:IsReady("Melee") then
            return Wind.SpearHandStrike:Cast()
        end

        --Keep Slow
        if Wind.Disable:IsReady() and Target:HealthPercentage() <= 50 and not Target:IsSnared() then
            return Wind.Disable:Cast()
        end

        if Wind.Disable:IsReady() and isRanged(Target) and not Target:IsSnared() and isRanged(Target) then
            return Wind.Disable:Cast()
        end

        --Don't burst isMeleeClass
        if RubimRH.PvPBursting(Target) and S.Disarm:IsReady() and not Target:IsDisarmed() then
            return Wind.Disarm()
        end
    end
end