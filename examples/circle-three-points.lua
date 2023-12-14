-- circle-three-points.lua
-- Constructs a circle given three points.

A = point(1.5, -1)
B = point(2.5, 1)
C = point(-1.5, -2)

-- Draws a pointer
function pointer(center)
	return polygon(
		center,
		center + point(-0.2, -0.6),
		center + point(0, -0.5),
		center + point(0.2, -0.6)
	):set { style = "brown" }
end

-- Draws a circle with a basic compass animation
function compass(c, time, layer, style)
	time = time or 1
	local angle = var(0)
	local a, b = c.center, c.radius
	local tracer = segment(a, a + (b-a):rotate(angle))
	tracer:set { style = Stroke(colors.brown, 7) }
	
	while sync() do
		fadeIn { tracer, time = 0.25, layer = "compass" }
		fadeOut { tracer, delay = time - 0.25, time = 0.25 }
		tween(angle, 2 * math.pi, time)
		draw { c, time = time, layer = layer, style = style }
	end
end

setLayers { "grid", "main", "compass", "points" }

draw { A, B, C, layer = "points", style = "largePoint", step = 0.5 }
pause(1)

C1, C2 = circle(A, B), circle(B, A)
C3, C4 = circle(C, A), circle(A, C)

compass(C1, 1, "grid", "grid")
compass(C2, 1, "grid", "grid")
pause(1)

compass(C3, 1, "grid", "curve")
compass(C4, 1, "grid", "curve")
pause(1)

L1 = line(intersect(C1, C2))
L2 = line(intersect(C3, C4))

I1, I2 = intersect(C1, C2)
L1 = line(I1, I2)
draw { I1, I2, layer = "points" }
draw { L1, layer = "grid", style = "grid" }
pause(1)

I3, I4 = intersect(C3, C4)
L2 = line(I3, I4)
draw { I3, I4, layer = "points" }
draw { L2, layer = "grid", style = "curve" }
pause(1)

centerPoint = intersect(L1, L2)

draw { centerPoint, layer = "points", style = "largePoint" }
pause(1)

compass(circle(centerPoint, A), 2)
pause(3)

while sync() do
	local p = pointer(A)
	fadeIn { p, layer = "points", time = 0.5 }
	fadeOut { p, time = 0.5, delay = 4.5 }
	tween(A.x, -1.5, 5)
end

pause(3)
while sync() do
	fadeOut { I1, I2, I3, I4, time = 1 }
	fadeOut(all "grid", 1)
end
pause(2)
erase(all(), 2)
