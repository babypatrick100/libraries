--[=[ 
	@class propertyUtil

	A utility module for working with the [Property](https://babypatrick100.github.io/libraries/api/Property/) class.
]=]

local Property = require(script.Parent.Property)

local propertyUtil = {}

local function ensurePropertyValueIsCorrect(property)
	if typeof(property:get()) ~= "number" then
		error(
			string.format(
				"%s has invalid value type (expected %s, got %s instead)",
				tostring(property),
				"number",
				typeof(property:get())
			)
		)
	end
end

--[=[ 
    Increments the given `property`'s value by 1.
]=]

function propertyUtil.increment(property: Property.Property<number>)
	-- Incase the property has been destroyed (usually in an edgecase).
	if not Property.is(property) then
		return
	end

	ensurePropertyValueIsCorrect(property)
	property:set(property:get() + 1)
end

--[=[ 
    Decrements the given `property`'s value by 1 though clamping the `property`'s value such
    that it does not become less than `0`.
]=]

function propertyUtil.decrement(property: Property.Property<number>)
	-- Incase the property has been destroyed (usually in an edgecase).
	if not Property.is(property) then
		return
	end

	ensurePropertyValueIsCorrect(property)
	property:set(math.max(property:get() - 1, 0))
end

return table.freeze(propertyUtil)
