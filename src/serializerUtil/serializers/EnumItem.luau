return {
	run = function(enumItem: EnumItem, intermediateSerializedData)
		intermediateSerializedData.value = enumItem.Value
		intermediateSerializedData.name = enumItem.Name
	end,
}
