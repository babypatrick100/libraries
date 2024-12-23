--[=[ 
	@class orderUtil

	A very simple utility module for working with order of numbers. 
]=]

local orderUtil = {}

--[=[
	Returns a function which returns a numerical value, which is always incremented by 1.

	```lua
	local nextOrder = orderUtil.nextOrder() 
	print(nextOrder()) --> 1
	print(nextOrder()) --> 2
	print(nextOrder()) --> 3
	```
]=]

function orderUtil.nextOrder(): () -> number
	local order = 0

	return function()
		order += 1
		return order
	end
end

return table.freeze(orderUtil)
