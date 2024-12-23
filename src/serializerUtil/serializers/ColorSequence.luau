return {
	run = function(colorSequenece: ColorSequence, intermediateSerializedData)
		local serializedKeypoints = {}

		for _, keypoint in colorSequenece.Keypoints do
			table.insert(serializedKeypoints, {
				keypoint.Time,
				keypoint.Value.R,
				keypoint.Value.G,
				keypoint.Value.B,
			})
		end

		intermediateSerializedData.keypoints = serializedKeypoints
	end,
}
