
include "mechanics.lua"

t = var(0.1)

P1 = point(-4, -2)

P2 = point(4, 1)

P = P1 * (1 - t) + P2 * t

measurements = group {
	datum(P1, 0.5, "grid"),
	datum(P2, 0.5, "grid"),
	label(P1, "P[_1]"),
	label(P2, "P[_2]"),
	measure(P1, P, "L[_1] = []", len(P1 - P)),
}

b = block(P, azimuth(P - P1), 0.8, 0.4, "green")
g = segment(P1, P2)

while sync() do
	tween(t, 0.9, 5)
	draw {
		g, b,
		title(point(0, -4), "Prismatic Joint")
	}
end

pause(2)

while sync() do
	tween(t, 0.5, 5)
	draw { measurements }
end
	
tween(t, 0.7, 2)

pause(1)
erase(all())
