
include "mechanics.lua"

L1 = 1
L2 = var(3)
L3 = var(3.5)
L4 = var(2)

local t = var(0)

local scale = 1

local base = point(0, -1)

P1 = base
P4 = base + point(L4 * scale, 0)

curves = {}
function getCurve(x, y)
	local trajectory = fourBarsTrajectory(P1, P4, L1 * scale, L2 * scale, L3 * scale, x, y)
	local c = curve(trajectory, 0, 2 * math.pi):set { style = "grid" }
	table.insert(curves, c)
	return c
end


P2, _, P3 = solveFourBars(P1, P4, L1 * scale, L2 * scale, L3 * scale, t)

-- Third point on coupler link
local i, j = coordinates(P2, P3)
--- This is how we tween any point in the coupler
local x = var(0)
local y = var(0)
PC = P2 + x * i + y * j

local linkage = group {
	groundPoint(P1, 0.4, "gray"),
	groundPoint(P4, 0.4, "gray"),
	bar(P1, P2, 0.2, "red"),
	bar(P4, P3, 0.2, "green"),
	bar(P2, P3, 0.2, "blue"),
	bar(P2, PC, 0.2, "blue"),
	bar(PC, P3, 0.2, "blue")
}


draw {
	linkage,
	time = 3
}

pause(1)

while sync() do
	tween(t, revolutions(5), 5, easing.Linear)
	draw {
		getCurve(0, 0),
		interpolator = easing.Linear,
		back = true
	}
end

while sync() do
	tween(t, revolutions(10), 5, easing.Linear)
	tween(x, 1, 1)
	draw {
		getCurve(1, 0),
		interpolator = easing.Linear,
		back = true,
		delay = 1
	}
end

while sync() do
	tween(t, revolutions(15), 5, easing.Linear)
	tween(x, 2, 1)
	tween(y, 4, 1)
	draw {
		getCurve(2, 4),
		interpolator = easing.Linear,
		back = true,
		delay = 1
	}
end

while sync() do
	tween(t, revolutions(20), 5, easing.Linear)
	tween(x, 2, 1)
	tween(y, -4, 1)
	draw {
		getCurve(2, -4),
		interpolator = easing.Linear,
		back = true,
		delay = 1
	}
end

while sync() do
	tween(t, revolutions(25), 5, easing.Linear)
	tween(x, -3, 1)
	tween(y, -2, 1)
	draw {
		getCurve(-3, -2),
		interpolator = easing.Linear,
		back = true,
		delay = 1
	}
end

while sync() do
	tween(t, revolutions(30), 5, easing.Linear)
	tween(x, -1, 1)
	tween(y, -4, 1)
	draw {
		getCurve(-1, -4),
		interpolator = easing.Linear,
		back = true,
		delay = 1
	}
end

while sync() do
	fadeOut(curves, 2)
	curves = {}
	tween(x, 0, 2)
	tween(y, 0, 2)
end

pause(1)

erase(all())
