
include "mechanics.lua"

slide("What is a Mechanism?", 5)

P1 = point(-6, -2)
P4 = point(0, -2)

A = var(degrees(60))

L1, L2, L3 = 2, 6, 3

P2, _, P3 = solveFourBars(P1, P4, L1, L2, L3, A)


draw { 
	groundPoint(P1, 0.6, "gray"),
	groundPoint(P4, 0.6, "gray"),
	bar(P1, P2, 0.3, "red"),
	bar(P3, P4, 0.3, "green"),
	bar(P2, P3, 0.3, "blue"),
	time = 5
}

draw { 
	angle(P1, P2),
	label(angle(P1, P2), "[theta]"),
	text(point(4, 0), "[theta] = [][deg]", math.deg(A))
}

pause(1)

tween(A, degrees(90), 1)
tween(A, degrees(120), 1)
tween(A, degrees(30), 1)

pause(1)

draw {
	measure(P1, P2, "L[_1]"),
	measure(P2, P3, "L[_2]"),
	measure(P3, P4, "L[_3]"),
	time = 3
}

pause(3)

erase(all())
