--[=[
	@class Connection

	A simple class for mimicking [RBXConnection](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptConnection) objects.
]=]

--[=[
	@prop Connected boolean
	@within Connection
	@tag Connection Instance
]=]

--[=[
	@type Connection Connection
	@within Connection
]=]

local Connection = {}
Connection.__index = Connection

--[=[
	Creates and returns a new connection object.

	@return Connection
]=]

function Connection.new(cleanupCallback: () -> ())
	local self = setmetatable({
		Connected = false,
		_cleanupCallback = cleanupCallback,
	}, Connection)
	return self
end

--[=[
	Disconnects the connection *and renders it unusuable*.
]=]

function Connection.__index:disconnect()
	self:_internalDisconnect()
end

--[=[
	Alias for [Connection:disconnect].
]=]

function Connection.__index:destroy()
	self:disconnect()
end

function Connection.__index:_internalDisconnect()
	self._cleanupCallback()
	self.Connected = false
end

export type Connection = typeof(Connection.new(function() end))

return table.freeze(Connection)
