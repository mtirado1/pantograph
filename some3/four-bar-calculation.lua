
include "mechanics.lua"

slide("Analyzing the Four Bar Linkage", 3)

P1 = point(-4, -2)
P4 = point(4, 0)

L1, L2, L3 = var(3), var(8), var(4)
t = var(degrees(60))

P2 = P1 + polar(L1, t)

a = len(P4 - P2)

alpha = math.acos((L3^2 - L2^2 - a^2) / (-2 * L2 * a))
beta = math.asin((P2.y - P4.y) / a)

P3 = P2 + polar(L2, alpha - beta)

local mechanism = group {
	groundPoint(P1, 0.5, "gray"),
	groundPoint(P4, 0.5, "gray"),
	bar(P1, P2, 0.25, "red"),
	bar(P2, P3, 0.25, "blue"),
	bar(P3, P4, 0.25, "green")
}

fadeIn { mechanism }


tween(t, revolutions(1) + degrees(60), 2)
tween(t, revolutions(2) + degrees(60), 2)

pause(2)

while sync() do
	P1.style = "largePoint"
	P4.style = "largePoint"
	tween(mechanism.opacity, 0.25, 1)
	draw { P1, P4, label(P1, "P[_1]"), label(P4, "P[_4]") }
end

pause(4)

local theta = angle(P1, P2)
local diagram2 = group {
	segment(P1, P2),
	polyline(P1, point(P2.x, P1.y), P2):set { style = "grid" },
	label(segment(P1, P2), "L[_1]"),
	P2, theta,
	label(P2, "P[_2]"),
	label(theta, "[theta]")
}

draw {
	diagram2
}

pause(8)


t3 = var(degrees(0))

sweepSegment = segment(P4, P4 + polar(L3, t3)):set { style = "grid" }
draw {
	sweepSegment, label(sweepSegment, "L[_3]")
}
tween(t3, revolutions(1), 2)

pause(2)

t4 = var(degrees(0))
sweepSegment2 = segment(P2, P2 + polar(L2, t4)):set { style = "grid" }
draw {
	sweepSegment2, label(sweepSegment2, "L[_2]")
}
tween(t4, revolutions(1), 2)

pause(2)

while sync() do
	tween(t3, revolutions(2), 4)
	tween(t4, revolutions(2), 4)
	draw { circle(P2, L2), time = 4 }
	draw { circle(P4, L3), time = 4 }
end

pause(8)

erase(all())
