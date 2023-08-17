A = point(-4, -2)
B = point(5, 0.5)

draw {
	X_AXIS:set { style = "grid" },
	Y_AXIS:set { style = "grid" },
	line(A, B):set { style = "construction" },
	segment(A, B),
	A, B,
	label(A, "A"), label(B, "B"),
	time = 3
}

t = var(0.2)
P = A * (1 - t) + B * t
P.style = "largePoint"

draw {
	P,
	label(P, "t = []", t)
}

pause(1)

tween(t, 0.3, 1)
tween(t, 0.8, 2)
tween(t, 0.1, 2)
tween(t, -0.2, 1)

pause(0.5)

erase(all())

pause(1)
