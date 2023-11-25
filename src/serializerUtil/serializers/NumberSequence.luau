return {
	run = function(numberSequence: NumberSequence, intermediateSerializedData)
		local serializedKeypoints = {}

		for _, keypoint in numberSequence.Keypoints do
			table.insert(serializedKeypoints, { keypoint.Time, keypoint.Value, keypoint.Envelope })
		end

		intermediateSerializedData.keypoints = serializedKeypoints
	end,
}
