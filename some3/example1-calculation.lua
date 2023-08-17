
include "mechanics.lua"


slide("Analysis of Mechanisms", 12)

A = point(-3, 2)
B = point(-1, -2)
C = point(2, 1)

m = group {
	bar(A, B, 0.3, "red"),
	bar(B, C, 0.3, "blue")
}

fadeIn { m }
tween(m.opacity, 0.25, 1)
draw {
	polyline(A, B, C),
	A, B, C
}

pause(2)

erase(all())

p1 = point(-3, 0)
Y = var(-1.5)
axis = horizontal(Y)
L1, L2 = var(2), var(5)

t = var(degrees(45))

p2, p3a, p3b = solvePiston(p1, L1, L2, axis, t)

local piston = group {
	groundPoint(p1, 0.6, "gray"),
	axis, block(p3a, azimuth(axis), 2, 0.6, "green"),
	bar(p1, p2, 0.3, "red"),
	bar(p2, p3a, 0.2, "blue")
}


draw { piston }

while sync() do
	tween(piston.opacity, 0.25, 2)
end

p1.style = "largePoint"
draw {
	p1, label(p1, "P[_1]"), time = 2
}

pause(2)

while sync() do
	draw {
		polyline(p1, point(p2.x, p1.y), p2):set { style = "construction" },
		segment(p1, p2),
		time = 2
	}
	draw {
		p2, label(p2, "P[_2]"), time = 2
	}
end

pause(2)

t2 = var(-2)
P_guess = point(t2, Y)
draw {
	horizontal(Y):set { style = "grid" },
	P_guess,
	time = 2
}

tween(t2, 2, 4)
tween(t2, -2, 4)

fadeOut { P_guess, time = 2 }

draw {
	circle(p2, p3a):set { style = "construction" },
	segment(p2, p3a),
	label(segment(p2, p3a), "L[_2]"),
	back = true,
	time = 2
}

draw {
	p3a,
	label(p3a, "P[_3]"),
	time = 2
}

pause(6)

erase(all())
