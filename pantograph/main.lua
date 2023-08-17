local animate = require "pantograph.animation"

local function parseFlags(arguments, binaryFlags)
	local binaryFlagSet = {}
	for i, f in ipairs(binaryFlags) do
		binaryFlagSet[f] = true
	end

	local values = {}
	local i = 1
	local skip = false
	while i <= #arguments do
		if arguments[i] == "--" then
			skip = true
		end
		local flag = arguments[i]:match("^%-%-(.+)$")
		if flag and binaryFlagSet[flag] and not skip then
			values[flag] = true
		elseif flag and not skip then
			i = i + 1
			values[flag] = arguments[i]
		else
			table.insert(values, arguments[i])
		end

		i = i + 1
	end

	return values
end

local flags = parseFlags(arg, {"test"})

local properties = {
	fps = tonumber(flags.fps) or 30,
	width = tonumber(flags.width) or 960,
	height = tonumber(flags.height) or 540,
	testMode = flags.test,
	scale = tonumber(flags.scale) or 2,
}



if flags.test then
	print("Animation settings")
	print(string.format("%dx%d @ %d fps", properties.width, properties.height, properties.fps))
	print(string.format("Scale: %f", properties.scale))
	for i, filename in ipairs(flags) do
		print("Testing animation...")
		print(string.format("#%i: %s", i, filename))
		local f, err = io.open(filename)
		if err then
			print(err)
			os.exit(1)
		end
		local content = f:read("*a")
		properties.title = filename
		animate(content, properties)
		print("Done")
	end
else
	for i, filename in ipairs(flags) do
		local f = io.open(filename)
		local content = f:read("*a")
		animate(content, properties)
	end
end
