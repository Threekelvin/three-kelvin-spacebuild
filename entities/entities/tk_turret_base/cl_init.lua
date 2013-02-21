include('shared.lua')

function ENT:Draw(bDontDrawModel)
    if bDontDrawModel then return end
    self:DrawModel()
end