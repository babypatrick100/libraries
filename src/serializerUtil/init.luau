--[=[
	@class serializerUtil

	A very simple utility for serializing and deserializing data types.

	:::note This utility supports the following data types: 
	- CFrame
	- Vector3
	- Vector2
	- BrickColor
	- Color3
	- Enum
	- EnumItem
	- Axes
	- CatalogSearchParams
	- ColorSequence
	- ColorSequenceKeypoint
	- NumberSequence
	- NumberSequenceKeypoint
	- Faces
	- Axes
	- NumberRange
	- PathWaypoint
	- Region3
	- Region3init16
	- TweenInfo
	- UDim
	- UDim2
	- Vector3int16
	- Vector2int16
	- Region3int16
	- Font
	- Rect
	- DateTime
	- PhysicalProperties
	:::
]=]

--[=[ 
	@type ClassDataType {valueType: any, serializer: (value: any, intermediateSerializedData: {}) -> (), deserializer: (serializedData: {}) -> (),} 
	@within serializerUtil
]=]

--[=[ 
	@prop customValueType string
	@within serializerUtil

	A constant to be used as a key in tables, to represent some type which this utility
	can easily know about when serializing and deserializing values.

	```lua
	local spmeTable = {
		-- Allow the serializer utility module to know the "type" of this table
		[serializerUtil.customValueType] = "uniqueType"
	}
	```
]=]

local Loader = require(script.Parent.Loader)

local deserializers = Loader.LoadChildren(script.deserializers)
local serializers = Loader.LoadChildren(script.serializers)

local SERIALIZED_DATA_KEY = "SERIALIZED_DATA"

local serializerUtil = { customValueType = "serDesCustomValueType" }

type ClassDataType = {
	valueType: any,
	serializer: { run: (value: any, intermediateSerializedData: { [any]: any }) -> () },
	deserializer: { run: (serializedData: { [any]: any }) -> any },
}

local function valueIsSerialized(value)
	return typeof(value) == "table" and value[SERIALIZED_DATA_KEY] == true
end

local function valueType(value)
	if typeof(value) == "table" and value[serializerUtil.customValueType] ~= nil then
		return value[serializerUtil.customValueType]
	end

	return typeof(value)
end

--[=[
	Serializes the given vale, if it can be serialized. If it can't be serialized, then the value it self is returned.

	```lua
	local serializedValue = serializerUtil.serializer(150)
	print(serializedValue) --> 150 (can't serialize a number!)
	local serializedValue = serializerUtil.serializer(CFrame.new(5,5,5))
	print(serializedValue) --> {...} (serialized data)
	```
]=]

function serializerUtil.serialize(value: any)
	for serializerType, serializer in serializers do
		local typeOfThisValue = valueType(value)

		if serializerType == typeOfThisValue then
			local intermediateSerializedData = {}
			intermediateSerializedData[SERIALIZED_DATA_KEY] = true
			intermediateSerializedData.valueType = typeOfThisValue
			serializer.run(value, intermediateSerializedData)
			return intermediateSerializedData
		end
	end

	return value
end

--[=[
	Deserializes the given serialized value, if it can be deserialized. If it can't be deserialized, then the value
	it self is returned.

	```lua
	local serializedValue = serializerUtil.serializer(CFrame.new(5,5,5))
	print(serializerUtil.deserialize(serializedValue)) --> CFrame (5,5,5) 
	print(serializerUtil.deserialize(15)) --> 15 (Can't deserialize a non-serialized value)
	```
]=]

function serializerUtil.deserialize(serializedData: any)
	if not valueIsSerialized(serializedData) then
		return serializedData
	end

	local valueType = serializedData.valueType

	for serializerType, deserializer in deserializers do
		if serializerType == valueType then
			return deserializer.run(serializedData)
		end
	end

	return nil
end

--[=[
	Adds a class data type to the serializer. A class data type (in the context of this utility) is simply
	an object which you can use to add your own custom serializers and deserializers.

	```lua
	-- In this project X, we have a funny which we would like to serialize
	-- and deserialize according to how our game is structured;
	local someUniqueTable = {
		[serializerUtil.customValueType] = "TheUniqueTable"
	}

	serializerUtil.addClassDataType({
		valueType = "TheUniqueTable",
		serializer = {
			run = function(uniqueTable, intermediateSerializedData)
				intermediateSerializedData.component = {1, 2, 3, 4, 5, 6}
			end,
		},
		deserializer = {
			run = function(serializedUniqueTable)
				return serializedUniqueTable.component
			end,
		},
	})

	local serializedTable = serializerUtil.serialize(someUniqueTable)
	print(serializerUtil.deserialize(serializedTable)) --> {1, 2, 3, 4, 5, 6}
	```

	:::tip Override default data types
	Currently this utility supports a lot of data types to serialize and serialize - however
	you can override them too with your own serializers and deserializers for them, for e.g:

	```lua
	-- Let's just override the serializer and deserializer for the `Vector3` data type
	-- in favour of our own:
	serializerUtil.addClassDataType({
		valueType = "Vector3",
		serializer = {
			run = function(vector3, intermediateSerializedData)
				intermediateSerializedData.components = {vector3.X, vector3.Y, vector3.Z}
			end,
		},
		deserializer = {
			run = function(serializedVector3)
				return Vector3.new(table.unpack(serializedVector3.components))
			end,
		},
	})
	```

	This gives you flexibility to append your own serializer and deserializer for specific data types
	as per your game's need!
	:::
]=]

function serializerUtil.addClassDataType(classDataType: ClassDataType)
	local valueTypeForClassDataType = classDataType.valueType
	local serializer = classDataType.serializer
	local deserializer = classDataType.deserializer

	serializers[valueTypeForClassDataType] = serializer
	deserializers[valueTypeForClassDataType] = deserializer

	return nil
end

--[=[
	Shorthand for adding multiple class data types in 1 go. [serializerUtil.addClass] is called
	for every class data type in `classDataTypes`.

	```lua
	local classDataTypes = {
		{
			valueType = "Vector3",
			serializer = {
				run = function(vector3, intermediateSerializedData)
					intermediateSerializedData.components = {vector3.X, vector3.Y, vector.Z}
				end,
			},
			deserializer = {
				run = function(serializedVector3)
					return Vector3.new(table.unpack(serializedVector3.components))
				end,
			},
		},

		{
			valueType = "Vector2",
			serializer = {
				run = function(vector2, intermediateSerializedData)
					intermediateSerializedData.components = {vector2.X, vector2.Y}
				end,
			},
			deserializer = {
				run = function(serializedVector2)
					return Vector2.new(table.unpack(serializedVector2.components))
				end,
			},
		}
	}

	serializerUtil.addClassDataTypes(classDataTypes)
	```
]=]

function serializerUtil.addClassDataTypes(classDataTypes: { ClassDataType })
	for _, classDataType in classDataTypes do
		serializerUtil.addClassDataType(classDataType)
	end
end

--[=[
	Deep serializes all keys and values in the given table via [serializerUtil.serialize].

	```lua
	local tabl = {bo = Enum.Keycode.A}
	local serializedTable = serializerUtil.serializeTableDeep(tabl)
	print(serializedTable) --> {bo: {...}} (serialized)
	```
]=]

function serializerUtil.serializeTableDeep(deserializedTable: { [any]: any })
	local serializedTable = {}

	for key, value in deserializedTable do
		if not valueIsSerialized(value) then
			if typeof(value) == "table" then
				value = serializerUtil.serializeTableDeep(value)
			else
				value = serializerUtil.serialize(value)
			end
		end

		if not valueIsSerialized(key) then
			if typeof(key) == "table" then
				key = serializerUtil.serializeTableDeep(key)
			else
				key = serializerUtil.serialize(key)
			end
		end

		serializedTable[key] = value
	end

	return serializedTable
end

--[=[
	Deep - deserializes all keys and values in the given table via [serializerUtil.deserialize].

	```lua
	local tabl = {bo = Enum.Keycode.A}
	local serializedTable = serializerUtil.serializeTableDeep(tabl)
	print(serializerUtil.deserializeTableDeep(serializedTable)) --> {bo: Enum.Keycode.A} (deserialized)
	```
]=]

function serializerUtil.deserializeTableDeep(serializedTable: { [any]: any })
	local deserializedTable = {}

	for key, value in serializedTable do
		if valueIsSerialized(value) then
			if value.valueType == "table" then
				value = serializerUtil.deserializeTableDeep(value)
			else
				value = serializerUtil.deserialize(value)
			end
		elseif typeof(value) == "table" then
			value = serializerUtil.deserializeTableDeep(value)
		end

		if valueIsSerialized(key) then
			if key.valueType == "table" then
				key = serializerUtil.deserializeTableDeep(key)
			else
				key = serializerUtil.deserialize(key)
			end
		elseif typeof(key) == "table" then
			key = serializerUtil.deserializeTableDeep(key)
		end

		deserializedTable[key] = value
	end

	return deserializedTable
end

return table.freeze(serializerUtil)
