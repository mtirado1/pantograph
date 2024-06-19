require "pantograph.mathutils"
local variable = require "pantograph.variable"
local canvas = require "pantograph.canvas"
local easing = require "pantograph.easing"

local function animate(code, properties)
	local config = {fps = properties.fps or 30}

	local image = canvas.Canvas:new(properties.width, properties.height)

	config.update = function(frames)
		properties.update(image:render(), frames or 1)
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

		--- Creates a variable.
		-- @param value Initial value
		var = function(value)
			return variable:new(variable.value(value))
		end,

		--- Creates a variable expression
		-- The expression will be evaluated only when its dependencies change value.
		-- If no dependencies are given, the expression is always evaluated.
		--
		-- @param func             Expression function, its arguments are the evaluated dependencies.
		-- @param ...dependencies? Expression dependencies
		expr = function(func, ...)
			return variable:newFunc(func, ...)
		end,

		--- Sets image layers
		-- @param layers Table containing layer names
		setLayers = function(layers)
			image:setLayers(layers)
		end,

		setStyle = function(style)
			image.style = style
		end,

		--- Returns all elements
		-- @param layer? If given, only returns all elements in the layer
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

		--- Creates a point variable.
		-- @param x? 0 by default
		-- @param y? 0 by default
		-- @param z? 0 by default
		point = MathUtils.point,
		-- Creates a polar point variable
		-- @param radius? 1 by default
		-- @param angle? 0 by default
		polar = MathUtils.polar,
		--- Calculates the dot product of two points
		-- @param a
		-- @param b
		dot = MathUtils.dot,

		--- Calculates the midpoint of a segment, line, or two points.
		-- @param a
		-- @param b?
		midpoint = MathUtils.midpoint,
		azimuth = MathUtils.azimuth,
		lerp = MathUtils.lerp,

		--- Evaluates a variable
		--  @param x  Variable to evaluate. If x is not a variable, returns x.
		value = function(x)
			return variable.value(x)
		end,

		--- Easing functions
		--
		-- @type table
		-- @param Linear
		-- @param EaseIn
		-- @param EaseOut
		-- @param EaseInOut
		easing = easing,

		--- Assigns a value to a variable
		--  @param var      Variable
		--  @param newValue New value
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

		--- Tweens a variable.
		-- @param var            Variable to tween
		-- @param newValue       New value
		-- @param time           Animation time
		-- @param interpolator?  Interpolating function (`EaseInOut` by default)
		tween = function(var, newValue, time, interpolator)
			var:tween(newValue, time, interpolator)
		end,

		--- Tweens multiple variables
		-- @param tweens List of tweens
		tweenAll = function(tweens)
			variable:tweenAll(tweens)
		end,

		--- Pauses the animation.
		-- @param time Pause time in seconds
		pause = function(time)
			config.update(time * config.fps)
		end,

		--- Erases and removes elements from the screen
		-- Works by tweening the `drawn` property of each element
		-- @type tableFunction
		-- @param ...elements    Elements to draw
		-- @param time?          Animation time. 1 second by default
		-- @param interpolator?  Interpolator function. EaseInOut by default
		-- @param delay?         Animation delay. 0 seconds by default
		-- @param style?         Style to assign to all elements
		-- @param layer?         Layer where the elements will be added
		erase = animateProperty("drawn", 1, 0, true),
		--- Draws elements on the screen
		-- Works by tweening the `drawn` property of each element
		-- @type tableFunction
		-- @param ...elements    Elements to draw
		-- @param time?          Animation time. 1 second by default
		-- @param interpolator?  Interpolator function. EaseInOut by default
		-- @param delay?         Animation delay. 0 seconds by default
		-- @param style?         Style to assign to all elements
		-- @param layer?         Layer where the elements will be added
		draw = animateProperty("drawn", 0, 1),

		--- Fades in elements on the screen
		-- Works by tweening the `opacity` property of each element
		-- @type tableFunction
		-- @param ...elements    Elements to draw
		-- @param time?          Animation time. 1 second by default
		-- @param interpolator?  Interpolator function. EaseInOut by default
		-- @param delay?         Animation delay. 0 seconds by default
		-- @param style?         Style to assign to all elements
		-- @param layer?         Layer where the elements will be added
		fadeIn = animateProperty("opacity", 0, 1),
		--- Fades out elements from the screen
		-- Works by tweening the `opacity` property of each element
		-- @type tableFunction
		-- @param ...elements    Elements to draw
		-- @param time?          Animation time. 1 second by default
		-- @param interpolator?  Interpolator function. EaseInOut by default
		-- @param delay?         Animation delay. 0 seconds by default
		-- @param style?         Style to assign to all elements
		-- @param layer?         Layer where the elements will be added
		fadeOut = animateProperty("opacity", 1, 0, true),

		len = MathUtils.len,
		--- Calculates intersections between lines, segments, and/or circles
		--  Returns variables that evaluate to the intersection points.
		-- @param a Line, segment or circle object
		-- @param b Line, segment or circle object
		intersect = MathUtils.intersect,
		tangent = MathUtils.tangent,

		--- Creates a line segment
		-- @param a First point
		-- @param b Second point
		segment = MathUtils.segment,
		--- Creates a vector
		-- Vectors behave as segments but are drawn with an arrow.
		-- @param a First point
		-- @param b? Second point
		vector = MathUtils.vector,
		--- Creates a line
		-- @param a First point
		-- @param b Second point
		line = MathUtils.line,
		-- Draws a horizontal line
		-- If `length` is given, it draws a segment instead.
		--
		-- @param center
		-- @param length?
		-- @param offset?
		horizontal = MathUtils.horizontal,
		-- Draws a vertical line
		-- If `length` is given, it draws a segment instead.
		--
		-- @param center
		-- @param length?
		-- @param offset?
		vertical = MathUtils.vertical,
		bisect = MathUtils.bisect,
		perpendicular = MathUtils.perpendicular,

		--- Creates a circle with a center and radius, or passing through a given point
		--  @param center
		--  @param radius  Can be a number or a point
		circle = MathUtils.circle,
		angle = MathUtils.angle,

		--- Creates a curve.
		-- The curve is a line with `N` points from `curve(start)` to `curve(stop)`
		--
		-- If `curve(t)` returns a number, it will be drawn as a function. *x = t, y = curve(t)*
		--
		-- @param curve Curve function.
		-- @param start Initial *t*
		-- @param stop  Final *t*
		-- @param N?    Number of points. Will use `abs(final - stop) * 20` by default
		curve = MathUtils.curve,
		text = MathUtils.text,
		title = function(...)
			local t = MathUtils.text(...)
			t.style = "title"
			return t
		end,
		label = MathUtils.label,
		--- Creates a polygon
		-- @param points Table containing polygon vertices
		polygon = MathUtils.polygon,
		--- Creates a polyline
		-- @param points Table containing polyline corners
		polyline = MathUtils.polyline,
		group = MathUtils.group,
		composite = MathUtils.composite,
		image = MathUtils.image,
		equation = MathUtils.equation,

		--- Adds elements to the screen
		-- @type tableFunction
		-- @param ...elements Elements to add
		-- @param style?      Style to assign to all elements
		-- @param layer?      Layer where the elements will be added
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

		--- Removes elements from the screen
		-- @param elements Table containing the elements to remove
		remove = function(elements)
			image:remove(table.unpack(elements))
		end,

		frame = properties.frame,

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

		print = properties.print,

		colors = canvas.colors,
		Fill = function(color, opacity)
			return {
				fill = color,
				opacity = opacity
			}
		end,
		Stroke = function(color, width, opacity)
			return {
				stroke = color,
				width = width,
				opacity = opacity
			}
		end,
		FillStroke = function(fill, stroke, width, opacity)
			return {
				fill = fill,
				stroke = stroke,
				width = width,
				opacity = opacity
			}
		end,
		Font = function(family, size, color, opacity)
			return {
				family = family,
				size = size,
				color = color,
				opacity = opacity
			}
		end,

		ipairs = ipairs,
		table = table,
		pairs = pairs
	}
	
	--- Loads a file containing Lua code
	-- @name include
	-- @type function
	-- @param file The file to load
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
