include("shared.lua")

local W = ScrW()
local H = ScrH()

function ENT:Initialize()
	self.Time = SysTime()
end

function ENT:Draw()
	self:DrawModel()

	if !self:GetNWBool("Sowed") then return end

	self:Draw3D2D()
	self:Movement()
end

function ENT:Movement()
	self.crop = self:GetNWEntity("crop")

	if (IsValid(self.crop)) then
		for i = 0, self.crop:GetBoneCount() do

			if self.crop:GetBoneName(i) == "root" then return end

			if (self:GetNWAngle("Bone" .. i)) then
				self.startAngle = self:GetNWAngle("Bone" .. i)

				local movement = self.startAngle + Angle(0,math.sin(CurTime() - self.Time + i) * i * 3, 0)

				self.crop:ManipulateBoneAngles( i, movement)
			end
		end
	end
end

function ENT:Draw3D2D()

	-- Defining stuff
	local pos = self:GetPos()
	local ang = self:GetAngles()

	ang:RotateAroundAxis(ang:Right(), 	90)
	ang:RotateAroundAxis(ang:Up(), 		0)
	ang:RotateAroundAxis(ang:Forward(), 0)

	local info_health = Material( "gui/gardening/info_health")
	local info_water = Material( "gui/gardening/info_water")
	local info_status = Material( "gui/gardening/info_status")

	local health = self:GetNWFloat("HP")
	local growth = self:GetNWFloat("Growth")
	local water = self:GetNWFloat("Water")

	-- Draws a triangle
	local triangle = {
	{ x = -128 * 1.5 + 105, y = -155 },
	{ x = -128 * 1.5 + 115, y = -140 },
	{ x = -128 * 1.5 + 105, y = -125 }}

	local ply = LocalPlayer()

	-- 3D2D screen
	if (ply:GetPos():Distance(self:GetPos()) < 150) then
		cam.Start3D2D(Vector(pos.x, pos.y + 2 * math.sin(CurTime()), pos.z + 5), Angle(-90, LocalPlayer():GetAngles().y, 90) - Angle(90, -90, 180), 0.15)

		-- Rounded box
		draw.RoundedBox( 16, -128 * 1.5, -165, 100, 60, FARMINGMOD.Config.Screen2D3DColor)

		-- Triangle
		surface.SetDrawColor( FARMINGMOD.Config.Screen2D3DColor )
		draw.NoTexture()
		surface.DrawPoly( triangle )

		-- Icons
		surface.SetDrawColor( 255, 255, 255, 200 )
		surface.SetMaterial( info_health )
		surface.DrawTexturedRect(-124 * 1.5, -175 + 20, 16, 16)

		surface.SetDrawColor( 255, 255, 255, 200 )
		surface.SetMaterial( info_water )
		surface.DrawTexturedRect(-124 * 1.5 + 32, -175 + 20, 16, 16)

		surface.SetDrawColor( 255, 255, 255, 200 )
		surface.SetMaterial( info_status )
		surface.DrawTexturedRect(-124 * 1.5 + 64, -175 + 20, 16, 16)

		-- Health Bar
		surface.SetDrawColor( 105, 165, 91, 255 )
		surface.DrawRect(-124 * 1.5, -175 + 38, 16, 18)

		surface.SetDrawColor( 200, 100, 100, 255 ) 
		surface.DrawRect(-124 * 1.5, -175 + 38, 16, -(18 / 100) * health + 18)

		surface.SetDrawColor( 40, 45, 46, 50 )
		surface.DrawOutlinedRect(-124 * 1.5, -175 + 38, 16, 18)

		-- Water Bar
		surface.SetDrawColor( 105, 165, 91, 255 )
		surface.DrawRect(-124 * 1.5 + 32, -175 + 38, 16, 18)

		surface.SetDrawColor( 200, 100, 100, 255 )
		surface.DrawRect(-124 * 1.5 + 32, -175 + 38, 16, -(18 / 100) * water + 18)

		surface.SetDrawColor( 40, 45, 46, 50 )
		surface.DrawOutlinedRect(-124 * 1.5 + 32, -175 + 38, 16, 18)

		-- Growth Bar
		surface.SetDrawColor( 105, 165, 91, 255 )
		surface.DrawRect(-124 * 1.5 + 64, -175 + 38, 16, 18)

		surface.SetDrawColor( 200, 100, 100, 255 )
		surface.DrawRect(-124 * 1.5 + 64, -175 + 38, 16, -(18 / 100) * growth + 18)

		surface.SetDrawColor( 40, 45, 46, 50 )
		surface.DrawOutlinedRect(-124 * 1.5 + 64, -175 + 38, 16, 18)

		cam.End3D2D()
	end

end