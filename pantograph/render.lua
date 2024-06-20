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

	if style.dash then
		style["stroke-dasharray"] = table.concat(style.dash, " ")
		style.dash = nil
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
	local points = object.points
	local style = renderStyle(object.style)

	if object.pointer then
		local last = #points
		local dx = points[last].x - points[last - 1].x
		local dy = points[last].y - points[last - 1].y
		local length = math.sqrt(dx*dx + dy*dy)
		if length > 0 then
			local scale = math.min(1, length / 12)
			local x = points[last].x - scale * dx / length * 12
			local y = points[last].y - scale * dy / length * 12
			points[last] = {x = x, y = y}
			local angle = math.deg(math.atan2(dy, dx))

			return svg.group {
				svg.polyline(points, style),
				svg.path():set {
					d = "M 12 0 L 0 4 L 0 -4 Z",
					transform = string.format("translate(%.2f,%.2f)rotate(%.2f)scale(%.2f)", x, y, angle, scale),
					fill = style.stroke
				}
			}
		end
	end
	return svg.polyline(points, style)
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
