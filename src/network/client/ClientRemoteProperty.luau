--[=[
	@class ClientRemoteProperty
	@client

	The clientside counterpart of [RemoteProperty]. A client remote property 
	in layman's terms is just an object connected to a remote property.
]=]

--[=[ 
	@prop onUpdate Signal <newValue: any, oldValue: any>
	@within ClientRemoteProperty
	@tag Read only
	@tag Signal
	@tag ClientRemoteProperty instance

	A [signal](https://sleitnick.github.io/RbxUtil/api/Signal/) which is fired, whenever the value 
	of the remote property (or the value of the client stored in the remote property)
	is updated.
	
	Incase the client has a specific value set for them in the remote property, then this signal
	will only fire if *that* value has been updated.
]=]

--[=[ 
	@type ClientRemoteProperty ClientRemoteProperty
	@within ClientRemoteProperty
]=]

local HttpService = game:GetService("HttpService")

local sharedEnums = require(script.Parent.Parent.sharedEnums)
local Property = require(script.Parent.Parent.Parent.Property)
local Trove = require(script.Parent.Parent.Parent.Trove)
local Promise = require(script.Parent.Parent.Parent.Promise)
local networkUtil = require(script.Parent.Parent.utilities.networkUtil)

local ClientRemoteProperty = { __index = {} }

function ClientRemoteProperty.new(remoteFunction)
	local property = Property.new()
	local self = setmetatable({
		onUpdate = property.onUpdate,
		_property = property,
		_trove = Trove.new(),
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

	Returns the value of the client stored in the remote property. If there is no value stored specifically for the client, 
	then the remote property's current value will be returned instead.
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

	Returns a promise which is resolved with a non-nil value of the client remote property, given
	that `valuePredicate` is not passed as an argument.

	```lua
	clientRemoteProperty:valuePromise():andThen(function(value)
		print(value) 
	end)
	```

	`valuePredicate` can ALSO be passed, which allows you to filter out values. If it returns
	exactly `true`, only then will the promise resolve with the new value.

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
	@tag Deprecated
	
	Invokes the remote property, to set the value for the client to `value`.

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
	warn(
		string.format(
			"[ClientRemoteProperty:setPromise] has been deprecated as of 8/29/2024. \n\t%s",
			debug.traceback()
		)
	)

	task.spawn(
		self._remoteFunction.InvokeServer,
		self._remoteFunction,
		networkUtil.serializeGivenArgs(self._remoteFunction, { value = value })
	)
end

--[=[
	@tag ClientRemoteProperty instance
	@tag Deprecated
	@return Promise<any>

	Works the same as [ClientRemoteProperty:set], but returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved **when**
	the server has set the value for the client to `value`, or else rejects with a `nil value`. Additionally, the returned promise 
	resolves with the value that was set. If this method is called againand the returned promise had not yet finished, then the old 
	promise returned will be cancelled.

	:::note Precaution
	This method performs a shallow check (`self:get() == value`) before informing the server to actually
	set the value. This is an attempt to avoid sending unnecessary requests to the server. For e.g:

	```lua
	local thisValue = {1,2,3}
	clientRemoteProperty:setPromise(thisValue):expect() -- Assuming this is successful....
	warn(clientRemoteProperty:setPromise(thisValue):expect()) -- Does not inform the server, immediately returns a resolved promise!
	```
	:::

	:::warning Possible Promise rejection
	This promise can also be rejected **with a nil value** if the server declines the client's request of setting the value for the client
	in the remote property. This behavior will be seen by default, if the remote property has no `clientSet` middleware - see [DefaultRemotePropertyMiddleware]
	and [RemotePropertyMiddleware] for more info.

	```lua
	-- Client
	clientRemoteProperty:setPromise(10):andThen(function(newValue)
		-- Success!
		print(newValue) --> 10
	end):catch(function()
		-- Server rejected the request
	end)
	```
	:::
]=]

function ClientRemoteProperty.__index:setPromise(value: any)
	warn(
		string.format(
			"[ClientRemoteProperty:setPromise] has been deprecated as of 8/29/2024. \n\t%s",
			debug.traceback()
		)
	)

	if self._valueSetPromises[value] ~= nil then
		self._valueSetPromises[value]:cancel()
	end

	if self:get() == value then
		return Promise.resolve(self:get())
	end

	local valueSetPromise = self._trove:AddPromise(Promise.new(function(resolve, reject)
		local valueGuiId = HttpService:GenerateGUID()
		local response =
			self._remoteFunction:InvokeServer(networkUtil.serializeGivenArgs(self._remoteFunction, {
				value = value,
				valueGuiId = valueGuiId,
			}))

		if typeof(response) == "table" and response.valueGuiId == valueGuiId then
			-- The server returned to us a table containing the value and a gui id,
			-- which means the client informed the server to set a value for the
			-- client, and the server accepted this request, thus from this info,
			-- we know this. Resolve pending value set promises
			resolve(response.value)
		else
			reject(nil)
		end
	end))

	self._valueSetPromises[value] = valueSetPromise
	valueSetPromise
		:finally(function()
			if self._valueSetPromises[value] == valueSetPromise then
				self._valueSetPromises[value] = nil
			end
		end)
		:catch(function() end)
	return valueSetPromise
end

--[=[
	@tag ClientRemoteProperty instance

	Destroys the client remote property and renders it unusable.
]=]

function ClientRemoteProperty.__index:destroy()
	self._trove:Destroy()
end

function ClientRemoteProperty.__index:_init()
	local remoteFunction = self._remoteFunction
	local internalPropertyValueSet = false

	local function setInternalPropertyValue(newValue: any)
		internalPropertyValueSet = true
		newValue = networkUtil.deserializeAndUnpackArgs(remoteFunction, newValue)

		if typeof(newValue) == "table" and newValue.valueGuiId ~= nil then
			-- The server returned to us a table containing the value and a gui id,
			-- which means the client informed the server to set a value for the
			-- client, and the server accepted this request, thus from this info,
			-- we know this!
			self._property:set(newValue.value)
		else
			self._property:set(newValue)
		end
	end

	local function retrieveInitialValue()
		local newValue = self._remoteFunction:InvokeServer()
		-- In case a new value was set already while we were retrieving the initial
		-- value, don't update the value of the property to avoid unexpected behavior!
		if internalPropertyValueSet then
			return
		end

		if newValue ~= nil then
			setInternalPropertyValue(newValue)
		end
	end

	function remoteFunction.OnClientInvoke(newValue)
		setInternalPropertyValue(newValue)
	end

	self._trove:Add(self._property)
	self._trove:Add(function()
		self._remoteFunction.OnClientInvoke = nil
		setmetatable(self, nil)
	end)

	-- If the remote property contained some initial value when being dispatched to the
	-- client, let's wait for the client to retrieve that initial value so that the client
	-- has guaranteed access to it as this is the expected behavior.

	-- EDGECASE(s): Now, it is possible that the client may already have value specifically set for them
	-- OR some middleware may have  set (resulting in no value being returned from the server for e.g) -
	-- in such cases, we don't really have to wait for some value from the server but there is no good enough
	-- way to know that, but that's ok :).
	if
		self._remoteFunction:GetAttribute(
			sharedEnums.Attribute.RemotePropertyHadContainedInitialValue
		)
	then
		retrieveInitialValue()
	else
		task.spawn(retrieveInitialValue)
	end
end

function ClientRemoteProperty:__tostring()
	return string.format("[ClientRemoteProperty]: (%s)", self._remoteFunction.Name)
end

export type ClientRemoteProperty = typeof(ClientRemoteProperty.new())

return table.freeze(ClientRemoteProperty)
