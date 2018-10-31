-- Borrowed from https://github.com/AmaranthineCodices/roact-material/tree/master/src/Components/Icon

local SheetAssets = {
	[1] = "rbxassetid://1330514658",
	[2] = "rbxassetid://1330515143",
	[3] = "rbxassetid://1330573324",
	[4] = "rbxassetid://1330573609",
	[5] = "rbxassetid://1330573880",
	[6] = "rbxassetid://1330574454",
	[7] = "rbxassetid://1330575498",
	[8] = "rbxassetid://1330575765",
	[9] = "rbxassetid://1330575939",
	[10] = "rbxassetid://1330582217",
	[11] = "rbxassetid://1330582416",
	[12] = "rbxassetid://1330582591",
	[13] = "rbxassetid://1330582964",
	[14] = "rbxassetid://1330583109",
	[15] = "rbxassetid://1330588230",
	[16] = "rbxassetid://1330588493",
	[17] = "rbxassetid://1330588679",
	[18] = "rbxassetid://1330588820",
	[19] = "rbxassetid://1330588932",
	[20] = "rbxassetid://1330592123"
}

local Instance_new = Instance.new
local Vector2_new = Vector2.new
local math_abs = math.abs

local Spritesheet = require(script.Spritesheets)

local function ClosestResolution(icon, goalResolution)
	local closest = 0
	local closestDelta = nil

	for resolution in next, icon do
		if goalResolution % resolution == 0 or resolution % goalResolution == 0 then
			return resolution
		elseif not closestDelta or math_abs(resolution - goalResolution) < closestDelta then
			closest = resolution
			closestDelta = math_abs(resolution - goalResolution)
		end
	end

	return closest
end

-- Icon Function
-- Usage:
--[[
	local MoreVert = Icon {
		Icon = "more_vert",
		Size = UDim2.new(0, 50, 0, 50),
		Position = UDim2.new(1, -5, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		IconColor3 = Color3.fromRGB(255, 255, 255),
		IconTransparency = 0,
		Type = "ImageButton", -- or "ImageLabel"
		ZIndex = 5
	}
	MoveVert.Parent = script.Parent
]]--

local function Icon(props)
	local iconName = props.Icon
	local icon = Spritesheet[iconName]
	local chosenResolution = props.Resolution

	if not chosenResolution then
		if props.Size.X.Scale ~= 0 or props.Size.Y.Scale ~= 0 then
			chosenResolution = ClosestResolution(icon, 1 / 0)
		else
			assert(props.Size.X.Offset == props.Size.Y.Offset, "If using offset Icon size must result in a square")
			chosenResolution = ClosestResolution(icon, props.Size.X.Offset)
		end
	end

	local variant = icon[chosenResolution]
	
	local IconImage = Instance_new(props.Type or "ImageLabel")
	IconImage.Image = SheetAssets[variant.Sheet]
	IconImage.BackgroundTransparency = 1
	IconImage.ImageRectSize = Vector2_new(variant.Size, variant.Size)
	IconImage.ImageRectOffset = Vector2_new(variant.X, variant.Y)
	IconImage.ImageColor3 = props.IconColor3
	IconImage.ImageTransparency = props.IconTransparency
	IconImage.Size = props.Size
	IconImage.Position = props.Position
	IconImage.AnchorPoint = props.AnchorPoint
	IconImage.ZIndex = props.ZIndex
	
	return IconImage
end

return Icon
