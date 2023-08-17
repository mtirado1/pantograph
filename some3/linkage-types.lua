include "mechanics.lua"

function Linkage(center, a, b, c, d, angle)
	local P1 = center + point(-d/2, 0)
	local P4 = center + point(d/2, 0)


	local isDoubleRocker = value(math.min(a, b, c, d)) == b

	local t = lerp { 0, 2 * math.pi, t = angle }

	if isDoubleRocker then
		minAngle = math.acos((c^2 - (a + b)^2 - d^2) / (-2 * d * (a + b)))
		maxAngle = math.acos(((b + c)^2 - a^2 - d^2) / (-2 * d * a))
		t = lerp {
			minAngle, maxAngle, minAngle,
			t = angle,
		}
	end
	
	local P2, _, P3 = solveFourBars(P1, P4, a, b, c, t)

	return group {
		circle(P1, a):set { style = "grid" },
		circle(P2, b):set { style = "grid" },
		circle(P4, c):set { style = "grid" },
		groundPoint(P1, 0.2, "gray"),
		groundPoint(P4, 0.2, "gray"),
		bar(P1, P4, 0.1, "yellow"),
		bar(P1, P2, 0.1, "red"),
		bar(P3, P4, 0.1, "green"),
		bar(P2, P3, 0.1, "blue")
	}
end

local a = var(0)

local sep = 6
local y = 3

e1 = group {
	Linkage(point(-sep, 0), 2, 2, 2, 1.5, a),
	title(point(-sep, 3), "Double Crank")
}
e2 = group {
	Linkage(point(0, 0), 2, 1, 2, 1.5, a),
	title(point(0, 3), "Double Rocker")
}
e3 = group {
	Linkage(point(sep, 0), 1, 2, 2, 1.5, a),
	title(point(sep, 3), "Crank - Rocker")
}


plot {
	e1, e2, e3
}

e1.opacity:set(0)
e2.opacity:set(0)
e3.opacity:set(0)

pause(1)

while sync() do
	fadeIn { e1 }
	tween(a, 5, 5, easing.Linear)
end

while sync() do
	fadeIn { e2 }
	tween(a, 10, 5, easing.Linear)
end

while sync() do
	fadeIn { e3 }
	tween(a, 15, 5, easing.Linear)
end

tween(a, 30, 15, easing.Linear)
erase(all(), 3)

