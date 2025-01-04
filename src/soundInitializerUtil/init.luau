--[=[
	@class soundInitializerUtil

	A simple utility module for initializing sounds used in conjunction with [soundUtil].
]=]

--[=[ 
	@prop GOAL_SOUND_VOLUME_ATTRIBUTE "GoalSoundVolume"
	@tag Constant
	@within soundInitializerUtil

	:::warning Not Accessible
	Constant, not accesible within `soundInitializerUtil`.
	:::
]=]

--[=[ 
	@prop DEFAULT_SOUND_VOLUME_LERP_IN_ALPHA  4
	@tag Constant
	@within soundInitializerUtil

	:::warning Not Accessible
	Constant, not accesible within `soundInitializerUtil`.
	:::
]=]

--[=[ 
	@prop DEFAULT_SOUND_VOLUME_LERP_OUT_ALPHA  4
	@tag Constant
	@within soundInitializerUtil

	:::warning Not Accessible
	Constant, not accesible within `soundInitializerUtil`.
	:::
]=]

local numberUtil = require(script.Parent.numberUtil)
local soundUtil = require(script.Parent.soundUtil)

local DEFAULT_SOUND_VOLUME_LERP_IN_ALPHA = 4
local DEFAULT_SOUND_VOLUME_LERP_OUT_ALPHA = 4

local soundInitializerUtil = {}

--[=[
	Initializes the given `sound` for basic fading in and fading out. If `lerpInAlpha` and `lerpOutAlpha` are not
	specified, they'll default to [soundInitializerUtil.DEFAULT_SOUND_VOLUME_LERP_IN_ALPHA].
]=]

function soundInitializerUtil.initForBasicFadingInAndOut(
	sound: Sound,
	data: {
		goalSoundVolumeIn: number,
		goalSoundVolumeOut: number,
		lerpInAlpha: number?,
		lerpOutAlpha: number?,
	}
)
	data.lerpInAlpha = data.lerpInAlpha or DEFAULT_SOUND_VOLUME_LERP_IN_ALPHA
	data.lerpOutAlpha = data.lerpOutAlpha or DEFAULT_SOUND_VOLUME_LERP_OUT_ALPHA

	soundUtil.registerSoundHeartbeatCallback(sound, function(_, deltaTime)
		if not sound.Playing then
			sound:Play()
		end

		sound.Volume =
			numberUtil.lerp(sound.Volume, data.goalSoundVolumeIn, deltaTime * data.lerpInAlpha)
	end)

	soundUtil.registerSoundCleanupCallback(sound, function(_, deltaTime)
		sound.Volume =
			numberUtil.lerp(sound.Volume, data.goalSoundVolumeOut, deltaTime * data.lerpOutAlpha)

		if numberUtil.close(sound.Volume, 0) then
			sound:Stop()
			return false
		end

		return true
	end)
end

return table.freeze(soundInitializerUtil)
