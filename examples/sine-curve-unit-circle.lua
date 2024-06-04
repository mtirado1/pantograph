R = 1
center = point(-6, 0)
angle = var(0)

dot = center + polar(R, angle)
curve_point = point(center.x + R + angle, dot.y)

function sine(t)
	return center + point(R + t, math.sin(t))
end

draw {
	horizontal(ORIGIN, 16),
	vertical(center, 3),
	style = "grid"
}

while sync() do
	local ticks = { "[pi]", "2[pi]", "3[pi]", "4[pi]" }
	for i = 1, 4 do
		local x = center.x + R + i * math.pi
		draw {
			vertical(point(x, 0), 0.2):set { style = "grid" },
			text(point(x, -0.5), ticks[i]),
			delay = (i - 1) * 0.25
		}
	end

	draw {
		segment(dot, curve_point):set { style = "grid" },
		curve(sine, 0, angle),
		circle(center, R),
		segment(center, dot),
		dot
	}
end

pause(1)
tween(angle, 4 * math.pi, 10)
tween(angle, 0, 5)
pause(1)
erase(all())
