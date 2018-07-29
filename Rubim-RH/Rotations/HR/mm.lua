local addonName, addonTable = ...;
local HL = HeroLib;
local Cache = HeroCache;
local Unit = HL.Unit;
local Player = Unit.Player;
local Target = Unit.Target;
local Spell = HL.Spell;
local Item = HL.Item;

local S = RubimRH.Spell[254]

if not Item.Hunter then 
	Item.Hunter = {}
end

Item.Hunter.Marksmanship = {
	-- Legendaries
	SephuzSecret 	                = Item(132452, {11,12}),
	-- Trinkets
	onvergenceofFates           	= Item(140806, {13, 14}),
	-- Potions
	PotionOfProlongedPower          = Item(142117),
}
local I = Item.Hunter.Marksmanship

S.AimedShot:RegisterInFlight()

local function APL()
	HL.GetEnemies(40)

	local function Precombat()
		if S.HuntersMark:IsReady() and Player:DebuffDownP(S.HuntersMark) then
			return S.HuntersMark:Cast()
		end
		-- double_tap,precast_time=5
		if S.DoubleTap:IsReady() then
			return S.DoubleTap:Cast()
		end
		-- aimed_shot,if=active_enemies<3
		if S.AimedShot:IsReady() and (Cache.EnemiesCount[40] < 3) then
			return S.AimedShot:Cast()
		end
		-- explosive_shot,if=active_enemies>2
		if S.ExplosiveShot:IsReady() and (Cache.EnemiesCount[40] > 2) then
			return S.ExplosiveShot:Cast()
		end
		return 0, 462338
	end	

	-- call precombat
	if not Player:AffectingCombat() then
		if Precombat() ~= nil then
			return Precombat()
		end
	end  

	-- auto_shot
	-- counter_shot,if=equipped.sephuzs_secret&target.debuff.casting.react&cooldown.buff_sephuzs_secret.up&!buff.sephuzs_secret.up
	-- use_items
	-- hunters_mark,if=debuff.hunters_mark.down
	if S.HuntersMark:IsReady() and (Target:DebuffDownP(S.HuntersMarkDebuff)) then
		return S.HuntersMark:Cast()
	end
	-- double_tap,if=cooldown.rapid_fire.remains<gcd
	if S.DoubleTap:IsReady() and (S.RapidFire:CooldownRemainsP() < Player:GCD()) then
		return S.DoubleTap:Cast()
	end
	-- berserking,if=cooldown.trueshot.remains>30
	if S.Berserking:IsReady() and RubimRH.CDsON() and (S.TrueShot:CooldownRemainsP() > 30) then
		return S.Berserking, Settings.Commons.OffGCDasOffGCD.Racials:Cast()
	end
	-- blood_fury,if=cooldown.trueshot.remains>30
	if S.BloodFury:IsReady() and RubimRH.CDsON() and (S.TrueShot:CooldownRemainsP() > 30) then
		return S.BloodFury, Settings.Commons.OffGCDasOffGCD.Racials:Cast()
	end
	-- ancestral_call,if=cooldown.trueshot.remains>30
	if S.AncestralCall:IsReady() and (S.TrueShot:CooldownRemainsP() > 30) then
		return S.AncestralCall:Cast()
	end
	-- fireblood,if=cooldown.trueshot.remains>30
	if S.Fireblood:IsReady() and (S.TrueShot:CooldownRemainsP() > 30) then
		return S.Fireblood:Cast()
	end
	-- lights_judgment
	if S.LightsJudgment:IsReady() and RubimRH.CDsON() and (true) then
		return S.LightsJudgment:Cast()
	end
	-- potion,if=(buff.trueshot.react&buff.bloodlust.react)|((consumable.prolonged_power&target.time_to_die<62)|target.time_to_die<31)

	-- trueshot,if=cooldown.aimed_shot.charges<1
	if S.TrueShot:IsReady() and (S.AimedShot:ChargesP() < 1) then
		return S.TrueShot:Cast()
	end
	-- barrage,if=active_enemies>1
	if S.Barrage:IsReady() and (Cache.EnemiesCount[40] > 1) then
		return S.Barrage:Cast()
	end
	-- explosive_shot,if=active_enemies>1
	if S.ExplosiveShot:IsReady() and (Cache.EnemiesCount[40] > 1) then
		return S.ExplosiveShot:Cast()
	end
	-- multishot,if=active_enemies>2&buff.precise_shots.up&cooldown.aimed_shot.full_recharge_time<gcd*buff.precise_shots.stack+action.aimed_shot.cast_time
	if S.MultiShot:IsReady() and (Cache.EnemiesCount[40] > 2 and Player:BuffP(S.PreciseShotsBuff) and S.AimedShot:FullRechargeTime() < Player:GCD() * Player:BuffStackP(S.PreciseShotsBuff) + S.AimedShot:CastTime()) then
		return S.MultiShot:Cast()
	end
	-- arcane_shot,if=active_enemies<3&buff.precise_shots.up&cooldown.aimed_shot.full_recharge_time<gcd*buff.precise_shots.stack+action.aimed_shot.cast_time
	if S.ArcaneShot:IsReady() and (Cache.EnemiesCount[40] < 3 and Player:BuffP(S.PreciseShotsBuff) and S.AimedShot:FullRechargeTime() < Player:GCD() * Player:BuffStackP(S.PreciseShotsBuff) + S.AimedShot:CastTime()) then
		return S.ArcaneShot:Cast()
	end
	-- aimed_shot,if=buff.precise_shots.down&buff.double_tap.down&(active_enemies>2&buff.trick_shots.up|active_enemies<3&full_recharge_time<cast_time+gcd)
	if S.AimedShot:IsReady() and (Player:BuffDownP(S.PreciseShotsBuff) and Player:BuffDownP(S.DoubleTapBuff) and (Cache.EnemiesCount[40] > 2 and Player:BuffP(S.TrickShotsBuff) or Cache.EnemiesCount[40] < 3 and S.AimedShot:FullRechargeTimeP() < S.AimedShot:CastTime() + Player:GCD())) then
		return S.AimedShot:Cast()
	end
	-- rapid_fire,if=active_enemies<3|buff.trick_shots.up
	if S.RapidFire:IsReady() and (Cache.EnemiesCount[40] < 3 or Player:BuffP(S.TrickShotsBuff)) then
		return S.RapidFire:Cast()
	end
	-- explosive_shot
	if S.ExplosiveShot:IsReady() and (true) then
		return S.ExplosiveShot:Cast()
	end
	-- barrage
	if S.Barrage:IsReady() and (true) then
		return S.Barrage:Cast()
	end
	-- piercing_shot
	if S.PiercingShot:IsReady() and (true) then
		return S.PiercingShot:Cast()
	end
	-- a_murder_of_crows
	if S.AMurderofCrows:IsReady() and (true) then
		return S.AMurderofCrows:Cast()
	end
	-- multishot,if=active_enemies>2&buff.trick_shots.down
	if S.MultiShot:IsReady() and (Cache.EnemiesCount[40] > 2 and Player:BuffDownP(S.TrickShotsBuff)) then
		return S.MultiShot:Cast()
	end
	-- aimed_shot,if=buff.precise_shots.down&(focus>70|buff.steady_focus.down)
	if S.AimedShot:IsReady() and (Player:BuffDownP(S.PreciseShotsBuff) and (Player:Focus() > 70 or Player:BuffDownP(S.SteadyFocusBuff))) then
		return S.AimedShot:Cast()
	end
	-- multishot,if=active_enemies>2&(focus>90|buff.precise_shots.up&(focus>70|buff.steady_focus.down&focus>45))
	if S.MultiShot:IsReady() and (Cache.EnemiesCount[40] > 2 and (Player:Focus() > 90 or Player:BuffP(S.PreciseShotsBuff) and (Player:Focus() > 70 or Player:BuffDownP(S.SteadyFocusBuff) and Player:Focus() > 45))) then
		return S.MultiShot:Cast()
	end
	-- arcane_shot,if=active_enemies<3&(focus>70|buff.steady_focus.down&(focus>60|buff.precise_shots.up))
	if S.ArcaneShot:IsReady() and (Cache.EnemiesCount[40] < 3 and (Player:Focus() > 70 or Player:BuffDownP(S.SteadyFocusBuff) and (Player:Focus() > 60 or Player:BuffP(S.PreciseShotsBuff)))) then
		return S.ArcaneShot:Cast()
	end
	-- serpent_sting,if=refreshable
	if S.SerpentSting:IsReady() and (Target:DebuffRefreshableCP(S.SerpentStingDebuff)) then
		return S.SerpentSting:Cast()
	end
	-- steady_shot
	if S.SteadyShot:IsReady() then
		return S.SteadyShot:Cast()
	end
	return 0, 975743
end

RubimRH.Rotation.SetAPL(254, APL)
local function PASSIVE()
	return RubimRH.Shared()
end

RubimRH.Rotation.SetPASSIVE(254, PASSIVE)