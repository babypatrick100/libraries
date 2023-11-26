--[=[
    @class rain

    Rain module by builthomas, *heavily modified and refactored by bub*.
]=]

--[[
	Rain module v1.0 by buildthomas (July 2018) 

	This module is licensed under the APLv2:
	http://www.apache.org/licenses/LICENSE-2.0
	
	In short, you may use this code only if you agree to the following:
	* This notice must always be present and may not be modified or removed in any copy of this code or derived code.
	* You may use this in commercial, closed source projects, and you may modify the source code itself.
	
	Refer to the license for a full description.
	
	For questions please reach out on the Developer Forum (@buildthomas)
	or via Twitter (https://www.twitter.com/buildthomasRBX)
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local Property = require(script.Parent.Property)

local MIN_SIZE = Vector3.new(0.05, 0.05, 0.05) -- Size of main emitter part when rain inactive
local RAIN_DEFAULT_COLOR = Color3.new(1, 1, 1) -- Default color3 of all rain elements
local RAIN_DEFAULT_TRANSPARENCY = 0 -- Default transparency scale ratio of all rain elements
local RAIN_DEFAULT_SPEEDRATIO = 1 -- Default speed scale ratio of falling rain effects
local RAIN_DEFAULT_INTENSITYRATIO = 1 -- Default intensity ratio of all rain elements
local RAIN_DEFAULT_LIGHTEMISSION = 0.05 -- Default lightEmission of all rain elements
local RAIN_DEFAULT_LIGHTINFLUENCE = 0.9 -- Default lightInfluence of all rain elements
local RAIN_DEFAULT_DIRECTION = Vector3.new(0, -1, 0) -- Default direction for rain to fall into

local RAIN_TRANSPARENCY_T1 = 0.25 -- Define the shape (time-wise) of the transparency curves for emitters
local RAIN_TRANSPARENCY_T2 = 0.75

local RAIN_SCANHEIGHT = 1000 -- How many studs to scan up from camera position to determine whether occluded

local RAIN_EMITTER_DIM_DEFAULT = 40 -- Size of emitter block to the side/up
local RAIN_EMITTER_DIM_MAXFORWARD = 100 -- Size of emitter block forwards when looking at the horizon
local RAIN_EMITTER_UP_MODIFIER = 20 -- Maximum vertical displacement of emitter (when looking fully up/down)

local RAIN_SOUND_ASSET = "rbxassetid://1516791621"
local RAIN_SOUND_BASEVOLUME = 0.2 -- Starting volume of rain sound effect when not occluded
local RAIN_SOUND_FADEOUT_TIME = 1
local GOAL_RAIN_SOUND_VOLUME = 0.5

local RAIN_STRAIGHT_ASSET = "rbxassetid://1822883048" -- Some properties of the straight rain particle effect
local RAIN_STRAIGHT_ALPHA_LOW = 0.7 -- Minimum particle transparency for the straight rain emitter
local RAIN_STRAIGHT_SIZE = NumberSequence.new(10)
local RAIN_STRAIGHT_LIFETIME = NumberRange.new(0.8)
local RAIN_STRAIGHT_MAX_RATE = 600 -- Maximum rate for the straight rain emitter
local RAIN_STRAIGHT_MAX_SPEED = 60 -- Maximum speed for the straight rain emitter

local RAIN_TOPDOWN_ASSET = "rbxassetid://1822856633" -- Some properties of the top-down rain particle effect
local RAIN_TOPDOWN_ALPHA_LOW = 0.85 -- Minimum particle transparency for the top-down rain emitter
local RAIN_TOPDOWN_SIZE = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 5.33, 2.75),
	NumberSequenceKeypoint.new(1, 5.33, 2.75),
})
local RAIN_TOPDOWN_LIFETIME = NumberRange.new(0.8)
local RAIN_TOPDOWN_ROTATION = NumberRange.new(0, 360)
local RAIN_TOPDOWN_MAX_RATE = 600 -- Maximum rate for the top-down rain emitter
local RAIN_TOPDOWN_MAX_SPEED = 60 -- Maximum speed for the top-down rain emitter

local RAIN_SPLASH_ASSET = "rbxassetid://1822856633" -- Some properties of the splash particle effect
local RAIN_SPLASH_ALPHA_LOW = 0.6 -- Minimum particle transparency for the splash emitters
local RAIN_SPLASH_SIZE = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.4, 3),
	NumberSequenceKeypoint.new(1, 0),
})
local RAIN_SPLASH_LIFETIME = NumberRange.new(0.1, 0.15)
local RAIN_SPLASH_ROTATION = NumberRange.new(0, 360)
local RAIN_SPLASH_NUM = 20 -- Amount of splashes per frame
local RAIN_SPLASH_CORRECTION_Y = 0.5 -- Offset from impact position for visual reasons
local RAIN_SPLASH_STRAIGHT_OFFSET_Y = 50 -- Offset against rain direction for straight rain particles from splash position
local RAIN_NOSPLASH_STRAIGHT_OFFSET_Y_MIN = 20 -- Min/max vertical offset from camera height for straight rain particles
local RAIN_NOSPLASH_STRAIGHT_OFFSET_Y_MAX = 100 -- when no splash position could be found (i.e. no floor at that XZ-column)

local RAIN_OCCLUDED_MINSPEED = 70 -- Minimum speed for the occluded straight rain emitters
local RAIN_OCCLUDED_MAXSPEED = 100 -- Maximum speed for the occluded straight rain emitters
local RAIN_OCCLUDED_SPREAD = Vector2.new(10, 10) -- Spread angle for the occluded straight rain emitters
local RAIN_OCCLUDED_MAXINTENSITY = 2 -- How many occluded straight rain particles are emitted for every splash for max intensity

local RAIN_OCCLUDECHECK_OFFSET_Y = 500 -- Vertical offset from camera height to start scanning downward from for splashes
local RAIN_OCCLUDECHECK_OFFSET_XZ_MIN = -100 -- Range of possible XZ offset values from camera XZ position for the splashes
local RAIN_OCCLUDECHECK_OFFSET_XZ_MAX = 100
local RAIN_OCCLUDECHECK_SCAN_Y = 550 -- Scan magnitude along rain path

local TWEEN_INFO_DELAY_1 = TweenInfo.new(1)
local TWEEN_INFO_DELAY_HALF = TweenInfo.new(0.5)

local RAIN_UPDATE_PERIOD = 6 -- Update the transparency of the main emitters + volume of rain inside every X frames

local RAIN_VOLUME_SCAN_RADIUS = 35 -- Defining grid for checking how far the camera is away from a spot exposed to rain
local RAIN_VOLUME_SCAN_GRID = { -- Unit range grid for scanning how far away user is from rain space
	-- range 0.2, 4 pts
	Vector3.new(0.141421363, 0, 0.141421363),
	Vector3.new(-0.141421363, 0, 0.141421363),
	Vector3.new(-0.141421363, 0, -0.141421363),
	Vector3.new(0.141421363, 0, -0.141421363),
	-- range 0.4, 8 pts
	Vector3.new(0.400000006, 0, 0),
	Vector3.new(0.282842726, 0, 0.282842726),
	Vector3.new(2.44929371e-17, 0, 0.400000006),
	Vector3.new(-0.282842726, 0, 0.282842726),
	Vector3.new(-0.400000006, 0, 4.89858741e-17),
	Vector3.new(-0.282842726, 0, -0.282842726),
	Vector3.new(-7.34788045e-17, 0, -0.400000006),
	Vector3.new(0.282842726, 0, -0.282842726),
	-- range 0.6, 10 pts
	Vector3.new(0.600000024, 0, 0),
	Vector3.new(0.485410213, 0, 0.352671146),
	Vector3.new(0.185410202, 0, 0.570633948),
	Vector3.new(-0.185410202, 0, 0.570633948),
	Vector3.new(-0.485410213, 0, 0.352671146),
	Vector3.new(-0.600000024, 0, 7.34788112e-17),
	Vector3.new(-0.485410213, 0, -0.352671146),
	Vector3.new(-0.185410202, 0, -0.570633948),
	Vector3.new(0.185410202, 0, -0.570633948),
	Vector3.new(0.485410213, 0, -0.352671146),
	-- range 0.8, 12 pts
	Vector3.new(0.772740662, 0, 0.207055241),
	Vector3.new(0.565685451, 0, 0.565685451),
	Vector3.new(0.207055241, 0, 0.772740662),
	Vector3.new(-0.207055241, 0, 0.772740662),
	Vector3.new(-0.565685451, 0, 0.565685451),
	Vector3.new(-0.772740662, 0, 0.207055241),
	Vector3.new(-0.772740662, 0, -0.207055241),
	Vector3.new(-0.565685451, 0, -0.565685451),
	Vector3.new(-0.207055241, 0, -0.772740662),
	Vector3.new(0.207055241, 0, -0.772740662),
	Vector3.new(0.565685451, 0, -0.565685451),
	Vector3.new(0.772740662, 0, -0.207055241),
}

local globalModifier = Instance.new("NumberValue") -- modifier for rain visibility for disabling/enabling over time span
globalModifier.Value = 1 -- 0 = fully visible, 1 = invisible

local CollisionMode = table.freeze({
	none = 0,
	whitelist = 1,
	blacklist = 2,
	callback = 3,
})

local connections = {} -- Stores connections to RunService signals when enabled
local disabled = true -- Value to figure out whether we are moving towards a disabled state (useful during tweens)
local rainDirection = RAIN_DEFAULT_DIRECTION -- Direction that rain falls into
local currentCeiling = nil -- Y coordinate of ceiling (if present)

local collisionMode = CollisionMode.none -- Collision mode (from rain.CollisionMode) for raycasting
local collisionList = nil -- blacklist/whitelist for raycasting
local collisionFunc = nil -- Raycasting test function for when collisionMode == rain.CollisionMode.callback

local straightLowAlpha = 1 -- Current transparency for straight rain particles
local topdownLowAlpha = 1 -- Current transparency for top-down rain particles
local intensityOccludedRain = 0 -- Current intensity of occluded rain particles
local numSplashes = 0 -- Current number of generated splashes per frame
local volumeTarget = 0 -- Current (target of tween for) sound volume

-- shorthands
local NSK010 = NumberSequenceKeypoint.new(0, 1, 0)
local NSK110 = NumberSequenceKeypoint.new(1, 1, 0)

local volumeScanGrid = table.create(#RAIN_VOLUME_SCAN_GRID) -- Pre-generate grid used for raining area distance scanning
for _, v in RAIN_VOLUME_SCAN_GRID do
	table.insert(volumeScanGrid, v * RAIN_VOLUME_SCAN_RADIUS)
end
table.sort(
	volumeScanGrid,
	function(a, b) -- Optimization: sort from close to far away for fast evaluation if closeby
		return a.Magnitude < b.Magnitude
	end
)

-- sound group for easy main volume tweaking
local soundGroup = Instance.new("SoundGroup")
soundGroup.Name = "__RainSoundGroup"
soundGroup.Volume = RAIN_SOUND_BASEVOLUME
soundGroup.Archivable = false

local rainSound

local function createRainSound(desiredSoundGroup)
	local sound = Instance.new("Sound")
	sound.Name = "__RainSound"
	sound.Volume = volumeTarget
	sound.SoundId = RAIN_SOUND_ASSET
	sound.Looped = true
	sound.SoundGroup = desiredSoundGroup
	sound.Parent = desiredSoundGroup
	sound.Archivable = false
	return sound
end

rainSound = createRainSound(soundGroup)

-- emitter block around camera used when outside
local emitter
do
	emitter = Instance.new("Part")
	emitter.Transparency = 1
	emitter.Anchored = true
	emitter.CanCollide = false
	emitter.Locked = false
	emitter.Archivable = false
	emitter.TopSurface = Enum.SurfaceType.Smooth
	emitter.BottomSurface = Enum.SurfaceType.Smooth
	emitter.Name = "__RainEmitter"
	emitter.Size = MIN_SIZE
	emitter.Archivable = false

	local straight = Instance.new("ParticleEmitter")
	straight.Name = "RainStraight"
	straight.LightEmission = RAIN_DEFAULT_LIGHTEMISSION
	straight.LightInfluence = RAIN_DEFAULT_LIGHTINFLUENCE
	straight.Size = RAIN_STRAIGHT_SIZE
	straight.Texture = RAIN_STRAIGHT_ASSET
	straight.LockedToPart = true
	straight.Enabled = false
	straight.Lifetime = RAIN_STRAIGHT_LIFETIME
	straight.Rate = RAIN_STRAIGHT_MAX_RATE
	straight.Speed = NumberRange.new(RAIN_STRAIGHT_MAX_SPEED)
	straight.EmissionDirection = Enum.NormalId.Bottom
	straight.Parent = emitter
	straight.Orientation = Enum.ParticleOrientation.FacingCameraWorldUp

	local topdown = Instance.new("ParticleEmitter")
	topdown.Name = "RainTopDown"
	topdown.LightEmission = RAIN_DEFAULT_LIGHTEMISSION
	topdown.LightInfluence = RAIN_DEFAULT_LIGHTINFLUENCE
	topdown.Size = RAIN_TOPDOWN_SIZE
	topdown.Texture = RAIN_TOPDOWN_ASSET
	topdown.LockedToPart = true
	topdown.Enabled = false
	topdown.Rotation = RAIN_TOPDOWN_ROTATION
	topdown.Lifetime = RAIN_TOPDOWN_LIFETIME
	topdown.Rate = RAIN_TOPDOWN_MAX_RATE
	topdown.Speed = NumberRange.new(RAIN_TOPDOWN_MAX_SPEED)
	topdown.EmissionDirection = Enum.NormalId.Bottom
	topdown.Parent = emitter
end

local splashAttachments, rainAttachments
do
	splashAttachments = {}
	rainAttachments = {}

	for _ = 1, RAIN_SPLASH_NUM do
		-- splashes on ground
		local splashAttachment = Instance.new("Attachment")
		splashAttachment.Name = "__RainSplashAttachment"
		local splash = Instance.new("ParticleEmitter")
		splash.LightEmission = RAIN_DEFAULT_LIGHTEMISSION
		splash.LightInfluence = RAIN_DEFAULT_LIGHTINFLUENCE
		splash.Size = RAIN_SPLASH_SIZE
		splash.Texture = RAIN_SPLASH_ASSET
		splash.Rotation = RAIN_SPLASH_ROTATION
		splash.Lifetime = RAIN_SPLASH_LIFETIME
		splash.Transparency = NumberSequence.new({
			NSK010,
			NumberSequenceKeypoint.new(RAIN_TRANSPARENCY_T1, RAIN_SPLASH_ALPHA_LOW, 0),
			NumberSequenceKeypoint.new(RAIN_TRANSPARENCY_T2, RAIN_SPLASH_ALPHA_LOW, 0),
			NSK110,
		})
		splash.Enabled = false
		splash.Rate = 0
		splash.Speed = NumberRange.new(0)
		splash.Name = "RainSplash"
		splash.Parent = splashAttachment
		splashAttachment.Archivable = false
		table.insert(splashAttachments, splashAttachment)

		-- occluded rain particle generation
		local rainAttachment = Instance.new("Attachment")
		rainAttachment.Name = "__RainOccludedAttachment"
		local straightOccluded = emitter.RainStraight:Clone()
		straightOccluded.Speed = NumberRange.new(RAIN_OCCLUDED_MINSPEED, RAIN_OCCLUDED_MAXSPEED)
		straightOccluded.SpreadAngle = RAIN_OCCLUDED_SPREAD
		straightOccluded.LockedToPart = false
		straightOccluded.Enabled = false
		straightOccluded.Parent = rainAttachment
		local topdownOccluded = emitter.RainTopDown:Clone()
		topdownOccluded.Speed = NumberRange.new(RAIN_OCCLUDED_MINSPEED, RAIN_OCCLUDED_MAXSPEED)
		topdownOccluded.SpreadAngle = RAIN_OCCLUDED_SPREAD
		topdownOccluded.LockedToPart = false
		topdownOccluded.Enabled = false
		topdownOccluded.Parent = rainAttachment
		rainAttachment.Archivable = false
		table.insert(rainAttachments, rainAttachment)
	end
end

local ignoreEmitterList = { emitter }
local raycastParams = RaycastParams.new()
local raycastFunctions = {}
raycastFunctions[CollisionMode.none] = function(
	origin: Vector3,
	direction: Vector3,
	ignoreCharacter: boolean?
)
	if collisionList then
		raycastParams.FilterDescendantsInstances = {}

		raycastParams:AddToFilter(
			if ignoreCharacter
				then { emitter, if Players.LocalPlayer then Players.LocalPlayer.Character else nil }
				else ignoreEmitterList
		)

		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	end

	return Workspace:Raycast(origin, direction, if collisionList then raycastParams else nil)
end
raycastFunctions[CollisionMode.blacklist] = function(origin: Vector3, direction: Vector3)
	if collisionList then
		raycastParams.FilterDescendantsInstances = {}
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams:AddToFilter(collisionList)
	end

	return Workspace:Raycast(origin, direction, if collisionList then raycastParams else nil)
end
raycastFunctions[CollisionMode.whitelist] = function(origin: Vector3, direction: Vector3)
	if collisionList then
		raycastParams.FilterDescendantsInstances = {}
		raycastParams.FilterType = Enum.RaycastFilterType.Include
		raycastParams:AddToFilter(collisionList)
	end

	return Workspace:Raycast(origin, direction, if collisionList then raycastParams else nil)
end
raycastFunctions[CollisionMode.callback] = function(origin: Vector3, direction: Vector3)
	local rayDestination = origin + direction
	local ray = raycastFunctions[CollisionMode.blacklist](origin, direction, ignoreEmitterList)

	-- draw multiple raycasts concatenated to each other until no hit / valid hit found
	while direction.Magnitude > 0.001 and ray ~= nil do
		if not collisionFunc(ray.Instance) then
			return ray
		end

		local start = ray.Position + direction.Unit * 0.001
		direction = rayDestination - start
		ray = raycastFunctions[CollisionMode.blacklist](start, direction, ignoreEmitterList)
	end

	return nil
end

local raycast = raycastFunctions[collisionMode]

--[=[
	@type CollisonModeFunction ((basePart: BasePart) -> boolean)?
	@within rain

	A predicate which is called automatically and is passed a base part as the only
	argument. 
	
	- If the predicate returns a *truthy* value, then the rain will hit the given
	base part.

	- If the predicate returns a non *truthy* value, then the rain will NOT
	hit the given basepart.
]=]

type CollisonModeFunction = ((basePart: BasePart) -> boolean)?

local function connectLoop()
	local rand = Random.new()

	local inside = true -- Whether camera is currently in a spot occluded from the sky
	local frame = RAIN_UPDATE_PERIOD -- Frame counter, and force update cycle right now

	-- Update emitter on RenderStepped since it needs to be synced to Camera
	table.insert(
		connections,
		RunService.RenderStepped:connect(function()
			-- Check if camera is outside or inside
			local part = raycast(
				Workspace.CurrentCamera.CFrame.Position,
				-rainDirection * RAIN_SCANHEIGHT,
				true
			)

			if
				(not currentCeiling or Workspace.CurrentCamera.CFrame.Position.Y <= currentCeiling)
				and not part
			then
				-- Camera is outside and under ceiling
				if volumeTarget < 1 and not disabled then
					volumeTarget = 1
					TweenService
						:Create(
							rainSound,
							TWEEN_INFO_DELAY_HALF,
							{ Volume = GOAL_RAIN_SOUND_VOLUME }
						)
						:Play()
				end

				frame = RAIN_UPDATE_PERIOD

				local t = math.abs(Workspace.CurrentCamera.CFrame.LookVector:Dot(rainDirection))

				local center = Workspace.CurrentCamera.CFrame.Position
				local right = Workspace.CurrentCamera.CFrame.LookVector:Cross(-rainDirection)
				right = right.Magnitude > 0.001 and right.Unit or -rainDirection
				local forward = rainDirection:Cross(right).Unit

				emitter.Size = Vector3.new(
					RAIN_EMITTER_DIM_DEFAULT,
					RAIN_EMITTER_DIM_DEFAULT,
					RAIN_EMITTER_DIM_DEFAULT
						+ (1 - t) * (RAIN_EMITTER_DIM_MAXFORWARD - RAIN_EMITTER_DIM_DEFAULT)
				)

				emitter.CFrame = CFrame.new(
					center.X,
					center.Y,
					center.Z,
					right.X,
					-rainDirection.X,
					forward.X,
					right.Y,
					-rainDirection.Y,
					forward.Y,
					right.Z,
					-rainDirection.Z,
					forward.Z
				) + (1 - t) * Workspace.CurrentCamera.CFrame.LookVector * emitter.Size.Z / 3 - t * rainDirection * RAIN_EMITTER_UP_MODIFIER

				emitter.RainStraight.Enabled = true
				emitter.RainTopDown.Enabled = true

				inside = false
			else
				-- Camera is inside / above ceiling

				emitter.RainStraight.Enabled = false
				emitter.RainTopDown.Enabled = false

				inside = true
			end
		end)
	)

	-- Do the other effects on Stepped
	local signal = RunService:IsRunning() and RunService.Stepped or RunService.RenderStepped
	table.insert(
		connections,
		signal:connect(function()
			frame = frame + 1

			-- Only do some updates once every few frames
			if frame >= RAIN_UPDATE_PERIOD then
				-- Measure of how much camera is facing down (0-1)
				local t = math.abs(Workspace.CurrentCamera.CFrame.LookVector:Dot(rainDirection))

				-- More looking down = see straight particles less and see top-down particles more
				local straightSequence = NumberSequence.new({
					NSK010,
					NumberSequenceKeypoint.new(
						RAIN_TRANSPARENCY_T1,
						(1 - t) * straightLowAlpha + t,
						0
					),
					NumberSequenceKeypoint.new(
						RAIN_TRANSPARENCY_T2,
						(1 - t) * straightLowAlpha + t,
						0
					),
					NSK110,
				})
				local topdownSequence = NumberSequence.new({
					NSK010,
					NumberSequenceKeypoint.new(
						RAIN_TRANSPARENCY_T1,
						t * topdownLowAlpha + (1 - t),
						0
					),
					NumberSequenceKeypoint.new(
						RAIN_TRANSPARENCY_T2,
						t * topdownLowAlpha + (1 - t),
						0
					),
					NSK110,
				})

				-- Find desired rotation for the straight rain particles
				local mapped = Workspace.CurrentCamera.CFrame:inverse()
					* (Workspace.CurrentCamera.CFrame.Position - rainDirection)
				local straightRotation = NumberRange.new(math.deg(math.atan2(-mapped.X, mapped.Y)))

				if inside then
					-- Update emitter properties
					for _, v in rainAttachments do
						v.RainStraight.Transparency = straightSequence
						v.RainStraight.Rotation = straightRotation
						v.RainTopDown.Transparency = topdownSequence
					end

					if not disabled then
						-- Only do occluded volume check if not moving towards disabled state
						local volume = 0

						if
							not currentCeiling
							or Workspace.CurrentCamera.CFrame.Position.Y <= currentCeiling
						then
							-- Check how far away camera is from a space open to the sky using volume scan grid

							local minDistance = RAIN_VOLUME_SCAN_RADIUS
							local rayDirection = -rainDirection * RAIN_SCANHEIGHT

							for i = 1, #volumeScanGrid do -- In order, so first hit is closest
								if
									not raycast(
										Workspace.CurrentCamera.CFrame * volumeScanGrid[i],
										rayDirection,
										true
									)
								then
									minDistance = volumeScanGrid[i].Magnitude
									break
								end
							end

							-- Volume is inversely proportionate to minimum distance
							volume = 1 - minDistance / RAIN_VOLUME_SCAN_RADIUS
						end

						if math.abs(volume - volumeTarget) > 0.01 then
							-- Value is sufficiently different from previous target, overwrite it
							volumeTarget = volume
							TweenService
								:Create(rainSound, TWEEN_INFO_DELAY_1, { Volume = volumeTarget })
								:Play()
						end
					end
				else
					-- Update emitter properties
					emitter.RainStraight.Transparency = straightSequence
					emitter.RainStraight.Rotation = straightRotation
					emitter.RainTopDown.Transparency = topdownSequence
				end

				-- Reset frame counter
				frame = 0
			end

			local center = Workspace.CurrentCamera.CFrame.Position
			local right = Workspace.CurrentCamera.CFrame.LookVector:Cross(-rainDirection)
			right = if right.Magnitude > 0.001 then right.Unit else -rainDirection

			local forward = rainDirection:Cross(right).Unit
			local transform = CFrame.new(
				center.X,
				center.Y,
				center.Z,
				right.X,
				-rainDirection.X,
				forward.X,
				right.Y,
				-rainDirection.Y,
				forward.Y,
				right.Z,
				-rainDirection.Z,
				forward.Z
			)
			local rayDirection = rainDirection * RAIN_OCCLUDECHECK_SCAN_Y

			-- Splash and occlusion effects
			for i = 1, numSplashes do
				local splashAttachment = splashAttachments[i]
				local rainAttachment = rainAttachments[i]

				-- Sample random splash position
				local x = rand:NextNumber(
					RAIN_OCCLUDECHECK_OFFSET_XZ_MIN,
					RAIN_OCCLUDECHECK_OFFSET_XZ_MAX
				)
				local z = rand:NextNumber(
					RAIN_OCCLUDECHECK_OFFSET_XZ_MIN,
					RAIN_OCCLUDECHECK_OFFSET_XZ_MAX
				)
				local ray =
					raycast(transform * Vector3.new(x, RAIN_OCCLUDECHECK_OFFSET_Y, z), rayDirection)

				if ray then
					-- Draw a splash at hit
					splashAttachment.Position = ray.Position + ray.Normal * RAIN_SPLASH_CORRECTION_Y
					splashAttachment.RainSplash:Emit(1)

					if inside then
						-- Draw occlusion rain particles a little bit above the splash position
						local corrected = ray.Position
							- rainDirection * RAIN_SPLASH_STRAIGHT_OFFSET_Y
						if
							currentCeiling
							and corrected.Y > currentCeiling
							and rainDirection.Y < 0
						then
							corrected = corrected
								+ rainDirection
									* (currentCeiling - corrected.Y)
									/ rainDirection.Y
						end
						rainAttachment.CFrame = transform - transform.Position + corrected
						rainAttachment.RainStraight:Emit(intensityOccludedRain)
						rainAttachment.RainTopDown:Emit(intensityOccludedRain)
					end
				elseif inside then
					-- Draw occlusion rain particles on the XZ-position at around the camera's height
					local corrected = transform
						* Vector3.new(
							x,
							rand:NextNumber(
								RAIN_NOSPLASH_STRAIGHT_OFFSET_Y_MIN,
								RAIN_NOSPLASH_STRAIGHT_OFFSET_Y_MAX
							),
							z
						)
					if currentCeiling and corrected.Y > currentCeiling and rainDirection.Y < 0 then
						corrected = corrected
							+ rainDirection * (currentCeiling - corrected.Y) / rainDirection.Y
					end
					rainAttachment.CFrame = transform - transform.Position + corrected
					rainAttachment.RainStraight:Emit(intensityOccludedRain)
					rainAttachment.RainTopDown:Emit(intensityOccludedRain)
				end
			end
		end)
	)
end

local function disconnectLoop()
	for _, v in connections do
		v:disconnect()
	end

	table.clear(connections)
end

local function disableSound(tweenInfo)
	-- Tween the rain sound to be mute over a given easing function
	volumeTarget = 0
	local tween = TweenService:Create(rainSound, tweenInfo, { Volume = 0 })
	tween.Completed:connect(function(state)
		if state == Enum.PlaybackState.Completed then
			rainSound:Stop()
		end
		tween:Destroy()
	end)
	tween:Play()
end

local function disable()
	disconnectLoop()

	-- Hide emitter
	emitter.RainStraight.Enabled = false
	emitter.RainTopDown.Enabled = false
	emitter.Size = MIN_SIZE

	-- Disable sound now if not tweened into disabled state beforehand
	if not disabled then
		disableSound(TweenInfo.new(RAIN_SOUND_FADEOUT_TIME))
	end
end

-- Shorthand for creating a tweenable "variable" using value object
local function makeProperty(valueObjectClass, defaultValue, setter)
	local valueObject = Instance.new(valueObjectClass)
	if defaultValue then
		valueObject.Value = defaultValue
	end
	valueObject.Changed:connect(setter)
	setter(valueObject.Value)
	return valueObject
end

local colorProp = makeProperty("Color3Value", RAIN_DEFAULT_COLOR, function(value)
	value = ColorSequence.new(value)
	emitter.RainStraight.Color = value
	emitter.RainTopDown.Color = value

	for _, v in splashAttachments do
		v.RainSplash.Color = value
	end
	for _, v in rainAttachments do
		v.RainStraight.Color = value
		v.RainTopDown.Color = value
	end
end)

local function updateTransparency(value)
	local opacity = (1 - value) * (1 - globalModifier.Value)
	local transparency = 1 - opacity

	straightLowAlpha = RAIN_STRAIGHT_ALPHA_LOW * opacity + transparency
	topdownLowAlpha = RAIN_TOPDOWN_ALPHA_LOW * opacity + transparency

	local splashSequence = NumberSequence.new({
		NSK010,
		NumberSequenceKeypoint.new(
			RAIN_TRANSPARENCY_T1,
			opacity * RAIN_SPLASH_ALPHA_LOW + transparency,
			0
		),
		NumberSequenceKeypoint.new(
			RAIN_TRANSPARENCY_T2,
			opacity * RAIN_SPLASH_ALPHA_LOW + transparency,
			0
		),
		NSK110,
	})

	for _, v in splashAttachments do
		v.RainSplash.Transparency = splashSequence
	end
end

local transparencyProp = makeProperty("NumberValue", RAIN_DEFAULT_TRANSPARENCY, updateTransparency)
globalModifier.Changed:connect(updateTransparency)

local speedRatioProp = makeProperty("NumberValue", RAIN_DEFAULT_SPEEDRATIO, function(value)
	emitter.RainStraight.Speed = NumberRange.new(value * RAIN_STRAIGHT_MAX_SPEED)
	emitter.RainTopDown.Speed = NumberRange.new(value * RAIN_TOPDOWN_MAX_SPEED)
end)

local intensityRatioProp = makeProperty("NumberValue", RAIN_DEFAULT_INTENSITYRATIO, function(value)
	emitter.RainStraight.Rate = RAIN_STRAIGHT_MAX_RATE * value
	emitter.RainTopDown.Rate = RAIN_TOPDOWN_MAX_RATE * value

	intensityOccludedRain = math.ceil(RAIN_OCCLUDED_MAXINTENSITY * value)
	numSplashes = RAIN_SPLASH_NUM * value
end)

local lightEmissionProp = makeProperty("NumberValue", RAIN_DEFAULT_LIGHTEMISSION, function(value)
	emitter.RainStraight.LightEmission = value
	emitter.RainTopDown.LightEmission = value

	for _, v in rainAttachments do
		v.RainStraight.LightEmission = value
		v.RainTopDown.LightEmission = value
	end
	for _, v in splashAttachments do
		v.RainSplash.LightEmission = value
	end
end)

local lightInfluenceProp = makeProperty("NumberValue", RAIN_DEFAULT_LIGHTINFLUENCE, function(value)
	emitter.RainStraight.LightInfluence = value
	emitter.RainTopDown.LightInfluence = value

	for _, v in rainAttachments do
		v.RainStraight.LightInfluence = value
		v.RainTopDown.LightInfluence = value
	end
	for _, v in splashAttachments do
		v.RainSplash.LightInfluence = value
	end
end)

local rainDirectionProp = makeProperty("Vector3Value", RAIN_DEFAULT_DIRECTION, function(value)
	if value.Magnitude > 0.001 then
		rainDirection = value.Unit
	end
end)

local rain = {}
rain.CollisionMode = CollisionMode

--[=[ 
	Enables the rain.
]=]

function rain.enable(tweenInfo: TweenInfo?)
	if tweenInfo ~= nil and typeof(tweenInfo) ~= "TweenInfo" then
		error(
			"bad argument #1 to 'enable' (TweenInfo expected, got " .. typeof(tweenInfo) .. ")",
			2
		)
	end

	disconnectLoop() -- Just in case :Enable(..) is called multiple times on accident

	emitter.RainStraight.Enabled = true
	emitter.RainTopDown.Enabled = true
	emitter.Parent = Workspace.CurrentCamera

	for i = 1, RAIN_SPLASH_NUM do
		splashAttachments[i].Parent = Workspace.Terrain
		rainAttachments[i].Parent = Workspace.Terrain
	end

	if RunService:IsRunning() then -- don't need sound in studio preview, it won't work anyway
		soundGroup.Parent = game:GetService("SoundService")
	end

	connectLoop()

	if tweenInfo then
		TweenService:Create(globalModifier, tweenInfo, { Value = 0 }):Play()
	else
		globalModifier.Value = 0
	end

	if not rainSound.Playing then
		rainSound:Play()
		rainSound.TimePosition = math.random() * rainSound.TimeLength
	end

	disabled = false
	rain.enabled:set(not disabled)
end

--[=[ 
	Disables the rain.
]=]

function rain.disable(tweenInfo: TweenInfo?)
	if tweenInfo ~= nil and typeof(tweenInfo) ~= "TweenInfo" then
		error(
			"bad argument #1 to 'disable' (TweenInfo expected, got " .. typeof(tweenInfo) .. ")",
			2
		)
	end

	if tweenInfo then
		local tween = TweenService:Create(globalModifier, tweenInfo, { Value = 1 })
		tween.Completed:connect(function(state)
			if state == Enum.PlaybackState.Completed then
				-- Only disable the rain completely once the visual effects are faded out
				disable()
			end
			tween:Destroy()
		end)
		tween:Play()
		-- Start tweening out sound now as well
		disableSound(tweenInfo)
	else
		globalModifier.Value = 1
		disable()
	end

	disabled = true
	rain.enabled:set(not disabled)
end

--[=[ 
	Sets the rain color.
]=]

function rain.setColor(value: Color3, tweenInfo: TweenInfo?)
	if typeof(value) ~= "Color3" then
		error("bad argument #1 to 'SetColor' (Color3 expected, got " .. typeof(value) .. ")", 2)
	elseif tweenInfo ~= nil and typeof(tweenInfo) ~= "TweenInfo" then
		error(
			"bad argument #2 to 'SetColor' (TweenInfo expected, got " .. typeof(tweenInfo) .. ")",
			2
		)
	end

	if tweenInfo then
		TweenService:Create(colorProp, tweenInfo, { Value = value }):Play()
	else
		colorProp.Value = value
	end
end

--[=[ 
	Returns the current rain color value.
]=]

function rain.color()
	return colorProp.Value
end

--[=[ 
	Returns the current rain transparency value.
]=]

function rain.transparency()
	return transparencyProp.Value
end

--[=[ 
	Returns the current rain ceiling value.
]=]

function rain.ceiling()
	return currentCeiling
end

local function makeRatioSetter(methodName, valueObject)
	-- Shorthand because most of the remaining property setters are very similar
	return function(value, tweenInfo)
		if typeof(value) ~= "number" then
			error(
				"bad argument #1 to '"
					.. methodName
					.. "' (number expected, got "
					.. typeof(value)
					.. ")",
				2
			)
		elseif tweenInfo ~= nil and typeof(tweenInfo) ~= "TweenInfo" then
			error(
				"bad argument #2 to '"
					.. methodName
					.. "' (TweenInfo expected, got "
					.. typeof(tweenInfo)
					.. ")",
				2
			)
		end

		value = math.clamp(value, 0, 1)

		if tweenInfo then
			TweenService:Create(valueObject, tweenInfo, { Value = value }):Play()
		else
			valueObject.Value = value
		end
	end
end

--[=[ 
	@within rain
	@function setTransparency
	@param transparency number

	Sets the transparency of the rain.
]=]

rain.setTransparency = makeRatioSetter("setTransparency", transparencyProp)

--[=[ 
	@within rain
	@function setTransparency
	@param speedRatio number
	
	Sets the speed ratio of the rain.
]=]

rain.setSpeedRatio = makeRatioSetter("setSpeedRatio", speedRatioProp)

--[=[ 
	@within rain
	@function setTransparency
	@param intensityRatio number

	Sets the intensity ratio of the rain.
]=]

rain.setIntensityRatio = makeRatioSetter("setIntensityRatio", intensityRatioProp)

--[=[ 
	@within rain
	@function setTransparency
	@param lightEmission number

	Sets the light emission of the rain.
]=]

rain.setLightEmission = makeRatioSetter("setLightEmission", lightEmissionProp)

--[=[ 
	@within rain
	@function setTransparency
	@param lightInfluence number

	Sets the light influence of the rain.
]=]

rain.setLightInfluence = makeRatioSetter("setLightInfluence", lightInfluenceProp)

--[=[ 
	Sets the volume of the rain sound.
]=]

function rain.setVolume(volume: number, tweenInfo: TweenInfo?)
	if typeof(volume) ~= "number" then
		error("bad argument #1 to 'setVolume' (number expected, got " .. typeof(volume) .. ")", 2)
	elseif tweenInfo ~= nil and typeof(tweenInfo) ~= "TweenInfo" then
		error(
			"bad argument #2 to 'setVolume' (TweenInfo expected, got " .. typeof(tweenInfo) .. ")",
			2
		)
	end

	if tweenInfo then
		TweenService:Create(soundGroup, tweenInfo, { Volume = volume }):Play()
	else
		soundGroup.Volume = volume
	end
end

--[=[ 
	Sets the sound group of the rain sound by first cloning a copy of it, and then setting the cloned variant's sound
	group to `newSoundGroup`, and the old variant is destroyed.
]=]

function rain.setSoundGroup(newSoundGroup: SoundGroup)
	soundGroup = newSoundGroup
	rainSound:Destroy()
	rainSound = createRainSound(newSoundGroup)
end

--[=[ 
    Returns the direction of the rain.
]=]

function rain.direction(): Vector3
	return rainDirectionProp.Value
end

--[=[ 
    Sets the direction of the rain.
]=]

function rain.setDirection(direction: Vector3, tweenInfo: TweenInfo?)
	if typeof(direction) ~= "Vector3" then
		error(
			"bad argument #1 to 'setDirection' (Vector3 expected, got " .. typeof(direction) .. ")",
			2
		)
	elseif tweenInfo ~= nil and typeof(tweenInfo) ~= "TweenInfo" then
		error(
			"bad argument #2 to 'setDirection' (TweenInfo expected, got "
				.. typeof(tweenInfo)
				.. ")",
			2
		)
	end

	if not (direction.Unit.Magnitude > 0) then -- intentional statement formatting since NaN comparison
		warn(
			"Attempt to set rain direction to a zero-length vector, falling back on default direction = ("
				.. tostring(RAIN_DEFAULT_DIRECTION)
				.. ")"
		)
		direction = RAIN_DEFAULT_DIRECTION
	end

	if tweenInfo then
		TweenService:Create(rainDirectionProp, tweenInfo, { Value = direction }):Play()
	else
		rainDirectionProp.Value = direction
	end
end

--[=[ 
    Sets the ceiling of the rain.
]=]

function rain.setCeiling(ceiling: number)
	if ceiling ~= nil and typeof(ceiling) ~= "number" then
		error("bad argument #1 to 'setCeiling' (number expected, got " .. typeof(ceiling) .. ")", 2)
	end

	currentCeiling = ceiling
end

--[=[ 
    Sets the straight texture of the rain.
]=]

function rain.setStraightTexture(asset: string)
	if typeof(asset) ~= "string" then
		error(
			"bad argument #1 to 'setStraightTexture' (string expected, got " .. typeof(asset) .. ")",
			2
		)
	end

	emitter.RainStraight.Texture = asset

	for _, v in rainAttachments do
		v.RainStraight.Texture = asset
	end
end

--[=[ 
    Sets the top down texture of the rain.
]=]

function rain.setTopDownTexture(asset: string)
	if typeof(asset) ~= "string" then
		error(
			"bad argument #1 to 'setStraightTexture' (string expected, got " .. typeof(asset) .. ")",
			2
		)
	end

	emitter.RainTopDown.Texture = asset

	for _, v in rainAttachments do
		v.RainTopDown.Texture = asset
	end
end

--[=[ 
    Sets the splash texture of the rain.
]=]

function rain.setSplashTexture(asset: string)
	if typeof(asset) ~= "string" then
		error(
			"bad argument #1 to 'setStraightTexture' (string expected, got " .. typeof(asset) .. ")",
			2
		)
	end

	for _, v in splashAttachments do
		v.RainSplash.Texture = asset
	end
end

--[=[ 
    Sets the sound id of the rain sound.
]=]

function rain.setSoundId(asset: string)
	if typeof(asset) ~= "string" then
		error("bad argument #1 to 'setSoundId' (string expected, got " .. typeof(asset) .. ")", 2)
	end

	rainSound.SoundId = asset
end

--[=[ 
    Sets the rain config.
]=]

function rain.setConfig(config: {
	ceiling: number?,
	intensityRatio: number?,
	direction: Vector3?,
	splashTexture: string?,
	topDownTexture: string?,
	volume: number?,
	straightTexture: string?,
	soundId: string?,
	transparency: number?,
	lightEmission: string?,
	lightInfluence: string?,
	color: Color3?,
	speedRatio: number?,
	collisionMode: string,
	collisionModeFunction: CollisonModeFunction?,
})
	if config.ceiling then
		rain.setCeiling(config.ceiling)
	end

	if config.direction then
		rain.setDirection(config.direction)
	end

	if config.intensityRatio then
		rain.setIntensityRatio(config.intensityRatio)
	end

	if config.splashTexture then
		rain.setSplashTexture(config.splashTexture)
	end

	if config.topDownTexture then
		rain.setTopDownTexture(config.topDownTexture)
	end

	if config.straightTexture then
		rain.setStraightTexture(config.straightTexture)
	end

	if config.volume then
		rain.setVolume(config.volume)
	end

	if config.soundId then
		rain.setSoundId(config.soundId)
	end

	if config.transparency then
		rain.setTransparency(config.transparency)
	end

	if config.lightEmission then
		rain.setLightEmission(config.lightEmission)
	end

	if config.lightInfluence then
		rain.setLightInfluence(config.lightInfluence)
	end

	if config.color then
		rain.setColor(config.color)
	end

	if config.speedRatio then
		rain.setSpeedRatio(config.speedRatio)
	end

	if config.collisionMode then
		rain.setCollisionMode(config.collisionMode, config.collisionModeFunction)
	end
end

--[=[
	@interface CollisionMode
	@within rain 
	.callback 3?
	.blacklist 2?
	.whitelist 1
	.none 0

	- If `rain.CollisionMode.whitelist` is passed as the first argument to [rain.SetCollisionMode], you can pass in a base part or an array of base parts
	to be hit by the rain **only**.

	- If `rain.CollisionMode.blacklist` is passed as the first argument to [rain.SetCollisionMode], you can pass in a base part or an array of base parts
	to NOT be hit by the rain.

	- If `rain.CollisionMode.callback` is passed as the first argument to [rain.SetCollisionMode], you can pass in a predicate [`CollisionModeFunction`]
	that can return a boolean value.
]=]

--[=[ 
	@param mode CollisionMode

	Sets the rain collision mode. 

	```lua
	-- Example uses:

	-- 1)
	rain.setCollisionMode(rain.CollisionMode.callback, function(basePart)
		return not basePart.CanCollide
	end)

	-- 2)
	rain.setCollisionMode(rain.CollisionMode.whitelist, {Workspace.Baseplate})

	-- 3)
	rain.setCollisionMode(rain.CollisionMode.blacklist, {Workspace.Baseplate})
	```
]=]

function rain.setCollisionMode(mode: string, param: { Instance } | Instance | CollisonModeFunction)
	if mode == CollisionMode.none then
		-- Regular mode needs no white/blacklist or test function
		collisionList = nil
		collisionFunc = nil
	elseif mode == CollisionMode.blacklist then
		if typeof(param) == "Instance" then
			-- Add emitter anyway, since users will probably not expect collisions with emitter block regardless
			collisionList = { param, emitter }
		elseif typeof(param) == "table" then
			for i = 1, #param do
				if typeof(param[i]) ~= "Instance" then
					error(
						"bad argument #2 to 'setCollisionMode' (blacklist contained a "
							.. typeof(param[i])
							.. " on index "
							.. tostring(i)
							.. " which is not an Instance)",
						2
					)
				end
			end
			collisionList = { emitter } -- see above
			for i = 1, #param do
				table.insert(collisionList, param[i])
			end
		else
			error(
				"bad argument #2 to 'setCollisionMode (Instance or array of Instance expected, got "
					.. typeof(param)
					.. ")'",
				2
			)
		end

		-- blacklist does not need a test function
		collisionFunc = nil
	elseif mode == CollisionMode.whitelist then
		if typeof(param) == "Instance" then
			collisionList = { param }
		elseif typeof(param) == "table" then
			for i = 1, #param do
				if typeof(param[i]) ~= "Instance" then
					error(
						"bad argument #2 to 'setCollisionMode' (whitelist contained a "
							.. typeof(param[i])
							.. " on index "
							.. tostring(i)
							.. " which is not an Instance)",
						2
					)
				end
			end
			collisionList = {}
			for i = 1, #param do
				table.insert(collisionList, param[i])
			end
		else
			error(
				"bad argument #2 to 'setCollisionMode (Instance or array of Instance expected, got "
					.. typeof(param)
					.. ")'",
				2
			)
		end

		-- whitelist does not need a test function
		collisionFunc = nil
	elseif mode == CollisionMode.callback then
		if typeof(param) ~= "function" then
			error(
				"bad argument #2 to 'setCollisionMode' (function expected, got "
					.. typeof(param)
					.. ")",
				2
			)
		end

		-- Test function does not need a list
		collisionList = nil

		collisionFunc = param
	else
		error(
			"bad argument #1 to 'setCollisionMode (rain.CollisionMode expected, got "
				.. typeof(param)
				.. ")'",
			2
		)
	end

	collisionMode = mode
	raycast = raycastFunctions[mode]
end

--[=[ 
	@prop enabled Property
	@within rain

	A [Property](https://bub.github.io/libraries/api/Property/) object that contains a value on whether the rain is enabled or not.
]=]

rain.enabled = Property.new(not disabled)

return table.freeze(rain)
