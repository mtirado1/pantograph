
include "mechanics.lua"

A = point(-5, 0)
B = point(-3, 0)

L1 = 1
L2 = var(2)

t = var(0)

C = A + polar(L1, t)

mechanism = group {
	groundPoint(A, 0.4, "gray"),
	groundPoint(B, 0.4, "gray"),
	bar(A, C, 0.2, "red"),
	segment(C, C + (B - C):unitVector() * L2),
	block(B, (B - C):azimuth(), 1, 0.5, "blue"),
	B
}

function getCurve(x)
	local f = function(t)
		local c = A + polar(L1, t)
		return c + (B - c):unitVector() * x
	end
	return curve(f, 0, 2 * math.pi):set { style = "blueStroke" }
end


draw { mechanism }



while sync() do
	tween(t, revolutions(1), 2)
	draw { getCurve(2), back = true, time = 2 }
end

tween(L2, 4, 0.5)
while sync() do
	tween(t, revolutions(2), 2)
	draw { getCurve(4), back = true, time = 2 }
end

tween(L2, 7, 0.5)
while sync() do
	tween(t, revolutions(3), 2)
	draw { getCurve(7), back = true, time = 2 }
end

tween(L2, 10, 0.5)
while sync() do
	tween(t, revolutions(4), 2)
	draw { getCurve(10), back = true, time = 2 }
end


pause(1)

fadeOut(all())
