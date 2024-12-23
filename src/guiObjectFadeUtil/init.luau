--[=[
	@class guiObjectFadeUtil

	A utility which implements fading in and out without dealing with issues like having an object
	specific transparency value rather than `0` - `1`.
]=]

local TweenService = game:GetService("TweenService")

local USE_CANVAS_GROUP = false
local DEFAULT_TRANSPARENCY_VALUE_TEXT_FORMAT = `Default%sTransparencyValue`

local connections = {}
local tweenableGuiObjectProperties = {
	[{ "TextLabel", "TextButton", "TextBox" }] = {
		"TextTransparency",
		"BackgroundTransparency",
		"TextStrokeTransparency",
	},

	[{ "ViewportFrame", "ImageButton", "ImageLabel" }] = {
		"ImageTransparency",
		"BackgroundTransparency",
	},

	[{ "Frame" }] = { "BackgroundTransparency" },
	[{ "ScrollingFrame" }] = { "ScrollBarImageTransparency", "BackgroundTransparency" },
	[{ "CanvasGroup" }] = { "GroupTransparency", "BackgroundTransparency" },
	[{ "UIStroke" }] = { "Transparency" },
}

local guiObjectFadeUtil = {}

local function tweenablePropertiesForGuiObject(guiObject: GuiObject): { string }?
	for guiObjectClassNames, properties in tweenableGuiObjectProperties do
		if table.find(guiObjectClassNames, guiObject.ClassName) ~= nil then
			return properties
		end
	end

	return {}
end

--[=[ 
	Fades in the given `guiObject`.
]=]

function guiObjectFadeUtil.fadeIn(guiObject: GuiObject, fadeTime: number)
	local tweenInfo = TweenInfo.new(fadeTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

	local function fadeItemsIn(itemsToFadeIn)
		for _, item in itemsToFadeIn do
			local itemTweenableProperties = tweenablePropertiesForGuiObject(item)
			if itemTweenableProperties == nil then
				continue
			end

			for _, property in itemTweenableProperties do
				local defaultPropertyTransparencyValueName =
					string.format(DEFAULT_TRANSPARENCY_VALUE_TEXT_FORMAT, property)
				local defaultPropertyTransparencyValue =
					item:FindFirstChild(defaultPropertyTransparencyValueName)

				if defaultPropertyTransparencyValue ~= nil then
					TweenService:Create(item, tweenInfo, {
						[property] = defaultPropertyTransparencyValue.Value,
					}):Play()
				else
					local defaultTransparencyValue = Instance.new("NumberValue")
					defaultTransparencyValue.Name = defaultPropertyTransparencyValueName
					defaultTransparencyValue.Value = item[property]
					defaultTransparencyValue.Parent = item

					item[property] = 1
					TweenService:Create(item, tweenInfo, {
						[property] = defaultTransparencyValue.Value,
					}):Play()
				end
			end
		end
	end

	if guiObject:IsA("CanvasGroup") and USE_CANVAS_GROUP then
		for _, property in tweenablePropertiesForGuiObject(guiObject) do
			local defaultPropertyTransparencyValueName =
				string.format(DEFAULT_TRANSPARENCY_VALUE_TEXT_FORMAT, property)
			local defaultPropertyTransparencyValue =
				guiObject:FindFirstChild(defaultPropertyTransparencyValueName)

			if defaultPropertyTransparencyValue ~= nil then
				TweenService:Create(guiObject, tweenInfo, {
					[property] = defaultPropertyTransparencyValue.Value,
				}):Play()
			else
				local defaultTransparencyValue = Instance.new("NumberValue")
				defaultTransparencyValue.Name = defaultPropertyTransparencyValueName
				defaultTransparencyValue.Value = guiObject[property]
				defaultTransparencyValue.Parent = guiObject

				guiObject[property] = 1
				TweenService:Create(guiObject, tweenInfo, {
					[property] = defaultTransparencyValue.Value,
				}):Play()
			end
		end

		return
	end

	local itemsToFadeIn = guiObject:GetDescendants()
	table.insert(itemsToFadeIn, guiObject)
	fadeItemsIn(itemsToFadeIn)

	connections[guiObject] = connections[guiObject] or {}

	table.insert(
		connections[guiObject],
		guiObject.DescendantAdded:Connect(function(descendant)
			fadeItemsIn({ descendant })
		end)
	)
end

--[=[ 
	Fades out the given `guiObject`.
]=]

function guiObjectFadeUtil.fadeOut(guiObject: GuiObject, fadeTime: number, override: number?)
	local tweenInfo = TweenInfo.new(fadeTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local goal = override or 1

	local function fadeItemsOut(itemsToFadeOut)
		for _, item in itemsToFadeOut do
			local itemTweenableProperties = tweenablePropertiesForGuiObject(item)
			if itemTweenableProperties == nil then
				continue
			end

			for _, property in itemTweenableProperties do
				local defaultPropertyTransparencyValueName =
					string.format(DEFAULT_TRANSPARENCY_VALUE_TEXT_FORMAT, property)
				local defaultPropertyTransparencyValue =
					item:FindFirstChild(defaultPropertyTransparencyValueName)

				if defaultPropertyTransparencyValue ~= nil then
					TweenService:Create(item, tweenInfo, {
						[property] = goal,
					}):Play()
				else
					local defaultTransparencyValue = Instance.new("NumberValue")
					defaultTransparencyValue.Name = defaultPropertyTransparencyValueName
					defaultTransparencyValue.Value = item[property]
					defaultTransparencyValue.Parent = item

					TweenService:Create(item, tweenInfo, {
						[property] = goal,
					}):Play()
				end
			end
		end
	end

	if guiObject:IsA("CanvasGroup") and USE_CANVAS_GROUP then
		for _, property in tweenablePropertiesForGuiObject(guiObject) do
			local defaultPropertyTransparencyValueName =
				string.format(DEFAULT_TRANSPARENCY_VALUE_TEXT_FORMAT, property)
			local defaultPropertyTransparencyValue =
				guiObject:FindFirstChild(defaultPropertyTransparencyValueName)

			if defaultPropertyTransparencyValue ~= nil then
				TweenService:Create(guiObject, tweenInfo, {
					[property] = goal,
				}):Play()
			else
				local defaultTransparencyValue = Instance.new("NumberValue")
				defaultTransparencyValue.Name = defaultPropertyTransparencyValueName
				defaultTransparencyValue.Value = guiObject[property]
				defaultTransparencyValue.Parent = guiObject

				TweenService:Create(guiObject, tweenInfo, {
					[property] = goal,
				}):Play()
			end
		end

		return
	end

	local itemsToFadeOut = guiObject:GetDescendants()
	table.insert(itemsToFadeOut, guiObject)
	fadeItemsOut(itemsToFadeOut)

	if connections[guiObject] ~= nil then
		for _, connection in connections[guiObject] do
			connection:Disconnect()
		end

		connections[guiObject] = nil
	end
end

return table.freeze(guiObjectFadeUtil)
