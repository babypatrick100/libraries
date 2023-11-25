--[=[
	@class RemoteProperty

	A remote property in layman's terms is simply an  object which can store some value for 
	all players as well as store in values specific to players. 
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
	@interface Middleware
	@within RemoteProperty
	.clientSet { (client: Player, value: any) -> any }?,
	.clientGet { (client: Player) -> any }?,

	`clientSet` and `clientGet` must be an array of callbacks, if specified.

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

	:::warning Yielding is not allowed
	Middleware callbacks aren't allowed to yield. If they do so, their thread will be closed and an error will be outputted.
	:::
	
	:::tip More control
	A `clientSet` callback can return a **non-nil** value, which will then be set as the value for the client in the remote property.
	This is useful in cases where you want to have more control over what values the client can set for them in the remote
	property.
	
	For e.g:

	```lua
	-- Server
	local Workspace = game:GetService("Workspace")
	
	local testRemoteProperty = Network.Server.RemoteProperty.new(50, {
		clientSet = {function() return "rickrolled" end}
	})

	local testNetwork = Network.Server.new("TestNetwork")
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
	
	local testRemoteProperty = Network.Server.RemoteProperty.new(50, {
		clientSet = {
			function() return "rickrolled" end,
			function() return "oof" end,
			function() return "hello" end
		}
	})

	local testNetwork = Network.Server.new("TestNetwork")
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

	:::warning Yielding is not allowed
	Middleware callbacks aren't allowed to yield. If they do so, their thread will be closed and an error will be outputted, but
	other callbacks will not be affected.
	:::
	
	:::tip More control
	A callback can return a non-nil value, which will then be returned to the client. This is useful in cases where you want to
	have more control over what values the client can retrieve from the remote property.
	
	For e.g:

	```lua
	-- Server
	local Workspace = game:GetService("Workspace")
	
	local testRemoteProperty = Network.Server.RemoteProperty.new(5000, {
		clientGet = {function() return "rickrolled" end}
	})

	local testNetwork = Network.Server.new("TestNetwork")
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
	
	local testRemoteProperty = Network.Server.RemoteProperty.new(50, {
		clientGet = {
			function() return "rickrolled" end,
			function() return "oof" end,
			function() return "hello" end
		}
	})

	local testNetwork = Network.Server.new("TestNetwork")
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
	clientSet = {},
}

local RemoteProperty = { __index = {} }

type Middleware<T> = {
	clientSet: { (remoteProperty: RemoteProperty<T>, client: Player, value: any) -> any? }?,
	clientGet: { (remoteProperty: RemoteProperty<T>, client: Player) -> any? }?,
}

--[=[
	@return RemoteProperty
	@param middleware Middleware?

	Creates and returns a new remote property with the value of `initialValue`.
]=]

function RemoteProperty.new<T>(initialValue: T, middleware: Middleware?): RemoteProperty<T>
	if middleware ~= nil then
		middleware = Sift.Dictionary.mergeDeep(middleware, DEFAULT_MIDDLEWARE_TEMPLATE)
	else
		middleware = Sift.Dictionary.copyDeep(DEFAULT_MIDDLEWARE_TEMPLATE)
	end

	local property = Property.new(initialValue)
	local self = setmetatable({
		onUpdate = property.onUpdate,
		clientValueOnUpdate = Signal.new(),
		_property = property,
		_middleware = middleware,
		_clientProperties = {},
		_janitor = Janitor.new(),
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

function RemoteProperty.__index:valuePromise(
	valuePredicate: ((newValue: any, oldValue: any) -> boolean)?
)
	return self._property:valuePromise(valuePredicate)
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

	Sets the value of the remote property for `client` *specifically*, to `value`. 
		
	:::note Precaution!
	- [Argument limitations](https://create.roblox.com/docs/scripting/events/argument-limitations-for-bindables-and-remotes)
	apply, as remote functions are internally used to render `value` accessible to the respective clients.

	- Setting the value for `client` to `nil` will **not** remove the client's value -- call [RemoteProperty:removeForClient]
	to do that.
	:::
]=]

function RemoteProperty.__index:setForClient(client: Player, value: any)
	local clientProperty = self:_clientProperty(client)
	clientProperty:set(value)
end

--[=[
	@tag RemoteProperty instance

	Works the same as [RemoteProperty.setForClient], but does not inform the client of the new value.
		
	:::note Precaution!
	- [Argument limitations](https://create.roblox.com/docs/scripting/events/argument-limitations-for-bindables-and-remotes)
	apply, as remote functions are internally used to render `value` accessible to the respective clients.

	- Setting the value for `client` to `nil` will **not** remove the client's value -- call [RemoteProperty:removeForClient]
	to do that.
	:::
]=]

function RemoteProperty.__index:bulkSetForClient(client: Player, value: any)
	local clientProperty = self:_clientProperty(client)
	clientProperty:bulkSet(value)
end

--[=[
	@tag RemoteProperty instance

	Removes the value stored for `client` *specifically* in the remote property.
]=]

function RemoteProperty.__index:removeForClient(client: Player)
	if not self._clientProperties[client] then
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

	Calls [RemoteProperty:removeForClient] for all clients in the `clients` table.
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
	valuePredicate: ((newValue: any, oldValue: any) -> boolean)?
)
	local clientProperty = self:_clientProperty(client)
	return clientProperty:valuePromise(valuePredicate)
end

--[=[
	@tag RemoteProperty instance

	Sets the value of the remote property to `value`.

	:::note Precaution!
	[Argument limitations](https://create.roblox.com/docs/scripting/events/argument-limitations-for-bindables-and-remotes)
	apply, as remote functions are internally used to render `value` accessible to the respective clients.
	:::
]=]

function RemoteProperty.__index:set(value: any)
	self._property:set(value)
end

--[=[
	@tag RemoteProperty instance

	Works the same as [RemoteProperty:set] but does not fire off any update signals.
]=]

function RemoteProperty.__index:bulkSet(value: any)
	self._property:bulkSet(value)
end

--[=[
	@tag RemoteProperty instance
	@return Signal

	Returns a signal that is fired whenever a value is updated for the given client.

	```lua
	remoteProperty:clientValueOnUpdateSignalForClient(somePlayer):Connect(function(newValue, oldValue)
										
	end)
	```
]=]

function RemoteProperty.__index:clientValueOnUpdateSignalForClient(client: Player)
	local clientValueProperty = self:_clientProperty(client)
	return clientValueProperty.onUpdate
end

--[=[
	@tag RemoteProperty instance
	@return RBXScriptConnection

	Observes the value for the given client.

	```lua
	remoteProperty:observeClientValue(somePlayer, function(newValue, oldValue)
		
	end)
	```
]=]

function RemoteProperty.__index:observeClientValue(
	client: Player,
	callback: (newValue: any, oldValue: any) -> ()
)
	local clientValueProperty = self:_clientProperty(client)
	return clientValueProperty:observe(callback)
end

--[=[
	@tag RemoteProperty instance
	@return RBXScriptConnection

	Observes the value of the remote property. 

	```lua
	remoteProperty:observe(function(newValue, oldValue)
		
	end)
	```
]=]

function RemoteProperty.__index:observe(callback: (newValue: any, oldValue: any?) -> ())
	return self._property:observe(callback)
end

--[=[
	@tag RemoteProperty instance
	
	Destroys the remote property and renders it unusable.
]=]

function RemoteProperty.__index:destroy()
	self._janitor:Destroy()
end

--[=[
	@private
]=]

function RemoteProperty.__index:dispatcherRemoteInstance()
	return self._valueDispatcherRemoteFunction
end

--[=[
	@private
]=]

function RemoteProperty.__index:dispatch(name: string, parent: Instance)
	local valueDispatcherRemoteFunction: RemoteFunction = self._valueDispatcherRemoteFunction
	valueDispatcherRemoteFunction:SetAttribute(sharedEnums.Attribute.BoundToRemoteProperty, true)
	valueDispatcherRemoteFunction.Name = name
	valueDispatcherRemoteFunction.Parent = parent

	self._janitor:Add(function()
		valueDispatcherRemoteFunction:Destroy()
	end)

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
		if typeof(setData) == "table" then
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
				self:setForClient(
					client,
					networkUtil.serializeGivenArgs(
						valueDispatcherRemoteFunction,
						clientSetMiddlewareAccumulatedResponses
					)
				)
				return nil
			end

			self:setForClient(client, setData.value)
			return nil
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

			if clientGetMiddlewareResponsesAreValid then
				networkUtil.safeInvokeClient(
					valueDispatcherRemoteFunction,
					client,
					clientGetMiddlewareAccumulatedResponses
				)
			else
				networkUtil.safeInvokeClient(
					valueDispatcherRemoteFunction,
					client,
					serializedNewValue
				)
			end
		end
	end)
end

function RemoteProperty.__index:_clientProperty(client: Player)
	if self._clientProperties[client] then
		return self._clientProperties[client]
	end

	local property = Property.new()

	property.onUpdate:Connect(function(newValue)
		if not client:IsDescendantOf(Players) then
			return
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
	self._valueDispatcherRemoteFunction = self._janitor:Add(Instance.new("RemoteFunction"))
	self._janitor:Add(self.clientValueOnUpdate)
	self._janitor:Add(self._property, "destroy")
	self._janitor:Add(function()
		for _, property in self._clientProperties do
			property:destroy()
		end

		self._clientProperties = nil
		setmetatable(self, nil)
	end)
end

function RemoteProperty:__tostring()
	return string.format("[RemoteProperty]: (%s)", self._valueDispatcherRemoteFunction.Name)
end

export type RemoteProperty<T> = typeof(setmetatable(
	{} :: {
		onUpdate: Property.Property<T>,
		_property: Property.Property<T>,
		_janitor: sharedTypes.Janitor,
		_middleware: Middleware<T>,
		_clientProperties: { [Player]: Property.Property<any> },
		clientValueOnUpdate: sharedTypes.Signal,
	},
	RemoteProperty
))

return table.freeze(RemoteProperty)
