
include "mechanics.lua"

t = var(degrees(30))

L1, L2, L3 = 2, 5, 3

P1 = point(-3, -1)
P4 = point(2, 0)

P2 = P1 + polar(L1, t)

_, P3 = intersect(circle(P2, L2), circle(P4, L3))


b1 = bar(P1, P2, 0.25, "red")
b2 = bar(P2, P3, 0.25, "blue")
b3 = bar(P4, P3, 0.25, "green")
b4 = bar(P1, P4, 0.25, "yellow")

pause(1)

slide("The Four Bar Linkage", 2)

while sync() do
	tween(t, degrees(120), 2, easing.Linear)
	draw { b1, time = 2 }
end

while sync() do
	tween(t, degrees(120 + 90), 2, easing.Linear)
	draw { b3, time = 2 }
end

while sync() do
	tween(t, degrees(120 + 180), 2, easing.Linear)
	draw { b2, time = 2 }
end

while sync() do
	tween(t, degrees(120 + 270), 2, easing.Linear)
	fadeIn(plot {
		b4, back = true
	}, 2)
end

tween(t, degrees(120 + 360 + 90), 4, easing.Linear)

while sync() do
	ground = group {
		groundPoint(P1, 0.5, "gray"),
		groundPoint(P4, 0.5, "gray")
	}
	tween(t, degrees(120 + 360 + 180), 2, easing.Linear)
	fadeOut { b4, time = 2 }
	fadeIn(plot {
		ground, back = true
	}, 2)
end

tween(t, degrees(120 + 720 + 360), 12, easing.Linear)

erase(all())
