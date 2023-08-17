

C = point(0, 0)
R = 3

A, B = point(-4, -3), point(1, 2)

-- The center
draw {
	C, label(C, "C"),
	time = 2
}

pause(1)

-- The radius
local s = segment(C, C + point(R, 0)):set { style = "grid" }
draw {
	s, label(s, "R"),
	circle(C, R),
	back = true,
	time = 2,
}

pause(1)

-- The line
draw {
	A, B,
	label(A, "A"),
	label(B, "B"),
	time = 1
}

draw {
	line(A, B), back = true, time = 2
}

pause(3)

draw {
	text(point(-8, 4), {
		"[b X](t) = [b A] + [b D]t",
		"[b D] = [b B] - [b A]"
	})
}
local t = 0.4
local X = A + (B - A) * t
local X_label = label(X, "X(t)")
draw {
	X, X_label
}

pause(15)

draw {
	text(point(-8, 2), {
		"|[b X] - [b C]|[^2] = R[^2]"
	})
}
pause(2)


draw {
	text(point(-8, 0), {
		"|[b A] + [b D]t - [b C]|[^2] - R[^2] = 0",
		"[b [Delta]] = [b A] - [b C]"
	})
}
pause(5)

local i1, i2 = intersect(line(A, B), circle(C, R))
i1.style = "largePoint"
i2.style = "largePoint"

while sync() do
	fadeOut {
		X, X_label
	}

	draw {
		text(point(0, -4), {
			"t = [() -[b D][dot][b [Delta]] [pm] [sqrt K]] / |[b D]|[^2]",
			"K = ([b D][dot][b [Delta]])[^2] - |[b D]|[^2] (|[b [Delta]]|[^2] - R[^2])",
			align = "middle"
		}),
		i1, i2, label(i1, "t[_1]"), label(i2, "t[_2]"),
		time = 2
	}
end

pause(3)

D = B - A
Delta = A - C

K = dot(D, Delta)^2 - len(D)^2 * (len(Delta)^2 - R^2)

draw {
	text(point(6, -3), "K = []", K),
	time = 2
}
pause(2)


tween(B, point(1, -2), 3)
pause(4)

while sync() do
	tween(B, point(-3, -2), 3)
	tween(A, point(-3, 2), 3)
end
pause(4)

tween(A, point(-4, 2), 3)
pause(4)

fadeOut(all(), 2)

pause(1)
