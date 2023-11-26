--[=[
	@class ClientRemoteProperty

	The clientside counterpart of [RemoteProperty]. A client remote property 
	in layman's terms is just an object connected to a serverside remote property.
]=]

--[=[ 
	@prop onUpdate Signal <newValue: any>
	@within ClientRemoteProperty
	@tag Read only
	@tag Signal
	@tag ClientRemoteProperty instance

	A [signal](https://sleitnick.github.io/RbxUtil/api/Signal/) which is fired, whenever the value 
	of the serverside remote property (to which this client remote property is connected) is updated.
	
	Incase the client has a specific value set for them in the serverside remote property, then this signal
	will only fire if *that* value has been updated.
]=]

--[=[ 
	@type ClientRemoteProperty ClientRemoteProperty
	@within ClientRemoteProperty
]=]

local HttpService = game:GetService("HttpService")

local networkFolder = script.Parent.Parent
local packages = script.Parent.Parent.Parent
local utilities = script.Parent.Parent.utilities

local sharedTypes = require(networkFolder.sharedTypes)
local Property = require(packages.Property)
local Janitor = require(packages.Janitor)
local Promise = require(packages.Promise)
local networkUtil = require(utilities.networkUtil)

local ClientRemoteProperty = { __index = {} }

--[=[
	@private
]=]

function ClientRemoteProperty.new<T>(remoteFunction: RemoteFunction): ClientRemoteProperty<T>
	local property = Property.new()
	local self = setmetatable({
		onUpdate = property.onUpdate,
		_property = property,
		_janitor = Janitor.new(),
		_rawProperty = Property.new(),
		_remoteFunction = remoteFunction,
		_valueSetPromises = {},
	}, ClientRemoteProperty)

	self:_init()
	return self
end

--[=[
	Returns a boolean indicating if `self` is a client remote property or not.
]=]

function ClientRemoteProperty.is(self: any): boolean
	return getmetatable(self) == ClientRemoteProperty
end

--[=[
	@tag ClientRemoteProperty instance
	@return any

	Returns the value of the client stored in the serverside remote property (to which the client remote property is connected to).
	If there is no value stored specifically for the client, then the serverside remote property's current value will be returned
	instead.
]=]

function ClientRemoteProperty.__index:get()
	return self._property:get()
end

--[=[
	@tag ClientRemoteProperty instance

	Observes the value of the client remote property. 

	```lua
	clientRemoteProperty:observe(function(newValue, oldValue)
		
	end)
	```
]=]

function ClientRemoteProperty.__index:observe(callback: (newValue: any, oldValue: any) -> ())
	return self._property:observe(callback)
end

--[=[
	@tag ClientRemoteProperty instance

	Returns a promise which is resolved with a non-nil value of the client remote property.

	```lua
	clientRemoteProperty:valuePromise():andThen(function(value)
		print(value) 
	end)
	```

	`valuePredicate` (an optional predicate), allows you to filter out values:

	```lua
	clientRemoteProperty:valuePromise(function(newValue, oldValue) 
		print(newValue, oldValue)
		return oldValue == 1
	end):andThen(function(value)
		print(value) 
	end)

	clientRemoteProperty:set(1) 
	clientRemoteProperty:set(2) 

	-- Output:
	-- 1, nil
	-- 2, 1
	-- 2
	```
]=]

function ClientRemoteProperty.__index:valuePromise(
	valuePredicate: ((newValue: any, oldValue: any) -> boolean)?
)
	return self._property:valuePromise(valuePredicate)
end

--[=[
	@tag ClientRemoteProperty instance
	
	Invokes the serverside remote property (to which this client remote propert is connected to), to set the value for the client to `value`.

	:::warning Possible rate limit
	It is possible that the client may be rate limited by the server (see [RemoteProperty:setRateLimitForClientSettingValue]), and thus
	requests to the server to set the value for the client can possibly be ignored by the server.

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
	:::

	:::warning Possible Value Set Request Rejection From Server
	The server can decline the client's request of setting the value for the client in the remote property. This behavior
	will be seen by default, if the remote property has no `clientSet` middleware - see [DefaultRemotePropertyMiddleware] 
	and [RemotePropertyMiddleware] for more info.
	:::
]=]

function ClientRemoteProperty.__index:set(value: any)
	task.spawn(
		self._remoteFunction.InvokeServer,
		self._remoteFunction,
		networkUtil.serializeGivenArgs(self._remoteFunction, { value = value })
	)
end

--[=[
	@tag ClientRemoteProperty instance
	@tag Advanced
	@return Promise

	Works the same as [ClientRemoteProperty:set], but returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved once
	the server has set the value for the client to `value`. 
	
	:::note
	Calling this method for the same exact value **again** before the old promise has settled 
	will simply result in the old promise to return. This is to avoid sending unnecessary
	requests to the server.

	```lua
	local promiseA = clientRemoteProperty:setPromise(10) 
	local promiseB = clientRemoteProperty:setPromise(10) -- Will not send another request to the server, old promise is returned

	print(promiseA:getStatus()) --> "Started"
	print(promiseA == promiseB) --> true
	```
	:::

	:::warning Possible Promise rejection
	This promise can also be rejected **with a nil value** if the server declines the client's request of setting the value for the client
	in the remote property. This behavior will be seen by default, if the serverside remote property  has  no `clientSet`
	middleware - see [DefaultRemotePropertyMiddleware] and [RemotePropertyMiddleware] for more info.
	:::

	```lua
	-- Client
	clientRemoteProperty:setPromise(10):andThen(function()
		-- Success!
		print(clientRemoteProperty:get()) --> 10
	end):catch(function()
		-- Server rejected the request
	end)
	```
]=]

function ClientRemoteProperty.__index:setPromise(value: any)
	if self._valueSetPromises[value] then
		return self._valueSetPromises[value]
	end

	local valueGuiId = HttpService:GenerateGUID()
	local rawPropertyOnUpdateConnection
	local valueSetPromise = self._janitor:Add(
		Promise.new(function(resolve, reject)
			task.defer(function()
				local wasSuccessful = self._remoteFunction:InvokeServer(
					networkUtil.serializeGivenArgs(self._remoteFunction, {
						value = value,
						valueGuiId = valueGuiId,
					})
				)

				if not wasSuccessful then
					reject(nil)
				end
			end)

			rawPropertyOnUpdateConnection = self._rawProperty.onUpdate:Connect(function(newValue)
				if typeof(newValue) == "table" and newValue.valueGuiId == valueGuiId then
					-- The server returned to us a table containing the value and a gui id,
					-- which means the client informed the server to set a value for the
					-- client, and the server accepted this request, thus from this info,
					-- we know this. Resolve pending value set promises
					resolve()
				end
			end)
		end),
		"cancel"
	)

	self._valueSetPromises[value] = valueSetPromise
	valueSetPromise
		:finally(function()
			self._valueSetPromises[value] = nil
			rawPropertyOnUpdateConnection:Disconnect()
		end)
		:catch(function() end)
	return valueSetPromise
end

--[=[
	@tag ClientRemoteProperty instance

	Destroys the client remote property and renders it unusable.
]=]

function ClientRemoteProperty.__index:destroy()
	self._janitor:Destroy()
end

--[=[
	@private
]=]

function ClientRemoteProperty.__index:_init()
	local remoteFunction = self._remoteFunction
	local internalPropertyValueSet = false

	local function setInternalPropertyValue(newValue: any)
		internalPropertyValueSet = true
		newValue = networkUtil.deserializeAndUnpack(remoteFunction, newValue)

		if typeof(newValue) == "table" and newValue.valueGuiId ~= nil then
			-- The server returned to us a table containing the value and a gui id,
			-- which means the client informed the server to set a value for the
			-- client, and the server accepted this request, thus from this info,
			-- we know this!
			self._property:set(newValue.value)
		else
			self._property:set(newValue)
		end

		self._rawProperty:set(newValue)
	end

	function remoteFunction.OnClientInvoke(newValue)
		setInternalPropertyValue(newValue)
	end

	self._janitor:Add(self._rawProperty, "destroy")
	self._janitor:Add(self._property, "destroy")
	self._janitor:Add(function()
		self._remoteFunction.OnClientInvoke = nil
		setmetatable(self, nil)
	end)

	task.spawn(function()
		local newValue = self._remoteFunction:InvokeServer()

		-- In case a new value was set already while we were retrieving the initial
		-- value, don't update the value of the property to avoid unexpected behavior!
		if not internalPropertyValueSet and newValue ~= nil then
			setInternalPropertyValue(newValue)
		end
	end)
end

--[=[
	@private
]=]

function ClientRemoteProperty:__tostring()
	return string.format("[ClientRemoteProperty]: (%s)", self._remoteFunction.Name)
end

export type ClientRemoteProperty<T> = typeof(setmetatable(
	{} :: {
		onUpdate: sharedTypes.Signal,
		_property: Property.Property<T>,
		_janitor: sharedTypes.Janitor,
		_remoteFunction: RemoteFunction,
	},
	ClientRemoteProperty
))

return table.freeze(ClientRemoteProperty)
