include('shared.lua')

function ENT:Draw()
    self.BaseClass.Draw(self)
    TK.TI:DrawExtractor(self)
end