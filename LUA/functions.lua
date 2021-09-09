-- PushLua - Yet another Ableton Push Lua Framework
-- (c) 2021 - Mockba the Borg
-- This code is distributed under the "IDGAFAWYDWTCALAYGMPC" license, which means:
-- I Don't Give A Fuck About What You Do With This Code As Long As You Give Me Proper Credit
--

-- General utility functions

-- Checks if a file exists
function file_exists(file)
	local f = io.open(file, "rb")
	if f then f:close() end
	return f ~= nil
end

-- Trims spaces from the head and tail of a string
function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- Explodes a string into an array using a delimiter
function explode(div,str)
	if (div=='') then return false end
	local pos,arr = 0,{}
	for st,sp in function() return string.find(str,div,pos,true) end do
		table.insert(arr,string.sub(str,pos,st-1))
		pos = sp + 1
	end
	table.insert(arr,string.sub(str,pos))
	return arr
end

-- Inserts space delimited arguments into an array
function getargs(text)
	local quote = text:sub(1,1) ~= '"'
	local ret = {}
	for chunk in string.gmatch(text, '[^"]+') do
		quote = not quote
		if quote then
			table.insert(ret,chunk)
		else
			for chunk in string.gmatch(chunk, "%S+") do
				table.insert(ret,chunk)
			end
		end
	end
	return ret
end

-- Prints an array like PHP's print_r
function print_r(t) 
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    sub_print_r(t,"  ")
end

-- Poor man's printf
function printf(s,...)
	return io.write(s:format(...))
end

-- Poor man'r printhex
function printhex(n)
	printf("0x%x\n", n)
end

-- End the script
function die(msg)
  io.stderr:write(msg,"\n")
  os.exit(1)
end
