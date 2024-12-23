--[=[ 
	@class basePartSizeUtil
	
	A utility module for resizing base parts on specific axes.
]=]

local TweenService = game:GetService("TweenService")

local Promise = require(script.Parent.Promise)
local instanceTranslationUtil = require(script.Parent.instanceTranslationUtil)

local DEFAULT_BASE_PART_TWEEN_INFO = TweenInfo.new(0)
local VECTOR_XZ = Vector3.new(1, 0, 1)
local VECTOR_YZ = Vector3.new(0, 1, 1)
local VECTOR_XY = Vector3.new(1, 1, 0)

local basePartSizeUtil = {}

local function promiseBasedOnTweens(tweens: { Tween })
	local promise
	promise = Promise.new(function(resolve)
		for _, tween in tweens do
			if tween.PlaybackState == Enum.PlaybackState.Begin then
				tween.Completed:Wait()
			end

			if tween.PlaybackState == Enum.PlaybackState.Cancelled then
				promise:cancel()
				return
			end
		end

		resolve()
	end)

	return promise
end

local function resizeBasepart(basePart, goalSize, goalCFrame, tweenInfo)
	if tweenInfo ~= nil then
		local tweens = {}
		local basePartSizeTween = TweenService:Create(basePart, tweenInfo, {
			Size = goalSize,
		})
		basePartSizeTween:Play()
		table.insert(tweens, basePartSizeTween)
		table.insert(
			tweens,
			instanceTranslationUtil.tweenInstanceToCFrame(
				basePart,
				tweenInfo or DEFAULT_BASE_PART_TWEEN_INFO,
				goalCFrame
			)
		)

		return promiseBasedOnTweens(tweens)
	else
		basePart.Size = goalSize
		basePart.CFrame = goalCFrame
		return nil
	end
end

--[=[
	Resizes the given `basePart`'s `Size`'s `X` to `newSizeX`. If `tweenInfo` is specified, then a promise 
	is returned which is resolved once the operation is  successful.

	@return Promise?
]=]

function basePartSizeUtil.resizeOnXAxis(basePart: BasePart, newSizeX: number, tweenInfo: TweenInfo?)
	local oldSize = basePart.Size
	local goalSize = (basePart.Size * VECTOR_YZ) + Vector3.new(newSizeX, 0, 0)
	local goalCFrame = basePart:GetPivot() * CFrame.new(-(newSizeX - oldSize.X) / 2, 0, 0)

	return resizeBasepart(basePart, goalSize, goalCFrame, tweenInfo)
end

--[=[
	Resizes the given `basePart`'s `Size`'s `Y` to `newSizeY`. If `tweenInfo` is specified, then a promise 
	is returned which is resolved once the operation is  successful.

	@return Promise?
]=]

function basePartSizeUtil.resizeOnYAxis(basePart: BasePart, newSizeY: number, tweenInfo: TweenInfo?)
	local oldSize = basePart.Size
	local goalSize = (basePart.Size * VECTOR_XZ) + Vector3.new(0, newSizeY, 0)
	local goalCFrame = basePart:GetPivot() * CFrame.new(0, -(newSizeY - oldSize.Y) / 2, 0)

	return resizeBasepart(basePart, goalSize, goalCFrame, tweenInfo)
end

--[=[
	Resizes the given `basePart`'s `Size`'s `Z` to `newSizeZ`. If `tweenInfo` is specified, then a promise 
	is returned which is resolved once the operation is  successful.

	@return Promise?
]=]

function basePartSizeUtil.resizeOnZAxis(basePart: BasePart, newSizeZ: number, tweenInfo: TweenInfo?)
	local goalSize = (basePart.Size * VECTOR_XY) + Vector3.new(0, 0, newSizeZ)
	local oldSize = basePart.Size
	local goalCFrame = basePart:GetPivot() * CFrame.new(0, 0, -(newSizeZ - oldSize.X) / 2)

	return resizeBasepart(basePart, goalSize, goalCFrame, tweenInfo)
end

return table.freeze(basePartSizeUtil)
