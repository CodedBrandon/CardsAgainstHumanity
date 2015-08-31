return function(number)
	number = tostring(number):reverse()
	local returnNumber = ""
	for x = 1, #number do
		local index = number:sub(x, x)
		if x % 3 == 0 and x < #number then
			returnNumber = returnNumber..index..","
		else
			returnNumber = returnNumber..index
		end
	end
	return returnNumber:reverse()
end
