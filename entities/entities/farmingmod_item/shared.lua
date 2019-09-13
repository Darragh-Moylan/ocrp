//Code: Eryk

ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Item drop"
ENT.Author 			= "Eryk"
ENT.Information		= "Drop them crops"
ENT.Category		= "Farming mod"

ENT.Spawnable		= false

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SetupDataTables()
    self:NetworkVar("Bool", 0, "Food")
    self:NetworkVar("Int", 0, "Amount")
    self:NetworkVar("String", 0, "EntityName")
end
