local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;

local OurName = UnitName('player')
local QuestPlateTooltip = CreateFrame('GameTooltip', 'QuestPlateTooltip', nil, 'GameTooltipTemplate')
QuestLogIndex = {} -- [questName] = questLogIndex, this is to "quickly" look up quests from its name in the tooltip

local function GetQuestProgress(unitID)
    --if not QuestPlatesEnabled or not name then return end
    --local guid = GUIDs[name]
    --local guid = unitID and UnitGUID(unitID)
    --if not guid then return end

    QuestPlateTooltip:SetOwner(WorldFrame, 'ANCHOR_NONE')
    --QuestPlateTooltip:SetHyperlink('unit:' .. guid)
    QuestPlateTooltip:SetUnit(unitID)

    local progressGlob -- concatenated glob of quest text
    local questType -- 1 for player, 2 for group
    local objectiveCount = 0
    local questTexture -- if usable item
    local questLogIndex -- should generally be set, index usable with questlog functions
    local questID
    for i = 3, QuestPlateTooltip:NumLines() do
        local str = _G['QuestPlateTooltipTextLeft' .. i]
        local text = str and str:GetText()
        if not text then
            return
        end
        questID = questID
        local playerName, progressText = strmatch(text, '^ ([^ ]-) ?%- (.+)$') -- nil or '' if 1 is missing but 2 is there

        local x, y
        if progressText then
            x, y = strmatch(progressText, '(%d+)/(%d+)')
            if x and y then
                local numLeft = y - x
                if numLeft > objectiveCount then
                    -- track highest number of objectives
                    objectiveCount = numLeft
                end
            end
        end

        -- todo: if multiple entries are present, ONLY read the quest objectives for the player
        -- if a name is listed in the pattern then we must be in a group
        if playerName and playerName ~= '' and playerName ~= OurName then
            -- quest is for another group member
            if not questType then
                questType = 2
            end
        else

            if progressText then
                --local x, y = strmatch(progressText, '(%d+)/(%d+)$')
                if not x or (x and y and x ~= y) then
                    progressGlob = progressGlob and progressGlob .. '\n' .. progressText or progressText
                end
            end
        end
    end

    return progressGlob, progressGlob and 1 or questType, objectiveCount, questLogIndex, questID
end

QuestObjectiveStrings = {}
local function CacheQuestIndexes()
    wipe(QuestLogIndex)
    for i = 1, GetNumQuestLogEntries() do
        -- for i = 1, GetNumQuestLogEntries() do if not select(4,GetQuestLogTitle(i)) and select(11,GetQuestLogTitle(i)) then QuestLogPushQuest(i) end end
        local title, level, suggestedGroup, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isBounty, isStory = GetQuestLogTitle(i)
        if not isHeader then
            QuestLogIndex[title] = i
            for objectiveID = 1, GetNumQuestLeaderBoards(i) or 0 do
                local objectiveText, objectiveType, finished, numFulfilled, numRequired = GetQuestObjectiveInfo(questID, objectiveID, false)
                if objectiveText then
                    QuestObjectiveStrings[title .. objectiveText] = { questID, objectiveID }
                end
            end
        end
    end
end

RubimRH.Listener:Add('Rubim_Events', 'QUEST_LOG_UPDATE', function(...)
    CacheQuestIndexes()
end)

function Unit:IsQuestMob()
    local unit = self.UnitID
    local questFlag = GetQuestProgress(unit)

    if questFlag ~= nil and Target:Exists() and Player:CanAttack(Target) and not Target:IsDeadOrGhost()then
        return true
    end
    return false
end