--[=[ 
	@class CustomAnimator

	A simple class for working with animations.
	
	```lua
	local playerHumanoidCustomAnimator = CustomAnimator.new(humanoidAnimator)
	local track = playerHumanoidCustomAnimator:loadAnimation(animation)
	track:Play()
	```
]=]

--[=[ 
    @type CustomAnimator CustomAnimator 
    @within CustomAnimator
]=]

local Promise = require(script.Parent.Promise)
local Signal = require(script.Parent.Signal)

local ANIM_FADE_TIME_ATTRIBUTE = "FadeTime"
local ANIM_WEIGHT_TIME_ATTRIBUTE = "Weight"
local ANIM_SPEED_TIME_ATTRIBUTE = "Speed"

local CustomAnimator = {}
CustomAnimator.__index = {}

--[=[ 
	Creates and returns a new custom animator object.
]=]

function CustomAnimator.new(animator: Animator | AnimationController): CustomAnimator
	assert(
		typeof(animator) == "Instance"
			and (animator:IsA("Animator") or animator:IsA("AnimationController")),
		string.format(
			"Bad argument to 'animator', expected Animator object, got %s",
			typeof(animator)
		)
	)

	return setmetatable({
		_animator = animator,
		_loadedAnimationTracks = {},
		_onAnimationLoaded = Signal.new(),
	}, CustomAnimator)
end

--[=[ 
	Returns the given loaded animation track from the animation, if found.
]=]

function CustomAnimator.__index:animationTrack(animation: Animation): AnimationTrack?
	return self._loadedAnimationTracks[animation]
end

--[=[ 
	Returns a promise which is resolved once the given animation is loaded via [CustomAnimator:loadAnimation].
]=]

function CustomAnimator.__index:onAnimationLoadPromise(animation: Animation)
	return Promise.new(function(resolve)
		while not self._loadedAnimationTracks[animation] do
			self._onAnimationLoaded:Wait()
		end

		resolve(animation)
	end)
end

--[=[ 
	Loads in the animation as an animation track.
]=]

function CustomAnimator.__index:loadAnimation(animation: Animation): AnimationTrack
	local animationTrack: AnimationTrack = self._animator:LoadAnimation(animation)
	self._loadedAnimationTracks[animation] = animationTrack
	self._onAnimationLoaded:Fire(animation)
	return animationTrack
end

--[=[ 
	Plays the given animation, if it has been loaded into the animator object via [CustomAnimator:loadAnimation].

	:::tip
	You can also setup attributes for `fadeTime`, `weight`, and `speed` in the animation object, 
	which will be used incase the arguments aren't specified.

	- `fadeTime` -> `FadeTime`
	- `weight` -> `Weight`
	- `speed` -> `Speed`
	:::
]=]

function CustomAnimator.__index:playAnimation(
	animation: Animation,
	fadeTime: number?,
	weight: number?,
	speed: number?
): AnimationTrack
	local animationTrack: AnimationTrack = self:animationTrack(animation)
	assert(
		animationTrack,
		string.format('Animation track "%s" cannot be played as it is not loaded!', animation.Name)
	)

	fadeTime = fadeTime or animation:GetAttribute(ANIM_FADE_TIME_ATTRIBUTE)
	weight = weight or animation:GetAttribute(ANIM_WEIGHT_TIME_ATTRIBUTE)
	speed = speed or animation:GetAttribute(ANIM_SPEED_TIME_ATTRIBUTE)

	animationTrack:Play(fadeTime, weight, speed)
	return animationTrack
end

--[=[ 
	Stops the given animation, if it has been loaded into the animator object via [CustomAnimator:loadAnimation].

	:::tip
	You can also setup an attribute for `fadeTime` in the animation object, which will be used incase the argument isn't specified.

	- `fadeTime` -> `FadeTime`
	:::
]=]

function CustomAnimator.__index:stopAnimation(
	animation: Animation,
	fadeTime: number?
): AnimationTrack
	local animationTrack: AnimationTrack = self:animationTrack(animation)
	assert(
		animationTrack,
		string.format('Animation track "%s" cannot be stopped as it is not loaded!', animation.Name)
	)

	fadeTime = fadeTime or animation:GetAttribute(ANIM_FADE_TIME_ATTRIBUTE)
	animationTrack:Stop(fadeTime)
	return animationTrack
end

--[=[ 
	Stops all loaded animations by calling [CustomAnimator:stopAnimation] on each loaded animation.
]=]

function CustomAnimator.__index:stopAll(fadeTime: number?)
	for animation in self._loadedAnimationTracks do
		self:stopAnimation(animation, fadeTime)
	end
end

--[=[ 
	Returns a read only array of all animations loaded into the animator object.
]=]

function CustomAnimator.__index:all(): { [Animation]: AnimationTrack }
	return table.freeze(table.clone(self._loadedAnimationTracks))
end

--[=[ 
	Stops the given animation track if loaded, and destroys it. 
]=]

function CustomAnimator.__index:cleanupAnimationTrack(animation: Animation)
	local animationTrack: AnimationTrack? = self:animationTrack(animation)

	if animationTrack then
		animationTrack:Stop()
		animationTrack:Destroy()
	end

	self._loadedAnimationTracks[animation] = nil
end

--[=[ 
	Returns the animator associated to the animator object.
]=]

function CustomAnimator.__index:animator(): Animator
	return self._animator
end

--[=[ 
	Destroys the custom animator object and renders it unusuable. Additionally, [CustomAnimator:cleanupAnimationTrack] is called
	on all loaded animation tracks too.
]=]

function CustomAnimator.__index:destroy()
	for animation in table.clone(self._loadedAnimationTracks) do
		self:cleanupAnimationTrack(animation)
	end

	self._onAnimationLoaded:Destroy()
	setmetatable(self, nil)
end

export type CustomAnimator = typeof(CustomAnimator.new(Instance.new("Animator")))

return table.freeze(CustomAnimator)
