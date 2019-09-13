//CODE: Eryk

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()

local randomModel = math.random(1,7)

	if (randomModel == 5) then
		randomModel = randomModel + 1
	end

	self:SetModel( "models/humans/group01/female_0" .. randomModel .. ".mdl" )
	self:SetHullType( HULL_HUMAN )
	self:SetHullSizeNormal( )
	self:SetNPCState( NPC_STATE_SCRIPT )
	self:SetSolid(  SOLID_BBOX )
	self:CapabilitiesAdd( CAP_ANIMATEDFACE, CAP_TURN_HEAD )
	self:SetUseType( SIMPLE_USE )
	self:DropToFloor()
	self:Give("weapon_hoe")

	self:SetMaxYawSpeed( 90 )

end

function ENT:AcceptInput( input, activator, caller )
	if input == "Use" and activator:IsPlayer() && activator:KeyPressed( 32 ) then
		net.Start("FARMINGMOD_SHOP")
		net.Send(activator)
	end
end
