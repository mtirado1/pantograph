local variable = require "pantograph.variable"
local textUtils = require "pantograph.textutils"
require "pantograph.mathutils"
require "pantograph.svg"
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
	background = Fill(white),
	margin = Stroke(yellow, 30),
	point = { fill = green, radius = 5},
	largePoint = { fill = darkGreen, radius = 7 },
	line = Stroke(brown, 3),
	grid = Stroke(yellow, 3),
	curve = Stroke(red, 3),
	solid = FillStroke(red, brown, 3),
	construction = Stroke(yellow, 3, {dashArray = "6"}),
	text = Font("Lexend", 20, black, {align = "center", baseline = "center"}),
	title = Font("Lexend", 24, black, {align = "center", baseline = "center", weight = "bold"}),
	textOffset = 20,
	red = Fill(red),
	blue = Fill(blue),
	blueStroke = Stroke(blue, 3),
	green = Fill(green),
	brown = Fill(brown),
	yellow = Fill(yellow),
	gray = Fill(gray)
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

function Canvas:renderStyle(element, default)
	if type(element.style) == "string" then
		return self.style[element.style] or self.style[default]
	elseif element.style then
		return element.style
	else
		return self.style[default]
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
	local points = element.points
	
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
		mid = points[lastPoint]:eval() + tSegment * (points[1]:eval() - points[lastPoint]:eval())
	else
		mid = points[lastPoint]:eval() + tSegment * (points[lastPoint + 1]:eval() - points[lastPoint]:eval())
	end
	table.insert(transformed, self:transform(mid))
	return polyline(transformed, self:renderStyle(element, "line"))
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
	local svgObject
	local k = kind(element)
	if k == "point" then
		local drawn = variable.value(element.drawn)
		local c = self:transform(element)
		if c == nil then return nil end
		local style = self:renderStyle(element, "point")
		local r = style.radius
		style = Fill(style.fill)
		svgObject = circle(c.x, c.y, drawn * r, style)
	elseif k == "segment" then
		local a, b, defined = resolveValues(element.a, element.b)
		if not defined then
			return nil
		end
		local drawn = variable.value(element.drawn)
		local p1 = self:transform(a)
		local p2 = self:transform(a + drawn * (b - a))

		svgObject = line(p1, p2, self:renderStyle(element, "line"))

		local angle = math.deg(math.atan2(p2.y - p1.y, p2.x - p1.x))

		if element.marker then
			svgObject = group {
				svgObject,
				path {
					d = "M -6 -4 V 4 L 6 0 Z",
					transform = string.format("translate(%s,%s) rotate(%s)", p2.x, p2.y, angle),
					fill = svgObject.attributes.stroke
				}
			}
		end
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
		svgObject = line(p1, p2, self:renderStyle(element, "line"))
	elseif k == "polyline" then
		svgObject = self:drawPolyline(element, false)
	elseif k == "polygon" then
		local transformed = {}
		local drawn = variable.value(element.drawn)
		if drawn == 1 then
			for i, point in ipairs(element.points) do
				transformed[i] = self:transform(point)
			end
			svgObject = polygon(transformed, self:renderStyle(element, "line"))
		else
			svgObject = self:drawPolyline(element, true)
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
				return self:transform(center + (radius - center):rotate(t))
			end
		else
			f = function(t)
				return self:transform(center + Polar(radius, t))
			end
		end

		local style = self:renderStyle(element, "line")
		svgObject = path(style):curve(0, drawn * 2 * math.pi, f, 12)
	elseif k == "angle" then
		local a, center, angle, defined = resolveValues(element.a, element.center, element.angle)
		if not defined then
			return nil
		end

		local a_delta = (a - center):unitVector() * 0.5
		local drawn = variable.value(element.drawn)

		local f = function(t)
			return self:transform(center + a_delta:rotate(t))
		end

		local style = self:renderStyle(element, "line")
		svgObject = path(style):curve(0, drawn * angle, f, 12)
	elseif k == "curve" then
		local start = variable.value(element.start)
		local stop = variable.value(element.stop)
		local drawn = variable.value(element.drawn)
		local curve = variable.value(element.curve)

		local f
		if type(variable.value(curve(start))) == "number" then
			f = function(t)
				return self:transform(Vector(t, variable.value(curve(t))))
			end
		else
			f = function(t)
				return self:transform(curve(t))
			end
		end

		local style = self:renderStyle(element, "curve")
		local N = element.nodes or 60
		local points = {}
		for i = 1, N do
			local t = (i - 1) / (N - 1)
			points[i] = f(start + drawn * (stop - start) * t)
		end
		--svgObject = path(style):curve(start, start + drawn * (stop - start), f, 30)
		svgObject = polyline(points, style)
	elseif k == "group" then
		local rendered = {}
		local drawn = variable.value(element.drawn)
		for i, subElement in ipairs(element.elements) do
			subElement.drawn:set(drawn)
			local svgElement = self:draw(subElement)
			if svgElement then
				table.insert(rendered, svgElement)
			end
		end
		svgObject = group(rendered)
	elseif k == "composite" then
		local rendered = {}
		for i, subElement in ipairs(element.elements) do
			local svgElement = self:draw(subElement)
			if svgElement then
				table.insert(rendered, svgElement)
			end
		end
		svgObject = group(rendered)
	elseif k == "image" then
		local center, href, width, height, defined = resolveValues(element.center, element.href, element.width, element.height)
		if not defined then
			return nil
		end

		center = self:transform(center)
		local scale = variable.value(self.camera.scale)
		width = width * scale
		height = height * scale

		svgObject = Element:new("image", {
			href = href,
			x = center.x - width/2,
			y = center.y - height/2,
			width = width,
			height = height
		})
	elseif k == "equation" then
		local center, defined = resolveValues(element.center)
		local equation = element.equation

		if not defined then
			return nil
		end

		local c = self:transform(center)
		local eq = element.equation:gsub("rgb%(0%%,0%%,0%%%)", black)
		svgObject = rawSvg(c.x - element.width / 2, c.y - element.height / 2, eq)
	elseif k == "text" then
		local center, defined = resolveValues(element.center)
		if not defined then
			return nil
		end

		center = self:transform(center)
		local style = self:renderStyle(element, "text")
		local drawn = variable.value(element.drawn)

		svgObject = textUtils.render(center.x, center.y, element.text, style)
		svgObject:set { opacity = drawn }
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

			if element.text then
				svgObject = textUtils.render(x, y, element.text, style)
			else
				svgObject = textUtils.run(x, y, "[]", { obj }, style)
			end

			local drawn = variable.value(element.drawn)
			svgObject:set { opacity = drawn }
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

			if element.text then
				svgObject = textUtils.render(x, y, element.text, style)
			else
				svgObject = textUtils.run(x, y, "[]", {(b - a):length()}, style)
			end

			local drawn = variable.value(element.drawn)
			svgObject:set { opacity = drawn }
			--svgObject:set { transform = string.format("rotate(%.2f, %.2f, %.2f)", -math.deg(angle), x, y) }
		elseif objKind == "angle" then
			local a, center, b, angle, defined = resolveValues(obj.a, obj.center, obj.b, obj.angle)
			if not defined then
				return nil
			end

			local midpoint = center + ((a - center):unitVector() * 0.6):rotate(angle / 2)
			local center = self:transform(midpoint)

			local x, y = center.x, center.y
			if element.text then
				svgObject = textUtils.render(x, y, element.text, style)
			else
				local degrees = math.deg(math.abs(angle))
				svgObject = textUtils.run(x, y, "[][deg]", { degrees }, style)
			end

			local drawn = variable.value(element.drawn)
			svgObject:set { opacity = drawn }
		else
			error(string.format("Cannot label '%s' element."))
		end
	end

	local opacity = variable.value(element.opacity)
	if opacity ~= 1 then
		svgObject:set { opacity = opacity }
	end

	return svgObject
end

function Canvas:render()
	local c = svg(self.width, self.height) {
		fill(self.style.background),
	}

	local layers = {}
	for i, name in ipairs(self.layers or {}) do
		local g = group()
		layers[name] = g
		c:add(g)
	end

	for i, e in ipairs(self.elements) do
		local rendered = self:draw(e)
		if rendered then
			local layerName = e.layer or "main"
			if layers[layerName] then
				layers[layerName]:add(rendered)
			else
				c:add(rendered)
			end
		end
	end

	c:add(fill(self.style.margin))

	return c:render()
end

return {
	Canvas = Canvas,
	colors = colors
}
