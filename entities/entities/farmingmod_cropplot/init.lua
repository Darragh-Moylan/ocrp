
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self.Inventory = {}
	self.Player = {}
	self.Data = {}

  	self:SetModel("models/props/eryk/farmingmod/cropplot.mdl")
  	self:SetSolid(SOLID_VPHYSICS)
  	self:SetMoveType(MOVETYPE_NONE)
  	self:SetUseType( SIMPLE_USE )

	self:AddCrop()
end

function ENT:AddCrop()
	self.crop = ents.Create("prop_physics")
	self.crop:SetModel("models/props/eryk/farmingmod/crop_01.mdl")
	self.crop:SetPos(self:GetPos())
	self.crop:SetCollisionGroup( COLLISION_GROUP_WORLD )
	self.crop:Spawn()
	self.crop:Activate()
	self.crop:SetColor(Color(0,0,0,0))
	self.crop:SetRenderMode( RENDERMODE_TRANSALPHA )
	self.crop:SetNotSolid(true)
	self.crop:SetParent(self)
	self.crop:DrawShadow( false )

	for i = 0, self.crop:GetBoneCount() do
		self:SetNWAngle("Bone" .. i, self.crop:GetManipulateBoneAngles( i ))
	end

	self:SetNWEntity("Crop", self.crop)
end

function ENT:SetPlayer(ply)
	self.Player = ply
end

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Sowed" );
	self:NetworkVar( "Bool", 1, "Fruit" );
	self:NetworkVar( "Bool", 2, "Harvest" );

	self:NetworkVar( "Float", 0, "HP" );
	self:NetworkVar( "Float", 1, "Growth" );
	self:NetworkVar( "Float", 2, "Water" );

	self:SetNWFloat("HP", 0)
	self:SetNWFloat("Growth", 0)
	self:SetNWFloat("Water", 0)

	self:SetNWBool("Sowed", false)
end

function ENT:Think()
	if (self:GetHarvest()) then return end

	if self:GetSowed() then
		if (self:GetGrowth() <= 100) then
			self:Growth()
			self:Watering()
			self:Healthy()

			self:SetNWFloat("HP", self:GetHP())
			self:SetNWFloat("Growth", self:GetGrowth())
			self:SetNWFloat("Water", self:GetWater())
		else
			if (!self:GetFruit()) then
				self:Fruit()
			else
				self:Harvest()
			end
		end
	end
end

function ENT:Sow(data)
	self.Data = data

	self:CreateInventory()

	self.crop:SetModel(self.Data.type["model"])

	self:SetSowed(true)
	self:SetFruit(false)
	self:SetHarvest(false)

	self:SetHP(100)
	self:SetGrowth(0)
	self:SetWater(100)

	self:SetNWBool("Sowed", true)

	self:EmitSound( "player/footsteps/dirt1.wav" )
end

function ENT:CreateInventory()
	local fruit_table = table.Copy(self.Data)
	local seeds_table = table.Copy(self.Data)

	fruit_table.seedbag = false
	seeds_table.seedbag = true

	self.Inventory = {}

	local random = math.Rand(0,100)

	if (table.HasValue(table.GetKeys(self.Data), "quality")) then

		if (random < self.Mutation) and (self.Data.quality) != 1 then
			fruit_table.quality = fruit_table.quality - 1
			seeds_table.quality = seeds_table.quality - 1
		end

		self.Inventory[fruit_table] = math.Round(math.Rand(1,FARMINGMOD.Config.Offspring*(self.Data.quality)))
		self.Inventory[seeds_table] = math.Round(math.Rand(0,FARMINGMOD.Config.Seeds*(self.Data.quality)))

	else

		if random < self.Mutation then
			fruit_table.quality = 3
			seeds_table.quality = 3
		end

		self.Inventory[fruit_table] = math.Round(math.Rand(1,FARMINGMOD.Config.Offspring))
		self.Inventory[seeds_table] = math.Round(math.Rand(0,FARMINGMOD.Config.Seeds))
	end

end

function ENT:ManageInventory(inventory, amount)
	for k, v in pairs(self.Inventory) do
		if inventory.name == k.name and inventory.seedbag == k.seedbag then
			self.Inventory[k] = self.Inventory[k] - amount

			if (self.Inventory[k] <= 0) then
				self.Inventory[k] = nil
			end

			if (table.Count(self.Inventory) == 0) then
				self:Reset()
			end

			net.Start("FARMINGMOD_HARVEST")
				net.WriteTable(self.Inventory)
				net.WriteEntity(self)
			net.Send(self.Player)
		end
	end
end

function ENT:Growth()
	self:SetGrowth(self:GetGrowth() + self.GrowthSpeed)

	if IsValid(self.crop) then
		self.crop:SetModelScale((self:GetGrowth() / self.Data.type["scale"]), 0 )
		self.crop:SetColor(Color(255,255,255,255))
	end
end

function ENT:Watering()

	if self:GetWater() >= 1 then
		self:SetWater(self:GetWater() - self.WaterSpeed)
	else
		self:SetHP(self:GetHP() - self.DamageSpeed)
	end

	if self:GetWater() < 100 and self:GetWater() > 75 then
		self:SetColor( Color(255, 210, 210, 255))
		self:SetRenderMode( RENDERMODE_TRANSALPHA )
	elseif self:GetWater() < 75 and self:GetWater() > 50 then
		self:SetColor( Color(255, 210, 210, 255))
		self:SetRenderMode( RENDERMODE_TRANSALPHA )
	elseif self:GetWater() < 50 and self:GetWater() > 25 then
		self:SetColor( Color(255, 230, 230, 255))
		self:SetRenderMode( RENDERMODE_TRANSALPHA )
	elseif self:GetWater() < 25 then
		self:SetColor( Color(255, 255, 255, 255))
		self:SetRenderMode( RENDERMODE_TRANSALPHA )
	end
end

function ENT:Healthy()
	if self:GetHP() < 0 then
		self:Reset()
	end
end

function ENT:IncreaseWater(water)
	if (self:GetWater() >= 100) then
		self:SetWater(99.9)
	end

	self:SetWater(self:GetWater() + water)
end

function ENT:Fruit()
	self.item = {}
	self.itemScale = 0

	local range = self.Data.type["range"]

	for i=1, self.Data.type["fruits"] do
		self.item[i] = ents.Create("prop_physics")
		self.item[i]:SetModel(self.Data.model)
		self.item[i]:SetPos(self:GetPos() +  Vector(math.random(-5,5),math.random(-5,5),math.random(range.min, range.max)))
		self.item[i]:SetAngles(Angle(0, math.random(0, 360), 0))
		self.item[i]:SetCollisionGroup( COLLISION_GROUP_WORLD )
		self.item[i]:Spawn()
		self.item[i]:Activate()
		self.item[i]:SetNotSolid(true)
		self.item[i]:SetParent(self)
		self.item[i]:SetModelScale(0, 0)
	end

	self:SetFruit(true)
end

function ENT:Harvest()
	if (self.itemScale < 50) then
		self.itemScale = self.itemScale + 1

		for k, v in pairs(self.item) do
			self.item[k]:SetModelScale(self.itemScale / 100, 0)
		end
	else
		self:SetHarvest(true)
	end
end

function ENT:Reset()
	self.Inventory = {}
	self.Data = {}

	self:SetHP(0)
	self:SetGrowth(0)
	self:SetWater(0)

	self:SetSowed(false)
	self:SetFruit(false)
	self:SetHarvest(false)

	self.crop:SetModelScale(0, 0)

	self:SetNWBool("Sowed", false)

	if (!self.item) then return end 

	for k, v in pairs(self.item) do
		if (IsValid(self.item[k])) then
			self.item[k]:Remove()
		end
	end
end

function ENT:Use(ply, entity)
	if (IsValid(self.Player) and IsValid(ply) and !self:GetSowed()) and (self.Player == ply) then
		net.Start("FARMINGMOD_PLANTOPTION")
			net.WriteEntity(self.Entity)
		net.Send(ply)
	elseif (IsValid(self.Player) and IsValid(ply) and self:GetHarvest()) and (self.Player == ply) then
		net.Start("FARMINGMOD_HARVEST")
			net.WriteTable(self.Inventory)
			net.WriteEntity(self)
		net.Send(ply)
	end
end

function ENT:OnRemove()
	if IsValid(self) and IsValid(self.Player) then
		FARMINGMOD:RemovePlot(self, self.Player)
	end
end
