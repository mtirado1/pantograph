-- SVG Renderer
local svg = require "pantograph.svg"

local function renderStyle(style)
	if style == nil then
		return {}
	end

	if style.width then
		style["stroke-width"] = style.width
		style.width = nil
	end

	if not style.fill then
		style.fill = "none"
	end

	if style.font then
		return svg.Font(style.font, style.size, style.color, {
			align = style.align,
			baseline = style.baseline
		})
	end

	return style
end

local render = {}

function render.fill(object)
	local style = renderStyle(object.style)
	return svg.rect(0, 0, "100%", "100%", style)
end

function render.circle(object)
	local center = object.center
	local style = renderStyle(object.style)
	return svg.circle(center.x, center.y, object.radius, style)
end

function render.line(object)
	-- TODO: object.pointer
	local style = renderStyle(object.style)
	return svg.polyline(object.points, style)
end

function render.polygon(object)
	local style = renderStyle(object.style)
	return svg.polygon(object.points, style)
end

function render.group(object)
	local style = renderStyle(object.style)
	local rendered = {}
	for i, element in ipairs(object.elements) do
		table.insert(rendered, render[element.type](element))
	end
	return svg.group(rendered, style)
end

function render.image(object)
end


local equationCache = {}

function render.equation(object)
	local center = object.center
	if not equationCache[object.equation] then
		local svg, width, height = generateEquation(object.equation)
		equationCache[object.equation] = {
			svg = svg,
			width = width,
			height = height
		}
	end

	local equation = equationCache[object.equation]

	local eq = equation.svg:gsub("rgb%(0%%,0%%,0%%%)", object.color)
	local element = svg.rawSvg(center.x - equation.width / 2, center.y - equation.height / 2, eq)
	element:set { width = object.drawn * equation.width }
	return element
end

function render.text(object)
	local center = object.center
	local style = renderStyle(object.style)
	if object.drawn ~= 1 then
		style.opacity = object.drawn
	end

	return svg.text(center.x, center.y, table.concat(object.text), style)
end

return function(canvas)
	local image = svg.svg(canvas.width, canvas.height) {}

	for i, element in ipairs(canvas) do
		image:add(render[element.type](element))
	end

	return image:render()
end
