
include "mechanics.lua"

-- Hand crank


t = var(0)


O = point(-1, 0)
handCrank = group {
	gear(O, 1, t, "yellow"),
	gear(O + point(3, 0), 2, -t/2, "blue"),
	bar(O, O + polar(3, t + degrees(180)), 0.25, "red")
}

draw { handCrank }

tween(t, degrees(30), 0.5)
tween(t, degrees(60), 0.5)
tween(t, degrees(120), 1)
tween(t, degrees(0), 0.5)

pause(1)

erase { handCrank }



O = point(0, 0)
t:set(0)
motor = group {
	groundPoint(O, 0.5, "gray"),
	bar(O, polar(2, t), 0.25, "red"),
	bar(O, polar(2, t + degrees(120)), 0.25, "red"),
	bar(O, polar(2, t + degrees(240)), 0.25, "red"),
}

draw { motor }

tween(t, revolutions(2), 2)

pause(1)

erase { motor }

-- Pliers



P1, P4 = point(-3, 0), point(3, 0)

L1, L2, L3 = 5, 1, 1
t = var(degrees(10))

P2, _, P3 = solveFourBars(P1, P4, L1, L2, L3, t)

x, y = coordinates(P2, P3)
pHandle = P2 -5*x + y

pliers = group {
	bar(P1, P4, 0.25, "gray"),
	bar(P4, P4 + (P4 - P1)/6, 0.25, "gray"),
	bar(P1, P2, 0.25, "gray"),
	bar(pHandle, P2, 0.25, "blue"),
	bar(P2, P3, 0.25, "gray"),
	bar(P3, 2*P3 - P2, 0.25, "gray"),
	bar(P3, P4, 0.25, "gray")
}

draw { pliers }

tween(t, degrees(15), 1)
tween(t, degrees(9), 1)
tween(t, degrees(15), 1)

erase { pliers }

pause(1)
