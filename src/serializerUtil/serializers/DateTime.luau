return {
	run = function(dateTime: DateTime, intermediateSerializedData)
		intermediateSerializedData.unixTimestamp = dateTime.UnixTimestamp
	end,
}
