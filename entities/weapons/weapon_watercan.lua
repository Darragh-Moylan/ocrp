AddCSLuaFile()

SWEP.PrintName				= "Watercan"
SWEP.Author					= "Eryk"
SWEP.Purpose				= "A weapon used to water cropplots"
SWEP.Category				= "Farmingmod"

SWEP.Slot					= 0
SWEP.SlotPos				= 1

SWEP.Spawnable				= FARMINGMOD.Enabled

SWEP.ViewModel				= Model( "models/weapons/eryk/farmingmod/v_watercan.mdl" )
SWEP.WorldModel				= Model( "models/weapons/eryk/watercan_weapon/w_watercan.mdl" )
SWEP.ViewModelFOV			= 70
SWEP.UseHands				= false
SWEP.HoldType				= "melee2"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.DrawAmmo				= false
SWEP.HitDistance			= 48

SWEP.Effect = EffectData()

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:CalcViewModelView( vm, oldPos, oldAng, pos, ang )
	local oldPos = vm:GetPos()
	local oldAng = vm:GetAngles()

	local newPos = pos + ang:Up() * -4 + ang:Forward() * -20
  	local newAng = ang + Angle(-18, 0, 0)

	return newPos, newAng
end

function SWEP:PrimaryAttack( right )
	local tr = self.Owner:GetEyeTrace()

	local vPoint = tr.Entity:GetPos() + Vector(0, 0, 15)
	self.Effect:SetOrigin( vPoint )
			
	if (tr.Entity:IsValid() and tr.Entity:GetClass() == "farmingmod_cropplot") and (tr.StartPos:Distance(tr.HitPos) < 100) then
		
		if (SERVER) then
			tr.Entity:IncreaseWater(FARMINGMOD.Config.WaterSpeed + 1)
		end

		util.Effect( "water_effect", self.Effect )
	end

	self:SetNextPrimaryFire( CurTime() + 0.1 )
end

function SWEP:SecondaryAttack()
	return
end
