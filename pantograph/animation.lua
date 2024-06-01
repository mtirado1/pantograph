require "pantograph.mathutils"
local variable = require "pantograph.variable"
local canvas = require "pantograph.canvas"
local easing = require "pantograph.easing"

local function animate(code, properties)
	local config = {fps = properties.fps or 30}

	local image = canvas.Canvas:new(properties.width, properties.height)

	config.update = function(frames)
		local output = image:render()
		frames = frames or 1
		for i = 1, frames or 1 do
			local cmd = "rsvg-convert"
			if properties.scale then
				cmd = string.format("rsvg-convert --width %d", properties.scale * properties.width)
			end
			local f = io.popen(cmd, "w")
			f:write(output)
			f:flush()
			f:close()
		end
	end

	config.frame = function(name)
		if name then
			local f = io.open(name, "w")
			f:write(image:render())
			f:close()
			return
		end
		print(image:render())
	end

	if properties.testMode then
		config.update = function()
			local s = image:render()
		end

		config.frame = config.update
	end

	-- This is it, the environment that hides all
	-- the methods and metatables and packs a
	-- vector, SVG, and math library in a neat DSL
	
	variable.animation = config

	-- Used for animating various properties
	local animateProperty = function(property, startValue, endValue, remove)
		return function(elements, time, interpolator)
			time = time or elements.time or 1
			interpolator = interpolator or elements.interpolator
			local delay = elements.delay or 0
			local tweens = {}
			image:add(table.unpack(elements))
			for i, e in ipairs(elements) do
				if elements.style then
					e.style = elements.style
				end
				if elements.layer then
					e.layer = elements.layer
				end
				tweens[i] = { e[property], endValue, time, interpolator, delay = delay }
				if remove then
					tweens[i].cleanup = function() image:remove(e) end
					tweens[i].startValue = startValue
				else
					e[property]:set(startValue)
				end
				if elements.step then
					delay = delay + elements.step
				end
			end
			variable:tweenAll(tweens)
		end
	end

	local env = {
		camera = image.camera,

		var = function(value)
			return variable:new(variable.value(value))
		end,

		varFunc = function(func, ...)
			return variable:newFunc(func, ...)
		end,

		setLayers = function(layers)
			image:setLayers(layers)
		end,

		setStyle = function(style)
			image.style = style
		end,

		all = function(layer)
			if layer then
				local filtered = {}
				for i, element in ipairs(image.elements) do
					if element.layer == layer then
						table.insert(filtered, element)
					end
				end
				return filtered
			end
			return image.elements
		end,

		point = MathUtils.point,
		polar = MathUtils.polar,
		dot = MathUtils.dot,
		midpoint = MathUtils.midpoint,
		azimuth = MathUtils.azimuth,
		lerp = MathUtils.lerp,

		value = function(x)
			return variable.value(x)
		end,

		easing = easing,

		set = function(var, newValue)
			var:set(newValue)
		end,

		sync = function()
			if variable.syncTweens then
				local tweens = variable.syncTweens
				variable.syncTweens = nil
				variable:tweenAll(tweens)
				return false
			else
				variable.syncTweens = {}
				return true
			end
		end,

		tween = function(var, newValue, time, interpolator)
			var:tween(newValue, time, interpolator)
		end,

		tweenAll = function(tweens)
			variable:tweenAll(tweens)
		end,

		pause = function(time)
			config.update(time * config.fps)
		end,

		erase = animateProperty("drawn", 1, 0, true),
		draw = animateProperty("drawn", 0, 1),

		fadeIn = animateProperty("opacity", 0, 1),
		fadeOut = animateProperty("opacity", 1, 0, true),

		len = MathUtils.len,
		intersect = MathUtils.intersect,
		tangent = MathUtils.tangent,

		segment = MathUtils.segment,
		vector = MathUtils.vector,
		line = MathUtils.line,
		horizontal = MathUtils.horizontal,
		vertical = MathUtils.vertical,
		bisect = MathUtils.bisect,
		perpendicular = MathUtils.perpendicular,
		circle = MathUtils.circle,
		angle = MathUtils.angle,
		curve = MathUtils.curve,
		text = MathUtils.text,
		title = function(...)
			local t = MathUtils.text(...)
			t.style = "title"
			return t
		end,
		label = MathUtils.label,
		polygon = MathUtils.polygon,
		polyline = MathUtils.polyline,
		group = MathUtils.group,
		composite = MathUtils.composite,
		image = MathUtils.image,
		equation = MathUtils.equation,

		plot = function(elements)
			if elements.style then
				for i, e in ipairs(elements) do
					e.style = elements.style
				end
			end
			if elements.layer then
				for i, e in ipairs(elements) do
					e.layer = elements.layer
				end
			end
			image:remove(table.unpack(elements))
			image:add(table.unpack(elements))

			return elements
		end,

		remove = function(elements)
			image:remove(table.unpack(elements))
		end,

		frame = config.frame,

		ORIGIN = variable:point(0, 0, 0),
		X_AXIS = MathUtils.line(variable:point(-1, 0), variable:point(1, 0)),
		Y_AXIS = MathUtils.line(variable:point(0, -1), variable:point(0, 1)),
		Z_AXIS = MathUtils.line(variable:point(0, 0, -1), variable:point(0, 0, 1)),
		degrees = function(n)
			return n * math.pi / 180
		end,
		math = {
			pi = math.pi,
			exp = variable:new(math.exp),
			sqrt = variable:new(math.sqrt),
			abs = variable:new(math.abs),
			sin = variable:new(math.sin),
			asin = variable:new(math.asin),
			cos = variable:new(math.cos),
			acos = variable:new(math.acos),
			tan = variable:new(math.tan),
			atan = variable:new(math.atan),
			min = variable:new(math.min),
			max = variable:new(math.max),
			floor = variable:new(math.floor),
			ceil = variable:new(math.ceil),
			deg = variable:new(math.deg),
			rad = variable:new(math.rad),
			random = math.random,
			randomseed = math.randomseed
		},
		random = math.random,

		print = function(...)
			if properties.testMode then
				print(...)
			end
		end,

		colors = canvas.colors,
		Fill = Fill,
		Stroke = Stroke,
		FillStroke = FillStroke,
		Font = Font,

		ipairs = ipairs,
		table = table,
		pairs = pairs
	}
	
	env.include = function(file)
		local f, err = io.open(file)
		if err then
			print(err)
			os.exit(1)
		end
		local code = f:read("*a")
		local func, err = load(code, file, "t", env)
		if err then
			print(err)
			os.exit(1)
		end
		func()
	end

	local func, err = load(code, properties.title or "Pantograph plot", "t", env)
	if err then
		print(err)
		os.exit(1)
	end

	func()
end

return animate
