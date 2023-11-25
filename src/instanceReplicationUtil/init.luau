--[=[ 
    @class instanceReplicationUtil

    An utility module for working with instance replication.
 
    ```lua
    -- GOAL: Create a model with a part, and ensure that the model is fully
    -- replicated to the client by the time the client accesses it.

    -- Server:
    local Workspace = game:GetService("Workspace")
    
    local model = Instance.new("Model")
    local part1 = Instance.new("Part")
    part1.Name = "Part1"
    part1.Parent = model
    model.Parent = Workspace

    -- storeInstanceSnapshot will capture the "snapshot" of the model and 
    -- store it within the model it self via attributes.
    instanceReplicationUtil.storeInstanceSnapshot(model)

    -- Client:

    -- instanceSnaphot will return a [promise](https://eryn.io/roblox-lua-promise/) which will be resolved once
    -- the model's snapshot (stored within the model by storeInstanceSnapshot)
    -- is ready.
    instanceReplicationUtil.instanceSnaphot(workspace.Model):andThen(function()
        -- Safely access the part without worrying if it has successfuly replicated
        -- or not!
        print(workspace.Model.Part1)
    end)
    ```

    :::note Possible deprecation
    This module is superseded by [StreamingEnabled](https://create.roblox.com/docs/workspace/streaming) (if used properly) 
    - you can set the `ModelStreamingMode` of models to `Atomic` to ensure all their descendants are loaded once the main model
    is loaded into the client.
    :::
]=]

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Promise = require(script.Parent.Promise)

local INSTANCE_GUI_ID_ATTRIBUTE = "__GuiId"
local INSTANCE_DESCENDANTS_COUNT = "__InstanceDescendantsCount"

local instanceReplicationUtil = {}

local function instanceIsValid(instance: Instance)
	return instance:GetAttribute(INSTANCE_GUI_ID_ATTRIBUTE) ~= nil
end

local function validDescendantsCount(instance: Instance): number
	local validDescendants = 0

	for _, descendant in instance:GetDescendants() do
		if instanceIsValid(descendant) then
			validDescendants += 1
		end
	end

	return validDescendants
end

--[=[
    This method will capture the "snapshot" of `instance` and store it within
    the instance it self via attributes. This method is to be used in conjuction with 
    [instanceReplicationUtil.instanceSnaphot].
]=]

function instanceReplicationUtil.storeInstanceSnapshot(instance: Instance)
	assert(RunService:IsServer(), "Can only store instance snapshot on the server!")

	local instanceDescendants = instance:GetDescendants()
	instance:SetAttribute(INSTANCE_DESCENDANTS_COUNT, #instanceDescendants)

	for _, descendant in instanceDescendants do
		descendant:SetAttribute(INSTANCE_GUI_ID_ATTRIBUTE, HttpService:GenerateGUID(true))
	end
end

--[=[
    Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved once `instance` has it's snapshot available.
    @return Promise<>

    :::warning Instance snapshot required
    This method will throw an error if [instanceUtil.storeInstanceSnapshot] has not been called on `instance`!
    :::

    :::tip Waiting for an instance's descendants on the client
    This utility module comes in handy in cases where the client has access to
    some instance but with no guarantee whether it has fully replicated by the 
    server or not. We can quite easily solve this problem! 
    
    First we'll have the server store the snapshot of the instance within the instance it self:
    
    ```lua
    instanceReplicationUtil.storeInstanceSnapshot(workspace.Model)
    ```

    Then on the client, we'll simply wait for the instance's snapshot to be 
    available:

    ```lua
    instanceReplicationUtil.instanceSnaphot(workspace.Model):andThen(function()
        -- At this point, you can safely access everything within workspace.Model!
        print(workspace.Model.SomeChild) 
    end)
    ```

    ### Known Limitations

    - a) `storeInstanceSnapshot` stores the snapshot of the given instance within
    the instance it self, through **attributes**. This means that at any point, the
    instance can simply have its attributes cleared away (e.g by the developer) which
    will break the implementation, however do note that this will usually be a sign 
    of developer error, so you need to be careful with this!

    - b) You need to ensure that the server calls `storeInstanceSnapshot` on the given
    instance **before** the client actually uses `instanceSnaphot` to wait
    for the replication of the instance's snapshot, since `instanceSnaphot`
    expects the given instance to have it's snapshot stored within the instance already.

    - c) There is a limit as to how many attributes an instance can have, however the limit is very large so this
    is really nothing to worry about.
    :::
]=]

function instanceReplicationUtil.instanceSnaphot(instance: Instance)
	assert(RunService:IsClient(), "Can only wait for the instance's snapshot on the client!")

	local minimumRequiredInstanceDescendants = instance:GetAttribute(INSTANCE_DESCENDANTS_COUNT)
	assert(
		minimumRequiredInstanceDescendants,
		string.format(
			"Instance's stored snapshot was not found. Are you sure you called .storeInstanceSnapshot on the server for the instance?"
		)
	)

	local bindable = Instance.new("BindableEvent")

	task.defer(function()
		local validDescendantsCount = validDescendantsCount(instance)

		if validDescendantsCount >= minimumRequiredInstanceDescendants then
			bindable:Fire()
		else
			local connection
			connection = instance.DescendantAdded:Connect(function(descendant)
				if not connection.Connected then
					return
				end

				if instanceIsValid(descendant) then
					validDescendantsCount += 1
				end

				if validDescendantsCount >= minimumRequiredInstanceDescendants then
					bindable:Fire()
					connection:Disconnect()
				end
			end)
		end
	end)

	local promise = Promise.fromEvent(bindable.Event)

	promise:finally(function()
		bindable:Destroy()
	end)

	return promise
end

return table.freeze(instanceReplicationUtil)
