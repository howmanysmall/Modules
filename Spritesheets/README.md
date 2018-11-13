# RoStrap Spritesheets

RoStrap Spritesheets is a custom spritesheet handler made for [RoStrap](https://github.com/RoStrap).


## Example Usage
------

To use this module, first create a folder in your Resources ModuleScript called `Spritesheets`. This is where you'll store your Spritesheet ModuleScripts. Here's an example Material Design icon Spritesheet I made.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage:WaitForChild("Resources"))
local Spritesheet = Resources:LoadLibrary("Spritesheet")
local Table = Resources:LoadLibrary("Table")

local Material = { }
Material.__index = Material

function Material.new()
	local self = Spritesheet.new("rbxassetid://1673032291")
	
	self:AddSprite("AddNew", Vector2.new(0, 0), Vector2.new(96, 96))
	self:AddSprite("Announcement", Vector2.new(96, 0), Vector2.new(96, 96))
	self:AddSprite("Close", Vector2.new(192, 0), Vector2.new(96, 96))
	self:AddSprite("CloudCompleted", Vector2.new(288, 0), Vector2.new(96, 96))
	self:AddSprite("Search", Vector2.new(384, 0), Vector2.new(96, 96))
	self:AddSprite("CloudDownload", Vector2.new(0, 96), Vector2.new(96, 96))
	self:AddSprite("CloudQueue", Vector2.new(96, 96), Vector2.new(96, 96))
	self:AddSprite("CloudUpload", Vector2.new(192, 96), Vector2.new(96, 96))
	self:AddSprite("Done", Vector2.new(288, 96), Vector2.new(96, 96))
	self:AddSprite("Settings", Vector2.new(384, 96), Vector2.new(96, 96))
	self:AddSprite("Exit", Vector2.new(0, 192), Vector2.new(96, 96))
	self:AddSprite("Help", Vector2.new(96, 192), Vector2.new(96, 96))
	self:AddSprite("Info", Vector2.new(192, 192), Vector2.new(96, 96))
	self:AddSprite("Emoticon", Vector2.new(288, 192), Vector2.new(96, 96))
	self:AddSprite("ShoppingCart", Vector2.new(384, 192), Vector2.new(96, 96))
	self:AddSprite("Label", Vector2.new(0, 288), Vector2.new(96, 96))
	self:AddSprite("Menu", Vector2.new(96, 288), Vector2.new(96, 96))
	self:AddSprite("Refresh", Vector2.new(192, 288), Vector2.new(96, 96))
	self:AddSprite("ReportProblem", Vector2.new(288, 288), Vector2.new(96, 96))
	self:AddSprite("VideoCamOff", Vector2.new(384, 288), Vector2.new(96, 96))
	self:AddSprite("VideoCam", Vector2.new(0, 384), Vector2.new(96, 96))
	
	setmetatable(self, Material)
	return self
end

setmetatable(Material, Spritesheet)
return Table.Lock(Material)
```

Call this script `Material` and make sure it's inside the `Spritesheets` folder.

To use it in a UI, make sure you require it in the script.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage:WaitForChild("Resources"))
local SpritesheetHandler = Resources:LoadLibrary("SpritesheetHandler")

local Gui = script.Parent
local Frame = Gui:WaitForChild("Frame")

local MenuButton = SpritesheetHandler:GetImageButton("Menu", "Material")
MenuButton.AnchorPoint = Vector2.new(0.5, 0.5)
MenuButton.Name = "MenuButton"
MenuButton.Position = UDim2.new(0.5, 0, 0.5, 0)
MenuButton.Size = UDim2.new(0, 30, 0, 30)
MenuButton.ZIndex = 2
MenuButton.ImageColor3 = Color.FromHex("#949494")
MenuButton.Parent = Frame
```
