--[=[ 
	@class textServiceUtil

	Wrapper for [TextService](https://create.roblox.com/docs/reference/engine/classes/TextService).
]=]

local TextService = game:GetService("TextService")

local Promise = require(script.Parent.Promise)

local textServiceUtil = {}

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the filtered
	string, to be displayed to all users.

	@return Promise<string>
]=]

function textServiceUtil.filterStringForBroadcastPromise(
	string: string,
	playerUserId: string,
	textFilterContext: Enum.TextFilterContext
)
	return Promise.new(function(resolve)
		local filterResult = TextService:FilterStringAsync(string, playerUserId, textFilterContext)
		local filteredString = filterResult:GetNonChatStringForBroadcastAsync()
		resolve(filteredString)
	end)
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the
	given string filtered in a manner appropriate for the passed user.

	@return Promise<string>
]=]

function textServiceUtil.filterStringForUserPromise(
	string: string,
	playerUserId: string,
	textFilterContext: Enum.TextFilterContext
)
	return Promise.new(function(resolve)
		local filterResult = TextService:FilterStringAsync(string, playerUserId, textFilterContext)
		local filteredString = filterResult:GetNonChatStringForUserAsync(playerUserId)
		resolve(filteredString)
	end)
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the 
	string filtered in the **least** restrictive manner appropriate for the given user.

	@return Promise<string>
]=]

function textServiceUtil.filterStringForUserChatPromise(
	string: string,
	playerUserId: string,
	textFilterContext: Enum.TextFilterContext
)
	return Promise.new(function(resolve)
		local filterResult = TextService:FilterStringAsync(string, playerUserId, textFilterContext)
		local filteredString = filterResult:GetChatForUserAsync(playerUserId)
		resolve(filteredString)
	end)
end

--[=[
	Wraps [TextService:GetFamilyInfoAsync](https://create.roblox.com/docs/reference/engine/classes/TextService#GetFamilyInfoAsync) into a promise.

	@return Promise<{FaceInfo: FaceInfo}>
]=]

function textServiceUtil.familyInfoPromise(assetId: string)
	return Promise.new(function(resolve)
		resolve(TextService:GetFamilyInfoAsync(assetId))
	end)
end

--[=[
	Wraps [TextService:GetTextSizeOffsetAsync](https://create.roblox.com/docs/reference/engine/classes/TextService#GetTextSizeOffsetAsync) into a promise.

	@return Promise<Vector2>
]=]

function textServiceUtil.textSizeOffsetPromise(fontSize: number, font: Enum.Font)
	return Promise.new(function(resolve)
		resolve(TextService:GetTextSizeOffsetAsync(fontSize, font))
	end)
end

--[=[
	Wraps [TextService:GetTextBoundsAsync](https://create.roblox.com/docs/reference/engine/classes/TextService#GetTextBoundsAsync) into a promise.

	@return Promise<Vector2>
]=]

function textServiceUtil.textBoundsPromise(params: GetTextBoundsParams)
	return Promise.new(function(resolve)
		resolve(TextService:GetTextBoundsAsync(params))
	end)
end

--[=[
	Wraps [TextService:FilterAndTranslateStringAsync](https://create.roblox.com/docs/reference/engine/classes/TextService#FilterAndTranslateStringAsync) into a promise.

	@return Promise<TextFilterTranslatedResult>
]=]

function textServiceUtil.filterAndTranslateStringPromise(
	stringToFilter: string,
	fromUserId: number,
	targetLocales: {},
	textContext: Enum.TextFilterContext
)
	return Promise.new(function(resolve)
		resolve(
			TextService:FilterAndTranslateStringAsync(
				stringToFilter,
				fromUserId,
				targetLocales,
				textContext
			)
		)
	end)
end

return table.freeze(textServiceUtil)
