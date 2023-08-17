include "mechanics.lua"

slide("Jamming Positions", 4)

X = 3
X2 = math.sqrt(2) * X / 2

P1 = point(-X/2, -X)

P4 = point(X/2, -X)

local t = var(degrees(60))
P4_ext = P4 + 2 * (P4 - P1)
P1_ext = P2 + 2 * (P2 - P1)
P2, P3_alt, P3 = solveFourBars(P1, P4, X, X2, X2, t)

P4_ext = P4 + 1.5 * (P4 - P1)
P1_ext = P2 + 1.5 * (P2 - P1)

local mech = group {
	bar(P4, P4_ext, 0.25, "yellow"),
	bar(P1, P4, 0.25, "yellow"),
	bar(P1, P2, 0.25, "red"),
	bar(P2, P1_ext, 0.25, "red"),
	bar(P2, P3, 0.25, "blue"),
	bar(P3, P4, 0.25, "green"),
}

solution1 = polyline(P2, P3, P4)
solution1.opacity = var(1)
solution2 = polyline(P2, P3_alt, P4)
solution2.opacity = var(0)
local diagram = group {
	circle(P2, P3):set { style = "grid" },
	circle(P4, P3):set { style = "grid" },
	segment(P1, P1_ext),
	segment(P1, P4_ext),
	solution1, solution2,
	P1, P2, P3, P3_alt, P4,
}


draw {
	mech
}

pause(3)

tween(t, degrees(10), 2)
tween(t, degrees(90), 2)

pause(3)

colinear = line(P2, P4)
fadeIn { colinear, time = 2 }
pause(5)
fadeOut { colinear, time = 2 }

while sync() do
	tween(t, degrees(30), 3)
	fadeIn { diagram, time = 3 }
	fadeOut { mech, time = 3 }
end

pause(1)

labels = plot {
	label(P3, "P[_3]"),
	label(P3_alt, "P[_3]'")
}

fadeIn(labels)

pause(1)


while sync() do
	tween(solution1.opacity, 0, 1)
	tween(solution2.opacity, 1, 1)
end

while sync() do
	tween(solution1.opacity, 1, 1)
	tween(solution2.opacity, 0, 1)
end

tween(t, degrees(90), 8)

pause(3)

while sync() do
	tween(t, degrees(30), 5)
	tween(solution2.opacity, 0, 1)
	fadeOut(labels)
end

tween(t, degrees(90), 8)

tween(t, degrees(30), 15)

erase(all())
