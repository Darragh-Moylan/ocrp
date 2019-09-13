//Code: Eryk

ENT.Base 			= "base_ai"
ENT.Type 			= "ai"
ENT.PrintName 		= "NPC Shop"
ENT.Author 			= "Eryk"
ENT.Information		= "Buy & Sell Items"
ENT.Category		= "Farmingmod"

ENT.Spawnable				= FARMINGMOD.Enabled
ENT.AutomaticFrameAdvance 	= true

function ENT:SetAutomaticFrameAdvance( bUsingAnim )
	self.AutomaticFrameAdvance = bUsingAnim
end
 
