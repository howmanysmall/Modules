local function validateMotor(motor)
	assert(type(motor) == "table")
	assert(type(motor.start) == "function")
	assert(type(motor.stop) == "function")
	assert(type(motor.step) == "function")
	assert(type(motor.setGoal) == "function")
	assert(type(motor.onStep) == "function")
	assert(type(motor.onComplete) == "function")
	assert(type(motor.destroy) == "function")
end

return validateMotor
