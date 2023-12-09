local function escapeArgument(arg)
	return "'" .. arg:gsub("'", [['"'"']]) .. "'"
end

function exec(cmd, ...)
	local args = { ... }
	for i, a in ipairs(args) do
		if type(a) == "table" then
			local result = {}
			for i, item in ipairs(a) do
				result[i] = escapeArgument(item)
			end
			args[i] = table.concat(result, " ")
		else
			args[i] = escapeArgument(tostring(a))
		end
	end
	
	print(string.format(cmd, table.unpack(args)))
	os.execute(string.format(cmd, table.unpack(args)))
end

function parseFlags(arguments, binaryFlags, shortFlags)
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
		local shortFlag = arguments[i]:match("^%-(.+)")
		if shortFlags[shortFlag] and not flag then
			flag = shortFlags[shortFlag]
		end

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

local equationCounter = 0
function generateEquation(equation)
	-- A shell script generates the equation on a file
	-- Requires:
	-- pdflatex, pdfcrop, pdf2svg
	local proc = io.popen(string.format([[
DIR=~/.config/pantograph
TEX="$DIR/tmp.tex"

PDF="$DIR/tmp.pdf"
CROP="$DIR/tmp_crop.tex"
SVG="$DIR/equation.svg"

mkdir -p "$DIR"

writeTex() {
	echo '\documentclass{article}' > "$TEX"
	echo '\usepackage{amsmath}' >> "$TEX"
	echo '\usepackage{amssymb}' >> "$TEX"
	printf "%%s\n" "\\begin{document}" >> "$TEX"
	echo '\pagestyle{empty}' >> "$TEX"
	printf "\$\$%%s\$\$\n" "$1" >> "$TEX"
	printf "%%s\n" "\\end{document}" >> "$TEX"

	pdflatex -halt-on-error -output-directory "$DIR" tmp.tex > /dev/null
	pdfcrop "$PDF" "$CROP" > /dev/null
	pdf2svg "$CROP" "$SVG" > /dev/null
	cat "$SVG"
}

writeTex %s]], escapeArgument(equation)))

	-- Remove the XML header
	local equation = proc:read("*a"):gsub("^<%?.-%?>", "")

	-- Parse the width and height
	local width, height = equation:match("width=\"(%d+).-\" height=\"(%d+).-\"")
	width, height = 2 * tonumber(width), 2 * tonumber(height)

	equation = equation:gsub("width=\".-\" height=\".-\"", string.format("width=\"%d\" height=\"%d\"", width, height))

	-- Make the id's different for each equation to avoid messing up the symbols when
	-- rendering multiple equations at once
	-- A bit hacky I know, but all this LaTeX rendering stuff is hacky...
	equationCounter = equationCounter + 1
	equation = equation:gsub("glyph", "eq" .. equationCounter .. "-glyph")

	return equation, width, height
end
