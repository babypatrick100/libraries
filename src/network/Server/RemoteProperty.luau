--[=[
	@class RemoteProperty
	@server

	A remote property in layman's terms is simply an  object which can store some global
	value as well as values specific to players. 
]=]

--[=[ 
	@prop RejectClientSetRequest "RejectClientSetRequest"
	@within RemoteProperty
	@tag Read only

	A marker that can be passed from a `clientSet` middleware callback, to reject a client's request of setting
	some value (for themselves in the remote property).
]=]

--[=[ 
	@interface DefaultRemotePropertyConfig 
	@within RemoteProperty
	.automaticArgumentSerializationAndDeserializationEnabled true
]=]

--[=[
	@interface DefaultRemotePropertyMiddleware
	@within RemoteProperty
	.clientSet {...}
	.clientGet {}

	By default, `clientSet` contains a function which always returns [RejectClientSetRequest], in
	order to reject the client's request of setting a value for themselves in the remote property, as this is a 
	security risk, if by default, this behavior is allowed. Additionally, a warn is also produced in the output 
	to let you know of this.
	
	So in order to allow clients to request the server to set their value, then you must define a middleware where `clientSet` contains
	**at least** 1 function, for e.g;
	
	```lua
	local remoteProperty = RemoteProperty.new({
		clientSet = {
			function(_, _, valueFromClient) 
				return valueFromClient
			end
		}
	})
	```
]=]

--[=[ 
		@interface RemotePropertyConfig 
		@within RemoteProperty
		.automaticArgumentSerializationAndDeserializationEnabled boolean -- determines whether or not values sent to clients by the remote signal be internally serialized/deserialized or not.
	
		- `automaticArgumentSerializationAndDeserializationEnabled` -> `true`
			- Arguments and values sent across the network by the remote property 
			will be automatically serialized and deserialized respectively, with the
			help of an internal library, i.e [serializerUtil](https://babypatrick100.github.io/libraries/api/serializerUtil/).
	
			:::note Serialization and deserialization limitations!
			While the serializer utility used to accomplish this supports a variety of data types, do keep in mind that not all data types
			can be supported on the go for serialization and deserialization - check the above hyperlink to the serializer utility on how
			many data types it supports.
			::::
	
			**See the type of the value of the remote property being `TweenInfo` on the client**:
	
			```lua
			-- Server
			local Workspace = game:GetService("Workspace")
	
			local testNetwork = network.Server.new("TestNetwork")
			local remoteProperty = network.Server.RemoteProperty.new(TweenInfo.new())
			testNetwork:append("remoteProperty",  remoteProperty) 
			testNetwork:dispatch(Workspace)
	
			-- Client
			local Workspace = game:GetService("Workspace")
	
			local testNetwork = network.client.fromParent("TestNetwork", Workspace):expect()
			print(typeof(testNetwork.remoteProperty:get())) --> "TweenInfo"
			```

		- `automaticArgumentSerializationAndDeserializationEnabled` -> `false`
			- Arguments and values sent across the network will not be internally serialized
			and deserialized. Using the same example as above:
			
			**See the type of the value of the remote property being `table` on the client instead of `TweenInfo`**:
	
			```lua
			-- Server
			local Workspace = game:GetService("Workspace")
	
			local testNetwork = network.Server.new("TestNetwork")
			local remoteProperty = network.Server.RemoteProperty.new(TweenInfo.new())
			testNetwork:append("remoteProperty",  remoteProperty) 
			testNetwork:dispatch(Workspace)
	
			-- Client
			local Workspace = game:GetService("Workspace")
	
			local testNetwork = network.client.fromParent("TestNetwork", Workspace):expect()
			print(typeof(testNetwork.remoteProperty:get())) --> "table"
			```
	]=]

--[=[ 
		@prop onUpdate Signal <newValue: T, oldValue: T?>
		@within RemoteProperty
		@tag Read only
		@tag Signal
		@tag RemoteProperty Instance
	
		A [signal](https://sleitnick.github.io/RbxUtil/api/Signal/) which is fired whenever the value 
		of the remote property is set to a new one. The signal is only passed the new value as the only argument.
	]=]

--[=[ 
		@prop clientValueOnUpdate Signal <client: Player, newValue: T, oldValue: T?>
		@within RemoteProperty
		@tag Read only
		@tag Signal
		@tag RemoteProperty Instance
	
		A [signal](https://sleitnick.github.io/RbxUtil/api/Signal/) which is fired whenever the value 
		of `player` specifically in the remote property is set to a new one. The signal is passed the player 
		as the first argument, and the new specific value of `player` set in the remote property, as the second argument. 
	]=]

--[=[ 
	@type RemoteProperty RemoteProperty 
	@within RemoteProperty
]=]

--[=[ 
	@type RemoteProperty RemoteProperty 
	@within RemoteProperty
]=]

--[=[ 
	@type Observer (newValue: T, oldValue: T?) -> ()
	@within RemoteProperty
]=]

--[=[
		@interface RemotePropertyMiddleware
		@within RemoteProperty
		.clientSet { (client: Player, value: any) -> any }?,
		.clientGet { (client: Player) -> any }?,
	
		:::warning Yielding in middleware callbacks is not allowed
		Middleware callbacks aren't allowed to yield. If they do so, their thread will be closed via
		[coroutine.close](https://create.roblox.com/docs/reference/engine/libraries/coroutine#close) and an
		error will be outputted in the console.

		Yielding, (especially in network-related code) results in weird bugs and behavior which can be hard to track down!
		:::
	
		### clientSet
	
		Callbacks in `clientSet` are called whenever the client tries to set the value of the remote property
		*for themselves specifically*.
	
		The first argument passed to each callback is a reference to the remote property itself,
		followed by the client object and the value the client is trying to set.
	
		```lua
		local clientSetCallbacks = {
			function (remoteProperty, client, value)
				print(RemoteProperty.is(remoteProperty)) --> true
				print(client:IsA("Player")) --> true 
			end
		}
		---
		```
	
		:::tip More control
		A `clientSet` callback can return a **non-nil** value, which will then be set as the value for the client in the remote property.
		This is useful in cases where you want to have more control over what values the client can set for themseves in the remote
		property.
		
		For e.g:
	
		```lua
		-- Server
		local Workspace = game:GetService("Workspace")
		
		local testRemoteProperty = network.Server.RemoteProperty.new(50, {
			clientSet = {function() return "rickrolled" end}
		})
	
		local testNetwork = network.Server.new("TestNetwork")
		testNetwork:append("property", testRemoteProperty)
		testNetwork:dispatch(Workspace)
	
		-- Client
		local Workspace = game:GetService("Workspace")
	
		local testNetwork = network.client.fromParent("TestNetwork", Workspace):expect()
		testNetwork.property:set(1)
		print(testNetwork.property.onUpdate:Wait()) --> "rickrolled" (This ought to print 1, but our middleware returned a custom value!)
		```

		You can also return [RejectClientSetRequest] from a `clientSet` middleware callback, in order to reject the client's
		request of setting a value for themselves in the remote property.
	
		Additionally, if more than 1 callback returns a value, then all those returned values will be packed into an array and *then* sent
		back to the client. This is by design - as it isn't ideal to disregard all returned values for just 1. 
		
		For e.g:
	
		```lua
		-- Server
		local Workspace = game:GetService("Workspace")
		
		local testRemoteProperty = network.Server.RemoteProperty.new(50, {
			clientSet = {
				function() return "rickrolled" end,
				function() return "oof" end,
				function() return "hello" end
			}
		})
	
		local testNetwork = network.Server.new("TestNetwork")
		testNetwork:append("property", testRemoteProperty)
		testNetwork:dispatch(Workspace)
	
		-- Client
		local Workspace = game:GetService("Workspace")
	
		local testNetwork = network.client.fromParent("TestNetwork", Workspace):expect()
		testNetwork.property:set(1)
		print(testNetwork.property.onUpdate:Wait()) --> {"oofed", "rickrolled", "hello"} 
		```

		If any of the `clientSet` middleware callbacks return [RejectClientSetRequest], then the client's
		request of setting a value for themselves in the remote property, will be rejected.
		:::
	
		### clientGet
	
		Callbacks in `clientGet` are called whenever the client tries to get the value of the remote property.
	
		The first argument passed to each callback is a reference to the remote property itself, which is followed by the client object.
	
		```lua
		local clientGetCallbacks = {
			function (remoteProperty, client)
				print(client:IsA("Player")) --> true
			end
		}
		---
		```
		
		:::tip More control
		A callback can return a non-nil value, which will then be returned to the client. This is useful in cases where you want to
		have more control over what values the client can retrieve from the remote property.
		
		For e.g:
	
		```lua
		-- Server
		local Workspace = game:GetService("Workspace")
		
		local testRemoteProperty = network.Server.RemoteProperty.new(5000, {
			clientGet = {function() return "rickrolled" end}
		})
	
		local testNetwork = network.Server.new("TestNetwork")
		testNetwork:append("property", testRemoteProperty)
		testNetwork:dispatch(Workspace)
	
		-- Client
		local Workspace = game:GetService("Workspace")
	
		local testNetwork = network.client.fromParent("TestNetwork", Workspace):expect()
		print(testNetwork.property:get()) --> "rickrolled" (This ought to print 5000, but our middleware returned a custom value!)
		```
	
		Additionally, if more than 1 callback returns a value, then all those returned values will be packed into an array and *then* sent
		back to the client. This is by design - as it isn't ideal to disregard all returned values for just 1. 
		
		For e.g:
	
		```lua
		-- Server
		local Workspace = game:GetService("Workspace")
		
		local testRemoteProperty = network.Server.RemoteProperty.new(50, {
			clientGet = {
				function() return "rickrolled" end,
				function() return "oof" end,
				function() return "hello" end
			}
		})
	
		local testNetwork = network.Server.new("TestNetwork")
		testNetwork:append("property", testRemoteProperty)
		testNetwork:dispatch(Workspace)
	
		-- Client
		local Workspace = game:GetService("Workspace")
	
		local testNetwork = network.client.fromParent("TestNetwork", Workspace):expect()
		print(testNetwork.property:get()) --> {"oofed", "rickrolled", "hello"} 
		```
		:::
	]=]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local sharedEnums = require(script.Parent.Parent.sharedEnums)
local Trove = require(script.Parent.Parent.Parent.Trove)
local Connection = require(script.Parent.Parent.Parent.Connection)
local Signal = require(script.Parent.Parent.Parent.Signal)
local Property = require(script.Parent.Parent.Parent.Property)
local Sift = require(script.Parent.Parent.Parent.Sift)
local networkUtil = require(script.Parent.Parent.utilities.networkUtil)

local DEFAULT_REMOTE_PROPERTY_CONFIG = {
	automaticArgumentSerializationAndDeserializationEnabled = true,
}

local ClientSetRequestValidator = { Reject = "Reject " }

local defaultRemotePropertyMiddleware = {
	clientGet = {},
	clientSet = {
		-- To stop clients from messing around with their values by default, better
		-- for security.
		function(remoteProperty, client: Player, newValue)
			warn(
				string.format(
					'[%s]: Client "%s" attempted to set their value (new value: %s). Request has been rejected for security, please specify a "clientSet" middleware containing at least 1 function to allow this.',
					tostring(remoteProperty),
					client.Name,
					tostring(newValue)
				)
			)

			return ClientSetRequestValidator.Reject
		end,
	},
}

local remoteProperties = {}

local RemoteProperty = {
	ClientSetRequestValidator = ClientSetRequestValidator,
	__index = {},
}

--[=[
	@param remotePropertyConfig RemotePropertyConfig?
	@param middleware RemotePropertyMiddleware?

	Creates and returns a new remote property with the value of `initialValue`.
	
	- If the 2nd parameter `middleware` is not specified, then it will default to [DefaultRemotePropertyMiddleware] instead.
		
	- If the 3rd parameter `remotePropertyConfig` is not specified, then it will default to [DefaultRemotePropertyConfig] instead. 
]=]

function RemoteProperty.new(
	initialValue: any,
	middleware: {
		clientSet: { (remoteProperty: RemoteProperty, client: Player, value: any) -> any }?,
		clientGet: { (remoteProperty: RemoteProperty, client: Player) -> any }?,
	}?,
	remotePropertyConfig: {
		automaticArgumentSerializationAndDeserializationEnabled: boolean,
	}?
): RemoteProperty
	if middleware ~= nil then
		middleware = Sift.Dictionary.mergeDeep(defaultRemotePropertyMiddleware, middleware)
	else
		middleware = Sift.Dictionary.copyDeep(defaultRemotePropertyMiddleware)
	end

	if remotePropertyConfig ~= nil then
		remotePropertyConfig = Sift.Dictionary.mergeDeep(DEFAULT_REMOTE_PROPERTY_CONFIG, middleware)
	else
		remotePropertyConfig = Sift.Dictionary.copyDeep(DEFAULT_REMOTE_PROPERTY_CONFIG)
	end

	local property = Property.new(initialValue)
	local self = setmetatable({
		onUpdate = property.onUpdate,
		clientValueOnUpdate = Signal.new(),
		_property = property,
		_middleware = middleware,
		_clientProperties = {},
		_clientSettingValueRateLimits = {},
		_clientSettingValueRateLimitClocks = {},
		_clientsValueObservers = {},
		_trove = Trove.new(),
		_remotePropertyConfig = remotePropertyConfig,
	}, RemoteProperty)

	self:_init()
	return self
end

--[=[
	Returns a boolean indicating if `self` is a remote property or not.
]=]

function RemoteProperty.is(self: any): boolean
	return getmetatable(self) == RemoteProperty
end

--[=[
	@tag RemoteProperty instance

	Returns a shallow copy of the current value set for the remote property.
]=]

function RemoteProperty.__index:get(): any
	return self._property:get()
end

--[=[
	@tag RemoteProperty instance
	@return Promise<any>
	
	Returns a promise which is resolved with a non-nil value of the remote property, given
	that `valuePredicate` is not passed as an argument.
	
	```lua
	remoteProperty:valuePromise():andThen(function(value)
		print(value) 
	end)
	```
	
	`valuePredicate` can also be passed, which allows you to filter out values. If it returns
	exactly `true`, only then will the promise resolve with the new value.
	
	```lua
	remoteProperty:valuePromise(function(newValue, oldValue) 
		return newValue == 10 and oldValue == 1
	end):andThen(function(value)
		print(value) 
	end)
	
	remoteProperty:set(1) 
	remoteProperty:set(10) 
	
	--> 10
	```
]=]

function RemoteProperty.__index:valuePromise(
	valuePredicate: (newValue: any, oldValue: any?) -> boolean
)
	return self._property:valuePromise(valuePredicate)
end

--[=[
	@tag RemoteProperty instance
	
	Rate limits the given client setting their own value by `rateLimit` seconds.
	
	:::note
	This specific rate limit set for this client will be **removed**
	once the client leaves the game.
	:::
	
	```lua
	-- Server
	remoteProperty:setRateLimitForClientSettingValue(client, 30) -- 30 seconds
	
	-- Client
	clientRemoteProperty.onUpdate:Connect(function(newValue)
		print(newValue) 
	end)
	
	-- Spam the setting of value for the client, so we ought for the value of the 
	-- client stored in the remote property (finally) to be `100`, but instead
	-- it will be `1`, as subsequent calls after the first one will be ignored
	-- due to the rate limit imposed.
	for index = 1, 100 do
		clientRemoteProperty:set(index)
	end
	
	--> 1 
	```
]=]

function RemoteProperty.__index:setRateLimitForClientSettingValue(client: Player, rateLimit: number)
	self._clientSettingValueRateLimits[client] = rateLimit
end

--[=[
	@tag RemoteProperty instance
	
	Calls [RemoteProperty:setForClient] for all clients in `clients`.
]=]

function RemoteProperty.__index:setForClients(clients: { Player }, value: T)
	for _, client in clients do
		self:setForClient(client, value)
	end
end

--[=[
	@tag RemoteProperty instance
	
	Sets the value of the remote property for `client` *specifically*, to `value`. This client
	will now no longer be receiving updates of the value *of the* remote property, and thus will only
	be receiving updates of their own specific value set in the remote property.

	:::note
	[RemoteProperty:removeForClient] will be called for the given client whenever they leave the game, so
	that this value is cleared out for the player, and thus this helps prevent memory leaks.
	:::

	:::warning Precaution!
	- Setting the value for `client` to `nil` will **not** remove the client's value - call [RemoteProperty:removeForClient]
	to do that.

	- This method will throw an error if you attempt to set a value for the client who are not present anymore
	in the server (i.e not a descendant of [Players](https://create.roblox.com/docs/reference/engine/classes/Players))  - this is done to avoid memory leaks.
	:::
]=]

function RemoteProperty.__index:setForClient(client: Player, value: any)
	if not client:IsDescendantOf(Players) then
		error(
			string.format(
				'[%s]: Attempt to set value for client "%s" but they\'re not present in server!',
				tostring(self),
				client.Name
			)
		)
	end

	local clientProperty = self:_clientProperty(client)
	clientProperty:set(value)
end

--[=[
	@tag RemoteProperty instance
	
	Removes the value stored for `client` *specifically* in the remote property. This client will
	now be informed of the current value *of the* remote property and will now no longer be
	receiving updates of their specific value (that was previously set in the remote property, as
	it has been removed), instead the client will start receiving updates of the value of the remote
	property itself.
]=]

function RemoteProperty.__index:removeForClient(client: Player)
	if self._clientProperties[client] == nil then
		return
	end

	self._clientProperties[client]:destroy()
	self._clientProperties[client] = nil

	-- Send the current value of the remote property back to the client so that
	-- the client can recieve the update of their new value:
	networkUtil.safeInvokeClient(
		self._valueDispatcherRemoteFunction,
		client,
		networkUtil.serializeGivenArgs(self._valueDispatcherRemoteFunction, self:get())
	)
end

--[=[
	@tag RemoteProperty instance
	
	Iterates through `clients` and calls [RemoteProperty:removeForClient] for each client.
]=]

function RemoteProperty.__index:removeForClients(clients: { Player })
	for _, client in clients do
		self:removeForClient(client)
	end
end

--[=[
	@tag RemoteProperty instance
	
	Returns a boolean indicating if there is a specific value stored for `client` 
	in the remote property.
]=]

function RemoteProperty.__index:clientHasValueSet(client: Player): boolean
	return self._clientProperties[client] ~= nil
end

--[=[
	@tag RemoteProperty instance
	@return any 
	
	Returns a shallow copy of value stored *specifically* for `client` in the remote property. 
]=]

function RemoteProperty.__index:clientValue(client: Player)
	local clientProperty = self._clientProperties[client]
	return if clientProperty then clientProperty:get() else nil
end

--[=[
	@tag RemoteProperty instance
	@return Promise<any>
	
	Returns a promise which is resolved with a non-nil value of the value stored for the client in the remote property.
	
	```lua
	remoteProperty:clientValuePromise(client):andThen(function(value)
		print(value) 
	end)
	```
	
	`valuePredicate` (an optional predicate), allows you to filter out values:
	
	```lua
	remoteProperty:clientValuePromise(client, function(newValue, oldValue) 
		print(newValue, oldValue)
		return oldValue == 1
	end):andThen(function(value)
		print(value) 
	end)
	
	remoteProperty:setForClient(client, 1) 
	remoteProperty:setForClient(client, 2) 
	
	-- Output:
	-- 1, nil
	-- 2, 1
	-- 2
	```
]=]

function RemoteProperty.__index:clientValuePromise(
	client: Player,
	valuePredicate: (newValue: any, oldValue: any?) -> boolean
)
	local clientProperty = self:_clientProperty(client)
	return clientProperty:valuePromise(valuePredicate)
end

--[=[
	@tag RemoteProperty instance
	
	Sets the value of the remote property to `value`. Clients who have a specific value set
	will not be informed of this new value of this remote property.
]=]

function RemoteProperty.__index:set(value: any)
	self._property:set(value)
end

--[=[
	@tag RemoteProperty instance
	@return Signal
	
	Returns a signal that is fired whenever a value is set for the client, or the client's
	specific value is updated in the remote property (through [RemoteProperty:setForClient]).
	
	```lua
	remoteProperty:clientValueOnUpdateSignalForClient(somePlayer):Connect(function(newValue, oldValue)
		print(newValue, oldValue)
	end)
	
	remoteProperty:setForClient(somePlayer, 1)
	--> 1, nil
	```
]=]

function RemoteProperty.__index:clientValueOnUpdateSignalForClient(client: Player)
	local clientValueProperty = self:_clientProperty(client)
	return clientValueProperty.onUpdate
end

--[=[
	@tag RemoteProperty instance
	@return Connection
	
	Observes the value of the given client stored in the remote property.
	
	```lua
	remoteProperty:observeClientValue(somePlayer, function(newValue, oldValue)
		print(newValue, oldValue) 
	end)
	
	remoteProperty:setForClient(somePlayer, 1)
	--> nil, nil
	--> 1, nil
	```
]=]

function RemoteProperty.__index:observeClientValue(
	client: Player,
	callback: (newValue: any, oldValue: any?) -> ()
)
	local clientValueProperty = self:_clientProperty(client)
	return clientValueProperty:observe(callback)
end

--[=[
	@tag RemoteProperty instance
	@return Connection
	
	Observes the value of the remote property. 
	
	```lua
	local remoteProperty = RemoteProperty.new()
	remoteProperty:observe(function(newValue, oldValue)
		print(newValue, oldValue)
	end)
	
	remoteProperty:set(1)
	--> nil, nil
	--> 1, nil
	```
]=]

function RemoteProperty.__index:observe(callback: (newValue: any, oldValue: any?) -> ())
	return self._property:observe(callback)
end

--[=[
	@tag RemoteProperty instance
	@return Connection
	
	Observes the values set for clients in the remote property. 
	
	```lua
	local remoteProperty = RemoteProperty.new()
	remoteProperty:observeClientsValue(function(client: Player, newValue, oldValue)
	
	end)
	```
]=]

function RemoteProperty.__index:observeClientsValue(observer: (
	player: Player,
	newValue: any,
	oldValue: any?
) -> ()): Connection.Connection
	table.insert(self._clientsValueObservers, observer)

	return Connection.new(function()
		local index = table.find(self._clientsValueObservers, observer)
		if index ~= nil then
			table.remove(self._clientsValueObservers, index)
		end
	end)
end

--[=[
	@tag RemoteProperty instance
		
	Destroys the remote property and renders it unusable. All clients who have a specific value
	set for themselves in the remote property will be removed through [RemoteProperty:removeForClient].
]=]

function RemoteProperty.__index:destroy()
	self._trove:Destroy()
end

function RemoteProperty.__index:dispatch(name, parent)
	local valueDispatcherRemoteFunction: RemoteFunction =
		self._trove:Add(self._valueDispatcherRemoteFunction)
	valueDispatcherRemoteFunction:SetAttribute(sharedEnums.Attribute.BoundToRemoteProperty, true)
	valueDispatcherRemoteFunction.Name = name

	local function clientGetMiddlewareResponses(client: Player)
		return networkUtil.serializeGivenArgs(
			valueDispatcherRemoteFunction,
			networkUtil.truncateAccumulatedResponses(
				self._middleware.clientGet,
				networkUtil.accumulatedResponseFromMiddlewareCallbacks(
					self._middleware.clientGet,
					self,
					client
				)
			)
		)
	end

	function valueDispatcherRemoteFunction.OnServerInvoke(client, setData)
		-- If the client has sent a set data, then that means they want to set
		-- their value specifically in the remote property, so let's handle that:
		if setData ~= nil then
			if typeof(setData) ~= "table" then
				return false
			end

			local playerSpecificRateLimit = self._clientSettingValueRateLimits[client] or 0
			local lastClientRateLimitClock = self._clientSettingValueRateLimitClocks[client] or 0

			if
				(Workspace:GetServerTimeNow() - lastClientRateLimitClock)
				< playerSpecificRateLimit
			then
				return false
			end

			self._clientSettingValueRateLimitClocks[client] = Workspace:GetServerTimeNow()
			setData =
				networkUtil.deserializeAndUnpackArgs(self._valueDispatcherRemoteFunction, setData)
			local clientSetMiddlewareAccumulatedResponses, clientSetMiddlewareResponsesAreValid =
				networkUtil.truncateAccumulatedResponses(
					self._middleware.clientSet,
					networkUtil.accumulatedResponseFromMiddlewareCallbacks(
						self._middleware.clientSet,
						self,
						client,
						setData.value
					)
				)

			if clientSetMiddlewareResponsesAreValid then
				if typeof(clientSetMiddlewareAccumulatedResponses) == "table" then
					if
						table.find(
							clientSetMiddlewareAccumulatedResponses,
							RemoteProperty.ClientSetRequestValidator.Reject
						) ~= nil
					then
						return false
					end
				elseif
					clientSetMiddlewareAccumulatedResponses
					== RemoteProperty.ClientSetRequestValidator.Reject
				then
					return false
				end

				self:setForClient(client, clientSetMiddlewareAccumulatedResponses)
			end

			return { value = setData.value, valueGuiId = setData.valueGuiId }
		end

		local retrievedClientGetMiddlewareResponses, clientGetMiddlewareResponsesAreValid =
			clientGetMiddlewareResponses(client)
		if clientGetMiddlewareResponsesAreValid then
			return retrievedClientGetMiddlewareResponses
		end

		return networkUtil.serializeGivenArgs(
			valueDispatcherRemoteFunction,
			if self:clientHasValueSet(client) then self:clientValue(client) else self:get()
		)
	end

	valueDispatcherRemoteFunction.Parent = parent

	self._property.onUpdate:Connect(function(newValue)
		local serializedNewValue =
			networkUtil.serializeGivenArgs(valueDispatcherRemoteFunction, newValue)

		for _, client in Players:GetPlayers() do
			if self:clientHasValueSet(client) then
				-- If the client already has a value set for them specifically,
				-- then we must not send this new value to them to avoid bugs.
				continue
			end

			local clientGetMiddlewareAccumulatedResponses, clientGetMiddlewareResponsesAreValid =
				clientGetMiddlewareResponses(client)

			networkUtil.safeInvokeClient(
				valueDispatcherRemoteFunction,
				client,
				if clientGetMiddlewareResponsesAreValid
					then clientGetMiddlewareAccumulatedResponses
					else serializedNewValue
			)
		end
	end)
end

function RemoteProperty.__index:_clientProperty(client)
	if self._clientProperties[client] ~= nil then
		return self._clientProperties[client]
	end

	local property = Property.new()
	property.onUpdate:Connect(function(newValue, oldValue)
		for _, clientValueObserver in self._clientsValueObservers do
			task.spawn(clientValueObserver, client, newValue, oldValue)
		end

		self.clientValueOnUpdate:Fire(client, newValue)
		networkUtil.safeInvokeClient(
			self._valueDispatcherRemoteFunction,
			client,
			networkUtil.serializeGivenArgs(self._valueDispatcherRemoteFunction, newValue)
		)
	end)

	self._clientProperties[client] = property
	return property
end

function RemoteProperty.__index:_init()
	self._valueDispatcherRemoteFunction = self._trove:Add(Instance.new("RemoteFunction"))
	self._valueDispatcherRemoteFunction:SetAttribute(
		sharedEnums.Attribute.AutomaticRemoteArgumentSerializationAndDeserializationEnabled,
		self._remotePropertyConfig.automaticArgumentSerializationAndDeserializationEnabled
	)
	self._valueDispatcherRemoteFunction:SetAttribute(
		sharedEnums.Attribute.RemotePropertyHadContainedInitialValue,
		self:get() ~= nil
	)
	self._trove:Add(self.clientValueOnUpdate)
	self._trove:Add(self._property)
	self._trove:Add(function()
		for client in self._clientProperties do
			self:removeForClient(client)
		end

		remoteProperties[self] = nil
		setmetatable(self, nil)
	end)
	remoteProperties[self] = self
end

function RemoteProperty.__index:_cleanupForClient(client)
	self._clientSettingValueRateLimits[client] = nil
	self._clientSettingValueRateLimitClocks[client] = nil
	self:removeForClient(client)
end

function RemoteProperty:__tostring()
	return string.format("[RemoteProperty]: (%s)", self._valueDispatcherRemoteFunction.Name)
end

Players.PlayerRemoving:Connect(function(player)
	for _, remoteProperty in remoteProperties do
		remoteProperty:_cleanupForClient(player)
	end
end)

export type RemoteProperty = typeof(RemoteProperty.new(nil))

return table.freeze(RemoteProperty)
