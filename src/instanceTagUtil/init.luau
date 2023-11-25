--[=[
	@class instanceTagUtil

	A utility module for working with instance tags.
]=]

local CollectionService = game:GetService("CollectionService")

local Promise = require(script.Parent.Promise)

local instanceTagUtil = {}

--[=[
	Observes the given [CollectionService](https://create.roblox.com/docs/reference/engine/classes/CollectionService) tag.
	`callbackAdded` will be automatically called on all instances with the given tag, and `callbackRemoved` (if specified)
	will be automatically called on an instance whenever it *no longer* has the given tag.

	```lua
	instanceTagUtil.observe("SomeTag", function(instanceAdded)
		
	end, function(instanceRemoved)
		
	end)
	```
]=]

function instanceTagUtil.observe(
	tag: string,
	callbackAdded: (instance: Instance) -> (),
	callbackRemoved: ((instance: Instance) -> ())?
)
	for _, instance in CollectionService:GetTagged(tag) do
		task.spawn(callbackAdded, instance)
	end

	local connections = {
		CollectionService:GetInstanceAddedSignal(tag):Connect(callbackAdded),
		if callbackRemoved ~= nil
			then CollectionService:GetInstanceRemovedSignal(tag):Connect(callbackRemoved)
			else nil,
	} :: { RBXScriptConnection }?

	return function()
		for _, connection in connections do
			connection:Disconnect()
		end

		connections = nil
	end
end

--[=[
	Returns a promise which is resolved when the given instance has the passed tag.

	```lua
	instanceTagUtil.instanceTagPromise(instance, "SomeTag", function()
		print(instance.Name, "has tag 'SomeTag'")
	end)
	```
]=]

function instanceTagUtil.instanceTagPromise(instance: Instance, tag: string)
	return Promise.new(function(resolve)
		if instance:HasTag(tag) then
			resolve()
			return
		end

		CollectionService:GetInstanceAddedSignal(instance):Wait()
		resolve()
	end)
end

return table.freeze(instanceTagUtil)
