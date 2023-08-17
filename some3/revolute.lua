
include "mechanics.lua"

t = var(0)
t2 = var(0)

pause(1)

P1 = ORIGIN
P2 = P1 + polar(2, t)
P3 = P2 + polar(3, t2)

angles = group {
	datum(P1, 0.5, "grid"),
	datum(P2, 0.5, "grid"),
	angle(P1, P2),
	angle(P2, P3),
	label(angle(P1, P2), "[theta][_1]"),
	label(angle(P2, P3), "[theta][_2]")
}
a = groundPoint(P1, 0.5, "gray")
b = bar(P1, P2, 0.25, "red")
c = bar(P2, P3, 0.25, "blue")

while sync() do
	tween(t, revolutions(2), 5, easing.Linear)

	draw { a, b, title(point(0, -4), "Revolute Joint") }
end

while sync() do
	tween(t, revolutions(4), 5, easing.Linear)
	tween(t2, revolutions(4), 5, easing.Linear)
	draw { c, angles }
end

erase(all())

-- Gears


A = point(-2, 0)
B = point(2, 0)

t = var(0)

draw {
	gear(A, 3, t, "red"),
	gear(B, 1, -3*t, "yellow")
}

tween(t, revolutions(1), 2, easing.Linear)
while sync() do
	fadeOut(all())
	fadeIn {
		groundPoint(A, 0.5, "gray"),
		groundPoint(B, 0.5, "gray"),
		bar(A, A + polar(3, t), 0.25, "red"),
		bar(B, B + polar(1, -3*t), 0.25, "blue")
	}
	tween(t, revolutions(3), 6, easing.Linear)
end

erase(all())

pause(1)
