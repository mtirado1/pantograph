
local function formatNumber(n)
	if math.floor(n) == n then
		return tostring(n)
	else
		return string.format("%.2f", n)
	end
end

Element = {}
Element.__index = Element

function Element:new(tag, attributes, children)
	local copy = {}
	for k, v in pairs(attributes or {}) do
		copy[k] = v
	end
	local e = {
		tag = tag,
		attributes = copy,
		children = children or {}
	}
	return setmetatable(e, Element)
end

function Element:add(elements)
	self.children = self.children or {}
	if not elements[1] then
		table.insert(self.children, elements)
		return self
	end
	for i, e in ipairs(elements) do
		table.insert(self.children, e)
	end
	return self
end

function Element:set(attributes)
	for key, value in pairs(attributes) do
		self.attributes[key] = value
	end
	return self
end

function Element:render()
	local s = "<" .. self.tag
	for attribute, value in pairs(self.attributes or {}) do
		local textValue = tostring(value)
		if type(value) == "number" then
			textValue = formatNumber(value)
		end
		s = string.format([[%s %s="%s"]], s, attribute, textValue)
	end
	if #self.children == 0 and not self.text then
		return s .. "/>"
	else
		s = s .. ">"
		if self.text then
			for i, textNode in ipairs(self.text) do
				if type(textNode) == "string" then
					s = s .. textNode
				else
					s = s .. textNode:render()
				end
			end
		end
		if #self.children > 0 then
			for i, child in ipairs(self.children) do
				s = s .. "\n" .. child:render()
			end
			s = s .. "\n"
		end
		return s .. "</" .. self.tag .. ">"
	end
end

function Element:save(filename)
	local file = io.open(filename, "w")
	file:write(self:render())
	file:close()
end

function Element.__tostring(e)
	return e:render()
end

function svg(width, height)
	return function(children)
		local canvas = Element:new("svg", {
			xmlns = "http://www.w3.org/2000/svg",
			['xmlns:xlink'] = "http://www.w3.org/1999/xlink",
			width = width,
			height = height
		})
		canvas.children = children
		return canvas
	end
end

function rawSvg(x, y, content)
	local e = Element:new("svg", {
		x = x, y = y
	})

	e.text = { content }
	return e
end

function line(p1, p2, attributes)
	return Element:new("line", {
		x1 = p1.x,
		y1 = p1.y,
		x2 = p2.x,
		y2 = p2.y
	}):set(attributes or {})
end

function polyline(data, attr)
	local points = {}
	local attributes = {}
	for k, v in pairs(attr) do
		attributes[k] = v
	end
	for i, v in pairs(data) do
		if type(i) == "number" then
			table.insert(points, formatNumber(v.x) .. " " .. formatNumber(v.y))
		else
			attributes[i] = v
		end
	end
	attributes.points = table.concat(points, " ")
	return Element:new("polyline", attributes)
end

function polygon(data, attr)
	local points = {}
	local attributes = {}
	for k, v in pairs(attr or {}) do
		attributes[k] = v
	end
	for i, v in pairs(data) do
		if type(i) == "number" then
			table.insert(points, formatNumber(v.x) .. " " .. formatNumber(v.y))
		else
			attributes[i] = v
		end
	end
	attributes.points = table.concat(points, " ")
	return Element:new("polygon", attributes)
end

function rect(x, y, width, height, attributes)
	return Element:new("rect", {
		x = x,
		y = y,
		width = width,
		height = height
	}):set(attributes)
end

function circle(x, y, r, attributes)
	return Element:new("circle", {
		cx = x,
		cy = y,
		r = r
	}):set(attributes or {})
end

function ellipse(cx, cy, rx, ry, attributes)
	return Element:new("ellipse", {
		cx = cx,
		cy = cy,
		rx = rx,
		ry = ry
	}):set(attributes or {})
end

function use(href, attributes)
	local attributes = attributes or {}
	attributes["xlink:href"] = href
	return Element:new("use", attributes)
end

function defs(children)
	return Element:new("defs", {}, children)
end

function style(text)
	local e = Element:new("style")
	e.text = {"\n" .. text}
	return e
end

function group(data)
	data = data or {}
	local children = {}
	local attributes = {}
	for i, v in pairs(data) do
		if type(i) == "number" then
			children[i] = v
		else
			attributes[i] = v
		end
	end
	
	return Element:new("g", attributes, children)
end

local Path = {}
Path.__index = function(self, key)
	if Path[key] then return Path[key] end
	return Element[key]
end

Path.__tostring = Element.__tostring

function Path:command(letter, ...)
	local arguments = {}
	for i, a in ipairs { ... } do
		if type(a) == "number" then
			table.insert(arguments, formatNumber(a))
		else
			table.insert(arguments, tostring(a))
		end
	end
	self.attributes.d = self.attributes.d .. letter .. table.concat(arguments, " ")
	return self
end

function Path:M(x, y) return self:command("M", x, y) end
function Path:L(x, y) return self:command("L", x, y) end
function Path:A(rx, ry, rotation, largeArc, sweep, x, y)
	if largeArc then largeArc = 1
	else largeArc = 0 end
	if sweep then sweep = 1
	else sweep = 0 end
	return self:command("A", rx, ry, rotation, largeArc, sweep, x, y)
end
function Path:H(x) return self:command("H", x) end
function Path:h(dx) return self:command("h", dx) end
function Path:V(y) return self:command("V", y) end
function Path:v(dy) return self:command("v", dy) end

function Path:C(x1, y1, x2, y2, x, y) return self:command("C", x1, y1, x2, y2, x, y) end
function Path:S(x2, y2, x, y) return self:command("S", x2, y2, x, y) end

function Path:Z() return self:command("Z") end

function Path:arc(x, y, rx, ry, startAngle, endAngle, clockwise, command)
	if clockwise == nil then
		clockwise = true
	end
	command = command or "M"

	local isLargeArc = math.abs(endAngle - startAngle) > math.pi
	if not clockwise then
		startAngle, endAngle = endAngle, startAngle
	end
	local start = Point(
		x + rx * math.cos(startAngle),
		y + ry * math.sin(startAngle)
	)
	local stop = Point(
		x + rx * math.cos(endAngle),
		y + ry * math.sin(endAngle)
	)
	self:command(command, start.x, start.y)
	return self:A(rx, ry, 0, isLargeArc, clockwise, stop.x, stop.y)
end

function Path:rect(x, y, w, h)
	if type(x) == "table" then
		local params = x
		x = params.x or 0
		y = params.y or 0
		w = params.w or params.width
		h = params.h or params.height
	end
	return self:M(x, y):h(w):v(h):h(-w):Z()
end

function Path:circle(x, y, r, clockwise)
	if type(x) == "table" then
		local params = x
		x = params.x or 0
		y = params.y or 0
		r = params.r
		clockwise = params.clockwise
	end

	if clockwise == nil then
		clockwise = true
	end
	return self:M(x + r, y)
		:A(r, r, 0, false, clockwise, x - r, y)
		:A(r, r, 0, false, clockwise, x + r, y)
		:Z()
end

function Path:slice(x, y, rx, ry, startAngle, endAngle)
	return self:M(x, y)
		:arc(x, y, rx, ry, startAngle, endAngle, true, "L")
		:Z()
end

function Path:square(x, y, r)
	if type(x) == "table" then
		local table = x
		x = table.x or 0
		y = table.y or 0
		r = table.r
	end
	return self:rect(x - r/2, y - r/2, r, r)
end

function Path:ring(x, y, r, width)
	return self:circle(x, y, r):circle(x, y, r + width, false)
end

function Path:ringSector(x, y, rx, ry, width, startAngle, endAngle)
	if type(x) == "table" then
		local params = x
		x = params.x or 0
		y = params.y or 0
		rx = params.rx or params.r
		ry = params.ry or params.r
		width = params.width
		startAngle = params.startAngle
		endAngle = params.endAngle
	end
	if endAngle < startAngle then
		endAngle, startAngle = startAngle, endAngle
	end
	return self:arc(x, y, rx + width, ry + width, startAngle, endAngle, true)
		:arc(x, y, rx, ry, startAngle, endAngle, false, "L")
		:Z()
end

function Path:star(x, y, radius, corners, ratio, angle)
	if type(radius) == "table" then
		local params = radius
		x = params.x or 0
		y = params.y or 0
		radius = params.radius or params.r
		corners = params.corners
		ratio = params.ratio
		angle = params.angle
	end

	local points = {}
	for i = 0, corners * 2 - 1 do
		local a = angle + math.pi * i / corners
		if i % 2 == 0 then
			table.insert(points, Point(
				x + radius * math.cos(a),
				y + radius * math.sin(a)
			))
		else
			table.insert(points, Point(
				x + ratio * radius * math.cos(a),
				y + ratio * radius * math.sin(a)
			))
		end
	end
	return self:polygon(points)
end

function Path:polygon(points)
	for i, point in ipairs(points) do
		if i == 1 then
			self:M(point.x, point.y)
		else
			self:L(point.x, point.y)
		end
	end
	return self:Z()
end

function Path:curve(start, stop, curve, n, delta)
	if type(start) == "table" then
		local params = start
		start = params.start or 0
		stop = params.stop or 1
		curve = params.curve
		n = params.n
		delta = params.delta
	end

	n = n or 10
	delta = delta or (stop - start) / 1000

	local inc = (stop - start) / (n - 1)
	local k = inc / delta / 3
	local first = true

	local P0, P1, P2, P3

	for t = 0, n - 2 do
		if first then
			local t1 = start + t * inc
			local f1 = curve(t1 + delta)
			P0 = curve(t1)
			P1 = {
				x = P0.x + k * (f1.x - P0.x),
				y = P0.y + k * (f1.y - P0.y)
			}
		end

		local t2 = start + (t + 1) * inc
		local f2 = curve(t2 - delta)
		P3 = curve(t2)
		P2 = {
			x = P3.x - k * (P3.x - f2.x),
			y = P3.y - k * (P3.y - f2.y)
		}

		if first then
			self:M(P0.x, P0.y):C(P1.x, P1.y, P2.x, P2.y, P3.x, P3.y)
			first = false
		else
			self:S(P2.x, P2.y, P3.x, P3.y)
		end
	end
	return self
end

function path(attributes)
	local attr = attributes or {}
	p = Element:new("path", attr):set{ d = attr.d or "" }
	setmetatable(p, Path)
	return p
end

function fill(style)
	return Element:new("rect", {
		width = "100%",
		height = "100%",
	}):set(style)
end

function text(x, y, text, style)
	local t = Element:new("text", style)
	t:set {x = x, y = y}
	if type(text) == "string" then
		text = {text}
	end
	t.text = text
	return t
end

function tspan(text, style)
	local span = Element:new("tspan", style)
	if type(text) == "string" then
		text = {text}
	end
	span.text = text
	return span
end

function Font(family, size, fill, style)
	local attributes = {}
	attributes["font-family"] = family
	attributes["font-size"] = size
	attributes.fill = fill
	if not style then return attributes end

	if style.weight then
		attributes['font-weight'] = style.weight
	end

	local textAnchor = "text-anchor"
	if style.align == "start" or style.align == "left" then
		attributes[textAnchor] = "start"
	elseif style.align == "middle" or style.align == "center" then
		attributes[textAnchor] = "middle"
	elseif style.align == "end" or style.align == "right" then
		attributes[textAnchor] = "end"
	end

	local baseline = "dominant-baseline"
	if style.baseline == "top" then
		attributes[baseline] = "hanging"
	elseif style.baseline == "middle" or style.baseline == "center" then
		attributes[baseline] = "middle"
	elseif style.baseline == "bottom" then
		attributes[baseline] = "auto"
	end
	return attributes
end

function Fill(color)
	return {fill = color, stroke = "none"}
end

function Stroke(color, width, attr)
	attr = attr or {}
	local obj = {
		fill = "none",
		stroke = color,
		["stroke-width"] = width
	}

	local dash = attr.dashArray or attr["stroke-dasharray"] or attr.dasharray
	if dash then
		obj["stroke-dasharray"] = dash
	end
	return obj
end

function FillStroke(fill, stroke, width)
	return {
		fill = fill,
		stroke = stroke,
		["stroke-width"] = width
	}
end

function Point(x, y) return {x = x, y = y} end
P = Point
