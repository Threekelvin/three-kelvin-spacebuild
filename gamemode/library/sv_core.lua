
local BadConstraints = {
    ["phys_keepupright"] = true,
    ["logic_collision_pair"] = true
}

function _R.Entity:GetConstrainedEntities()
    local out = {[self] = self}
    if !self.Constraints then return out end
    
    local tbtab = {{self,1}}
    while #tbtab > 0 do
        local bd = tbtab[#tbtab]
        local bde = bd[1]
        local bdc = bde.Constraints[bd[2]]
        local ce
        
        if bdc then
            if bde == bdc.Ent1 then
                ce = bdc.Ent2
            else
                ce = bdc.Ent1
            end
        end
        
        if bd[2] > #bde.Constraints then
            tbtab[#tbtab] = nil
        elseif !IsValid(bdc) or !IsValid(ce) or BadConstraints[bdc:GetClass()] then
            bd[2] = bd[2] + 1
        else
            if !out[ce] then
                tbtab[#tbtab+1] = {ce,1}
            else
                bd[2] = bd[2] + 1
            end
            
            out[bde] = bde
            out[ce] = ce
        end
    end
    
    return out
end