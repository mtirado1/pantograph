
include "mechanics.lua"
slide("Degrees of Freedom", 12)

P = point(0, 0)


draw {
	X_AXIS:set { style = "grid" },
	Y_AXIS:set { style = "grid" },
	P
}


s1 = segment(point(P.x, 0), P) 
s2 = segment(ORIGIN, point(P.x, 0), P)

cartesianElements = plot {
	s1, s2,
	label(s1, "y"),
	label(s2, "x"),
	label(P, "x=[], y=[]", P.x, P.y)
}

while sync() do
	draw(cartesianElements, 5)
	plot { P }
	tween(P, point(2, 3), 3)
end

pause(1)

while sync() do
	fadeOut(cartesianElements, 5)
	polarElements = plot {
		segment(ORIGIN, P),
		label(segment(P, ORIGIN), "r"),
		label(angle(ORIGIN, P), "[theta]"),
		angle(ORIGIN, P),
		label(P, "r=[], [theta]=[][deg]", len(P), math.deg(azimuth(P)))
	}
	draw(polarElements, 5)
	plot { P }
	tween(P, point(-2, 2), 5)
end

pause(2)

erase(all())
