
function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local Particle = ParticleEmitter(pos)
	for i = 1,6 do
		local effect = Particle:Add("effects/spark",pos)
		if effect then
           effect:SetColor( 150, 150, 255, 230 )            
		   effect:SetVelocity( Vector(VectorRand().x * 3, VectorRand().y * 3, -2) * 10 )
		   effect:SetDieTime(1)            
		   effect:SetLifeTime(0)            
		   effect:SetStartSize(2)    
		   effect:SetEndSize(0)
		   effect:SetBounce(1)
		   effect:SetCollide(true)
		   effect:SetGravity(Vector(0,0,0))
		end
	end
	Particle:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
