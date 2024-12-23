--[=[ 
	@class instanceNetworkOwnerUtil

	An utility module for working with instance network ownership.
]=]

local instanceNetworkOwnerUtil = {}

--[=[
	Sets the network owner of `instance` to `networkOwner` *safely*.

	:::tip Safe to call
	This method should be preferred over directly setting the network owner of `instance` 
	via [SetNetworkOwner](https://create.roblox.com/docs/reference/engine/classes/BasePart#SetNetworkOwner), as
	it won't error in cases where the network ownership API cannot be used on `instance`.
	::: 
]=]

function instanceNetworkOwnerUtil.safeSetInstanceNetworkOwner(
	instance: BasePart,
	networkOwner: Player?
)
	if not instance:CanSetNetworkOwnership() then
		return
	end

	instance:SetNetworkOwner(networkOwner)
end

--[=[
	Returns the network owner of `instance` *safely*.
	
	:::tip Safe to call
	This method should be preferred over directly getting the network owner of `instance` 
	via [GetNetworkOwner](https://create.roblox.com/docs/reference/engine/classes/BasePart#GetNetworkOwner), as
	it will safely return `nil` (instead of erroring) in cases where the network ownership API cannot be used on `instance`!
	::: 
]=]

function instanceNetworkOwnerUtil.safeInstanceNetworkOwner(instance: BasePart): Player?
	if instance:IsGrounded() then
		return nil
	end

	return instance:GetNetworkOwner()
end

return table.freeze(instanceNetworkOwnerUtil)
