
include "mechanics.lua"

P1 = point(-3, -2)
L1 = 1
L2 = 3
L3 = 4
Lpump = 0.5
L4 = 4

P4 = P1 + point(L1 + L3, L2)
P1.style = "largePoint"
P4.style = "largePoint"

t = var(0)

P2 = P1 + polar(L1, t)

c1 = circle(P2, L2)
c2 = circle(P4, L3)

_, P3 = intersect(c1, c2)

P5 = P4 + (P4 - P3) * Lpump

axis = line(P4 + point(L3 * Lpump, 0), P4 + point(L3 * Lpump, -5))

c3 = circle(P5, L4)
cylinder = intersect(c3, axis)


size = 0.25

diagram = group {
	c1:set { style = "grid" },
	c2:set { style = "grid" },
	c3:set { style = "grid" },
	axis:set { style = "grid" },
	angle(P1, P2),
	polyline(P1, P2, P3, P5, cylinder),
	P1, P2, P3, P4, P5, cylinder,
	label(P1, "P[_1]"),
	label(P2, "P[_2]"),
	label(P3, "P[_3]"),
	label(P4, "P[_4]"),
	label(P5, "P[_5]"),
	label(cylinder, "P[_6]"),
}

pump = group {
	groundPoint(P1, size * 2, "gray"),
	groundPoint(P4, size * 3, "gray"),
	bar(P1, P2, size, "red"),
	block(cylinder, 0, 1.5, 0.75, "green"),
	bar(P5, cylinder, size / 1.5, "red"),
	bar(P2, P3, size, "blue"),
	bar(P3, P4, size * 1.5, "blue"),
	bar(P4, P5, size * 1.5, "blue")
}


draw { pump, time = 2 }

tween(t, 10 * math.pi, 5, easing.Linear)

while sync() do
	fadeOut { pump, time = 3}
	draw { diagram, time = 3}
	tween(t, 20 * math.pi, 9, easing.Linear)
end

erase { diagram, time = 2 }
