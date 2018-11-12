local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage:WaitForChild("Resources"))
local Table = Resources:LoadLibrary("Table")
local Typer = Resources:LoadLibrary("Typer")

local SpritesheetHandler = { }
local SpritesheetCache = { }

local function GetImageInstance(InstanceType, Index, Style)
	local Sheet = SpritesheetCache[Style]
	if not Sheet then
		Sheet = require(Resources:GetSpritesheet(Style)).new()
		SpritesheetCache[Style] = Sheet
	end
	
	return Sheet:GetSprite(InstanceType, Index)
end

SpritesheetHandler.GetImageLabel = Typer.AssignSignature(2, Typer.String, Typer.String, function(self, Index, Style)
	return GetImageInstance("ImageLabel", Index, Style)
end)

SpritesheetHandler.GetImageButton = Typer.AssignSignature(2, Typer.String, Typer.String, function(self, Index, Style)
	return GetImageInstance("ImageButton", Index, Style)
end)

return Table.Lock(SpritesheetHandler)
