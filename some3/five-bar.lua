
include "mechanics.lua"

slide("The Five Bar Linkage", 3)

local ratio = var(-1)

L1, L2, L3, L4 = var(3), var(4), var(6), var(3)

P1 = point(-3, -1)
P5 = point(3, -1)

angle = var(0)
angle2 = var(0)
local P2, _, P3, P4 = solveFiveBars(P1, P5, L1, L2, L3, L4, angle, angle2)

local c = fiveBarsTrajectory(P1, P5, L1, L2, L3, L4, ratio, 0)

local fiveBarNoGear = group {
	groundPoint(P1, 0.5, "gray"),
	groundPoint(P5, 0.5, "gray"),
	bar(P1, P2, 0.25, "red"),
	bar(P2, P3, 0.25, "blue"),
	bar(P3, P4, 0.25, "green"),
	bar(P4, P5, 0.25, "blue"),
}

draw { fiveBarNoGear }

tween(angle, degrees(30), 4)
tween(angle2, degrees(20), 4)
tween(angle2, -angle, 4)

angle2:set(-angle)

pause(2)

erase { fiveBarNoGear }


pause(2)

local fiveBar = group {
	gear(P1, 6 - 3 / math.abs(ratio), angle, "yellow"),
	gear(P5, 3 / math.abs(ratio), ratio * angle, "yellow"),
	groundPoint(P1, 0.5, "gray"),
	groundPoint(P5, 0.5, "gray"),
	bar(P1, P2, 0.25, "red"),
	bar(P2, P3, 0.25, "blue"),
	bar(P3, P4, 0.25, "green"),
	bar(P4, P5, 0.25, "blue"),
	curve(c, 0, 2 * math.pi)
}

draw { fiveBar }


pause(1)

tween(angle, 2 * math.pi, 6)

while sync() do
	tween(L1, var(2), 1)
	tween(L4, var(2), 1)
	tween(L3, var(4), 1)
end

tween(angle, 4 * math.pi, 6)

erase(all())
