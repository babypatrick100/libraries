--[=[ 
	@class playerUtil

	An utility module for working with players.
 
	```lua
	playerUtil.playerGroupRolePromise(2981707497, 1):andThen(function(groupRole)
		print(groupRole)
	end):catch(function(defaultGroupRole, errorMessage)
		warn(tostring(errorMessage))
	end)
	```
]=]

--[=[ 
	@interface PlayerGroupRank
	@within playerUtil
	.Default 0
]=]

--[=[ 
	@interface PlayerGroupRole
	@within playerUtil
	.Default "Guest"
]=]

--[=[
	@interface PlayerSafeChatStatus  
	@within playerUtil	
	.On "On"
	.Off "Off"
	.Unknown "Unknown"
]=]

local GroupService = game:GetService("GroupService")

local Promise = require(script.Parent.Promise)
local Sift = require(script.Parent.Sift)
local playerPolicyInfoUtil = require(script.Parent.playerPolicyInfoUtil)

local playerUtil = {
	PlayerSafeChatStatus = {
		On = "On",
		Off = "Off",
		Unknown = "Unknown",
	},

	PlayerGroupRank = {
		Default = 0,
	},

	PlayerGroupRole = {
		Default = "Guest",
	},
}

--[=[
	@return Promise<number>

	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the group rank of the player in the given group. If the group rank
	couldn't be retrieved, then the promise will reject with [DefaultGroupRank], along with the error message.

	```lua
	playerUtil.playerGroupRankPromise(2981707497, 1):andThen(function(groupRank)
		print(groupRank)
	end):catch(function(defaultGroupRank, errorMessage)
		print(groupRank, tostring(errorMessage))
	end)
	```
]=]

function playerUtil.playerGroupRankPromise(playerUserId: number, groupId: number)
	return Promise.new(function(resolve, reject)
		local wasSuccessful, response =
			pcall(GroupService.GetGroupsAsync, GroupService, playerUserId, groupId)

		if wasSuccessful then
			local result = response[Sift.Array.findWhere(response, function(groupInfo)
				return groupInfo.Id == groupId
			end)]

			resolve(if result then result.Rank else playerUtil.PlayerGroupRank.Default)
		else
			reject(playerUtil.PlayerGroupRank.Default, response)
		end
	end)
end

--[=[ 
	@return Promise<boolean>

	A promisified wrapper over [Player:IsFriendsWith](https://create.roblox.com/docs/reference/engine/classes/Player#IsFriendsWith).
	If the promise rejects, it will reject with (`isFriends` as `false`), along with the error message.

	```lua
	playerUtil.playerIsFriendsWithPromise(2981707497, 27842645):andThen(function(isFriends)
		print(isFriends)
	end):catch(function(isFriends, errorMessage)
		print(isFriends, tostring(errorMessage))
	end)
	```
]=]

function playerUtil.playerIsFriendsWithPromise(player: Player, userId: number)
	return Promise.new(function(resolve, reject)
		local wasSuccessful, response = pcall(player.IsFriendsWith, player, userId)

		if wasSuccessful then
			resolve(response)
		else
			reject(false, response)
		end
	end)
end

--[=[ 
	@return Promise<{[string]: any}>

	A promisified wrapper over [Player:GetFriendsOnline](https://create.roblox.com/docs/reference/engine/classes/Player#GetFriendsOnline).
	If the promise rejects, it will reject with (`friends` as an empty array i.e `{}`), along with the error message.

	```lua
	playerUtil.playerFriendsOnlinePromise(player, 15):andThen(function(friends)
		for _, friend in friends do
			print(friend.UserName)
		end
	end):catch(function(friends, errorMessage)
		-- `friends` will be an empty array
		print(friends, tostring(errorMessage))
	end)
	```
]=]

function playerUtil.playerFriendsOnlinePromise(player: Player, maxFriends: number)
	return Promise.new(function(resolve, reject)
		local wasSuccessful, response = pcall(player.GetFriendsOnline, player, maxFriends)

		if wasSuccessful then
			resolve(response)
		else
			reject({}, response)
		end
	end)
end

--[=[ 
	@return Promise<string>

	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the group role of the player in the given group. 
	If the promise rejects, it will reject with (`groupRole` as [DefaultGroupRole]), along with the error message.

	```lua
	playerUtil.playerGroupRolePromise(2981707497, 1):andThen(function(groupRole)
		print(groupRole)
	end):catch(function(defaultGroupRole, errorMessage)
		warn(tostring(errorMessage))
	end)
	```
]=]

function playerUtil.playerGroupRolePromise(playerUserId: number, groupId: number)
	return Promise.new(function(resolve, reject)
		local wasSuccessful, response =
			pcall(GroupService.GetGroupsAsync, GroupService, playerUserId, groupId)

		if wasSuccessful then
			local result = response[Sift.Array.findWhere(response, function(groupInfo)
				return groupInfo.Id == groupId
			end)]

			resolve(if result ~= nil then result.Role else playerUtil.PlayerGroupRole.Default)
		else
			reject(playerUtil.PlayerGroupRole.Default, response)
		end
	end)
end

--[=[ 
	@return Promise<boolean>

	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with a boolean indicating if the given player is in the given group or not. 
	If the promise rejects, it will reject with (`playerIsInGroup` as `false`), along with the error message.

	```lua
	playerUtil.playerIsInGroupPromise(2981707497, 1):andThen(function(playerIsInGroup)
		print(playerIsInGroup)
	end):catch(function(playerIsInGroup, errorMessage)
		-- playerIsInGroupPromise will always be false here
		print(playerIsInGroupPromise, tostring(errorMessage))
	end)
	```
]=]

function playerUtil.playerIsInGroupPromise(playerUserId: number, groupId: number)
	return Promise.new(function(resolve, reject)
		local playerGroupRankSuccessfullyRetrieved, playerGroupRankPromise, errorMessage =
			playerUtil.playerGroupRankPromise(playerUserId, groupId):await()

		if playerGroupRankSuccessfullyRetrieved then
			resolve(playerGroupRankPromise > playerUtil.PlayerGroupRank.Default)
		else
			reject(false, errorMessage)
		end
	end)
end

--[=[
	@return Promise<PlayerSafeChatStatus>
	
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the safe chat status of the given player.
	If the promise rejects, it will reject with (`safeChatStatus` as `playerUtil.PlayerSafeChatStatus.Unknown`), along with the error message.

	```lua
	playerUtil.safeChatStatusPromise(player):andThen(function(safeChatStatus)
		print(safeChatStatus == playerUtil.PlayerSafeChatStatus.On)
	end)
	```
]=]

function playerUtil.safeChatStatusPromise(player: Player)
	return Promise.new(function(resolve, reject)
		local playerPolicyInfoRetrievalWasSuccessful, playerPolicyInfo =
			playerPolicyInfoUtil.playerPolicyInfoPromise(player):await()

		if not playerPolicyInfoRetrievalWasSuccessful then
			reject(playerUtil.PlayerSafeChatStatus.Unknown, playerPolicyInfo)
			return
		end

		if
			not table.find(playerPolicyInfo.AllowedExternalLinkReferences, "Discord")
			and playerPolicyInfo.IsSubjectToChinaPolicies
		then
			resolve(playerUtil.PlayerSafeChatStatus.Unknown)
		elseif not table.find(playerPolicyInfo.AllowedExternalLinkReferences, "Discord") then
			resolve(playerUtil.PlayerSafeChatStatus.On)
		else
			resolve(playerUtil.PlayerSafeChatStatus.Off)
		end
	end)
end

return table.freeze(playerUtil)
