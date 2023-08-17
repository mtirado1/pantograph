
include "mechanics.lua"

local ratio = var(-2)

L1, L2, L3, L4 = 2, 5, 4, 2

P1 = point(-2, -2)
P5 = point(2, -2)

angle = var(0)
local P2, _, P3, P4 = solveFiveBars(P1, P5, L1, L2, L3, L4, angle, angle * ratio)

local c = fiveBarsTrajectory(P1, P5, L1, L2, L3, L4, ratio, 0)

local fiveBar = group {
	gear(P1, 8/3, angle, "yellow"),
	gear(P5, 4/3, ratio * angle, "yellow"),
	groundPoint(P1, 0.5, "gray"),
	groundPoint(P5, 0.5, "gray"),
	bar(P1, P2, 0.25, "red"),
	bar(P2, P3, 0.25, "blue"),
	bar(P3, P4, 0.25, "green"),
	bar(P4, P5, 0.25, "blue"),
	curve(c, 0, 2 * math.pi, 300)
}

draw { fiveBar, time = 3}


pause(1)

tween(angle, revolutions(1), 10)

erase(all())
