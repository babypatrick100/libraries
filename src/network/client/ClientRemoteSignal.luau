--[=[
	@class ClientRemoteSignal

	The clientside counterpart of [RemoteSignal]. A client remote signal in 
	layman's terms is just an object connected to a serverside remote signal.
]=]

--[=[ 
	@type ClientRemoteSignal ClientRemoteSignal
	@within ClientRemoteSignal
]=]

local packages = script.Parent.Parent.Parent
local utilities = script.Parent.Parent.utilities
local networkFolder = script.Parent.Parent

local sharedTypes = require(networkFolder.sharedTypes)
local Janitor = require(packages.Janitor)
local networkUtil = require(utilities.networkUtil)

local ClientRemoteSignal = { __index = {} }

--[=[
	@private
]=]

function ClientRemoteSignal.new(remoteEvent: RemoteEvent): ClientRemoteSignal
	local self = setmetatable({
		_remoteEvent = remoteEvent,
		_janitor = Janitor.new(),
	}, ClientRemoteSignal)

	self:_init()
	return self
end

--[=[
	Returns a boolean indicating if `self` is a client remote signal or not.
]=]

function ClientRemoteSignal.is(self: any): boolean
	return getmetatable(self) == ClientRemoteSignal
end

--[=[
	@tag ClientRemoteSignal instance

	Connects `callback` to the client remote signal so that it is called whenever 
	the serverside remote signal (to which the client remote signal is connected to) 
	dispatches some data to the client. Additionally, `callback` will be passed all the arguments 
	sent by the server.
]=]

function ClientRemoteSignal.__index:connect(callback: (...any) -> ()): RBXScriptConnection
	local connection
	connection = self._janitor:Add(self._remoteEvent.OnClientEvent:Connect(function(args)
		-- Need to check for connection variable as it is possible it is nil - since
		-- connected remote event callbacks are flushed.
		if connection and not connection.Connected then
			return
		end

		callback(networkUtil.deserializeAndUnpack(self._remoteEvent, args))
	end))

	return connection
end

--[=[
	@tag ClientRemoteSignal instance

	Works almost exactly the same as [ClientRemoteSignal:connect], except the 
	connection returned is  disconnected immediately upon `callback` being called.
]=]

function ClientRemoteSignal.__index:once(callback: (...any) -> ()): RBXScriptConnection
	return self._janitor:Add(self._remoteEvent.OnClientEvent:Once(function(args)
		callback(networkUtil.deserializeAndUnpack(self._remoteEvent, args))
	end))
end

--[=[
	@tag ClientRemoteSignal instance

	Fires `...` arguments to the serverside remote signal (to which the client
	remote signal is connected to).
]=]

function ClientRemoteSignal.__index:fireServer(...: any)
	self._remoteEvent:FireServer(networkUtil.serializeGivenArgs(self._remoteEvent, ...))
end

--[=[
	@tag ClientRemoteSignal instance
	@tag yields

	Yields the current thread until the serverside remote signal (to which the client 
	remote signal is connected to) dispatches some data to the client. The yielded thread 
	is resumed once the server fires some data to the client, with the arguments sent by the 
	server.

	```lua
	-- Server
	remoteSignal:fireAllClients("Hi")

	-- Client
	print(clientRemoteSignal:wait()) --> "Hi"
	```
]=]

function ClientRemoteSignal.__index:wait(): ...any
	return self._remoteEvent.OnClientEvent:Wait()
end

--[=[
	@tag ClientRemoteSignal instance
	
	Destroys the client remote signal and renders it unusable.
]=]

function ClientRemoteSignal.__index:destroy()
	self._janitor:Destroy()
end

--[=[
	@private
]=]

function ClientRemoteSignal.__index:_init()
	self._janitor:Add(function()
		setmetatable(self, nil)
	end)
end

--[=[
	@private
]=]

function ClientRemoteSignal:__tostring()
	return string.format(
		"[%s]: (%s)",
		if self._remoteEvent:IsA("UnreliableRemoteEvent")
			then "ClientRemoteSignal [UNRELIABLE]"
			else "ClientRemoteSignal",
		self._remoteEvent.Name
	)
end

export type ClientRemoteSignal = typeof(setmetatable(
	{} :: {
		_remoteEvent: RemoteEvent | UnreliableRemoteEvent,
		_janitor: sharedTypes.Janitor,
	},
	ClientRemoteSignal
))

return table.freeze(ClientRemoteSignal)
