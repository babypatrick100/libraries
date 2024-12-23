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
	@type Property Property
	@within Property
]=]

local Signal = require(script.Parent.Signal)
local Trove = require(script.Parent.Trove)
local Promise = require(script.Parent.Promise)

local Property = {}
Property.__index = {}

local function defaultPropertyValueMapper(newValue)
	return newValue
end

--[=[
	@return Property

	A constructor method that creates a new property object, with `initialValue` as the current value
	of the property.
]=]

function Property.new(initialValue: any)
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
	@tag Property Instance
	
	Creates a new property and binds it to the current property, and returns the new
	property. The new property will operate on the value of the current property, however
	you may specify a `mapper` function for more control. The `mapper` function will be 
	passed the new value and the old value of the current property (and when the current
	property is updated), the return value of the mapper will be the new value of the new
	property.
	
	The new property will be automatically destroyed once the current prpoerty is destroyed.

	```lua
	local property = Property.new(5)
	local anotherProperty = property:clone(function(number)
		return number + 5
	end)

	print(anotherProperty:get()) --> 10
	property:set(10)
	print(anotherProperty:get()) --> 15
	```
]=]

function Property.__index:clone(mapper: ((newValue: any, oldValue: any) -> any)?)
	mapper = mapper or defaultPropertyValueMapper

	local newProperty = self._trove:Add(Property.new())
	newProperty:silentSet(mapper(self:get(), nil))
	self._trove:Add(self.onUpdate:Connect(function(...)
		newProperty:set(mapper(...))
	end))

	return newProperty
end

--[=[
	@tag Property Instance

	Binds the property to a property of the given Roblox instance. When the instance is destroyed,
	the property is automatically destroyed as well.

	```lua
	local property = Property.new()
	property:bindToInstanceProperty(workspace.Baseplate, "Transparency")

	property.onUpdate:Connect(function(newTransparency, oldTransparency)
		print(newTransparency, oldTransparency) --> 1, 0
	end)

	print(property:get()) --> 0

	workspace.Baseplate.Transparency = 1

	-- Deferred signal behavior: (Roblox instance-signals are not immediately fired)
	print(property.onUpdate:Wait()) --> 1
	```
]=]

function Property.__index:bindToInstanceProperty(instance: Instance, property: string)
	self:silentSet(instance[property])

	self._trove:Add(instance:GetPropertyChangedSignal(property):Connect(function()
		self:set(instance[property])
	end))
end

--[=[
	@tag Property Instance

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
	self:silentSet(instance:GetAttribute(attribute))

	self._trove:Add(instance:GetAttributeChangedSignal(attribute):Connect(function()
		self:set(instance:GetAttribute(attribute))
	end))
end

--[=[
	@tag Property Instance

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
	@tag Property Instance

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
	@tag Property Instance

	Observes the value of the property. 

	```lua
	property:observe(function(newValue, oldValue)

	end)
	```
]=]

function Property.__index:observe(callback: (newValue: any, oldValue: any) -> ())
	task.defer(function()
		if not Property.is(self) then
			return
		end

		local initialValue = self:get()
		if initialValue ~= nil then
			callback(initialValue, nil)
		end
	end)

	return self.onUpdate:Connect(callback)
end

--[=[
	@tag Property Instance

	Returns a promise which is resolved with a non-nil value of the property, given that
	`valuePredicate` is not passed as an argument.

	```lua
	local property = Property.new()

	property:valuePromise():andThen(function(value)
		print(value) --> 2
	end)

	property:set(2)
	```

	`valuePredicate` can also be passed, which allows you to filter out values. If it returns
	exactly `true`, only then will the promise resolve with the new value.

	```lua
	property:valuePromise(function(newValue, oldValue) 
		return newValue == 10 and oldValue == 1
	end):andThen(function(newValue)
		print(newValue) 
	end)
	
	property:set(1) 
	property:set(10) 
	--> 10
	```

	:::note
	The returned promise will be cancelled as soon as the property object is destroyed.
	:::

	@return Promise 
]=]

function Property.__index:valuePromise(valuePredicate: ((newValue: any, oldValue: any) -> boolean)?)
	return self._trove:AddPromise(Promise.new(function(resolve)
		if valuePredicate ~= nil then
			local lastValue = nil

			while true do
				local currentValue = self:get()
				if currentValue ~= nil then
					-- We need to check for `self:get() == currentValue` as it is possible
					-- that the property may have been updated while `valuePredicate` was
					-- running (incase `valuePredicate` yielded), otherwise we won't be able
					-- to run the predicate for the latest value!
					if
						valuePredicate(currentValue, lastValue) == true
						and self:get() == currentValue
					then
						resolve(currentValue)
						return
					end

					lastValue = currentValue
				end

				self.onUpdate:Wait()
			end
		else
			while self:get() == nil do
				self.onUpdate:Wait()
			end

			resolve(self:get())
		end
	end))
end

--[=[
	@tag Property Instance

	Works the same as [Property:set] except that values aren't checked for equality, for e.g:

	```lua
	local property = Property.new()

	property.onUpdate:Connect(function(newValue)
		print(newValue) 
	end)
	property:forceSet(1) 
	property:forceSet(2) 
	property:forceSet("a") 
	
	--> 1
	--> 2
	--> "a"
	```
]=]

function Property.__index:forceSet(value: any)
	local oldValue = self._value
	self._value = value
	self.onUpdate:Fire(value, oldValue)
end

--[=[
	@tag Property Instance

	Works almost the same as [Property:set], but never fires off the [Property.onUpdate] signal.
]=]

function Property.__index:silentSet(value: any)
	self._value = value
end

--[=[
	Returns a shallow copy of the current value of the property.

	```lua
	local property = Property.new()

	local t = {}
	property:set(t)
	print(property:get() == t) --> false
	```
]=]

function Property.__index:get(): any
	return if typeof(self._value) == "table" then table.clone(self._value) else self._value
end

--[=[
	@tag Property Instance

	Destroys the property and renders it unusable.
]=]

function Property.__index:destroy()
	self._trove:Destroy()
	setmetatable(self, nil)
end

function Property:__tostring()
	return string.format("[Property]: (%s)", tostring(self._value))
end

export type Property = typeof(Property.new())

return table.freeze(Property)
