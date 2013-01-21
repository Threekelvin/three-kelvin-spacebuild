
///--- Particles ---\\\
usermessage.Hook("particlebeam", function(msg)
	local particle = msg:ReadString()
	local this = Entity(msg:ReadShort())
	local ent = Entity(msg:ReadShort())
	if !ValidEntity(this) || !ValidEntity(ent) then return end
	
	local CP1 = {
		["entity"] = this,
		["attachtype"] = PATTACH_ABSORIGIN_FOLLOW,
	}
	local CP2 = {
		["entity"] = ent,
		["attachtype"] = PATTACH_ABSORIGIN_FOLLOW,
	}
	
	this:CreateParticleEffect(particle, {CP1, CP2})
end)