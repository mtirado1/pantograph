local variable = require "pantograph.variable"
local textUtils = require "pantograph.textutils"
require "pantograph.mathutils"
require "pantograph.vector"

-- Compatibility with LuaJIT
table.unpack = table.unpack or unpack

Canvas = {}
Canvas.__index = Canvas

local white = "#fff0cf"
local black = "#453035"
local gray = "#746363"
local red = "#de765c" 
local blue = "#68c3b7"
local brown = "#904236"
local green = "#5f9e8c"
local darkGreen = "#466a60"
local yellow = "#ffbc7d"

local colors = {
	white = white,
	black = black,
	gray = gray,
	red = red,
	blue = blue,
	brown = brown,
	green = green,
	darkGreen = darkGreen,
	yellow = yellow,
}

Canvas.style = {
	background = { fill = white },
	point = { fill = green, radius = 5},
	largePoint = { fill = darkGreen, radius = 7 },
	line = { stroke = brown, width = 3 },
	grid = { stroke = yellow, width = 3 },
	curve = { stroke = red, width = 3 },
	solid = { fill = red, stroke = brown, width = 3 },
	construction = { stroke = yellow, width = 3, dash = { 6 } },
	text = { font = "Lexend", size = 20, color = black, align = "center", baseline = "center" },
	title = { font = "Lexend", size = 24, color = black, align = "center", baseline = "center", weight = "bold" },
	textOffset = 20,
	red = { fill = red },
	blue = { fill = blue },
	blueStroke = { stroke = blue, width = 3 },
	green = { fill = green },
	brown = { fill = brown },
	yellow = { fill = yellow },
	gray = { fill = gray }
}

-- Converts a point to a SVG plane, the most basic transformation before plotting
function Canvas:transform(p)
	p = variable.value(p)
	if not p then
		return nil
	end
	local scale = variable.value(self.camera.scale)
	local zAngle = variable.value(self.camera.zAngle)
	local xAngle = variable.value(self.camera.xAngle)
	local yAngle = variable.value(self.camera.yAngle)
	local perspective
	if self.camera.perspective then
		perspective = variable.value(self.camera.perspective)
	end

	p = p:rotate(zAngle):rotateY(yAngle):rotateX(xAngle)

	if perspective then
		local k = perspective / (perspective - p.z)
		p.x = p.x * k
		p.y = p.y * k
	end

	return {
		x = p.x * scale + self.width / 2,
		y = -p.y * scale + self.height / 2
	}
end

function Canvas:new(width, height)
	local canvas = {
		width = width,
		height = height,
		elements = {},
		elementIndex = {},
		layers = nil,
		camera = {
			zAngle = variable:new(0),
			xAngle = variable:new(0),
			yAngle = variable:new(0),
			perspective = nil,
			scale = variable:new(50)
		}
	}
	return setmetatable(canvas, Canvas)
end

function Canvas:setLayers(layers)
	if #layers == 0 then
		layers = nil
	end
	self.layers = layers
end

function Canvas:configureElement(e)
	if not e.drawn then
		e.drawn = variable:new(1)
	end
	if not e.opacity then
		e.opacity = variable:new(1)
	end

	if e.elements then
		for i, subElement in ipairs(e.elements) do
			self:configureElement(subElement)
		end
	end
end

function Canvas:add(...)
	for i, e in ipairs {...} do
		if not self.elementIndex[e] then
			self.elementIndex[e] = true
			self:configureElement(e)
			table.insert(self.elements, e)
		end
	end
end

function Canvas:remove(...)
	local toBeRemoved = {...}

	for i, toRemove in ipairs(toBeRemoved) do
		if self.elementIndex[toRemove] then
			for j, element in ipairs(self.elements) do
				if toRemove == element then
					self.elementIndex[element] = nil
					table.remove(self.elements, j)
				end
			end
		end
	end
end

local function clone(o)
	local cloned = {}
	for k, v in pairs(o) do
		cloned[k] = v
	end
	return cloned
end

function Canvas:renderStyle(element, default)
	if type(element.style) == "string" then
		return clone(self.style[element.style] or self.style[default])
	elseif element.style then
		return clone(element.style)
	else
		return clone(self.style[default])
	end
end

local function perimeter(points, n)
	n = n or #points

	local p = 0
	for i = 1, n do
		local next = i % #points + 1
		local s = (variable.value(points[next]) - variable.value(points[i])):length()
		p = p + s
	end
	return p
end

function Canvas:drawPolyline(element, isPolygon)
	local drawn = variable.value(element.drawn)
	local points = variable.value(element.points)
	
	local P, p = perimeter(points, isPolygon and #points or (#points - 1)), 0
	local lastPoint, lastSegment

	for i = 1, #points do
		lastSegment = (variable.value(points[i]) - variable.value(points[i % #points + 1])):length()
		if p + lastSegment > P * drawn then
			lastPoint = i
			break
		end

		p = p + lastSegment
	end


	local tSegment = (drawn * P - p) / lastSegment

	local transformed = {}
	for i = 1, lastPoint do
		table.insert(transformed, self:transform(points[i]))
	end
	local mid
	if lastPoint == #points then
		mid = variable.value(points[lastPoint]) + tSegment * (variable.value(points[1]) - variable.value(points[lastPoint]))
	else
		mid = variable.value(points[lastPoint]) + tSegment * (variable.value(points[lastPoint + 1]) - variable.value(points[lastPoint]))
	end
	table.insert(transformed, self:transform(mid))

	return {
		type = "line",
		points = transformed,
		style = self:renderStyle(element, "line")
	}
end

function Canvas:getCurve(curve, start, stop, N)
	local points = {}
	for i = 1, N do
		local t = start + (stop - start) * (i - 1) / (N - 1)
		table.insert(points, self:transform(curve(t)))
	end

	return points
end

local function resolveValues(...)
	local result = {}
	local defined = true
	for i, var in ipairs{...} do
		local value = variable.value(var)
		defined = value and defined
		table.insert(result, value)
	end
	table.insert(result, defined)
	return table.unpack(result)
end

function Canvas:draw(element)
	local object
	local k = kind(element)
	if k == "point" then
		local drawn = variable.value(element.drawn)
		local c = self:transform(element)
		if c == nil then return nil end
		local style = self:renderStyle(element, "point")
		local r = style.radius

		object = {
			type = "circle",
			center = c,
			radius = drawn * r,
			style = style
		}
	elseif k == "segment" then
		local a, b, defined = resolveValues(element.a, element.b)
		if not defined then
			return nil
		end
		local drawn = variable.value(element.drawn)
		local p1 = self:transform(a)
		local p2 = self:transform(a + drawn * (b - a))

		object = {
			type = "line",
			points = { p1, p2 },
			style = self:renderStyle(element, "line"),
			pointer = element.marker
		}
	elseif k == "line" then
		local a, b, defined = resolveValues(element.a, element.b)
		if not defined then
			return nil
		end
		local drawn = variable.value(element.drawn)
		local delta = 3 * (b - a)
		a = a - delta
		b = b + delta
		local p1 = self:transform(a)
		local p2 = self:transform(a + drawn * (b - a))

		object = {
			type = "line",
			points = { p1, p2 },
			style = self:renderStyle(element, "line")
		}
	elseif k == "polyline" then
		object = self:drawPolyline(element, false)
	elseif k == "polygon" then
		local transformed = {}
		local drawn = variable.value(element.drawn)
		if drawn == 1 then
			local points = variable.value(element.points)
			for i, point in ipairs(points) do
				transformed[i] = self:transform(point)
			end
			object = {
				type = "polygon",
				points = transformed,
				style = self:renderStyle(element, "line")
			}
		else
			object = self:drawPolyline(element, true)
		end
	elseif k == "circle" then
		local center, radius, defined = resolveValues(element.center, element.radius)
		if not defined then
			return nil
		end
		local drawn = variable.value(element.drawn)

		local f
		if type(radius) ~= "number" then
			f = function(t)
				return center + (radius - center):rotate(t)
			end
		else
			f = function(t)
				return center + Polar(radius, t)
			end
		end

		local style = self:renderStyle(element, "line")
		object = {
			type = "line",
			points = self:getCurve(f, 0, drawn * 2 * math.pi, 120),
			style = style
		}
	elseif k == "angle" then
		local a, center, angle, defined = resolveValues(element.a, element.center, element.angle)
		if not defined then
			return nil
		end

		local a_delta = (a - center):unitVector() * 0.5
		local drawn = variable.value(element.drawn)

		local f = function(t)
			return center + a_delta:rotate(t)
		end

		local style = self:renderStyle(element, "line")
		object = {
			type = "line",
			points = self:getCurve(f, 0, drawn * angle, 120),
			style = style
		}
	elseif k == "curve" then
		local start = variable.value(element.start)
		local stop = variable.value(element.stop)
		local drawn = variable.value(element.drawn)
		local curve = variable.value(element.curve)

		local f
		if type(variable.value(curve(start))) == "number" then
			f = function(t)
				return Vector(t, variable.value(curve(t)))
			end
		else
			f = curve
		end

		local style = self:renderStyle(element, "curve")
		local N = element.nodes or math.max(2, math.ceil(math.abs(stop - start) * 20))

		object = {
			type = "line",
			points = self:getCurve(f, start, start + drawn * (stop - start), N),
			style = style
		}
	elseif k == "group" then
		local rendered = {}
		local drawn = variable.value(element.drawn)
		for i, subElement in ipairs(element.elements) do
			subElement.drawn:set(drawn)
			local object = self:draw(subElement)
			if object then
				table.insert(rendered, object)
			end
		end
		object = {
			type = "group",
			elements = rendered
		}
	elseif k == "composite" then
		local rendered = {}
		for i, subElement in ipairs(element.elements) do
			local object = self:draw(subElement)
			if object then
				table.insert(rendered, object)
			end
		end
		object = {
			type = "group",
			style = {},
			elements = rendered
		}
	elseif k == "image" then
		-- TODO
	elseif k == "equation" then
		local center, defined = resolveValues(element.center)
		local equation = element.equation
		local drawn = variable.value(element.drawn)

		if not defined then
			return nil
		end

		local c = self:transform(center)
		object = {
			type = "equation",
			drawn = drawn,
			color = black,
			center = c,
			equation = equation
		}
	elseif k == "text" then
		local center, defined = resolveValues(element.center)
		if not defined then
			return nil
		end

		center = self:transform(center)
		local style = self:renderStyle(element, "text")
		local drawn = variable.value(element.drawn)

		object = {
			type = "text",
			center = center,
			drawn = drawn,
			text = textUtils.eval(element.text),
			style = style
		}
	elseif k == "label" then
		local obj, defined = resolveValues(element.obj)
		if not defined then
			return nil
		end

		local offset = self.style.textOffset

		local objKind = kind(obj)
		local style = self:renderStyle(element, "text")
		if objKind == "point" then
			local center = self:transform(obj)
			local x, y = center.x, center.y - offset
			local drawn = variable.value(element.drawn)

			local text
			if element.text then
				text = textUtils.eval(element.text)
			else
				text = textUtils.eval(textUtils.parse("[]", { obj }))
			end

			object = {
				type = "text",
				center = { x = x, y = y },
				drawn = drawn,
				text = text,
				style = style
			}
		elseif objKind == "line" or objKind == "segment" then
			local a, b, defined = resolveValues(obj.a, obj.b)
			if not defined then
				return nil
			end

			local a, b = variable.value(obj.a), variable.value(obj.b)
			local center = self:transform((a + b) / 2)

			local a_t = self:transform(a)
			local b_t = self:transform(b)
			-- Don't render labels if the segments are not visible
			if math.sqrt((a_t.x - b_t.x)^2 + (a_t.y - b_t.y)^2) <= 0.1 then
				return nil
			end

			local angle = math.atan2(a_t.y - b_t.y, b_t.x - a_t.x)
			local x = center.x - offset * math.sin(angle)
			local y = center.y - offset * math.cos(angle)
			local drawn = variable.value(element.drawn)

			local text
			if element.text then
				text = textUtils.eval(element.text)
			else
				text = textUtils.eval(textUtils.parse("[]", {(b - a):length()}))
			end

			object = {
				type = "text",
				center = { x = x, y = y },
				drawn = drawn,
				text = text,
				style = style
			}
		elseif objKind == "angle" then
			local a, center, b, angle, defined = resolveValues(obj.a, obj.center, obj.b, obj.angle)
			if not defined then
				return nil
			end

			local midpoint = center + ((a - center):unitVector() * 0.6):rotate(angle / 2)
			local center = self:transform(midpoint)
			local drawn = variable.value(element.drawn)

			local text
			if element.text then
				text = textUtils.eval(element.text)
			else
				local degrees = math.deg(math.abs(angle))
				text = textUtils.eval(textUtils.parse("[][deg]", { degrees }))
			end

			object = {
				type = "text",
				center = center,
				text = text,
				drawn = drawn,
				style = style
			}
		else
			error(string.format("Cannot label '%s' element.", objKind))
		end
	end

	local opacity = variable.value(element.opacity)
	if opacity ~= 1 then
		object.style.opacity = opacity
	end

	return object
end

function Canvas:render()
	local canvas = {
		width = self.width,
		height = self.height
	}

	table.insert(canvas, {
		type = "fill",
		style = self.style.background
	})

	local layers = {}
	for i, name in ipairs(self.layers or {}) do
		local g = { type = "group", elements = {} }
		layers[name] = g
		table.insert(canvas, g)
	end

	for i, e in ipairs(self.elements) do
		local rendered = self:draw(e)
		if rendered then
			local layerName = e.layer or "main"
			if layers[layerName] then
				table.insert(layers[layerName].elements, rendered)
			else
				table.insert(canvas, rendered)
			end
		end
	end

	return canvas
end

return {
	Canvas = Canvas,
	colors = colors
}
