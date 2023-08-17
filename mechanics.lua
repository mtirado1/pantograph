-- returns P2, P3_A, P3_B

function slide(s, time)
	local title = text(ORIGIN, s)
	title.style = "title"
	draw { title, time = 0.5 }
	pause(time - 1)
	erase { title, time = 0.5}
end

function solvePiston(p1, L1, L2, axis, angle)
	local p2 = p1 + polar(L1, angle)

	local c = circle(p2, L2)
	local p3_a, p3_b = intersect(c, axis) -- two solutions, circle-circle intersection
	return p2, p3_a, p3_b
end

function solveFourBars(p1, p4, L1, L2, L3, angle)
	local p2 = p1 + polar(L1, angle)

	local c1 = circle(p2, L2)
	local c2 = circle(p4, L3)

	local p3_a, p3_b = intersect(c1, c2) -- two solutions
	return p2, p3_a, p3_b
end

function fourBarsTrajectory(p1, p4, L1, L2, L3, dx, dy)
	local angle = var(0)
	local p2 = p1 + polar(L1, angle)

	local c1 = circle(p2, L2)
	local c2 = circle(p4, L3)

	local p3_a, p3_b = intersect(c1, c2) -- two solutions

	local barAngle = (p3_b - p2):azimuth()
	local i, j = coordinates(p2, p3_b)
	local final = p2 + i * dx + j * dy

	return function(t)
		angle:set(t)
		return final
	end
end

function solveFiveBars(p1, p5, L1, L2, L3, L4, angle, angle2)
	local p2 = p1 + polar(L1, angle)
	local p4 = p5 + polar(L4, angle2)

	local c1 = circle(p2, L2)
	local c2 = circle(p4, L3)

	local p3_a, p3_b = intersect(c1, c2)

	return p2, p3_a, p3_b, p4
end

function fiveBarsTrajectory(p1, p5, L1, L2, L3, L4, gearRatio, phase)
	local angle = var(0)
	local p2 = p1 + polar(L1, angle)
	local p4 = p5 + polar(L4, phase + angle * gearRatio)

	local c1 = circle(p2, L2)
	local c2 = circle(p4, L3)

	local p3_a, p3_b = intersect(c1, c2)

	return function(t)
		angle:set(t)
		return p3_b
	end
end

function block(center, angle, width, height, style)
	local H = point(0, height/2):rotate(angle)
	local W = point(width/2):rotate(angle)
	return polygon(
		center + W + H,
		center + W - H,
		center - W - H,
		center - W + H
	):set {
		center = center,
		width = width,
		height = height,
		style = style
	}
end

function groundPoint(center, radius, style)
	local drawn = var(1)
	local r = radius * drawn
	local x = point(r, 0)
	local y = point(0, r)
	local g = composite {
		circle(center, r):set { style = style },
		polygon(center + x, center + x - y, center - x - y, center - x):set { style = style }
	}:set { drawn = drawn }
	return g
end

function gear(center, radius, angle, style)
	local elements = {
		circle(center, radius):set { style = style }
	}

	local N = 12
	for i = 0, N - 1 do
		local a = angle + (2 * math.pi * i / N)
		table.insert(elements, segment(
			center + polar(radius / 3, a),
			center + polar((2 / 3) * radius, a)
		))
	end
	
	return group(elements)
end

function bar(p1, p2, radius, style)
	local drawn = var(1)
	local pEnd = p1 * (1 - drawn) + p2 * drawn
	local d = pEnd - p1
	local r = d:unitVector():perpendicular() * radius * 0.75 * drawn
	local rCircle = radius * drawn
	local g = composite {
		circle(p1, rCircle):set { style = style },
		circle(pEnd, rCircle):set { style = style },
		polygon(
			p1 + r, pEnd + r, pEnd - r, p1 - r
		):set { style = style }
	}:set {
		p1 = p1,
		p2 = p2,
		drawn = drawn
	}
	return g
end

function revolution(x, n, time)
	x:set(0)
	tween(x, 2 * pi * n, time, easing.Linear)
end



function datum(center, radius, style)
	return group {
		segment(center + point(-2 * radius, 0), center + point(2 * radius, 0)):set { style = style },
		segment(center + point(0, -2 * radius), center + point(0, 2 * radius)):set { style = style },
		circle(center, radius):set { style = style }
	}
end

function project(a, b, p)
	if not p then
		a, b, p = ORIGIN, a, b
	end

	local vector = b - a
	local projectedLength = dot(vector, p - a) / len(vector)

	local x = a + vector:unitVector() * projectedLength
	local y = a + p - x

	return x, y
end

function coordinates(a, b)
	local vector = a
	if b then
		vector = b - a
	end

	local i = vector:unitVector()
	local j = perpendicular(i)
	return i, j
end

function measure(a, b, text, ...)
	local offset = 0.5
	local h = 0.1

	local x, y = coordinates(a, b)
	local ruler = segment(a + y * offset, b + y * offset)
	local g = group {
		ruler,
		segment(a + y * (offset + h), a + y * (offset - h)),
		segment(b + y * (offset + h), b + y * (offset - h))
	}
	if text then
		g.elements[4] = label(ruler, text, ...)
	end
	return g
end

function revolutions(n)
	return (2 * math.pi) * n
end
