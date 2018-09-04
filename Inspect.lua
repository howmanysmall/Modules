local Inspect = { }
Inspect.KEY = setmetatable({ }, { __tostring = function() return "Inspect.KEY" end })
Inspect.METATABLE = setmetatable({ }, { __tostring = function() return "Inspect.METATABLE" end })

local MATCH = string.match
local GSUB = string.gsub
local CHAR = string.char
local FORMAT = string.format
local REP = string.rep
local FLOOR = math.floor
local SORT = table.sort
local CONCAT = table.concat

local function SmartQuote(String)
	if MATCH(String, '"') and not MATCH(String, "'") then
		return "'" .. String .. "'"
	end
	return '"' .. GSUB(String, '"', '\\"') .. '"'
end

local ShortControlCharEscapes = {
	["\a"] = "\\a", ["\b"] = "\\b", ["\f"] = "\\f", ["\n"] = "\\n",
	["\r"] = "\\r", ["\t"] = "\\t", ["\v"] = "\\v"
}

local LongControlCharEscapes = { }
for Index = 0, 31 do
	local Character = CHAR(Index)
	if not ShortControlCharEscapes[Character] then
		ShortControlCharEscapes[Character] = "\\" .. Index
		LongControlCharEscapes[Character] = FORMAT("\\%03d", Index)
	end
end

local function Escape(String)
	return (GSUB(GSUB(GSUB(String, "\\", "\\\\"), "(%c)%f[0-9]", LongControlCharEscapes), "%c", ShortControlCharEscapes))
end

local function IsIdentifier(String)
	return type(String) == "string" and MATCH(String, "^[_%a][_%a%d]*$")
end

local function IsSequenceKey(Key, SequenceLength)
	return type(Key) == "number" and 1 <= Key and Key <= SequenceLength and FLOOR(Key) == Key
end

local DefaultTypeOrders = {
	["number"] = 1, ["boolean"] = 2, ["string"] = 3, ["table"] = 4,
	["function"] = 5, ["userdata"] = 6, ["thread"] = 7
}

local function SortKeys(A, B)
	local TypeA, TypeB = type(A), type(B)
	if TypeA == TypeB and (TypeA == "string" or TypeA == "number") then return A < B end
	local DefaultTypeA, DefaultTypeB = DefaultTypeOrders[TypeA], DefaultTypeOrders[TypeB]
	if DefaultTypeA and DefaultTypeB then
		return DefaultTypeOrders[TypeA] < DefaultTypeOrders[TypeB]
	elseif DefaultTypeA then
		return true
	elseif DefaultTypeB then
		return false
	end
	return TypeA < TypeB
end

local function GetSequenceLength(Table)
	local Length = 1
	local Value = rawget(Table, Length)
	while Value ~= nil do
		Length = Length + 1
		Value = rawget(Table, Length)
	end
	return Length - 1
end

local function GetNonSequentialKeys(Table)
	local Keys, KeysLength = { }, 0
	local SequenceLength = GetSequenceLength(Table)
	for Key in next, Table do
		if not IsSequenceKey(Key, SequenceLength) then
			KeysLength = KeysLength + 1
			Keys[KeysLength] = Key
		end
	end
	SORT(Keys, SortKeys)
	return Keys, KeysLength, SequenceLength
end

local function CountTableAppearances(Table, TableAppearances)
	TableAppearances = TableAppearances or { }
	if type(Table) == "table" then
		if not TableAppearances[Table] then
			TableAppearances[Table] = 1
			for Key, Value in next, Table do
				CountTableAppearances(Key, TableAppearances)
				CountTableAppearances(Value, TableAppearances)
			end
			CountTableAppearances(getmetatable(Table), TableAppearances)
		else
			TableAppearances[Table] = TableAppearances[Table] + 1
		end
	end
	
	return TableAppearances
end

local function CopySequence(Sequence)
	local Copy, Length = { }, #Sequence
	for Index = 1, Length do Copy[Index] = Sequence[Index] end
	return Copy, Length
end

local function MakePath(Path, ...)
	local Keys = {...}
	local NewPath, Length = CopySequence(Path)
	for Index = 1, #Keys do
		NewPath[Length + Index] = Keys[Index]
	end
	return NewPath
end

local function ProcessRecursive(Process, Item, Path, Visited)
	if Item == nil then return nil end
	if Visited[Item] then return Visited[Item] end
	local Processed = Process(Item, Path)
	if type(Processed) == "table" then
		local ProcessedCopy = { }
		Visited[Item] = ProcessedCopy
		local ProcessedKey
		
		for Key, Value in next, Processed do
			ProcessedKey = ProcessRecursive(Process, Key, MakePath(Path, Key, Inspect.KEY), Visited)
			if ProcessedKey ~= nil then
				ProcessedCopy[ProcessedKey] = ProcessRecursive(Process, Value, MakePath(Path, ProcessedKey), Visited)
			end
		end
		
		local Metatable = ProcessRecursive(Process, getmetatable(Processed), MakePath(Path, Inspect.METATABLE), Visited)
		if type(Metatable) ~= "table" then Metatable = nil end
		setmetatable(ProcessedCopy, Metatable)
		Processed = ProcessedCopy
	end
	return Processed
end

local Inspector = { }
local InspectorMeta = { __index = Inspector }

function Inspector:Puts(...)
	local Arguments = {...}
	local Buffer = self.Buffer
	local Length = #Buffer
	for Index = 1, #Arguments do
		Length = Length + 1
		Buffer[Length] = Arguments[Index]
	end
end

function Inspector:Down(Function)
	self.Level = self.Level + 1
	Function()
	self.Level = self.Level - 1
end

function Inspector:Tabify()
	self:Puts(self.NewLine, REP(self.Indent, self.Level))
end

function Inspector:AlreadyVisited(Value)
	return self.IDs[Value] ~= nil
end

function Inspector:GetID(Value)
	local ID = self.IDs[Value]
	if not ID then
		local ValueType = type(Value)
		ID = (self.MaxIDs[ValueType] or 0) + 1
		self.MaxIDs[ValueType] = ID
		self.IDs[Value] = ID
	end
	return tostring(ID)
end

function Inspector:PutKey(Key)
	if IsIdentifier(Key) then return self:Puts(Key) end
	self:Puts("[")
	self:PutValue(Key)
	self:Puts("]")
end

function Inspector:PutTable(Table)
	if Table == Inspect.KEY or Table == Inspect.METATABLE then
		self:Puts(tostring(Table))
	elseif self:AlreadyVisited(Table) then
		self:Puts("<table ", self:GetID(Table), ">")
	elseif self.Level >= self.Depth then
		self:Puts("{...}")
	else
		if self.TableAppearances[Table] > 1 then self:Puts("<", self:GetID(Table), ">") end
		local NonSequentialKeys, NonSequentialKeysLength, SequenceLength = GetNonSequentialKeys(Table)
		local Metatable = getmetatable(Table)
		
		self:Puts("{")
		self:Down(function()
			local Count = 0
			for Index = 1, SequenceLength do
				if Count > 0 then self:Puts(",") end
				self:Puts(" ")
				self:PutValue(Table[Index])
				Count = Count + 1
			end
			
			for Index = 1, NonSequentialKeysLength do
				local Key = NonSequentialKeys[Index]
				if Count > 0 then self:Puts(",") end
				self:Tabify()
				self:PutKey(Key)
				self:Puts(" = ")
				self:PutValue(Table[Key])
				Count = Count + 1
			end
			
			if type(Metatable) == "table" then
				if Count > 0 then self:Puts(",") end
				self:Tabify()
				self:Puts("<metatable> = ")
				self:PutValue(Metatable)
			end
		end)
		
		if NonSequentialKeysLength > 0 or type(Metatable) == "table" then
			self:Tabify()
		elseif SequenceLength > 0 then
			self:Puts(" ")
		end
		
		self:Puts("}")
	end
end

function Inspector:PutValue(Value)
	local ValueType = type(Value)
	if ValueType == "string" then
		self:Puts(SmartQuote(Escape(Value)))
	elseif ValueType == "number" or ValueType == "boolean" or ValueType == "nil" then
		self:Puts(tostring(Value))
	elseif ValueType == "table" then
		self:PutTable(Value)
	else
		self:Puts("<", ValueType, " ", self:GetID(Value), ">")
	end
end

function Inspect.Inspect(Root, Opt)
	local Options = Opt or { }
	local Depth = Options.Depth or 1 / 0
	local NewLine = Options.NewLine or "\n"
	local Indent = Options.Indent or "	"
	local Process = Options.Process
	
	if Process then
		Root = ProcessRecursive(Process, Root, { }, { })
	end
	
	local inspector = setmetatable({
		Depth = Depth,
		Level = 0,
		Buffer = { },
		IDs = { },
		MaxIDs = { },
		NewLine = NewLine,
		Indent = Indent,
		TableAppearances = CountTableAppearances(Root)
	}, InspectorMeta)
	
	inspector:PutValue(Root)
	return CONCAT(inspector.Buffer)
end

setmetatable(Inspect, {
	__call = function(_, ...)
		return Inspect.Inspect(...)
	end
})

return Inspect
