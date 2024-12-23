--[=[
	@class soundUtil

	A utility module for working with sounds.

	```lua
	soundUtil.registerSoundHeartbeatCallback(someSound, function(sound, deltaTime)
		if not sound.Playing then
			sound.Volume = 0
			sound:Play()
		end

		-- Lerp the volume to 1:
		sound.Volume += (1 - sound.Volume) * deltaTime * 2
	end)

	soundUtil.registerSoundCleanupCallback(someSound, function(sound, deltaTime)
		-- Lerp the volume to 0:
		sound.Volume += (0 - sound.Volume) * deltaTime * 2

		if sound.Volume < 1e-3 then
			-- We've fully lerped the volume to 0, let's stop the sound and finish
			-- up cleanup!
			sound:Stop()
			return false
		end

		return true
	end)

	soundUtil.playSound(someSound)
	```
]=]

--[=[ 
	@prop onSoundCleanup Signal <sound: Sound>
	@within soundUtil
	@tag Read only
	@tag Signal

	A [signal](https://sleitnick.github.io/RbxUtil/api/Signal/) which is fired whenever a sound instance is cleaned up.
	
	```lua
	soundUtil.onSoundCleanup:Connect(function(sound: Sound)
		warn(sound, " cleaned up")
	end)
	```
	
	:::note
	This signal will only fire under the following circumstances:

	- A sound instance played through this utility was destroyed (through `:Destroy`).
	:::
]=]

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Signal = require(script.Parent.Signal)
local Trove = require(script.Parent.Trove)

local soundIdHeartbeatCallbacks = {}
local soundIdCleanupCallbacks = {}
local soundIdsMarkedForStop = {}
local soundIdsMarkedAsPlaying = {}

local soundHeartbeatCallbacks = {}
local soundsMarkedAsPlaying = {}
local soundsMarkedForStop = {}
local soundCleanupCallbacks = {}
local registeredSounds = {}
local mapped3DSoundHolders = {}

local soundUtil = {}
soundUtil.onSoundCleanup = Signal.new()

--[=[
	Returns an array of all sound instances that are currently playing.
]=]

function soundUtil.playingSounds(): { Sound }
	local activeSoundsPlaying = {}

	for _, sound in registeredSounds do
		if not sound.Playing then
			continue
		end

		table.insert(activeSoundsPlaying, sound)
	end

	return table.freeze(activeSoundsPlaying)
end

--[=[
	Stops all playing sounds which have a `SoundId` of `soundId`, via [soundUtil.stopSound].
]=]

function soundUtil.stopAllSoundsOfSoundId(soundId: string)
	for _, sound in registeredSounds do
		if sound.SoundId ~= soundId then
			continue
		end

		soundUtil.stopSound(sound)
	end
end

--[=[
	Plays a cloned version of the sound and destroys it when it has ended.
]=]

function soundUtil.playSoundCloneAndCleanup(sound: Sound): Sound
	local clonedSound = sound:Clone()
	clonedSound.Name = string.format("%s_Clone", sound.Name)
	clonedSound.Parent = sound.Parent

	soundUtil.playSound(clonedSound)
	clonedSound.Ended:Connect(function()
		clonedSound:Destroy()
	end)
	return clonedSound
end

--[=[
	Stops all playing sounds via [soundUtil.stopSound].
]=]

function soundUtil.stopAll()
	for _, sound in registeredSounds do
		soundUtil.stopSound(sound)
	end
end

--[=[
	Plays the given sound instance, if the sound instance has a heartbeat callback registered for it, then	
	the sound instance will not be played automatically.
	
	```lua
	soundUtil.registerSoundHeartbeatCallback(someSound, function(sound, deltaTime)
		if not sound.Playing then
			sound.Volume = 0
			sound:Play()
		end
		-- Lerp the volume to 1:
		sound.Volume += (2 - sound.Volume) * deltaTime
	end)
	
	soundUtil.playSound(someSound)
	```
]=]

function soundUtil.playSound(sound: Sound): Sound
	local soundIsRegistered = table.find(registeredSounds, sound) ~= nil

	soundsMarkedAsPlaying[sound] = true
	soundsMarkedForStop[sound] = nil

	if soundHeartbeatCallbacks[sound] == nil then
		sound:Play()
	end

	if not soundIsRegistered then
		local trove = Trove.new()
		trove:AttachToInstance(sound)

		local soundHolder = mapped3DSoundHolders[sound]
		if soundHolder ~= nil then
			trove:Add(soundHolder)
			trove:Add(sound.Ended:Connect(function()
				sound:Destroy()
			end))
		end

		table.insert(registeredSounds, sound)

		trove:Add(function()
			soundUtil.onSoundCleanup:Fire(sound)

			soundsMarkedAsPlaying[sound] = nil
			soundsMarkedForStop[sound] = nil
			mapped3DSoundHolders[sound] = nil
			soundCleanupCallbacks[sound] = nil
			soundHeartbeatCallbacks[sound] = nil

			local index = table.find(registeredSounds, sound)
			if index ~= nil then
				table.remove(registeredSounds, index)
			end
		end)
	end

	return sound
end

--[=[
	Plays the given sound at the specified given 3D position or instance. If the sound instance has a heartbeat callback registered for it, 
	then the sound instance will not be played automatically. Once the sound has ended, it'll be destroyed.
	
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
	soundUtil.playSound3D(someStorage.someRandomSound, workspace.ZombiePart) -- PANIC: `someStorage.someRandomSound` does not exist anymore!
	
	-- GOOD:
	oundUtil.playSound3D(someStorage.someRandomSound:Clone(), workspace.Baseplate)
	soundUtil.playSound3D(someStorage.someRandomSound:Clone(), workspace.ZombiePart) 
	```
	:::
]=]

function soundUtil.playSound3D(sound: Sound, positionOrBasePart: Vector3 | BasePart): Sound
	if mapped3DSoundHolders[sound] == nil then
		if typeof(positionOrBasePart) == "Vector3" then
			local soundHolderPart = Instance.new("Part")
			soundHolderPart.Anchored = true
			soundHolderPart.Transparency = 1
			soundHolderPart.Name = string.format("SoundPlayer_%s", sound.Name)
			soundHolderPart.CanCollide = false
			soundHolderPart.CanQuery = false
			soundHolderPart.CanTouch = false
			soundHolderPart.Position = positionOrBasePart
			soundHolderPart.Parent = Workspace
			sound.Parent = soundHolderPart
			mapped3DSoundHolders[sound] = soundHolderPart
		else
			sound.Parent = positionOrBasePart
		end
	end

	soundUtil.playSound(sound)
	return sound
end

--[=[
	Stops the given sound instance. 
]=]

function soundUtil.stopSound(sound: Sound)
	soundsMarkedForStop[sound] = true
	soundsMarkedAsPlaying[sound] = nil

	-- We need to stop the sound instance if no cleanup callback was specified at
	-- all.
	if soundCleanupCallbacks[sound] == nil then
		sound:Stop()
	end
end

--[=[
	Stops the given sound of sound id `soundId`. 
]=]

function soundUtil.stopSoundId(soundId: string)
	soundIdsMarkedForStop[soundId] = true
	soundIdsMarkedAsPlaying[soundId] = nil
end

--[=[
	Plays the given sound of sound id `soundId`. 

	```lua
	soundUtil.registerSoundIdHeartbeatCallback(someSoundId, function(soundId, deltaTime)
		local soundsOfTheSameSoundId = getSoundsOfSoundId(soundId) -- {...}

		for _, sound in soundsOfTheSameSoundId do
			if not sound.Playing then
				sound.Volume = 0
				sound:Play()
			end
			
			-- Lerp the volume to 2:
			sound.Volume += (2 - sound.Volume) * deltaTime
		end
	end)
	
	soundUtil.playSoundId(someSoundId)
	```
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
	local someSound = ...
	soundUtil.registerSoundCleanupCallback(someSound, function(someSound, deltaTime)
		-- Lerp the volume to 0:
		someSound.Volume += (0 - someSound.Volume) * deltaTime
		
		if someSound.Volume < 1e-3 then
			-- We've fully lerped the volume to 0, let's stop the sound and finish
			-- up cleanup!
			someSound:Stop()
			return false 
		end

		return true 
	end)
	
	soundUtil.playSound(someSound)
	task.wait(2)
	someSoundUtil.stopSound(someSound)
	```

	:::note
	The `cleanupPredicate` will no longer run if the same sound instance is suddenly played again.
	:::	
]=]

function soundUtil.registerSoundCleanupCallback(
	sound: Sound,
	cleanupPredicate: ((
		sound: Sound,
		deltaTime: number
	) -> boolean)?
)
	soundCleanupCallbacks[sound] = cleanupPredicate
end

--[=[
	Registers the given callback as a heartbeat callback for the given sound instance. It
	will be called every [Heartbeat](https://create.roblox.com/docs/reference/engine/classes/RunService#Heartbeat)
	for as long as the sound is playing (sound will be in "playing" state if it has been played by [soundUtil.playSound]
	and has not finished / stopped yet).
	
	```lua
	soundUtil.registerSoundHeartbeatCallback(someSound, function(sound, deltaTime)
		if not sound.Playing then
			sound.Volume = 0
			sound:Play()
		end
		-- Lerp the volume to 2:
		sound.Volume += (2 - sound.Volume) * deltaTime
	end)

	soundUtil.playSound(someSound)
	```
]=]

function soundUtil.registerSoundHeartbeatCallback(
	sound: Sound,
	heartbeatCallback: (sound: Sound, deltaTime: number) -> ()
)
	soundHeartbeatCallbacks[sound] = heartbeatCallback
end

--[=[
	Registers the given callback as a heartbeat callback for the given **sound id**. It
	will be called every [Heartbeat](https://create.roblox.com/docs/reference/engine/classes/RunService#Heartbeat)
	for as long as the sound id is not requested to stop (the sound id will be in "playing" state if it has been played 
	by [soundUtil.playSoundId]).
	
	```lua
	soundUtil.registerSoundIdHeartbeatCallback(someSoundId, function(soundId, deltaTime)
		local soundsOfTheSameSoundId = getSoundsOfSoundId(soundId) -- {...}

		for _, sound in soundsOfTheSameSoundId do
			if not sound.Playing then
				sound.Volume = 0
				sound:Play()
			end
			
			-- Lerp the volume to 2:
			sound.Volume += (2 - sound.Volume) * deltaTime
		end
	end)
	
	soundUtil.playSoundId(someSoundId)
	```
]=]

function soundUtil.registerSoundIdHeartbeatCallback(
	soundId: string,
	heartbeatCallback: (
		soundId: string,
		deltaTime: number
	) -> ()
)
	soundIdHeartbeatCallbacks[soundId] = heartbeatCallback
end

--[=[
	Registers the given callback as a cleanup callback for the given **sound id**. The callback will be
	called every [Heartbeat](https://create.roblox.com/docs/reference/engine/classes/RunService#Heartbeat) when the 
	sound id is stopped via [soundUtil.stopSoundId], for as long as it doesn't return `false` (to complete cleanup). 
	
	```lua
	soundUtil.registerSoundIdCleanupCallback(someSoundId, function(soundId, deltaTime)
		local soundsOfTheSameSoundId = getSoundsOfSoundId(soundId) -- {...}
		local soundsCleanedUpCount = 0

		for _, sound in soundsOfTheSameSoundId do
			-- Lerp the volume to 0:
			sound.Volume += (0 - someSound.Volume) * deltaTime

			if sound.Volume < 1e-3 then
				cleanedUpAllSounds += 1

				-- We've fully lerped the volume to 0, let's stop the sound and finish
				-- up cleanup!
				if sound.Playing then
					sound:Stop()
				end
			end
		end

		-- Finish up cleanup once we have cleaned up all sound instances
		return soundsCleanedUpCount < #soundsOfTheSameSoundId
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
	for sound, callback in soundHeartbeatCallbacks do
		if not soundsMarkedAsPlaying[sound] then
			continue
		end

		callback(sound, deltaTime)
	end

	for sound, callback in soundCleanupCallbacks do
		if not soundsMarkedForStop[sound] then
			continue
		end

		if callback(sound, deltaTime) == false then
			soundsMarkedForStop[sound] = nil
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
