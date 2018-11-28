local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Resources = require(ReplicatedStorage:WaitForChild("Resources"))
local DataStoreService = Resources:LoadLibrary("DataStoreService")
local Debug = Resources:LoadLibrary("Debug")
local Typer = Resources:LoadLibrary("Typer")

local RbxWeb = { }

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

RbxWeb.AddGeneric = Typer.AssignSignature(2, Typer.String, Typer.String, Typer.OptionalString, function(self, Key, Scope, Prefix)
	local KeyPrefix = Prefix or ""
	local DataStore = DataStoreService:GetDataStore(Key, Scope)
	DATA_STORES[DataStore] = KeyPrefix
	return DataStore
end)

RbxWeb.AddOrdered = Typer.AssignSignature(2, Typer.String, Typer.String, Typer.OptionalString, function(self, Key, Scope, Prefix)
	local KeyPrefix = Prefix or ""
	local DataStore = DataStoreService:GetOrderedDataStore(Key, Scope)
	DATA_STORES[DataStore] = KeyPrefix
	return DataStore
end)

RbxWeb.GetGeneric = Typer.AssignSignature(2, Typer.InstanceWhichIsAGlobalDataStore, function(self, DataRoot)
	return setmetatable({
		GetKey = Typer.AssignSignature(2, Typer.PositiveInteger, function(self, Data)
			return self.Prefix .. Data
		end),
		
		GetAsync = Typer.AssignSignature(2, Typer.String, function(self, Key)
			local Success, Data = PushGenericQueue(function()
				return pcall(DataRoot.GetAsync, DataRoot, Key)
			end, GetGenericYieldTime)
			
			if not Success then
				Debug.Warn("Error in GetAsync for GlobalDataStore %q:\n%s", DataRoot, Data)
			end
			return Success, Data
		end),
		
		NewAsync = Typer.AssignSignature(2, Typer.String, Typer.Any, function(self, Key, Value)
			local Success, Data = PushGenericQueue(function()
				return pcall(DataRoot.SetAsync, DataRoot, Key, Value)
			end, GetGenericYieldTime)
			
			if not Success then
				Debug.Warn("Error in NewAsync for GlobalDataStore %q:\n%s", DataRoot, Data)
			end
			return Success, Data
		end),
		
		SaveAsync = Typer.AssignSignature(2, Typer.String, Typer.Function, function(self, Key, Callback)
			local Success, Data = PushGenericQueue(function()
				return pcall(DataRoot.UpdateAsync, DataRoot, Key, Callback)
			end, GetGenericYieldTime)
			
			if not Success then
				Debug.Warn("Error in SaveAsync for GlobalDataStore %q:\n%s", DataRoot, Data)
			end
			return Success, Data
		end),
		
		DeleteAsync = Typer.AssignSignature(2, Typer.String, function(self, Key)
			local Success, Data = PushGenericQueue(function()
				return pcall(DataRoot.RemoveAsync, DataRoot, Key)
			end, GetGenericYieldTime)
			
			if not Success then
				Debug.Warn("Error in DeleteAsync for GlobalDataStore %q:\n%s", DataRoot, Data)
			end
			return Success, Data
		end),
		
		IncrementAsync = Typer.AssignSignature(2, Typer.String, Typer.Integer, function(self, Key, Delta)
			local Success, Data = PushGenericQueue(function()
				return pcall(DataRoot.IncrementAsync, DataRoot, Key, Delta)
			end, GetGenericYieldTime)
			
			if not Success then
				Debug.Warn("Error in IncrementAsync for GlobalDataStore %q:\n%s", DataRoot, Data)
			end
			return Success, Data
		end)
	}, {
		__index = function(_, Key)
			return ({ Prefix = DATA_STORES[DataRoot] })[Key]
		end
	})
end)

RbxWeb.GetOrdered = Typer.AssignSignature(2, Typer.InstanceWhichIsAOrderedDataStore, function(self, DataRoot)
	return setmetatable({
		CollectData = Typer.AssignSignaure(2, Typer.OptionalBoolean, function(self, Ascend)
			local DataTable = { }
			local IsAscending = Ascend or false
			local Success, Data = PushGenericQueue(function()
				return pcall(DataRoot.GetSortedAsync, DataRoot, IsAscending, 100)
			end, GetSortYieldTime)
			
			if not Success then
				Debug.Warn("Error in CollectData for OrderedDataStore %q:\n%s", DataRoot, Data)
				return Success, Data
			else
				while true do
					local PageSuccess, PageData = pcall(Data.GetCurrentPage, Data)
					if PageSuccess then
						for Index, Value in next, PageData do DataTable[Value.key] = Value.value end
						if Data.IsFinished then break end
					else
						Debug.Warn("Error in GetCurrentPage for OrderedDataStore %q:\n%s", DataRoot, PageData)
						return PageSuccess, PageData
					end
					
					local NextPageSuccess, NextPageData = pcall(Data.AdvanceToNextPageAsync, Data)
					if not NextPageSuccess then
						Debug.Warn("Error in AdvanceToNextPageAsync for OrderedDataStore %q:\n%s", DataRoot, NextPageData)
						return NextPageSuccess, NextPageData
					end
				end
			end
			
			return Success, DataTable
		end),
		
		GetKey = Typer.AssignSignature(2, Typer.PositiveInteger, function(self, Data)
			return self.Prefix .. Data
		end),
		
		GetAsync = Typer.AssignSignature(2, Typer.String, function(self, Key)
			local Success, Data = PushGenericQueue(function()
				return pcall(DataRoot.GetAsync, DataRoot, Key)
			end, GetGenericYieldTime)
			
			if not Success then
				Debug.Warn("Error in GetAsync for OrderedDataStore %q:\n%s", DataRoot, Data)
			end
			return Success, Data
		end),
		
		NewAsync = Typer.AssignSignature(2, Typer.String, Typer.Any, function(self, Key, Value)
			local Success, Data = PushGenericQueue(function()
				return pcall(DataRoot.SetAsync, DataRoot, Key, Value)
			end, GetGenericYieldTime)
			
			if not Success then
				Debug.Warn("Error in NewAsync for OrderedDataStore %q:\n%s", DataRoot, Data)
			end
			return Success, Data
		end),
		
		SaveAsync = Typer.AssignSignature(2, Typer.String, Typer.Function, function(self, Key, Callback)
			local Success, Data = PushGenericQueue(function()
				return pcall(DataRoot.UpdateAsync, DataRoot, Key, Callback)
			end, GetGenericYieldTime)
			
			if not Success then
				Debug.Warn("Error in SaveAsync for OrderedDataStore %q:\n%s", DataRoot, Data)
			end
			return Success, Data
		end),
		
		DeleteAsync = Typer.AssignSignature(2, Typer.String, function(self, Key)
			local Success, Data = PushGenericQueue(function()
				return pcall(DataRoot.RemoveAsync, DataRoot, Key)
			end, GetGenericYieldTime)
			
			if not Success then
				Debug.Warn("Error in DeleteAsync for OrderedDataStore %q:\n%s", DataRoot, Data)
			end
			return Success, Data
		end),
		
		IncrementAsync = Typer.AssignSignature(2, Typer.String, Typer.Integer, function(self, Key, Delta)
			local Success, Data = PushGenericQueue(function()
				return pcall(DataRoot.IncrementAsync, DataRoot, Key, Delta)
			end, GetGenericYieldTime)
			
			if not Success then
				Debug.Warn("Error in IncrementAsync for OrderedDataStore %q:\n%s", DataRoot, Data)
			end
			return Success, Data
		end)
	}, {
		__index = function(_, Key)
			return ({ Prefix = DATA_STORES[DataRoot] })[Key]
		end
	})
end)

return Resources:LoadLibrary("Table").Lock(RbxWeb)
