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
