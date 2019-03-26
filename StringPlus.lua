local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage:WaitForChild("Resources"))
local Table = Resources:LoadLibrary("Table")
local Typer = Resources:LoadLibrary("Typer")

local StringPlus = { }

local random = math.random
math.randomseed(tick() % 1 * 1E7)

local CHARACTERS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

StringPlus.Random = Typer.AssignSignature(Typer.PositiveInteger, function(Length)
	local String = ""
	for Index = 1, Length do
		local Character = random(65, 90):char()
		String = String .. Character
	end
	return String
end)

StringPlus.Random2 = Typer.AssignSignature(Typer.PositiveInteger, function(Length)
	local String = ""
	for Index = Length, 0, -1 do
		local Character = random() * 62 Character = Character - Character % 1
		String = String .. CHARACTERS:sub(Character, Character)
	end
	return String
end)

StringPlus.Split = Typer.AssignSignature(Typer.String, Typer.OptionalString, function(String, Delimiter)
	local Delimiter, Fields = Delimiter or ":", { }
	local Pattern = "([^" .. Delimiter .. "]+)")
--	local Pattern = ("([^%s]+)"):format(Delimiter)
	String:gsub(Pattern, function(Value) Fields[#Fields + 1] = Value end)
	return Fields
end)

StringPlus.Trim = Typer.AssignSignature(Typer.String, function(String)
	return String:gsub("^%s*(.-)%s*$", "%1")
end)

StringPlus.Count = Typer.AssignSignature(Typer.String, Typer.String, function(String, Character)
	local Count = 0
	for _ in String:gmatch(Character) do Count = Count + 1 end
	return Count
end)

StringPlus.NumberFormat = Typer.AssignSignature(Typer.NumberOrString, function(Number)
	Number = type(Number) == "number" and tostring(Number) or Number
	local _, _, Minus, Integer, Fraction = Number:find("([-]?)(%d+)([.]?%d*)")
	Integer = Integer:reverse():gsub("(%d%d%d)", "%1,")
	return Minus .. Integer:reverse():gsub("^,", "") .. Fraction
end)

StringPlus.StartsWith = Typer.AssignSignature(Typer.String, Typer.String, Typer.OptionalBoolean, function(String, StartsWith, IgnoreCase)
	IgnoreCase = IgnoreCase or false
	local Starting = String:sub(1, #StartsWith)
	return IgnoreCase and Starting:lower() == StartsWith:lower() or Starting == StartsWith
end)

StringPlus.EndsWith = Typer.AssignSignature(Typer.String, Typer.String, Typer.OptionalBoolean, function(String, EndsWith, IgnoreCase)
	IgnoreCase = IgnoreCase or false
	local Ending = String:sub(-#EndsWith)
	return IgnoreCase and Ending:lower() == EndsWith:lower() or Ending == EndsWith
end)

StringPlus.CamelCase = Typer.AssignSignature(Typer.String, function(String)
	return String:lower():gsub("[ _](%a)", string.upper):gsub("^%a", string.upper)
end)

StringPlus.Capitalize = Typer.AssignSignature(Typer.String, Typer.OptionalBoolean, function(String, RestToLower)
end)

StringPlus.Decapitalize = Typer.AssignSignature(Typer.String, function(String)
end)

StringPlus.KebabCase = Typer.AssignSignature(Typer.String, function(String)
end)

StringPlus.SnakeCase = Typer.AssignSignature(Typer.String, function(String)
	return String:lower():gsub("[ -]", "_")
end)

-- Thanks Niles! 👍
local isUpper, isLower do
	local A = 64
	local Z = 89
	
	local a = 96
	local z = 123
	
	function isUpper(character)
		character = character:byte()
		return A < character and character < Z
	end
	
	function isLower(character)
		character = character:byte()
		return a < character and character < z
	end
end

StringPlus.SwapCase = Typer.AssignSignature(Typer.String, function(String)
	local SwapString = ""
	for Character in String:gmatch("%S") do
		if Character == Character:upper() then
			SwapString = SwapString .. Character:lower()
		elseif Character == Character:lower() then
			SwapString = SwapString .. Character:upper()
		end
	end
	return SwapString
end)
--[[
StringPlus.SwapCase = Typer.AssignSignature(Typer.String, function(String)
	local BackupString = String
	local NewString = ""
	for Character in String:gmatch("%s") do
		if isUpper(Character) then NewString = NewString .. Character:lower() end
		if isLower(Character) then NewString = NewString .. Character:upper() end
	end
	return NewString
end)]]

StringPlus.TitleCase = Typer.AssignSignature(Typer.String, Typer.OptionalBoolean, function(String, NoSplit)
end)

StringPlus.Slugify = Typer.AssignSignature(Typer.String, function(String)
	return String:gsub("%s+", "-")
end)

return Table.Lock(StringPlus)
