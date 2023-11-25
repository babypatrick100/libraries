return {
	run = function(serializedColorSequence)
		local deserializedKeypoints = {}

		for _, serializedKeypoint in serializedColorSequence.keypoints do
			table.insert(
				deserializedKeypoints,
				ColorSequenceKeypoint.new(
					serializedKeypoint[1],
					Color3.new(select(2, table.unpack(serializedKeypoint)))
				)
			)
		end

		return ColorSequence.new(deserializedKeypoints)
	end,
}
