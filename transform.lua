VERSION = "0.1.0"

local micro = import("micro")
local config = import("micro/config")
local buffer = import("micro/buffer")

function getLines(from, to)
    local buf = micro.CurPane().Buf
    local lines = {buf:Line(from.Y):sub(from.X+1)}

    if from.Y == to.Y then
        return lines
    end

    for lineNo = from.Y+1, to.Y-1 do
        table.insert(lines, buf:Line(lineNo))
    end

    table.insert(lines, buf:Line(to.Y):sub(1, to.X))

    return lines
end

local function replace_selection(replacement, whole_lines, no_selection_all_text)
	whole_lines = whole_lines == nil and true or whole_lines
	no_selection_all_text = no_selection_all_text == nil and true or no_selection_all_text

	local pane = micro.CurPane()
	local cursor =  pane.Cursor
	local from, to

	if cursor:HasSelection() then
		if cursor.CurSelection[1]:GreaterThan(-cursor.CurSelection[2]) then
		   	from, to = cursor.CurSelection[2], cursor.CurSelection[1]
		else
			from, to = cursor.CurSelection[1], cursor.CurSelection[2]
		end
	  
		if whole_lines then 
			from.X = 0
			to.X = string.len(pane.Buf:Line(to.Y))
		end
	  
 		from,to = buffer.Loc(from.X, from.Y), buffer.Loc(to.X, to.Y)
	elseif no_selection_all_text then
	    local lastLine = pane.Buf:LinesNum() - 1
	    local lastLineLen = string.len(pane.Buf:Line(lastLine))
	    from, to = buffer.Loc(0, 0), buffer.Loc(lastLineLen,lastLine)
	else 
		return micro.InfoBar():Message("Error: you have to select text first")
	end

	local oldLines = getLines(from, to)
	local newText = replacement(oldLines)
	if type(newText) == 'table' then
	  newText = table.concat(newText, "\n")
	end
	  
	pane.Buf:Replace(from, to, newText)

end

local function unique(lines)
	local unique = {}
	local out = {}
	for _,line in ipairs(lines) do
		if unique[line] == nil then
			unique[line] = true
			table.insert(out, line)
		end
	end
	return out
end

local function sort(lines)
	local out = {}
	for _,line in ipairs(lines) do
		table.insert(out, line)
	end
	table.sort(out, function(a, b) return a:lower() < b:lower() end)
	return out
end

local function each_line(process)
	return function(lines)
		local out = {}
		for _,line in ipairs(lines) do
			out[#out+1] = process(line)
		end
		return out
	end
end

local trim = function(line) return (line:gsub("^%s*(.-)%s*$", "%1")) end
local trim_left = function(line) return (line:gsub("^%s*(.-)$", "%1")) end
local trim_right = function(line) return (line:gsub("^(.-)%s*$", "%1")) end

local function line_to_columns(line, separator, remove_quoutes)
	local q = remove_quoutes and 1 or 0
	line = line .. separator
	local ret = {}
	local fieldstart = 1
	repeat
	    if line:find('^%s*"', fieldstart) then
			local a, c
			local i  = line:find('"', fieldstart) 
			repeat
	        -- find closing quote
		        a, i, c = line:find('"("?)', i + 1)
			until c ~= '"'    -- quote not followed by quote?
			if not i then return micro.InfoBar():Message("Error: unmatched \"") end
			local f = line:sub(fieldstart + q, i - q)
			table.insert(ret, (string.gsub(f, '""', '"')))
			fieldstart = line:find(separator, i) + 1
	    else                -- unquoted; find next comma
			local nexti = line:find(separator, fieldstart)
			table.insert(ret, line:sub(fieldstart, nexti-1))
			fieldstart = nexti + 1
	    end
	until fieldstart > string.len(line)
	return ret
end


local function to_table(lines, from, remove_quoutes, to, prefix, suffix)
	prefix = prefix or ""
	suffix = suffix or ""
  
	local data = {}
	local max_width = {}
  
	for _,line in ipairs(lines) do
		local columns = line_to_columns(line, from, remove_quoutes)
		table.insert(data, columns)
		for i,v in ipairs(columns) do
			if max_width[i] == nil or v:len() > max_width[i] then 
			  max_width[i] = v:len()
			end
		end
	end
  
	local space={}
	local header={}
	for i,v in ipairs(max_width) do
		space[i] = string.rep(" ", v)
		header[i] = string.rep("-", v)
	end

	local out = {}
	for _,columns in ipairs(data) do
		local line ={}
		if #columns>1 or columns[1]:len() > 0 then
			for i,v in ipairs(columns) do
				table.insert(line, string.sub(v..space[i], 1, max_width[i]))
			end
			table.insert(out, prefix .. table.concat(line, to) .. suffix)
		end
	end

	if to == ' | ' then
		table.insert(out, 2, prefix .. table.concat(header, to) .. suffix)
	end
	return out
end

local function from_table(lines, from, to)
	local out = {}

	if (from == '|') then
		table.remove(lines, 2)
	end
	
	for _,line in ipairs(lines) do
		local columns = line_to_columns(line, from, false)
		local retLine = {}
				
		for i,column in ipairs(columns) do
			column = trim(column)
			if from ~= '|' or (i > 1 and (i < #columns or column:len() > 0)) then 	
				if column:sub(1,1) ~= '"' and column:find('"') then
					micro.Log("1:>"..column.."<"..line..">")
					column ='"' .. column:gsub('"','""') .. '"'
				elseif column:sub(1,1) ~= '"' and column:find(to) then
					micro.Log("2:>"..column.."<")
					column ='"' .. column .. '"'
				end 
				table.insert(retLine, column)
			end
		end
		table.insert(out, table.concat(retLine, to))
	end

	return out
end

local function lines_to_list(lines, separator, quoute)
	if quoute then
		return quoute .. table.concat(lines, quoute .. separator .. quoute) .. quoute
	else
		return table.concat(lines, separator)
	end
end

function init()
    config.MakeCommand("unique", function() replace_selection(unique, true, true)  end, config.NoComplete)
    config.MakeCommand("sort", function() replace_selection(sort, true, true)  end, config.NoComplete)

    config.MakeCommand("trim-right", function() replace_selection(each_line(trim_right), true, true)  end, config.NoComplete)
    config.MakeCommand("trim-left", function() replace_selection(each_line(trim_left), true, true)  end, config.NoComplete)
    config.MakeCommand("trim", function() replace_selection(each_line(trim), true, true)  end, config.NoComplete)

    config.MakeCommand("csv-to-table", function() replace_selection(function(lines) return to_table(lines, ',', true, ' | ', '| ', ' |') end, true, true)  end, config.NoComplete)
    config.MakeCommand("csv-equal-width", function() replace_selection(function(lines) return to_table(lines, ',', false, ', ') end, true, true)  end, config.NoComplete)
    config.MakeCommand("csv-trim", function() replace_selection(function(lines) return from_table(lines, ',', ',') end, true, true)  end, config.NoComplete)

    config.MakeCommand("table-to-csv", function() replace_selection(function(lines) return from_table(lines, '|', ',') end, true, true)  end, config.NoComplete)
	config.MakeCommand("table-format", function() replace_selection(function(lines) return to_table(from_table(lines, '|', ','), ',', true, ' | ', '| ', ' |') end, true, true)  end, config.NoComplete)

	config.MakeCommand("lines-to-list", function() replace_selection(function(lines) return lines_to_list(lines,', ',false) end, true, true) end, config.NoComplete)
	config.MakeCommand("lines-to-list-quoute-double", function() replace_selection(function(lines) return lines_to_list(lines,', ', '"') end, true, true) end, config.NoComplete)
	config.MakeCommand("lines-to-list-quoute-sinlge", function() replace_selection(function(lines) return lines_to_list(lines,', ', "'") end, true, true) end, config.NoComplete)
		
    config.AddRuntimeFile("transform", config.RTHelp, "help/transform.md")
end
