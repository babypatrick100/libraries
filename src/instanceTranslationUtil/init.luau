--[=[ 
	@class instanceTranslationUtil

	A simple utility for translating the `CFrame` property of base parts and model.
]=]

local TweenService = game:GetService("TweenService")

local tweensInProgress = {}

local instanceTranslationUtil = {}

--[=[
	Tweens the CFrame of the given instance to `result` CFrame, using 
	[Instance:PivotTo](https://create.roblox.com/docs/reference/engine/classes/PVInstance#PivotTo).

	```lua
	instanceTranslationUtil.tweenInstanceToCFrame(someModel, TweenInfo.new(1), {CFrame = CFrame.new(0,100,0)})
	```

	https://devforum.roblox.com/t/is-there-any-way-i-can-tween-pivotto/1918057/2
]=]

function instanceTranslationUtil.tweenInstanceToCFrame(
	instance: BasePart | Model,
	tweenInfo: TweenInfo,
	result: CFrame
): Tween
	if tweensInProgress[instance] ~= nil then
		tweensInProgress[instance]:Cancel()
	end

	local cframe = Instance.new("CFrameValue")
	cframe.Value = instance:GetPivot()

	local tween = TweenService:Create(cframe, tweenInfo, { Value = result })
	tween:Play()
	tweensInProgress[instance] = tween

	cframe:GetPropertyChangedSignal("Value"):Connect(function()
		if tweensInProgress[instance] ~= tween then
			return
		end

		if tween.PlaybackState == Enum.PlaybackState.Cancelled then
			return
		end

		instance:PivotTo(cframe.Value)
	end)

	tween.Completed:Connect(function()
		cframe:Destroy()

		if tweensInProgress[instance] == tween then
			tweensInProgress[instance] = nil
		end
	end)

	return tween
end

return table.freeze(instanceTranslationUtil)
