local pairs, ipairs = pairs, ipairs
local GetSpellInfo = GetSpellInfo
local ItemSlots = { 1, 2, 3, 5 }

local AzeriteEmpoweredItem = _G.C_AzeriteEmpoweredItem
local AzeriteTraits = {}

local AzeriteEssence = _G.C_AzeriteEssence
local AzeriteEssences = { Major = {}, Minor = {}, Total = {} }

local function AzeriteEssenceUpdate() 
	wipe(AzeriteEssences.Major)
	wipe(AzeriteEssences.Minor)
	wipe(AzeriteEssences.Total)
	if AzeriteEssence and AzeriteEmpoweredItem.IsHeartOfAzerothEquipped() then
		for i = Enum.AzeriteEssence.MainSlot, Enum.AzeriteEssence.PassiveTwoSlot do 
			if not AzeriteEssence.GetSlotInfo(i) then -- not locked slot (major should as default unlocked)
				local essenceID = AzeriteEssence.GetActiveEssence(i)
				if essenceID then 
					local info = AzeriteEssence.GetEssenceInfo(essenceID) -- not sure if it's exactly table 
					local ID, Name, Rank, Unlocked, Valid, Icon = info.ID, info.name, info.rank, info.unlocked, info.valid, info.icon			
					if i == Enum.AzeriteEssence.MainSlot then 
						--[[
						local spellID = AzeriteEssence.GetActionSpell() -- this thing removed on latest PTR lol 
						if spellID then 
							AzeriteEssences.Major[GetSpellInfo(spellID)] = { ID = ID, Name = Name, Rank = Rank, Unlocked = Unlocked, Valid = Valid, Icon = Icon, IsAction = true }
							AzeriteEssences.Major[spellID] = { ID = ID, Name = Name, Rank = Rank, Unlocked = Unlocked, Valid = Valid, Icon = Icon, IsAction = true }
						end 
						]]
						-- not possible get name unless GetMilestoneSpell(milestoneID)
						local milestones = AzeriteEssence.GetMilestones()
						for _, milestoneInfo in ipairs(milestones) do
							if milestoneInfo.slot == i then
								local spellID = AzeriteEssence.GetMilestoneSpell(milestoneInfo.milestoneID)
								AzeriteEssences.Major[GetSpellInfo(spellID)] = { ID = ID, Name = Name, Rank = Rank, Unlocked = Unlocked, Valid = Valid, Icon = Icon }
								AzeriteEssences.Major[spellID] = { ID = ID, Name = Name, Rank = Rank, Unlocked = Unlocked, Valid = Valid, Icon = Icon }
								break 
							end 
						end	
						-- need somehow identify usable spell because Major slot can be Passive =\ 
						-- IsAction can be used as key to indentify it
						-- TESTING: Try collect all keys to see which will be recorded  
						AzeriteEssences.Major[essenceID] = { ID = ID, Name = Name, Rank = Rank, Unlocked = Unlocked, Valid = Valid, Icon = Icon }
						AzeriteEssences.Major[ID] = { ID = ID, Name = Name, Rank = Rank, Unlocked = Unlocked, Valid = Valid, Icon = Icon }
						AzeriteEssences.Major[Name] = { ID = ID, Name = Name, Rank = Rank, Unlocked = Unlocked, Valid = Valid, Icon = Icon }						
					else 
						-- not possible get name unless GetMilestoneSpell(milestoneID)
						local milestones = AzeriteEssence.GetMilestones()
						for _, milestoneInfo in ipairs(milestones) do
							if milestoneInfo.slot == i then
								local spellID = AzeriteEssence.GetMilestoneSpell(milestoneInfo.milestoneID)
								AzeriteEssences.Minor[GetSpellInfo(spellID)] = { ID = ID, Name = Name, Rank = Rank, Unlocked = Unlocked, Valid = Valid, Icon = Icon }
								AzeriteEssences.Minor[spellID] = { ID = ID, Name = Name, Rank = Rank, Unlocked = Unlocked, Valid = Valid, Icon = Icon }
								break 
							end 
						end								
						AzeriteEssences.Minor[ID] = { ID = ID, Name = Name, Rank = Rank, Unlocked = Unlocked, Valid = Valid, Icon = Icon }
						AzeriteEssences.Minor[Name] = { ID = ID, Name = Name, Rank = Rank, Unlocked = Unlocked, Valid = Valid, Icon = Icon }
					end 
					AzeriteEssences.Total[GetSpellInfo(spellID)] = { ID = ID, Name = Name, Rank = Rank, Unlocked = Unlocked, Valid = Valid, Icon = Icon }
					AzeriteEssences.Total[spellID] = { ID = ID, Name = Name, Rank = Rank, Unlocked = Unlocked, Valid = Valid, Icon = Icon }
					-- TESTING: Try collect all keys to see which will be recorded 
					AzeriteEssences.Total[essenceID] = { ID = ID, Name = Name, Rank = Rank, Unlocked = Unlocked, Valid = Valid, Icon = Icon }
					AzeriteEssences.Total[ID] = { ID = ID, Name = Name, Rank = Rank, Unlocked = Unlocked, Valid = Valid, Icon = Icon }	
					AzeriteEssences.Total[Name] = { ID = ID, Name = Name, Rank = Rank, Unlocked = Unlocked, Valid = Valid, Icon = Icon }	
				end 
			end 			
		end 		
	end 
end 

local function AzeriteTraitsUpdate()  	
	local AzeriteItems = {}      	
	for i = 1, #ItemSlots do
		AzeriteItems[ItemSlots[i]] = Item:CreateFromEquipmentSlot(ItemSlots[i])
	end
	wipe(AzeriteTraits)            
	for slot, item in pairs(AzeriteItems) do
		if not item:IsItemEmpty() then
			local itemLoc = item:GetItemLocation()
			-- Azerite Empower
			if slot ~= 2 and AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLoc) then
				local tierInfos = AzeriteEmpoweredItem.GetAllTierInfo(itemLoc)
				for _, tierInfo in pairs(tierInfos) do
					for _, powerId in pairs(tierInfo.azeritePowerIDs) do
						if AzeriteEmpoweredItem.IsPowerSelected(itemLoc, powerId) then
							local spellIDAzerite = GetSpellInfo(C_AzeriteEmpoweredItem.GetPowerInfo(powerId).spellID)
							if not AzeriteTraits[spellIDAzerite] then
								AzeriteTraits[spellIDAzerite] = 1
							else
								AzeriteTraits[spellIDAzerite] = AzeriteTraits[spellIDAzerite] + 1
							end                                    
						end
					end
				end
			end
			-- Azerite Essence
			if slot == 2 then 
				AzeriteEssenceUpdate() 
			end 
		end
	end       
end

-- Azerite Empower
RubimRH.Listener:Add("Rubim_Events", "PLAYER_ENTERING_WORLD", AzeriteTraitsUpdate)
RubimRH.Listener:Add("Rubim_Events", "PLAYER_EQUIPMENT_CHANGED", AzeriteTraitsUpdate)
RubimRH.Listener:Add("Rubim_Events", "SPELLS_CHANGED", AzeriteTraitsUpdate)

function AzeriteRank(spellID)
    local rank = AzeriteTraits[GetSpellInfo(spellID)]
    return rank and rank or 0
end

-- Azerite Essence
if AzeriteEssence then
	RubimRH.Listener:Add("Rubim_Events", "AZERITE_ESSENCE_CHANGED", AzeriteEssenceUpdate)
	RubimRH.Listener:Add("Rubim_Events", "AZERITE_ESSENCE_ACTIVATED", AzeriteEssenceUpdate)
	RubimRH.Listener:Add("Rubim_Events", "AZERITE_ESSENCE_ACTIVATION_FAILED", AzeriteEssenceUpdate)
end 

function AzeriteEssenceGet(ID)
	return AzeriteEssences.Total[GetSpellInfo(ID)] or AzeriteEssences.Total[ID]
end 

function AzeriteEssenceGetMajor(ID)
	return AzeriteEssences.Major[GetSpellInfo(ID)] or AzeriteEssences.Major[ID]
end 

function AzeriteEssenceGetMinor(ID)
	return AzeriteEssences.Minor[GetSpellInfo(ID)] or AzeriteEssences.Minor[ID]
end 

function AzeriteEssenceHasActionSpell(spellID) -- doesn't work properly while we have TESTING phase 
	local SpellName = GetSpellInfo(spellID)
	return AzeriteEssences.Major[SpellName] and AzeriteEssences.Major[SpellName].IsAction
end 

--[[
C_AzeriteEssence.GetEssenceInfo(essenceID)
C_AzeriteEssence.GetActiveEssence(slot)
C_AzeriteEssence.CanActivateEssence(slot or id)
C_AzeriteEmpoweredItem.IsHeartOfAzerothEquipped()

https://github.com/mrbuds/wow-api-web/blob/1eb680b5f4fb66484bacff217bfba2f479ab31bf/Blizzard_APIDocumentation/AzeriteEssenceDocumentation.lua
https://github.com/tomrus88/BlizzardInterfaceCode/blob/master/Interface/AddOns/Blizzard_AzeriteEssenceUI/Blizzard_AzeriteEssenceUI.lua
https://github.com/simulationcraft/simc-addon/blob/master/core.lua
]]