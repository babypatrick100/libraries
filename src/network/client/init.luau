--[=[
	@class networkClient
	@client

	The client counterpart of [network].
]=]

--[=[ 
	@prop ClientRemoteProperty ClientRemoteProperty
	@within networkClient
	@tag Read only
]=]

--[=[ 
	@prop ClientRemoteSignal ClientRemoteSignal
	@within networkClient
	@tag Read only
]=]

local Promise = require(script.Parent.Parent.Promise)
local sharedEnums = require(script.Parent.sharedEnums)
local networkUtil = require(script.Parent.utilities.networkUtil)

local DEFAULT_NETWORK_FOLDER_RETRIEVAL_TIMEOUT = 20

local networkAbstracts = {}

local networkClient = {
	ClientRemoteProperty = require(script.ClientRemoteProperty),
	ClientRemoteSignal = require(script.ClientRemoteSignal),
}

local function abstractOfNetworkFolder(networkFolder): { [string]: any }
	if networkAbstracts[networkFolder] then
		return networkAbstracts[networkFolder]
	end

	local abstract = {}

	for _, descendant in networkFolder:GetChildren() do
		if descendant:GetAttribute(sharedEnums.Attribute.BoundToRemoteSignal) then
			abstract[descendant.Name] = networkClient.ClientRemoteSignal.new(descendant)
			continue
		elseif descendant:GetAttribute(sharedEnums.Attribute.BoundToRemoteProperty) then
			abstract[descendant.Name] = networkClient.ClientRemoteProperty.new(descendant)
			continue
		end

		if descendant:GetAttribute(sharedEnums.Attribute.RemoteValueType) == "function" then
			abstract[descendant.Name] = function(...)
				local args = { ... }
				local index = table.find(args, abstract)

				if index then
					table.remove(args, index)
				end

				local promise = Promise.new(function(resolve)
					resolve(
						networkUtil.deserializeAndUnpackArgs(
							descendant,
							descendant:InvokeServer(
								networkUtil.serializeGivenArgs(descendant, table.unpack(args))
							)
						)
					)
				end)

				if descendant:GetAttribute(sharedEnums.Attribute.RemotePromisified) then
					return promise
				else
					return promise:expect()
				end
			end
		else
			abstract[descendant.Name] =
				networkUtil.deserializeAndUnpackArgs(descendant, descendant:InvokeServer())
		end
	end

	networkAbstracts[networkFolder] = abstract
	networkFolder.Destroying:Connect(function()
		networkAbstracts[networkFolder] = nil
	end)

	return table.freeze(abstract)
end

local function networkFoldersFromParent(parent: Instance): { Folder }
	local networkFolders = {}

	for _, networkFolder in parent:GetChildren() do
		if networkFolder:GetAttribute(sharedEnums.Attribute.NetworkFolder) == nil then
			continue
		end

		table.insert(networkFolders, networkFolder)
	end

	return networkFolders
end
--[=[
	Returns an array of *all* networks dispatched to `parent`.

	```lua
	-- Server
	local Workspace = game:GetService("Workspace")

	local network1 = network.Server.new("Test1", Workspace)
	network1:append("status", "not good mate")
	network1:dispatch(Workspace)

	local network2 = network.Server.new("Test2", Workspace)
	network2:append("status", "good mate!")
	network2:dispatch(Workspace)

	-- Client
	local Workspace = game:GetService("Workspace")
	
	for _, networkObject in Network.client.fromParent(Workspace) do
		print(networkObject.status) 
	end

	--> "not good mate"
	--> "good mate!"
	```
]=]

function networkClient.allFromParent(parent: Instance): { [string]: { [string]: any } }
	local networks = {}

	for _, networkFolder in networkFoldersFromParent(parent) do
		networks[networkFolder.Name] = abstractOfNetworkFolder(networkFolder)
	end

	return table.freeze(networks)
end

--[=[
	@return Promise<DispatchedNetwork: {[string]: any}>

	Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved once a network with the 
	name of `name`, is dispatched to `parent`. If a network with the name of `name` is already dispatched to
	`parent`, the promise will immediately resolve.

	For e.g:

	```lua
	-- Server
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Workspace = game:GetService("Workspace")

	local network = require(ReplicatedStorage.Packages.network) 

	local testNetwork = Network.Server.new("Test")
	testNetwork:append("method", function(player)
		return string.format("hi, %s!", player.Name)
	end)

	-- Dispatch the network to workspace:
	testNetwork:dispatch(Workspace) 

	-- Client
	local Workspace = game:GetService("Workspace")

	-- Get the network of name "Test", dispatched to workspace
	local testNetwork = network.client.fromParent("Test", Workspace):expect()
	print(testNetwork.method()) --> "hi, bubshurb!"
	```

	You can also pass in `timeout` which will result in the promise to be rejected (if it hasn't resolved in time).
	`timeout` will default to `20` seconds.
]=]

function networkClient.fromParent(name: string, parent: Instance, timeout: number?)
	return Promise.new(function(resolve, reject)
		local networkFolder =
			parent:WaitForChild(name, timeout or DEFAULT_NETWORK_FOLDER_RETRIEVAL_TIMEOUT)

		if networkFolder == nil then
			reject(nil)
			return
		end

		resolve(abstractOfNetworkFolder(networkFolder))
	end)
end

return table.freeze(networkClient)
