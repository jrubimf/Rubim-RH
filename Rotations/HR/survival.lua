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
		


	  -- Spells
	  if not Spell.Hunter then Spell.Hunter = {}; end
	  Spell.Hunter.Survival = {
		-- Racials
		ArcaneTorrent                 = Spell(25046),
		Berserking                    = Spell(26297),
		BloodFury                     = Spell(20572),
		GiftoftheNaaru                = Spell(59547),
		Shadowmeld                    = Spell(58984),
		-- Abilities
		AspectoftheEagle              = Spell(186289),
		Carve                         = Spell(187708),
		ExplosiveTrap                 = Spell(191433),
		ExplosiveTrapDot              = Spell(13812),
		FlankingStrike                = Spell(202800),
		Harpoon                       = Spell(190925),
		Lacerate                      = Spell(185855),
		MongooseBite                  = Spell(190928),
		MongooseFury                  = Spell(190931),
		RaptorStrike                  = Spell(186270),
		-- Talents
		AMurderofCrows                = Spell(206505),
		AnimalInstincts               = Spell(204315),
		Butchery                      = Spell(212436),
		Caltrops                      = Spell(187698),
		CaltropsDebuff                = Spell(194279),
		CaltropsTalent                = Spell(194277),
		DragonsfireGrenade            = Spell(194855),
		MokNathalTactics              = Spell(201081),
		SerpentSting                  = Spell(87935),
		SerpentStingDebuff            = Spell(118253),
		SnakeHunter                   = Spell(201078),
		SpittingCobra                 = Spell(194407),
		SteelTrap                     = Spell(187650),
		SteelTrapDebuff               = Spell(162487),
		SteelTrapTalent               = Spell(162488),
		ThrowingAxes                  = Spell(200163),
		WayoftheMokNathal             = Spell(201082),
		-- Artifact
		FuryoftheEagle                = Spell(203415),
		-- Defensive
		AspectoftheTurtle             = Spell(186265),
		Exhilaration                  = Spell(109304),
		-- Utility
		-- Legendaries
		-- Misc
		ExposedFlank                  = Spell(252094),
		PotionOfProlongedPowerBuff    = Spell(229206),
		SephuzBuff                    = Spell(208052),
		PoolFocus                     = Spell(9999000010)
		-- Macros
	  };
	  local S = Spell.Hunter.Survival;
	  -- Items
	  if not Item.Hunter then Item.Hunter = {}; end
	  Item.Hunter.Survival = {
		-- Legendaries
		FrizzosFinger                 = Item(137043, {11, 12}),
		SephuzSecret                  = Item(132452, {11,12}),
		-- Trinkets
		ConvergenceofFates            = Item(140806, {13, 14}),
		-- Potions
		PotionOfProlongedPower        = Item(142117)
	  };
	  local I = Item.Hunter.Survival;
	  -- Rotation Var
	  
	  -- GUI Settings
		-- actions=variable,name=frizzosEquipped,value=(equipped.137043)
	  local function FrizzosEquipped ()
		return I.FrizzosFinger:IsEquipped();
	  end
	  -- actions+=/variable,name=mokTalented,value=(talent.way_of_the_moknathal.enabled)
	  local function MokTalented ()
		return S.WayoftheMokNathal:IsAvailable();
	  end
	  local function CDs ()
		if CDsON() then
		  -- actions.CDs=arcane_torrent,if=focus<=30
		  if S.ArcaneTorrent:IsCastable() and Player:Focus() <= 30 then
			return S.ArcaneTorrent:ID()
		  end
		  -- actions.CDs+=/berserking,if=buff.aspect_of_the_eagle.up
		  if S.Berserking:IsCastable() and Player:Buff(S.AspectoftheEagle) then
			return S.Berserking:ID()
		  end
		  -- actions.CDs+=/blood_fury,if=buff.aspect_of_the_eagle.up
		  if S.BloodFury:IsCastable() and Player:Buff(S.AspectoftheEagle) then
			return S.BloodFury:ID()
		  end
		  -- actions.CDs+=/potion,if=buff.aspect_of_the_eagle.up&(buff.berserking.up|buff.blood_fury.up)
		  -- actions.CDs+=/snake_hunter,if=cooldown.mongoose_bite.charges=0&buff.mongoose_fury.remains>3*gcd&(cooldown.aspect_of_the_eagle.remains>5&!buff.aspect_of_the_eagle.up)
		  if S.SnakeHunter:IsCastable() and S.MongooseBite:Charges() == 0 and Player:BuffRemains(S.MongooseFury) > 3 * Player:GCD() and (S.AspectoftheEagle:CooldownRemains() > 5 and not Player:BuffP(S.AspectoftheEagle)) then
			return S.SnakeHunter:ID()
		  end
		  -- actions.CDs+=/aspect_of_the_eagle,if=buff.mongoose_fury.up&(cooldown.mongoose_bite.charges=0|buff.mongoose_fury.remains<11)
		  if S.AspectoftheEagle:IsCastable() and Player:BuffP(S.MongooseFury) and (S.MongooseBite:Charges() == 0 or Player:BuffRemainsP(S.MongooseFury) < 11) then
			return S.AspectoftheEagle:ID()
		  end
		end
	  end
	  local function AoE ()
		if AoEON() then
		  -- actions.aoe=butchery
		  if S.Butchery:IsCastable() and Player:FocusPredicted(0.2) > 40 then
			return S.Butchery:ID()
		  end
		  -- actions.aoe+=/caltrops,if=!ticking
		  if S.Caltrops:IsCastable() and S.CaltropsTalent:CooldownUp() and not Target:Debuff(S.CaltropsDebuff) and not S.SteelTrapTalent:IsAvailable() then
			return S.Caltrops:ID()
		  end
		  -- actions.aoe+=/explosive_trap
		  if S.ExplosiveTrap:IsCastable() then
			return S.ExplosiveTrap:ID()
		  end
		  -- actions.aoe+=/carve,if=(talent.serpent_sting.enabled&dot.serpent_sting.refreshable)|(active_enemies>5)
		  if S.Carve:IsCastable() and Player:FocusPredicted(0.2) > 35 and ((S.SerpentSting:IsAvailable() and Target:DebuffRefreshable(S.SerpentStingDebuff, 3.6)) or (Cache.EnemiesCount[5] > 5)) then
			return S.IsCastable:ID()
		  end
		end
	  end
	  local function BitePhase ()
		-- actions.bitePhase=mongoose_bite,if=cooldown.mongoose_bite.charges=3
		if S.MongooseBite:IsCastable() and S.MongooseBite:Charges() == 3 then
		  return S.MongooseBite:ID()
		end
		-- actions.bitePhase+=/flanking_strike,if=buff.mongoose_fury.remains>(gcd*(cooldown.mongoose_bite.charges+1))
		if S.FlankingStrike:IsCastable() and Player:FocusPredicted(0.2) > 45 and Player:BuffRemainsP(S.MongooseFury) > (Player:GCD() *(S.MongooseBite:Charges() + 1)) then
		  return S.FlankingStrike:ID()
		end
		-- actions.bitePhase+=/fury_of_the_eagle,if=(!variable.mokTalented|(buff.moknathal_tactics.remains>(gcd*(8%3))))&!buff.aspect_of_the_eagle.up,interrupt_immediate=1,interrupt_if=cooldown.mongoose_bite.charges=3|(ticks_remain<=1&buff.moknathal_tactics.remains<0.7)
		-- Keep the ancient line because of interrupt_immediate=1,interrupt_if
		-- actions.bitePhase=fury_of_the_eagle,if=(!talent.way_of_the_moknathal.enabled|buff.moknathal_tactics.remains>(gcd*(8%3)))&buff.mongoose_fury.stack=6,interrupt_if=(talent.way_of_the_moknathal.enabled&buff.moknathal_tactics.remains<=tick_time)
		if CDsON() and S.FuryoftheEagle:IsCastable() and (not S.WayoftheMokNathal:IsAvailable() or Player:BuffRemains(S.MokNathalTactics) > (Player:GCD() * (8 / 3))) and Player:BuffStack(S.MongooseFury) == 6 then 
		  return S.FuryoftheEagle:ID()
		end
		-- actions.bitePhase+=/mongoose_bite,if=buff.mongoose_fury.up
		if S.MongooseBite:IsCastable() and Player:Buff(S.MongooseFury) then
		  return S.MongooseBite:ID()
		end
		-- actions.bitePhase+=/lacerate,if=dot.lacerate.refreshable&(focus+35>(45-((cooldown.flanking_strike.remains%gcd)*(focus.regen*gcd))))
		if S.Lacerate:IsCastable() and Player:FocusPredicted(0.2) > 30 and Target:DebuffRefreshable(S.Lacerate, 3.6) and (Player:Focus() + 35 >(45 -((S.FlankingStrike:CooldownRemains() / Player:GCD()) * (Player:FocusRegen() * Player:GCD())))) then
		  return S.Lacerate:ID()
		end
		-- actions.bitePhase+=/raptor_strike,if=buff.t21_2p_exposed_flank.up
		if S.RaptorStrike:IsCastable() and Player:FocusPredicted(0.2) > 25 and Player:BuffP(S.ExposedFlank) then
		  return S.RaptorStrike:ID()
		end
		-- actions.bitePhase+=/spitting_cobra
		if S.SpittingCobra:IsCastable() then
		  return S.SpittingCobra:ID()
		end
		-- actions.bitePhase+=/dragonsfire_grenade
		if S.DragonsfireGrenade:IsCastable() then
		  return S.DragonsfireGrenade:ID()
		end
		-- actions.bitePhase+=/steel_trap
		if S.SteelTrap:IsCastable() and S.SteelTrapTalent:CooldownUp() and not S.CaltropsTalent:IsAvailable() then
		  return S.SteelTrap:ID()
		end
		-- actions.bitePhase+=/a_murder_of_crows
		if S.AMurderofCrows:IsCastable() and Player:FocusPredicted(0.2) > 30 then
		  return S.AMurderofCrows:ID()
		end
		-- actions.bitePhase+=/caltrops,if=!ticking
		if S.Caltrops:IsCastable() and S.CaltropsTalent:CooldownUp() and not Target:Debuff(S.CaltropsDebuff) and not S.SteelTrapTalent:IsAvailable() then
		  return S.Caltrops:ID()
		end
		-- actions.bitePhase+=/explosive_trap
		if S.ExplosiveTrap:IsCastable() then
		  return S.ExplosiveTrap:ID()
		end
	  end
	  local function BiteTrigger ()
		-- actions.biteTrigger=lacerate,if=remains<14&set_bonus.tier20_4pc&cooldown.mongoose_bite.remains<gcd*3
		if S.Lacerate:IsCastable() and Target:DebuffRemainsP(S.Lacerate) < 14 and AC.Tier20_4Pc and S.MongooseBite:CooldownRemains() < Player:GCD() * 3 then
		  return S.Lacerate:ID()
		end
		-- actions.biteTrigger+=/mongoose_bite,if=charges>=2
		if S.MongooseBite:IsCastable() and S.MongooseBite:Charges() >= 3 then
		  return S.MongooseBite:ID()
		end
	  end
	  local function Fillers ()
		-- actions.fillers=flanking_strike,if=cooldown.mongoose_bite.charges<3
		if S.FlankingStrike:IsCastable() and Player:FocusPredicted(0.2) > 45 and S.MongooseBite:Charges() < 3 then
		  return S.FlankingStrike:ID()
		end
		-- actions.fillers+=/spitting_cobra
		if S.SpittingCobra:IsCastable() then
		  return S.SpittingCobra:ID()
		end
		-- actions.fillers+=/dragonsfire_grenade
		if S.DragonsfireGrenade:IsCastable() then
		  return S.DragonsfireGrenade:ID()
		end
		-- actions.fillers+=/lacerate,if=refreshable|!ticking
		if S.Lacerate:IsCastable() and Player:FocusPredicted(0.2) > 30 and (Target:DebuffRefreshable(S.Lacerate, 3.6) or not Target:Debuff(S.Lacerate)) then
		  return S.Lacerate:ID()
		end
		-- actions.fillers+=/raptor_strike,if=buff.t21_2p_exposed_flank.up&!variable.mokTalented
		if S.RaptorStrike:IsCastable() and Player:FocusPredicted(0.2) > 25 and Player:BuffP(S.ExposedFlank) and not MokTalented() then
		  return S.RaptorStrike:ID()
		end
		-- actions.fillers+=/raptor_strike,if=(talent.serpent_sting.enabled&!dot.serpent_sting.ticking)
		if S.RaptorStrike:IsCastable() and Player:FocusPredicted(0.2) > 25 and (S.SerpentSting:IsAvailable() and not Target:Debuff(S.SerpentStingDebuff)) then
		  return S.RaptorStrike:ID()
		end
		-- actions.fillers+=/steel_trap,if=refreshable|!ticking
		if S.SteelTrap:IsCastable() and S.SteelTrapTalent:CooldownUp() and not S.CaltropsTalent:IsAvailable() and (Target:DebuffRefreshable(S.SteelTrapDebuff, 3.6) or not Target:Debuff(S.SteelTrapTalent)) then
		  return S.SteelTrap:ID()
		end
		-- actions.fillers+=/caltrops,if=refreshable|!ticking
		if S.Caltrops:IsCastable() and S.CaltropsTalent:CooldownUp() and not S.SteelTrapTalent:IsAvailable() and (Target:DebuffRefreshable(S.CaltropsDebuff, 3.6) or not Target:Debuff(S.CaltropsDebuff)) then
		  return S.Caltrops:ID()
		end
		-- actions.fillers+=/explosive_trap
		if S.ExplosiveTrap:IsCastable() then
		  return S.ExplosiveTrap:ID()
		end
		-- actions.fillers+=/butchery,if=variable.frizzosEquipped&dot.lacerate.refreshable&(focus+40>(50-((cooldown.flanking_strike.remains%gcd)*(focus.regen*gcd))))
		if S.Butchery:IsCastable() and Player:FocusPredicted(0.2) > 40 and FrizzosEquipped() and Target:DebuffRefreshable(S.Lacerate, 3.6) and (Player:Focus() + 40 >(50 -((S.FlankingStrike:CooldownRemains() / Player:GCD()) * (Player:FocusRegen() * Player:GCD())))) then
		  return S.Butchery:ID()
		end
	  end
	  local function MokMaintain ()
		-- actions.mokMaintain=raptor_strike,if=(buff.moknathal_tactics.remains<(gcd)|(buff.moknathal_tactics.stack<3))
		if S.RaptorStrike:IsCastable() and Player:FocusPredicted(0.2) > 25 and ((Player:BuffRemainsP(S.MokNathalTactics) < (Player:GCD())) or (Player:BuffStack(S.MokNathalTactics) < 3)) then
		  return S.RaptorStrike:ID()
		end
	  end
	--- APL Main
	function SurvRotation()
		-- Unit Update
		AC.GetEnemies(8);
		AC.GetEnemies(5);
		-- Defensives
		  -- Exhilaration
		  if S.Exhilaration:IsCastable() and Player:HealthPercentage() <= 70 then
			return S.Exhilaration:ID()
		  end
		-- Out of Combat
		if not Player:AffectingCombat() then
			return 146250
		end
		-- In Combat
		  
		  -- actions+=/call_action_list,name=mokMaintain,if=variable.mokTalented
		  if MokTalented() then
			if MokMaintain() ~= nil then
				return MokMaintain()
			end
		  end
		  -- actions+=/call_action_list,name=CDs
		  if CDs() ~= nil then
				return CDs()
			end
		  -- actions+=/call_action_list,name=aoe,if=active_enemies>=3
		  if Cache.EnemiesCount[5] >= 3 then
			if AoE() ~= nil then
				return AoE()
			end
		  end
		  -- actions+=/call_action_list,name=fillers,if=!buff.mongoose_fury.up
		  if not Player:BuffP(S.MongooseFury) then
			if Fillers() ~= nil then
				return Fillers()
			end
		  end
		  -- actions+=/call_action_list,name=biteTrigger,if=!buff.mongoose_fury.up
		  if not Player:BuffP(S.MongooseFury) then
			if BiteTrigger() ~= nil then
				return BitePhase()
			end
		  end
		  -- actions+=/call_action_list,name=bitePhase,if=buff.mongoose_fury.up
		  if Player:BuffP(S.MongooseFury) then
			if BitePhase() ~= nil then
				return BitePhase()
			end
		  end
		  return 233159
	  end


	--- Last Update: 11/28/2017


	-- # Executed before combat begins. Accepts non-harmful actions only.
	-- actions.precombat=flask
	-- actions.precombat+=/augmentation
	-- actions.precombat+=/food
	-- actions.precombat+=/summon_pet
	-- # Snapshot raid buffed stats before combat begins and pre-potting is done.
	-- actions.precombat+=/snapshot_stats
	-- actions.precombat+=/potion
	-- actions.precombat+=/explosive_trap
	-- actions.precombat+=/steel_trap
	-- actions.precombat+=/dragonsfire_grenade
	-- actions.precombat+=/harpoon

	-- # Executed every time the actor is available.
	-- actions=variable,name=frizzosEquipped,value=(equipped.137043)
	-- actions+=/variable,name=mokTalented,value=(talent.way_of_the_moknathal.enabled)
	-- actions+=/use_items
	-- actions+=/muzzle,if=target.debuff.casting.react
	-- actions+=/auto_attack
	-- actions+=/call_action_list,name=mokMaintain,if=variable.mokTalented
	-- actions+=/call_action_list,name=CDs
	-- actions+=/call_action_list,name=aoe,if=active_enemies>=3
	-- actions+=/call_action_list,name=fillers,if=!buff.mongoose_fury.up
	-- actions+=/call_action_list,name=biteTrigger,if=!buff.mongoose_fury.up
	-- actions+=/call_action_list,name=bitePhase,if=buff.mongoose_fury.up

	-- actions.CDs=arcane_torrent,if=focus<=30
	-- actions.CDs+=/berserking,if=buff.aspect_of_the_eagle.up
	-- actions.CDs+=/blood_fury,if=buff.aspect_of_the_eagle.up
	-- actions.CDs+=/potion,if=buff.aspect_of_the_eagle.up&(buff.berserking.up|buff.blood_fury.up)
	-- actions.CDs+=/snake_hunter,if=cooldown.mongoose_bite.charges=0&buff.mongoose_fury.remains>3*gcd&(cooldown.aspect_of_the_eagle.remains>5&!buff.aspect_of_the_eagle.up)
	-- actions.CDs+=/aspect_of_the_eagle,if=buff.mongoose_fury.up&(cooldown.mongoose_bite.charges=0|buff.mongoose_fury.remains<11)

	-- actions.aoe=butchery
	-- actions.aoe+=/caltrops,if=!ticking
	-- actions.aoe+=/explosive_trap
	-- actions.aoe+=/carve,if=(talent.serpent_sting.enabled&dot.serpent_sting.refreshable)|(active_enemies>5)

	-- actions.bitePhase=mongoose_bite,if=cooldown.mongoose_bite.charges=3
	-- actions.bitePhase+=/flanking_strike,if=buff.mongoose_fury.remains>(gcd*(cooldown.mongoose_bite.charges+1))
	-- actions.bitePhase+=/mongoose_bite,if=buff.mongoose_fury.up
	-- actions.bitePhase+=/fury_of_the_eagle,if=(!variable.mokTalented|(buff.moknathal_tactics.remains>(gcd*(8%3))))&!buff.aspect_of_the_eagle.up,interrupt_immediate=1,interrupt_if=cooldown.mongoose_bite.charges=3|(ticks_remain<=1&buff.moknathal_tactics.remains<0.7)
	-- actions.bitePhase+=/lacerate,if=dot.lacerate.refreshable&(focus+35>(45-((cooldown.flanking_strike.remains%gcd)*(focus.regen*gcd))))
	-- actions.bitePhase+=/raptor_strike,if=buff.t21_2p_exposed_flank.up
	-- actions.bitePhase+=/spitting_cobra
	-- actions.bitePhase+=/dragonsfire_grenade
	-- actions.bitePhase+=/steel_trap
	-- actions.bitePhase+=/a_murder_of_crows
	-- actions.bitePhase+=/caltrops,if=!ticking
	-- actions.bitePhase+=/explosive_trap

	-- actions.biteTrigger=lacerate,if=remains<14&set_bonus.tier20_4pc&cooldown.mongoose_bite.remains<gcd*3
	-- actions.biteTrigger+=/mongoose_bite,if=charges>=2

	-- actions.fillers=flanking_strike,if=cooldown.mongoose_bite.charges<3
	-- actions.fillers+=/spitting_cobra
	-- actions.fillers+=/dragonsfire_grenade
	-- actions.fillers+=/lacerate,if=refreshable|!ticking
	-- actions.fillers+=/raptor_strike,if=buff.t21_2p_exposed_flank.up&!variable.mokTalented
	-- actions.fillers+=/raptor_strike,if=(talent.serpent_sting.enabled&!dot.serpent_sting.ticking)
	-- actions.fillers+=/steel_trap,if=refreshable|!ticking
	-- actions.fillers+=/caltrops,if=refreshable|!ticking
	-- actions.fillers+=/explosive_trap
	-- actions.fillers+=/butchery,if=variable.frizzosEquipped&dot.lacerate.refreshable&(focus+40>(50-((cooldown.flanking_strike.remains%gcd)*(focus.regen*gcd))))
	-- actions.fillers+=/carve,if=variable.frizzosEquipped&dot.lacerate.refreshable&(focus+40>(50-((cooldown.flanking_strike.remains%gcd)*(focus.regen*gcd))))
	-- actions.fillers+=/flanking_strike
	-- actions.fillers+=/raptor_strike,if=(variable.mokTalented&buff.moknathal_tactics.remains<gcd*4)|(focus>((25-focus.regen*gcd)+55))

	-- actions.mokMaintain=raptor_strike,if=(buff.moknathal_tactics.remains<(gcd)|(buff.moknathal_tactics.stack<3))