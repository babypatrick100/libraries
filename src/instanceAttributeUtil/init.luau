--[=[
	@class instanceAttributeUtil

	A utility module for working with instance attributes.
]=]

local Promise = require(script.Parent.Promise)

local instanceAttributeUtil = {}

--[=[
	Returns a read only array of all descendants in `instanceTree` which have the
	`desiredAttribute` attribute.
]=]

function instanceAttributeUtil.all(instanceTree: Instance, desiredAttribute: string): { Instance }
	local captured = {}

	for _, descendant in instanceTree:GetDescendants() do
		if descendant:GetAttribute(desiredAttribute) ~= nil then
			table.insert(captured, descendant)
		end
	end

	return table.freeze(captured)
end

--[=[
	Works similar to [instanceAttributeUtil.observe], but observes an array of 
	attributes instead of a single attribute. 

	```lua
	instanceAttributeUtil.observeMany(workspace, {"Number1", "Number2"}, function(newAttributes, oldAttributes)
		print(newAttributes.Number1 + newAttributes.Number2)
	end)
	```
]=]

function instanceAttributeUtil.observeMany(
	instance: Instance,
	attributesToObserve: { string },
	observer: (
		newAttributes: { [string]: any },
		oldAttributeValue: { [string]: any }?
	) -> ()
): RBXScriptConnection
	local newAttributes = {}
	local oldAttributes = {}

	local newAttributesCount = 0

	for attribute, value in instance:GetAttributes() do
		if table.find(attributesToObserve, attribute) == nil then
			continue
		end

		newAttributes[attribute] = value
		newAttributesCount += 1
	end

	if newAttributesCount == #attributesToObserve then
		task.spawn(observer, newAttributes, nil)
	end

	return instance.AttributeChanged:Connect(function(attribute)
		if table.find(attributesToObserve, attribute) == nil then
			return
		end

		local newAttributeValue = instance:GetAttribute(attribute)
		newAttributes[attribute] = newAttributeValue

		task.spawn(observer, newAttributes, oldAttributes)
		oldAttributes[attribute] = newAttributeValue
	end)
end

--[=[
	Sets up an event connection which listens to any descendant added to `instanceTree`, if it has the
	`desiredAttribute` atribute, then `callback` will be called. 

	This method will also capture initial descendants of the given `instanceTree` as well.

	```lua
	instanceAttributeUtil.new(workspace, "Test", function(instance)
		print(instance)
	end)
	```
]=]

function instanceAttributeUtil.new(
	instanceTree: Instance,
	desiredAttribute: string,
	callback: (descendant: Instance) -> ()
): RBXScriptConnection
	for _, descendant in instanceTree:GetDescendants() do
		if descendant:GetAttribute(desiredAttribute) ~= nil then
			task.spawn(callback, descendant)
		end
	end

	return instanceTree.DescendantAdded:Connect(function(descendant)
		if descendant:GetAttribute(desiredAttribute) ~= nil then
			callback(descendant)
		end
	end)
end

--[=[
	Sets up an event connection which listens to any descendant removed from `instanceTree`, if it has the
	`desiredAttribute` atribute, then `callback` will be called. Returns a [RBXScriptConnection](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptConnection) object.

	```lua
	instanceAttributeUtil.removed(workspace, "Test", function(instance)
		print(instance)
	end)
	```
]=]

function instanceAttributeUtil.removed(
	instanceTree: Instance,
	desiredAttribute: string,
	callback: (descendant: Instance) -> ()
): RBXScriptConnection
	return instanceTree.DescendantRemoving:Connect(function(descendant)
		if descendant:GetAttribute(desiredAttribute) ~= nil then
			callback(descendant)
		end
	end)
end

--[=[
	Observes the value of attribute `desiredAttribute` in `instance`, so `observer` is called
	every time the attribute updates. Returns a [RBXScriptConnection](https://create.roblox.com/docs/reference/engine/datatypes/RBXScriptConnection) object, 
	as well a promise that is resolved when `observer` is called for the first time and has finished running.

	```lua
	instanceAttributeUtil.observe(workspace, "SomeAttribute", function(newValue, oldValue)
		...
	end)
	```

	@return RBXScriptConnection, Promise<>
]=]

function instanceAttributeUtil.observe(
	instance: Instance,
	desiredAttribute: string,
	observer: (newAttributeValue: any, oldAttributeValue: any) -> ()
): (RBXScriptConnection, any)
	local oldAttributeValue = instance:GetAttribute(desiredAttribute)
	local promise = Promise.new(function(resolve)
		if oldAttributeValue ~= nil then
			observer(oldAttributeValue, nil)
		end

		resolve()
	end)

	local connection = instance:GetAttributeChangedSignal(desiredAttribute):Connect(function()
		task.spawn(observer, instance:GetAttribute(desiredAttribute), oldAttributeValue)
		oldAttributeValue = instance:GetAttribute(desiredAttribute)
	end)

	return connection, promise
end

--[=[
	Returns a promise which is resolved when the given instance has the given attribute.
	
	```lua
	instanceAttributeUtil.instanceAttributePromise(instance, "SomeAttribute"):andThen(function(value)
		print(value) --> 5
	end)

	instance:SetAttribute("SomeAttribute", 5)
	```

	`predicate` can also be passed, which should return a boolean value. It is passed
	the new attribute value of the instance, and the old attribute value of the instance. The promise
	will only resolve when `predicate` returns `true` for the new attribute value of the instance.

	The returned promise will be cancelled if `instance` is destroyed.

	```lua
	instanceAttributeUtil.instanceAttributePromise(instance, "SomeAttribute", function(newValue, oldValue)
		return newValue == 2 and oldValue == 1
	end):andThen(function(value)
		print(value) --> 2
	end)

	instance:SetAttribute("SomeAttribute", 1)
	instance:SetAttribute("SomeAttribute", 2)
	```

	@return Promise<value: any>
]=]

function instanceAttributeUtil.instanceAttributePromise(
	instance: Instance,
	attribute: string,
	predicate: ((
		newValue: any,
		oldValue: any
	) -> boolean)?
)
	local promise = Promise.new(function(resolve)
		if predicate == nil then
			if instance:GetAttribute(attribute) ~= nil then
				resolve(instance:GetAttribute(attribute))
			else
				instance:GetAttributeChangedSignal(attribute):Wait()
				resolve()
			end
		else
			local oldValue
			while predicate(instance:GetAttribute(attribute), oldValue) ~= true do
				oldValue = instance:GetAttribute(attribute)
				instance:GetAttributeChangedSignal(attribute):Wait()
			end

			resolve(instance:GetAttribute(attribute))
		end
	end)

	local instanceDestroyingConnection = instance.Destroying:Once(function()
		promise:cancel()
	end)

	promise:finally(function()
		instanceDestroyingConnection:Disconnect()
	end)

	return promise
end

--[=[
	Calls [instanceAttributeUtil.instanceAttributePromise] for every attribute in `attributes`, and saves
	the promise internally. Returns a promise that is reolved once all internal promises have been resolved.

	@return Promise<>
]=]

function instanceAttributeUtil.instanceAttributesPromise(instance: Instance, attributes: { string })
	local instanceAttributePromises = {}

	for _, attribute in attributes do
		table.insert(
			instanceAttributePromises,
			instanceAttributeUtil.instanceAttributePromise(instance, attribute)
		)
	end

	return Promise.all(instanceAttributePromises)
end

--[=[
	Sets the attributes of `instance` from the `attributes` table.

	```lua
	instanceAttributeUtil.setInstanceAttributes(workspace.Baseplate, {IsMayoSauce = true})
	print(workspace.Baseplate:GetAttribute("IsMayoSauce")) --> true
	```
]=]

function instanceAttributeUtil.setInstanceAttributes(
	instance: Instance,
	attributes: { [string]: any }
)
	for attribute, value in attributes do
		instance:SetAttribute(attribute, value)
	end
end

return table.freeze(instanceAttributeUtil)
