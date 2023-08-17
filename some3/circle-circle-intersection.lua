include "mechanics.lua"

C1 = point(-5, -0.5)
R1 = 4

C2 = point(-1, 1.5)
R2 = 3


c1, c2 = circle(C1, R1), circle(C2, R2)

draw { c1, time = 2 }
draw { c2, time = 2 }
pause(8)
draw { C1, C2, label(C1, "C[_1]"), label(C2, "C[_2]") }
I1, I2 = intersect(c1, c2)
R1_line = segment(C1, I2):set { style = "blueStroke" }
R2_line = segment(I2, C2):set { style = "blueStroke" }
draw {
	R1_line, R2_line,
	label(R1_line, "R[_1]"),
	label(R2_line, "R[_2]"),
	back = true
}

pause(3)

local U = vector(C1, C2)
plot { U, style = "grid", back = true }
draw {
	U, label(U, "U"),
}

local V = perpendicular(U)
plot { V, style = "grid", back = true }
draw { V, label(V, "V") }

pause(5)

si, ti = project(C1, C2, I2)
S = segment(si, I2)
T = segment(ti, I2)
plot {
	S, T,
	style = "construction", back = true
}

draw {
	label(T, "s |[bold U]|"),
	label(S, "t |[bold V]|"),
	S, T 
}


pause(5)


draw { I1, I2, label(I1, "X[_2]"), label(I2, "X[_1]") }

pause(3)

draw {
	text(point(2.5, 4), {
		"|[bold U]| = |[bold V]|",
		"(s[^2] + t[^2]) |[bold U]|[^2] = R[_1][^2]",
		"((1 - s)[^2] + t[^2]) |[bold U]|[^2] = R[_2][^2]"
	})
}

pause(5)

draw {
	text(point(2.5, 2), {
		"(s[^2] + t[^2] - (1-s)[^2] - t[^2]) |[bold U]|[^2] = R[_1][^2] - R[_2][^2]"
	})
}

pause(5)

draw {
	text(point(2.5, 0), {
		"(2s - 1) |[bold U]| = R[_1][^2] - R[_2][^2]"
	})
}

pause(5)

draw {
	text(point(2.5, -1), {
		"s = (1/2) [() (R[_1][^2] - R[_2][^2]) / |[bold U]|[^2] + 1]",
	})
}

pause(5)

draw {
	text(point(2.5, -2), {
		"t[^2] = R[_1][^2] / |[bold U]|[^2] - s[^2]"
	})
}

pause(5)

draw {
	text(point(2.5, -4), {
		"X = [bold C][_1] + s[bold U] [pm] t[bold V]"
	})
}

pause(5)


tween(C2, point(2, -0.5), 1)
pause(5)
tween(C2, point(2, 1), 1)
pause(5)

erase(all())

pause(1)
