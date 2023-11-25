--[=[
    @class RemoteSignal

    A remote signal in layman's terms is simply an object which dispatches data
    to a client (who can listen to this data through a client remote signal) and 
    listens to data dispatched to itself by a client (through a client remote signal).
]=]

--[=[ 
    @type RemoteSignal RemoteSignal
    @within RemoteSignal
    @tag Read only
]=]

--[=[
    @interface Middleware
    @within RemoteSignal
    .serverEvent { (client: Player, args: {any}) -> any }?,

    `serverEvent` must be array of callbacks, if specified.

    ### `serverEvent` 

    Callbacks in `serverEvent` are called whenever the client fires off the remote signal.

    The first argument passed to each callback is a reference to the remote signal itself,
    which is followed by the client object, which is followed by an array of arguments sent 
    by the client. 

    ```lua
    local serverEventCallbacks = {
        function (remoteSignal, client, arguments)
            print(RemoteSignal.is(remoteSignal)) --> true
            print(client:IsA("Player")) --> true 
            print(typeof(arguments)) --> "table"
        end
    }
    ---
    ```

    :::warning Yielding is not allowed
    Middleware callbacks aren't allowed to yield. If they do so, their thread will be closed and an error will be outputted.
    :::

    :::tip More control
    - If any of the callbacks return an **explicit** false value, then the remote signal
    will not be fired. For e.g:

    ```lua
    -- Server
    local Workspace = game:GetService("Workspace")

    local testNetwork = network.Server.new("TestNetwork")
    local testRemoteSignal = network.Server.RemoteSignal.new({
        serverEvent = {function() return false end}
    })

    testRemoteSignal:connect(function()
        print("Fired") --> never prints
    end)

    testNetwork:append("signal", testRemoteSignal)
    testNetwork:dispatch(Workspace)

    -- Client
    local Workspace = game:GetService("Workspace")
    
    local testNetwork = network.client.fromParent("TestNetwork", Workspace)
    print(testNetwork.signal:fireServer()) 
    ```

    - Additionally, you can modify the `arguments` table, for e.g:

    ```lua
    -- Server
    local Workspace = game:GetService("Workspace")

    local testNetwork = network.Server.new("TestNetwork")
    local testRemoteSignal = network.Server.RemoteSignal.new({
        serverEvent = {
            function(_, arguments) 
                arguments[2] = 5 
                arguments[3] = "test"
            end
        }
    })

    testRemoteSignal:connect(function(client, a, b)
        print(a, b) --> 5, "test" (a and b ought to be 1 and 24 respectively, but they were modified through the middleware)
    end)

    testNetwork:append("signal", testRemoteSignal)
    testNetwork:dispatch(Workspace)

    -- Client
    local Workspace = game:GetService("Workspace")

    local testNetwork = network.client.fromParent("Test", Workspace):expect()
    print(testNetwork.signal:fireServer(1, 24)) 
    ```
    :::
]=]

local Players = game:GetService("Players")

local networkFolder = script.Parent.Parent
local packages = networkFolder.Parent
local utilities = networkFolder.utilities

local sharedTypes = require(networkFolder.sharedTypes)
local sharedEnums = require(networkFolder.sharedEnums)
local Janitor = require(packages.Janitor)
local Sift = require(packages.Sift)
local networkUtil = require(utilities.networkUtil)

local DEFAULT_MIDDLEWARE_TEMPLATE = { serverEvent = {} }

local RemoteSignal = { __index = {} }

type Middleware = { serverEvent: { serverEvent: { () -> boolean } } }

--[=[
    @param middleware Middleware?
    @return RemoteSignal

    Creates and returns a new remote signal.
]=]

function RemoteSignal.new(middleware: Middleware?): RemoteSignal
	if middleware ~= nil then
		middleware = Sift.Dictionary.mergeDeep(middleware, DEFAULT_MIDDLEWARE_TEMPLATE)
	else
		middleware = Sift.Dictionary.copyDeep(DEFAULT_MIDDLEWARE_TEMPLATE)
	end

	local self = setmetatable({
		_janitor = Janitor.new(),
		_middleware = middleware,
	}, RemoteSignal)

	self:_init()
	return self
end

--[=[
    Returns a boolean indicating if `self` is a remote signal or not.
]=]

function RemoteSignal.is(self: any): boolean
	return getmetatable(self) == RemoteSignal
end

--[=[
    @tag RemoteSignal instance

    Connects `callback` to the remote signal so that it is called whenever the client
    fires the remote signal. Additionally, `callback` will be passed all the arguments sent 
    by the client.

    ```lua
    -- Server
    remoteSignal:connect(function(client, a, b)
        print(a + b) --> 3
    end)

    -- Client
    clientRemoteSignal:fireServer(1, 2)
    ```
]=]

function RemoteSignal.__index:connect(callback: (client: Player, ...any) -> ()): RBXScriptConnection
	return self._remoteEvent.OnServerEvent:Connect(function(client: Player, serializedArgs)
		local args = { networkUtil.deserializeAndUnpack(self._remoteEvent, serializedArgs) }

		if not self:_shouldInvocate(client, unpack(args)) then
			return
		end

		callback(client, unpack(args))
	end)
end

--[=[
	@tag RemoteSignal instance

	Works almost exactly the same as [RemoteSignal:connect], except the 
	connection returned is  disconnected immediately upon `callback` being called.
]=]

function RemoteSignal.__index:once(callback: (client: Player, ...any) -> ()): RBXScriptConnection
	return self._remoteEvent.OnServerEvent:Once(function(client: Player, serializedArgs)
		local args = { client, networkUtil.deserializeAndUnpack(self._remoteEvent, serializedArgs) }

		if not self:_shouldInvocate(unpack(args)) then
			return
		end

		callback(unpack(args))
	end)
end

--[=[
    @tag RemoteSignal instance

    Connects `callback` to the remote signal so that it is called whenever the remote signal
    is fired off by the client *successfully*. Additionally, `callback` will be passed all the arguments sent 
    by the client.

    ```lua
    -- Server
    remoteSignal:connect(function(client, a, b)
        print(a + b) --> 3
    end)

    -- Client
    clientRemoteSignal:fireServer(1, 2)
    ```
]=]

--[=[
    @tag RemoteSignal instance

    Yields the current thread until the remote signal is *successfully* fired off by the client. 
    The yielded thread is resumed once the client fires some data to the server *successfully*, 
    with the arguments sent by the client.

    ```lua
    -- Server
    local client, a, b = remoteSignal:wait()
    print(a + b) --> 3

    -- Client
    clientRemoteSignal:fireServer(1, 2)
    ```
]=]

function RemoteSignal.__index:wait<T...>(): T...
	local yieldedThread = coroutine.running()

	self:once(function(...)
		task.spawn(yieldedThread, ...)
	end)

	return coroutine.yield()
end

--[=[
    @tag RemoteSignal instance

    Fires the arguments `...` to `client`.
]=]

function RemoteSignal.__index:fireClient<T...>(client: Player, ...: T...)
	self._remoteEvent:FireClient(client, networkUtil.serializeGivenArgs(self._remoteEvent, ...))
end

--[=[
    @tag RemoteSignal instance

    Calls [RemoteSignal:fireClient] for every player in the game, also 
    passing in the arguments `...`.
]=]

function RemoteSignal.__index:fireAllClients<T...>(...: T...)
	self._remoteEvent:FireAllClients(networkUtil.serializeGivenArgs(self._remoteEvent, ...))
end

--[=[
    @tag RemoteSignal instance

    Calls [RemoteSignal:fireClient] for every player in the `clients` table only, also 
    passing in the arguments `...`.
]=]

function RemoteSignal.__index:fireClients<T...>(clients: { Player }, ...: T...)
	local serializedArgs = networkUtil.serializeGivenArgs(self._remoteEvent, ...)

	for _, client in clients do
		self._remoteEvent:FireClient(client, serializedArgs)
	end
end

--[=[
    @tag RemoteSignal instance

    Calls [RemoteSignal:fireClient] for every player in the game, except for `client`, also 
    passing in the arguments `...`.
]=]

function RemoteSignal.__index:fireAllClientsExcept<T...>(client: Player, ...: T...)
	local serializedArgs = networkUtil.serializeGivenArgs(self._remoteEvent, ...)

	for _, player in Players:GetPlayers() do
		if player == client then
			continue
		end

		self._remoteEvent:FireClient(player, serializedArgs)
	end
end

--[=[
    @tag RemoteSignal instance
    
    Destroys the remote signal and renders it unusable.
]=]

function RemoteSignal.__index:destroy()
	self._janitor:Destroy()
end

--[=[
    @private
]=]

function RemoteSignal.__index:dispatcherRemoteInstance()
	return self._remoteEvent
end

--[=[
    @private
]=]

function RemoteSignal.__index:dispatch(name: string, parent: Instance)
	self._remoteEvent.Name = name
	self._remoteEvent:SetAttribute(sharedEnums.Attribute.BoundToRemoteSignal, true)
	self._remoteEvent.Parent = parent
end

function RemoteSignal.__index:_shouldInvocate(client: Player, ...: any)
	local args = { ... }

	-- If there is an explicit false value included in the accumulated
	-- response of all serverEvent callbacks, then that means we should
	-- avoid this client's request to fire off the remote signal:
	if
		table.find(
			networkUtil.accumulatedResponseFromMiddlewareCallbacks(
				self._middleware.serverEvent,
				self,
				client,
				args
			),
			false
		)
	then
		return false
	end

	return true
end

function RemoteSignal.__index:_init()
	self._remoteEvent = self._janitor:Add(Instance.new("RemoteEvent"))
	self._janitor:Add(function()
		setmetatable(self, nil)
	end)
end

function RemoteSignal:__tostring()
	return string.format("[RemoteSignal]: (%s)", self._remoteEvent.Name)
end

export type RemoteSignal = typeof(setmetatable(
	{} :: {
		_janitor: sharedTypes.Janitor,
		_middleware: Middleware,
	},
	RemoteSignal
))

return table.freeze(RemoteSignal)
