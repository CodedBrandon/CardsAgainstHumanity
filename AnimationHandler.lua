local Player = game.Players.LocalPlayer
repeat wait() until Player.Character
local human = Player.Character:FindFirstChild("Humanoid") or Player.Character:WaitForChild("Human")

local tracks = {}
for _, animation in pairs(script:GetChildren()) do
	tracks[animation.Name] = human:LoadAnimation(animation)
end

script.Parent.OnInvoke = function() return tracks end
