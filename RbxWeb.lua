local Players = game:GetService("Players")

local error = error
local format = string.format

local function FastAssert(Condition, ...)
	if not Condition then
		if select("#", ...) > 0 then
			local Success, Result = pcall(format, ...)
			if Success then
				error("[FastAssert] Assertion failed: " .. Result, 2)
			end
		end
		error("[FastAssert] Assertion failed.", 2)
	end
end

local RbxWeb = { }

local DATA_STORE = nil
local DATA_STORES = { }
local YIELD = false
local STANDARD_WAIT = 0.5

local function GetGenericYieldTime()
	return 60 / (60 + #Players:GetPlayers() * 10)
end

local function GetSortYieldTime()
	return 60 / (5 * #Players:GetPlayers() * 2)
end

local function PushGenericQueue(Callback, Yielder)
	if not YIELD then
		YIELD = true
		local Data = { Callback() }
		wait(Yielder())
		YIELD = false
		return unpack(Data)
	else
		wait(STANDARD_WAIT)
		return PushGenericQueue(Callback, Yielder)
	end
end

function RbxWeb.new(DataModel)
	FastAssert(DATA_STORE == nil, "DATA_STORE isn't nil, it is currently set to %q (%s).", tostring(DATA_STORE), typeof(DATA_STORE))
	DATA_STORE = DataModel:GetService("DataStoreService")
end

function RbxWeb:Initialize(DataModel)
	FastAssert(DATA_STORE == nil, "DATA_STORE isn't nil, it is currently set to %q (%s).", tostring(DATA_STORE), typeof(DATA_STORE))
	DATA_STORE = DataModel:GetService("DataStoreService")
end

function RbxWeb:AddGeneric(Key, Scope, Prefix)
	local KeyPrefix = Prefix or ""
	local DataStore = DATA_STORE:GetDataStore(Key, Scope)
	DATA_STORES[DataStore] = KeyPrefix
	return DataStore
end

function RbxWeb:AddOrdered(Key, Scope, Prefix)
	local KeyPrefix = Prefix or ""
	local DataStore = DATA_STORE:GetOrderedDataStore(Key, Scope)
	DATA_STORES[DataStore] = KeyPrefix
	return DataStore
end

function RbxWeb:GetGeneric(DataRoot)
	return setmetatable({
		GetKey = function(self, Data)
			return self.Prefix .. Data
		end,
		
		GetAsync = function(self, Key)
			local Success, Data = PushGenericQueue(function()
				return pcall(DataRoot.GetAsync, DataRoot, Key)
			end, GetGenericYieldTime)
			
			if not Success then
				warn(format("Error in GetAsync for GlobalDataStore %q:\n%s", DataRoot, Data))
			end
			return Success, Data
		end,
		
		NewAsync = function(self, Key, Value)
			local Success, Data = PushGenericQueue(function()
				return pcall(DataRoot.SetAsync, DataRoot, Key, Value)
			end, GetGenericYieldTime)
			
			if not Success then
				warn(format("Error in NewAsync for GlobalDataStore %q:\n%s", DataRoot, Data))
			end
			return Success, Data
		end,
		
		SaveAsync = function(self, Key, Callback)
			local Success, Data = PushGenericQueue(function()
				return pcall(DataRoot.UpdateAsync, DataRoot, Key, Callback)
			end, GetGenericYieldTime)
			
			if not Success then
				warn(format("Error in SaveAsync for GlobalDataStore %q:\n%s", DataRoot, Data))
			end
			return Success, Data
		end,
		
		DeleteAsync = function(self, Key)
			local Success, Data = PushGenericQueue(function()
				return pcall(DataRoot.RemoveAsync, DataRoot, Key)
			end, GetGenericYieldTime)
			
			if not Success then
				warn(format("Error in DeleteAsync for GlobalDataStore %q:\n%s", DataRoot, Data))
			end
			return Success, Data
		end,
		
		IncrementAsync = function(self, Key, Delta)
			local Success, Data = PushGenericQueue(function()
				return pcall(DataRoot.IncrementAsync, DataRoot, Key, Delta)
			end, GetGenericYieldTime)
			
			if not Success then
				warn(format("Error in IncrementAsync for GlobalDataStore %q:\n%s", DataRoot, Data))
			end
			return Success, Data
		end
	}, {
		__index = function(_, Key)
			return ({ Prefix = DATA_STORES[DataRoot] })[Key]
		end
	})
end

function RbxWeb:GetOrdered(DataRoot)
	return setmetatable({
		CollectData = function(self, Ascend)
			local DataTable = { }
			local IsAscending = Ascend or false
			local Success, Data = PushGenericQueue(function()
				return pcall(DataRoot.GetSortedAsync, DataRoot, IsAscending, 100)
			end, GetSortYieldTime)
			
			if not Success then
				warn(format("Error in CollectData for OrderedDataStore %q:\n%s", DataRoot, Data))
				return Success, Data
			else
				while true do
					local PageSuccess, PageData = pcall(Data.GetCurrentPage, Data)
					if PageSuccess then
						for Index, Value in next, PageData do DataTable[Value.key] = Value.value end
						if Data.IsFinished then break end
					else
						warn(format("Error in GetCurrentPage for OrderedDataStore %q:\n%s", DataRoot, PageData))
						return PageSuccess, PageData
					end
					
					local NextPageSuccess, NextPageData = pcall(Data.AdvanceToNextPageAsync, Data)
					if not NextPageSuccess then
						warn(format("Error in AdvanceToNextPageAsync for OrderedDataStore %q:\n%s", DataRoot, NextPageData))
						return NextPageSuccess, NextPageData
					end
				end
			end
			
			return Success, DataTable
		end,
		
		GetKey = function(self, Data)
			return self.Prefix .. Data
		end,
		
		GetAsync = function(self, Key)
			local Success, Data = PushGenericQueue(function()
				return pcall(DataRoot.GetAsync, DataRoot, Key)
			end, GetGenericYieldTime)
			
			if not Success then
				warn(format("Error in GetAsync for OrderedDataStore %q:\n%s", DataRoot, Data))
			end
			return Success, Data
		end,
		
		NewAsync = function(self, Key, Value)
			local Success, Data = PushGenericQueue(function()
				return pcall(DataRoot.SetAsync, DataRoot, Key, Value)
			end, GetGenericYieldTime)
			
			if not Success then
				warn(format("Error in NewAsync for OrderedDataStore %q:\n%s", DataRoot, Data))
			end
			return Success, Data
		end,
		
		SaveAsync = function(self, Key, Callback)
			local Success, Data = PushGenericQueue(function()
				return pcall(DataRoot.UpdateAsync, DataRoot, Key, Callback)
			end, GetGenericYieldTime)
			
			if not Success then
				warn(format("Error in SaveAsync for OrderedDataStore %q:\n%s", DataRoot, Data))
			end
			return Success, Data
		end,
		
		DeleteAsync = function(self, Key)
			local Success, Data = PushGenericQueue(function()
				return pcall(DataRoot.RemoveAsync, DataRoot, Key)
			end, GetGenericYieldTime)
			
			if not Success then
				warn(format("Error in DeleteAsync for OrderedDataStore %q:\n%s", DataRoot, Data))
			end
			return Success, Data
		end,
		
		IncrementAsync = function(self, Key, Delta)
			local Success, Data = PushGenericQueue(function()
				return pcall(DataRoot.IncrementAsync, DataRoot, Key, Delta)
			end, GetGenericYieldTime)
			
			if not Success then
				warn(format("Error in IncrementAsync for OrderedDataStore %q:\n%s", DataRoot, Data))
			end
			return Success, Data
		end
	}, {
		__index = function(_, Key)
			return ({ Prefix = DATA_STORES[DataRoot] })[Key]
		end
	})
end

return RbxWeb
