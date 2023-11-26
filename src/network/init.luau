--[=[
	@class network

	A simple yet incredibly useful network module which simplifies and extends server-client communication.

	```lua
	local Workspace = game:GetService("Workspace")

	-- Server
	local testNetwork = Network.Server.new("TestNetwork")
	testNetwork:append("method", function(player)
		return string.format("hi, %s!", player.Name)
	end)
	testNetwork:dispatch(Workspace)

	-- Client
	local Workspace = game:GetService("Workspace")

	local testNetwork = network.client.fromParent("TestNetwork", Workspace):expect()
	print(testNetwork.method()) --> "hi, bub!"
	```
]=]

--[=[ 
	@prop Server NetworkServer
	@within network
	@tag Read only
]=]

--[=[ 
	@prop client networkClient
	@within network
	@tag Read only
]=]

local ClientRemoteProperty = require(script.client.ClientRemoteProperty)
local ClientRemoteSignal = require(script.client.ClientRemoteSignal)
local RemoteProperty = require(script.Server.RemoteProperty)
local RemoteSignal = require(script.Server.RemoteSignal)
local Server = require(script.Server)

export type ClientRemoteProperty = ClientRemoteProperty.ClientRemoteProperty
export type ClientRemoteSignal = ClientRemoteSignal.ClientRemoteSignal
export type RemoteSignal = RemoteSignal.RemoteSignal
export type RemoteProperty = RemoteProperty.RemoteProperty
export type NetworkServer = Server.NetworkServer

return table.freeze({
	Server = require(script.Server),
	client = require(script.client),
})
