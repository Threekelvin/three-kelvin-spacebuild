include('shared.lua')

function ENT:Initialize()
    self.mining = 0
    self.stable = true
end

function ENT:Draw()
    self.BaseClass.Draw(self)
    self:DrawExtractor()
end