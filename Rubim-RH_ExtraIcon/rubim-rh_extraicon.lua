local name, addon = ...
RubimExtra = true
RubimExtraVer = 01102018
local safeColor = true
local tostring, tonumber, print = tostring, tonumber, print

local function round2(num, idp)
    mult = 10 ^ (idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function roundscale(num, idp)
    mult = 10 ^ (idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

RubimRH.topIcons = CreateFrame("Frame", nil, UIParent)
RubimRH.topIcons:SetBackdrop(nil)
RubimRH.topIcons:SetFrameStrata("TOOLTIP")
RubimRH.topIcons:SetToplevel(true)
RubimRH.topIcons:SetSize(240, 30) 
RubimRH.topIcons:SetPoint("TOPLEFT", -29, 12) 
RubimRH.topIcons.texture = RubimRH.topIcons:CreateTexture(nil, "OVERLAY")
RubimRH.topIcons.texture:SetAllPoints(true)
RubimRH.topIcons.texture:SetColorTexture(0, 0, 0, 0)

if safeColor then
    RubimRH.topIcons.texture:SetColorTexture(0, 0, 0, 1)
end

RubimRH.topIcons:SetScale(1)
RubimRH.topIcons:Show(1)

RubimRH.ccIcon = CreateFrame("Frame", nil, RubimRH.topIcons) -- was missed
RubimRH.ccIcon:SetBackdrop(nil)
RubimRH.ccIcon:SetSize(1, 1)
RubimRH.ccIcon:SetPoint("TOPLEFT", RubimRH.topIcons, 0, 0)
RubimRH.ccIcon.texture = RubimRH.ccIcon:CreateTexture(nil, "OVERLAY")
RubimRH.ccIcon.texture:SetAllPoints(true)
RubimRH.ccIcon.texture:SetColorTexture(0, 1, 1, 0)
RubimRH.ccIcon:SetScale(1)
RubimRH.ccIcon:Show(1)

RubimRH.kickIcon = CreateFrame("Frame", nil, RubimRH.topIcons)
RubimRH.kickIcon:SetBackdrop(nil)
RubimRH.kickIcon:SetSize(1, 1)
RubimRH.kickIcon:SetPoint("TOPLEFT", RubimRH.topIcons, 30, 0)
RubimRH.kickIcon.texture = RubimRH.kickIcon:CreateTexture(nil, "OVERLAY")
RubimRH.kickIcon.texture:SetAllPoints(true)
RubimRH.kickIcon.texture:SetColorTexture(0, 1, 1, 0)
RubimRH.kickIcon:SetScale(1)
RubimRH.kickIcon:Show(1)

RubimRH.stIcon = CreateFrame("Frame", nil, RubimRH.topIcons)
RubimRH.stIcon:SetBackdrop(nil)
RubimRH.stIcon:SetSize(30, 30)
RubimRH.stIcon:SetPoint("TOPLEFT", RubimRH.topIcons, 60, 0) 
RubimRH.stIcon.texture = RubimRH.stIcon:CreateTexture(nil, "OVERLAY")
RubimRH.stIcon.texture:SetAllPoints(true)
RubimRH.stIcon.texture:SetColorTexture(0, 1, 0, 0)
RubimRH.stIcon:SetScale(1)
RubimRH.stIcon:Show(1)

RubimRH.aoeIcon = CreateFrame("Frame", nil, RubimRH.topIcons)
RubimRH.aoeIcon:SetBackdrop(nil)
RubimRH.aoeIcon:SetSize(30, 30)
RubimRH.aoeIcon:SetPoint("TOPLEFT", RubimRH.topIcons, 90, 0) 
RubimRH.aoeIcon.texture = RubimRH.aoeIcon:CreateTexture(nil, "OVERLAY")
RubimRH.aoeIcon.texture:SetAllPoints(true)
RubimRH.aoeIcon.texture:SetColorTexture(1, 1, 0, 0)
RubimRH.aoeIcon:SetScale(1)
RubimRH.aoeIcon:Show(1)

RubimRH.gladiatorIcon = CreateFrame("Frame", nil, RubimRH.topIcons)
RubimRH.gladiatorIcon:SetBackdrop(nil)
RubimRH.gladiatorIcon:SetSize(30, 30)
RubimRH.gladiatorIcon:SetPoint("TOPLEFT", RubimRH.topIcons, 120, 0) 
RubimRH.gladiatorIcon.texture = RubimRH.gladiatorIcon:CreateTexture(nil, "OVERLAY")
RubimRH.gladiatorIcon.texture:SetAllPoints(true)
RubimRH.gladiatorIcon.texture:SetColorTexture(0, 0, 1, 0)
RubimRH.gladiatorIcon:SetScale(1)
RubimRH.gladiatorIcon:Show(1)

RubimRH.passiveIcon = CreateFrame("Frame", nil, RubimRH.topIcons)
RubimRH.passiveIcon:SetBackdrop(nil)
RubimRH.passiveIcon:SetSize(30, 30)
RubimRH.passiveIcon:SetPoint("TOPLEFT", RubimRH.topIcons, 150, 0) 
RubimRH.passiveIcon.texture = RubimRH.passiveIcon:CreateTexture(nil, "OVERLAY")
RubimRH.passiveIcon.texture:SetAllPoints(true)
RubimRH.passiveIcon.texture:SetColorTexture(1, 0, 0, 0)
RubimRH.passiveIcon:SetScale(1)
RubimRH.passiveIcon:Show(1)

-- For what these frames here? They have wrong SetPoint anyway
function RubimRH.Arena1Icon(texture)
    RubimRH.class1Icon.texture:SetTexture(texture)
end

function RubimRH.Arena2Icon(texture)
    RubimRH.class2Icon.texture:SetTexture(texture)
end

function RubimRH.Arena3Icon(texture)
    RubimRH.class3Icon.texture:SetTexture(texture)
end
RubimRH.class1Icon = CreateFrame("Frame", nil, RubimRH.topIcons)
RubimRH.class1Icon:SetBackdrop(nil)
RubimRH.class1Icon:SetFrameStrata("TOOLTIP")
RubimRH.class1Icon:SetSize(30, 30)
RubimRH.class1Icon:SetPoint("TOPLEFT", RubimRH.topIcons, 121, 0) --12
RubimRH.class1Icon.texture = RubimRH.class1Icon:CreateTexture(nil, "OVERLAY")
RubimRH.class1Icon.texture:SetAllPoints(true)
RubimRH.class1Icon.texture:SetColorTexture(1, 0, 0, 0)
RubimRH.class1Icon:SetScale(1)
RubimRH.class1Icon:Show(1)

RubimRH.class2Icon = CreateFrame("Frame", nil, RubimRH.topIcons)
RubimRH.class2Icon:SetBackdrop(nil)
RubimRH.class2Icon:SetFrameStrata("TOOLTIP")
RubimRH.class2Icon:SetSize(30, 30)
RubimRH.class2Icon:SetPoint("TOPLEFT", RubimRH.topIcons, 151, 0) --12
RubimRH.class2Icon.texture = RubimRH.class2Icon:CreateTexture(nil, "OVERLAY")
RubimRH.class2Icon.texture:SetAllPoints(true)
RubimRH.class2Icon.texture:SetColorTexture(1, 0, 0, 0)
RubimRH.class2Icon:SetScale(1)
RubimRH.class2Icon:Show(1)

RubimRH.class3Icon = CreateFrame("Frame", nil, RubimRH.topIcons)
RubimRH.class3Icon:SetBackdrop(nil)
RubimRH.class3Icon:SetFrameStrata("TOOLTIP")
RubimRH.class3Icon:SetSize(30, 30)
RubimRH.class3Icon:SetPoint("TOPLEFT", RubimRH.topIcons, 181, 0) --12
RubimRH.class3Icon.texture = RubimRH.class3Icon:CreateTexture(nil, "OVERLAY")
RubimRH.class3Icon.texture:SetAllPoints(true)
RubimRH.class3Icon.texture:SetColorTexture(1, 0, 0, 0)
RubimRH.class3Icon:SetScale(1)
RubimRH.class3Icon:Show(1)

--RubimRH.arena1.texture:SetColorTexture(0, 0.56, 0) -- Interrupt
--RubimRH.arena1.texture:SetColorTexture(0.56, 0, 0) -- Interrupt
RubimRH.arena1 = CreateFrame("Frame", nil, RubimRH.topIcons)
RubimRH.arena1:SetBackdrop(nil)
RubimRH.arena1:SetFrameStrata("TOOLTIP")
RubimRH.arena1:SetSize(175, 8)
RubimRH.arena1:SetPoint("TOPLEFT", RubimRH.topIcons, 213, -12) --12
RubimRH.arena1.texture = RubimRH.arena1:CreateTexture(nil, "OVERLAY")
RubimRH.arena1.texture:SetAllPoints(true)
RubimRH.arena1:SetScale(1)
RubimRH.arena1:Show(1)

RubimRH.arena12 = CreateFrame("Frame", nil, RubimRH.topIcons)
RubimRH.arena12:SetBackdrop(nil)
RubimRH.arena12:SetFrameStrata("TOOLTIP")
RubimRH.arena12:SetSize(8, 8)
RubimRH.arena12:SetPoint("TOPLEFT", RubimRH.topIcons, 213, -20) --12
RubimRH.arena12.texture = RubimRH.arena12:CreateTexture(nil, "OVERLAY")
RubimRH.arena12.texture:SetAllPoints(true)
RubimRH.arena12.texture:SetColorTexture(0, 0, 0, 0)
RubimRH.arena12:SetScale(1)
RubimRH.arena12:Show(1)

RubimRH.arena2 = CreateFrame("Frame", nil, RubimRH.topIcons)
RubimRH.arena2:SetBackdrop(nil)
RubimRH.arena2:SetFrameStrata("TOOLTIP")
RubimRH.arena2:SetSize(175, 8)
RubimRH.arena2:SetPoint("TOPLEFT", RubimRH.topIcons, 387, -12) --12
RubimRH.arena2.texture = RubimRH.arena2:CreateTexture(nil, "OVERLAY")
RubimRH.arena2.texture:SetAllPoints(true)
RubimRH.arena2:SetScale(1)
RubimRH.arena2:Show(1)

RubimRH.arena22 = CreateFrame("Frame", nil, RubimRH.topIcons)
RubimRH.arena22:SetBackdrop(nil)
RubimRH.arena22:SetFrameStrata("TOOLTIP")
RubimRH.arena22:SetSize(8, 8)
RubimRH.arena22:SetPoint("TOPLEFT", RubimRH.topIcons, 387, -20) --12
RubimRH.arena22.texture = RubimRH.arena22:CreateTexture(nil, "OVERLAY")
RubimRH.arena22.texture:SetAllPoints(true)
RubimRH.arena22.texture:SetColorTexture(0, 0, 0, 0)
RubimRH.arena22:SetScale(1)
RubimRH.arena22:Show(1)

RubimRH.arena3 = CreateFrame("Frame", nil, RubimRH.topIcons)
RubimRH.arena3:SetBackdrop(nil)
RubimRH.arena3:SetFrameStrata("TOOLTIP")
RubimRH.arena3:SetSize(175, 8)
RubimRH.arena3:SetPoint("TOPLEFT", RubimRH.topIcons, 561, -12) --12
RubimRH.arena3.texture = RubimRH.arena3:CreateTexture(nil, "OVERLAY")
RubimRH.arena3.texture:SetAllPoints(true)
RubimRH.arena3:SetScale(1)
RubimRH.arena3:Show(1)

RubimRH.arena32 = CreateFrame("Frame", nil, RubimRH.topIcons)
RubimRH.arena32:SetBackdrop(nil)
RubimRH.arena32:SetFrameStrata("TOOLTIP")
RubimRH.arena32:SetSize(8, 8)
RubimRH.arena32:SetPoint("TOPLEFT", RubimRH.topIcons, 561, -20) --12
RubimRH.arena32.texture = RubimRH.arena32:CreateTexture(nil, "OVERLAY")
RubimRH.arena32.texture:SetAllPoints(true)
RubimRH.arena32.texture:SetColorTexture(1, 0, 0, 0)
RubimRH.arena32:SetScale(1)
RubimRH.arena32:Show(1)

TargetColor = CreateFrame("Frame", "TargetColor", RubimRH.topIcons)
TargetColor:SetBackdrop(nil)
TargetColor:SetFrameStrata("TOOLTIP")
TargetColor:SetSize(1, 1)
TargetColor:SetScale(1)
TargetColor:SetPoint("TOPLEFT", RubimRH.topIcons, 737, -12)
TargetColor.texture = TargetColor:CreateTexture(nil, "OVERLAY")
TargetColor.texture:SetAllPoints(true)
TargetColor.texture:SetColorTexture(0, 0, 0, 1.0)

local showedOnce = false
local function ScaleFix()
	local resolution
	local DPI = GetScreenDPIScale()
    if GetCVar("gxMaximize") == "1" then 
		-- Fullscreen (only 8.2+)
		resolution = tonumber(strmatch(GetScreenResolutions(), "%dx(%d+)")) --tonumber(string.match(GetCVar("gxFullscreenResolution"), "%d+x(%d+)"))
	else 
		-- Windowed 
		resolution = select(2, GetPhysicalScreenSize()) --tonumber(string.match(GetCVar("gxWindowedResolution"), "%d+x(%d+)")) 
		
		-- Regarding Windows DPI
		-- Note: Full HD 1920x1080 offsets (100% X8 Y31 / 125% X9 Y38)
		-- You might need specific thing to get truth relative graphic area, so just contact me if you see this and can't find fix for DPI > 1 e.g. 100%
		if not showedOnce and GetScreenDPIScale() ~= 1 then 
			message("You use not 100% Windows DPI and this can may apply conflicts. Set own X and Y offsets in source.")
		end 
	end 	
	
	local myscale1 = 0.42666670680046 * (1080 / resolution)

    RubimRH.topIcons:SetParent(nil)
    RubimRH.topIcons:SetScale(myscale1) 
	RubimRH.topIcons:SetFrameStrata("TOOLTIP")
	RubimRH.topIcons:SetToplevel(true)
	
    if TargetColor then
        if not TargetColor:IsShown() then
            TargetColor:Show()
        end
        TargetColor:SetScale((0.71111112833023 * (1080 / resolution)) / (TargetColor:GetParent() and TargetColor:GetParent():GetEffectiveScale() or 1))
    end    
end

local function UpdateCVAR()
    if GetCVar("Contrast")~="50" then 
		SetCVar("Contrast", 50)
		print("Contrast should be 50")		
	end
    if GetCVar("Brightness")~="50" then 
		SetCVar("Brightness", 50) 
		print("Brightness should be 50")			
	end
    if GetCVar("Gamma")~="1.000000" then 
		SetCVar("Gamma", "1.000000") 
		print("Gamma should be 1")	
	end
    if GetCVar("colorblindsimulator")~="0" then SetCVar("colorblindsimulator", 0) end; 
    -- Not neccessary
    if GetCVar("RenderScale")~="1" then SetCVar("RenderScale", 1) end; 
	--[[
    if GetCVar("MSAAQuality")~="0" then SetCVar("MSAAQuality", 0) end;
    -- Could effect bugs if > 0 but FXAA should work, some people saying MSAA working too 
	local AAM = tonumber(GetCVar("ffxAntiAliasingMode"))
    if AAM > 2 and AAM ~= 6 then 		
		SetCVar("ffxAntiAliasingMode", 0) 
		print("You can't set higher AntiAliasing mode than FXAA or not equal to MSAA 8x")
	end
	]]
    if GetCVar("doNotFlashLowHealthWarning")~="1" then SetCVar("doNotFlashLowHealthWarning", 1) end; 
    -- WM removal
    if GetCVar("screenshotQuality")~="10" then SetCVar("screenshotQuality", 10) end;    
    -- UNIT_NAMEPLAYES_AUTOMODE (must be visible)
    if GetCVar("nameplateShowAll")=="0" then
        SetCVar("nameplateShowAll", 1)
		print("All nameplates should be visible")
    end
    if GetCVar("nameplateShowEnemies")~="1" then
        SetCVar("nameplateShowEnemies", 1) 
        print("Enemy nameplates should be enabled")
    end
end

local function ConsoleUpdate()
    UpdateCVAR()  
	ScaleFix()    
end 


RubimRH.Listener:Add('Rubim_Events', 'PLAYER_ENTERING_WORLD', ConsoleUpdate)
RubimRH.Listener:Add('Rubim_Events', 'UI_SCALE_CHANGED', ConsoleUpdate)
RubimRH.Listener:Add('Rubim_Events', 'DISPLAY_SIZE_CHANGED', ConsoleUpdate)
VideoOptionsFrame:HookScript("OnHide", ConsoleUpdate)
InterfaceOptionsFrame:HookScript("OnHide", UpdateCVAR)