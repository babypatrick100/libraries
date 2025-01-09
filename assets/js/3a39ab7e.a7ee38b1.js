"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[866],{42573:e=>{e.exports=JSON.parse('{"functions":[{"name":"playerGroupRankPromise","desc":"Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the group rank of the player in the given group. If the group rank\\ncouldn\'t be retrieved, then the promise will reject with [DefaultGroupRank], along with the error message.\\n\\n```lua\\nplayerUtil.playerGroupRankPromise(2981707497, 1):andThen(function(groupRank)\\n\\tprint(groupRank)\\nend):catch(function(defaultGroupRank, errorMessage)\\n\\tprint(groupRank, tostring(errorMessage))\\nend)\\n```","params":[{"name":"playerUserId","desc":"","lua_type":"number"},{"name":"groupId","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"Promise<number>"}],"function_type":"static","source":{"line":71,"path":"src/playerUtil/init.luau"}},{"name":"playerIsFriendsWithPromise","desc":" \\n\\nA promisified wrapper over [Player:IsFriendsWith](https://create.roblox.com/docs/reference/engine/classes/Player#IsFriendsWith).\\nIf the promise rejects, it will reject with (`isFriends` as `false`), along with the error message.\\n\\n```lua\\nplayerUtil.playerIsFriendsWithPromise(2981707497, 27842645):andThen(function(isFriends)\\n\\tprint(isFriends)\\nend):catch(function(isFriends, errorMessage)\\n\\tprint(isFriends, tostring(errorMessage))\\nend)\\n```","params":[{"name":"player","desc":"","lua_type":"Player"},{"name":"userId","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"Promise<boolean>"}],"function_type":"static","source":{"line":103,"path":"src/playerUtil/init.luau"}},{"name":"playerFriendsOnlinePromise","desc":" \\n\\nA promisified wrapper over [Player:GetFriendsOnline](https://create.roblox.com/docs/reference/engine/classes/Player#GetFriendsOnline).\\nIf the promise rejects, it will reject with (`friends` as an empty array i.e `{}`), along with the error message.\\n\\n```lua\\nplayerUtil.playerFriendsOnlinePromise(player, 15):andThen(function(friends)\\n\\tfor _, friend in friends do\\n\\t\\tprint(friend.UserName)\\n\\tend\\nend):catch(function(friends, errorMessage)\\n\\t-- `friends` will be an empty array\\n\\tprint(friends, tostring(errorMessage))\\nend)\\n```","params":[{"name":"player","desc":"","lua_type":"Player"},{"name":"maxFriends","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"Promise<{[string]: any}>"}],"function_type":"static","source":{"line":133,"path":"src/playerUtil/init.luau"}},{"name":"playerGroupRolePromise","desc":" \\n\\nReturns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the group role of the player in the given group. \\nIf the promise rejects, it will reject with (`groupRole` as [DefaultGroupRole]), along with the error message.\\n\\n```lua\\nplayerUtil.playerGroupRolePromise(2981707497, 1):andThen(function(groupRole)\\n\\tprint(groupRole)\\nend):catch(function(defaultGroupRole, errorMessage)\\n\\twarn(tostring(errorMessage))\\nend)\\n```","params":[{"name":"playerUserId","desc":"","lua_type":"number"},{"name":"groupId","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"Promise<string>"}],"function_type":"static","source":{"line":160,"path":"src/playerUtil/init.luau"}},{"name":"playerIsInGroupPromise","desc":" \\n\\nReturns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with a boolean indicating if the given player is in the given group or not. \\nIf the promise rejects, it will reject with (`playerIsInGroup` as `false`), along with the error message.\\n\\n```lua\\nplayerUtil.playerIsInGroupPromise(2981707497, 1):andThen(function(playerIsInGroup)\\n\\tprint(playerIsInGroup)\\nend):catch(function(playerIsInGroup, errorMessage)\\n\\t-- playerIsInGroupPromise will always be false here\\n\\tprint(playerIsInGroupPromise, tostring(errorMessage))\\nend)\\n```","params":[{"name":"playerUserId","desc":"","lua_type":"number"},{"name":"groupId","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"Promise<boolean>"}],"function_type":"static","source":{"line":193,"path":"src/playerUtil/init.luau"}},{"name":"safeChatStatusPromise","desc":"Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved with the safe chat status of the given player.\\nIf the promise rejects, it will reject with (`safeChatStatus` as `playerUtil.PlayerSafeChatStatus.Unknown`), along with the error message.\\n\\n```lua\\nplayerUtil.safeChatStatusPromise(player):andThen(function(safeChatStatus)\\n\\tprint(safeChatStatus == playerUtil.PlayerSafeChatStatus.On)\\nend)\\n```","params":[{"name":"player","desc":"","lua_type":"Player"}],"returns":[{"desc":"","lua_type":"Promise<PlayerSafeChatStatus>"}],"function_type":"static","source":{"line":219,"path":"src/playerUtil/init.luau"}}],"properties":[],"types":[{"name":"PlayerGroupRank","desc":" ","fields":[{"name":"Default","lua_type":"0","desc":""}],"source":{"line":20,"path":"src/playerUtil/init.luau"}},{"name":"PlayerGroupRole","desc":" ","fields":[{"name":"Default","lua_type":"\\"Guest\\"","desc":""}],"source":{"line":26,"path":"src/playerUtil/init.luau"}},{"name":"PlayerSafeChatStatus","desc":"","fields":[{"name":"On","lua_type":"\\"On\\"","desc":""},{"name":"Off","lua_type":"\\"Off\\"","desc":""},{"name":"Unknown","lua_type":"\\"Unknown\\"","desc":""}],"source":{"line":34,"path":"src/playerUtil/init.luau"}}],"name":"playerUtil","desc":" \\n\\nAn utility module for working with players.\\n \\n```lua\\nplayerUtil.playerGroupRolePromise(2981707497, 1):andThen(function(groupRole)\\n\\tprint(groupRole)\\nend):catch(function(defaultGroupRole, errorMessage)\\n\\twarn(tostring(errorMessage))\\nend)\\n```","source":{"line":14,"path":"src/playerUtil/init.luau"}}')}}]);