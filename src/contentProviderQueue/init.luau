--[=[ 
	@class ContentProviderQueue

	A simple class for working with [ContentProvider](https://create.roblox.com/docs/reference/engine/classes/ContentProvider).
	
	```lua
	local contentProviderQueue = ContentProviderQueue.new()
	contentProviderQueue:addInstances({sound1, sound2, sound3})
	print(#contentProviderQueue:pendingInstances()) --> 3
	contentProviderQueue:fullyProgressed():await() -- ensure all pending instances are preloaded
	print(#contentProviderQueue:pendingInstances()) --> 0
	```
]=]

--[=[ 
	@prop onProgressed Signal <instance: Instance, contentProviderId: string, deltaTime: number, status: Enum.AssetFetchStatus>
	@within ContentProviderQueue
	@tag Read only
	@tag Signal
	@tag ContentProviderQueue Instance

	A [signal](https://sleitnick.github.io/RbxUtil/api/Signal/) which is fired whenever an instance in the content provider
	queue object has being 'processed' by preloading. 

	`deltaTime` is the amount of time the instance took to be 'processsed' for preload.
]=]

--[=[ 
	@prop onProgressing Signal <instance: Instance>
	@within ContentProviderQueue
	@tag Read only
	@tag Signal
	@tag ContentProviderQueue Instance

	A [signal](https://sleitnick.github.io/RbxUtil/api/Signal/) which is fired whenever an instance in the content provider
	queue object is being preloaded.
]=]

--[=[ 
	@prop onAdded Signal <instance: Instance>
	@within ContentProviderQueue
	@tag Read only
	@tag Signal
	@tag ContentProviderQueue Instance

	A [signal](https://sleitnick.github.io/RbxUtil/api/Signal/) which is fired whenever an instance is added to the content provider queue object.
]=]

--[=[ 
	@prop onRemoved Signal <instance: Instance>
	@within ContentProviderQueue
	@tag Read only
	@tag Signal
	@tag ContentProviderQueue Instance

	A [signal](https://sleitnick.github.io/RbxUtil/api/Signal/) which is fired whenever an instance is removed from the content provider queue object.
]=]

--[=[ 
	@type ContentProviderQueue ContentProviderQueue 
	@within ContentProviderQueue
]=]

local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")

local Promise = require(script.Parent.Promise)
local Janitor = require(script.Parent.Janitor)
local Signal = require(script.Parent.Signal)
local throttleUtil = require(script.Parent.throttleUtil)

local ContentProviderQueue = {}
ContentProviderQueue.__index = {}

local DEFAULT_UPDATE_INTERVAL = 0.05
local MAX_CONTENT_PROVIDER_QUEUE_PROGRESS_PERCENT = 1

local contentProviderQueues = {} :: { ContentProviderQueue }

--[=[
	Creates a new content preloader queue object. An `initialUpdateInterval` argument can be passed
	as the initial update interval of the queue.
]=]

function ContentProviderQueue.new(initialUpdateInterval: number?): ContentProviderQueue
	local janitor = Janitor.new()
	local self = setmetatable({
		onProgressed = janitor:Add(Signal.new()),
		onProgressing = janitor:Add(Signal.new()),
		onAdded = janitor:Add(Signal.new()),
		onRemoved = janitor:Add(Signal.new()),
		_janitor = janitor,
		_instances = {},
		_instancesPreloading = {},
		_instancesSuccessfullyPreloadedCount = 0,
		_instancesToPreload = 0,
		_updateInterval = initialUpdateInterval or DEFAULT_UPDATE_INTERVAL,
		_paused = false,
	}, ContentProviderQueue)

	self:_init()
	return self
end

--[=[
	Sets the update interval of the queue, i.e the interval at which the queue will preload
	each asset.
]=]

function ContentProviderQueue.__index:setUpdateInterval(updateInterval: number)
	self._updateInterval = updateInterval
end

--[=[
	Adds the given instance to the content provider queue. If the given instance
	already exists, then the instance **will not** be readded again.
]=]

function ContentProviderQueue.__index:add(instance: Instance)
	if table.find(self._instances, instance) then
		return
	end

	table.insert(self._instances, instance)
	self._instancesToPreload += 1
	self.onAdded:Fire(instance)
end

--[=[
	Adds all instances in `instances` to the content provider queue, via [ContentProviderQueue:add].
]=]

function ContentProviderQueue.__index:addInstances(instances: { Instance })
	for _, instance in instances do
		self:add(instance)
	end
end

--[=[
	Removes the instance from the given queue, if the instance was being preloaded, then it
	will be disregarded by the content provider queue.
	
	```lua
	local contentProviderQueue = ...
	contentProviderQueue:add(sound1)
	print(#contentProviderQueue:pendingInstances()) --> 1
	contentProviderQueue:remove(sound1)
	print(pendingInstancescontentProviderQueue:pendingInstances()) --> 0
	```
]=]

function ContentProviderQueue.__index:remove(instance: Instance)
	local index = table.find(self._instances, instance)

	if index then
		self._instancesToPreload -= 1
		table.remove(self._instances, index)
	end

	table.remove(self._instancesPreloading, table.find(self._instancesPreloading, instance))
	self.onRemoved:Fire(instance)
end

--[=[
	Returns a number from `0` to `1` indicating the progress of the content provider queue.
]=]

function ContentProviderQueue.__index:progress(): number
	if self._instancesToPreload == 0 then
		return MAX_CONTENT_PROVIDER_QUEUE_PROGRESS_PERCENT
	end
	
	return math.clamp(
		self._instancesSuccessfullyPreloadedCount / math.max(self._instancesToPreload, 1),
		0,
		MAX_CONTENT_PROVIDER_QUEUE_PROGRESS_PERCENT
	)
end

--[=[
	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved once the content provider queue
	has fully progressed, i.e there are no more instances to preload.

	@return Promise<>
]=]

function ContentProviderQueue.__index:fullyProgressed()
	return Promise.new(function(resolve)
		while self:progress() < MAX_CONTENT_PROVIDER_QUEUE_PROGRESS_PERCENT do
			self.onProgressed:Wait()
		end

		task.defer(resolve)
	end)
end

--[=[
	Returns a boolean indicating if the content provider queue object is paused or not.
]=]

function ContentProviderQueue.__index:paused(): boolean
	return self._paused
end

--[=[
	Resumes the content provider queue.
]=]

function ContentProviderQueue.__index:resume()
	self._paused = false
end

--[=[
	Pauses the content provider queue object. If any more instances are to be preloaded, they won't be
	until the content provider object is resumed back. 
]=]

function ContentProviderQueue.__index:pause()
	self._paused = true
end

--[=[
	Clears all instances to be preloaded from the content provider queue object, via [ContentProviderQueue:remove].
]=]

function ContentProviderQueue.__index:empty()
	for _, instance in self._instances do
		self:remove(instance)
	end
end

--[=[
	Returns a read only array of all instances, left to be preloaded in the content provider queue object.
]=]

function ContentProviderQueue.__index:pendingInstances(): { Instance }
	return table.freeze(table.clone(self._instances))
end

--[=[
	Destroys the content provider queue object, and also empties it through [ContentProviderQueue:empty].
]=]

function ContentProviderQueue.__index:destroy()
	self._janitor:Destroy()
end

--[=[
	Destroys the content provider queue object, empties it through [ContentProviderQueue:empty] and renders
	it unusable.
	
	@private
]=]

function ContentProviderQueue.__index:_init()
	table.insert(contentProviderQueues, self)

	self._janitor:Add(function()
		table.remove(contentProviderQueues, table.find(contentProviderQueues, self))
		self:empty()
		setmetatable(self, nil)
	end)
end

RunService.Heartbeat:Connect(function(deltaTime)
	for _, contentProviderQueue in contentProviderQueues do
		if contentProviderQueue._paused then
			continue
		end

		if #contentProviderQueue._instances == 0 then
			continue
		end

		for _, instance in table.clone(contentProviderQueue._instances) do
			if
				not throttleUtil.throttle(contentProviderQueue._updateInterval, deltaTime, instance)
			then
				continue
			end

			if table.find(contentProviderQueue._instancesPreloading, instance) then
				continue
			end

			local instancePreloadPromise =
				contentProviderQueue._janitor:AddPromise(Promise.defer(function(resolve)
					contentProviderQueue.onProgressing:Fire(instance)
					local clockBefore = os.clock()

					ContentProvider:PreloadAsync({ instance }, function(contentProviderId, status)
						-- Ensure we don't run further code if the content provider queue
						-- was destroyed during preloading of assets, to avoid errors!
						if not table.find(contentProviderQueues, contentProviderQueue) then
							return
						end

						if not table.find(contentProviderQueue._instances, instance) then
							-- Instance was removed from the queue, even though it has
							-- been processed for preload..
							return
						end

						table.remove(
							contentProviderQueue._instances,
							table.find(contentProviderQueue._instances, instance)
						)
						table.remove(
							contentProviderQueue._instancesPreloading,
							table.find(contentProviderQueue._instancesPreloading, instance)
						)

						contentProviderQueue._instancesSuccessfullyPreloadedCount += 1
						contentProviderQueue.onProgressed:Fire(
							instance,
							contentProviderId,
							os.clock() - clockBefore,
							status
						)
						resolve()
					end)
				end))

			table.insert(contentProviderQueue._instancesPreloading, instance)

			instancePreloadPromise:finally(function(status)
				if status == Promise.Status.Cancelled then
					return
				end

				contentProviderQueue:remove(instance)
			end)
		end
	end
end)

export type ContentProviderQueue = typeof(ContentProviderQueue.new())

return table.freeze(ContentProviderQueue)
