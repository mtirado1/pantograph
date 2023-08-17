
include "mechanics.lua"
t = var(0)
a1 = var(degrees(20))
a2 = var(degrees(-30))
a3 = var(degrees(-60))


A = point(-1.5 + t, -3)
B = A + polar(4, a1)
C = B + polar(2, a2)
D = C + polar(1, a3)


draw { 
	horizontal(-3),
	groundPoint(A, 0.6, "gray"),
	bar(A, B, 0.3, "red"),
	bar(B, C, 0.3, "blue"),
	bar(C, D, 0.3, "green")
}

while sync() do
	tween(t, 3, 1)
	tween(a1, degrees(45), 1)
	tween(a2, degrees(60), 3)
	tween(a3, degrees(0), 2)
end

pause(1)

fadeOut(all())

t = var(0)

while sync() do
	tween(t, revolutions(2), 1, easing.Linear)
	fadeIn {
		groundPoint(point(-4, 0), 0.6, "gray"),
		bar(point(-4, 0), point(-4, 0) + polar(2, t), 0.3, "red"),
		title(point(-4, -4), "Revolute"),
		time = 1
	}
end

while sync() do
	tween(t, revolutions(4), 1, easing.Linear)
	fadeIn {
		segment(point(2, 0), point(6, 0)),
		block(point(4 + 2 * math.sin(t), 0), 0, 1, 0.5, "blue"),
		title(point(4, -4), "Prismatic"),
		time = 1
	}
end

while sync() do
	tween(t, revolutions(6), 1, easing.Linear)
	fadeOut(all())
end

pause(1)
