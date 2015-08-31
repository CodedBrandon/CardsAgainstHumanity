local Workspace = game:WaitForChild("Workspace")

local lights = {} do
	for _, item in pairs(Workspace:WaitForChild("AnimatedParts"):GetChildren()) do
		if item.Name == "Light" then
			local glow = Instance.new("SelectionBox", item) do
				glow.Adornee = item
				glow.Name = "Glow"
				glow.SurfaceColor3 = Color3.new(1,1,1)
				glow.SurfaceTransparency = 0
				glow.Transparency = 1
			end
			local illumination = Instance.new("PointLight", item) do
				illumination.Name = "Light"
				illumination.Brightness = 2
				illumination.Range = 14
				illumination.Shadows = true
			end
			table.insert(lights, item)
		elseif item.Name == "Color" then
			local glow = Instance.new("SelectionBox", item) do
				glow.Adornee = item
				glow.Name = "Glow"
				glow.SurfaceColor3 = Color3.new(1,1,1)
				glow.SurfaceTransparency = 0
				glow.Transparency = 1
			end
			table.insert(lights, item)
		elseif item.Name == "InvisLight" then
			local illumination = Instance.new("PointLight", item) do
				illumination.Name = "Light"
				illumination.Brightness = 1.25
				illumination.Range = 18
				illumination.Shadows = true
			end
			table.insert(lights, item)
		elseif item.Name == "LightBall" then
			local positionSetterC1 = Instance.new("BodyPosition", item.C1) do
				positionSetterC1.position = item.C1.Position
				item.C1.Anchored = false
			end
			local positionSetterC2 = Instance.new("BodyPosition", item.C2) do
				positionSetterC2.position = item.C2.Position
				item.C2.Anchored = false
			end
		elseif item.Name == "Sink" then
			local sinkOn = false
			item.Cold.Activate.MouseClick:connect(function()
				if sinkOn then
					item.Output.Water.Enabled = false
					sinkOn = false
				else
					item.Output.Water.Color = ColorSequence.new(
						Color3.new(1,1,1),
						Color3.new(100/255, 100/255, 1)
					)
					item.Output.Water.Enabled = true
					sinkOn = true
				end
			end)
			item.Hot.Activate.MouseClick:connect(function()
				if sinkOn then
					item.Output.Water.Enabled = false
					sinkOn = false
				else
					item.Output.Water.Color = ColorSequence.new(
						Color3.new(1,1,1),
						Color3.new(1, 100/255, 100/255)
					)
					item.Output.Water.Enabled = true
					sinkOn = true
				end
			end)
		end
	end
	
	local setColor = Color3.new(0, 0, 0)
	function setLight(color)
		setColor = color
		for _, light in pairs(lights) do
			if light.Name == "Light" then
				light.Light.Color = color
				light.Glow.SurfaceColor3 = color
			elseif light.Name == "Color" then
				light.Glow.SurfaceColor3 = color
			elseif light.Name == "InvisLight" then
				light.Light.Color = color
			end
		end
	end
	
	setLight(Color3.new(0, 0, 0))
	
	local red, blue, green = 0, 0, 0
	local setRed, setBlue, setGreen = 0, 0, 0
	local isReallyRed, isReallyBlue, isReallyGreen = true, true, true
	
	coroutine.resume(coroutine.create(function()
		while true do
			if setRed == red then
				isReallyRed = true
			elseif setRed > red then
				isReallyRed = false
				red = red + 1
			elseif setRed < red then
				isReallyRed = false
				red = red - 1
			end
			setLight(Color3.new(red/255, setColor.g, setColor.b))
			wait()
		end
	end))
	coroutine.resume(coroutine.create(function()
		while true do
			if setBlue == blue then
				isReallyBlue = true
			elseif setBlue > blue then
				isReallyBlue = false
				blue = blue + 1
			elseif setBlue < blue then
				isReallyBlue = false
				blue = blue - 1
			end
			setLight(Color3.new(setColor.r, setColor.g, blue/255))
			wait()
		end
	end))
	coroutine.resume(coroutine.create(function()
		while true do
			if setGreen == green then
				isReallyGreen = true
			elseif setGreen > green then
				isReallyGreen = false
				green = green + 1
			elseif setGreen < green then
				isReallyGreen = false
				green = green - 1
			end
			setLight(Color3.new(setColor.r, green/255, setColor.b))
			wait()
		end
	end))
	coroutine.resume(coroutine.create(function()
		while true do
			local function halt() repeat wait() until (isReallyRed and isReallyGreen and isReallyBlue) end
			wait(1)
			setRed, setBlue, setGreen = 0,   0,   0;    halt()
			setRed, setBlue, setGreen = 105, 255, 50;   halt()
			setRed, setBlue, setGreen = 24,  29,  255;  halt()
			setRed, setBlue, setGreen = 212, 25,  200;  halt()
			setRed, setBlue, setGreen = 252, 24,  8;    halt()
			setRed, setBlue, setGreen = 255, 194, 15;   halt()
		end
	end))
end

