--[=[
	@class soundUtil
	A utility module for working with sounds.

	```lua
	soundUtil.registerSoundHeartbeatCallback(someSoundInstance, function(soundInstance, deltaTime)
		if not soundInstance.Playing then
			soundInstance.Volume = 0
			soundInstance:Play()
		end

		-- Lerp the volume to 1:
		soundInstance.Volume += (1 - soundInstance.Volume) * deltaTime * 2
	end)

	soundUtil.registerSoundInstanceCleanupCallback(someSoundInstance, function(soundInstance, deltaTime)
		-- Lerp the volume to 0:
		soundInstance.Volume += (0 - soundInstance.Volume) * deltaTime * 2

		if soundInstance.Volume < 1e-3 then
			-- We've fully lerped the volume to 0, let's stop the sound and finish
			-- up cleanup!
			soundInstance:Stop()
			return false
		end

		return true
	end)

	soundUtil.playSound(someSoundInstance)
	```
]=]

--[=[ 
	@prop onSoundInstanceCleanup Signal <soundInstance: Sound>
	@within soundUtil
	@tag Read only
	@tag Signal

	A [signal](https://sleitnick.github.io/RbxUtil/api/Signal/) which is fired whenever a sound instance is cleaned up.
	
	```lua
	soundUtil.onSoundInstanceCleanup:Connect(function(soundInstance: Sound)
		warn(soundInstance, " cleaned up")
	end)
	```
	
	:::note
	This signal will only fire under the following circumstances:

	- A sound instance played through this utility was destroyed (through `:Destroy`).
	:::
]=]

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local Signal = require(script.Parent.Signal)
local Trove = require(script.Parent.Trove)

local soundIdHeartbeatCallbacks = {}
local soundIdCleanupCallbacks = {}
local soundIdsMarkedForStop = {}
local soundIdsMarkedAsPlaying = {}

local soundInstanceHeartbeatCallbacks = {}
local soundInstancesMarkedAsPlaying = {}
local soundInstancesMarkedForStop = {}
local soundInstanceCleanupCallbacks = {}
local registeredSoundInstances = {}
local mapped3DSoundInstanceHolders = {}

local soundUtil = {}
soundUtil.onSoundInstanceCleanup = Signal.new()

--[=[
	Returns an array of all sound instances that are currently playing.
]=]

function soundUtil.playingSoundInstances(): { Sound }
	local activeSoundInstancesPlaying = {}

	for _, soundInstance in registeredSoundInstances do
		if not soundInstance.Playing then
			continue
		end

		table.insert(activeSoundInstancesPlaying, soundInstance)
	end

	return table.freeze(activeSoundInstancesPlaying)
end

--[=[
	Stops all playing sounds which have a `SoundId` of `soundId`, via [soundUtil.stopSound].
]=]

function soundUtil.stopAllSoundsOfSoundId(soundId: string)
	for _, soundInstance in registeredSoundInstances do
		if soundInstance.SoundId ~= soundId then
			continue
		end

		soundUtil.stopSound(soundInstance)
	end
end

--[=[
	Plays a cloned version of the sound and destroys it when it has ended.
]=]

function soundUtil.playSoundCloneAndCleanup(sound: Sound)
	local clonedSound = sound:Clone()
	clonedSound.Name = string.format("%s_Clone", sound.Name)
	clonedSound.Parent = sound.Parent

	soundUtil.playSound(clonedSound)
	clonedSound.Ended:Connect(function()
		clonedSound:Destroy()
	end)
end

--[=[
	Stops all playing sounds via [soundUtil.stopSound].
]=]

function soundUtil.stopAll()
	for _, soundInstance in registeredSoundInstances do
		soundUtil.stopSound(soundInstance)
	end
end

--[=[
	Plays the given sound instance, if the sound instance has a heartbeat callback registered for it, then	
	the sound instance will not be played automatically.
	
	```lua
	soundUtil.registerSoundHeartbeatCallback(someSoundInstance, function(soundInstance, deltaTime)
		if not soundInstance.Playing then
			soundInstance.Volume = 0
			soundInstance:Play()
		end
		-- Lerp the volume to 1:
		soundInstance.Volume += (2 - soundInstance.Volume) * deltaTime
	end)
	
	soundUtil.playSound(someSoundInstance)
	```
]=]

function soundUtil.playSound(soundInstance: Sound)
	local soundInstanceIsRegistered = table.find(registeredSoundInstances, soundInstance) ~= nil

	soundInstancesMarkedAsPlaying[soundInstance] = true
	soundInstancesMarkedForStop[soundInstance] = nil

	if not soundInstanceHeartbeatCallbacks[soundInstance] then
		soundInstance:Play()
	end

	if not soundInstanceIsRegistered then
		local trove = Trove.new()
		local soundHolder = mapped3DSoundInstanceHolders[soundInstance]

		if soundHolder then
			trove:Add(soundHolder)
		end

		table.insert(registeredSoundInstances, soundInstance)

		trove:Add(soundInstance.Destroying:Connect(function()
			task.defer(trove.Destroy, trove)
		end))

		trove:Add(function()
			soundUtil.onSoundInstanceCleanup:Fire(soundInstance)

			soundInstancesMarkedAsPlaying[soundInstance] = nil
			soundInstancesMarkedForStop[soundInstance] = nil
			mapped3DSoundInstanceHolders[soundInstance] = nil
			soundInstanceCleanupCallbacks[soundInstance] = nil
			soundInstanceHeartbeatCallbacks[soundInstance] = nil
			table.remove(
				registeredSoundInstances,
				table.find(registeredSoundInstances, soundInstance)
			)
		end)
	end
end

--[=[
	Plays the given sound at the specified given 3D position or instance. If the sound instance has a heartbeat callback registered for it, 
	then the sound instance will not be played automatically.
	
	```lua
	-- Usecase: lightning bolt sounds!
	local lightningBoltSound = ...
	local generatedLightningBoltModel = ...
	soundUtil.playSound3D(lightningBoltSound, generatedLightningBoltModel.PrimaryPart) 
	```
	
	:::note
	Ideally you should always generally pass in a cloned version of the sound instance so you can
	reuse it.
	
	```lua
	-- BAD:
	soundUtil.playSound3D(someStorage.someRandomSound, workspace.Baseplate)
	soundUtil.playSound3D(someStorage.someRandomSound, workspace.ZombiePart) -- PANIC: someStorage.someRandomSound does not exist anymore!
	
	-- GOOD:
	oundUtil.playSound3D(someStorage.someRandomSound:Clone(), workspace.Baseplate)
	soundUtil.playSound3D(someStorage.someRandomSound:Clone(), workspace.ZombiePart) 
	```
	:::
]=]

function soundUtil.playSound3D(soundInstance: Sound, positionOrBasePart: Vector3 | BasePart)
	if not mapped3DSoundInstanceHolders[soundInstance] then
		if typeof(positionOrBasePart) == "Vector3" then
			local soundHolderPart = Instance.new("Part")
			soundHolderPart.Anchored = true
			soundHolderPart.Transparency = 1
			soundHolderPart.Name = string.format("SoundPlayer_%s", soundInstance.Name)
			soundHolderPart.CanCollide = false
			soundHolderPart.CanQuery = false
			soundHolderPart.CanTouch = false
			soundHolderPart.Position = positionOrBasePart
			soundHolderPart.Parent = Workspace
			soundInstance.Parent = soundHolderPart
			mapped3DSoundInstanceHolders[soundInstance] = soundHolderPart
		else
			soundInstance.Parent = positionOrBasePart
		end
	end

	soundUtil.playSound(soundInstance)
end

--[=[
	Stops the given sound instance. 
]=]

function soundUtil.stopSound(soundInstance: Sound)
	soundInstancesMarkedForStop[soundInstance] = true
	soundInstancesMarkedAsPlaying[soundInstance] = nil

	-- We need to stop the sound instance if no cleanup callback was specified at
	-- all..
	if not soundInstanceCleanupCallbacks[soundInstance] then
		soundInstance:Stop()
	end
end

--[=[
	Stops the given sound id. 
]=]

function soundUtil.stopSoundId(soundId: string)
	soundIdsMarkedForStop[soundId] = true
	soundIdsMarkedAsPlaying[soundId] = nil
end

--[=[
	Plays the given sound id. 

	```lua
	soundUtil.registerSoundIdHeartbeatCallback(someSoundId, function(soundId, deltaTime)
		local soundInstancesOfTheSameSoundId = getSoundInstancesOfSoundId(soundId) -- {...}

		for _, soundInstance in soundInstancesOfTheSameSoundId do
			if not soundInstance.Playing then
				soundInstance.Volume = 0
				soundInstance:Play()
			end
			
			-- Lerp the volume to 2:
			soundInstance.Volume += (2 - soundInstance.Volume) * deltaTime
		end
	end)
	
	soundUtil.playSoundId(someSoundId)
	```

	:::note No 3D functionality
	There is no API support for playing sound ids in 3D due to the estimated
	API complexity.
	:::
]=]

function soundUtil.playSoundId(soundId: string)
	soundIdsMarkedForStop[soundId] = nil
	soundIdsMarkedAsPlaying[soundId] = true
end

--[=[
	Registers the given callback as a cleanup callback for the given sound instance. The callback will be
	called every [Heartbeat](https://create.roblox.com/docs/reference/engine/classes/RunService#Heartbeat) when the 
	sound is stopped via [soundUtil.stopSound], for as long as it doesn't return `false` (to complete cleanup). 
	
	```lua
	local someSoundInstance = ...
	soundUtil.registerSoundInstanceCleanupCallback(someSoundInstance, function(someSoundInstance, deltaTime)
		-- Lerp the volume to 0:
		someSoundInstance.Volume += (0 - someSoundInstance.Volume) * deltaTime
		
		if someSoundInstance.Volume < 1e-3 then
			-- We've fully lerped the volume to 0, let's stop the sound and finish
			-- up cleanup!
			someSoundInstance:Stop()
			return false 
		end

		return true 
	end)
	
	soundUtil.playSound(someSoundInstance)
	task.wait(2)
	someSoundUtil.stopSound(someSoundInstance)
	```
	:::note
	The `cleanupPredicate` will no longer run IF the same sound instance is suddenly played again.
	:::	
]=]

function soundUtil.registerSoundInstanceCleanupCallback(
	soundInstance: Sound,
	cleanupPredicate: ((
		soundInstance: Sound,
		deltaTime: number
	) -> boolean)?
)
	soundInstanceCleanupCallbacks[soundInstance] = cleanupPredicate
end

--[=[
	Registers the given callback as a heartbeat callback for the given sound instance. It
	will be called every [Heartbeat](https://create.roblox.com/docs/reference/engine/classes/RunService#Heartbeat)
	for as long as the sound is playing (sound will be in "playing" state if it has been played by [soundUtil.playSound]
	and has not finished / stopped yet).
	
	```lua
	soundUtil.registerSoundInstanceHeartbeatCallback(someSoundInstance, function(soundInstance, deltaTime)
		if not soundInstance.Playing then
			soundInstance.Volume = 0
			soundInstance:Play()
		end
		-- Lerp the volume to 2:
		soundInstance.Volume += (2 - soundInstance.Volume) * deltaTime
	end)

	soundUtil.playSound(someSoundInstance)
	```
]=]

function soundUtil.registerSoundInstanceHeartbeatCallback(
	soundInstance: Sound,
	heartbeatCallback: ((
		soundInstance: Sound,
		deltaTime: number
	) -> ())?
)
	soundInstanceHeartbeatCallbacks[soundInstance] = heartbeatCallback
end

--[=[
	Registers the given callback as a heartbeat callback for the given **sound id**. It
	will be called every [Heartbeat](https://create.roblox.com/docs/reference/engine/classes/RunService#Heartbeat)
	for as long as the sound id is not requested to stop (the sound id will be in "playing" state if it has been played 
	by [soundUtil.playSoundId]).
	
	```lua
	soundUtil.registerSoundIdHeartbeatCallback(someSoundId, function(soundId, deltaTime)
		local soundInstancesOfTheSameSoundId = getSoundInstancesOfSoundId(soundId) -- {...}

		for _, soundInstance in soundInstancesOfTheSameSoundId do
			if not soundInstance.Playing then
				soundInstance.Volume = 0
				soundInstance:Play()
			end
			
			-- Lerp the volume to 2:
			soundInstance.Volume += (2 - soundInstance.Volume) * deltaTime
		end
	end)
	
	soundUtil.playSoundId(someSoundId)
	```
]=]

function soundUtil.registerSoundIdHeartbeatCallback(
	soundId: string,
	heartbeatCallback: ((
		soundId: string,
		deltaTime: number
	) -> ())?
)
	soundIdHeartbeatCallbacks[soundId] = heartbeatCallback
end

--[=[
	Registers the given callback as a cleanup callback for the given **sound id**. The callback will be
	called every [Heartbeat](https://create.roblox.com/docs/reference/engine/classes/RunService#Heartbeat) when the 
	sound id is stopped via [soundUtil.stopSoundId], for as long as it doesn't return `false` (to complete cleanup). 
	
	```lua
	soundUtil.registerSoundIdCleanupCallback(someSoundId, function(soundId, deltaTime)
		local soundInstancesOfTheSameSoundId = getSoundInstancesOfSoundId(soundId) -- {...}
		local soundInstancesCleanedUpCount = 0

		for _, soundInstance in soundInstancesOfTheSameSoundId do
			-- Lerp the volume to 0:
			soundInstance.Volume += (0 - someSoundInstance.Volume) * deltaTime

			if soundInstance.Volume < 1e-3 then
				cleanedUpAllSoundInstances += 1

				-- We've fully lerped the volume to 0, let's stop the sound and finish
				-- up cleanup!
				if soundInstance.Playing then
					soundInstance:Stop()
				end
			end
		end

		-- Finish up cleanup once we have cleaned up all sound instances
		return soundInstancesCleanedUpCount < #soundInstancesOfTheSameSoundId
	end)
	
	soundUtil.playSoundId(someSoundId)
	task.wait(2)
	someSoundUtil.stopSoundId(someSoundId)
	```

	:::note
	The `cleanupPredicate` will no longer run IF the given sound id is suddenly played again (and the `cleanupPredicate`
	hasn't yet completed).
	:::	
]=]

function soundUtil.registerSoundIdCleanupCallback(
	soundId: string,
	cleanupPredicate: ((
		soundId: string,
		deltaTime: number
	) -> boolean)?
)
	soundIdCleanupCallbacks[soundId] = cleanupPredicate
end

RunService.Heartbeat:Connect(function(deltaTime: number)
	for soundInstance, callback in soundInstanceHeartbeatCallbacks do
		if not soundInstancesMarkedAsPlaying[soundInstance] then
			continue
		end

		callback(soundInstance, deltaTime)
	end

	for soundInstance, callback in soundInstanceCleanupCallbacks do
		if not soundInstancesMarkedForStop[soundInstance] then
			continue
		end

		if callback(soundInstance, deltaTime) == false then
			soundInstancesMarkedForStop[soundInstance] = nil
		end
	end

	for soundId, callback in soundIdHeartbeatCallbacks do
		if not soundIdsMarkedAsPlaying[soundId] then
			continue
		end

		callback(soundId, deltaTime)
	end

	for soundId, callback in soundIdCleanupCallbacks do
		if not soundIdsMarkedForStop[soundId] then
			continue
		end

		if callback(soundId, deltaTime) == false then
			soundIdsMarkedForStop[soundId] = nil
		end
	end
end)

return table.freeze(soundUtil)
