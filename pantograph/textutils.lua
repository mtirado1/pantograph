local variable = require "pantograph.variable"

local Text = {}

local TextReplacements = {
	alpha = "α",
	beta = "β",
	delta = "δ", Delta = "Δ",
	epsilon = "ε",
	lambda = "λ",
	phi = "φ",
	pi = "π", Pi = "Π",
	tau = "τ",
	theta = "θ",
	sigma = "σ", Sigma = "Σ",
	deg = "°",
	approx = "≈",
	neq = "≠",
	geq = "≥",
	leq = "≤",
	pm = "±",
	dot = "·",
	["("] = "[",
	[")"] = "]",
	["()"] = function(x) return "[" .. Text.eval(x)  .. "]" end,
	["sqrt"] = function(x) return "√(" .. Text.eval(x) .. ")" end,
}

function Text.parse(s, params, paramCount)
	paramCount = paramCount or 1
	local components = {}

	local a, b = s:find("%b[]")
	local index = 1
	while a do
		local command = s:sub(a, b)
		local prev = s:sub(index, a - 1)
		if #prev > 0 then
			table.insert(components, prev)
		end

		if command == "[]" then
			table.insert(components, {value = params[paramCount], precision = 2})
			paramCount = paramCount + 1
		elseif command:find("^%[%.%d+%]$") then
			local precision = tonumber(command:match("%d+"))
			table.insert(components, {value = params[paramCount], precision = precision})
			paramCount = paramCount + 1
		else
			local cmd, args = command:match("%[([^%s%[%]%d]+)%s*(.*)%]")
			local replace = TextReplacements[cmd]
			if type(replace) == "string" then
				table.insert(components, replace)
			else
				local arg
				arg, paramCount = Text.parse(args, params, paramCount)
				table.insert(components, {
					func = replace,
					arg = arg
				})
			end
		end

		index = b + 1
		a, b = s:find("%b[]", index)
	end

	local last = s:sub(index)
	if #last > 0 then
		table.insert(components, last)
	end
	
	return components, paramCount
end

-- truncates to precision if required
local function formatNumber(n, precision)
	local s = tostring(n)
	if math.floor(n) == n then
		return tostring(n)
	else
		local decimals = s:match("%.(%d+)$")
		return string.format("%." .. precision .. "f", n)
	end
end

local function formatValue(x, precision, is3D)
	local value = variable.value(x)
	if type(value) == "number" then
		return formatNumber(value, precision)
	elseif value.x then
		if is3D then
			return string.format("(%s, %s, %s)", formatNumber(value.x, precision), formatNumber(value.y, precision), formatNumber(value.z, precision))
		else
			return string.format("(%s, %s)", formatNumber(value.x, precision), formatNumber(value.y, precision))
		end
	end

	return tostring(value)
end

function Text.eval(components)
	local result = {}
	for i, component in ipairs(components) do
		if type(component) == "string" then
			table.insert(result, component)
		elseif component.value then
			table.insert(result, formatValue(component.value, component.precision))
		elseif component.func then
			table.insert(result, component.func(component.arg))
		else
			table.insert(result, "[???]")
		end
	end

	return result
end

return Text
