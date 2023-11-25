--[=[
	@within custom
	
	A custom callback for [FindFirstChildOfClass](https://create.roblox.com/docs/reference/engine/classes/Instance#FindFirstChildOfClass).

	```lua
	waitForUtil.custom.class(Workspace, "TextLabel"):andThen(function(textLabel: TextLabel)
		print(basePart.ClassName == "TextLabel") --> true
	end)
	```
]=]

local function class(instance: Instance, className: string)
	return instance:FindFirstChildOfClass(className)
end

return class
