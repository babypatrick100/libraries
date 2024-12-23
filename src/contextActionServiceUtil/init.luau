--[=[ 
	@class contextActionServiceUtil
	
	A simple utility module for working with [ContextActionService](https://create.roblox.com/docs/reference/engine/classes/ContextActionService).
]=]

local ContextActionService = game:GetService("ContextActionService")

local contextActionServiceUtil = {}

--[=[
	Works almost exactly the same as [ContextActionService:BindAction](https://create.roblox.com/docs/reference/engine/classes/ContextActionService#BindAction),
	except that a custom handler is passed as the 2nd argument, which then calls `actionCallback`but returns `Enum.ContextActionResult.Pass` so 
	the handler never sinks any inputs.

	You can think of the custom handler like this:

	```lua
	function(...)
		actionCallback(...)
		return Enum.ContextActionResult.Pass
	end
	```

	```lua
	contextActionServiceUtil.bindActionNoInputSink(
		"Input", 
		function(_, inputState: Enum.UserInputState, inputObject: InputObject)
			print("User pressed Enum.Keycode.A")
		end, 
		false, Enum.Keycode.A
	)
	```
]=]

function contextActionServiceUtil.bindActionNoInputSink(
	actionName: string,
	actionCallback: (
		actionName: string,
		inputState: Enum.UserInputState,
		inputObject: InputObject
	) -> (),
	createTouchButton: boolean,
	...: Enum.UserInputType | Enum.KeyCode
)
	ContextActionService:BindAction(actionName, function(...)
		actionCallback(...)
		return Enum.ContextActionResult.Pass
	end, createTouchButton, ...)
end

return table.freeze(contextActionServiceUtil)
