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
local GOAL_SOUND_VOLUME_ATTRIBUTE = "GoalSoundVolume"

local soundInitializerUtil = {}

--[=[
	Initializes the given `sound` for basic fading in and fading out. If `lerpInAlpha` and `lerpOutAlpha` are not
	specified, they'll default to [soundInitializerUtil.DEFAULT_SOUND_VOLUME_LERP_IN_ALPHA] and [soundInitializerUtil.DEFAULT_SOUND_VOLUME_LERP_OUT_ALPHA]
	respectively.

	:::warning
	This method will throw an error if the given `sound` does not have the attribute [soundInitializerUtil.GOAL_SOUND_VOLUME_ATTRIBUTE].
	:::
]=]

function soundInitializerUtil.initForBasicFadingInAndOut(
	sound: Sound,
	lerpInAlpha: number?,
	lerpOutAlpha: number?
)
	assert(
		sound:GetAttribute(GOAL_SOUND_VOLUME_ATTRIBUTE) ~= nil,
		string.format(
			'Missing attribute "%s" in [%s]',
			GOAL_SOUND_VOLUME_ATTRIBUTE,
			sound:GetFullName()
		)
	)

	soundUtil.registerSoundHeartbeatCallback(sound, function(_, deltaTime)
		if not sound.Playing then
			sound:Play()
		end

		sound.Volume = numberUtil.lerp(
			sound.Volume,
			sound:GetAttribute(GOAL_SOUND_VOLUME_ATTRIBUTE) :: number,
			deltaTime * (lerpInAlpha or DEFAULT_SOUND_VOLUME_LERP_IN_ALPHA)
		)
	end)

	soundUtil.registerSoundCleanupCallback(sound, function(_, deltaTime)
		sound.Volume = numberUtil.lerp(
			sound.Volume,
			0,
			deltaTime * (lerpOutAlpha or DEFAULT_SOUND_VOLUME_LERP_OUT_ALPHA)
		)

		if numberUtil.close(sound.Volume, 0) then
			sound:Stop()
			return false
		end

		return true
	end)
end

return table.freeze(soundInitializerUtil)
