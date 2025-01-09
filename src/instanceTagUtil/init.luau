--[=[
	@class instanceTagUtil

	A utility module for working with instance tags.
]=]

local CollectionService = game:GetService("CollectionService")

local Promise = require(script.Parent.Promise)
local Connection = require(script.Parent.Connection)

local instanceTagUtil = {}

--[=[
	@return Connection
	
	Observes the given [CollectionService](https://create.roblox.com/docs/reference/engine/classes/CollectionService) tag.
	`tagAddedCallback` will be automatically called on all instances with the given `tag`, and `tagRemovedCallback` (if specified)
	will be automatically called, being passed the instance that no *no longer* has the given `tag`.

	```lua
	instanceTagUtil.observe("SomeTag", function(instanceWithTheTag)
		
	end, function(instanceThatHadTheTag)
		
	end)
	```
]=]

function instanceTagUtil.observe(
	tag: string,
	tagAddedCallback: (instanceWithTheTag: Instance) -> (),
	tagRemovedCallback: ((instanceThatHadTheTag: Instance) -> ())?
)
	for _, instance in CollectionService:GetTagged(tag) do
		task.spawn(tagAddedCallback, instance)
	end

	local connections = {
		CollectionService:GetInstanceAddedSignal(tag):Connect(tagAddedCallback),
		if tagRemovedCallback ~= nil
			then CollectionService:GetInstanceRemovedSignal(tag):Connect(tagRemovedCallback)
			else nil,
	}

	return Connection.new(function()
		for _, connection in connections do
			connection:Disconnect()
		end
	end)
end

--[=[
	Returns a promise which is resolved when the given instance has the given `tag`.
	
	:::note
	The returned promise will be cancelled if `instance` is destroyed.
	:::

	```lua
	instanceTagUtil.instanceTagPromise(instance, "SomeTag", function()
		print(instance.Name, "now has the tag 'SomeTag'")
	end)
	```
]=]

function instanceTagUtil.instanceTagPromise(instance: Instance, tag: string)
	local promise = Promise.new(function(resolve)
		while not instance:HasTag(tag) do
			CollectionService:GetInstanceAddedSignal(tag):Wait()
		end

		resolve(instance)
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
	Adds all tags in `tags` to the given `instance`.

	```lua
	instanceTagUtil.addTagsToInstance(workspace.Baseplate, {"Test"})
	print(CollectionService:HasTag(workspace.Baseplate, "Test")) --> true
	```
]=]

function instanceTagUtil.addTagsToInstance(instance: Instance, tags: { string })
	for _, tag in tags do
		CollectionService:AddTag(instance, tag)
	end
end

--[=[
	Removes all tags in `tags` from the given `instance`.

	```lua
	instanceTagUtil.addTagsToInstance(workspace.Baseplate, {"Test"})
	print(CollectionService:HasTag(workspace.Baseplate, "Test")) --> true
	instanceTagUtil.removeTagsFromInstance(workspace.Baseplate, {"Test"})
	print(CollectionService:HasTag(workspace.Baseplate, "Test")) --> false
	```
]=]

function instanceTagUtil.removeTagsFromInstance(instance: Instance, tags: { string })
	for _, tag in tags do
		CollectionService:RemoveTag(instance, tag)
	end
end

--[=[
	Works similar to [instanceTagUtil.observe], but observes an array of tags instead of a single tag. `observer`
	will initially be immediately called being passed an array of all the tags (in `tagsToObserve`) that the given
	`instance` has at that time, and then called again everytime a tag (that exists in `tagsToObserve`) is added or removed
	from the given `instance`.

	`oldTags` will be initially `nil` the first time `observer` is called. However whenever the `observer` is called again,
	`oldTags` will be be an array representing the tags the `instance` had during the time when `observer` was *previously*
	called.

	```lua
	instanceTagUtil.observeMany(workspace.Part, {"Number1", "Number2"}, function(newTags, oldTags)
		print(`newTags: {newTags}, oldTags: {oldTags}`) 
	end)

	workspace.Part:AddTag("Number1")
	workspace.Part:AddTag("Number2")

	-- OUTPUT:
	--> {}, nil 
	--> {"Number1", "Number2"}, {}
	```

	@return Connection 
]=]

function instanceTagUtil.observeMany(
	instance: Instance,
	tagsToObserve: { string },
	observer: (newTags: { string }, oldTags: { string }?) -> ()
): Connection.Connection
	local newTags = {}
	local oldTags = {}

	for tag in instance:GetTags() do
		if table.find(tagsToObserve, tag) == nil then
			continue
		end

		table.insert(newTags, tag)
	end

	task.spawn(observer, newTags, nil)

	local connections = {}
	table.insert(
		connections,
		CollectionService.TagAdded:Connect(function(tag)
			if table.find(tagsToObserve, tag) == nil or table.find(newTags, tag) ~= nil then
				return
			end

			if not instance:HasTag(tag) then
				return
			end

			oldTags = table.clone(newTags)
			table.insert(newTags, tag)
			task.spawn(observer, newTags, oldTags)
		end)
	)

	table.insert(
		connections,
		CollectionService.TagRemoved:Connect(function(tag)
			if table.find(tagsToObserve, tag) == nil or table.find(newTags, tag) ~= nil then
				return
			end

			local index = table.find(newTags, tag)
			if index ~= nil then
				oldTags = table.clone(newTags)
				table.remove(newTags, index)
				task.spawn(observer, newTags, oldTags)
			end
		end)
	)

	return Connection.new(function()
		for _, connection in connections do
			connection:Disconnect()
		end
	end)
end

return table.freeze(instanceTagUtil)
