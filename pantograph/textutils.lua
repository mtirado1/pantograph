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
	["()"] = function(x) return "[" .. tostring(tspan(Text.eval(x)))  .. "]" end,
	["sqrt"] = function(x) return "√(" ..  tostring(tspan(Text.eval(x))) .. ")" end,
	["_"] = function(x) return tspan(Text.eval(x), {["font-size"] = "75%", ["baseline-shift"] = "sub"}) end,
	["^"] = function(x) return tspan(Text.eval(x), {["font-size"] = "75%", ["baseline-shift"] = "super"}) end,
	b = function(x) return tspan(Text.eval(x), {["font-weight"] = "bold"}) end,
	bold = function(x) return tspan(Text.eval(x), {["font-weight"] = "bold"}) end,
	i = function(x) return tspan(Text.eval(x), {["font-style"] = "italic"}) end,
	italic = function(x) return tspan(Text.eval(x), {["font-style"] = "italic"}) end,
	large = function(x) return tspan(Text.eval(x), {["font-size"] = "125%"}) end,
	xlarge = function(x) return tspan(Text.eval(x), {["font-size"] = "150%"}) end,
	xxlarge = function(x) return tspan(Text.eval(x), {["font-size"] = "200%"}) end,
	small = function(x) return tspan(Text.eval(x), {["font-size"] = "75%"}) end,
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
	if math.tointeger(n) then
		return tostring(math.tointeger(n))
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

function Text.parseLines(lines, params)
	if type(lines) == "string" then
		lines = { lines }
	else
		lines.align = lines.align or "start"
	end

	local paramCount = 1
	local parsedLines = { align = lines.align, height = lines.height }

	for i, line in ipairs(lines) do
		local parsed
		parsed, paramCount = Text.parse(line, params, paramCount)
		table.insert(parsedLines, parsed)
	end

	return parsedLines
end

function Text.render(x, y, parsedLines, style)
	local content = {}

	for i, line in ipairs(parsedLines) do
		table.insert(content, tspan(Text.eval(line), {
			x = x,
			y = y
		}))
		y = y + style["font-size"] * (parsedLines.height or 1.25)
	end

	local tag = text(x, y, content, style)
	if parsedLines.align then
		tag:set { ["text-anchor"] = parsedLines.align }
	end

	return tag
end

function Text.run(x, y, lines, params, style)
	local content = Text.parseLines(lines, params)
	return Text.render(x, y, content, style)
end

return Text
