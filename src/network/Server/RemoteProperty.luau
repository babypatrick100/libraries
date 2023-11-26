--[=[
	@class RemoteProperty

	A remote property in layman's terms is simply an  object which can store some value for 
	all players as well as store in values specific to players. 
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

	By default, `clientSet` contains a function which always returns either the value set for the client, or the value
	of the remote property, back to the client. This is to stop the remote property from listening to the clients request
	to set their value, as this is a security risk, if by default, this behavior is allowed. Additionally, a warn is also
	produced in the output to let you know of this.

	The default middleware template is defined as follows:

	```lua
	local DEFAULT_MIDDLEWARE_TEMPLATE = {
		clientSet = {
			function(remoteProperty, client: Player, newValue) 
				warn(
					string.format(
						'[%s]: Client "%s" attempted to set their value (new value: %s). Request has been rejected for security, please specify a "clientSet" middleware containing at least 1 function to allow this.',
							tostring(remoteProperty),
							client.Name,
							tostring(newValue)
						)
					)
					return if remoteProperty:clientHasValueSet(client)
						then remoteProperty:clientValue(client)
						else remoteProperty:get()
				end
			},
			clientGet = {}
		}
		```
	
		In order to allow clients to request the server to set their value, then you must define a middleware where `clientSet` contains
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
		@interface RemoteSignalConfig 
		@within RemoteProperty
		.automaticArgumentSerializationAndDeserializationEnabled boolean -- determines whether or not values sent to clients by the remote signal be internally serialized/deserialized or not.
	
		- `automaticArgumentSerializationAndDeserializationEnabled` -> `true`
			- Arguments and values sent across the network by the remote property 
			will be automatically serialized and deserialized respectively, with the
			help of an internal library, i.e [serializerUtil](https://bub.github.io/libraries/api/serializerUtil/).
	
			::note Serialization and deserialization limitations!
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
		@prop onUpdate Signal <newValue: any, oldValue: any?>
		@within RemoteProperty
		@tag Read only
		@tag Signal
		@tag RemoteProperty Instance
	
		A [signal](https://sleitnick.github.io/RbxUtil/api/Signal/) which is fired whenever the value 
		of the remote property is set to a new one. The signal is only passed the new value as the only argument.
	]=]
	
	--[=[ 
		@prop clientValueOnUpdate Signal <client: Player, newValue: any, oldValue: any?>
		@within RemoteProperty
		@tag Read only
		@tag Signal
		@tag RemoteProperty Instance
	
		A [signal](https://sleitnick.github.io/RbxUtil/api/Signal/) which is fired whenever the value 
		of `player` specifically in the remote property is set to a new one. The signal is passed the player 
		as the first argument, and the new specific value of `player` set in the remote property, as the second argument. 
	]=]
	
	--[=[ 
		@type RemoteProperty RemoteProperty<T> 
		@within RemoteProperty
	]=]
	
	--[=[ 
		@type RemotePropertyOnUpdateCallback (newValue: any, oldValue: any) -> ()
		@within RemoteProperty
	]=]
	
	--[=[ 
		@type RemotePropertyValuePredicate (newValue: any, oldValue: any) -> boolean
		@within RemoteProperty
	]=]
	
	--[=[
		@interface RemotePropertyMiddleware
		@within RemoteProperty
		.clientSet { (client: Player, value: any) -> any }?,
		.clientGet { (client: Player) -> any }?,
	
		`clientSet` and `clientGet` must be an array of callbacks, if specified.
	
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
		which is followed by the client object and the value the client is trying to set.
	
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
	
	local networkFolder = script.Parent.Parent
	local packages = networkFolder.Parent
	
	local sharedEnums = require(networkFolder.sharedEnums)
	local sharedTypes = require(networkFolder.sharedTypes)
	local Janitor = require(packages.Janitor)
	local Signal = require(packages.Signal)
	local Property = require(packages.Property)
	local Sift = require(packages.Sift)
	local networkUtil = require(networkFolder.utilities.networkUtil)
	
	local DEFAULT_MIDDLEWARE_TEMPLATE = {
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
				return if remoteProperty:clientHasValueSet(client)
					then remoteProperty:clientValue(client)
					else remoteProperty:get()
			end,
		},
	}
	local DEFAULT_CONFIG_TEMPLATE = {
		automaticArgumentSerializationAndDeserializationEnabled = true,
	}
	
	local remoteProperties = {}
	
	local RemoteProperty = { __index = {} }
	
	type RemotePropertyOnUpdateCallback = (newValue: any, oldValue: any) -> ()
	type RemotePropertyMiddleware<T> = {
		clientSet: { (remoteProperty: RemoteProperty<T>, client: Player, value: any) -> any }?,
		clientGet: { (remoteProperty: RemoteProperty<T>, client: Player) -> any }?,
	}
	type RemotePropertyConfig = typeof(DEFAULT_CONFIG_TEMPLATE)
	type RemotePropertyValuePredicate = (newValue: any, oldValue: any) -> boolean
	
	--[=[
		Creates and returns a new remote property with the value of `initialValue`.
	
		- If the 2nd parameter `middleware` is not specified, then it will default to [DefaultRemotePropertyMiddleware] instead.
		
		- If the 3rd parameter `config` is not specified, then it will default to [DefaultRemotePropertyConfig] instead. 
	]=]
	
	function RemoteProperty.new<T>(
		initialValue: T,
		middleware: RemotePropertyMiddleware<T>?,
		config: RemotePropertyConfig?
	): RemoteProperty<T>
		if middleware ~= nil then
			middleware = Sift.Dictionary.mergeDeep(DEFAULT_MIDDLEWARE_TEMPLATE, middleware)
		else
			middleware = Sift.Dictionary.copyDeep(DEFAULT_MIDDLEWARE_TEMPLATE)
		end
		if config ~= nil then
			config = Sift.Dictionary.mergeDeep(DEFAULT_CONFIG_TEMPLATE, middleware)
		else
			config = Sift.Dictionary.copyDeep(DEFAULT_CONFIG_TEMPLATE)
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
			_janitor = Janitor.new(),
			_config = config,
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
		@return any 
	
		Returns a shallow copy of the current value set for the remote property.
	]=]
	
	function RemoteProperty.__index:get()
		return self._property:get()
	end
	
	--[=[
		@tag RemoteProperty instance
		@return Promise<any>
	
		Returns a promise which is resolved with a non-nil value of the remote property.
	
		```lua
		remoteProperty:valuePromise():andThen(function(value)
			print(value) 
		end)
		```
	
		`valuePredicate` (an optional predicate), allows you to filter out values:
	
		```lua
		remoteProperty:valuePromise(function(newValue, oldValue) 
			print(newValue, oldValue)
			return oldValue == 1
		end):andThen(function(value)
			print(value) 
		end)
	
		remoteProperty:set(1) 
		remoteProperty:set(2) 
	
		-- Output:
		-- 1, nil
		-- 2, 1
		-- 2
		```
	]=]
	
	function RemoteProperty.__index:valuePromise(valuePredicate: RemotePropertyValuePredicate?)
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
	
	function RemoteProperty.__index:setForClients(clients: { Player }, value: any)
		for _, client in clients do
			self:setForClient(client, value)
		end
	end
	
	--[=[
		@tag RemoteProperty instance
	
		Calls [RemoteProperty:bulkSetForClient] for all clients in `clients`.
	]=]
	
	function RemoteProperty.__index:bulkSetForClients(clients: { Player }, value: any)
		for _, client in clients do
			self:bulkSetForClient(client, value)
		end
	end
	
	--[=[
		@tag RemoteProperty instance
	
		Sets the value of the remote property for `client` *specifically*, to `value`. This client
		will now no longer be receiving updates of the value *of the* remote property, and thus will only
		be receiving updates of their own specific value set in the remote property.
	
		:::warning Precaution!
		- Setting the value for `client` to `nil` will **not** remove the client's value - call [RemoteProperty:removeForClient]
		to do that.
		:::
	
		:::warning Potential Memory Leak!
		- A new internal [Property]() object will be created for the given client to house this specific
		value - make sure to call [RemoteProperty:removeForClient] -- (when the client leaves the game or when
		you no longer need the specific value), for memory cleaning.
	
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
	
		Works the same as [RemoteProperty.setForClient], but does not inform the client of this new value
		set for them (this **does not** mean the client will not have access to this new value, but instead
		the client will not receive a signal that their value updated - they can still access this value manually
		through [ClientRemoteProperty:get].
	
		:::warning Precaution!
		Setting the value for `client` to `nil` will **not** remove the client's value - call [RemoteProperty:removeForClient]
		to do that.
		:::
	
		:::warning Potential Memory Leak!
		- A new internal [Property]() object will be created for the given client to house this specific
		value - make sure to call [RemoteProperty:removeForClient] -- (when the client leaves the game or when
		you no longer need the specific value), for memory cleaning.
	
		- This method will throw an error if you attempt to set a value for the client who are not present anymore
		in the server (i.e not a descendant of [Players](https://create.roblox.com/docs/reference/engine/classes/Players)) - this is done to avoid memory leaks.
		:::
	]=]
	
	function RemoteProperty.__index:bulkSetForClient(client: Player, value: any)
		if not client:IsDescendantOf(Players) then
			error(
				string.format(
					'[%s]: Attempt to set bulk value for client "%s" but they\'re not present in server!',
					tostring(self),
					client.Name
				)
			)
		end
	
		local clientProperty = self:_clientProperty(client)
		clientProperty:bulkSet(value)
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
	
		Returns a shallow copy of value stored *specifically* for `client` in the remote property. 
	]=]
	
	function RemoteProperty.__index:clientValue(client: Player): any
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
		valuePredicate: RemotePropertyValuePredicate?
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
	
		Works the same as [RemoteProperty:set] but does not fire off any on update signals.
	]=]
	
	function RemoteProperty.__index:bulkSet(value: any)
		self._property:bulkSet(value)
	end
	
	--[=[
		@tag RemoteProperty instance
		@return Signal
	
		Returns a signal that is fired whenever a value is set for the client, or the client's
		specific value is updated in the remote property.
	
		```lua
		remoteProperty:clientValueOnUpdateSignalForClient(somePlayer):Connect(function(newValue, oldValue)
			print(newValue, oldValue) 							
		end)
	
		remoteProperty:setForClient(somePlayer, 1)
		--> nil, nil
		--> 1, nil
		```
	]=]
	
	function RemoteProperty.__index:clientValueOnUpdateSignalForClient(client: Player)
		local clientValueProperty = self:_clientProperty(client)
		return clientValueProperty.onUpdate
	end
	
	--[=[
		@tag RemoteProperty instance
		@return RBXScriptConnection
	
		Observes the value of the given client stored in the remote property.
	
		```lua
		remoteProperty:observeClientValue(somePlayer, function(newValue, oldValue)
			print(newValue, oldValue) --> 1, nil
		end)
	
		remoteProperty:setForClient(somePlayer, 1)
		--> nil, nil
		--> 1, nil
		```
	]=]
	
	function RemoteProperty.__index:observeClientValue(
		client: Player,
		callback: RemotePropertyOnUpdateCallback
	)
		local clientValueProperty = self:_clientProperty(client)
		return clientValueProperty:observe(callback)
	end
	
	--[=[
		@tag RemoteProperty instance
		@return RBXScriptConnection
	
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
	
	function RemoteProperty.__index:observe(callback: RemotePropertyOnUpdateCallback)
		return self._property:observe(callback)
	end
	
	--[=[
		@tag RemoteProperty instance
		
		Destroys the remote property and renders it unusable. All clients who have a specific value
		set for themselves in the remote property will be removed through [RemoteProperty:removeForClient].
	]=]
	
	function RemoteProperty.__index:destroy()
		self._janitor:Destroy()
	end
	
	--[=[
		@private
	]=]
	
	function RemoteProperty.__index:dispatch(name: string, parent: Instance)
		local valueDispatcherRemoteFunction: RemoteFunction =
			self._janitor:Add(self._valueDispatcherRemoteFunction)
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
	
		function valueDispatcherRemoteFunction.OnServerInvoke(client, setData: any)
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
				setData = networkUtil.deserializeAndUnpack(self._valueDispatcherRemoteFunction, setData)
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
					-- This check is necessary, as it is possible that the response
					-- accumulated from `clientSet` middlewares is the same as the
					-- current value of the client (but with a different reference),
					-- so we want to avoid unnecessary updates.
					-- This will happen as a result of the default `clientSet` middleware..
					if
						not Sift.Dictionary.equals(
							clientSetMiddlewareAccumulatedResponses,
							self:clientValue(client)
						)
					then
						self:setForClient(client, clientSetMiddlewareAccumulatedResponses)
					end
	
					return false
				end
	
				self:_bulkSetForClientRaw(client, setData.value, {
					value = setData.value,
					valueGuiId = setData.valueGuiId,
				})
	
				return true
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
	
		-- Send off the new value to the current players in game:
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
	
	--[=[
		@private
	]=]
	
	function RemoteProperty.__index:_bulkSetForClientRaw(client: Player, value: any, rawData: any)
		networkUtil.safeInvokeClient(
			self._valueDispatcherRemoteFunction,
			client,
			networkUtil.serializeGivenArgs(self._valueDispatcherRemoteFunction, rawData)
		)
		self:bulkSetForClient(client, value)
	end
	
	--[=[
		@private
	]=]
	
	function RemoteProperty.__index:_clientProperty(client: Player)
		if self._clientProperties[client] then
			return self._clientProperties[client]
		end
	
		local property = Property.new()
		property.onUpdate:Connect(function(newValue)
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
	
	--[=[
		@private
	]=]
	
	function RemoteProperty.__index:_init()
		self._valueDispatcherRemoteFunction = self._janitor:Add(Instance.new("RemoteFunction"))
		self._valueDispatcherRemoteFunction:SetAttribute(
			sharedEnums.Attribute.AutomaticArgumentSerializationAndDeserializationEnabled,
			self._config.automaticArgumentSerializationAndDeserializationEnabled
		)
		self._janitor:Add(self.clientValueOnUpdate)
		self._janitor:Add(self._property, "destroy")
		self._janitor:Add(function()
			for client in self._clientProperties do
				self:removeForClient(client)
			end
	
			remoteProperties[self] = nil
			setmetatable(self, nil)
		end)
		remoteProperties[self] = self
	end
	
	--[=[
		@private
	]=]
	
	function RemoteProperty:__tostring()
		return string.format("[RemoteProperty]: (%s)", self._valueDispatcherRemoteFunction.Name)
	end
	
	Players.PlayerRemoving:Connect(function(player)
		for _, remoteProperty in remoteProperties do
			remoteProperty._clientSettingValueRateLimits[player] = nil
			remoteProperty._clientSettingValueRateLimitClocks[player] = nil
		end
	end)
	
	export type RemoteProperty<T> = typeof(setmetatable(
		{} :: {
			onUpdate: sharedTypes.Signal,
			_property: Property.Property<T>,
			_janitor: sharedTypes.Janitor,
			_middleware: RemotePropertyMiddleware<T>,
			_config: RemotePropertyConfig,
			_clientProperties: { [Player]: Property.Property<T> },
			clientValueOnUpdate: sharedTypes.Signal,
		},
		RemoteProperty
	))
	
	return table.freeze(RemoteProperty)
	