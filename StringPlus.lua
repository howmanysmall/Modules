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
	return IgnoreCase and String:lower():sub(1, #StartsWith) == StartsWith:lower() or String:sub(1, #StartsWith) == StartsWith
end)

StringPlus.EndsWith = Typer.AssignSignature(Typer.String, Typer.String, Typer.OptionalBoolean, function(String, EndsWith, IgnoreCase)
	IgnoreCase = IgnoreCase or false
	return IgnoreCase and String:lower():sub(-#EndsWith) == EndsWith:lower() or String:sub(-#EndsWith) == EndsWith
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

-- WIP
StringPlus.SwapCase = Typer.AssignSignature(Typer.String, function(String)
	local BackupString = String
	local NewString = ""
	for Character in String:gmatch("%s") do
		if isUpper(Character) then NewString = NewString .. Character:lower() end
		if isLower(Character) then NewString = NewString .. Character:upper() end
	end
	return NewString
end)

StringPlus.TitleCase = Typer.AssignSignature(Typer.String, Typer.OptionalBoolean, function(String, NoSplit)
end)

StringPlus.Slugify = Typer.AssignSignature(Typer.String, function(String)
end)

return Table.Lock(StringPlus)
