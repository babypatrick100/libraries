--[=[
	@class toolUtil

	A simple utility module for working with tools.
]=]

local playerUtil = require(script.Parent.playerUtil)

local toolUtil = {}

--[=[
	Returns the owner instance of the given tool, if found.
]=]

function toolUtil.toolOwnerInstance(tool: Tool): Player?
	local playerFromTool = playerUtil.playerFromInstance(tool)
	local toolParent = tool.Parent

	if playerFromTool then
		return playerFromTool
	end

	if toolParent then
		if toolParent:IsA("Backpack") then
			return toolParent.Parent
		end
	end

	return nil
end

return table.freeze(toolUtil)
