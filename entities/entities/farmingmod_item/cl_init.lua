include("shared.lua")

surface.CreateFont( "farmingmod_font2d3d", {
	font = "Arial",
	size = 100,
	weight = 400,
	antialias = true,
} )


function ENT:Draw()

	self:DrawModel()

	if self:GetFood() then return end

	local ply = LocalPlayer()

	local pos = self:GetPos()
	local ang = self:GetAngles()

	local min = select(1, self:GetCollisionBounds())
	local max = select(2, self:GetCollisionBounds())

	local len_height = math.sqrt(min.z^2 + max.z^2)

	if (ply:GetPos():Distance(pos) < 150 and self:GetAmount() != 0) then
		cam.Start3D2D(pos, Angle(-90, LocalPlayer():GetAngles().y, 0) - Angle(90, -90, 90), 0.025)

			surface.SetFont( "farmingmod_font2d3d" )

			local textposx, textposy = surface.GetTextSize(self:GetEntityName() .. "(" .. self:GetAmount() .. ")")

			surface.SetDrawColor( 0, 0, 0, 230 )

			draw.RoundedBox( 64, -textposx * 1.5 - (-textposx * 1.5) / 2, len_height * -54, textposx * 1.5, 25 * 5, Color(255,255,255,200))

			surface.SetTextColor( 50, 50, 50, 255 )
			surface.SetTextPos((textposx / 2) - textposx, len_height * -50 * 1.07)
			surface.DrawText(self:GetEntityName() .. "(" .. self:GetAmount() .. ")")

		cam.End3D2D()
	end
end
