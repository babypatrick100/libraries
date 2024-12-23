--[=[ 
	@class instancePropertyUtil

	An utility module for working with instance properties.
]=]

local TweenService = game:GetService("TweenService")

local instancePropertyUtil = {}

--[=[
	Sets the properties of `instance` from the `properties` table.

	```lua
	instancePropertyUtil.setInstanceProperties(workspace.Baseplate, {Transparency = 1})
	print(workspace.Baseplate.Transparency) --> 1

	local tween = instancePropertyUtil.setInstanceProperties(workspace.Baseplate, {Transparency = 0}, TweenInfo.new(5))
	tween.Completed:Wait()
	```
]=]

function instancePropertyUtil.setInstanceProperties(
	instance: Instance,
	properties: { [string]: any },
	tweenInfo: TweenInfo?
): Tween?
	if tweenInfo then
		local tween = TweenService:Create(instance, tweenInfo, properties)
		tween:Play()
		return tween
	else
		for property, value in properties do
			instance[property] = value
		end
	end

	return nil
end

--[=[
	Observes the given property of the instance. `observer` will be called initially, being passed
	the current value of the property. As the property updates, `observer` will be called being passed
	*both* the new value of the property *and* the old value.

	```lua
	instancePropertyUtil.observeProperty(workspace.Baseplate, "Anchored", function(newPropertyValue, oldPropertyValue)
		print(newPropertyValue, oldPropertyValue)
	end)
	```
]=]

function instancePropertyUtil.observeProperty(
	instance: Instance,
	property: string,
	observer: (newValue: any, oldValue: any) -> ()
): RBXScriptConnection
	local lastValue = instance[property]
	task.spawn(observer, lastValue, nil)

	return instance:GetPropertyChangedSignal(property):Connect(function()
		observer(instance[property], lastValue)
		lastValue = instance[property]
	end)
end

return table.freeze(instancePropertyUtil)
