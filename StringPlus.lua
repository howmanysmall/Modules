local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Resources = require(ReplicatedStorage.Resources)
local Table = Resources:LoadLibrary("Table")
local Typer = Resources:LoadLibrary("Typer")

local StringPlus = {}

math.randomseed(tick() % 1 * 1E7)

local CHARACTERS = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
local CASE_SWAP = setmetatable({A = "a", B = "b", C = "c", D = "d", E = "e", F = "f", G = "g", H = "h", I = "i", J = "j", K = "k", L = "l", M = "m", N = "n", O = "o", P = "p", Q = "q", R = "r", S = "s", T = "t", U = "u", V = "v", W = "w", X = "x", Y = "y", Z = "z", a = "A", b = "B", c = "C", d = "D", e = "E", f = "F", g = "G", h = "H", i = "I", j = "J", k = "K", l = "L", m = "M", n = "N", o = "O", p = "P", q = "Q", r = "R", s = "S", t = "T", u = "U", v = "V", w = "W", x = "X", y = "Y", z = "Z"}, {
	__index = function(_, Index)
		return Index
	end;
})

StringPlus.Random = Typer.AssignSignature(Typer.PositiveInteger, function(Length)
	local String = ""
	for _ = 1, Length do
		local Character = string.char(math.random(65, 90))
		String = String .. Character
	end

	return String
end)

StringPlus.Random2 = Typer.AssignSignature(Typer.PositiveInteger, function(Length)
	local String = ""
	for _ = Length, 0, -1 do
		local Character = math.random() * 62
		Character = Character - Character % 1
		String = String .. string.sub(CHARACTERS, Character, Character)
	end

	return String
end)

StringPlus.Split = Typer.AssignSignature(Typer.String, Typer.OptionalString, function(String, Delimiter)
	local Delimiter, Fields = Delimiter or ":", {}
	local Pattern = "([^" .. Delimiter .. "]+)"
	string.gsub(String, Pattern, function(Value) Fields[#Fields + 1] = Value end)
	return Fields
end)

StringPlus.Trim = Typer.AssignSignature(Typer.String, function(String)
	return (string.gsub(String, "^%s*(.-)%s*$", "%1"))
end)

StringPlus.Count = Typer.AssignSignature(Typer.String, Typer.String, function(String, Character)
	local Count = 0
	for _ in string.gmatch(String, Character) do Count = Count + 1 end
	return Count
end)

StringPlus.NumberFormat = Typer.AssignSignature(Typer.NumberOrString, function(Number)
	Number = type(Number) == "number" and tostring(Number) or Number
	local _, _, Minus, Integer, Fraction = string.find(Number, "([-]?)(%d+)([.]?%d*)")
	Integer = string.gsub(string.reverse(Integer), "(%d%d%d)", "%1,")
	return Minus .. string.gsub(string.reverse(Integer), "^,", "") .. Fraction
end)

StringPlus.StartsWith = Typer.AssignSignature(Typer.String, Typer.String, Typer.OptionalBoolean, function(String, StartsWith, IgnoreCase)
	IgnoreCase = IgnoreCase or false
	local Starting = string.sub(String, 1, #StartsWith)
	return IgnoreCase and string.lower(Starting) == string.lower(StartsWith) or Starting == StartsWith
end)

StringPlus.EndsWith = Typer.AssignSignature(Typer.String, Typer.String, Typer.OptionalBoolean, function(String, EndsWith, IgnoreCase)
	IgnoreCase = IgnoreCase or false
	local Ending = string.sub(String, -#EndsWith)
	return IgnoreCase and string.lower(Ending) == string.lower(EndsWith) or Ending == EndsWith
end)

StringPlus.CamelCase = Typer.AssignSignature(Typer.String, function(String)
	return (string.gsub(string.gsub(string.lower(String), "[ _](%a)", string.upper), "^%a", string.upper))
end)

StringPlus.Capitalize = Typer.AssignSignature(Typer.String, Typer.OptionalBoolean, function(String, RestToLower)
end)

StringPlus.Decapitalize = Typer.AssignSignature(Typer.String, function(String)
end)

StringPlus.KebabCase = Typer.AssignSignature(Typer.String, function(String)
end)

StringPlus.SnakeCase = Typer.AssignSignature(Typer.String, function(String)
	return (string.gsub(string.lower(String), "[ -]", "_"))
end)

StringPlus.SwapCase = Typer.AssignSignature(Typer.String, function(String)
	local SwapString = ""

	for Index = 1, #String do
		SwapString = SwapString .. CASE_SWAP[string.sub(String, Index, Index)]
	end

	return SwapString
end)

StringPlus.TitleCase = Typer.AssignSignature(Typer.String, Typer.OptionalBoolean, function(String, NoSplit)
end)

StringPlus.Slugify = Typer.AssignSignature(Typer.String, function(String)
	return (string.gsub(String, "%s+", "-"))
end)

return Table.Lock(StringPlus)
