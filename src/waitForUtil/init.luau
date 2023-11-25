--[=[ 
	@class waitForUtil

	An utility module for [WaitFor](https://sleitnick.github.io/RbxUtil/api/WaitFor/).
 
	```lua
	waitForUtil.custom.class(Workspace, "TextLabel"):andThen(function(textLabel: TextLabel)
		...
	end)
	```
]=]

--[=[ 
	@class custom

	A read only table consisting of utility methods for [WaitFor.Custom](https://sleitnick.github.io/RbxUtil/api/WaitFor/#Custom).
]=]

local Loader = require(script.Parent.Loader)

local waitForUtil = {}

waitForUtil.custom = {}

for customName, customCallback in Loader.LoadChildren(script.custom) do
	waitForUtil.custom[customName] = function(...)
		local args = { ... }

		return function()
			return customCallback(unpack(args))
		end
	end
end

table.freeze(waitForUtil.custom)

return table.freeze(waitForUtil)
