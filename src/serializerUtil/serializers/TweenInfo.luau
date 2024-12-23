return {
	run = function(tweenInfo: TweenInfo, intermediateSerializedData)
		intermediateSerializedData.components = {
			tweenInfo.Time,
			tweenInfo.Reverses,
			tweenInfo.RepeatCount,
			tweenInfo.DelayTime,
			tweenInfo.EasingDirection.Name,
			tweenInfo.EasingStyle.Name,
		}
	end,
}
