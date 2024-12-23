--[=[ 
	@class InstanceDataHolder

	A very simple class for storing data for instances.
]=]

local InstanceDataHolder = {}
InstanceDataHolder.__index = {}

--[=[
	Creates and returns a new instance data holder.
]=]

function InstanceDataHolder.new()
	return setmetatable({
		_instancesData = {},
	}, InstanceDataHolder)
end

--[=[
	Returns `true` if the given object is a [InstanceDataHolder].
]=]

function InstanceDataHolder.is(self: any): boolean
	return getmetatable(self) == InstanceDataHolder
end

--[=[
	Returns the data of the given `instance` stored in the instance data holder. If it does not exist,
	then a new one (an empty table) will be created for it and returned instead.

	:::tip Automatic cleanup
	When `instance` is destroyed, the data stored for it will be automatically cleaned up.
	:::

	:::warning
	`instance` must **not** be parented to `nil` - if so, then this method will throw an error. 
	:::
]=]

function InstanceDataHolder.__index:instanceData(instance: Instance): { [any]: any }
	-- `instance.Parent` checks are cheap!
	if instance.Parent == nil then
		error(`Given instance {instance.Name} must be in game.`)
	end

	local instanceData = self._instancesData[instance]
	if instanceData == nil then
		instanceData = {
			data = {},
			connection = instance.Destroying:Connect(function()
				self._instancesData[instance] = nil
			end),
		}

		self._instancesData[instance] = instanceData
	end

	return instanceData.data
end

--[=[
	Cleans up the given `instance`'s data stored in the instance data holder, if it exists.

	:::tip
	Usually you don't really have to call this method as stored instance data are automatically
	cleaned up once the instances are destroyed, but this method exists to give the developer more
	control.
	:::
]=]

function InstanceDataHolder.__index:cleanupForInstance(instance: Instance)
	local instanceData = self._instancesData[instance]
	if instanceData == nil then
		return
	end

	instanceData.connection:Disconnect()
	self._instancesData[instance] = nil
end

--[=[
	Cleans up all instance data stored in the instance data holder.
]=]

function InstanceDataHolder.__index:cleanupForAll()
	for _, instanceData in self._instancesData do
		instanceData.connection:Disconnect()
	end

	self._instancesData = {}
end

--[=[
	Calls [InstanceDataHolder:cleanupForAll] and destroys the instance data holder, rendering it unusable.
]=]

function InstanceDataHolder.__index:destroy()
	self:cleanup()
	setmetatable(self, nil)
end

return table.freeze(InstanceDataHolder)
