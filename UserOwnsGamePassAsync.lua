local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")

local Resources = require(ReplicatedStorage:WaitForChild("Resources"))
local FastSpawn = Resources:LoadLibrary("FastSpawn")
local Promise = Resources:LoadLibrary("Promise")
local Typer = Resources:LoadLibrary("Typer")

--[[**
	UserOwnsGamePassAsync - For checking whether or not a Player owns a certain GamePass.
	@param Player The Player you want to check. Requires a Player Instance.
	@param GamePassID The GamePass ID you want to check for. Requires a positive integer.
	@returns Promise Function / Boolean
**--]]
local UserOwnsGamePassAsync = Typer.AssignSignature(Typer.InstanceWhichIsAPlayer, Typer.PositiveInteger, function(Player, GamePassID)
	return Promise.new(function(Resolve, Reject)
		FastSpawn(function()
			local Success, Value = pcall(MarketplaceService.UserOwnsGamePassAsync, MarketplaceService, Player.UserId, GamePassID)
			if Success then
				Resolve(Value)
			else
				Reject(Value)
			end
		end)
	end)
end)

return UserOwnsGamePassAsync
