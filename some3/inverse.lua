
include "mechanics.lua"

slide("Synthesis of Mechanisms", 20)

L2 = 2

-- three angles and coordinates
a1, c1 = degrees(-30), point(-1, 3)
a2, c2 = degrees(-60), point(0, 0)
a3, c3 = degrees(0), point(-0.5, -2.5)

d1 = c1 + polar(L2, a1)
d2 = c2 + polar(L2, a2)
d3 = c3 + polar(L2, a3)

draw { segment(c1, d1), c1, d1, time = 3, label(c1, "P[_2]"), label(d1, "P[_3]") }
draw { segment(c2, d2), c2, d2, time = 3, label(c2, "P[_2]'"), label(d2, "P[_3]'")  }
draw { segment(c3, d3), c3, d3, time = 3, label(c3, "P[_2]''"), label(d3, "P[_3]''")  }

pause(10)

draw(plot { polyline(c1, c2, c3), back = true, style = "grid", time = 3 })

draw(plot {
	bisect(c1, c2):set { style = "construction" },
	bisect(c2, c3):set { style = "construction" },
	back = true
})

P1 = intersect(bisect(c1, c2), bisect(c2, c3))
draw { P1, label(P1, "P[_1]") }
draw(plot { circle(P1, c1), back = true })


pause(1)

draw(plot { polyline(d1, d2, d3), back = true, style = "grid", time = 3 })

draw(plot {
	bisect(d1, d2):set { style = "construction" },
	bisect(d2, d3):set { style = "construction" },
	back = true
})

P4 = intersect(bisect(d1, d2), bisect(d2, d3))
draw { P4, label(P4, "P[_4]") }
draw(plot { circle(P4, d1), back = true })

pause(1)

pause(2)

L1 = len(P1 - c1)
L3 = len(d1 - P4)

t = azimuth(c1 - P1)
P2, P3 = solveFourBars(P1, P4, L1, L2, L3, t)


draw {
	bar(P3, P4, 0.25, "green"),
	bar(P2, P3, 0.25, "blue"),
	bar(P1, P2, 0.25, "red")
}

pause(1)

tween(t, azimuth(c3 - P1), 5)
tween(t, azimuth(c1 - P1), 2)
tween(t, azimuth(c3 - P1), 2)

pause(2)

erase(all(), 2)
