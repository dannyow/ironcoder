-- Write process information to Desktop
-- Usage inserts a global object called "processes" into the runtime when a lua script is called.  "processes" is an NSArray object containing NSDictionaries of process information.

local f = assert(io.open(os.getenv("HOME").."/Desktop/processes.txt", "w+"))
f:write("File created on "..os.date().."\n------------------------------------------\n\n")
e = processes:objectEnumerator()
p = e:nextObject()
while p do
	f:write(string.format("%s \t- \t%s \t(%s)\n", p:valueForKey("name"), p:valueForKey("uptime"), p:valueForKey("percent")))
	p = e:nextObject()
end
f:close()
