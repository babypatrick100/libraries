return {
	run = function(serializedTweenInfo)
		local components = serializedTweenInfo.components

		return TweenInfo.new(
			components[1],
			Enum.EasingStyle[components[6]],
			Enum.EasingDirection[components[5]],
			components[3],
			components[2],
			components[4]
		)
	end,
}
