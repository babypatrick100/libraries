--[=[ 
	@class ValueMultiplier

	A very simple class for working with value multipliers.
]=]

--[=[ 
	@prop DEFAULT_MULTIPLIER 1
	@tag Constant
	@within ValueMultiplier

	:::warning Not Accessible
	Constant, not accesible within `ValueMultiplier`.
	:::
]=]

local Promise = require(script.Parent.Promise)
local Signal = require(script.Parent.Signal)

local DEFAULT_MULTIPLIER = 1

local valueMultipliers = {}
local onValueMultiplierCreated = Signal.new()

local ValueMultiplier = {}
ValueMultiplier.__index = ValueMultiplier

--[=[ 
	@tag ValueMultiplier Instance

	Creates and returns a new value multiplier object. If `multiplier` is not specified, it'll default to
	[ValueMultiplier.DEFAULT_MULTIPLIER].

	```lua
	local valueMultiplier = ValueMultiplier.new("Test", 16, 16)

	print(valueMultiplier:updatedValue()) --> 16
	valueMultiplier:setMultiplier(2)
	print(valueMultiplier:updatedValue()) --> 32
	```

	:::warning
	This method will throw an error if `value` is `nil` - it must be specified as a number.
	:::

	@return ValueMultiplier
]=]

function ValueMultiplier.new(
	identifier: any,
	value: number,
	baseValue: number?,
	multiplier: number?
)
	assert(value ~= nil, "Value cannot be nil!")

	local self = setmetatable({
		_baseValue = baseValue,
		_value = value,
		_multiplier = multiplier or DEFAULT_MULTIPLIER,
		_identifier = identifier,
	}, ValueMultiplier)

	self:_init()
	return self
end

--[=[ 
	Returns the value multiplier object of identifier `identifier`, if there is any.
]=]

function ValueMultiplier.fromIdentifier(identifier: any): ValueMultiplier?
	return valueMultipliers[identifier]
end

--[=[ 
	Promisified version of [ValueMultiplier.fromIdentifier].

	@return Promise<ValueMultiplier>
]=]

function ValueMultiplier.fromIdentifierPromise(identifier: any)
	return Promise.new(function(resolve)
		while ValueMultiplier.fromIdentifier(identifier) == nil do
			onValueMultiplierCreated:Wait()
		end

		resolve(ValueMultiplier.fromIdentifier(identifier))
	end)
end

--[=[ 
	@tag ValueMultiplier Instance
	@return Connection
	
	Observes for a new value multiplier created under the given `identifier`. If one
	already exists, then `observer` will be called for it initially.

	```lua
	local valueMultiplier = ValueMultiplier.new("test", 0)

	ValueMultiplier.observeForIdentifier("test", function(newValueMultiplier)
		print(newValueMultiplier:baseValue())
	end)

	valueMultiplier:destroy()
	ValueMultiplier.new("test", 5)

	--> 0
	--> 5
	```
]=]

function ValueMultiplier.observeForIdentifier(
	identifier: any,
	observer: (newValueMultiplier: ValueMultiplier) -> ()
): Signal.Connection
	local onValueMultiplierCreatedConnection = onValueMultiplierCreated:Connect(
		function(valueMultiplier)
			if valueMultiplier:identifier() == identifier then
				observer(valueMultiplier)
			end
		end
	)

	if ValueMultiplier.fromIdentifier(identifier) ~= nil then
		task.spawn(observer, ValueMultiplier.fromIdentifier(identifier))
	end

	return onValueMultiplierCreatedConnection
end

--[=[ 
	@tag ValueMultiplier Instance

	Returns the current value of the value multiplier adjusted based off of the multiplier and
	the base value. If no base value is set, then just the current value will be returned instead.

	```lua
	
	local valueMultiplier = ValueMultiplier.new(player, 16)

	print(valueMultiplier.updatedValue()) --> 16, as no base value is set

	valueMultiplier:setMultiplier(2)

	print(valueMultiplier.updatedValue()) --> Still 16, as no base value is set
	valueMultiplier:setBaseValue(16)
	print(valueMultiplier:updatedValue()) --> 32
	```
]=]

function ValueMultiplier.__index:updatedValue(): number
	local multiplier = self:multiplier()
	local baseValue = self:baseValue()

	if baseValue == nil then
		return self._value
	end

	local difference = (baseValue * multiplier) - self._value
	return self._value + difference
end

--[=[ 
   @tag ValueMultiplier Instance

   Sets the value multiplier's value to `newValue`.
]=]

function ValueMultiplier.__index:setValue(newValue: number)
	self._value = newValue
end

--[=[ 
   @tag ValueMultiplier Instance

   Sets the value multiplier's base value to `baseValue`.
]=]

function ValueMultiplier.__index:setBaseValue(baseValue: number)
	self._baseValue = baseValue
end

--[=[ 
	@tag ValueMultiplier Instance

	Sets the value multiplier's multiplier to `newMultiplier`.
]=]

function ValueMultiplier.__index:setMultiplier(newMultiplier: number)
	self._multiplier = newMultiplier
end

--[=[ 
   @tag ValueMultiplier Instance

   Returns the multiplier set for the value multiplier.
]=]

function ValueMultiplier.__index:multiplier(): number
	return self._multiplier
end

--[=[ 
	@tag ValueMultiplier Instance

	Returns the base value of the value multiplier.
]=]

function ValueMultiplier.__index:baseValue(): number?
	return self._baseValue
end

--[=[ 
	@tag ValueMultiplier Instance

	Destroys the value multiplier and renders it unusable.
]=]

function ValueMultiplier.__index:destroy()
	valueMultipliers[self._identifier] = nil
	setmetatable(self, nil)
end

function ValueMultiplier.__index:_init()
	valueMultipliers[self._identifier] = self
	onValueMultiplierCreated:Fire(self)
end

export type ValueMultiplier = typeof(ValueMultiplier.new({}, 0))

return table.freeze(ValueMultiplier)
