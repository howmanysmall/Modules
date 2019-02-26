# Modules
Again.

Inspect isn't made by me, the original is found [here](https://github.com/kikito/inspect.lua). I just changed the code slightly and reformatted it.


# RbxWeb Tutorial
```Lua
local RbxWeb = require(PathToModule) RbxWeb:Initialize(game)
local GameData = RbxWeb:AddGeneric("GAME_DATA", "PLAYER_DATA_")
local GameDataApi = RbxWeb:GetGeneric(GameData)

local DATA_DEFAULT = { Wins = 0, Points = 0 }

Players.PlayerAdded:Connect(function(Player)
    local Stats = Instance.new("Folder")
    Stats.Name = "leaderstats"
    
    local Wins = Instance.new("IntValue")
    Wins.Name = "Wins"
    Wins.Parent = Stats
    
    local Points = Instance.new("IntValue")
    Points.Name = "Points"
    Points.Parent = Stats
    
    Stats.Parent = Player
    
    local PlayerKey = GameDataApi:GetKey(Player.UserId)
    local Success, PlayerData = GameDataApi:GetAsync(PlayerKey)
    if not PlayerData then
        PlayerData = DATA_DEFAULT
        GameDataApi:SetAsync(PlayerKey, PlayerData)
    end
    Wins.Value = PlayerData.Wins
    Points.Value = PlayerData.Points
end)

Players.PlayerRemoving:Connect(function(Player)
    local PlayerKey = GameDataApi:GetKey(Player.UserId)
    local PlayerData = { Wins = Player.leaderstats.Wins.Value, Points = Player.leaderstats.Points.Value }
    GameDataApi:SetAsync(PlayerKey, PlayerData)
end)
```
