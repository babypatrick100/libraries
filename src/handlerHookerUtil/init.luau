--[=[
	@class handlerHookerUtil

	A simple utility module for working with handlers.
]=]

local Promise = require(script.Parent.Promise)

local handlerHookerUtil = {}

--[=[
	Returns a promise which is resolved with all the values returned by `handler`, when it is called 
	(the `callbackMember` in it), being passed `...` as the arguments.

	```lua
	handlerHookerUtil.promiseRunHandler(badgeHandler, "run")
	```

	@return Promise<...: any>
]=]

function handlerHookerUtil.promiseRunHandler(
	handler: { [string]: any },
	callbackMember: string,
	...: any
)
	local args = { ... }

	return Promise.new(function(resolve)
		resolve(handler[callbackMember](table.unpack(args)))
	end)
end

return table.freeze(handlerHookerUtil)
