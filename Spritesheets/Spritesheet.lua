local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage:WaitForChild("Resources"))
local Debug = Resources:LoadLibrary("Debug")
local Typer = Resources:LoadLibrary("Typer")

local Spritesheet = { }
Spritesheet.__index = Spritesheet

Spritesheet.new = Typer.AssignSignature(Typer.String, function(Texture)
	local self = { }
	self.Texture = Texture
	self.Sprites = { }
	setmetatable(self, Spritesheet)
	return self
end)

Spritesheet.AddSprite = Typer.AssignSignature(2, Typer.String, Typer.Vector2, Typer.Vector2, function(self, Index, Position, Size)
	local Sprite = { Position = Position, Size = Size }
	self.Sprites[Index] = Sprite
end)

Spritesheet.GetSprite = Typer.AssignSignature(2, Typer.String, Typer.String, function(self, InstanceType, Index)
	local Sprite = self.Sprites[Index]
	if not Sprite then Debug.Warn("Couldn't find a sprite with index %q.", Index) return false end
	local Element = Instance.new(InstanceType)
	Element.BackgroundTransparency = 1
	Element.Image = self.Texture
	Element.Size = UDim2.new(0, Sprite.Size.X, 0, Sprite.Size.Y)
	Element.ImageRectOffset = Sprite.Position
	Element.ImageRectSize = Sprite.Size
	return Element
end)

return Spritesheet
