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

local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local soundHeartbeatCallbacks = {}
local soundsMarkedAsPlaying = {}
local soundsMarkedForStop = {}
local soundCleanupCallbacks = {}
local registeredSounds = {}
local mapped3DSoundHolders = {}

local soundUtil = {}

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
	Stops all playing registered ounds via [soundUtil.stopSound].
]=]

function soundUtil.stopAll()
	for sound in registeredSounds do
		soundUtil.stopSound(sound)
	end
end

--[=[
	Plays the given sound instance, if the sound instance has a heartbeat callback registered for it, then
	the sound instance will not be played by this method.
	
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

function soundUtil.playSound(sound: Sound)
	soundsMarkedAsPlaying[sound] = true
	soundsMarkedForStop[sound] = nil

	if soundHeartbeatCallbacks[sound] == nil then
		sound:Play()
	end
end

--[=[
	Plays the given sound at the specified given 3D position or instance. If the sound instance has a heartbeat callback registered for it, 
	then the sound instance will not be played by this method. Once the sound has ended, it'll be destroyed.
	
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
	soundUtil.playSoundIn3DOnce(someStorage.someRandomSound, workspace.Baseplate)
	soundUtil.playSoundIn3DOnce(someStorage.someRandomSound, workspace.ZombiePart) -- PANIC: `someStorage.someRandomSound` does not exist anymore!
	
	-- GOOD:
	oundUtil.playSoundIn3DOnce(someStorage.someRandomSound:Clone(), workspace.Baseplate)
	soundUtil.playSoundIn3DOnce(someStorage.someRandomSound:Clone(), workspace.ZombiePart) 
	```
	:::
]=]

function soundUtil.playSoundIn3DOnce(sound: Sound, positionOrBasePart: Vector3 | BasePart)
	if mapped3DSoundHolders[sound] ~= nil then
		return
	end

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

		sound.Ended:Once(function()
			if mapped3DSoundHolders[sound] ~= soundHolderPart then
				return
			end

			mapped3DSoundHolders[sound] = nil
		end)
	else
		mapped3DSoundHolders[sound] = positionOrBasePart
		sound.Parent = positionOrBasePart

		sound.Ended:Once(function()
			if mapped3DSoundHolders[sound] ~= positionOrBasePart then
				return
			end

			mapped3DSoundHolders[sound] = nil
		end)
	end

	soundsMarkedAsPlaying[sound] = true
	soundsMarkedForStop[sound] = nil

	if soundHeartbeatCallbacks[sound] == nil then
		sound:Play()
	end
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

RunService.Heartbeat:Connect(function(deltaTime: number)
	for sound, callback in soundHeartbeatCallbacks do
		if soundsMarkedAsPlaying[sound] == nil then
			continue
		end

		callback(sound, deltaTime)
	end

	for sound, callback in soundCleanupCallbacks do
		if soundsMarkedForStop[sound] == nil then
			continue
		end

		if callback(sound, deltaTime) == false then
			soundsMarkedForStop[sound] = nil
		end
	end
end)

return table.freeze(soundUtil)
