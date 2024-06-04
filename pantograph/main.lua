local animate = require "pantograph.animation"
require "pantograph.utils"

VERSION = "0.1"

local flags = parseFlags(arg, {"render", "help", "version"}, {o = "output", h = "help", v = "version"})
local properties = {
	fps = tonumber(flags.fps) or 30,
	scale = tonumber(flags.scale) or 2,
	width = tonumber(flags.width) or 960,
	height = tonumber(flags.height) or 540,
}

if flags.version then
	print(string.format("Pantograph %s", VERSION))
elseif flags.help then
	print [[
Pantograph - Programmatic SVG and animation engine
  Usage:
  pantograph [options] files

  Options:
    --fps       Frames per second
    --scale     Canvas scale
    --width     Canvas width
    --height    Canvas height
    --output    Output file]]
elseif flags.render then
	for i, filename in ipairs(flags) do
		local f = io.open(filename)
		local content = f:read("*a")

		properties.update = function(image, frames)
			local output = image:render()
			for i = 1, frames do
				local cmd = string.format("rsvg-convert --width %d", properties.scale * properties.width)
				local f = io.popen(cmd, "w")
				f:write(output)
				f:flush()
				f:close()
			end
		end

		properties.frame = function(image, name)
			if name then
				local f = io.open(name, "w")
				f:write(image:render())
				f:close()
				return
			end
			print(image:render())
		end

		properties.print = function() end

		animate(content, properties)
	end
else
	print("Animation settings")
	print(string.format("%dx%d @ %d fps", properties.width, properties.height, properties.fps))
	print(string.format("Scale: %f", properties.scale))

	local files = {}
	for i, filename in ipairs(flags) do
		files[i] = filename
		print("Testing animation...")
		print(string.format("#%i: %s", i, filename))
		local f, err = io.open(filename)
		if err then
			print(err)
			os.exit(1)
		end
		local content = f:read("*a")
		properties.title = filename

		local frames = 1
		properties.update = function(image)
			frames = frames + 1
			local s = image:render()
		end

		properties.frame = properties.update
		properties.print = print

		local t1 = os.clock();
		animate(content, properties)
		local totalTime = os.clock() - t1
		print(string.format("Finished in %.2fms. (%d fps)" , totalTime * 1000, math.floor(frames / totalTime)))
	end

	exec(
		"pantograph --render --fps %s --scale %s --width %s --height %s %s | ffmpeg -hide_banner -y -r %s -i - -b:v 2M -pix_fmt yuv420p -vcodec libx264 %s",
		properties.fps,
		properties.scale,
		properties.width,
		properties.height,
		files,
		properties.fps,
		flags.output or "export.mp4"
	)
end
