local Promise = require(script.Parent.Promise)

--[=[
	@class instanceAttributeUtil

	A utility module for working with instance attributes.
]=]

local instanceAttributeUtil = {}

--[=[
	Returns an array of all descendants in `instanceTree` which have the
	`desiredAttribute` attribute.
]=]

function instanceAttributeUtil.all(instanceTree: Instance, desiredAttribute: string)
	local captured = {}

	for _, descendant in instanceTree:GetDescendants() do
		if descendant:GetAttribute(desiredAttribute) ~= nil then
			table.insert(captured, descendant)
		end
	end

	return captured
end

--[=[
	Sets up an event connection which listens to any descendant added to `instanceTree`, if it has the
	`desiredAttribute` atribute, then `callback` will be called.

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
)
	return instanceTree.DescendantAdded:Connect(function(descendant)
		if descendant:GetAttribute(desiredAttribute) ~= nil then
			callback(descendant)
		end
	end)
end

--[=[
	Sets up an event connection which listens to any descendant removed from `instanceTree`, if it has the
	`desiredAttribute` atribute, then `callback` will be called.

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
)
	return instanceTree.DescendantRemoving:Connect(function(descendant)
		if descendant:GetAttribute(desiredAttribute) ~= nil then
			callback(descendant)
		end
	end)
end

--[=[
	Observes the value of attribute `desiredAttribute` in `instance`, so `callback` is called
	every time the attribute updates.

	```lua
	instanceAttributeUtil.observe(workspace, "Some", function(attributeValue)
		print(instance)
	end)
	```
]=]

function instanceAttributeUtil.observe(
	instance: Instance,
	desiredAttribute: string,
	callback: (attributeValue: any) -> ()
)
	local attributeValue = instance:GetAttribute(desiredAttribute)
	if attributeValue ~= nil then
		task.spawn(callback, attributeValue)
	end

	return instance:GetAttributeChangedSignal(desiredAttribute):Connect(function()
		callback(instance:GetAttribute(desiredAttribute))
	end)
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

	```lua
	instanceAttributeUtil.instanceAttributePromise(instance, "SomeAttribute", function(newValue, oldValue)
		return newValue == 2 and oldValue == 1
	end):andThen(function(value)
		print(value) --> 2
	end)

	instance:SetAttribute("SomeAttribute", 1)
	instance:SetAttribute("SomeAttribute", 2)
	```
]=]

function instanceAttributeUtil.instanceAttributePromise(
	instance: Instance,
	attribute: string,
	predicate: ((
		newValue: any,
		oldValue: any
	) -> boolean)?
)
	return Promise.new(function(resolve)
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
end

return table.freeze(instanceAttributeUtil)
