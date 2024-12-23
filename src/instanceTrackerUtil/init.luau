--[=[ 
	@class instanceTrackerUtil
	
	A simple utility module for working with instances and their properties.

	:::note
	This utility works in conjuction with the [Property] class.
	:::

	```lua
	-- Example type writer effect
	local name = Property.new("newText")

	instanceTrackerUtil.setProps(textLabel, {
		Name = instanceTrackerUtil.bind(name, function(name) 
			local goalLength = string.len(name)
			local timeToTake = goalLength / 30
			local accumulated = 0

			return function(updatedName)
				if timeToTake < accumulated then return nil end

				accumulated += RunService.Heartbeat:Wait()
				return string.sub(name, 1, math.floor((accumulated / timeToTake) * goalLength))
			end
		end)
	})
	```
]=]

--[=[ 
	@interface TransformerBinder
	@within instanceTrackerUtil
	
	.property Property,
	.transformer (newValue: any, oldValue: any?) -> any,
	.__propertyTransformer true,
]=]

local Property = require(script.Parent.Property)
local Connection = require(script.Parent.Connection)

local PROPERTY_TRANSFORMER_MEMBER = "__propertyTransformer"

local cleanupCallbacks = {}
local trackedInstances = {}

local instanceTrackerUtil = {}

local function isTransformerBinder(value)
	return typeof(value) == "table" and value[PROPERTY_TRANSFORMER_MEMBER] == true
end

local function applyTransformedValue(instance, instanceProperty, transformedValue, property)
	if typeof(transformedValue) == "Instance" and transformedValue:IsA("Tween") then
		transformedValue:Play()

		return Connection.new(function()
			transformedValue:Cancel()
		end)
	else
		if typeof(transformedValue) == "function" then
			local lastValue = nil

			local loopThread = task.defer(function()
				while true do
					local newTransformedValue = transformedValue(property:get(), lastValue)
					lastValue = property:get()

					if newTransformedValue == nil then
						break
					end

					instance[instanceProperty] = newTransformedValue
					property:silentSet(newTransformedValue)
				end
			end)

			return Connection.new(function()
				task.cancel(loopThread)
			end)
		else
			instance[instanceProperty] = transformedValue
		end
	end

	return nil
end

--[=[ 
	Starts tracking the given instance so that the utility can easily cleanup once this instance is untracked. The 
	`cleanupCallback` is called `instanceTrackerUtil.untrack` is called on the instance.

	```lua
	instanceTrackerUtil.track(screenGui.Frame, function(frame)
		frame:TweenPosition(UDim2.fromScale(1, 0))
	end)
	```
]=]

function instanceTrackerUtil.track(
	instance: Instance,
	cleanupCallback: ((instance: Instance) -> ())?
)
	if cleanupCallback ~= nil then
		cleanupCallbacks[instance] = cleanupCallback
	end

	trackedInstances[instance] = { propConnections = {} }
end

--[=[ 
	Returns a transformer binder, to be used by `instanceTrackerUtil.setProps`,
	the value of `property` is wrapped onto `transformer`.

	@return TransformerBinder
]=]

function instanceTrackerUtil.bind(
	property: Property.Property,
	transformer: (newValue: any, oldValue: any?) -> any
)
	return table.freeze({
		property = property,
		transformer = transformer,
		[PROPERTY_TRANSFORMER_MEMBER] = true,
	})
end

--[=[ 
	@return TransformerBinder

	Returns a transformer binder, to be used by `instanceTrackerUtil.setProps`,
	the value of `property` of `instance` is wrapped onto `transformer`.

	```lua
	local name = Property.new("newText")

	instanceTrackerUtil.setProps(textLabel, {
		Text = instanceTrackerUtil.bindToInstanceProperty(Workspace.Baseplate, "Transparency", function(newTransparency, oldTransparency) 
			return tostring(newTransparency)
		end)
	})

	Workspace.Baseplate.Transparency = 1

	task.defer(function()
		print(textLabel.Text) --> "1"
	end)
	```
]=]

function instanceTrackerUtil.bindToInstanceProperty(
	instance: Instance,
	instanceProperty: string,
	transformer: (newValue: any, oldValue: any?) -> any
)
	local property = Property.new()
	property:bindToInstanceProperty(instance, instanceProperty)

	return table.freeze({
		property = property,
		transformer = transformer,
		[PROPERTY_TRANSFORMER_MEMBER] = true,
	})
end

--[=[ 
	@return TransformerBinder

	Returns a transformer binder, to be used by `instanceTrackerUtil.setProps`, 
	the attribute (`attribute`)` of `instance` is wrapped onto `transformer`.

	```lua
	local name = Property.new("newText")

	instanceTrackerUtil.setProps(textLabel, {
		Text = instanceTrackerUtil.bindToInstanceAttribute(Workspace.Baseplate, "SomeAttribute", function(newAttributeValue, oldAttributeValue) 
			return  newAttributeValue
		end)
	})

	Workspace.Baseplate:SetAttribute("SomeAttribute", "TestText")
	task.defer(function()
		print(textLabel.Text) --> "TestText"
	end)
	```
]=]

function instanceTrackerUtil.bindToInstanceAttribute(
	instance: Instance,
	attribute: string,
	transformer: (newValue: any, oldValue: any?) -> any
)
	local property = Property.new()
	property:bindToInstanceAttribute(instance, attribute)
	return table.freeze({
		property = property,
		transformer = transformer,
		[PROPERTY_TRANSFORMER_MEMBER] = true,
	})
end

--[=[ 
	@return Connection

	Initializes the given instance with `props`. If properties are specified in `props`, the
	instance property will be bind to the **value of the property*.

	Returns a cleanup function which when called, will destroy all properties bound to the instance.

	```lua
	local textProp = Property.new("someText")
	local nameProp = Property.new("test")

	instanceTrackerUtil.setProps(textLabel, {
		Text = textProp,

		TextStrokeTransparency = 1,

		-- Bind the "Name" property of the textlabel to a callback
		-- which will be called every time the "name" property's value
		-- changes (and is called initially), you can return a new value
		-- from the callback using the given property value, which'll be
		-- applied to the instance's property itself.
		Name = instanceTrackerUtil.bind(nameProp, function(name) 
			return name .. "_Cool"
		end)
	})

	print(textLabel.Name) --> "test_Cool"
	nameProp:set("nope")
	print(textLabel.Name) --> "nope_Cool"
	text:set("eyes")
	print(textLabel.Text) --> "eyes"
	```

	You can also treat the bound function as a higher order function and return another function from it which will be called
	*indefinitely* **until it returns an explicit nil value** or the prop reupdates. The function is just passed the latest value
	of the property and the old value of the property, and it's return value is used as the new value of the property.

	:::note
	The property is updated to the **non-nil** return value of the function, however it is bulk updated so no on update signals
	are fired (which effectively prevents the higher order function from being unnecessarily recalled).
	:::
	
	- You can use this to implement cool animations, for e.g a type writer effect:

	```lua
	-- Example type writer effect
	local nameProp = Property.new("newText")

	instanceTrackerUtil.setProps(textLabel, {
		Name = instanceTrackerUtil.bind(nameProp, function(name) 
			local goalLength = string.len(name)
			local timeToTake = goalLength / 30
			local accumulated = 0

			return function(updatedName)
				-- We are done with the time writer effect, let's return a nil value to stop
				-- this function from being called.
				if timeToTake < accumulated then return nil end

				accumulated += RunService.Heartbeat:Wait()
				return string.sub(name, 1, math.floor((accumulated / timeToTake) * goalLength))
			end
		end)
	})	
	```

	- Tweening:

	```lua
	local GOAL_TRANSPARENCY = 1

	local transparencyProp = Property.new(0)

	local function lerp(n, g, a)
		return n + (g - n) * a
	end

	local function close(n, g)
		return (n - g) < 0.001
	end

	instanceTrackerUtil.setProps(Workspace.Baseplate, {
		Transparency = instanceTrackerUtil.bind(transparencyProp, function() 
			return function(updatedTransparency)
				if close(updatedTransparency, GOAL_TRANSPARENCY) then return nil end

				return lerp(updatedTransparency, GOAL_TRANSPARENCY, RunService.Heartbeat:Wait() * 2)
			end
		end)
	})	
	```
]=]

function instanceTrackerUtil.setProps(
	instance: Instance,
	props: { [string]: any }
): Connection.Connection
	local initializedInstanceAncestor = nil
	if typeof(instance) == "Instance" then
		for initializedInstance in trackedInstances do
			if instance:IsDescendantOf(initializedInstance) then
				initializedInstanceAncestor = initializedInstance
				break
			end
		end
	end

	initializedInstanceAncestor = if initializedInstanceAncestor ~= nil
		then trackedInstances[initializedInstanceAncestor]
		else nil

	local connections = {}
	local transformerCleaner

	for instanceProperty, propertyOrValue in props do
		if isTransformerBinder(propertyOrValue) then
			local actualProperty = propertyOrValue.property
			local transformer = propertyOrValue.transformer
			local propertyValues = { actualProperty:get() }
			local transformedValue = transformer(unpack(propertyValues))

			if transformedValue ~= nil then
				transformerCleaner = applyTransformedValue(
					instance,
					instanceProperty,
					transformedValue,
					actualProperty
				)
			end

			local onUpdateConnection = actualProperty.onUpdate:Connect(function(...)
				local updatedPropertyValues = { ... }
				local updatedTransformedValue = if #updatedPropertyValues > 0
					then transformer(unpack(updatedPropertyValues))
					else nil

				if updatedTransformedValue == nil then
					return
				end

				if transformerCleaner ~= nil then
					transformerCleaner()
				end

				transformerCleaner = applyTransformedValue(
					instance,
					instanceProperty,
					updatedTransformedValue,
					actualProperty
				)
			end)

			table.insert(connections, onUpdateConnection)
			if initializedInstanceAncestor ~= nil then
				table.insert(initializedInstanceAncestor.propConnections, onUpdateConnection)
			end
		else
			if Property.is(propertyOrValue) then
				instance[instanceProperty] = if propertyOrValue:get() ~= nil
					then propertyOrValue:get()
					else instance[instanceProperty]

				local onUpdateConnection = propertyOrValue.onUpdate:Connect(function(newValue)
					instance[instanceProperty] = newValue
				end)

				table.insert(connections, onUpdateConnection)
				if initializedInstanceAncestor ~= nil then
					table.insert(initializedInstanceAncestor.propConnections, onUpdateConnection)
				end
			else
				applyTransformedValue(instance, instanceProperty, propertyOrValue, propertyOrValue)
			end
		end
	end

	return Connection.new(function()
		for _, connection in connections do
			if initializedInstanceAncestor ~= nil then
				local index = table.find(initializedInstanceAncestor.propConnections, connection)
				if index ~= nil then
					table.remove(initializedInstanceAncestor.propConnections, index)
				end
			end

			connection:Disconnect()
		end
	end)
end

--[=[ 
	Cleans up the given instance and untracks it, if it was previously being tracked.
	If a cleanup callback for the given instance exists, it will be called. Additionally, 
	all property objects used for the properties of the descendants of the given instance
	will have their connections cleaned up.

	```lua
	local myPart = workspace.MyPart

	local brickColor = Property.new(BrickColor.Red())
	local transparency = Property.new(0)

	-- Bind the "BrickColor" property of myPart to the above property:
	instanceTrackerUtil.setProps(myPart, {BrickColor = brickColor})

	-- Bind the "Transparency" property of myPart.SomeOtherPart to the above property:
	instanceTrackerUtil.setProps(myPart.SomeOtherPart, {Transparency = transparency})

	-- Track myPart: 
	instanceTrackerUtil.track(myPart, function()
		-- the transparency and brickColor property will soon have their connections cleaned up, so allow
		-- them to be set to their default values (myPart's brick color will now turn white
		-- and myPart.SomeOtherPart's transparency will now be set to 0)
		brickColor:set(BrickColor.White())
		transparency:set(0)
	end)

	task.wait(5)

	instanceTrackerUtil.untrack(myPart)
	```
]=]

function instanceTrackerUtil.untrack(instance: Instance)
	local cleanupCallback = cleanupCallbacks[instance]
	local trackedInstance = trackedInstances[instance]

	if cleanupCallback ~= nil then
		task.spawn(cleanupCallback, instance)
	end

	if trackedInstance ~= nil then
		for _, connection in trackedInstance.propConnections do
			connection:Disconnect()
		end
	end

	trackedInstances[instance] = nil
	cleanupCallbacks[instance] = nil
end

return table.freeze(instanceTrackerUtil)
