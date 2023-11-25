--[=[ 
	@class matterEntityUtil

	Utility module for working with [matter](https://eryn.io/matter/) entities.
]=]

--[=[ 
	@type InstanceIdAttribute "serverEntityId" | "clientEntityId"
	@within matterEntityUtil

	Is `serverEntityId` on the server and `clientEntityId` on the client.
]=]

local RunService = game:GetService("RunService")

local Promise = require(script.Parent.Promise)

local ID_ATTRIBUTE = if RunService:IsServer() then "serverEntityId" else "clientEntityId"

local matterEntityUtil = {}

--[=[ 
	Sets an attribute ([InstanceIdAttribute]) in the given instance to `id`. 
]=]

function matterEntityUtil.setInstanceId(instance: Instance, id: number)
	instance:SetAttribute(ID_ATTRIBUTE, id)
end

--[=[ 
	Returns the instane attribute id of the given instance, if found.
]=]

function matterEntityUtil.instanceId(instance: Instance): number?
	return instance:GetAttribute(ID_ATTRIBUTE)
end

--[=[ 
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the entity id attribute (set by [matterEntityUtil.setInstanceId]) of the given instance.

	```lua
	matterEntityUtil.instanceIdPromise(instance):andThen(function(entityId)
		print(typeof(entityId)) --> "number"
	end)
	```

	@return Promise<number>
]=]

function matterEntityUtil.instanceIdPromise(instance: Instance)
	return Promise.new(function(resolve)
		while not instance:GetAttribute(ID_ATTRIBUTE) do
			instance:GetAttributeChangedSignal(ID_ATTRIBUTE):Wait()
		end

		resolve(instance:GetAttribute(ID_ATTRIBUTE))
	end)
end

--[=[ 
	Returns the id of the entity which has the given components.

	```lua
	local id = world:spawn(componentA)
	local entityId = matterEntityUtil.entityIdFromComponents(componentA)

	print(entityId == id)
	```

	@param world Matter.World
	@param ... Matter.Component
]=]

function matterEntityUtil.entityIdFromComponents(world, ...): number?
	local requiredComponents = { ... }

	for entityId, entityData in world do
		local shouldSkip = false

		for _, component in requiredComponents do
			if not entityData[component] then
				shouldSkip = true
				break
			end
		end

		if shouldSkip then
			continue
		end

		return entityId
	end

	return nil
end

return table.freeze(matterEntityUtil)
