-- Component
-- Stephen Leitnick
-- Modifications by babypatrick100
-- November 26, 2021

type AncestorList = { Instance }

--[=[
	@type ExtensionFn (component) -> ()
	@within Component
]=]
type ExtensionFn = (any) -> ()

--[=[
	@type ExtensionShouldFn (component) -> boolean
	@within Component
]=]
type ExtensionShouldFn = (any) -> boolean

--[=[
	@interface Extension
	@within Component
	.shouldExtend ExtensionShouldFn?
	.shouldConstruct ExtensionShouldFn?
	.constructing ExtensionFn?
	.constructed ExtensionFn?
	.starting ExtensionFn?
	.started ExtensionFn?
	.stopping ExtensionFn?
	.stopped ExtensionFn?

	An extension allows the ability to extend the behavior of
	components. This is useful for adding injection systems or
	extending the behavior of components by wrapping around
	component lifecycle methods.

	The `shouldConstruct` function can be used to indicate
	if the component should actually be created. This must
	return `true` or `false`. A component with multiple
	`shouldConstruct` extension functions must have them _all_
	return `true` in order for the component to be constructed.
	The `shouldConstruct` function runs _before_ all other
	extension functions and component lifecycle methods.

	The `shouldExtend` function can be used to indicate if
	the extension itself should be used. This can be used in
	order to toggle an extension on/off depending on whatever
	logic is appropriate. If no `shouldExtend` function is
	provided, the extension will always be used if provided
	as an extension to the component.

	As an example, an extension could be created to simply log
	when the various lifecycle stages run on the component:

	```lua
	local Logger = {}
	function Logger.constructing(component, componentClass) print("constructing", component) end
	function Logger.constructed(component, componentClass) print("constructed", component) end
	function Logger.starting(component, componentClass) print("starting", component) end
	function Logger.started(component, componentClass) print("started", component) end
	function Logger.stopping(component, componentClass) print("stopping", component) end
	function Logger.stopped(component, componentClass) print("stopped", component) end

	local MyComponent = Component.new({tag = "MyComponent", extensions = {Logger}})
	```

	Sometimes it is useful for an extension to control whether or
	not a component should be constructed. For instance, if a
	component on the client should only be instantiated for the
	local player, an extension might look like this, assuming the
	instance has an attribute linking it to the player's UserId:
	```lua
	local player = game:GetService("Players").LocalPlayer

	local OnlyLocalPlayer = {}
	function OnlyLocalPlayer.shouldConstruct(component)
		local ownerId = component.instance:GetAttribute("OwnerId")
		return ownerId == player.UserId
	end

	local MyComponent = Component.new({tag = "MyComponent", extensions = {OnlyLocalPlayer}})
	```

	It can also be useful for an extension itself to turn on/off
	depending on various contexts. For example, let's take the
	Logger from the first example, and only use that extension
	if the bound instance has a Log attribute set to `true`:
	```lua
	function Logger.shouldExtend(component)
		return component.instance:GetAttribute("Log") == true
	end
	```
]=]
type Extension = {
	shouldExtend: ExtensionShouldFn?,
	shouldConstruct: ExtensionShouldFn?,
	constructing: ExtensionFn?,
	constructed: ExtensionFn?,
	starting: ExtensionFn?,
	started: ExtensionFn?,
	stopping: ExtensionFn?,
	stopped: ExtensionFn?,
}

--[=[
	@interface ComponentConfig
	@within Component
	.tag string -- CollectionService tag to use
	.ancestors {Instance}? -- Optional array of ancestors in which components will be started
	.extensions {Extension}? -- Optional array of extension objects

	Component configuration passed to `Component.new`.

	- If no ancestors option is included, it defaults to `{workspace, game.Players}`.
	- If no extensions option is included, it defaults to a blank table `{}`.
]=]
type ComponentConfig = {
	tag: string,
	ancestors: AncestorList?,
	extensions: { Extension }?,
	[any]: any,
}

--[=[
	@within Component
	@prop started Signal
	@tag Event
	@tag Component Class

	Fired when a new instance of a component is started.

	```lua
	local MyComponent = Component.new({tag = "MyComponent"})

	MyComponent.started:Connect(function(component) end)
	```
]=]

--[=[
	@within Component
	@prop stopped Signal
	@tag Event
	@tag Component Class

	Fired when an instance of a component is stopped.

	```lua
	local MyComponent = Component.new({tag = "MyComponent"})

	MyComponent.stopped:Connect(function(component) end)
	```
]=]

--[=[
	@tag Component Instance
	@within Component
	@prop instance Instance
	
	A reference back to the _Roblox_ instance from within a _component_ instance. When
	a component instance is created, it is bound to a specific Roblox instance, which
	will always be present through the `Instance` property.

	```lua
	MyComponent.started:Connect(function(component)
		local robloxInstance: Instance = component.instance
		print("Component is bound to " .. robloxInstance:GetFullName())
	end)
	```
]=]

local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local Signal = require(script.Parent.Signal)
local Symbol = require(script.Parent.Symbol)
local Trove = require(script.Parent.Trove)
local Promise = require(script.Parent.Promise)

local IS_SERVER = RunService:IsServer()
local DEFAULT_ANCESTORS = { Workspace, Players, Lighting }
local DEFAULT_TIMEOUT = 60
local COMPONENT_LIFECYLE_METHOD_DEBUG = "%s [%s]"
local COMPONENT_MEM_TAG = "%s (%s)"
local RUN_SERVICE_EVENTS_TO_CONNECT = {
	steppedUpdate = RunService.Stepped,
	heartbeatUpdate = RunService.Heartbeat,
	renderSteppedUpdate = if RunService:IsClient() then RunService.RenderStepped else nil,
}
local COMPONENTS_BOUND_TO_SAME_INSTANCE_CONSTRUCT_EXPECTED_INTERVAl = 10

-- Symbol keys:
local KEY_ANCESTORS = Symbol("ancestors")
local KEY_INST_TO_COMPONENTS = Symbol("InstancesToComponents")
local KEY_LOCK_CONSTRUCT = Symbol("LockConstruct")
local KEY_COMPONENTS = Symbol("Components")
local KEY_TROVE = Symbol("Trove")
local KEY_EXTENSIONS = Symbol("extensions")
local KEY_ACTIVE_EXTENSIONS = Symbol("ActiveExtensions")
local KEY_STARTED = Symbol("started")
local START_PROMISE = Symbol("START_PROMISE")
local CONSTRUCT_PROMISE = Symbol("CONSTRUCT_PROMISE")

local componentsConstructingPromises = {}
local globalComponents = {}
local onGlobalComponentStarted = Signal.new()

local function NextRenderName(): string
	return "ComponentRender" .. HttpService:GenerateGUID()
end

local function InvokeExtensionFn(component, componentClass, fnName: string)
	for _, extension in component[KEY_ACTIVE_EXTENSIONS] do
		local fn = extension[fnName]
		if type(fn) == "function" then
			fn(component, componentClass)
		end
	end
end

local function shouldConstruct(component): boolean
	for _, extension in component[KEY_ACTIVE_EXTENSIONS] do
		local fn = extension.shouldConstruct
		if type(fn) == "function" then
			local shouldConstructComponent = fn(component)
			if not shouldConstructComponent then
				return false
			end
		end
	end

	return true
end

local function GetActiveExtensions(component, extensionList)
	local activeExtensions = table.create(#extensionList)
	local allActive = true
	for _, extension in extensionList do
		local fn = extension.shouldExtend
		local shouldExtend = type(fn) ~= "function" or not not fn(component)
		if shouldExtend then
			table.insert(activeExtensions, extension)
		else
			allActive = false
		end
	end
	return if allActive then extensionList else activeExtensions
end

--[=[
	@class Component

	Bind components to Roblox instances using the Component class and CollectionService tags.

	:::note
	The Component class is made by `sleitnick`, this is just a modified variant of it which includes
	case changes (from PascalCase to camelCase), bug & edgecase fixes and performance improvements.
	:::

	To avoid confusion of terms:
	- `Component` refers to this module.
	- `Component Class` (e.g. `MyComponent` through this documentation) refers to a class created via `Component.new`
	- `Component Instance` refers to an instance of a component class.
	- `Roblox Instance` refers to the Roblox instance to which the component instance is bound.

	Methods and properties are tagged with the above terms to help clarify the level at which they are used.
]=]

local Component = {}
Component.__index = Component

--[=[
	@tag Component
	@param config ComponentConfig
	@return ComponentClass

	Create a new custom Component class.

	```lua
	local MyComponent = Component.new({tag = "MyComponent"})
	```

	A full example might look like this:

	```lua
	local MyComponent = Component.new({
		tag = "MyComponent",
		ancestors = {workspace},
		extensions = {Logger}, -- See Logger example within the example for the Extension type
	})

	local AnotherComponent = require(somewhere.AnotherComponent)

	-- Optional if UpdateRenderStepped should use BindToRenderStep:
	MyComponent.renderPriority = Enum.renderPriority.Camera.Value

	function MyComponent:construct()
		self.MyData = "Hello"
	end

	function MyComponent:start()
		local another = self:component(AnotherComponent)
		another:DoSomething()
	end

	function MyComponent:stop()
		self.MyData = "Goodbye"
	end

	function MyComponent:heartbeatUpdate(dt)
	end

	function MyComponent:steppedUpdate(time, dt)
	end
	
	function MyComponent:renderSteppedUpdate(dt)
	end
	```
]=]
function Component.new(config: ComponentConfig)
	local customComponent = table.clone(config)
	customComponent.__index = customComponent
	customComponent.__tostring = function()
		return "Component<" .. config.tag .. ">"
	end
	customComponent[KEY_ANCESTORS] = config.ancestors or DEFAULT_ANCESTORS
	customComponent[KEY_INST_TO_COMPONENTS] = {}
	customComponent[KEY_COMPONENTS] = {}
	customComponent[KEY_LOCK_CONSTRUCT] = {}
	customComponent[KEY_TROVE] = Trove.new()
	customComponent[KEY_EXTENSIONS] = config.extensions or {}
	customComponent[KEY_STARTED] = false
	customComponent.started = customComponent[KEY_TROVE]:Construct(Signal)
	customComponent.stopped = customComponent[KEY_TROVE]:Construct(Signal)
	setmetatable(customComponent, Component)
	customComponent:_setup()
	return customComponent
end

--[=[
	@tag Component
	@return ComponentClass?

	Returns the component instance of the component class bound to the given tag, if found.
]=]

function Component.fromTag(tag: string, instance: Instance)
	for _, component in globalComponents do
		if component.tag ~= tag then
			continue
		end

		local componentInstance = component:fromInstance(instance)
		if componentInstance ~= nil and componentInstance.instance == instance then
			return componentInstance
		end
	end

	return nil
end

--[=[
	@tag Component
	@return Promise

	Promisified version of [Component.fromTag].
]=]

function Component.fromTagPromise(tag: string, instance: Instance)
	return Promise.new(function(resolve)
		while Component.fromTag(tag, instance) == nil do
			onGlobalComponentStarted:Wait()
		end

		resolve(Component.fromTag(tag, instance))
	end)
end

function Component:_instantiate(instance: Instance)
	local component = setmetatable({}, self)
	component.instance = instance
	component[KEY_ACTIVE_EXTENSIONS] = GetActiveExtensions(component, self[KEY_EXTENSIONS])
	if not shouldConstruct(component) then
		return nil
	end
	InvokeExtensionFn(component, self, "constructing")
	if type(component.construct) == "function" then
		self[CONSTRUCT_PROMISE] = Promise.new(function(resolve)
			resolve(component:construct())
		end)
	end

	componentsConstructingPromises[component.instance] = componentsConstructingPromises[component.instance]
		or {}
	componentsConstructingPromises[component.instance][component] = component

	component[CONSTRUCT_PROMISE]:finally(function()
		componentsConstructingPromises[component.instance][component] = nil
		if next(componentsConstructingPromises[component.instance]) == nil then
			componentsConstructingPromises[component.instance] = nil
		end
	end)

	self[CONSTRUCT_PROMISE]:expect()
	InvokeExtensionFn(component, self, "constructed")
	return component
end

function Component:_setup()
	local watchingInstances = {}

	local function StartComponent(component)
		while componentsConstructingPromises[component.instance] ~= nil do
			local _, thisComponent = next(componentsConstructingPromises[component.instance])

			local componentStartupWaitThread = task.delay(
				COMPONENTS_BOUND_TO_SAME_INSTANCE_CONSTRUCT_EXPECTED_INTERVAl,
				function()
					warn(
						string.format(
							"%s [%s] waiting for component %s [%s] to construct. [%.2fs~ elapsed]",
							tostring(component),
							component.instance:GetFullName(),
							tostring(thisComponent),
							thisComponent.instance:GetFullName(),
							COMPONENTS_BOUND_TO_SAME_INSTANCE_CONSTRUCT_EXPECTED_INTERVAl
						)
					)
				end
			)

			thisComponent[CONSTRUCT_PROMISE]:await()
			task.cancel(componentStartupWaitThread)
		end

		-- The component was already destroyed by the time we have finished waiting
		-- for other components bound to the same instance to construct.
		if self[KEY_INST_TO_COMPONENTS][component.instance] == nil then
			return
		end

		debug.setmemorycategory(
			string.format(COMPONENT_MEM_TAG, tostring(component), component.instance.Name)
		)
		InvokeExtensionFn(component, self, "starting")

		component[START_PROMISE] = Promise.new(function(resolve)
			resolve(component:start())
		end)
			:andThen(function()
				table.insert(globalComponents, component)
				onGlobalComponentStarted:Fire(component)
				InvokeExtensionFn(component, self, "started")

				local hasRenderSteppedUpdate = typeof(component.renderSteppedUpdate) == "function"
				if hasRenderSteppedUpdate and not IS_SERVER then
					if component.renderPriority then
						component._renderName = NextRenderName()
						RunService:BindToRenderStep(
							component._renderName,
							component.renderPriority,
							function(...)
								debug.profilebegin(
									string.format(
										COMPONENT_LIFECYLE_METHOD_DEBUG,
										tostring(component),
										"renderSteppedUpdate"
									)
								)
								component:renderSteppedUpdate(...)
								debug.profileend()
							end
						)
					end
				end

				component[KEY_STARTED] = true
				self.started:Fire(component)
			end)
			:catch(function(errorMessage)
				warn(tostring(errorMessage))
			end)
	end

	local function StopComponent(component)
		local index = table.find(globalComponents, component)
		if index ~= nil then
			table.remove(globalComponents, index)
		end

		if component._renderName ~= nil then
			RunService:UnbindFromRenderStep(component._renderName)
		end

		component[START_PROMISE]:cancel()
		component[CONSTRUCT_PROMISE]:cancel()

		InvokeExtensionFn(component, self, "stopping")
		component:stop()
		InvokeExtensionFn(component, self, "stopped")
		self.stopped:Fire(component)
	end

	local function SafeConstruct(instance, id)
		if self[KEY_LOCK_CONSTRUCT][instance] ~= id then
			return nil
		end
		local component = self:_instantiate(instance)
		if self[KEY_LOCK_CONSTRUCT][instance] ~= id then
			return nil
		end
		return component
	end

	local function TryConstructComponent(instance)
		if self[KEY_INST_TO_COMPONENTS][instance] then
			return
		end

		local id = self[KEY_LOCK_CONSTRUCT][instance] or 0
		id += 1
		self[KEY_LOCK_CONSTRUCT][instance] = id

		local component = SafeConstruct(instance, id)
		if not component then
			return
		end

		self[KEY_INST_TO_COMPONENTS][instance] = component
		table.insert(self[KEY_COMPONENTS], component)

		-- EDGECASE: Incase in the construction phase of the component, more components
		-- bound to the same instance arise, so we need to start the component in the next
		-- invocation point available using `task.defer` to safely handle this - since
		-- `StartComponent` will wait for other pending component constructions (bound to the
		-- same instance) to finish before actually starting the component!
		task.defer(function()
			if self[KEY_INST_TO_COMPONENTS][instance] ~= component then
				return
			end

			StartComponent(component)
		end)
	end

	local function TryDeconstructComponent(instance)
		local component = self[KEY_INST_TO_COMPONENTS][instance]
		if not component then
			return
		end
		self[KEY_INST_TO_COMPONENTS][instance] = nil
		self[KEY_LOCK_CONSTRUCT][instance] = nil
		local components = self[KEY_COMPONENTS]
		local index = table.find(components, component)
		if index then
			local n = #components
			components[index] = components[n]
			components[n] = nil
		end
		if component[KEY_STARTED] then
			task.spawn(StopComponent, component)
		end
	end

	local function StartWatchingInstance(instance)
		if watchingInstances[instance] then
			return
		end
		local function IsInAncestorList(): boolean
			for _, parent in self[KEY_ANCESTORS] do
				if instance:IsDescendantOf(parent) or instance == parent then
					return true
				end
			end
			return false
		end
		local ancestryChangedHandle = self[KEY_TROVE]:Connect(
			instance.AncestryChanged,
			function(_, parent)
				if parent and IsInAncestorList() then
					TryConstructComponent(instance)
				else
					TryDeconstructComponent(instance)
				end
			end
		)
		watchingInstances[instance] = ancestryChangedHandle
		if IsInAncestorList() then
			TryConstructComponent(instance)
		end
	end

	local function InstanceTagged(instance: Instance)
		StartWatchingInstance(instance)
	end

	local function InstanceUntagged(instance: Instance)
		local watchHandle = watchingInstances[instance]
		watchingInstances[instance] = nil

		if watchHandle then
			self[KEY_TROVE]:Remove(watchHandle)
			watchHandle:Disconnect()
		end

		TryDeconstructComponent(instance)
	end

	self[KEY_TROVE]:Connect(CollectionService:GetInstanceAddedSignal(self.tag), InstanceTagged)
	self[KEY_TROVE]:Connect(CollectionService:GetInstanceRemovedSignal(self.tag), InstanceUntagged)

	local tagged = CollectionService:GetTagged(self.tag)
	for _, instance in tagged do
		task.defer(InstanceTagged, instance)
	end
end

--[=[
	@tag Component Class
	@return {Component}

	Gets a copy table array of all existing component objects. For example,
	if there was a component class linked to the "MyComponent" tag,
	and three Roblox instances in your game had that same tag, then
	calling `all` would return the three component instances.

	```lua
	local MyComponent = Component.new({tag = "MyComponent"})

	-- ...

	local components = MyComponent:all()
	for _,component in components do
		component:DoSomethingHere()
	end
	```
]=]
function Component:all()
	return table.clone(self[KEY_COMPONENTS])
end

--[=[
	@tag Component Class
	@return Component?

	Gets an instance of a component class from the given Roblox
	instance. Returns `nil` if not found.

	```lua
	local MyComponent = require(somewhere.MyComponent)

	local myComponentInstance = MyComponent:fromInstance(workspace.SomeInstance)
	```
]=]
function Component:fromInstance(instance: Instance)
	return self[KEY_INST_TO_COMPONENTS][instance]
end

--[=[
	@tag Component Class
	@return Promise<ComponentInstance>

	Resolves a promise once the component instance is present on a given
	Roblox instance.

	An optional `timeout` can be provided to reject the promi	se if it
	takes more than `timeout` seconds to resolve. If no timeout is
	supplied, `timeout` defaults to 60 seconds.

	```lua
	local MyComponent = require(somewhere.MyComponent)

	MyComponent:waitForInstance(workspace.SomeInstance):andThen(function(myComponentInstance)
		-- Do something with the component class
	end)
	```
]=]
function Component:waitForInstance(instance: Instance, timeout: number?)
	local componentInstance = self:fromInstance(instance)
	if componentInstance then
		return Promise.resolve(componentInstance)
	end
	return Promise.fromEvent(self.started, function(c)
		local match = c.instance == instance
		if match then
			componentInstance = c
		end
		return match
	end)
		:andThen(function()
			return componentInstance
		end)
		:timeout(if type(timeout) == "number" then timeout else DEFAULT_TIMEOUT)
end

--[=[
	@tag Component Class
	`construct` is called before the component is started, and should be used
	to construct the component instance.

	:::warning 
	You should handle any potential data loading (or any code that needs to yield) in the
	`construct` method, as the component **will not be started** unless all other components
	bound to the same instance have been constructed. This addresses [Issue 127](https://github.com/Sleitnick/RbxUtil/issues/127).

	A warn will be outputted in the console after about `10` seconds if there are still other pending components not
	yet fully constructed, while this component is awaiting to be started. You should ensure all your components construct
	within reasonable amount of time!
	:::

	:::note Cancellation
	If this method has not yet finished when the component instance is stopped, then it will be forcefully
	stopped.
	:::

	```lua
	local MyComponent = Component.new({tag = "MyComponent"})

	function MyComponent:construct()
		self.SomeData = 32
		self.OtherStuff = "HelloWorld"
	end
	```
]=]
function Component:construct() end

--[=[
	@tag Component Class
	`start` is called when the component is started, **and all other component instances of the instance bound to the component are ready**. At this point in time, it
	is safe to grab other components also bound to the same instance.

	:::note Cancellation
	If this method has not yet finished when the component instance is stopped, then it will be forcefully
	stopped.
	:::

	```lua
	local MyComponent = Component.new({tag = "MyComponent"})
	local AnotherComponent = require(somewhere.AnotherComponent)

	function MyComponent:start()
		-- e.g., grab another component:
		local another = self:component(AnotherComponent)
	end
	```
]=]
function Component:start() end

--[=[
	@tag Component Class
	`stop` is called when the component is stopped. This occurs either when the
	bound instance is removed from one of the whitelisted ancestors _or_ when
	the matching tag is removed from the instance. This also means that the
	instance _might_ be destroyed, and thus it is not safe to continue using
	the bound instance (e.g. `self.instance`) any longer.

	This should be used to clean up the component.

	```lua
	local MyComponent = Component.new({tag = "MyComponent"})

	function MyComponent:stop()
		self.SomeStuff:destroy()
	end
	```
]=]
function Component:stop() end

--[=[
	@tag Component Instance
	@param componentClass ComponentClass
	@return Component?

	Retrieves another component instance bound to the same
	Roblox instance.

	```lua
	local MyComponent = Component.new({tag = "MyComponent"})
	local AnotherComponent = require(somewhere.AnotherComponent)

	function MyComponent:start()
		local another = self:component(AnotherComponent)
	end
	```
]=]
function Component:component(componentClass)
	return componentClass[KEY_INST_TO_COMPONENTS][self.instance]
end

--[=[
	@tag Component Class
	@function heartbeatUpdate
	@param dt number
	@within Component

	If this method is present on a component, then it will be
	automatically connected to `RunService.Heartbeat`.

	:::tip 
	`Component` will only ever hook up 1 heartbeat connection for **every single component instance**. As of writing,
	in sleitnick's variant, a heartbeat connection is hooked up for **each component instance**, which is not scalable for large
	scale operations.
	:::

	:::note Method
	This is a method, not a function. This is a limitation
	of the documentation tool which should be fixed soon.
	:::
	
	```lua
	local MyComponent = Component.new({tag = "MyComponent"})
	
	function MyComponent:heartbeatUpdate(dt)
	end
	```
]=]
--[=[
	@tag Component Class
	@function steppedUpdate
	@param time number
	@param dt number
	@within Component

	If this method is present on a component, then it will be
	automatically connected to `RunService.Stepped`.

	:::tip 
	`Component` will only ever hook up 1 stepped connection for **every single component instance**. As of writing,
	in sleitnick's variant, a stepped connection is hooked up for **each component instance**, which is not scalable for large
	scale operations.
	:::

	:::note Method
	This is a method, not a function. This is a limitation
	of the documentation tool which should be fixed soon.
	:::
	
	```lua
	local MyComponent = Component.new({tag = "MyComponent"})
	
	function MyComponent:steppedUpdate(time, dt)
	end
	```
]=]
--[=[
	@tag Component Class
	@function renderSteppedUpdate
	@param dt number
	@within Component
	@client

	If this method is present on a component, then it will be
	automatically connected to `RunService.RenderStepped`. If
	the `[Component].renderPriority` field is found, then the
	component will instead use `RunService:BindToRenderStep()`
	to bind the function.

	:::tip 
	`Component` will only ever hook up 1 render stepped connection for **every single component instance**. 
	As of writing, in sleitnick's variant, a render stepped connection is hooked up for **each component instance** , 
	which is not scalable for large scale operations.

	However, if `renderPriority` is specified, then a new render stepped connection will be hooked up for the component
	instance.
	:::

	:::note Method
	This is a method, not a function. This is a limitation
	of the documentation tool which should be fixed soon.
	:::
	
	```lua
	-- Example that uses `RunService.RenderStepped` automatically:

	local MyComponent = Component.new({tag = "MyComponent"})
	
	function MyComponent:renderSteppedUpdate(dt)
	end
	```
	```lua
	-- Example that uses `RunService:BindToRenderStep` automatically:
	
	local MyComponent = Component.new({tag = "MyComponent"})

	-- Defining a renderPriority will force the component to use BindToRenderStep instead
	MyComponent.renderPriority = Enum.renderPriority.Camera.Value
	
	function MyComponent:renderSteppedUpdate(dt)
	end
	```
]=]

function Component:destroy()
	self[KEY_TROVE]:destroy()
end

for callbackIdentifier, event in RUN_SERVICE_EVENTS_TO_CONNECT do
	event:Connect(function(...)
		for _, component in globalComponents do
			if typeof(component[callbackIdentifier]) ~= "function" then
				continue
			end

			-- Components with `renderPriority` set will have a `BindToRenderStep`
			-- connection hooked up separately.
			if
				callbackIdentifier == RUN_SERVICE_EVENTS_TO_CONNECT.renderSteppedUpdate
				and component.renderPriority ~= nil
			then
				continue
			end

			debug.profilebegin(
				string.format(
					COMPONENT_LIFECYLE_METHOD_DEBUG,
					tostring(component),
					callbackIdentifier
				)
			)
			component[callbackIdentifier](component, ...)
			debug.profileend()
		end
	end)
end

return Component
