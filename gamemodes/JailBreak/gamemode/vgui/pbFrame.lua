local PNL = {}
local TId = surface.GetTextureID("prisonbreak/background_texture") --Texture ID

function PNL:Init()
	self.Title = "Unnamed"
	self.PaintHook = function() end
end
function PNL:Paint()
	local X = 1
	local Y = 2
	local Oset

	if(self:GetWide()>self:GetTall())or(self:GetWide()==self:GetTall())then
		Oset = X
	elseif(self:GetTall()>self:GetWide())then
		Oset = Y
	else
		return
	end
	if(Oset==Y)then
		local t=math.ceil(self:GetTall()/self:GetWide())--Tiles
		for i=1,t do
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetTexture(TId)
			surface.DrawTexturedRect(0,-self:GetWide()+(i*self:GetWide()),self:GetWide(),self:GetWide())
		end
	elseif(Oset==X)then
		local t=math.ceil(self:GetWide()/self:GetTall())--Tiles
		for i=1,t do
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetTexture(TId)
			surface.DrawTexturedRect(-self:GetTall()+(self:GetTall()*i),0,self:GetTall(),self:GetTall())
		end
	end

	surface.SetDrawColor(0,0,0,255)
	surface.DrawRect(0,0,self:GetWide(),2)
	surface.DrawRect(5,5,self:GetWide()-10,45)
	surface.DrawRect(0,0,2,self:GetTall())
	surface.DrawRect(self:GetWide()-2,0,2,self:GetTall())
	surface.DrawRect(2,self:GetTall()-2,self:GetWide()-4,2)

	draw.SimpleText(self.Title,"pbTitleFont",15,29,Color(255,255,255,255),0,1)

	self.PaintHook()
end
vgui.Register( "pbFrame", PNL, "Panel" )