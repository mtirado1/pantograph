local vectorMethods = {}
vectorMethods.__index = vectorMethods

function vectorMethods.scale(v, k)
	return Vector(v.x * k, v.y * k, v.z * k)
end

function vectorMethods.dot(a, b)
	return a.x * b.x + a.y * b.y + a.z * b.z
end

function vectorMethods.cross(a, b)
	return Vector(
		a.y * b.z - a.z * b.y,
		a.z * b.x - a.x * b.z,
		a.x * b.y - a.y * b.x
	)
end

function vectorMethods.azimuth(self)
	return math.atan2(self.y, self.x)
end

function vectorMethods.add(a, b)
	return Vector(a.x + b.x, a.y + b.y, a.z + b.z)
end

function vectorMethods.length(self)
	return math.sqrt(self.x^2 + self.y^2 + self.z^2)
end

function vectorMethods.transform(self, m)
	return Vector(
		m[1][1] * self.x + m[1][2] * self.y + m[1][3] * self.z + m[1][4],
		m[2][1] * self.x + m[2][2] * self.y + m[2][3] * self.z + m[2][4],
		m[3][1] * self.x + m[3][2] * self.y + m[3][3] * self.z + m[3][4]
	)
end


-- default 2D rotation
function vectorMethods:rotate(angle)
	local cos = math.cos(angle)
	local sin = math.sin(angle)
	return Vector(
		self.x * cos - self.y * sin,
		self.x * sin + self.y * cos,
		self.z
	)
end

function vectorMethods.rotateX(angle)
	local cos = math.cos(angle)
	local sin = math.sin(angle)
	return Vector(
		self.x,
		self.y * cos - self.z * sin,
		self.y * sin + self.z * cos
	)
end

function vectorMethods.rotateY(angle)
	local cos = math.cos(angle)
	local sin = math.sin(angle)
	return Vector(
		self.x * cos + self.z * sin,
		self.y,
		self.x * -sin + self.z * cos
	)
end

vectorMethods.rotateZ = vectorMethods.rotate

function vectorMethods.angleBetween(self, other)
	return math.acos(self:dot(other) / (#self * #other))
end

function vectorMethods.unitVector(self)
	return self / self:length()
end

function vectorMethods.__mul(a, b)
	if type(a) == "number" then
		return b:scale(a)
	elseif type(b) == "number" then
		return a:scale(b)
	else
		return nil
	end
end

function vectorMethods.__div(a, b)
	if type(b) == "number" then
		return a:scale(1/b)
	else
		return nil
	end
end

function vectorMethods.__add(a, b)
	if getmetatable(a) == vectorMethods
	and getmetatable(b) == vectorMethods then
		return a:add(b)
	else
		return nil
	end
end

function vectorMethods.__unm(v)
	return v:scale(-1)
end

function vectorMethods.__sub(a, b)
	if getmetatable(a) == vectorMethods
	and getmetatable(b) == vectorMethods then
		return a:add(-b)
	else
		return nil
	end
end

function vectorMethods.__eq(a, b)
	return  a.x == b.x
		and a.y == b.y
		and a.z == b.z
end

function vectorMethods.__len(a)
	return a:length()
end

function vectorMethods.__tostring(v)
	return "(" .. v.x .. ", " .. v.y .. ", " .. v.z .. ")"
end

function vectorMethods.__concat(a, b)
	return tostring(a) .. tostring(b)
end

-- Vector
function Vector(x, y, z)
	local v = {
		x = x or 0,
		y = y or 0,
		z = z or 0
	}
	setmetatable(v, vectorMethods)
	return v
end

function P(x, y, z)
	return Vector(x, y, z)
end

function Polar(r, angle)
	return Vector(math.cos(angle), math.sin(angle)) * r
end

function Spherical(r, rightAscension, declination)
	return Vector(
		r * math.cos(declination) * math.cos(rightAscension),
		r * math.cos(declination) * math.sin(rightAscension),
		r * math.sin(declination)
	);
end

-- Matrix

local matrixMethods = {}
matrixMethods.__index = matrixMethods

function matrixMethods.__mul(a, b)
	if type(a) == "number" then
		return b:scale(a)
	elseif type(b) == "number" then
		return a:scale(b)
	end

	local m = { 
		{ 0, 0, 0, 0 },
		{ 0, 0, 0, 0 },
		{ 0, 0, 0, 0 },
		{ 0, 0, 0, 0 }
	}
	for i = 1, 4 do
	for j = 1, 4 do
	for k = 1, 4 do
		m[i][j] = m[i][j] + a[i][k] * b[k][j]
	end end end
	return Matrix(m)
end

function matrixMethods.scale(self, k)
	local m = Matrix {
		{k, 0, 0, 0},
		{0, k, 0, 0},
		{0, 0, k, 0},
		{0, 0, 0, 1}
	}
	return m * self
end

function matrixMethods.translate(self, v)
	local m = Matrix {
		{1, 0, 0, v.x or 0},
		{0, 1, 0, v.y or 0},
		{0, 0, 1, v.z or 0},
		{0, 0, 0, 1},
	}
	return m * self
end

function matrixMethods.rotateX(self, angle)
	local sin = math.sin(angle)
	local cos = math.cos(angle)
	local m = Matrix {
		{1, 0, 0, 0},
		{0, cos, -sin, 0},
		{0, sin, cos, 0},
		{0, 0, 0, 1}	
	}
	return m * self
end

function matrixMethods.rotateY(self, angle)
	local sin = math.sin(angle)
	local cos = math.cos(angle)
	local m = Matrix {
		{cos, 0, sin, 0},
		{0, 1, 0, 0},
		{-sin, 0, cos, 0},
		{0, 0, 0, 1}	
	}
	return m * self
end

function matrixMethods.rotateZ(self, angle)
	local sin = math.sin(angle)
	local cos = math.cos(angle)
	local m = Matrix {
		{cos, -sin, 0, 0},
		{sin, cos, 0, 0},
		{0, 0, 1, 0},
		{0, 0, 0, 1}	
	}
	return m * self
end

function matrixMethods.rotate(self, angles)
	if type(angles) == "number" then
		return m:rotateZ(angles)
	end
	local m = self
	for i = 1, #angles.axis do
		local axis = string.sub(angles.axis, i, i)
		local angle = angles[i]
		if axis == "x" then
			m = m:rotateX(angle)
		elseif axis == "y" then
			m = m:rotateY(angle)
		elseif axis == "z" then
			m = m:rotateZ(angle)
		end
	end
	return m
end

function Matrix(m)
	local matrix = m or {
		{ 1, 0, 0, 0 },
		{ 0, 1, 0, 0 },
		{ 0, 0, 1, 0 },
		{ 0, 0, 0, 1 }
	}
	setmetatable(matrix, matrixMethods)
	return matrix
end
