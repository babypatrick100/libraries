"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[4757],{1681:e=>{e.exports=JSON.parse('{"functions":[{"name":"playerGroupRank","desc":" \\nReturns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the group rank of the player in the given group. If the group rank couldn\'t be retrieved,\\nthen the promise will reject with [DefaultGroupRank] and with the error message.\\n\\n```lua\\nplayerUtil.playerGroupRank(2981707497, 1):andThen(function(groupRank)\\n\\tprint(groupRank)\\nend):catch(function(defaultGroupRank, errorMessage)\\n\\tprint(groupRank, tostring(errorMessage))\\nend)\\n```","params":[{"name":"playerUserId","desc":"","lua_type":"number"},{"name":"groupId","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"Promise<groupId: number>"}],"function_type":"static","source":{"line":65,"path":"src/playerUtil/init.luau"}},{"name":"playerIsFriendsWith","desc":" \\nReturns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with a boolean indicating whether or not\\nthe given player is friends with the given `userId`. This is a wrapper over \\n[Player:IsFriendsWith](https://create.roblox.com/docs/reference/engine/classes/Player#IsFriendsWith).\\n\\n```lua\\nplayerUtil.playerIsFriendsWith(2981707497, 27842645):andThen(function(isFriends)\\n\\tprint(isFriends)\\nend):catch(function(isFriends, errorMessage)\\n\\tprint(isFriends, tostring(errorMessage))\\nend)\\n```","params":[{"name":"player","desc":"","lua_type":"Player"},{"name":"userId","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"Promise<boolean>"}],"function_type":"static","source":{"line":98,"path":"src/playerUtil/init.luau"}},{"name":"playerFriendsOnline","desc":" \\nReturns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with an array of fields of info\\nregarding the given player\'s friends. This is a wrapper over \\n[Player:GetFriendsOnline](https://create.roblox.com/docs/reference/engine/classes/Player#GetFriendsOnline).\\n\\n```lua\\nplayerUtil.playerFriendsOnline(player, 15):andThen(function(friends)\\n\\tfor _, friend in friends do\\n\\t\\tprint(friend.UserName)\\n\\tend\\nend):catch(function(friends, errorMessage)\\n\\t-- friends will be an empty array\\n\\tprint(friends, tostring(errorMessage))\\nend)\\n```","params":[{"name":"player","desc":"","lua_type":"Player"},{"name":"maxFriends","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"Promise<{...}>"}],"function_type":"static","source":{"line":129,"path":"src/playerUtil/init.luau"}},{"name":"playerGroupRole","desc":" \\nReturns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the group role of the player in the given group. If the group role couldn\'t be retrieved,\\nthen the promise will reject with [DefaultGroupRole] and with the error message.\\n\\n```lua\\nplayerUtil.playerGroupRole(2981707497, 1):andThen(function(groupRole)\\n\\tprint(groupRole)\\nend):catch(function(defaultGroupRole, errorMessage)\\n\\twarn(tostring(errorMessage))\\nend)\\n```","params":[{"name":"playerUserId","desc":"","lua_type":"number"},{"name":"groupId","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"Promise<groupRole: string>"}],"function_type":"static","source":{"line":156,"path":"src/playerUtil/init.luau"}},{"name":"playerIsInGroup","desc":" \\nReturns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with a boolean indicating if the given player is in the given group or not. \\nIf the player\'s group status couldn\'t be retrieved, then the promise will reject with a false value, \\nalong with the error message.\\n\\n```lua\\nplayerUtil.playerIsInGroup(2981707497, 1):andThen(function(playerIsInGroup)\\n\\tprint(playerIsInGroup)\\nend):catch(function(playerIsInGroup, errorMessage)\\n\\t-- playerIsInGroup will always be false here\\n\\tprint(playerIsInGroup, tostring(errorMessage))\\nend)\\n```","params":[{"name":"playerUserId","desc":"","lua_type":"number"},{"name":"groupId","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"Promise<boolean>"}],"function_type":"static","source":{"line":190,"path":"src/playerUtil/init.luau"}},{"name":"safeLoadCharacter","desc":" \\nA simple wrapper over [Player:LoadCharacter](https://create.roblox.com/docs/reference/engine/classes/Player#LoadCharacter), except that it handles the necessary edge cases\\nto ensure smooth player character loading.\\n\\n:::note Player character loading queue\\nPlayer character loadings are queued; so if you call this method for a player while it was\\npreviously called for the same player (and that operation has not yet completed), then the \\nnew call will not load the player\'s character until the previous player character load call\\nhas finished.\\n\\n```lua\\nplayerUtil.safeLoadCharacter(player) \\nplayerUtil.safeLoadCharacter(player) -- This operation won\'t load the character until the above call finishes loading the character.\\n```\\n:::\\n\\n```lua\\nplayerUtil.safeLoadCharacter(player):andThen(function(newPlayerCharacter)\\n\\tprint(newPlayerCharacter)\\nend):catch(function(errorMessage)\\n\\tprint(tostring(errorMessage))\\nend)\\n```","params":[{"name":"player","desc":"","lua_type":"Player"}],"returns":[{"desc":"","lua_type":"Promise<Model>"}],"function_type":"static","source":{"line":230,"path":"src/playerUtil/init.luau"}},{"name":"safeChatStatus","desc":"Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the safe chat status of the given player.\\n\\n```lua\\nplayerUtil.safeChatStatus(player):andThen(function(safeChatStatus)\\n\\tprint(safeChatStatus == playerUtil.playerSafeChatStatus.on)\\nend)\\n```","params":[{"name":"player","desc":"","lua_type":"Player"}],"returns":[{"desc":"","lua_type":"Promise<\\"on\\" | \\"off\\" | \\"unknown\\">"}],"function_type":"static","source":{"line":279,"path":"src/playerUtil/init.luau"}}],"properties":[{"name":"defaultPlayerGroupRank","desc":" ","lua_type":"0","source":{"line":19,"path":"src/playerUtil/init.luau"}},{"name":"defaultPlayerGroupRole","desc":" ","lua_type":"\\"Guest\\"","source":{"line":24,"path":"src/playerUtil/init.luau"}}],"types":[{"name":"playerSafeChatStatus","desc":"","fields":[{"name":"on","lua_type":"string","desc":""},{"name":"off","lua_type":"string","desc":""},{"name":"unknown","lua_type":"string","desc":""}],"source":{"line":32,"path":"src/playerUtil/init.luau"}}],"name":"playerUtil","desc":" \\n\\nAn utility module for working with players.\\n \\n```lua\\nplayerUtil.playerGroupRole(2981707497, 1):andThen(function(groupRole)\\n\\tprint(groupRole)\\nend):catch(function(defaultGroupRole, errorMessage)\\n\\twarn(tostring(errorMessage))\\nend)\\n```","source":{"line":14,"path":"src/playerUtil/init.luau"}}')}}]);