local easing = require "pantograph.easing"
require "pantograph.vector"

local Variable = {}
Variable.__index = function(t, key)
	if key == "x" or key == "y" or key == "z" then
		local p = Variable:newFunc(function(point) return point[key] end, t)
		t[key] = p
		return p
	else
		return Variable[key]
	end
end


function Variable.value(x)
	if getmetatable(x) == Variable then
		return x:eval()
	end

	return x
end

local value = Variable.value

function Variable.toVariable(x)
	if getmetatable(x) == Variable then
		return x
	end

	return Variable:new(x)
end

function Variable:dependencies(...)
	self.funcValues = {...}
	for i, dep in ipairs(self.funcValues) do
		if getmetatable(dep) == Variable then
			dep.controlled[self] = true
		end
	end
	return self
end

local DependencyTable = {
	__mode = "k"
}

local function createDependencyTable()
	return setmetatable({}, DependencyTable)
end

function Variable:new(value)
	local var = {value = value, controlled = createDependencyTable()}
	return setmetatable(var, self)
end

function Variable:newFunc(func, ...)
	local p = Variable:new():dependencies(...)
	p.func = func
	return p
end

function Variable:resetDependencies()
	self.updated = nil
	for k, v in pairs(self.controlled) do
		k:resetDependencies()
	end
end

function Variable:set(newValue)
	if getmetatable(newValue) == Variable then
		self.func = function(x) return x end
		self:dependencies(newValue)
	elseif type(newValue) == "table" and newValue.x then
		self.x:set(newValue.x or 0)
		self.y:set(newValue.y or 0)
		self.z:set(newValue.z or 0)
		self:dependencies(self.x, self.y, self.z)
	else
		self.value = newValue
		self.func = nil
		self.funcValues = nil
	end
	self:resetDependencies()
end

function Variable:tweenAll(tweens)
	if Variable.syncTweens then
		for i, tween in ipairs(tweens) do
			table.insert(Variable.syncTweens, tween)
		end
		return
	end

	local fps = self.animation.fps or 30
	local maxTime = 0
	local tweenData = {}
	-- { var, newValue, time, interpolator, delay = delay }
	for i, tween in ipairs(tweens) do
		local delay = tween.delay or 0
		if tween[3] + delay > maxTime then
			maxTime = tween[3] + delay
		end
		tweenData[i] = {
			var = tween[1],
			oldValue = tween.startValue or tween[1]:eval(),
			newValue = value(tween[2]),
			frames = tween[3] * fps,
			interpolator = tween[4] or easing.EaseInOut,
			delayFrames = math.floor(fps * delay),
			cleanup = tween.cleanup,
			t = 0
		}
	end

	local frames = math.floor(fps * maxTime)
	for i = 1, frames do
		for j, tween in ipairs(tweenData) do
			local waiting = i <= tween.delayFrames
			local completed = i - tween.delayFrames > tween.frames
			if not completed and not waiting then
				tween.t = tween.interpolator((i - tween.delayFrames) / tween.frames)
				tween.var:set(easing.lerp(tween.oldValue, tween.newValue, tween.t))
			end

			if (i - tween.delayFrames >= tween.frames) and tween.cleanup then
				tween.cleanup()
			end
		end
		self.animation.update(1)
	end
end

function Variable:tween(newValue, time, interpolator)
	if not self.animation then
		return error("No update function defined.")
	end

	if Variable.syncTweens then
		table.insert(Variable.syncTweens, {self, newValue, time, interpolator})
		return
	end

	local fps = self.animation.fps or 30

	local oldValue = self:eval()
	newValue = value(newValue)
	local frames = math.floor(fps * time)
	local t = 0
	local f = interpolator or easing.EaseInOut

	for i = 1, frames do
		t = f(i / frames)
		self:set(easing.lerp(oldValue, newValue, t))
		self.animation.update(1)
	end
end

function Variable:point(x, y, z)
	local p = Variable:new()
	p.func = function(x, y, z)
		return Vector(x, y, z)
	end
	p.x = self.toVariable(x or 0)
	p.y = self.toVariable(y or 0)
	p.z = self.toVariable(z or 0)
	p:dependencies(p.x, p.y, p.z)
	return p
end

function Variable:polar(r, angle)
	local p = Variable:new()
	p.func = function(radius, angle)
		return Polar(radius, angle)
	end
	p.radius = self.toVariable(r or 1)
	p.angle = self.toVariable(angle or 0)
	p:dependencies(p.radius, p.angle)
	return p
end

local function resolveValues(values)
	local result = {}
	for i, v in ipairs(values or {}) do
		local resolved = value(v)
		if resolved == nil then
			return nil
		end

		table.insert(result, resolved)
	end

	return result
end

function Variable:eval()
	if self.func then
		if #self.funcValues == 0 then
			return value(self.func())
		elseif not self.updated then
			local resolved = resolveValues(self.funcValues)
			if not resolved then
				return nil
			end
			local result = self.func(table.unpack(resolved))
			self.cached = result
			self.updated = true
		end
		return self.cached
	else
		return self.value
	end
end



function Variable.__tostring(x)
	return "Variable<" .. tostring(x:eval()) .. ">"
end

function Variable.__add(x, y)
	local n = Variable:new()
	n:dependencies(x, y)
	n.func = function(a, b) return a + b end
	return n
end

function Variable.__sub(x, y)
	local n = Variable:new():dependencies(x, y)
	n.func = function(a, b) return a - b end
	return n
end

function Variable.__mul(x, y)
	local n = Variable:new():dependencies(x, y)
	n.func = function(a, b) return a * b end
	return n
end

function Variable.__div(x, y)
	local n = Variable:new():dependencies(x, y)
	n.func = function(a, b) return a / b end
	return n
end

function Variable.__pow(x, y)
	local n = Variable:new():dependencies(x, y)
	n.func = function(a, b) return a ^ b end
	return n
end

function Variable.__unm(x)
	local n = Variable:new():dependencies(x)
	n.func = function(a) return -a end
	return n
end

function Variable:__call(...)
	local n = Variable:new():dependencies(self, ...)
	if type(self.value) == "function" then
		n.func = function(f, ...) return f(...) end
		return n
	end
	return nil
end

function Variable:rotate(angle)
	return Variable:newFunc(function(point, angle)
		return point:rotate(angle)
	end, self, angle)
end

function Variable:unitVector()
	return Variable:newFunc(function(point)
		return point:unitVector()
	end, self)
end

function Variable:azimuth()
	return Variable:newFunc(function(point)
		return point:azimuth()
	end, self)
end

function Variable:perpendicular()
	return Variable:newFunc(function(point)
		return Vector(point.y, -point.x, point.z)
	end, self)
end

return Variable
