"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[9849],{33447:e=>{e.exports=JSON.parse('{"functions":[{"name":"enable","desc":" \\nEnables the rain.","params":[{"name":"tweenInfo","desc":"","lua_type":"TweenInfo?"}],"returns":[],"function_type":"static","source":{"line":783,"path":"src/rain/init.luau"}},{"name":"disable","desc":" \\nDisables the rain.","params":[{"name":"tweenInfo","desc":"","lua_type":"TweenInfo?"}],"returns":[],"function_type":"static","source":{"line":827,"path":"src/rain/init.luau"}},{"name":"setColor","desc":" \\nSets the rain color.","params":[{"name":"value","desc":"","lua_type":"Color3"},{"name":"tweenInfo","desc":"","lua_type":"TweenInfo?"}],"returns":[],"function_type":"static","source":{"line":860,"path":"src/rain/init.luau"}},{"name":"color","desc":" \\nReturns the current rain color value.","params":[],"returns":[],"function_type":"static","source":{"line":881,"path":"src/rain/init.luau"}},{"name":"transparency","desc":" \\nReturns the current rain transparency value.","params":[],"returns":[],"function_type":"static","source":{"line":889,"path":"src/rain/init.luau"}},{"name":"ceiling","desc":" \\nReturns the current rain ceiling value.","params":[],"returns":[],"function_type":"static","source":{"line":897,"path":"src/rain/init.luau"}},{"name":"setTransparency","desc":" \\n\\nSets the transparency of the rain.","params":[{"name":"transparency","desc":"","lua_type":"number"}],"returns":[],"function_type":"static","source":{"line":942,"path":"src/rain/init.luau"}},{"name":"setTransparency","desc":" \\n\\nSets the speed ratio of the rain.","params":[{"name":"speedRatio","desc":"","lua_type":"number"}],"returns":[],"function_type":"static","source":{"line":952,"path":"src/rain/init.luau"}},{"name":"setTransparency","desc":" \\n\\nSets the intensity ratio of the rain.","params":[{"name":"intensityRatio","desc":"","lua_type":"number"}],"returns":[],"function_type":"static","source":{"line":962,"path":"src/rain/init.luau"}},{"name":"setTransparency","desc":" \\n\\nSets the light emission of the rain.","params":[{"name":"lightEmission","desc":"","lua_type":"number"}],"returns":[],"function_type":"static","source":{"line":972,"path":"src/rain/init.luau"}},{"name":"setTransparency","desc":" \\n\\nSets the light influence of the rain.","params":[{"name":"lightInfluence","desc":"","lua_type":"number"}],"returns":[],"function_type":"static","source":{"line":982,"path":"src/rain/init.luau"}},{"name":"setVolume","desc":" \\nSets the volume of the rain sound.","params":[{"name":"volume","desc":"","lua_type":"number"},{"name":"tweenInfo","desc":"","lua_type":"TweenInfo?"}],"returns":[],"function_type":"static","source":{"line":988,"path":"src/rain/init.luau"}},{"name":"setSoundGroup","desc":" \\nSets the sound group of the rain sound by first cloning a copy of it, and then setting the cloned variant\'s sound\\ngroup to `newSoundGroup`, and the old variant is destroyed.","params":[{"name":"newSoundGroup","desc":"","lua_type":"SoundGroup"}],"returns":[],"function_type":"static","source":{"line":1010,"path":"src/rain/init.luau"}},{"name":"direction","desc":" \\nReturns the direction of the rain.","params":[],"returns":[{"desc":"","lua_type":"Vector3\\r\\n"}],"function_type":"static","source":{"line":1020,"path":"src/rain/init.luau"}},{"name":"setDirection","desc":" \\nSets the direction of the rain.","params":[{"name":"direction","desc":"","lua_type":"Vector3"},{"name":"tweenInfo","desc":"","lua_type":"TweenInfo?"}],"returns":[],"function_type":"static","source":{"line":1028,"path":"src/rain/init.luau"}},{"name":"setCeiling","desc":" \\nSets the ceiling of the rain.","params":[{"name":"ceiling","desc":"","lua_type":"number"}],"returns":[],"function_type":"static","source":{"line":1063,"path":"src/rain/init.luau"}},{"name":"setStraightTexture","desc":" \\nSets the straight texture of the rain.","params":[{"name":"asset","desc":"","lua_type":"string"}],"returns":[],"function_type":"static","source":{"line":1075,"path":"src/rain/init.luau"}},{"name":"setTopDownTexture","desc":" \\nSets the top down texture of the rain.","params":[{"name":"asset","desc":"","lua_type":"string"}],"returns":[],"function_type":"static","source":{"line":1094,"path":"src/rain/init.luau"}},{"name":"setSplashTexture","desc":" \\nSets the splash texture of the rain.","params":[{"name":"asset","desc":"","lua_type":"string"}],"returns":[],"function_type":"static","source":{"line":1113,"path":"src/rain/init.luau"}},{"name":"setSoundId","desc":" \\nSets the sound id of the rain sound.","params":[{"name":"asset","desc":"","lua_type":"string"}],"returns":[],"function_type":"static","source":{"line":1130,"path":"src/rain/init.luau"}},{"name":"setConfig","desc":" \\nSets the rain config.","params":[{"name":"config","desc":"","lua_type":"{\\r\\n\\tceiling: number?,\\r\\n\\tintensityRatio: number?,\\r\\n\\tdirection: Vector3?,\\r\\n\\tsplashTexture: string?,\\r\\n\\ttopDownTexture: string?,\\r\\n\\tvolume: number?,\\r\\n\\tstraightTexture: string?,\\r\\n\\tsoundId: string?,\\r\\n\\ttransparency: number?,\\r\\n\\tlightEmission: string?,\\r\\n\\tlightInfluence: string?,\\r\\n\\tcolor: Color3?,\\r\\n\\tspeedRatio: number?,\\r\\n\\tcollisionMode: string,\\r\\n\\tcollisionModeFunction: CollisonModeFunction?,\\r\\n}"}],"returns":[],"function_type":"static","source":{"line":1142,"path":"src/rain/init.luau"}},{"name":"setCollisionMode","desc":" \\n\\nSets the rain collision mode. \\n\\n```lua\\n-- Example uses:\\n\\n-- 1)\\nrain.setCollisionMode(rain.CollisionMode.callback, function(basePart)\\n\\treturn not basePart.CanCollide\\nend)\\n\\n-- 2)\\nrain.setCollisionMode(rain.CollisionMode.whitelist, {Workspace.Baseplate})\\n\\n-- 3)\\nrain.setCollisionMode(rain.CollisionMode.blacklist, {Workspace.Baseplate})\\n```","params":[{"name":"mode","desc":"","lua_type":"CollisionMode"},{"name":"param","desc":"","lua_type":"{ Instance } | Instance | CollisonModeFunction"}],"returns":[],"function_type":"static","source":{"line":1255,"path":"src/rain/init.luau"}}],"properties":[{"name":"enabled","desc":" \\n\\nA [Property](https://babypatrick100.github.io/libraries/api/Property/) object that contains a value on whether the rain is enabled or not.","lua_type":"Property","source":{"line":1357,"path":"src/rain/init.luau"}}],"types":[{"name":"CollisonModeFunction","desc":"A predicate which is called automatically and is passed a base part as the only\\nargument. \\n\\n- If the predicate returns a *truthy* value, then the rain will hit the given\\nbase part.\\n\\n- If the predicate returns a non *truthy* value, then the rain will NOT\\nhit the given basepart.","lua_type":"((basePart: BasePart) -> boolean)?","source":{"line":371,"path":"src/rain/init.luau"}},{"name":"CollisionMode","desc":"- If `rain.CollisionMode.whitelist` is passed as the first argument to [rain.SetCollisionMode], you can pass in a base part or an array of base parts\\nto be hit by the rain **only**.\\n\\n- If `rain.CollisionMode.blacklist` is passed as the first argument to [rain.SetCollisionMode], you can pass in a base part or an array of base parts\\nto NOT be hit by the rain.\\n\\n- If `rain.CollisionMode.callback` is passed as the first argument to [rain.SetCollisionMode], you can pass in a predicate [`CollisionModeFunction`]\\nthat can return a boolean value.","fields":[{"name":"callback","lua_type":"3?","desc":""},{"name":"blacklist","lua_type":"2?","desc":""},{"name":"whitelist","lua_type":"1","desc":""},{"name":"none","lua_type":"0","desc":""}],"source":{"line":1234,"path":"src/rain/init.luau"}}],"name":"rain","desc":"Rain module by builthomas, *heavily modified and refactored by bubshurb*.","source":{"line":6,"path":"src/rain/init.luau"}}')}}]);