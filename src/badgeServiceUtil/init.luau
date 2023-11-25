--[=[ 
	@class badgeServiceUtil

	An utility module for working with [BadgeService](https://create.roblox.com/docs/reference/engine/classes/BadgeService).
 
	```lua
	local wasSuccessful, playerHasBadge, errorMessage = badgeServiceUtil.playerHasBadge(
		2981707497, 123
	):await()
	```
]=]

--[=[
	@interface BadgeInfo
	@within badgeServiceUtil	
	.Name string
	.Description boolean
	.IconImageId number
	.IsEnabled boolean
]=]

local BadgeService = game:GetService("BadgeService")

local Promise = require(script.Parent.Promise)

local badgeServiceUtil = {}

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved wih the badge info of the given
	badge id. This is just a wrapper over [BadgeService:GetBadgeInfoAsync](https://create.roblox.com/docs/reference/engine/classes/BadgeService#GetBadgeInfoAsync).

	@return Promise<BadgeInfo>
]=]

function badgeServiceUtil.badgeInfo(badgeId: number)
	return Promise.new(function(resolve)
		resolve(BadgeService:GetBadgeInfoAsync(badgeId))
	end)
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved wih a boolean indicating
	whether or not the given player has the specified badge or not. This is just a wrapper over 
	[BadgeService:UserHasBadgeAsync](https://create.roblox.com/docs/reference/engine/classes/BadgeService#UserHasBadgeAsync).

	```lua
	local wasSuccessful, playerHasBadge, errorMessage = badgeServiceUtil.playerHasBadge(
		123, 123
	):await()
	```

	:::note
	Incase the promise is rejected, `playerHasBadge` will always be `false`.
	:::

	@return Promise<boolean>
]=]

function badgeServiceUtil.playerHasBadge(playerUserId: number, badgeId: number)
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
	local wasSuccessful, errorMessage = badgeServiceUtil.awardBadgeToPlayer(123, 123):await()
	```

	@return Promise<boolean>
]=]

function badgeServiceUtil.awardBadgeToPlayer(playerUserId: number, badgeId: number)
	return Promise.new(function(resolve)
		resolve(BadgeService:AwardBadge(playerUserId, badgeId))
	end)
end

return table.freeze(badgeServiceUtil)
