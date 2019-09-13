AddCSLuaFile()

SWEP.PrintName				= "Hoe"
SWEP.Author					= "Eryk"
SWEP.Purpose				= "A weapon used for building cropplots"
SWEP.Category				= "Farmingmod"

SWEP.Slot					= 0
SWEP.SlotPos				= 1

SWEP.Spawnable				= FARMINGMOD.Enabled

SWEP.ViewModel				= Model( "models/weapons/eryk/farmingmod/v_hoe.mdl" )
SWEP.WorldModel				= Model( "models/weapons/eryk/farmingmod/w_hoe.mdl" )
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

local SwingSound = Sound( "WeaponFrag.Throw" )

function SWEP:Initialize()
	self:SetWeaponHoldType( self.HoldType )
end

function SWEP:GhostProp(trace)
	self.ghostProp = ents.CreateClientProp()
	self.ghostProp:SetModel( "models/props/eryk/farmingmod/cropplot.mdl" )
	self.ghostProp:SetMaterial("models/wireframe")
	self.ghostProp:Spawn()
	self.ghostProp:Activate()
end

function SWEP:SetupDataTables()
	self:NetworkVar( "Bool", 0, "canBuildCropplot" )
	self:SetNWBool("buildEnable", true)
end

function SWEP:CalcViewModelView( vm, oldPos, oldAng, pos, ang )
	local oldPos = vm:GetPos()
	local oldAng = vm:GetAngles()

	local newPos = pos + ang:Up() * 5 + ang:Forward() * -12
	return newPos, ang
end

function SWEP:CheckCollisionBox()

	local tr = self.Owner:GetEyeTrace()

	local hitVector = tr.HitPos

	local check = true

	for k, v in pairs( ents.FindInSphere( tr.HitPos, 25 ) ) do
		self:SetcanBuildCropplot( false )

		if (check) then
			check = false
		end
	end

	return check

end

function SWEP:PrimaryAttack( right )

	local tr = self.Owner:GetEyeTrace()
	local normal = tr.HitNormal:Angle().p

	if (SERVER) then
		self.Owner:SetAnimation( PLAYER_ATTACK1 )

		if (tr.HitWorld and normal > 90 and tr.StartPos:Distance(tr.HitPos) < 250) then
			if self:CheckCollisionBox() and FARMINGMOD:MaxPlots(self.Owner) then

				local cropplot = ents.Create("farmingmod_cropplot")
				cropplot:SetPos(tr.HitPos + Vector(0, 0, 2))
				cropplot:SetAngles(Angle(0,self.Owner:GetAngles().y,0))
				cropplot:Activate()
				cropplot:Spawn()
				cropplot:SetPlayer(self.Owner)

				FARMINGMOD:RegisterPlot(cropplot, self.Owner)

				self.Owner:SendLua("surface.PlaySound( \"weapons/iceaxe/iceaxe_swing1.wav\" )")
			else
				self.Owner:SendLua("surface.PlaySound( \"common/wpn_denyselect.wav\" )")
			end
		else
			self.Owner:SendLua("surface.PlaySound( \"common/wpn_denyselect.wav\" )")
		end
	end

	self:SendWeaponAnim( ACT_VM_HITCENTER )

	self:SetNextPrimaryFire( CurTime() + 0.4 )
	self:SetNextSecondaryFire( CurTime() + 0.4 )
end

function SWEP:SecondaryAttack()

	local tr = self.Owner:GetEyeTrace()

	if (SERVER) then
		self.Owner:SendLua("surface.PlaySound( \"weapons/iceaxe/iceaxe_swing1.wav\" )")
		if (IsValid(tr.Entity)) then
			if (tr.Entity:GetClass() == "farmingmod_cropplot") and (tr.Entity.Player == self.Owner) then
				FARMINGMOD:RemovePlot(tr.Entity, self.Owner)

				self.Owner:SetAnimation( PLAYER_ATTACK1 )

			end
		end
	end

	self:SetNextPrimaryFire( CurTime() + 0.4 )
	self:SetNextSecondaryFire( CurTime() + 0.4 )

	self:SendWeaponAnim( ACT_VM_HITCENTER )
end

function SWEP:Think()

	local tr = self.Owner:GetEyeTrace()
	local normal = tr.HitNormal:Angle().p

	if (SERVER) then

		for k, v in pairs( ents.FindInSphere( tr.HitPos, 25 ) ) do
			self:SetcanBuildCropplot( false )
		end

		self:SetNWBool("buildEnable", self:GetcanBuildCropplot())

		if (tr.HitWorld and normal > 90 and tr.StartPos:Distance(tr.HitPos) < 250 ) then
			self:SetcanBuildCropplot( true )
		else
			self:SetcanBuildCropplot( false )
		end
	end

	if (CLIENT) then

		if (input.IsKeyDown(KEY_R) and !g_SpawnMenu:IsVisible() and !gui.IsConsoleVisible() and gui.MouseX() == 0) then
			if (!IsValid(FARMINGMOD.PANELS.Encyclopedia)) then
				FARMINGMOD:Encyclopedia()
			end
		end

		if (IsValid(self.ghostProp)) then

			if (!self:GetNWBool("buildEnable")) then
				self.ghostProp:SetColor(Color(255, 0, 0, 255))
				self.ghostProp:SetRenderMode(RENDERMODE_TRANSALPHA)
			else
				self.ghostProp:SetColor(Color(0, 255, 0, 255))
				self.ghostProp:SetRenderMode(RENDERMODE_TRANSALPHA)
			end

			if (self:GetcanBuildCropplot()) then
				self.ghostProp:SetNoDraw( false )

				self.ghostProp:SetPos(tr.HitPos + Vector(0, 0, 2))
				self.ghostProp:SetAngles(Angle(0, self.Owner:GetAngles().y, 0))

			else
				self.ghostProp:SetNoDraw( true )
			end

		end
	end

end


function SWEP:PreDrawViewModel()
	if (CLIENT) then
		if (!IsValid(self.ghostProp)) then
			self:GhostProp()
		end
	end
end

function SWEP:Holster()
	if (CLIENT) then
		if (IsValid(self.ghostProp)) then
			self.ghostProp:Remove()
		end
	end
	return true
end

function SWEP:OnDrop()
	self:Remove()
end

function SWEP:OnRemove()
	if (CLIENT) then
		if (IsValid(self.ghostProp)) then
			self.ghostProp:Remove()
		end
	end
end
