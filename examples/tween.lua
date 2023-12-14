
-- Creation of variable x
x = var(-2) 

-- This sets x to the number 0, the variable reference is lost
-- x = 0

-- The proper way of updating the variable x is:
set(x, 0)

-- y is a variable that evaluates to 2 * sin(x)
y = 2 * math.sin(x)

P = point(x, y)

draw { P }
pause(1)
tween(x, 3, 2) -- Tween x to 3 in 2 seconds
pause(1)
tween(x, -3, 2)
pause(1)
