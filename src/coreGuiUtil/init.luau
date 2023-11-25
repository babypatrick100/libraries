--[=[ 
    @class coreGuiUtil

    A simple utility module for working with [CoreGui](https://create.roblox.com/docs/reference/engine/classes/CoreGui)'s API.
]=]

local StarterGui = game:GetService("StarterGui")

local Promise = require(script.Parent.Promise)

local coreGuiUtil = {}

--[=[
    Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved once [StarterGui:SetCore](https://create.roblox.com/docs/reference/engine/classes/StarterGui#SetCore) has successfully executed.

    ```lua
    coreGuiUtil.setCore("AvatarContextMenuTheme", {
        BackgroundImage = "", 
        BackgroundTransparency = 0.5, 
        BackgroundColor = Color3.fromRGB(111, 145, 242),
        NameTagColor = Color3.fromRGB(0, 0, 200),
        NameUnderlineColor = Color3.fromRGB(213, 233, 255),
        ButtonFrameColor = Color3.fromRGB(15, 24, 65), 
        ButtonFrameTransparency = 0.2, 
        ButtonUnderlineColor = Color3.fromRGB(213, 233, 255), 
        Font = Enum.Font.SciFi
    }):andThen(function()
        print("Successfully set core AvatarContextMenuTheme")
    end)
    ```

    @return Promise<>
]=]

function coreGuiUtil.setCore(coreGuiName: string, ...: any)
	local args = { ... }

	return Promise.new(function(resolve)
		while not pcall(StarterGui.SetCore, StarterGui, coreGuiName, table.unpack(args)) do
			task.wait()
		end

		resolve()
	end)
end

--[=[
    Returns a [promise](https://eryn.io/roblox-lua-promise/) which is resolved once [StarterGui:SetCoreGuiEnabled](https://create.roblox.com/docs/reference/engine/classes/StarterGui#SetCoreGuiEnabled) has successfully executed.

    ```lua
    coreGuiUtil.setCoreGuiEnabled(Enum.CoreGuiType.Health, false):andThen(function()
        print("Successfully disabled the Health core gui")
    end)    
    ```

    @return Promise<>
]=]

function coreGuiUtil.setCoreGuiEnabled(gui: Enum.CoreGuiType, enabled: boolean)
	return Promise.new(function(resolve)
		-- Quite a hacky way, but the only way currently. Will refactor this
		-- once Roblox solves race condition issues related to this.
		while not StarterGui:GetCoreGuiEnabled(gui) do
			task.wait()
		end

		StarterGui:SetCoreGuiEnabled(gui, enabled)
		resolve()
	end)
end

return table.freeze(coreGuiUtil)
