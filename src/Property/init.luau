--[=[ 
	@class Property

	A class for wrapping values around setters and getters. A property in layman's terms is simply an object which contains some value.
 
	```lua
	local property = Property.new(5)
	print(property:get()) --> 5

	property.onUpdate:Connect(function(newValue, oldValue)
		print(newValue, oldValue) --> 10, 5
	end)

	property:set(10) 
	```
]=]

--[=[ 
	@prop onUpdate Signal <newValue: any, oldValue: any>
	@within Property
	@readonly
	@tag Signal
	@tag Property Instance

	A [signal](https://sleitnick.github.io/RbxUtil/api/Signal/) which is fired whenever the value of the property is 
	set to a new one. The signal is only passed the new value as the only argument.
]=]

--[=[ 
	@type Property Property<T> 
	@within Property
]=]

local Signal = require(script.Parent.Signal)
local Trove = require(script.Parent.Trove)
local Promise = require(script.Parent.Promise)

local Property = {}
Property.__index = {}

type Signal = typeof(Signal.new())
type Trove = typeof(Trove.new())

--[=[
	@return Property

	A constructor method that creates a new property object, with `initialValue` as the current value
	of the property.
]=]

function Property.new<T>(initialValue: T?): Property<T>
	local trove = Trove.new()
	local self = setmetatable({
		onUpdate = trove:Add(Signal.new()),
		_value = initialValue,
		_trove = Trove.new(),
	}, Property)

	trove:Add(function()
		setmetatable(self, nil)
	end)

	return self
end

--[=[
	A method that returns a boolean indicating if `self` is a property or not.
]=]

function Property.is(self: any): boolean
	return getmetatable(self) == Property
end

--[=[
	Binds the property to a property of the given Roblox instance. When the instance is destroyed,
	the property is automatically destroyed as well.

	```lua
	local property = Property.new()
	property:bindToRobloxProperty(workspace.Baseplate, "Transparency")

	property.onUpdate:Connect(function(newTransparency, oldTransparency)
		print(newTransparency, oldTransparency) --> 1, 0
	end)

	print(property:get()) --> 0

	workspace.Baseplate.Transparency = 1

	-- Deferred signal behavior: (Roblox instance-signals are not immediately fired)
	print(property.onUpdate:Wait()) --> 1
	```
]=]

function Property.__index:bindToRobloxProperty(instance: Instance, property: string)
	self:bulkSet(instance[property])

	self._trove:Add(instance:GetPropertyChangedSignal(property):Connect(function()
		self:set(instance[property])
	end))
end

--[=[
	Binds the property to an attribute of the given Roblox instance. When the instance is destroyed,
	the property is automatically destroyed as well.

	```lua
	local property = Property.new()
	property:bindToInstanceAttribute(workspace.Baseplate, "SomeAttribute")

	print(property:get()) --> nil

	workspace.Baseplate:SetAttribute("SomeAttribute", 5)

	print(property:get()) --> 5
	```
]=]

function Property.__index:bindToInstanceAttribute(instance: Instance, attribute: string)
	self:bulkSet(instance:GetAttribute(attribute))

	self._trove:Add(instance:GetAttributeChangedSignal(attribute):Connect(function()
		self:set(instance:GetAttribute(attribute))
	end))
end

--[=[
	Binds the property to an instance so that once the instance is destroyed,
	the property will be destroyed too.

	```lua
	local property = Property.new()
	property:bindToInstance(workspace.Baseplate)

	 print(Property.is(property)) --> true

	workspace.Baseplate:Destroy()

	task.wait() -- Deferred signal behavior

	print(Property.is(property)) --> false
	```
]=]

function Property.__index:bindToInstance(instance: Instance)
	self._trove:Add(instance.Destroying:Connect(function()
		self:destroy()
	end))
end

--[=[
	Sets the value of the property to `value`, if this new value isn't the same as the previous value. 
]=]

function Property.__index:set(value: any)
	local oldValue = self._value

	if oldValue == value then
		return
	end

	self._value = value
	self.onUpdate:Fire(value, oldValue)
end

--[=[
	Observes the value of the property. 

	```lua
	property:observe(function(newValue, oldValue)

	end)
	```
]=]

function Property.__index:observe(callback: (newValue: any, oldValue: any) -> ())
	task.defer(function()
		local initialValue = self:get()
		if initialValue ~= nil then
			callback(initialValue, nil)
		end
	end)

	return self.onUpdate:Connect(callback)
end

--[=[
	Returns a promise which is resolved with a non-nil value of the property.

	```lua
	local property = Property.new()

	property:valuePromise():andThen(function(value)
		print(value) --> 2
	end)

	property:set(2)
	```

	`valuePredicate` (an optional predicate), allows you to filter out values:

	```lua
	local property = Property.new()

	property:valuePromise(function(newValue, oldValue) 
		print(newValue, oldValue)
		return oldValue == "no"
	end):andThen(function(value)
		print(value) --> "yes"
	end)

	property:set("no") 
	property:set("yes") 

	-- Output:
	-- "no", nil
	-- "yes", "no"
	-- "yes"
	```
]=]

function Property.__index:valuePromise(valuePredicate: ((newValue: any, oldValue: any) -> boolean)?)
	return Promise.new(function(resolve)
		if valuePredicate ~= nil then
			local lastValue
			while valuePredicate(self:get(), lastValue) ~= true do
				lastValue = self:get()
				self.onUpdate:Wait()
			end
		end

		while self:get() == nil do
			self.onUpdate:Wait()
		end

		resolve(self:get())
	end)
end

--[=[
	@tag Property Instance

	Works the same as [Property:set] except that tables aren't checked for equality, for e.g:

	```lua
	local property = Property.new()

	property.onUpdate:Connect(function(newVal)
		warn(newVal) --> {1}
	end)

	local t = {1}

	property:forceSet(t) --> Fires off the .onUpdate signal (expected)

	-- This ought to not fire off the signal, but the previous and new value
	-- aren't checked for equality since they're both tables)
	property:forceSet(t) 

	-- Fires off the .onUpdate signal (expected as a number ~= table) 
	property:forceSet(1) 

	-- Does NOT fire off the .onUpdate signal, since the previous value 
	-- (a number, not a table) and the new value (a number, not a table) are the
	-- same!
	property:forceSet(1) 
	```
]=]

function Property.__index:forceSet(value: any)
	local oldValue = self._value

	if oldValue == value and typeof(value) == "table" and typeof(oldValue) == "table" then
		return
	end

	self._value = value
	self.onUpdate:Fire(value, oldValue)
end

--[=[
	Works almost the same as [Property:set], but never fires off the [Property.onUpdate] signal.
]=]

function Property.__index:bulkSet(value: any)
	self._value = value
end

--[=[
	@return any
	Returns a shallow copy of the current value of the property.

	```lua
	local property = Property.new()

	local t = {}
	property:set(t)
	print(property:get() == t) --> false
	```
]=]

function Property.__index:get()
	return if typeof(self._value) == "table" then table.clone(self._value) else self._value
end

--[=[
	Destroys the property and renders it unusable.
]=]

function Property.__index:destroy()
	self._trove:Destroy()
	setmetatable(self, nil)
end

function Property:__tostring()
	return string.format("[Property]: (%s)", tostring(self._value))
end

export type Property<T> = typeof(setmetatable(
	{} :: {
		onUpdate: Signal,
		_value: T,
		_trove: Trove,
	},
	Property
))

return table.freeze(Property)
