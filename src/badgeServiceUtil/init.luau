--[=[ 
	@class badgeServiceUtil

	An utility module for working with [BadgeService](https://create.roblox.com/docs/reference/engine/classes/BadgeService).
]=]

--[=[
	@interface BadgeInfo
	@within badgeServiceUtil	
	.Name string
	.Description string
	.IconImageId string
	.IsEnabled boolean
]=]

--[=[
	@interface DEFAULT_BADGE_INFO
	@within badgeServiceUtil	
	@tag Constant

	.Name ""
	.Description ""
	.IconImageId ""
	.IsEnabled false

	:::warning Not Accessible
	Constant, not accesible within `badgeServiceUtil`.
	:::
]=]

local BadgeService = game:GetService("BadgeService")

local Promise = require(script.Parent.Promise)

local DEFAULT_BADGE_INFO = {
	Name = "",
	Description = "",
	IconImageId = "",
	IsEnabled = false,
}

local badgeServiceUtil = {}

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved wih the badge info of the given
	badge id. This is just a wrapper over [BadgeService:GetBadgeInfoAsync](https://create.roblox.com/docs/reference/engine/classes/BadgeService#GetBadgeInfoAsync).
	
	If the promise rejects, it will reject with a **shallow copy** of [DEFAULT_BADGE_INFO] (for `badgeInfo)` 
	and an error message.

	```lua
	badgeServiceUtil.badgeInfoPromise(badgeId):andThen(function(badgeInfo)
	
	end):catch(function(defaultBadgeInfo, errorMessage)
	
	end)
	```

	@return Promise<BadgeInfo>
]=]

function badgeServiceUtil.badgeInfoPromise(badgeId: number)
	return Promise.new(function(resolve, reject)
		local wasSuccessful, response = pcall(BadgeService.GetBadgeInfoAsync, BadgeService, badgeId)

		if wasSuccessful then
			resolve(response)
		else
			reject(table.clone(DEFAULT_BADGE_INFO), response)
		end
	end)
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved wih an array of badge ids the given player owns.
	This is just a wrapper over [BadgeService:GetBadgeInfoAsync](https://create.roblox.com/docs/reference/engine/classes/BadgeService#GetBadgeInfoAsync).

	If the promise rejects, it will reject with an empty table (for `playerOwnedBadgeIds`) and an error message.

	```lua
	badgeServiceUtil.checkPlayerBadgesPromise(playerUserId, badgeIds):andThen(function(playerOwnedBadgeIds)
	
	end):catch(function(playerOwnedBadgeIds, errorMessage)
		-- `playerOwnedBadgeIds` will be an empty array
	end)
	```

	@return Promise<{number}>
]=]

function badgeServiceUtil.checkPlayerBadgesPromise(playerUserId: number, badgeIds: { number })
	return Promise.new(function(resolve, reject)
		local wasSuccessful, response =
			pcall(BadgeService.CheckUserBadgesAsync, BadgeService, playerUserId, badgeIds)

		if wasSuccessful then
			resolve(response)
		else
			reject({}, response)
		end
	end)
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved wih a boolean indicating
	whether or not the given player has the specified badge or not. This is just a wrapper over 
	[BadgeService:UserHasBadgeAsync](https://create.roblox.com/docs/reference/engine/classes/BadgeService#UserHasBadgeAsync).

	If the promise rejects, it will reject with `false` (for `playerHasBadge`) and an error message.

	```lua
	badgeServiceUtil.playerHasBadgePromise(playerUserId, badgeId):andThen(function(playerHasBadge)
	
	end):catch(function(playerHasBadge, errorMessage)
		-- `playerHasBadge` will always be `false` here
	end)
	```

	@return Promise<boolean>
]=]

function badgeServiceUtil.playerHasBadgePromise(playerUserId: number, badgeId: number)
	return Promise.new(function(resolve, reject)
		local wasSuccessful, response =
			pcall(BadgeService.UserHasBadgeAsync, BadgeService, playerUserId, badgeId)

		if wasSuccessful then
			resolve(response)
		else
			reject(false, response)
		end
	end)
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved once the given player
	has being successfully awarded with the given badge. This is just a wrapper over 
	[BadgeService:AwardBadge](https://create.roblox.com/docs/reference/engine/classes/BadgeService#AwardBadge).

	```lua
	badgeServiceUtil.awardBadgeToPlayerPromise(playerUserId, badgeId):andThen(function(playerWasAwardedBadge)
	
	end):catch(function(playerWasAwardedBadge, errorMessage)
		-- `playerWasAwardedBadge` will always be `false` here
	end)
	```
	
	If the promise rejects, it will reject with `false` (for `playerWasAwardedBadge`) and an error message.

	@return Promise<boolean>
]=]

function badgeServiceUtil.awardBadgeToPlayerPromise(playerUserId: number, badgeId: number)
	return Promise.new(function(resolve, reject)
		local wasSuccessful, response =
			pcall(BadgeService.AwardBadge, BadgeService, playerUserId, badgeId)

		if wasSuccessful then
			resolve(response)
		else
			reject(false, response)
		end
	end)
end

return table.freeze(badgeServiceUtil)
