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

local networkFolder = script.Parent.Parent
local packages = script.Parent.Parent.Parent
local utilities = script.Parent.Parent.utilities

local sharedTypes = require(networkFolder.sharedTypes)
local Property = require(packages.Property)
local Janitor = require(packages.Janitor)
local networkUtil = require(utilities.networkUtil)

local ClientRemoteProperty = { __index = {} }

--[=[
	@private
]=]

function ClientRemoteProperty.new(remoteFunction: RemoteFunction): ClientRemoteProperty
	local property = Property.new()
	local self = setmetatable({
		onUpdate = property.onUpdate,
		_property = property,
		_janitor = Janitor.new(),
		_remoteFunction = remoteFunction,
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
]=]

function ClientRemoteProperty.__index:set(value: any)
	task.spawn(self._remoteFunction.InvokeServer, self._remoteFunction, { value = value })
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

function ClientRemoteProperty.__index:dispatcherRemoteInstance()
	return self._remoteFunction
end

function ClientRemoteProperty.__index:_init()
	local remoteFunction = self._remoteFunction

	function remoteFunction.OnClientInvoke(newValue)
		self._property:set(networkUtil.deserializeAndUnpack(remoteFunction, newValue))
	end

	self._janitor:Add(self._property, "destroy")
	self._janitor:Add(function()
		self._remoteFunction.OnClientInvoke = nil
		setmetatable(self, nil)
	end)

	local newValue = self._remoteFunction:InvokeServer()

	-- In case a new value was set while we were retrieving the initial value, don't
	-- update the value of the property to avoid unexpected behavior!
	if self:get() == nil and newValue ~= nil then
		self._property:set(networkUtil.deserializeAndUnpack(remoteFunction, newValue))
	end
end

function ClientRemoteProperty:__tostring()
	return string.format("[ClientRemoteProperty]: (%s)", self._remoteFunction.Name)
end

export type ClientRemoteProperty = typeof(setmetatable(
	{} :: {
		onUpdate: sharedTypes.Signal,
		_property: Property.Property<any>,
		_janitor: sharedTypes.Janitor,
		_remoteFunction: RemoteFunction,
	},
	ClientRemoteProperty
))

return table.freeze(ClientRemoteProperty)
