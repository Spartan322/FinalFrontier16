include('shared.lua')

ENT.TargetModel = "models/Humans/Group01/Male_06.mdl"
ENT.Prisoner = true

function ENT:Initialize()
	self:SetSequence(self:LookupSequence("idle_angry"))
end

function ENT:Draw()
	if not JB.MainMenuEnabled then return end

	if self.TargetModel ~= self:GetModel() and self:IsValid() then
		self:SetModel(self.TargetModel)
	end
	local seq= self:LookupSequence("idle_angry")
	if self:GetSequence() ~= self:LookupSequence("idle_angry") then
		self:SetSequence(seq)
	end
	cam.IgnoreZ(false)
	
	self:DrawModel()
	
	if not self.Prisoner then return end
	cam.IgnoreZ(true)
		local BonePos , BoneAng = self:GetBonePosition(self:LookupBone("ValveBiped.Bip01_Head1"))
		local mul = 6.5
		if self:GetAngles() == Angle(0,-90,0) then
			mul = 5
		end
		local pos= BonePos+(BoneAng:Right()*mul)+Vector(0,0,3.7)
		render.SetMaterial(Material( "cs_italy/black" ))
		
		render.DrawQuadEasy( pos,self:GetAngles():Forward(),6,1.5,Color( 255, 255, 255, 255 ), 0) 
	cam.IgnoreZ(false)
end