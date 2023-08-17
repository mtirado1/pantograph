include "mechanics.lua"

P1 = point(-6, -2)
P4 = point(0, -2)

A = var(degrees(60))

L1, L2, L3 = 2, 6, 3

P2, _, P3 = solveFourBars(P1, P4, L1, L2, L3, A)

for k = -60, 60, 20 do
	f = value(A) + degrees(k)
	local p2, _, p3 = solveFourBars(P1, P4, L1, L2, L3, f)
	b = bar(p2, p3, 0.3, "blue")
	plot { b }
	b:set { opacity = 0.25 }
end

plot {
	circle(P1, P2),
	circle(P4, P3),
	circle(P2, P3),
	line(P2, P3),
	style = "grid"
}

plot { 
	groundPoint(P1, 0.6, "gray"),
	groundPoint(P4, 0.6, "gray"),
	bar(P1, P2, 0.3, "red"),
	bar(P3, P4, 0.3, "green"),
	bar(P2, P3, 0.3, "blue")
}

c = P2
local angle = (P3 - P2):azimuth()
dx = 11

spacing = var(1)
for dy = -6, 0, 2 do
	local trajectory = fourBarsTrajectory(P1, P4, L1, L2, L3, dx, dy * spacing)
	local c = curve(trajectory, 0, 2 * math.pi)
	plot { c, back = true }
end

for dy = -6, 0, 2 do
	local p = point(dx, dy * spacing):rotate(angle) + c
	p.style = "largePoint"
	plot { p }
end

plot {
	title(point(-9, 3.5), {"[xxlarge The [large MATHEMATICS]]", "[xxlarge of [large KINEMATIC CHAINS]]", height = 3 }),
	title(point(-9, -4.5), {"[large #SOME3]"})
}


frame "cover.svg"
