
local Status = {}
local Mat1 = Material("Models/effects/splodearc_sheet")
local Mat2 = Material("models/alyx/emptool_glow")

if usermessage then
	local IncomingMessage = usermessage.IncomingMessage
	function usermessage.IncomingMessage(idx, msg)
		if idx != "TKTib" then IncomingMessage(idx, msg) return end
        
        local entid, stable = msg:ReadShort(), msg:ReadBool()
        Status[entid] = stable
	end
end

local function Stable(ent)
	local EntID = ent:EntIndex()
	if Status[EntID] == nil then return true end
	return Status[EntID]
end

function _R.Entity:DrawTib()
	if self.Offset > 0 then
		self.Offset = self.Offset - self.Speed * (SysTime() - self.time)
		self.time = SysTime()
		
		if self.Offset < 0 then 
			self.Offset = 0
			self:SetRenderOrigin(self.pos)
		else
			if util.IsValidModel(self.Ghost) then
				if self.Offset < self.Speed * 5 then
					self:SetRenderOrigin(self.pos - self:GetUp() * (self.Speed * 5 - self.Offset))
				else
					self:SetRenderOrigin(self.pos)
				end
				self:SetModel(self.Ghost)
				self:SetModelScale(1, 0)
				self:DrawModel()
				
				self:SetModelScale(1.1, 0)
				render.MaterialOverride(Mat1)
				self:DrawModel()
				render.MaterialOverride(nil)
				
				self:SetModel(self.LastModel)
			end
			
			self:SetRenderOrigin(self.pos - self:GetUp() * self.Offset)
		end
	else
		self.Offset = 0
		self:SetRenderOrigin(self.pos)
	end
	
	self:SetModelScale(1, 0)
	self:DrawModel()

	self:SetModelScale(1.1, 0)
	if Stable(self) then
		render.MaterialOverride(Mat1)
	else
		render.MaterialOverride(Mat2)
	end
	self:DrawModel()

	render.MaterialOverride(nil)
end

function _R.Entity:DrawExtractor()
	if self:GetActive() then
		if self.mining != self:GetCrystal() then
			self.mining = self:GetCrystal()
			local ent = Entity(self.mining)
			self:StopParticles()
			if self.mining == 0 || !IsValid(ent) then return end
			self.stable = Stable(ent)
			
			local CPoint0 = {
				["entity"] = ent,
				["attachtype"] = PATTACH_ABSORIGIN_FOLLOW,
			}
			local CPoint1 = {
				["entity"] = self,
				["attachtype"] = PATTACH_ABSORIGIN_FOLLOW,
			}
			
			self:CreateParticleEffect("medicgun_beam_blue_trail", {CPoint0, CPoint1})
			self:CreateParticleEffect("medicgun_beam_blue_trail", {CPoint0, CPoint1})
			self:CreateParticleEffect("medicgun_beam_attrib_overheal", {CPoint0, CPoint1})
			self:CreateParticleEffect("medicgun_beam_attrib_healing", {CPoint0, CPoint1})
			
			if !self.stable then
				self:CreateParticleEffect("medicgun_beam_red_invunglow", {CPoint0, CPoint1})
			end
		else
			local ent = Entity(self.mining)
			if self.mining == 0 || !IsValid(ent) then return end
			
			local CPoint0 = {
				["entity"] = ent,
				["attachtype"] = PATTACH_ABSORIGIN_FOLLOW,
			}
			local CPoint1 = {
				["entity"] = self,
				["attachtype"] = PATTACH_ABSORIGIN_FOLLOW,
			}
			
			if self.stable != Stable(ent) then
				self.stable = Stable(ent)
				if !self.stable then
					self:CreateParticleEffect("medicgun_beam_red_invunglow", {CPoint0, CPoint1})
				else
					self:StopParticles()
					self:CreateParticleEffect("medicgun_beam_blue_trail", {CPoint0, CPoint1})
					self:CreateParticleEffect("medicgun_beam_blue_trail", {CPoint0, CPoint1})
					self:CreateParticleEffect("medicgun_beam_attrib_overheal", {CPoint0, CPoint1})
					self:CreateParticleEffect("medicgun_beam_attrib_healing", {CPoint0, CPoint1})
				end
			end
		end
	else
		if self.mining != 0 then
			self.mining = 0
			self:StopParticles()
		end
	end
end