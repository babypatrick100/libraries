return {
	run = function(serializedNumberSequence)
		local deserializedKeypoints = {}

		for _, serializedKeypoint in serializedNumberSequence.keypoints do
			table.insert(
				deserializedKeypoints,
				NumberSequenceKeypoint.new(table.unpack(serializedKeypoint))
			)
		end

		return NumberSequence.new(deserializedKeypoints)
	end,
}
