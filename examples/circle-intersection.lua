
A = point(0, 0)
r1 = 3

B = point(0, 0)
r2 = 2

c1 = circle(A, r1) 
draw { c1 }
pause(1)
c2 = circle(B, r2)
draw { c2 }
pause(2)

-- Currently the intersection points don't exits,
-- but their references have been created.
intersection1, intersection2 = intersect(c1, c2)

plot {
	intersection1, intersection2
}

pause(1)

tween(B, point(-4, 0), 5)

pause(1)
