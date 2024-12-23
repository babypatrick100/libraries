return {
	run = function(serializedNumberSequenceKeypoint)
		return NumberSequenceKeypoint.new(table.unpack(serializedNumberSequenceKeypoint.components))
	end,
}
