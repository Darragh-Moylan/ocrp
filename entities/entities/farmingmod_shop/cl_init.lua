include('shared.lua')

surface.CreateFont( "farmingmod_font2d3d", {
	font = "Trebuchet18",
	size = 1000,
	weight = 600,
	antialias = true,
} )

function ENT:Initialize()
	local language = FARMINGMOD.Language[FARMINGMOD.Config.Language]

	self.title = language.npc.title
end

function ENT:Draw()

	self:DrawModel()

	if (!IsValid(self.chatbox)) then
		self.chatbox = ents.CreateClientProp("models/extras/info_speech.mdl")
		self.chatbox:SetPos(self:GetPos() + Vector(0,0,90))
		self.chatbox:SetAngles(self:GetAngles())
		self.chatbox:SetParent(self)
		self.chatbox:Spawn()
		self.chatbox:SetNoDraw(true)
	end

	if (IsValid(self.chatbox)) then

	local pos = self.chatbox:GetPos()
	local ang = self.chatbox:GetAngles()

	ang:RotateAroundAxis(ang:Right(), 	90)
	ang:RotateAroundAxis(ang:Up(), 		0)
	ang:RotateAroundAxis(ang:Forward(), 0)

		cam.Start3D2D(Vector(pos.x, pos.y + 2 * math.sin(CurTime()), pos.z), Angle(-90, ang.y + -180, 0) - Angle(90, -90, 90), 0.025)

			surface.SetFont( "farmingmod_font2d3d" )

			local textposx, textposy = surface.GetTextSize(self.title )

			draw.RoundedBox( 64,-textposx * 1.2 - (-textposx * 1.2) / 2, 550, textposx * 1.2, 25 * 8, Color(50,50,50,200))

			surface.SetTextColor( 255, 255, 255, 255 )
			surface.SetTextPos((textposx / 2) - textposx, 550 * 1.07)
			surface.DrawText(self.title)

		cam.End3D2D()

	end
end

function ENT:OnRemove()
	if (IsValid(self.chatbox))then
		self.chatbox:Remove()
	end
end
