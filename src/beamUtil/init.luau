--[=[ 
	@class beamUtil
	
	A simple utility for working with beams.
]=]

local beamUtil = {}

-- https://devforum.roblox.com/t/how-is-this-follow-the-arrows-system-made/297875/2
local function pathToPart(beam: Beam, a0: Attachment, part: BasePart)
	local attachment1 = part:FindFirstChildOfClass("Attachment") or Instance.new("Attachment")
	attachment1.Parent = part

	beam.Attachment0 = a0
	beam.Attachment1 = attachment1
end

--[=[
	Attaches the given beam.
]=]

function beamUtil.attachBeam(beam: Beam, a0: Attachment, part: BasePart, beamParent: Instance)
	beam.Parent = beamParent
	pathToPart(beam, a0, part)
end

return table.freeze(beamUtil)
