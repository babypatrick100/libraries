--[=[
	@class ClientRemoteSignal
	@client

	The clientside counterpart of [RemoteSignal]. A client remote signal in layman's terms is just an object
	connected to a remote signal.
]=]

--[=[ 
	@type ClientRemoteSignal ClientRemoteSignal
	@within ClientRemoteSignal
]=]

local Trove = require(script.Parent.Parent.Parent.Trove)
local networkUtil = require(script.Parent.Parent.utilities.networkUtil)

local ClientRemoteSignal = { __index = {} }

function ClientRemoteSignal.new(remote)
	local self = setmetatable({
		_remote = remote,
		_trove = Trove.new(),
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
	the remote signal dispatches some data to the client. Additionally, `callback` will be passed all the arguments 
	sent by the server.
]=]

function ClientRemoteSignal.__index:connect(callback: (...any) -> ()): RBXScriptConnection
	local connection
	connection = self._trove:Add(self._remote.OnClientEvent:Connect(function(args)
		if connection ~= nil and not connection.Connected then
			return
		end

		callback(networkUtil.deserializeAndUnpackArgs(self._remote, args))
	end))

	return connection
end

--[=[
	@tag ClientRemoteSignal instance

	Works almost exactly the same as [ClientRemoteSignal:connect], except the 
	connection returned is  disconnected immediately upon `callback` being called.
]=]

function ClientRemoteSignal.__index:once(callback: (...any) -> ()): RBXScriptConnection
	return self._trove:Add(self._remote.OnClientEvent:Once(function(args)
		callback(networkUtil.deserializeAndUnpackArgs(self._remote, args))
	end))
end

--[=[
	@tag ClientRemoteSignal instance

	Fires `...` arguments to the remote signal.
]=]

function ClientRemoteSignal.__index:fireServer(...: any)
	self._remote:FireServer(networkUtil.serializeGivenArgs(self._remote, ...))
end

--[=[
	@tag ClientRemoteSignal instance
	@tag yields

	Yields the current thread until the remote signal dispatches some data to the client.
	The yielded thread is resumed once the server fires some data to the client,  with the
	arguments sent by the server.

	```lua
	-- Server
	remoteSignal:fireAllClients("Hi")

	-- Client
	print(clientRemoteSignal:wait()) --> "Hi"
	```
]=]

function ClientRemoteSignal.__index:wait(): ...any
	return self._remote.OnClientEvent:Wait()
end

--[=[
	@tag ClientRemoteSignal instance
	
	Destroys the client remote signal and renders it unusable.
]=]

function ClientRemoteSignal.__index:destroy()
	self._trove:Destroy()
end

function ClientRemoteSignal.__index:_init()
	self._trove:Add(function()
		setmetatable(self, nil)
	end)
end

function ClientRemoteSignal:__tostring()
	return string.format(
		"[%s]: (%s)",
		if self._remote:IsA("UnreliableRemoteEvent")
			then "ClientRemoteSignal [Unreliable]"
			else "ClientRemoteSignal",
		self._remote.Name
	)
end

export type ClientRemoteSignal = typeof(ClientRemoteSignal.new())

return table.freeze(ClientRemoteSignal)
