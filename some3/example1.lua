include "mechanics.lua"

slide("Building a Mechanism", 6)

p1 = point(-3, 0)
Y = var(-1.5)
axis = horizontal(Y)
L1, L2 = var(2), var(5)

t = var(0)

p2, p3a, p3b = solvePiston(p1, L1, L2, axis, t)

couplerAngle = (p3a-p2):azimuth():value()
a1, a2, a3 = var(0), var(couplerAngle), var(0)

draw {
	groundPoint(p1, 0.6, "gray"),
	bar(p1, p1 + polar(L1, a1), 0.3, "red"),
	time = 4
}

pause(3)

tween(a1, degrees(30), 0.5)
tween(a1, degrees(-30), 0.5)
tween(a1, degrees(0), 0.5)
tween(a1, degrees(30), 0.5)
tween(a1, degrees(0), 0.5)

pause(2)


draw {
	bar(p1 + polar(L1, a1), p1 + polar(L1, a1) + polar(L2, a2), 0.2, "blue"),
	time = 4
}
pause(2)

tween(a2, degrees(30), 0.5)
tween(a2, degrees(60), 0.5)
tween(a2, degrees(-30), 0.5)
tween(a2, degrees(-60), 0.5)
tween(a2, couplerAngle, 0.5)

pause(2)

draw {
	block(p1 + polar(L1, a1) + polar(L2, a2), a3, 2, 0.6, "green"),
	back = true,
	time = 4
}


pause(2)

tween(a3, degrees(30), 0.5)
tween(a3, degrees(-30), 0.5)
tween(a3, degrees(0), 0.5)

remove(all())
plot {
	groundPoint(p1, 0.6, "gray"),
	block(p3a, 0, 2, 0.6, "green"),
	bar(p1, p2, 0.3, "red"),
	bar(p2, p3a, 0.2, "blue")
}
draw { axis, back = true}

pause(5)

tween(t, revolutions(10), 10, easing.Linear)

pause(1)

erase(all())
