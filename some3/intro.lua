
include "mechanics.lua"

-- Engine

function drawPiston(center, L1, L2, axis, angle)
	local p2, p3 = solvePiston(center, L1, L2, axis, angle)

	return group {
		bar(center, p2, 0.25, "red"),
		block(p3, azimuth(axis), 1, 1.5, "green"),
		bar(p2, p3, 0.25, "blue")
	}
end


center = point(0, -3)
v1 = point(4, 8)
v2 = point(-4, 8)


angle = var(0)

local pistons = group {
	groundPoint(center, 0.5, "gray"),
	drawPiston(center, 1, 4, line(center, v1), angle),
	drawPiston(center, 1, 4, line(center, v2), angle + math.pi)
}

plot { pistons }
pistons.opacity:set(0)

pause(1)

while sync() do
	fadeIn { pistons }
	tween(angle, 5 * math.pi, 2, easing.Linear)
end

while sync() do
	erase {
		pistons,
		time = 1,
		delay = 1
	}
	tween(angle, 10 * math.pi, 2, easing.Linear)
end

pause(0.5)

-- Windshield wipers

O = point(-6, -3.5)
C = point(3, -1)
D = point(-2, -1)

L1 = 1
L2 = 9
L3 = 5
L4 = 2

t = var(0)

A = O + polar(L1, t)

B = intersect(circle(A, L2), circle(C, L4))
E = intersect(circle(D, L4), circle(B, L3))

x1, y1 = coordinates(E, D)
x2, y2 = coordinates(B, C)

wiper = group {
	groundPoint(O, 0.5, "gray"),
	groundPoint(C, 0.5, "gray"),
	groundPoint(D, 0.5, "gray"),
	bar(O, A, 0.25, "red"),
	bar(A, B, 0.25, "blue"),
	bar(E, B, 0.25, "blue"),
	bar(B, C, 0.25, "green"),
	bar(E, D, 0.25, "green"),
	polyline(E, E + 2 * x1, E + 6 * x1 + 2 * y1),
	polyline(B, B + 2 * x2, B + 6 * x2 + 2 * y2)
}

draw { wiper }

tween(t, revolutions(4), 2, easing.Linear)

erase { wiper }

-- Pantograph

O = point(-3, -3)
draftPoint = point(-1, -3)

draftLength = 8
draftScale = 3
effectiveScale = draftLength / draftScale


_, P1 = intersect(circle(O, draftScale), circle(draftPoint, draftScale))

P2 = O + draftLength * (P1 - O) / draftScale

P3 = intersect(circle(draftPoint, draftLength - draftScale), circle(P2, draftScale))

plotPoint = P2 + draftLength * (P3 - P2) / draftScale

pantograph = group {
	groundPoint(O, 0.5, "gray"),
	bar(O, P2, 0.25, "blue"),
	bar(P2, plotPoint, 0.25, "blue"),
	bar(P1, draftPoint, 0.25, "red"),
	bar(draftPoint, P3, 0.25, "red")
}

draw {
	pantograph
}


t = var(0)
square = lerp {
	point(-1, -3),
	point(0, -3),
	point(0, -2),
	point(-0.5, -2.5),
	point(-1, -2),
	point(-1, -3),
	t = t
}

local O2 = O * (1 - effectiveScale)
smallSquare = polygon(
	point(-1, -3),
	point(0, -3),
	point(0, -2),
	point(-0.5, -2.5),
	point(-1, -2)
)
amplifiedSquare = polygon(
	O2 + point(-1, -3) * effectiveScale,
	O2 + point(0, -3) * effectiveScale,
	O2 + point(0, -2) * effectiveScale,
	O2 + point(-0.5, -2.5) * effectiveScale,
	O2 + point(-1, -2) * effectiveScale
)

draftPoint:set(square)

while sync() do
	tween(t, 1, 2)
	draw {
		amplifiedSquare,
		smallSquare,
		time = 2,
		back = true
	}
end

pause(0.5)

erase {
	amplifiedSquare,
	smallSquare,
	pantograph
}

-- Arm


armBase = point(-4, 2)
L1 = 5
L2 = 5

angle = var(degrees(-90))
stretch = var(1)

p2 = armBase + polar(L1, angle)

mid = midpoint(armBase, p2)

c1 = circle(mid, stretch)
c2 = circle(p2, L2/2)

_, q = intersect(c1, c2)

s = segment(mid, q)
arm = group {
	groundPoint(armBase, 0.5, "gray"),
	s,
	block(mid, azimuth(s), 0.5, 0.5, "green"),
	block(q, azimuth(s), 0.5, 0.5, "green"),
	bar(armBase, p2, 0.25, "red"),
	bar(p2, p2 + 2 * (q - p2), 0.25, "blue"),
}

draw { arm }


while sync() do
	tween(angle, degrees(-30), 1)
	tween(stretch, 3, 1)
end

while sync() do
	tween(angle, degrees(-10), 1)
	tween(stretch, 4.5, 0.5)
end

while sync() do
	tween(angle, degrees(-60), 1)
	tween(stretch, 1, 0.5)
end

erase { arm }
pause(1)
