
-- polar() creates a point given a radius and angle
function f(a)
	return polar(2, a) + polar(0.5, 7 * a)
end

pause(1)

draw {
	-- Draw curve from 0 to 2pi, using 300 points
	curve(f, 0, 2 * math.pi, 300),
	time = 3
}

pause(1)
