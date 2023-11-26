"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[2113],{77010:e=>{e.exports=JSON.parse('{"functions":[{"name":"badgeInfo","desc":"Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved wih the badge info of the given\\nbadge id. This is just a wrapper over [BadgeService:GetBadgeInfoAsync](https://create.roblox.com/docs/reference/engine/classes/BadgeService#GetBadgeInfoAsync).","params":[{"name":"badgeId","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"Promise<BadgeInfo>"}],"function_type":"static","source":{"line":34,"path":"src/badgeServiceUtil/init.luau"}},{"name":"playerHasBadge","desc":"Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved wih a boolean indicating\\nwhether or not the given player has the specified badge or not. This is just a wrapper over \\n[BadgeService:UserHasBadgeAsync](https://create.roblox.com/docs/reference/engine/classes/BadgeService#UserHasBadgeAsync).\\n\\n```lua\\nlocal wasSuccessful, playerHasBadge, errorMessage = badgeServiceUtil.playerHasBadge(\\n\\t123, 123\\n):await()\\n```\\n\\n:::note\\nIncase the promise is rejected, `playerHasBadge` will always be `false`.\\n:::","params":[{"name":"playerUserId","desc":"","lua_type":"number"},{"name":"badgeId","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"Promise<boolean>"}],"function_type":"static","source":{"line":58,"path":"src/badgeServiceUtil/init.luau"}},{"name":"awardBadgeToPlayer","desc":"Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved once the given player\\nhas being successfully awarded with the given badge. This is just a wrapper over \\n[BadgeService:AwardBadge](https://create.roblox.com/docs/reference/engine/classes/BadgeService#AwardBadge).\\n\\n```lua\\nlocal wasSuccessful, errorMessage = badgeServiceUtil.awardBadgeToPlayer(123, 123):await()\\n```","params":[{"name":"playerUserId","desc":"","lua_type":"number"},{"name":"badgeId","desc":"","lua_type":"number"}],"returns":[{"desc":"","lua_type":"Promise<boolean>"}],"function_type":"static","source":{"line":83,"path":"src/badgeServiceUtil/init.luau"}}],"properties":[],"types":[{"name":"BadgeInfo","desc":"","fields":[{"name":"Name","lua_type":"string","desc":""},{"name":"Description","lua_type":"boolean","desc":""},{"name":"IconImageId","lua_type":"number","desc":""},{"name":"IsEnabled","lua_type":"boolean","desc":""}],"source":{"line":21,"path":"src/badgeServiceUtil/init.luau"}}],"name":"badgeServiceUtil","desc":" \\n\\nAn utility module for working with [BadgeService](https://create.roblox.com/docs/reference/engine/classes/BadgeService).\\n \\n```lua\\nlocal wasSuccessful, playerHasBadge, errorMessage = badgeServiceUtil.playerHasBadge(\\n\\t2981707497, 123\\n):await()\\n```","source":{"line":12,"path":"src/badgeServiceUtil/init.luau"}}')}}]);