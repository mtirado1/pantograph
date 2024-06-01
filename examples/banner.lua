
setLayers {
	"main",
	"points"
}

P0 = point(-6, 0)
P1 = point(-2, 0)
P2 = point(2, 0)
P3 = point(6, 0)

alpha = var(0)
local R = 1.5

local monteCarlo = {
	slider = var(0),
	inside = {},
	N = 200
}

for i = 1, monteCarlo.N do
	local x = value(2 * (math.random() - 0.5) * R)
	local y = value(2 * (math.random() - 0.5) * R)
	local p = P3 + point(x, y)

	if x^2 + y^2 > R^2 then
		p.style = { fill = colors.blue, radius = 3}
		monteCarlo.inside[i] = false
	else
		p.style = { fill = colors.green, radius = 3}
		monteCarlo.inside[i] = true
	end

	p.opacity = varFunc(function(slider)
		if slider < i then
			return 0
		else
			return 1
		end
	end, monteCarlo.slider)

	plot { p, layer = "points" }
end

monteCarlo.pi = varFunc(function(slider)
	local n = 0
	local items = value(math.floor(slider))
	for i = 1, items do
		if monteCarlo.inside[i] then
			n = n + 1
		end
	end

	if items == 0 then
		return 0
	end

	return 4 * n / items
end, monteCarlo.slider)

function axis(center)
	local R = 1.6
	return group {
		segment(center + point(-R, 0), center + point(R, 0)):set { style = "grid" },
		segment(center + point(0, -R), center + point(0, R)):set { style = "grid" }
	}
end

local luaR = R / 1.5
local r = luaR * (1 - 1 / math.sqrt(2))
local corner = P0 + point(luaR, luaR)
local smallCorner = P0 + point(luaR * (math.sqrt(2) - 1), luaR * (math.sqrt(2) - 1))

draw {
	circle(P0, luaR),
	circle(corner, r),
	circle(smallCorner, r),
	axis(P0),

	circle(P1, R),
	circle(P3, R),
	polygon(
		P3 + point(R, R),
		P3 + point(R, -R),
		P3 + point(-R, -R),
		P3 + point(-R, R)
	),
	axis(P1),
	style = "grid",
	time = 1
}

local triangle = {
	P1,
	P1 + polar(R, alpha),
	P1 + point(R * math.cos(alpha), 0)
}

function c(t)
	return P2 + 1.5 * point(math.cos(3 * t + alpha), math.sin(2 * t + alpha))
end

draw {
	polygon(table.unpack(triangle)):set { style = "red" },
	segment(triangle[1], triangle[2]),
	curve(c, 0, 2 * math.pi, 200), -- t from 0 to 2pi, 200 points
	time = 1
}

draw {
	triangle[1],
	triangle[2],
	triangle[3],
	title(P0, "Pantograph"),
	text(P3 + point(0, R), "N = []", math.floor(monteCarlo.slider)),
	text(P3 + point(0, -R), "[pi] [approx] []", monteCarlo.pi),
	layer = "points",
	time = 1
}

pause(1)

while sync() do
	tween(alpha, math.rad(3 * 360), 10, easing.Linear)
	tween(monteCarlo.slider, monteCarlo.N, 10, easing.Linear)
end

pause(2)
