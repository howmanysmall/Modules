local RunService = game:GetService("RunService")

local assign = require(script.Parent.assign)
local createSignal = require(script.Parent.createSignal)

local GroupMotor = { }
GroupMotor.prototype = { }
GroupMotor.__index = GroupMotor.prototype

local function createGroupMotor(initialValues)
	assert(type(initialValues) == "table")

	local states = { }

	for key, value in next, initialValues do
		states[key] = {
			value = value,
			complete = true
		}
	end

	local self = {
		__goals = { },
		__states = states,
		__allComplete = true,
		__onComplete = createSignal(),
		__onStep = createSignal()
	}

	setmetatable(self, GroupMotor)

	return self
end

function GroupMotor.prototype:start()
	self.__connection = RunService.RenderStepped:Connect(function(dt)
		self:step(dt)
	end)
end

function GroupMotor.prototype:stop()
	if self.__connection ~= nil then
		self.__connection:Disconnect()
	end
end

function GroupMotor.prototype:step(dt)
	assert(type(dt) == "number")

	if self.__allComplete then return end

	local allComplete = true
	local values = { }

	for key, state in next, self.__states do
		if not state.complete then
			local goal = self.__goals[key]

			if goal ~= nil then
				local maybeNewState = goal:step(state, dt)

				if maybeNewState ~= nil then
					state = maybeNewState
					self.__states[key] = maybeNewState
				end
			else
				state.complete = true
			end

			if not state.complete then
				allComplete = false
			end
		end

		values[key] = state.value
	end

	local wasAllComplete = self.__allComplete
	self.__allComplete = allComplete

	self.__onStep:fire(values)

	if allComplete and not wasAllComplete then
		self.__onComplete:fire(values)
	end
end

function GroupMotor.prototype:setGoal(goals)
	assert(type(goals) == "table")

	self.__goals = assign({ }, self.__goals, goals)

	for key in next, goals do
		local state = self.__states[key]

		if not state then
			error(("Cannot set goal for the value %s because it doesn't exist"):format(tostring(key)), 2)
		end

		state.complete = false
	end

	self.__allComplete = false
end

function GroupMotor.prototype:onStep(callback)
	assert(type(callback) == "function")

	return self.__onStep:subscribe(callback)
end

function GroupMotor.prototype:onComplete(callback)
	assert(type(callback) == "function")

	return self.__onComplete:subscribe(callback)
end

function GroupMotor.prototype:destroy()
	self:stop()
end

return createGroupMotor
