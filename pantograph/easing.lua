-- Easing functions

local function lerp(a, b, t)
	local f = function(t)
		return a * (1 - t) + b * t
	end
	if type(a) == "function" and type(b) == "function" then
		f = function(t)
			return function(...)
				return a(...) * (1 - t) + b(...) * t 
			end
		end
	end

	return t and f(t) or f
end

local function lerpMany(t, ...)
	local values = { ... }
	local N1 = math.floor(t * (#values - 1))
	local N2 = math.ceil(t * (#values - 1))
	local a = values[N1 + 1]
	local b = values[N2 + 1]
	local currentT = t - N1 * t / (#values - 1)
	return a * (1 - currentT) + b * currentT
end

local function Linear(t)
	return t
end

local function EaseInOut(t)
	return 3 * t * t - 2 * t * t * t
end

local function EaseIn(t)
	return t * t * (2 - t)
end

local function EaseOut(t)
	return t * (1 + t - t * t)
end


return {
	lerp = lerp,
	Linear = Linear,
	EaseInOut = EaseInOut,
	EaseIn = EaseIn,
	EaseOut = EaseOut
}
