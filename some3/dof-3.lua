
include "mechanics.lua"

L = 4
local t = var(degrees(0))
A = point(-2, 0)
B = A + polar(L, t)


draw { A, B }

pause(2)

local s1 = segment(A, B):set { style = "construction" }
local s1_label = label(s1, "L = []", L)
plot {
	s1, back = true
}

draw {
	s1, s1_label
}

pause(2)

local xSegment = segment(ORIGIN, point(A.x, 0))
local ySegment = segment(A, point(A.x, 0))
draw {
	X_AXIS:set { style = "grid" },
	Y_AXIS:set { style = "grid" },
	xSegment, ySegment,
	bar(A, B, 0.25, "red"),
	angle(A, B),
	label(angle(A, B), "[theta] = []°", math.deg(azimuth(B - A))),
	label(xSegment, "x"),
	label(ySegment, "y")
}

pause(1)

tween(t, degrees(120), 2)
tween(A, point(-2, -2), 2)
tween(t, degrees(-120), 2)
tween(A, point(-1, -1), 2)

pause(1)

draw {
	groundPoint(A, 0.5, "gray"),
	back = true
}

tween(t, degrees(390), 2)

pause(3)

draw(plot {
	groundPoint(B, 0.5, "gray"),
	back = true
})

pause(5)

erase(all())
