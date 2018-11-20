local function assign(target, ...)
	for i = 1, select("#", ...) do
		local source = select(i, ...)

		for key, value in next, source do
			target[key] = value
		end
	end

	return target
end

return assign
