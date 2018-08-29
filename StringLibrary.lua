local Resources = require(game:GetService("ReplicatedStorage"):WaitForChild("Resources"))
local Table = Resources:LoadLibrary("Table")
local Typer = Resources:LoadLibrary("Typer")
-- This requires RoStrap. Check it out on GitHub [https://github.com/RoStrap] and Roblox [https://www.roblox.com/library/725884332/RoStrap-Package-Manager].
-- If you don't want to use RoStrap, just remove the first two lines and replace `return Table.Lock(StringLibrary)` with `return StringLibrary`. But you should use RoStrap.

local StringLibrary = { }

local MATCH = string.match
local GSUB = string.gsub

-- Credit to Crazyman32 for these next two functions.

StringLibrary.GetNumberFromString = Typer.AssignSignature(Typer.String, function(String)
	if not String or type(String) ~= "string" then return String and type(String) == "number" and String or 0 end
	return tonumber(String) or tonumber(MATCH(String, "%-?%d+%.?%d*")) or 0
end)

StringLibrary.PositiveInteger = Typer.AssignSignature(Typer.String, function(String)
	return GSUB(String, "%D+", "")
end)

StringLibrary.ClampNumber = Typer.AssignSignature(Typer.String, Typer.PositiveInteger, Typer.PositiveInteger, function(String, Min, Max)
	local Number = StringLibrary.GetNumberFromString(String)
	return tostring(math.clamp(Number, Min, Max))
end)

return Table.Lock(StringLibrary)
