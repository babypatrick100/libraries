"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[9212],{48812:n=>{n.exports=JSON.parse('{"functions":[{"name":"playingSoundInstances","desc":"Returns an array of all sound instances that are currently playing.","params":[],"returns":[{"desc":"","lua_type":"{ Sound }\\r\\n"}],"function_type":"static","source":{"line":79,"path":"src/soundUtil/init.luau"}},{"name":"stopAllSoundsOfSoundId","desc":"Stops all playing sounds which have a `SoundId` of `soundId`, via [soundUtil.stopSound].","params":[{"name":"soundId","desc":"","lua_type":"string"}],"returns":[],"function_type":"static","source":{"line":97,"path":"src/soundUtil/init.luau"}},{"name":"playSoundCloneAndCleanup","desc":"Plays a cloned version of the sound and destroys it when it has ended.","params":[{"name":"sound","desc":"","lua_type":"Sound"}],"returns":[],"function_type":"static","source":{"line":111,"path":"src/soundUtil/init.luau"}},{"name":"stopAll","desc":"Stops all playing sounds via [soundUtil.stopSound].","params":[],"returns":[],"function_type":"static","source":{"line":126,"path":"src/soundUtil/init.luau"}},{"name":"playSound","desc":"Plays the given sound instance, if the sound instance has a heartbeat callback registered for it, then\\t\\nthe sound instance will not be played automatically.\\n\\n```lua\\nsoundUtil.registerSoundHeartbeatCallback(someSoundInstance, function(soundInstance, deltaTime)\\n\\tif not soundInstance.Playing then\\n\\t\\tsoundInstance.Volume = 0\\n\\t\\tsoundInstance:Play()\\n\\tend\\n\\t-- Lerp the volume to 1:\\n\\tsoundInstance.Volume += (2 - soundInstance.Volume) * deltaTime\\nend)\\n\\nsoundUtil.playSound(someSoundInstance)\\n```","params":[{"name":"soundInstance","desc":"","lua_type":"Sound"}],"returns":[],"function_type":"static","source":{"line":150,"path":"src/soundUtil/init.luau"}},{"name":"playSound3D","desc":"Plays the given sound at the specified given 3D position or instance. If the sound instance has a heartbeat callback registered for it, \\nthen the sound instance will not be played automatically.\\n\\n```lua\\n-- Usecase: lightning bolt sounds!\\nlocal lightningBoltSound = ...\\nlocal generatedLightningBoltModel = ...\\nsoundUtil.playSound3D(lightningBoltSound, generatedLightningBoltModel.PrimaryPart) \\n```\\n\\n:::note\\nIdeally you should always generally pass in a cloned version of the sound instance so you can\\nreuse it.\\n\\n```lua\\n-- BAD:\\nsoundUtil.playSound3D(someStorage.someRandomSound, workspace.Baseplate)\\nsoundUtil.playSound3D(someStorage.someRandomSound, workspace.ZombiePart) -- PANIC: someStorage.someRandomSound does not exist anymore!\\n\\n-- GOOD:\\noundUtil.playSound3D(someStorage.someRandomSound:Clone(), workspace.Baseplate)\\nsoundUtil.playSound3D(someStorage.someRandomSound:Clone(), workspace.ZombiePart) \\n```\\n:::","params":[{"name":"soundInstance","desc":"","lua_type":"Sound"},{"name":"positionOrBasePart","desc":"","lua_type":"Vector3 | BasePart"}],"returns":[],"function_type":"static","source":{"line":217,"path":"src/soundUtil/init.luau"}},{"name":"stopSound","desc":"Stops the given sound instance. ","params":[{"name":"soundInstance","desc":"","lua_type":"Sound"}],"returns":[],"function_type":"static","source":{"line":243,"path":"src/soundUtil/init.luau"}},{"name":"stopSoundId","desc":"Stops the given sound id. ","params":[{"name":"soundId","desc":"","lua_type":"string"}],"returns":[],"function_type":"static","source":{"line":258,"path":"src/soundUtil/init.luau"}},{"name":"playSoundId","desc":"Plays the given sound id. \\n\\n```lua\\nsoundUtil.registerSoundIdHeartbeatCallback(someSoundId, function(soundId, deltaTime)\\n\\tlocal soundInstancesOfTheSameSoundId = getSoundInstancesOfSoundId(soundId) -- {...}\\n\\n\\tfor _, soundInstance in soundInstancesOfTheSameSoundId do\\n\\t\\tif not soundInstance.Playing then\\n\\t\\t\\tsoundInstance.Volume = 0\\n\\t\\t\\tsoundInstance:Play()\\n\\t\\tend\\n\\t\\t\\n\\t\\t-- Lerp the volume to 2:\\n\\t\\tsoundInstance.Volume += (2 - soundInstance.Volume) * deltaTime\\n\\tend\\nend)\\n\\nsoundUtil.playSoundId(someSoundId)\\n```\\n\\n:::note No 3D functionality\\nThere is no API support for playing sound ids in 3D due to the estimated\\nAPI complexity.\\n:::","params":[{"name":"soundId","desc":"","lua_type":"string"}],"returns":[],"function_type":"static","source":{"line":290,"path":"src/soundUtil/init.luau"}},{"name":"registerSoundInstanceCleanupCallback","desc":"Registers the given callback as a cleanup callback for the given sound instance. The callback will be\\ncalled every [Heartbeat](https://create.roblox.com/docs/reference/engine/classes/RunService#Heartbeat) when the \\nsound is stopped via [soundUtil.stopSound], for as long as it doesn\'t return `false` (to complete cleanup). \\n\\n```lua\\nlocal someSoundInstance = ...\\nsoundUtil.registerSoundInstanceCleanupCallback(someSoundInstance, function(someSoundInstance, deltaTime)\\n\\t-- Lerp the volume to 0:\\n\\tsomeSoundInstance.Volume += (0 - someSoundInstance.Volume) * deltaTime\\n\\t\\n\\tif someSoundInstance.Volume < 1e-3 then\\n\\t\\t-- We\'ve fully lerped the volume to 0, let\'s stop the sound and finish\\n\\t\\t-- up cleanup!\\n\\t\\tsomeSoundInstance:Stop()\\n\\t\\treturn false \\n\\tend\\n\\n\\treturn true \\nend)\\n\\nsoundUtil.playSound(someSoundInstance)\\ntask.wait(2)\\nsomeSoundUtil.stopSound(someSoundInstance)\\n```\\n:::note\\nThe `cleanupPredicate` will no longer run IF the same sound instance is suddenly played again.\\n:::\\t","params":[{"name":"soundInstance","desc":"","lua_type":"Sound"},{"name":"cleanupPredicate","desc":"","lua_type":"((\\r\\n\\t\\tsoundInstance: Sound,\\r\\n\\t\\tdeltaTime: number\\r\\n\\t) -> boolean)?\\r\\n"}],"returns":[],"function_type":"static","source":{"line":325,"path":"src/soundUtil/init.luau"}},{"name":"registerSoundInstanceHeartbeatCallback","desc":"Registers the given callback as a heartbeat callback for the given sound instance. It\\nwill be called every [Heartbeat](https://create.roblox.com/docs/reference/engine/classes/RunService#Heartbeat)\\nfor as long as the sound is playing (sound will be in \\"playing\\" state if it has been played by [soundUtil.playSound]\\nand has not finished / stopped yet).\\n\\n```lua\\nsoundUtil.registerSoundInstanceHeartbeatCallback(someSoundInstance, function(soundInstance, deltaTime)\\n\\tif not soundInstance.Playing then\\n\\t\\tsoundInstance.Volume = 0\\n\\t\\tsoundInstance:Play()\\n\\tend\\n\\t-- Lerp the volume to 2:\\n\\tsoundInstance.Volume += (2 - soundInstance.Volume) * deltaTime\\nend)\\n\\nsoundUtil.playSound(someSoundInstance)\\n```","params":[{"name":"soundInstance","desc":"","lua_type":"Sound"},{"name":"heartbeatCallback","desc":"","lua_type":"((\\r\\n\\t\\tsoundInstance: Sound,\\r\\n\\t\\tdeltaTime: number\\r\\n\\t) -> ())?\\r\\n"}],"returns":[],"function_type":"static","source":{"line":355,"path":"src/soundUtil/init.luau"}},{"name":"registerSoundIdHeartbeatCallback","desc":"Registers the given callback as a heartbeat callback for the given **sound id**. It\\nwill be called every [Heartbeat](https://create.roblox.com/docs/reference/engine/classes/RunService#Heartbeat)\\nfor as long as the sound id is not requested to stop (the sound id will be in \\"playing\\" state if it has been played \\nby [soundUtil.playSoundId]).\\n\\n```lua\\nsoundUtil.registerSoundIdHeartbeatCallback(someSoundId, function(soundId, deltaTime)\\n\\tlocal soundInstancesOfTheSameSoundId = getSoundInstancesOfSoundId(soundId) -- {...}\\n\\n\\tfor _, soundInstance in soundInstancesOfTheSameSoundId do\\n\\t\\tif not soundInstance.Playing then\\n\\t\\t\\tsoundInstance.Volume = 0\\n\\t\\t\\tsoundInstance:Play()\\n\\t\\tend\\n\\t\\t\\n\\t\\t-- Lerp the volume to 2:\\n\\t\\tsoundInstance.Volume += (2 - soundInstance.Volume) * deltaTime\\n\\tend\\nend)\\n\\nsoundUtil.playSoundId(someSoundId)\\n```","params":[{"name":"soundId","desc":"","lua_type":"string"},{"name":"heartbeatCallback","desc":"","lua_type":"((\\r\\n\\t\\tsoundId: string,\\r\\n\\t\\tdeltaTime: number\\r\\n\\t) -> ())?\\r\\n"}],"returns":[],"function_type":"static","source":{"line":390,"path":"src/soundUtil/init.luau"}},{"name":"registerSoundIdCleanupCallback","desc":"Registers the given callback as a cleanup callback for the given **sound id**. The callback will be\\ncalled every [Heartbeat](https://create.roblox.com/docs/reference/engine/classes/RunService#Heartbeat) when the \\nsound id is stopped via [soundUtil.stopSoundId], for as long as it doesn\'t return `false` (to complete cleanup). \\n\\n```lua\\nsoundUtil.registerSoundIdCleanupCallback(someSoundId, function(soundId, deltaTime)\\n\\tlocal soundInstancesOfTheSameSoundId = getSoundInstancesOfSoundId(soundId) -- {...}\\n\\tlocal soundInstancesCleanedUpCount = 0\\n\\n\\tfor _, soundInstance in soundInstancesOfTheSameSoundId do\\n\\t\\t-- Lerp the volume to 0:\\n\\t\\tsoundInstance.Volume += (0 - someSoundInstance.Volume) * deltaTime\\n\\n\\t\\tif soundInstance.Volume < 1e-3 then\\n\\t\\t\\tcleanedUpAllSoundInstances += 1\\n\\n\\t\\t\\t-- We\'ve fully lerped the volume to 0, let\'s stop the sound and finish\\n\\t\\t\\t-- up cleanup!\\n\\t\\t\\tif soundInstance.Playing then\\n\\t\\t\\t\\tsoundInstance:Stop()\\n\\t\\t\\tend\\n\\t\\tend\\n\\tend\\n\\n\\t-- Finish up cleanup once we have cleaned up all sound instances\\n\\treturn soundInstancesCleanedUpCount < #soundInstancesOfTheSameSoundId\\nend)\\n\\nsoundUtil.playSoundId(someSoundId)\\ntask.wait(2)\\nsomeSoundUtil.stopSoundId(someSoundId)\\n```\\n\\n:::note\\nThe `cleanupPredicate` will no longer run IF the given sound id is suddenly played again (and the `cleanupPredicate`\\nhasn\'t yet completed).\\n:::\\t","params":[{"name":"soundId","desc":"","lua_type":"string"},{"name":"cleanupPredicate","desc":"","lua_type":"((\\r\\n\\t\\tsoundId: string,\\r\\n\\t\\tdeltaTime: number\\r\\n\\t) -> boolean)?\\r\\n"}],"returns":[],"function_type":"static","source":{"line":440,"path":"src/soundUtil/init.luau"}}],"properties":[{"name":"onSoundInstanceCleanup","desc":" \\n\\nA [signal](https://sleitnick.github.io/RbxUtil/api/Signal/) which is fired whenever a sound instance is cleaned up.\\n\\n```lua\\nsoundUtil.onSoundInstanceCleanup:Connect(function(soundInstance: Sound)\\n\\twarn(soundInstance, \\" cleaned up\\")\\nend)\\n```\\n\\n:::note\\nThis signal will only fire under the following circumstances:\\n\\n- A sound instance played through this utility was destroyed (through `:Destroy`).\\n:::","lua_type":"Signal <soundInstance: Sound>","tags":["Read only","Signal"],"source":{"line":54,"path":"src/soundUtil/init.luau"}}],"types":[],"name":"soundUtil","desc":"A utility module for working with sounds.\\n\\n```lua\\nsoundUtil.registerSoundHeartbeatCallback(someSoundInstance, function(soundInstance, deltaTime)\\n\\tif not soundInstance.Playing then\\n\\t\\tsoundInstance.Volume = 0\\n\\t\\tsoundInstance:Play()\\n\\tend\\n\\n\\t-- Lerp the volume to 1:\\n\\tsoundInstance.Volume += (1 - soundInstance.Volume) * deltaTime * 2\\nend)\\n\\nsoundUtil.registerSoundInstanceCleanupCallback(someSoundInstance, function(soundInstance, deltaTime)\\n\\t-- Lerp the volume to 0:\\n\\tsoundInstance.Volume += (0 - soundInstance.Volume) * deltaTime * 2\\n\\n\\tif soundInstance.Volume < 1e-3 then\\n\\t\\t-- We\'ve fully lerped the volume to 0, let\'s stop the sound and finish\\n\\t\\t-- up cleanup!\\n\\t\\tsoundInstance:Stop()\\n\\t\\treturn false\\n\\tend\\n\\n\\treturn true\\nend)\\n\\nsoundUtil.playSound(someSoundInstance)\\n```","source":{"line":33,"path":"src/soundUtil/init.luau"}}')}}]);