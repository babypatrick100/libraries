local enums = Enum:GetEnums()
local enumItems = {}

for _, enum in enums do
	for _, enumItem in enum:GetEnumItems() do
		table.insert(enumItems, enumItem)
	end
end

return {
	run = function(serializedEnumItem)
		for _, enumItem in enumItems do
			if
				enumItem.Value == serializedEnumItem.value
				and enumItem.Name == serializedEnumItem.name
			then
				return enumItem
			end
		end

		return nil
	end,
}
