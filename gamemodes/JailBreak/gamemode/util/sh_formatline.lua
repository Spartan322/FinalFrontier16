-- Format line
-- Adds new lines to a string to make it fit in a certain panel
-- By newbee, ripped from PrisonBreak2.

function JB.util.FormatLine(str,font,size) --note to self: size equals width in pixes
	surface.SetFont( font )
	
	local start = 1
	local c = 1	
	local endstr = ""
	local n = 0
	local lastspace = 0
	while( string.len( str ) > c )do
		local sub = string.sub( str, start, c )
		if( string.sub( str, c, c ) == " " ) then
			lastspace = c
		end

		if( surface.GetTextSize( sub ) >= size ) then
			local sub2
			
			if( lastspace == 0 ) then
				lastspace = c
			end
			
			if( lastspace > 1 ) then
				sub2 = string.sub( str, start, lastspace - 1 )
				c = lastspace
			else
				sub2 = string.sub( str, start, c )
			end
			endstr = endstr .. sub2 .. "\n"
			start = c + 1
			n = n + 1	
		end
		c = c + 1
	end
	
	if( start < string.len( str ) ) then
		endstr = endstr .. string.sub( str, start )
	end
	
	return endstr, n
end