--[=[
	@class NetworkServer
	@server

	The server counterpart of [network].
]=]

--[=[ 
	@prop RemoteProperty RemoteProperty
	@within NetworkServer
	@tag Read only
]=]

--[=[ 
	@prop RemoteProperty RemoteProperty
	@within NetworkServer
	@tag Read only
]=]

--[=[
	@type MethodCallInbound (methodName: string, client: Player, args: {any}) -> boolean
	@within NetworkServer
]=]

--[=[
	@type MethodCallOutbound (methodName: string, client: Player, args: {any}, methodResponse: any) -> any
	@within NetworkServer
]=]

--[=[
	@type ValueDispatch (client: Player, value: any) -> any
	@within NetworkServer
]=]

--[=[ 
	@interface DefaultMiddleware 
	@within NetworkServer
	.AutomaticArgumentSerializationAndDeserialization string 
	
	- `AutomaticArgumentSerializationAndDeserialization`:
		- Arguments and values sent across the network will be automatically serialized and deserialized respectively. The network
		package uses the [serializerUtil](https://bubshayz.github.io/libraries/api/serializerUtil/) module behind the scenes to accomplish this.

		- [RemoteProperty], [RemoteSignal], [ClientRemoteProperty] and [ClientRemoteSignal] bound to the network object will respect this feature.

		:::note 
		While the serializer utility used to accomplish this supports a variety of data types, do keep in mind that not all data types
		can be supported on the go for serialization and deserialization - check the above hyperlink to the serializer utility on how
		many data types it supports.
		::::
]=]

--[=[ 
	@type NetworkServer NetworkServer
	@within NetworkServer
]=]

--[=[
	@interface Middleware
	@within NetworkServer
	.methodCallInbound MethodCallInbound?
	.methodCallOutbound MethodCallOutbound?
	.valueDispatch ValueDispatch?

	`methodCallInbound`, `methodCallOutbound` and `valueDispatch` must be an array of callbacks, if specified. 

	:::warning Yielding is not allowed
	Middleware callbacks aren't allowed to yield. If they do so, their thread will be closed and an error will be outputted, but
	other callbacks will not be affected.
	:::

	### `methodCallInbound` 

	Callbacks in `methodCallInbound` are called whenever a client tries to call any of the appended methods of the network. 

	The first argument passed to each callback is the name of the method (the client called), and the second argument, i.e 
	the arguments sent by the client, which are packed into an array. 
	
	```lua
	local methodCallInboundCallbacks = {
		function (methodName, client: Player, arguments)
			print(client:IsA("Player")) --> true 
			print(typeof(arguments)) --> "table"
		end
	}
	---
	```

	:::tip More control
	- If any of the callbacks return an **explicit** false value, then the method which the client tried to call, will *not* be
	called. This is useful as you can implement for e.g, implementing rate limits!

	- Additionally, you can modify the `arguments` table which will be reflected in the method, for e.g:

	```lua
	-- Server
	local Workspace = game:GetService("Workspace")

	local testNetwork = Network.Server.new("TestNetwork", {methodCallInbound = {
		function(_, _, arguments) 
			arguments[2] = "test"
		end
	}})
	testNetwork:append("method", function(player, a)
		print(a) --> "test" (a ought to be 1, but the middleware modified it!)
	end)
	testNetwork:dispatch(Workspace)

	-- Client
	local Workspace = game:GetService("Workspace")

	local testNetwork = network.client.fromParent("TestNetwork", Workspace):expect()
	testNetwork.method(1) 
	```
	:::

	### `methodCallOutbound` 

	Callbacks in `methodCallOutbound` are called whenever a method (appended to the network) is called by the client, and 
	has **finished** running.  

	The first argument passed to each callback is the name of the method (client called), and the second argument, i.e 
	the arguments sent by the client, which are packed into an array. 

	A third argument i.e `methodResponse` is passed to each callback as well, which is just the response of the method called. 

	```lua
	local methodCallOutboundCallbacks = {
		function (methodName, client: Player, arguments, methodResponse)
			print(client:IsA("Player")) --> true 
			print(typeof(arguments)) --> "table"
		end
	}
	---
	```
	
	Additionally, these callbacks can return a value that overrides the actual result of the method (which will be sent
	back to the client). For e.g:

	```lua
	-- Server:
	local Workspace = game:GetService("Workspace")

	local middleware = {
		{
			function (methodName, arguments, methodResponse)
				print(methodResponse) --> "this"
				return 50
			end
		}
	}

	local testNetwork = network.Server.new("TestNetwork", middleware)
	testNetwork:append("someMethod", function()
		return "this"
	end)
	testNetwork:dispatch(Workspace)

	-- Client:
	local Workspace = game:GetService("Workspace")

	local testNetwork = network.fromParent("TestNetwork", Workspace):expect()
	print(testNetwork.someMethod()) --> 50 
	```

	Additionally, if more than 1 callback returns a value, then all those returned values will be packed into an array and *then* sent
	back to the client. This is by design, as it isn't ideal to disregard all returned values for just 1.
	
	For e.g: 
	
	```lua
	-- Server:
	local Workspace = game:GetService("Workspace")

	local middleware = {
		{
			function (methodName, arguments, response)
				return 1
			end,

			function (methodName, arguments, response)
				return 2
			end,

			function (methodName, arguments, response)
				return 3
			end
		}
	}

	local testNetwork = network.server.new("TestNetwork", middleware)
	testNetwork:append("someMethod", function()
		return "this"
	end)
	testNetwork:dispatch(Workspace)

	-- Client:
	local Workspace = game:GetService("Workspace")

	local testNetwork = network.client.fromParent("TestNetwork", Workspace):expect()
	print(testNetwork.someMethod()) --> {1, 2, 3} 
	```

	### `valueDispatch` 

	Callbacks in `valueDispatch` are called whenever the network object replicates a value (**specifically a non function and not a remote signal
	and not a remote property**), e.g a table, number, string, etc.

	The first argument passed to each callback is the client itself whom the value is going to replicate to, and the value.
	
	```lua
	local valueDispatchCallbacks = {
		function (client, value)
			---
		end,
	   
	}
	---
	```

	The return value of the callback will be used in favour of the original value. If more than 1 callback returns
	a value, all of them will be packed into an array and *then* sent.

	```lua
	local Workspace = game:GetService("Workspace")
	
	-- Server
	local valueDispatchCallbacks = {
		function (client, value)
			return {
				test = 1
			}
		end,
	   
	}

	local testNetwork = Network.Server.new("TestNetwork", {valueDispatch = valueDispatchCallbacks})
	testNetwork:append("someValue", 5)
	testNetwork:dispatch(Workspace)

	-- Client
	local Workspace = game:GetService("Workspace")

	local testNetwork = network.client.fromParent("TestNetwork", Workspace):expect()
	print(testNetwork.someValue) --> {test = 1} (this thought to be 5, but the middleware returned a table instead)
	```

	```lua
	-- Server
	local Workspace = game:GetService("Workspace")
	
	local valueDispatchCallbacks = {
		function (client, value)
			print(value) --> 5
			return 1
		end,
		
		function (client, value)
			print(value) --> 5
		 	return 2
		end
	}

	local testNetwork = Network.Server.new("TestNetwork", {valueDispatch = valueDispatchCallbacks})
	testNetwork:append("someValue", 5)
	testNetwork:dispatch(Workspace)

	-- Client
	local Workspace = game:GetService("Workspace")

	local testNetwork = network.client.fromParent("TestNetwork", Workspace):expect()
	print(testNetwork.someValue) --> {1, 2}
	---
	```

	:::tip More control
	- If any of the callbacks return a `nil` value, then the value will not be replicated to the client. For e.g:

	```lua
		local Workspace = game:GetService("Workspace")
	
	-- Server
	local valueDispatchCallbacks = {
		function (client, value)
			return nil
		end,
	   
	}

	local testNetwork = Network.Server.new("TestNetwork", {valueDispatch = valueDispatchCallbacks})
	testNetwork:append("someValue", 5)
	testNetwork:dispatch(Workspace)

	-- Client
	local Workspace = game:GetService("Workspace")

	local testNetwork = network.client.fromParent("TestNetwork", Workspace):expect()
	print(testNetwork.someValue) --> nil (this thought to be 5, but the middleware returned a nil value instead)
	```
	:::
]=]

local packages = script.Parent.Parent
local utilities = script.Parent.utilities

local Janitor = require(packages.Janitor)
local Sift = require(packages.Sift)
local Promise = require(packages.Promise)
local networkUtil = require(utilities.networkUtil)
local RemoteSignal = require(script.RemoteSignal)
local Signal = require(packages.Signal)
local RemoteProperty = require(script.RemoteProperty)
local sharedEnums = require(script.Parent.sharedEnums)
local sharedTypes = require(script.Parent.sharedTypes)

local DEFAULT_MIDDLEWARES_TEMPLATE = {
	methodCallOutbound = {},
	methodCallInbound = {},
	valueDispatch = {},
	default = {},
}

local DEFAULT_MIDDLEWARE = table.freeze({
	AutomaticArgumentSerializationAndDeserialization = "AutomaticArgumentSerializationAndDeserialization",
})

local networks = {}
local onNetworkCreated = Signal.new()

local NetworkServer = {
	RemoteProperty = RemoteProperty,
	RemoteSignal = RemoteSignal,
	DefaultMiddleware = DEFAULT_MIDDLEWARE,
	__index = {},
}

--[=[
	@return NetworkServer?

	Returns a network of the given name, if found.

	```lua
	-- Script 1:
	local network = NetworkServer.new("Test")
	network:append("key", "some value")
	network:dispatch(game:GetService("ReplicatedStorage"))

	-- Script 2:
	local testNetwork = NetworkServer.fromName("Test")
	```
]=]

function NetworkServer.fromName(name: string): NetworkServer?
	return networks[name]
end

--[=[
	@return NetworkServer?

	Promisified version of [NetworkServer.fromName].

	```lua
	-- Script 1:
	local network = NetworkServer.new("Test")
	network:append("key", "some value")
	network:dispatch(game:GetService("ReplicatedStorage"))

	-- Script 2:
	NetworkServer.fromNamePromise("Test"):andThen(function(testNetwork)
		print(testNetwork:dispatch()) 
	end)
	```
]=]

function NetworkServer.fromNamePromise(name: string)
	if networks[name] then
		return Promise.resolve(networks[name])
	end

	return Promise.new(function(resolve)
		while networks[name] == nil do
			onNetworkCreated:Wait()
		end

		resolve(networks[name])
	end)
end

--[=[
	@param middlewares {DefaultMiddleware | Middleware?}?
	@return NetworkServer

	Creates and returns a new network object of `name`.

	```lua
	-- Server:
	local network = NetworkServer.new("Test")
	network:append("key", "some value")
	network:dispatch(game:GetService("ReplicatedStorage"))

	-- Client:
	local network = network.Client.fromParent("Test", game:GetService("ReplicatedStorage")):expect()
	print(network.key) --> "some value"
	```
	
	The 2nd argument, `middlewares` can be passed which can be used by the network object as
	it's middleware. Middlewares allow  you to determine the behavior of network objects *globally*, 
	so they affect the functions, remote signals and remote properties bound to the network object as a whole.

	```lua
	local network = NetworkServer.new(
		"Test", 
		{
			-- Can pass in default middlewares too, in this case, let's pass in a default middleware
			-- for automatic serialization and deserialization of arguments sent across the network:
			default = {NetworkServer.DefaultMiddleware.AutomaticArgumentSerializationAndDeserialization}, 
		}
	)

	-- Normally, you can't send in TweenInfo objects across the network. In order to do so, you would
	-- need to serialize them! Now that we have set a default middleware for serialization and deserialiation,
	-- this will be done automatically for us!
	network:append("key", TweenInfo.new(5))
	network:dispatch(game:GetService("ReplicatedStorage"))

	-- Client:
	local network = network.Client.fromParent("Test", game:GetService("ReplicatedStorage")):expect()
	print(typeof(network.key)) --> "TweenInfo"
	```
	
	:::note Precaution!
	The network object will initially not be accessible to the client. You need to call [NetworkServer:dispatch] 
	to render the network object accessible to the client!
	:::
]=]

function NetworkServer.new(name: string, middlewares: { (Middleware | string)? }): NetworkServer
	assert(networks[name] == nil, string.format('Network "%s" already exists!', name))

	for key, middleware in middlewares do
		if key ~= "default" then
			continue
		end

		for _, defaultMiddleware in middleware do
			assert(
				NetworkServer.DefaultMiddleware[defaultMiddleware],
				string.format(
					'Default middleware "%s" in middlewares.default (#2nd argument to NetworkServer.new) is not a valid member of NetworkServer.DefaultMiddleware!',
					tostring(middleware)
				)
			)
		end
	end

	local self = setmetatable({
		_name = name,
		_janitor = Janitor.new(),
		_middlewares = Sift.Dictionary.mergeDeep(DEFAULT_MIDDLEWARES_TEMPLATE, middlewares),
	}, NetworkServer)

	self:_init()
	return self
end

--[=[
	Returns a boolean indicating if `self` is a network object or not.
]=]

function NetworkServer.is(self: any): boolean
	return getmetatable(self) == NetworkServer
end

--[=[
	Returns a boolean indicating if the network object is dispatched to the 
	client or not. 
]=]

function NetworkServer.__index:dispatched(): boolean
	return self._networkFolder.Parent ~= nil
end

--[=[
	@param value any

	Appends a key-value pair, `key` and `value`, to the network object, so that
	it is available to the client once the network object is dispatched. 

	For e.g:

	```lua
	-- Server
	local Workspace = game:GetService("Workspace")

	local testNetwork = Network.Server.new("TestNetwork")
	testNetwork:append("key", "the value!")
	testNetwork:dispatch(Workspace)

	-- Client
	local testNetwork = Network.client.fromParent("TestNetwork", Workspace):expect()
	print(testNetwork.key) --> "the value!"
	```

	:::tip More support
	You can also append a [RemoteSignal] and a [RemoteProperty] as well, they'll be represented as a [ClientRemoteSignal] and a [ClientRemoteProperty]
	to the client respectively!
	::: 

	:::note Precaution!
	If the network object does not have a default middleware (`AutomaticArgumentSerializationAndDeserialization` specifically) set, 
	then [argument limitations](https://create.roblox.com/docs/scripting/events/argument-limitations-for-bindables-and-remotes)
	will apply, as remote functions are internally used the key-value pairs accessible to the clients.
	:::

	:::warning
	This method will error if the network object is dispatched to the client. 
	Always make sure to append keys and values *before* you dispatch the 
	network object. You can check if a network object is dispatched to the 
	client or not through [NetworkServer:dispatched].
	:::
]=]

function NetworkServer.__index:append(key: string, value: any)
	assert(
		not self:dispatched(),
		"Cannot append key value pair as network object is dispatched to the client!"
	)

	self:_setup(key, value)
end

--[=[
	Dispatches the network folder of the network object to `parent`, rendering
	the network object accessible to the client now.

	:::warning
	If another network object of the same name as this network object is already
	dispatched to `parent`, then this method will error - you can't have more than 
	1 network object of the same name dispatched to the same instance!
	:::
]=]

function NetworkServer.__index:dispatch(parent: Instance)
	self._networkFolder.Parent = parent
end

--[=[
	Destroys the network object and all appended remote properties &
	remote signals within the network object, and renders the network 
	object useless. 
]=]

function NetworkServer.__index:destroy()
	self._janitor:Destroy()
end

function NetworkServer.__index:_setupRemoteObject(
	key: string,
	value: RemoteProperty.RemoteProperty<any> | RemoteSignal.RemoteSignal
)
	local dispatcherRemoteFunction = value:dispatcherRemoteInstance()
	dispatcherRemoteFunction:SetAttribute(
		sharedEnums.Attribute.AutomaticSerializationAndDeserializationEnabled,
		table.find(
			self._middlewares.default,
			NetworkServer.DefaultMiddleware.AutomaticArgumentSerializationAndDeserialization
		) ~= nil
	)
	value:dispatch(key, self._networkFolder)

	self._janitor:Add(function()
		-- Destroy the remote property/remote signal if it already isn't
		-- destroyed yet, to avoid memory leaks:
		if not RemoteProperty.is(value) or not RemoteSignal.is(value) then
			return
		end

		value:destroy()
	end)
end

function NetworkServer.__index:_setup(key: string, value: any)
	if RemoteSignal.is(value) or RemoteProperty.is(value) then
		self:_setupRemoteObject(key, value)
		return
	end

	local remoteFunction = Instance.new("RemoteFunction")
	remoteFunction.Name = key
	remoteFunction:SetAttribute(sharedEnums.Attribute.ValueType, typeof(value))
	remoteFunction:SetAttribute(
		sharedEnums.Attribute.AutomaticSerializationAndDeserializationEnabled,
		table.find(
			self._middlewares.default,
			NetworkServer.DefaultMiddleware.AutomaticArgumentSerializationAndDeserialization
		) ~= nil
	)
	remoteFunction.Parent = self._networkFolder

	function remoteFunction.OnServerInvoke(client: Player, serializedArgs: { any })
		local deserializedArgs =
			{ networkUtil.deserializeAndUnpack(remoteFunction, serializedArgs) }

		if typeof(value) == "function" then
			local methodCallInboundMiddlewareAccumulatedResponses =
				networkUtil.accumulatedResponseFromMiddlewareCallbacks(
					self._middlewares.methodCallInbound,
					key,
					client,
					unpack(deserializedArgs)
				)

			-- If there is an explicit false value included in the accumulated
			-- the response of all inbound method callbacks, then that means we should
			-- avoid this client's request to call the method!
			if
				methodCallInboundMiddlewareAccumulatedResponses ~= nil
				and table.find(methodCallInboundMiddlewareAccumulatedResponses, false)
			then
				return
			end

			local methodResponses = { value(client, unpack(deserializedArgs)) }
			local methodCallOutboundMiddlewareAccumulatedResponses, methodCallOutboundMiddlewareResponsesAreValid =
				networkUtil.truncateAccumulatedResponses(
					self._middlewares.methodCallOutbound,
					networkUtil.accumulatedResponseFromMiddlewareCallbacks(
						self._middlewares.methodCallOutbound,
						key,
						client,
						deserializedArgs,
						unpack(methodResponses)
					)
				)

			if methodCallOutboundMiddlewareResponsesAreValid then
				return networkUtil.serializeGivenArgs(
					remoteFunction,
					methodCallOutboundMiddlewareAccumulatedResponses
				)
			else
				return networkUtil.serializeGivenArgs(remoteFunction, unpack(methodResponses))
			end
		else
			local valueDispatchMiddlewareAccumulatedResponses, valueDispatchMiddlewareResponsesAreValid =
				networkUtil.truncateAccumulatedResponses(
					self._middlewares.valueDispatch,
					networkUtil.accumulatedResponseFromMiddlewareCallbacks(
						self._middlewares.valueDispatch,
						client,
						value
					)
				)

			return networkUtil.serializeGivenArgs(
				remoteFunction,
				if valueDispatchMiddlewareResponsesAreValid
					then valueDispatchMiddlewareAccumulatedResponses
					else value
			)
		end
	end

	self._janitor:Add(function()
		remoteFunction.OnServerInvoke = nil
		remoteFunction:Destroy()
	end)
end

function NetworkServer.__index:_init()
	self:_setupNetworkFolder()
	networks[self._name] = self
	onNetworkCreated:Fire()

	self._janitor:Add(function()
		networks[self._name] = nil
		setmetatable(self, nil)
	end)
end

function NetworkServer.__index:_setupNetworkFolder()
	local networkFolder = self._janitor:Add(Instance.new("Folder"))
	networkFolder.Name = self._name
	networkFolder:SetAttribute(sharedEnums.Attribute.NetworkFolder, true)
	self._networkFolder = networkFolder
end

export type Middleware = {
	methodCallOutbound: {
		(
			methodName: string,
			client: Player,
			args: { any },
			methodResponse: any
		) -> any
	}?,

	methodCallInbound: { (methodName: string, client: Player, args: { any }) -> boolean }?,
}

export type NetworkServer = typeof(setmetatable(
	{} :: {
		_name: string,
		_janitor: sharedTypes.Janitor,
		_middlewares: typeof(DEFAULT_MIDDLEWARES_TEMPLATE),
	},
	NetworkServer
))

return table.freeze(NetworkServer)
