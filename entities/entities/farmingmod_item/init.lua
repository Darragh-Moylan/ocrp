
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self.Inventory = {}

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()

	if IsValid(phys) then
		phys:Wake()
	end

	self:SetAmount(self:GetAmount() or 0)
	self:SetFood(false)
end

local function Language()
	return FARMINGMOD.Language[FARMINGMOD.Config.Language]
end

function ENT:SetInventory(table, amount)
	local language = Language()

	self.Inventory = table

	if amount then
		table.amount = amount
	end

	for k, v in pairs(language) do
		if string.lower(tostring(table.name)) == tostring(k) then
			self:SetEntityName(v.name)
		end
	end

	if (self.Inventory.seedbag) then
		self:SetModel("models/props/eryk/farmingmod/seedbag.mdl")

		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)

		local phys = self:GetPhysicsObject()

		if IsValid(phys) then
			phys:Wake()
		end
	end

	self:SetAmount(table.amount)
end

function ENT:GiveHunger(ply)
	if (DarkRP) then
		for k, v in pairs(DarkRP.disabledDefaults["modules"]) do
			if(k == "hungermod" and v == false) then
				ply:setSelfDarkRPVar("Energy", math.Clamp((ply:getDarkRPVar("Energy") or 100) + 10, 0, 100))
			end
		end
	end
end

function ENT:GiveHealth(ply)
	if (ply:Health() <= 100) then
		ply:SetHealth(ply:Health() + 10)
		if (ply:Health() >= 100) then
			ply:SetHealth(100)
		end
	end
end

function ENT:Use(ply, entity)
    if not IsValid(ply) then return end

		if self:GetFood() then
				self:GiveHunger(ply)
				self:GiveHealth(ply)
		else
			FARMINGMOD:AddItems(self.Inventory, self:GetAmount(), ply)
		end

	self:Remove()
end
