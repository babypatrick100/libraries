--[=[
	@class rbxScriptSignalUtil

	An utility module for working with RBXScriptSignals.
]=]

local rbxScriptSignalUtil = {}

--[=[ 
	Initializes events. Returns a cleanup function which upon being called, will cleanup all the events.

	```lua
	rbxScriptSignalUtil.initEvents({
		[workspace.ChildAdded] = function(child)
			print(child.Name, "added to Workspace!")
		end
	})
	```
]=]

function rbxScriptSignalUtil.initEvents(events: { [RBXScriptSignal]: (...any) -> () })
	local connections = {}

	for rbxScriptSignal, callback in events do
		local connection
		connection = rbxScriptSignal:Connect(function(...)
			-- In deferred signal behavior, connections queue up for resumption,
			-- so it is possible that some connection is queued up but is disconnected!
			if not connection.Connected then
				return
			end

			callback(...)
		end)

		table.insert(connections, connection)
	end

	return function()
		for _, connection in connections do
			connection:Disconnect()
		end

		connections = {}
	end
end

return table.freeze(rbxScriptSignalUtil)
