local variable = require "pantograph.variable"
local textUtils = require "pantograph.textutils"
require "pantograph.vector"

function kind(obj)
	if obj.kind then
		return obj.kind
	end

	local value = variable.value(obj)
	if value == nil then
		return "undefined"
	elseif type(value) == "number" then
		return "number"
	elseif value.x then
		obj.kind = "point"
		return "point"
	end

	return "undefined"
end

MathElement = {}
MathElement.__index = MathElement

function MathElement:new(kind, props)
	local e = {kind = kind}
	for k, v in pairs(props) do
		e[k] = v
	end
	return setmetatable(e, self)
end

function MathElement:set(props)
	for k, v in pairs(props) do
		self[k] = v
	end
	return self
end

MathUtils = {}

function MathUtils.point(x, y, z)
	local p = variable:point(x, y, z)
	p.kind = "point"
	return p
end

function MathUtils.polar(radius, angle)
	local p = variable:polar(radius, angle)
	p.kind = "point"
	return p
end

function MathUtils.midpoint(a, b)
	local mid
	if a and b then
		mid = (a + b) / 2
	elseif a.kind == "segment" or a.kind == "line" then
		mid = (a.a + a.b) / 2
	else
		return nil
	end

	mid.kind = "point"
	return mid
end

function MathUtils.azimuth(a)
	local k = kind(a)
	if k == "point" then
		return a:azimuth()
	elseif k == "segment" or k == "line" then
		return (a.b - a.a):azimuth()
	end
end

function MathUtils.perpendicular(a, b)
	if a and b then
		local v = b - a
		return variable:point(-v.y, v.x)
	elseif kind(a) == "segment" or kind(a) == "line" then
		local v = a.b - a.a
		local p = variable:point(-v.y, v.x)
		return MathElement:new(kind(a), {
			a = a.a,
			b = a.a + p,
			marker = a.marker
		})
	elseif kind(a) == "point" then
		local v = a
		return variable:point(-v.y, v.x)
	end
end

function MathUtils.bisect(a, b)
	if a and b then
		local v = b - a
		local perpendicular = variable:point(-v.y, v.x)
		local o = (a + b - perpendicular) / 2
		return MathUtils.line(o, o + perpendicular)
	elseif a.kind == "segment" or a.kind == "line" then
		local v = a.b - a.a
		local perpendicular = variable:point(-v.y, v.x)
		local o = (a.a + a.b - perpendicular) / 2
		return MathElement:new(a.kind, {a = o, b = o + perpendicular})
	end

	return nil
end


function MathUtils.len(element)
	if element.kind == "line" or element.kind == "segment" then
		return variable:newFunc(function(a, b)
			return (a - b):length()
		end, element.a, element.b)
	elseif kind(element) == "point" then
		return variable:newFunc(function(a)
			return a:length()
		end, element)
	end

	error("Can't obtain length.")
	return nil
end

function MathUtils.dot(p1, p2)
	local kind1, kind2 = kind(p1), kind(p2)
	if kind1 == "point" and kind2 == "point" then
		return variable:newFunc(function(a, b)
			return a:dot(b)
		end, p1, p2)
	else
		return nil
	end
end

local function lineLineIntersection(L1, L2, aIsSegment, bIsSegment)
	local p1, d1 = L1.a, L1.b - L1.a
	local p2, d2 = L2.a, L2.b - L2.a

	local function dotPerp(v1, v2)
		return v1.x * v2.y - v2.x * v1.y
	end

	local p = variable:newFunc(function(p1, d1, p2, d2)
		local dp = dotPerp(d1, d2)
		local Delta = p2 - p1
		if dp == 0 then
			return nil
		end

		local s = dotPerp(Delta, d2) / dp
		local t = dotPerp(Delta, d1) / dp

		if (aIsSegment and bIsSegment) and ((s > 1 or s < 0) or (t > 1 or t < 0)) then
			return nil
		elseif bIsSegment and (t > 1 or t < 0) then
			return nil
		end

		return p1 + s * d1 -- or p2 + t * d2
	end, p1, d1, p2, d2)

	return p
end

local function circleLineIntersection(a, b, isSegment)
	local c, r = a.center, a.trueRadius
	local p1, p2 = b.a, b.b
	
	local P, D = p1, p2 - p1
	local Delta = P - c
	local dot, len = MathUtils.dot, MathUtils.len
	local discriminant = dot(D, Delta)^2 - len(D)^2 * (len(Delta)^2 - r^2)

	local p1 = variable:newFunc(function(D, Delta, discriminant, P, D)
		if discriminant < 0 then
			return nil
		end
		local t = (-D:dot(Delta) + math.sqrt(discriminant)) / D:length()^2
		if isSegment and (t < 0 or t > 1) then
			return nil
		end
		return P + t * D
	end, D, Delta, discriminant, P, D)

	local p2 = variable:newFunc(function(D, Delta, discriminant, P, D)
		if discriminant < 0 then
			return nil
		end
		local t = (-D:dot(Delta) - math.sqrt(discriminant)) / D:length()^2
		if isSegment and (t < 0 or t > 1) then
			return nil
		end
		return P + t * D
	end, D, Delta, discriminant, P, D)

	return p1, p2
end

local function circleCircleIntersection(a, b)
	local c1, r1 = a.center, a.trueRadius
	local c2, r2 = b.center, b.trueRadius

	local p1 = variable:newFunc(function(c1, r1, c2, r2)
		local u = c2 - c1
		local uLength = u:length() ^ 2
		local v = Vector(u.y, -u.x)

		local s = (1 + (r1 * r1 - r2 * r2) / uLength) / 2
		local tSquared = r1 * r1 / uLength - s * s

		if tSquared < 0 then return nil end
		return c1 + s * u + math.sqrt(tSquared) * v

	end, c1, r1, c2, r2)

	local p2 = variable:newFunc(function(c1, r1, c2, r2)
		local u = c2 - c1
		local uLength = u:length() ^ 2
		local v = Vector(u.y, -u.x)

		local s = (1 + (r1 * r1 - r2 * r2) / uLength) / 2
		local tSquared = r1 * r1 / uLength - s * s

		if tSquared < 0 then return nil end
		return c1 + s * u - math.sqrt(tSquared) * v
	end, c1, r1, c2, r2)


	return p1, p2
end

local function arrangeObjects(...)
	local objects = {...}
	table.sort(objects, function(a, b) return kind(a) < kind(b) end)
	local names = {}
	for i = 1, #objects do
		names[i] = kind(objects[i])
	end
	return table.concat(names, "-"), table.unpack(objects) 
end

local function circlePointTangent(circle, point)
	local center = (point + circle.center) / 2
	local radius = MathUtils.len((point - circle.center) / 2)
	local midCircle = MathUtils.circle(center, radius)

	return circleCircleIntersection(circle, midCircle)
end

function MathUtils.lerp(properties)
	return variable:newFunc(function(t, ...)
		if t > 1 then
			t = t - math.floor(t)
		end
		local values = { ... }
		local intervals = #values - 1

		local index = math.floor(t * intervals)
		local ratio = t * intervals - index
		if properties.interpolator then
			ratio = properties.interpolator(ratio)
		end
		if index == intervals then
			return values[#values]
		end

		if index < 0 then
			return values[1]
		end

		return values[index + 1] * (1 - ratio) + values[index + 2] * ratio
	end, properties.t, table.unpack(properties))
end

function MathUtils.tangent(a, b)
	local kinds, a, b = arrangeObjects(a, b)

	if kinds == "circle-point" then
		return circlePointTangent(a, b)
	else
		error("Can't get tangent for " .. kinds)
	end
end

-- Intersection points of two objects, they may be undefined
function MathUtils.intersect(a, b)
	local kinds, a, b = arrangeObjects(a, b)

	if kinds == "circle-circle" then
		return circleCircleIntersection(a, b)
	elseif kinds == "circle-line" then
		return circleLineIntersection(a, b)
	elseif kinds == "circle-segment" then
		return circleLineIntersection(a, b, true)
	elseif kinds == "line-line" then
		return lineLineIntersection(a, b)
	elseif kinds == "line-segment" then
		return lineLineIntersection(a, b, false, true)
	elseif kinds == "segment-segment" then
		return lineLineIntersection(a, b, true, true)
	end

	return nil
end

function MathUtils.segment(a, b)
	return MathElement:new("segment", {a = a, b = b})
end

function MathUtils.line(a, b)
	return MathElement:new("line", {a = a, b = b})
end

function MathUtils.horizontal(center, length, offset)
	if not length then
		return MathUtils.line(center + Vector(-1, 0), center + Vector(1, 0))
	elseif offset then
		return MathUtils.segment(center + variable:point(-length/2 + offset, 0), center + variable:point(length/2 + offset, 0))
	else
		return MathUtils.segment(center + variable:point(-length/2, 0), center + variable:point(length/2, 0))
	end
end

function MathUtils.vertical(center, length, offset)
	if not length then
		return MathUtils.line(center + Vector(-1, 0), center + Vector(1, 0))
	elseif offset then
		return MathUtils.segment(center + variable:point(0, -length/2 + offset), center + variable:point(0, length/2 + offset))
	else
		return MathUtils.segment(center + variable:point(0, -length/2), center + variable:point(0, length/2))
	end
end

function MathUtils.vector(a, b)
	if not b then
		b = a
		a = variable:point(0, 0, 0)
	end
	return MathElement:new("segment", {a = a, b = b, marker = true})
end

function MathUtils.circle(center, radius)
	local trueRadius = variable:new():dependencies(center, radius)
	trueRadius.func = function(c, r)
		if type(r) == "number" then return r end
		return (r - c):length()
	end

	return MathElement:new("circle", {center = center, radius = radius, trueRadius = trueRadius})
end

function MathUtils.angle(a, center, b)
	if not b then
		a, center, b = a + variable:point(1, 0), a, center
	end
	local angle = variable:newFunc(function(a, center, b)
		local a_angle = (a - center):azimuth()
		local b_angle = (b - center):azimuth()
		return b_angle - a_angle
	end, a, center, b)
	return MathElement:new("angle", {center = center, a = a, b = b, angle = angle})
end

function MathUtils.curve(curve, start, stop, n)
	return MathElement:new("curve", {
		curve = variable.toVariable(curve),
		start = variable.toVariable(start),
		stop = variable.toVariable(stop),
		nodes = n
	})
end

function MathUtils.text(center, content, ...)
	local parsed = textUtils.parseLines(content, {...})
	return MathElement:new("text", {center = center, text = parsed})
end

function MathUtils.label(element, content, ...)
	local text = nil
	if content then
		text = textUtils.parseLines(content, {...})
	end
	return MathElement:new("label", {obj = element, text = text})
end

function MathUtils.polyline(...)
	local points = {...}
	if #points == 1 then
		points = points[1]
	end
	return MathElement:new("polyline", {points = points})
end

function MathUtils.polygon(...)
	local points = {...}
	if #points == 1 then
		points = points[1]
	end
	return MathElement:new("polygon", {points = points})
end

function MathUtils.group(elements)
	return MathElement:new("group", {elements = elements})
end

function MathUtils.composite(elements)
	return MathElement:new("composite", {elements = elements})
end

function MathUtils.image(center, href, width, height)
	width = width or 1
	height = height or width
	return MathElement:new("image", {
		center = center,
		href = href,
		width = width,
		height = height
	})
end

local equationCounter = 0
function MathUtils.equation(center, equation)
	local equationSvg, width, height = generateEquation(equation)

	return MathElement:new("equation", {
		center = center,
		width = width,
		height = height,
		equation = equationSvg
	})
end
