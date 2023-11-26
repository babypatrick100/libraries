--[=[
	@class RemoteSignal

	A remote signal in layman's terms is simply an object which dispatches data
	to a client (who can listen to this data through a client remote signal) and 
	listens to data dispatched to itself by a client (through a client remote signal).
]=]

--[=[ 
	@interface DefaultRemoteSignalConfig 
	@within RemoteProperty
	.automaticArgumentSerializationAndDeserializationEnabled true
	.globalRateLimit 0
	.useUnreliableRemoteEvent false
]=]

--[=[
	@interface DefaultRemoteSignalMiddleware
	@within RemoteSignal
	.serverEvent {}
]=]

--[=[ 
	@type RemoteSignal RemoteSignal
	@within RemoteSignal
]=]

--[=[ 
	@type RemoteSignalConnectCallback (client: Player, ...any) -> ()
	@within RemoteSignal
]=]

--[=[ 
	@interface RemoteSignalConfig
	@within RemoteSignal
	.useUnreliableRemoteEvent boolean -- determines whether or not the remote signal will use `UnreliableRemoteEvent` or `RemoteEvent` internally.
	.automaticArgumentSerializationAndDeserializationEnabled boolean -- determines whether or not values sent to clients by the remote signal be internally serialized/deserialized or not.
	.globalRateLimit number -- (in seconds) will serve as the global rate limit for all players firing to this RemoteSignal.

	- `automaticArgumentSerializationAndDeserializationEnabled` -> `true`
		- Arguments and values sent across the network by the remote signal 
		will be automatically serialized and deserialized respectively, with the
		help of an internal library, i.e [serializerUtil](https://bub.github.io/libraries/api/serializerUtil/).

		:::note Serialization and deserialization limitations
		While the serializer utility used to accomplish this supports a variety of data types, do keep in mind that not all data types
		can be supported on the go for serialization and deserialization - check the above hyperlink to the serializer utility on how
		many data types it supports.
		::::

		**See the type of the value sent to the client by the remote signal, being `TweenInfo` on the client**:

		```lua
		-- Server
		local Workspace = game:GetService("Workspace")
		local Players = game:GetService("Players")

		local testNetwork = network.Server.new("TestNetwork")
		local remoteSignal = network.Server.RemoteSignal.new()
		testNetwork:append("remoteSignal",  remoteSignal) 
		testNetwork:dispatch(Workspace)

		remoteSignal:fireClient(Players:GetPlayers()[1] or Players.PlayerAdded:Wait())

		-- Client
		local Workspace = game:GetService("Workspace")

		local testNetwork = network.client.fromParent("TestNetwork", Workspace):expect()
		testNetwork.remoteSignal:connect(function(value)
			print(typeof(value)) --> "TweenInfo"
		end)
		```
	- `automaticArgumentSerializationAndDeserializationEnabled` -> `false`
		- Arguments and values sent across the network by the remote signal will not be internally serialized
		and deserialized. Using the same example as above:
		
		**See the type of the value sent to the client by the remote signal, being `TweenInfo` on the client**:

		```lua
		-- Server
		local Workspace = game:GetService("Workspace")
		local Players = game:GetService("Players")

		local testNetwork = network.Server.new("TestNetwork")
		local remoteSignal = network.Server.RemoteSignal.new()
		testNetwork:append("remoteSignal",  remoteSignal) 
		testNetwork:dispatch(Workspace)

		remoteSignal:fireClient(Players:GetPlayers()[1] or Players.PlayerAdded:Wait())

		-- Client
		local Workspace = game:GetService("Workspace")

		local testNetwork = network.client.fromParent("TestNetwork", Workspace):expect()
		testNetwork.remoteSignal:connect(function(value)
			print(typeof(value)) --> "table"
		end)
		```
]=]

--[=[
	@interface RemoteSignalMiddleware
	@within RemoteSignal
	.serverEvent { (client: Player, args: {any}) -> any }?,

	`serverEvent` must be array of callbacks, if specified.

	:::warning Yielding in middleware callbacks is not allowed
	Middleware callbacks aren't allowed to yield. If they do so, their thread will be closed via
	[coroutine.close](https://create.roblox.com/docs/reference/engine/libraries/coroutine#close) and an
	error will be outputted in the console.

	Yielding, (especially in network-related code) results in weird bugs and behavior which can be hard to track down!
	:::

	### `serverEvent` 

	Callbacks in `serverEvent` are called whenever the client fires off the remote signal.

	The first argument passed to each callback is a reference to the remote signal itself,
	which is followed by the client itself, which is followed by an array of arguments fired 
	by the client. 

	```lua
	local serverEventCallbacks = {
		function (remoteSignal, client: Player, arguments)
			print(RemoteSignal.is(remoteSignal)) --> true
			print(client:IsA("Player")) --> true 
			print(typeof(arguments)) --> "table"
		end
	}
	---
	```

	:::tip More control
	- If any of the callbacks return an **explicit** false value, then the remote signal
	will not be fired. For e.g:

	```lua
	-- Server
	local Workspace = game:GetService("Workspace")

	local testNetwork = network.Server.new("TestNetwork")
	local testRemoteSignal = network.Server.RemoteSignal.new({
		serverEvent = {function() return false end}
	})

	testRemoteSignal:connect(function()
		print("Fired") --> never prints
	end)

	testNetwork:append("signal", testRemoteSignal)
	testNetwork:dispatch(Workspace)

	-- Client
	local Workspace = game:GetService("Workspace")
	
	local testNetwork = network.client.fromParent("TestNetwork", Workspace)
	print(testNetwork.signal:fireServer()) 
	```

	- Additionally, you can modify the `arguments` table before it is passed to the connected callback, for e.g:

	```lua
	-- Server
	local Workspace = game:GetService("Workspace")

	local testNetwork = network.Server.new("TestNetwork")
	local testRemoteSignal = network.Server.RemoteSignal.new({
		serverEvent = {
			function(_, arguments) 
				arguments[2] = 5 
				arguments[3] = "test"
			end
		}
	})

	testRemoteSignal:connect(function(client, a, b)
		print(a, b) --> 5, "test" (a and b ought to be 1 and 24 respectively, but they were modified through the middleware)
	end)

	testNetwork:append("signal", testRemoteSignal)
	testNetwork:dispatch(Workspace)

	-- Client
	local Workspace = game:GetService("Workspace")

	local testNetwork = network.client.fromParent("Test", Workspace):expect()
	print(testNetwork.signal:fireServer(1, 24)) 
	```
	:::
]=]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local networkFolder = script.Parent.Parent
local packages = networkFolder.Parent
local utilities = networkFolder.utilities

local sharedTypes = require(networkFolder.sharedTypes)
local sharedEnums = require(networkFolder.sharedEnums)
local Janitor = require(packages.Janitor)
local Sift = require(packages.Sift)
local networkUtil = require(utilities.networkUtil)

local DEFAULT_MIDDLEWARE_TEMPLATE = { serverEvent = {} }
local DEFAULT_CONFIG_TEMPLATE = {
	useUnreliableRemoteEvent = false,
	automaticArgumentSerializationAndDeserializationEnabled = true,
	globalRateLimit = 0,
}

local remoteSignals = {}

local RemoteSignal = { __index = {} }

type RemoteSignalMiddleware = { serverEvent: { () -> boolean } }
type RemoteSignalConfig = {
	useUnreliableRemoteEvent: boolean?,
	globalRateLimit: number?,
	automaticArgumentSerializationAndDeserializationEnabled: boolean,
}
type RemoteSignalConnectCallback = (client: Player, ...any) -> ()

--[=[
	Creates and returns a new remote signal. 

	- If the 2nd parameter `middleware` is not specified, then it will default to [DefaultRemoteSignalMiddleware] instead.
	- If the 3rd parameter `config` is not specified, then it will default to [DefaultRemoteSignalConfig] instead.
]=]

function RemoteSignal.new(
	middleware: RemoteSignalMiddleware?,
	config: RemoteSignalConfig?
): RemoteSignal
	if middleware ~= nil then
		middleware = Sift.Dictionary.mergeDeep(DEFAULT_MIDDLEWARE_TEMPLATE, middleware)
	else
		middleware = Sift.Dictionary.copyDeep(DEFAULT_MIDDLEWARE_TEMPLATE)
	end

	if config ~= nil then
		config = Sift.Dictionary.mergeDeep(DEFAULT_CONFIG_TEMPLATE, config)
	else
		config = Sift.Dictionary.copyDeep(DEFAULT_CONFIG_TEMPLATE)
	end

	local self = setmetatable({
		_janitor = Janitor.new(),
		_middleware = middleware,
		_config = config,
		_playerSpecificRateLimits = {},
		_playerRateLimitsClock = {},
	}, RemoteSignal)

	self:_init()
	return self
end

--[=[
	Returns a boolean indicating if `self` is a remote signal or not.
]=]

function RemoteSignal.is(self: any): boolean
	return getmetatable(self) == RemoteSignal
end

--[=[
	@tag RemoteSignal instance

	Connects `callback` to the remote signal so that it is called whenever the client
	fires the remote signal. Additionally, `callback` will be passed all the arguments sent 
	by the client.  

	```lua
	-- Server
	remoteSignal:connect(function(client, a, b)
		print(a + b) --> 3
	end)

	-- Client
	clientRemoteSignal:fireServer(1, 2)
	```

	:::warning Possible Rate Limit
	It is possible that the client firing to this remote signal is intercepted by a rate-limit, either
	due to the global rate limit imposed on this remote signal for all players, or a specific-rate limit
	imposed for this client.

	```lua
	local remoteSignal = RemoteSignal.new(nil, 10) -- global rate limit of 10 seconds
	-- Server
	remoteSignal:connect(function()
		print("Fired")
	end)

	--> "Fired" 
	-- Only printed once!

	-- Client
	for _ = 1, 5 do
		clientRemoteSignal:fireServer()
	end
	```

	If you do not desire this behavior, you can do the following:
		
	- Set a specific rate limit for the client through [RemoteSignal:setRateLimitForClient] or [RemoteSignal:setRateLimitForClients], to `0`.
	- Not impose a global rate limit to the remote signal (See [RemoteSignalConfig] for more info).
	:::
]=]

function RemoteSignal.__index:connect(callback: RemoteSignalConnectCallback): RBXScriptConnection
	local connection
	connection = self._remoteEvent.OnServerEvent:Connect(
		function(client: Player, serializedArgs: sharedTypes.SerializedArgs)
			if not connection.Connected then
				return
			end

			self:_handleClientFire(client, serializedArgs, callback)
		end
	)

	return connection
end

--[=[
	@tag RemoteSignal instance

	Works almost exactly the same as [RemoteSignal:connect], except the 
	connection returned is  disconnected immediately upon `callback` being called.
]=]

function RemoteSignal.__index:once(callback: RemoteSignalConnectCallback): RBXScriptConnection
	local connection
	connection = self._remoteEvent.OnServerEvent:Once(
		function(client: Player, serializedArgs: sharedTypes.SerializedArgs)
			if not connection.Connected then
				return
			end

			self:_handleClientFire(client, serializedArgs, callback)
		end
	)

	return connection
end

--[=[
	@tag RemoteSignal instance

	Connects `callback` to the remote signal so that it is called whenever the remote signal
	is fired off by the client *successfully*. Additionally, `callback` will be passed all the arguments sent 
	by the client.

	```lua
	-- Server
	remoteSignal:connect(function(client, a, b)
		print(a + b) --> 3
	end)

	-- Client
	clientRemoteSignal:fireServer(1, 2)
	```
]=]

--[=[
	@tag RemoteSignal instance

	Yields the current thread until the remote signal is *successfully* fired off by the client. 
	The yielded thread is resumed once the client fires some data to the server *successfully*, 
	with the arguments sent by the client.

	```lua
	-- Server
	local client, a, b = remoteSignal:wait()
	print(a + b) --> 3

	-- Client
	clientRemoteSignal:fireServer(1, 2)
	```
]=]

function RemoteSignal.__index:wait(): ...any
	local yieldedThread = coroutine.running()

	self:once(function(...)
		task.defer(yieldedThread, ...)
	end)

	return coroutine.yield()
end

--[=[
	@tag RemoteSignal instance

	Sets a specific rate limit for the given client.

	:::note
	This specific rate limit set for this client will be **removed**
	once the client leaves the game.
	:::
]=]

function RemoteSignal.__index:setRateLimitForClient(client: Player, rateLimit: number)
	self._playerSpecificRateLimits[client] = rateLimit
end

--[=[
	@tag RemoteSignal instance

	Wrapper for [RemoteSignal:setRateLimitForClient] for an array of clients.
]=]

function RemoteSignal.__index:setRateLimitForClients(clients: { Player }, rateLimit: number)
	for _, client in clients do
		self:setRateLimitForClient(client, rateLimit)
	end
end

--[=[
	@tag RemoteSignal instance

	Removes the **specific rate limit set** for the given client (through [RemoteSignal:setRateLimitForClient]).

	:::note Global Rate Limit 
	If the remote signal has a global rate limit set (see [RemoteSignal.new]'s second parameter), then
	the given client will now be subject to that global rate limit. 

	If you do not desire this behavior and want the rate limit imposation completely lifted for the client, 
	you should set a specific rate limit of `0` for the given client (through [RemoteSignal:setRateLimitForClient]).
	:::
]=]

function RemoteSignal.__index:removeSpecificRateLimitForClient(client: Player)
	self._playerSpecificRateLimits[client] = nil
end

--[=[
	@tag RemoteSignal instance

	Wrapper for [RemoteSignal:removeSpecificRateLimitForClient] for an array of clients.
]=]

function RemoteSignal.__index:removeSpecificRateLimitForClients(clients: { Player })
	for _, client in clients do
		self:removeRateLimitForClient(client)
	end
end

--[=[
	@tag RemoteSignal instance

	Fires the given arguments to `client`.
]=]

function RemoteSignal.__index:fireClient(client: Player, ...: any)
	self._remoteEvent:FireClient(client, networkUtil.serializeGivenArgs(self._remoteEvent, ...))
end

--[=[
	@tag RemoteSignal instance

	Calls [RemoteSignal:fireClient] for every player in the game, passing in the given arguments.
]=]

function RemoteSignal.__index:fireAllClients(...: any)
	for _, player in Players:GetPlayers() do
		self:fireClient(player, ...)
	end
end

--[=[
	@tag RemoteSignal instance

	Iterates through `clients` and calls [RemoteSignal:fireClient] for each client, 
	passing in the given arguments.
]=]

function RemoteSignal.__index:fireClients(clients: { Player }, ...: any)
	for _, client in clients do
		self:fireClient(client, ...)
	end
end

--[=[
	@tag RemoteSignal instance

	Calls [RemoteSignal:fireClient] for every player in the game, except for `client`, 
	passing in the given arguments.
]=]

function RemoteSignal.__index:fireAllClientsExcept(client: Player, ...: any)
	for _, player in Players:GetPlayers() do
		if player == client then
			continue
		end

		self:fireClient(player, ...)
	end
end

--[=[
	@tag RemoteSignal instance
	
	Destroys the remote signal and renders it unusable.
]=]

function RemoteSignal.__index:destroy()
	self._janitor:Destroy()
end

--[=[
	@private
]=]

function RemoteSignal.__index:_handleClientFire(
	client: Player,
	serializedArgs: sharedTypes.SerializedArgs,
	callback: RemoteSignalConnectCallback
)
	local args = { client, networkUtil.deserializeAndUnpack(self._remoteEvent, serializedArgs) }
	if self:_authenticateClientFireRequest(args) == false then
		return
	end

	callback(unpack(args))
end

--[=[
	@private
]=]

function RemoteSignal.__index:dispatch(name: string, parent: Instance)
	self._remoteEvent.Name = name
	self._remoteEvent.Parent = parent
end

--[=[
	@private
]=]

function RemoteSignal.__index:_authenticateClientFireRequest(
	client: Player,
	serializedArgs: sharedTypes.SerializedArgs
)
	local playerSpecificRateLimit = self._playerSpecificRateLimits[client]
	local lastPlayerRateLimitClock = self._playerRateLimitsClock[client] or 0

	if
		(Workspace:GetServerTimeNow() - lastPlayerRateLimitClock)
		< (playerSpecificRateLimit or self._config.globalRateLimit)
	then
		return false
	end

	self._playerRateLimitsClock[client] = Workspace:GetServerTimeNow()

	-- If there is an explicit false value included in the accumulated
	-- response of all serverEvent callbacks, then that means we should
	-- avoid this client's request to fire off the remote signal:
	if
		table.find(
			networkUtil.accumulatedResponseFromMiddlewareCallbacks(
				self._middleware.serverEvent,
				self,
				client,
				serializedArgs
			),
			false
		)
	then
		return false
	end

	return true
end

function RemoteSignal.__index:_init()
	self._remoteEvent = self._janitor:Add(
		if self._config.useUnreliableRemoteEvent
			then Instance.new("UnreliableRemoteEvent")
			else Instance.new("RemoteEvent")
	)
	self._remoteEvent:SetAttribute(
		sharedEnums.Attribute.AutomaticArgumentSerializationAndDeserializationEnabled,
		self._config.automaticArgumentSerializationAndDeserializationEnabled
	)
	self._remoteEvent:SetAttribute(sharedEnums.Attribute.BoundToRemoteSignal, true)
	remoteSignals[self] = self

	self._janitor:Add(function()
		remoteSignals[self] = nil
		setmetatable(self, nil)
	end)
end

function RemoteSignal:__tostring()
	return string.format(
		"[%s]: (%s)",
		if self._config.shouldUseUnreliableRemoteEvent
			then "RemoteSignal [UNRELIABLE]"
			else "RemoteSignal",
		self._remoteEvent.Name
	)
end

Players.PlayerRemoving:Connect(function(player)
	for _, remoteSignal in remoteSignals do
		remoteSignal._playerRateLimitsClock[player] = nil
		remoteSignal._playerSpecificRateLimits[player] = nil
	end
end)

export type RemoteSignal = typeof(setmetatable(
	{} :: {
		_janitor: sharedTypes.Janitor,
		_middleware: RemoteSignalMiddleware,
		_config: RemoteSignalConfig,
		_playerSpecificRateLimits: { [Player]: number },
		_playerRateLimitsClock: {
			[Player]: number,
		},
		_remoteEvent: sharedTypes.RemoteEventOrUnreliable,
	},
	RemoteSignal
))

return table.freeze(RemoteSignal)
