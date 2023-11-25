return {
	run = function(serializedNumberRange)
		return NumberRange.new(table.unpack(serializedNumberRange.components))
	end,
}
