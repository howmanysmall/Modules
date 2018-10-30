local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage:WaitForChild("Resources"))
local Table = Resources:LoadLibrary("Table")
local Typer = Resources:LoadLibrary("Typer")

local StringPlus = { }

local RandomLib = Random.new(tick() % 1 * 1E7)

StringPlus.Random = Typer.AssignSignature(Typer.PositiveInteger, function(Length)
	local String = ""
	for Index = 1, Length do
		local Character = RandomLib:NextInteger(65, 90):char()
		String = String .. Character
	end
	return String
end)

StringPlus.Random2 = Typer.AssignSignature(Typer.PositiveInteger, function(Length)
	local Characters = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
	local String = ""
	for Index = Length, 0, -1 do
		local Character = math.floor(RandomLib:NextNumber() * #Characters)
		String = String .. Characters:sub(Character, Character)
	end
	return String
end)


StringPlus.Split = Typer.AssignSignature(Typer.String, Typer.OptionalString, function(String, Delimiter)
	local Delimiter, Fields = Delimiter or ":", { }
	local Pattern = ("([^%s]+)"):format(Delimiter)
	String:gsub(Pattern, function(Value) Fields[#Fields + 1] = Value end)
	return Fields
end)

StringPlus.Trim = Typer.AssignSignature(Typer.String, function(String)
	return String:gsub("^%s*(.-)%s*$", "%1")
end)

return Table.Lock(StringPlus)
