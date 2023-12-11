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
		properties.testMode = true
		animate(content, properties)
		print("Done")
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
