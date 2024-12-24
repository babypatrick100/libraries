--[=[
	@within numberUtil
	
	Returns a function which returns a numerical value, which is always incremented by 1.

	```lua
	local nextOrder = numberUtil.nextOrder() 
	print(nextOrder()) --> 1
	print(nextOrder()) --> 2
	print(nextOrder()) --> 3
	```
]=]

local function nextOrder(): () -> number
	local order = 0

	return function()
		order += 1
		return order
	end
end

return nextOrder
