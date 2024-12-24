--[=[ 
	@class queryUtil

	A utility for basic query operations.
]=]

--[=[ 
	@type Connection RBXScriptConnection | {Connected: boolean, Disconnect: (self: Connection) -> ()}
	@within queryUtil
]=]

--[=[ 
	@type EventLike<T> {Connect: ((T) -> ()) -> Connection, connect: ((T) -> ()) -> Connection}
	@within queryUtil
]=]

local Property = require(script.Parent.Property)
local Trove = require(script.Parent.Trove)

local queryUtil = {}

type Connection = RBXScriptConnection | {
	Connected: boolean,
	Disconnect: (self: Connection) -> (),
}
type EventLike<T> = {
	Connect: (((T) -> ()) -> Connection)?,
	connect: (((T) -> ()) -> Connection)?,
}

local function elementIsLikeEvent(element)
	if typeof(element) == "RBXScriptSignal" then
		return true
	elseif typeof(element) == "table" then
		return typeof(element.Connect) == "function" or typeof(element.connect) == "function"
	end

	return false
end

local function connectToEvent(event, callback)
	if typeof(event.Connect) == "function" then
		return event:Connect(callback)
	elseif typeof(event.connect) == "function" then
		return event:connect(callback)
	end

	return nil
end

--[=[ 
	Returns a property object and a trove. The property object is initially updated with 
	`queryResults`, and then updated based off of `queryAddition` and `queryRemoving` events
	firing off.

	```lua
	local Workspace = game:GetService("Workspace")

	local queryResultsProperty, cleanup = queryUtil.query(
		Workspace:GetDescendants(), 
		Workspace.DescendantAdded, 
		Workspace.DescendantRemoving
	)

	queryResultsProperty:observe(function(newQueryResults, oldQueryResults)
		print(newQueryResults) --> {...} (Array of all Workspace descendants)
	end)
	```

	@return Property<T>, Trove
]=]

function queryUtil.query<T>(
	queryResults: T,
	queryAddition: EventLike<T>,
	queryRemoving: EventLike<T>
): (Property.Property, Trove.Trove)
	assert(elementIsLikeEvent(queryAddition), "Argument #2 'queryAddition' must be like an event!")
	assert(elementIsLikeEvent(queryRemoving), "Argument #3 'queryRemoving' must be like an event!")

	local trove = Trove.new()
	local queryResultsProperty = trove:Add(Property.new(table.clone(queryResults :: any)))

	trove:Add(connectToEvent(queryAddition, function(resultAddition)
		local queryResultsNow = queryResultsProperty:get()
		table.insert(queryResultsNow, resultAddition)
		queryResultsProperty:set(queryResultsNow)
	end))

	trove:Add(connectToEvent(queryRemoving, function(resultRemoving)
		local queryResultsNow = queryResultsProperty:get()
		local index = table.find(queryResultsNow, resultRemoving)
		if index ~= nil then
			table.remove(queryResultsNow, index)
		end

		queryResultsProperty:set(queryResultsNow)
	end))

	return queryResultsProperty, trove
end

return table.freeze(queryUtil)
