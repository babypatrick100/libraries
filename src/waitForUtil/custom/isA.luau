--[=[
	@within custom
	
	A custom callback for [FindFirstChildWhichIsA](https://create.roblox.com/docs/reference/engine/classes/Instance#FindFirstChildWhichIsA).

	```lua
	waitForUtil.custom.class(Workspace, "BasePart"):andThen(function(basePart: BasePart)
		print(basePart:IsA("BasePart")) --> true
	end)
	```
]=]

local function isA(instance: Instance, isA: string)
	return instance:FindFirstChildWhichIsA(isA)
end

return isA
