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

--[=[ 
	@prop onAnimationLoaded Signal<animation: Animation, animationTrack: AnimationTrack>
	@tag CustomAnimator Instance 
	@within CustomAnimator

	A signal which is fired whenever a new animation is loaded through [CustomAnimator:loadAnimation].
]=]

local Promise = require(script.Parent.Promise)
local Signal = require(script.Parent.Signal)
local instanceTroveUtil = require(script.Parent.instanceTroveUtil)

local ANIM_FADE_TIME_ATTRIBUTE = "AnimationPlayFadeTime"
local ANIM_WEIGHT_TIME_ATTRIBUTE = "AnimationPlayWeight"
local ANIM_SPEED_TIME_ATTRIBUTE = "AnimationPlaySpeed"

local CustomAnimator = {}
CustomAnimator.__index = {}

--[=[ 
	Creates and returns a new custom animator object. 

	@return CustomAnimator
]=]

function CustomAnimator.new(animator: Animator | AnimationController)
	assert(
		typeof(animator) == "Instance"
			and (animator:IsA("Animator") or animator:IsA("AnimationController")),
		string.format(
			"Bad argument #1 to 'animator', expected `Animator` or `AnimationController`, got %s instead!",
			if typeof(animator) == "Instance" then animator.ClassName else typeof(animator)
		)
	)

	return setmetatable({
		onAnimationLoaded = Signal.new(),
		_animator = animator,
		_loadedAnimationTracks = {},
		_scheduledAnimationPlayOnLoadPromises = {},
	}, CustomAnimator)
end

--[=[ 
	@tag CustomAnimator instance

	Returns the given loaded animation track from the animation, if found.
]=]

function CustomAnimator.__index:animationTrack(animation: Animation): AnimationTrack?
	return self._loadedAnimationTracks[animation]
end

--[=[ 
	@tag CustomAnimator instance

	Returns a promise which is resolved once the given animation is loaded via [CustomAnimator:loadAnimation].

	:::note Automatic promise cancellation
	The returned promise will be cancelled if the animator object or the animation controller object this custom
	animator is connected to, is destroyed.
	:::

	@return Promise<AnimationTrack>
]=]

function CustomAnimator.__index:onAnimationLoadPromise(animation: Animation)
	local animatorTrove = instanceTroveUtil.instanceTrove(self._animator)
	return animatorTrove:AddPromise(Promise.new(function(resolve)
		while self._loadedAnimationTracks[animation] == nil do
			self.onAnimationLoaded:Wait()
		end

		resolve(self._loadedAnimationTracks[animation])
	end))
end

--[=[ 
	@tag CustomAnimator instance

	Loads in the given `animation`.
]=]

function CustomAnimator.__index:loadAnimation(animation: Animation): AnimationTrack
	local animationTrack: AnimationTrack = self._animator:LoadAnimation(animation)
	self._loadedAnimationTracks[animation] = animationTrack
	self.onAnimationLoaded:Fire(animation, animationTrack)
	return animationTrack
end

--[=[ 
	@tag CustomAnimator instance

	Tries to play the given `animation`, if it has been loaded into the custom animator via [CustomAnimator:loadAnimation]. This
	method will return the animation track of the loaded `animation` upon successfully playing it, else it'll return `nil`.

	:::tip
	You can also setup attributes for `fadeTime`, `weight`, and `speed` in `animation`,  which will be used incase the
	arguments for them aren't specified.

	| Attribute | Argument 
	| -- | -- |
	| `"AnimationPlayFadeTime"` | `fadeTime` 
	| `"AnimationPlayWeight"` | `weight` 
	| `"AnimationPlaySpeed"` | `speed` 
	:::
]=]

function CustomAnimator.__index:tryPlayAnimation(
	animation: Animation,
	priority: Enum.AnimationPriority?,
	fadeTime: number?,
	weight: number?,
	speed: number?
): AnimationTrack?
	local animationTrack: AnimationTrack = self:animationTrack(animation)
	if animationTrack == nil then
		return nil
	end

	fadeTime = fadeTime or animation:GetAttribute(ANIM_FADE_TIME_ATTRIBUTE)
	weight = weight or animation:GetAttribute(ANIM_WEIGHT_TIME_ATTRIBUTE)
	speed = speed or animation:GetAttribute(ANIM_SPEED_TIME_ATTRIBUTE)
	animationTrack.Priority = priority or animationTrack.Priority
	animationTrack:Play(fadeTime, weight, speed)
	return animationTrack
end

--[=[ 
	@tag CustomAnimator instance
	@return Promise<>

	Plays the given `animation` as soon as it is loaded into the custom animator. Returns a promise which is resolved
	once the given `animation` has **finished playing**. Additionally, you can cancel the returned promise which in turn
	will also stop the `animation` from playing any further.
	
	:::note Automatic promise cancellation
	- If this method is called again for the same animation while the previous promise has not yet finished, then the previous promise
	will be cancelled.
	
	- The returned promise will be cancelled if the animator object or the animation controller object this custom
	animator is connected to, is destroyed.
	:::
]=]

function CustomAnimator.__index:scheduleAnimationToPlayOnLoadPromise(
	animation: Animation,
	priority: Enum.AnimationPriority?,
	fadeTime: number?,
	weight: number?,
	speed: number?
): AnimationTrack?
	local scheduledAnimationPlayOnLoadPromise =
		self._scheduledAnimationPlayOnLoadPromises[animation]
	if scheduledAnimationPlayOnLoadPromise ~= nil then
		scheduledAnimationPlayOnLoadPromise:cancel()
	end

	local animatorTrove = instanceTroveUtil.instanceTrove(self._animator)
	self._scheduledAnimationPlayOnLoadPromises[animation] =
		animatorTrove:AddPromise(Promise.new(function(resolve, _, onCancel)
			local animationLoadPromise = self:onAnimationLoadPromise(animation)
			onCancel(function()
				animationLoadPromise:cancel()
			end)

			animationLoadPromise:expect()

			local animationTrack: AnimationTrack =
				self:tryPlayAnimation(animation, priority, fadeTime, weight, speed)
			local animationTrackEndedPromise = Promise.fromEvent(animationTrack.Ended)

			onCancel(function()
				animationTrackEndedPromise:cancel()
				self:tryStopAnimation(animation)
			end)

			animationTrackEndedPromise:expect()
			resolve()
		end))

	self._scheduledAnimationPlayOnLoadPromises[animation]:finally(function()
		self._scheduledAnimationPlayOnLoadPromises[animation] = nil
	end)

	return self._scheduledAnimationPlayOnLoadPromises[animation]
end

--[=[ 
	@tag CustomAnimator instance

	Tries to stop the given `animation`, if it is loaded. Also cancels the promise returned by 
	[CustomAnimator:scheduleAnimationPlayOnLoadPromise] for the given `animation`, if found.
]=]

function CustomAnimator.__index:tryStopAnimation(animation: Animation, fadeTime: number?)
	local scheduledAnimationPlayOnLoadPromise =
		self._scheduledAnimationPlayOnLoadPromises[animation]
	if scheduledAnimationPlayOnLoadPromise ~= nil then
		scheduledAnimationPlayOnLoadPromise:cancel()
	end

	local animationTrack: AnimationTrack = self:animationTrack(animation)
	if animationTrack == nil then
		return
	end

	fadeTime = fadeTime or animation:GetAttribute(ANIM_FADE_TIME_ATTRIBUTE)
	animationTrack:Stop(fadeTime)
end

--[=[ 
	@tag CustomAnimator instance

	Stops all loaded animations by calling [CustomAnimator:tryStopAnimation] on each one of them.
]=]

function CustomAnimator.__index:stopAll(fadeTime: number?)
	for animation in self._loadedAnimationTracks do
		self:tryStopAnimation(animation, fadeTime)
	end
end

--[=[ 
	@tag CustomAnimator instance

	Returns a read only copy dictionary of all animations loaded into the animator object.
]=]

function CustomAnimator.__index:all(): { [Animation]: AnimationTrack }
	return table.freeze(table.clone(self._loadedAnimationTracks))
end

--[=[ 
	@tag CustomAnimator instance

	Destroys the animation track of the given `animation` if loaded, and removes it from the custom animator. 
]=]

function CustomAnimator.__index:cleanupAnimation(animation: Animation)
	local animationTrack: AnimationTrack? = self:animationTrack(animation)
	if animationTrack ~= nil then
		animationTrack:Destroy()
	end

	self._loadedAnimationTracks[animation] = nil
end

--[=[ 
	@tag CustomAnimator instance

	Returns the animator associated to the animator object.
]=]

function CustomAnimator.__index:animator(): Animator
	return self._animator
end

--[=[ 
	@tag CustomAnimator instance
	
	Destroys the custom animator object and renders it unusuable. Additionally, [CustomAnimator:cleanupAnimationTrack] is called
	on all loaded animation tracks too.
]=]

function CustomAnimator.__index:destroy()
	for animation in table.clone(self._loadedAnimationTracks) do
		self:cleanupAnimation(animation)
	end

	self.onAnimationLoaded:Destroy()
	setmetatable(self, nil)
end

export type CustomAnimator = typeof(CustomAnimator.new(Instance.new("Animator")))

return table.freeze(CustomAnimator)
