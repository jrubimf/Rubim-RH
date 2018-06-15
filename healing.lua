local name, addon = ...
if AethysCore == nil then
    message("ERROR: Aethyhs Core is missing. Please download it.")
end
if AethysCache == nil then
    message("ERROR: Aethyhs Cache is missing. Please download it.")
end

local function round2(num, idp)
    mult = 10 ^ (idp or 0)
    return math.floor(num * mult + 0.5) / mult
end


--ROTATION
MiniRotation = CreateFrame("Frame", nil)
MiniRotation:SetBackdrop(nil)
MiniRotation:SetFrameStrata("HIGH")
MiniRotation:SetSize(30, 30)
MiniRotation:SetPoint("TOPLEFT", 31, 12) --12
MiniRotation.texture = MiniRotation:CreateTexture(nil, "TOOLTIP")
MiniRotation.texture:SetAllPoints(true)
MiniRotation.texture:SetColorTexture(0, 0, 0, 1.0)
local height
local currentHeight = tonumber(string.match(({ GetScreenResolutions() })[GetCurrentResolution()], "%d+x(%d+)"))
if roundscale(GetScreenHeight()) == currentHeight then
    height = GetScreenHeight()
elseif GetCVar("useuiscale") == "1" and GetCVar("gxMaximize") == "1" then
    height = currentHeight
elseif GetCVar("useuiscale") == "0" and GetCVar("gxMaximize") == "0" then
    height = roundscale(GetScreenHeight())
elseif GetCVar("useuiscale") == "1" and GetCVar("gxMaximize") == "0" then
    SetCVar("useuiScale", 0)
    return
end
local myscale1 = 0.42666670680046 * (1080 / height)
local myscale2 = 0.17777778208256 * (1080 / height)
if TellMeWhen_Group1:GetEffectiveScale() ~= myscale1 then
    TellMeWhen_Group1:SetParent(nil)
    TellMeWhen_Group1:SetScale(myscale1)
    TellMeWhen_Group1:SetFrameStrata("TOOLTIP")
    TellMeWhen_Group1:SetToplevel(true)
end
if TellMeWhen_Group2:GetEffectiveScale() ~= myscale2 then
    TellMeWhen_Group2:SetParent(nil)
    TellMeWhen_Group2:SetScale(myscale2)
    TellMeWhen_Group2:SetFrameStrata("TOOLTIP")
    TellMeWhen_Group2:SetToplevel(true)
end

function roundscale(num, idp)
    mult = 10 ^ (idp or 0)
    return math.floor(num * mult + 0.5) / mult
end

function SetFrameScale(frame, input, x, y, w, h)
    local xOffset0 = 1
    if frame:GetEffectiveScale() == nil then
        return
    end
    if GetCVar("gxMaximize") == "0" then
        xOffset0 = 0.9411764705882353
    end
    xPixel, yPixel, wPixel, hPixel = x, y, w, h
    xRes, yRes = string.match(({ GetScreenResolutions() })[GetCurrentResolution()], "(%d+)x(%d+)");
    uiscale = UIParent:GetScale();
    XCoord = xPixel * (768.0 / xRes) * GetMonitorAspectRatio() / uiscale / xOffset0
    YCoord = yPixel * (768.0 / yRes) / uiscale;
    Weight = wPixel * (768.0 / xRes) * GetMonitorAspectRatio() / uiscale
    Height = hPixel * (768.0 / yRes) / uiscale;
    local myscale = input * (1080 / height)
    if frame:GetEffectiveScale() ~= myscale then
        frame:SetPoint("TOPLEFT", XCoord, YCoord)
        frame:SetSize(Weight, Height)
        frame:SetScale(myscale / (frame:GetParent() and frame:GetParent():GetEffectiveScale() or 1))
    end
end

MiniRotation:Show()

local updateIcon = CreateFrame("Frame");
updateIcon:SetScript("OnUpdate", function(self, sinceLastUpdate)
    updateIcon:onUpdate(sinceLastUpdate);
end);

function updateIcon:onUpdate(sinceLastUpdate)
    self.sinceLastUpdate = (self.sinceLastUpdate or 0) + sinceLastUpdate;
    if (self.sinceLastUpdate >= 0.2) then
        MiniRotation.texture:SetTexture(GetSpellTexture(MainRotation()))
        self.sinceLastUpdate = 0;
    end
end