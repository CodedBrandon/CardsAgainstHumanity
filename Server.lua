game.OnClose = function() wait(5) end

local DataStoreService = game:GetService("DataStoreService")

local PlayerData = DataStoreService:GetDataStore("PlayerData_CAH")
local InternalData = DataStoreService:GetDataStore("InternalData_CAH") do
	if InternalData and not InternalData:GetAsync("Streaming") then
		InternalData:SetAsync("Streaming", false)
	end
end
local WinsLeaderboard = DataStoreService:GetOrderedDataStore("WinsLeaderboard_CAH")
local RatioLeaderboard = DataStoreService:GetOrderedDataStore("RatioLeaderboard_CAH")
local LevelLeaderboard = DataStoreService:GetOrderedDataStore("LevelLeaderboard_CAH")

local MarketPlace = game.MarketplaceService
local PointsService = game.PointsService
local GamePasses = game.GamePassService
local Badges = game.BadgeService
local Filter = game.Chat

local numberFormat = require(game.Workspace.NumberFormat)
local MarketId = require(game.workspace.MarketId)

local function updatePlayerLists()
	for _, player in pairs(game.Players:GetChildren()) do
		require(player.Client).Game:UpdatePlayers()
	end
end

local spawnFlare = 1 do
	coroutine.resume(coroutine.create(function()
		while true do
			if spawnFlare < 1 then
				spawnFlare = spawnFlare + 0.1
			end
			game.Workspace.Spawn.Transparency = spawnFlare
			wait(0.1)
		end
	end))
end

game.Players.PlayerAdded:connect(function(Player)
	if Player.Name:sub(1, 6) == "Guest " then
		Player:Kick("You require a ROBLOX Account to Play this Game.")
	end
	script.Client:Clone().Parent = Player
	Player.Neutral = false
	local loadSize = 16
	
	repeat wait(1) until Player.Client.IsLoaded.Value
	local Client = require(Player.Client)
	Client.Game:LoadBar(1, loadSize)
	
	if DataStoreService and PlayerData then -- Player Data
		Player.Client.Credits.Value = PlayerData:GetAsync(
			Player.userId..".Credits"
		) or Player.Client.Credits.Value
		Client.Game:LoadBar(2, loadSize)
		
		do -- Settings
			do -- Load Chat Color
				local red = PlayerData:GetAsync(
					Player.userId..".Chat.Red"
				) or Player.Client.Settings.ChatColor.Value.r
				Client.Game:LoadBar(3, loadSize)
				local green = PlayerData:GetAsync(
					Player.userId..".Chat.Green"
				) or Player.Client.Settings.ChatColor.Value.g
				Client.Game:LoadBar(4, loadSize)
				local blue = PlayerData:GetAsync(
					Player.userId..".Chat.Blue"
				) or Player.Client.Settings.ChatColor.Value.b
				Client.Game:LoadBar(5, loadSize)
				Player.Client.Settings.ChatColor.Value = Color3.new(red, green, blue)
			end
			Player.Client.Settings.MuteMusic.Value = PlayerData:GetAsync(
				Player.userId..".MuteMusic"
			) or Player.Client.Settings.MuteMusic.Value
			Client.Game:LoadBar(6, loadSize)
			Player.Client.Settings.MuteSounds.Value = PlayerData:GetAsync(
				Player.userId..".MuteSounds"
			) or Player.Client.Settings.MuteSounds.Value
			Client.Game:LoadBar(7, loadSize)
			Player.Client.Settings.ShowNames.Value = PlayerData:GetAsync(
				Player.userId..".ShowNames"
			) or Player.Client.Settings.ShowNames.Value
			Client.Game:LoadBar(8, loadSize)
			Player.Client.Settings.EnableTips.Value = PlayerData:GetAsync(
				Player.userId..".EnableTips"
			) or Player.Client.Settings.EnableTips.Value
			Client.Game:LoadBar(9, loadSize)
		end
		
		for _, stat in pairs(Player.Client.Stats:GetChildren()) do
			stat.Value = PlayerData:GetAsync(
				Player.userId.."."..stat.Name
			) or stat.Value
		end
		Client.Game:LoadBar(10, loadSize)
		
		for _, redeemable in pairs(Player.Client.Redeem:GetChildren()) do
			redeemable.Value = PlayerData:GetAsync(
				Player.userId.."."..redeemable.Name
			) or redeemable.Value
		end
		Client.Game:LoadBar(11, loadSize)
		
		do -- Streak
			local currentDay = math.floor(tick() / (60 * 60 * 24))
			
			local lastDay = PlayerData:GetAsync(
				Player.userId..".StreakTracker"
			) or 0
			Client.Game:LoadBar(12, loadSize)
			
			local streak = PlayerData:GetAsync(
				Player.userId..".Streak"
			) or Player.Client.Streak.Value
			Client.Game:LoadBar(13, loadSize)
			
			local getEarnings = function(streak)
				local earnings = math.ceil(streak * 0.25)
				Player.Client.Credits.Value = Player.Client.Credits.Value + earnings
				return tostring(earnings)
			end
			
			if lastDay == currentDay then
				Client.Game.GUI.Streak:Destroy()
			elseif lastDay + 1 == currentDay then
				streak = streak + 1
				Client.Game:ShowStreak(streak, getEarnings(streak))
			else
				streak = 1
				Client.Game:ShowStreak(streak, getEarnings(streak))
			end
			Player.Client.Streak.Value = streak
		end
	end
	
	do -- Gamepasses / Badges
		local passes = Player.Client.Passes
		Client.GUI:RandomizeCards(GamePasses:PlayerHasPass(Player, MarketId.BlankStart))
		passes.ColorSpectrum.Value = GamePasses:PlayerHasPass(Player, MarketId.ColorSpectrum)
		passes.DrinksAround.Value = GamePasses:PlayerHasPass(Player, MarketId.DrinksAround)
		if GamePasses:PlayerHasPass(Player, MarketId.RollingWealth) then
			passes.CreditMultiplier.Value = passes.CreditMultiplier.Value + 1
		end
		if GamePasses:PlayerHasPass(Player, MarketId.Experienced) then
			passes.ExperienceMultipler.Value = passes.ExperienceMultipler.Value + 0
		end
		if GamePasses:PlayerHasPass(Player, MarketId.IncreasedOdds) then
			Player.Client.BlankChance.Value = math.floor(Player.Client.BlankChance.Value / 2)
		end
		if GamePasses:PlayerHasPass(Player, MarketId.Donator) then
			Player.Client.Display.Value = "Donator"
		end
	end
	Client.Game:LoadBar(14, loadSize)
	
	do -- Display Checks
		if Player.userId == 41800504 then -- Rindyr
			Player.Client.Display.Value = "Developer"
			Player.Client.Admin.Value = true
			Player.Client.Moderator.Value = true
			Player.Client.Passes.ColorSpectrum.Value = true
			Player.Client.Passes.DrinksAround.Value = true
		elseif Player.userId == 17659316 then -- Darkflares
			Player.Client.Display.Value = "Builder"
			Player.Client.Admin.Value = true
			Player.Client.Moderator.Value = true
			Player.Client.Passes.ColorSpectrum.Value = true
			Player.Client.Passes.DrinksAround.Value = true
		elseif Player.userId == 404329 then -- Dirtboss
			Player.Client.Display.Value = "Ideas Man"
			Player.Client.Admin.Value = true
			Player.Client.Moderator.Value = true
			Player.Client.Passes.ColorSpectrum.Value = true
			Player.Client.Passes.DrinksAround.Value = true
		elseif Player:IsInGroup(947196) then -- Powered By Lua
			if Player:GetRankInGroup(947196) == 200 then
				Player.Client.Display.Value = "Moderator"
				Player.Client.Moderator.Value = true
			elseif Player:GetRankInGroup(947196) == 250 then
				Player.Client.Display.Value = "Beta Tester"
				Player.Client.Passes.ColorSpectrum.Value = true
				Player.Client.Passes.DrinksAround.Value = true
			end
		elseif Player:IsInGroup(2564804) then -- DBS
			if Player:GetRankInGroup(2564804) >= 100 then
				Player.Client.Display.Value = "Member"
			end
		end
	end
	Client.Game:LoadBar(15, loadSize)
	
	if Player.Name == "Player" or Player.Name == "Player1" then
		Player.Client.Admin.Value = true
		Player.Client.Moderator.Value = true 
		Player.Client.Settings.MuteMusic.Value = true
	end
	Client.Game:LoadBar(16, loadSize)
	wait(0.1)
	repeat wait() until Client.Game:PlayIntro()
	Player.Character:SetPrimaryPartCFrame(game.Workspace.Spawn.CFrame * CFrame.Angles(0, math.rad(180), 0))
	spawnFlare = 0.2
	updatePlayerLists()
	game.Workspace.Chat.Color.Value = Player.Client.Settings.ChatColor.Value
	game.Workspace.Chat.Value = Player.Name.." Joined the Game"
	Player.Client.ServerLoaded.Value = true
	wait(1)
	Client.Game.GUI.Intro:Destroy()
end)

game.Players.PlayerRemoving:connect(function(Player)
	if 
		DataStoreService 
		and PlayerData 
		and WinsLeaderboard
		and RatioLeaderboard
		and LevelLeaderboard
		and Player.Client.IsLoaded.Value
	then
		PlayerData:SetAsync(
			Player.userId..".Credits",
			Player.Client.Credits.Value
		)
		
		do -- Settings
			do -- Save Chat Color
				PlayerData:SetAsync(
					Player.userId..".Chat.Red",
					Player.Client.Settings.ChatColor.Value.r
				)
				PlayerData:SetAsync(
					Player.userId..".Chat.Green",
					Player.Client.Settings.ChatColor.Value.g
				)
				PlayerData:SetAsync(
					Player.userId..".Chat.Blue",
					Player.Client.Settings.ChatColor.Value.b
				)
			end
			
			PlayerData:SetAsync(
				Player.userId..".MuteMusic",
				Player.Client.Settings.MuteMusic.Value
			)
			PlayerData:SetAsync(
				Player.userId..".MuteSounds",
				Player.Client.Settings.MuteSounds.Value
			)
			PlayerData:SetAsync(
				Player.userId..".ShowNames",
				Player.Client.Settings.ShowNames.Value
			)
			PlayerData:SetAsync(
				Player.userId..".EnableTips",
				Player.Client.Settings.EnableTips.Value
			)
		end
		
		for _, stat in pairs(Player.Client.Stats:GetChildren()) do
			PlayerData:SetAsync(
				Player.userId.."."..stat.Name,
				stat.Value
			)
		end
		
		for _, redeemable in pairs(Player.Client.Redeem:GetChildren()) do
			PlayerData:SetAsync(
				Player.userId.."."..redeemable.Name,
				redeemable.Value
			)
		end
		
		WinsLeaderboard:SetAsync(
			Player.Name, Player.Client.Stats.GamesWon.Value
		)
		RatioLeaderboard:SetAsync(
			Player.Name, Player.Client.Ratio.Value
		)
		LevelLeaderboard:SetAsync(
			Player.Name, Player.Client.Stats.Level.Value
		)
		
		do -- Streak
			local currentDay = math.floor(tick() / (60 * 60 * 24))
			PlayerData:SetAsync(
				Player.userId..".StreakTracker",
				currentDay
			)
			PlayerData:SetAsync(
				Player.userId..".Streak",
				Player.Client.Streak.Value
			)
		end
		
	end
	
	updatePlayerLists()
	game.Workspace.Chat.Color.Value = Player.Client.Settings.ChatColor.Value
	game.Workspace.Chat.Value = Player.Name.." Left the Game"
end)

MarketPlace.ProcessReceipt = function(info)
	if pcall(function()
		for _, player in pairs(game.Players:GetChildren()) do
			if player.userId == info.PlayerId then
				if info.ProductId == MarketId.FiftyCredits then
					player.Client.Credits.Value = player.Client.Credits.Value + 50
					player.Client.Stats.Experience.Value = player.Client.Stats.Experience.Value + 5
				-- 50 Credits
				elseif info.ProductId == MarketId.OneHundredCredits then
					player.Client.Credits.Value = player.Client.Credits.Value + 100
					player.Client.Stats.Experience.Value = player.Client.Stats.Experience.Value + 10
				-- 100 Credits
				elseif info.ProductId == MarketId.FiveHundredCredits then
					player.Client.Credits.Value = player.Client.Credits.Value + 500
					player.Client.Stats.Experience.Value = player.Client.Stats.Experience.Value + 25
				-- 500 Credits
				elseif info.ProductId == MarketId.OneThousandCredits then
					player.Client.Credits.Value = player.Client.Credits.Value + 1000
					player.Client.Stats.Experience.Value = player.Client.Stats.Experience.Value + 50
				-- 1,000 Credits
				elseif info.ProductId == MarketId.FiveThousandCredits then
					player.Client.Credits.Value = player.Client.Credits.Value + 5000
					player.Client.Stats.Experience.Value = player.Client.Stats.Experience.Value + 100
				-- 5,000 Credits
				elseif info.ProductId == MarketId.TenThousandCredits then
					player.Client.Credits.Value = player.Client.Credits.Value + 10000
					player.Client.Stats.Experience.Value = player.Client.Stats.Experience.Value + 150
				-- 10,000 Credits
				elseif info.ProductId == MarketId.FiftyThousandCredits then
					player.Client.Credits.Value = player.Client.Credits.Value + 50000
					player.Client.Stats.Experience.Value = player.Client.Stats.Experience.Value + 250
				-- 50,000 Credits
				elseif info.ProductId == MarketId.BlankStart then
					
				-- Blank Start
				elseif info.ProductId == MarketId.ColorSpectrum then
					player.Client.Passes.ColorSpectrum.Value = true
				-- Color Spectrum
				elseif info.ProductId == MarketId.Donator then
					
				-- Donator
				elseif info.ProductId == MarketId.DrinksAround then
					player.Client.Passes.DrinksAround.Value = true
				-- Drinks Around
				elseif info.ProductId == MarketId.Experienced then
					player.Client.Passes.ExperienceMultiplier.Value = player.Client.Passes.ExperienceMultiplier.Value + 1
				-- Experienced
				elseif info.ProductId == MarketId.IncreasedOdds then
					player.Client.BlankChance.Value = player.Client.BlankChance.Value / 2
				-- Increased Odds
				elseif info.ProductId == MarketId.RollingWealth then
					player.Client.Passes.CreditMultiplier.Value = player.Client.Passes.CreditMultiplier.Value + 1
				-- Rolling Wealth
				elseif info.ProductId == MarketId.ResetStats then
					player.Client.Stats.GamesWon.Value = 0
					player.Client.Stats.GamesLost.Value = 0
					player.Client.Stats.Level.Value = 0
					player.Client.Stats.Experience.Value = 0
				-- ResetStats
				end
				player.Client.Sounds.Energize:Play()
				break
			end
		end
	end) then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	else
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
end

game.Workspace.Filter.OnServerInvoke = function(player, chat)
	return Filter:FilterStringForPlayerAsync(chat, player)
end

for _, gameTable in pairs(game.Workspace:GetChildren()) do
	if gameTable.Name == "Table" then
		local gameScript = script.Game:Clone()
		gameScript.Parent = gameTable
		gameScript.Disabled = false
	end
end

game.Workspace.Streaming.Changed:connect(function(value)
	InternalData:SetAsync("Streaming", value)
end)

game.Workspace.ChildAdded:connect(function(hat)
	if hat:IsA("Hat") then hat:destroy() end
end)

wait(10) -- Leaderboard
while
	WinsLeaderboard
	and RatioLeaderboard
	and LevelLeaderboard
	and InternalData
do
	for _, player in pairs(game.Players:GetChildren()) do
		if player.userId > 0 and player.Client.ServerLoaded.Value then
			WinsLeaderboard:SetAsync(
				player.Name, player.Client.Stats.GamesWon.Value
			)
			RatioLeaderboard:SetAsync(
				player.Name, player.Client.Ratio.Value
			)
			LevelLeaderboard:SetAsync(
				player.Name, player.Client.Stats.Level.Value
			)
		end
	end
	local leaderboard = {
		wins = {},
		ratio = {},
		level = {}
	}
	for _, name in pairs(WinsLeaderboard:GetSortedAsync(false, 50):GetCurrentPage()) do
		if name.key ~= "Player" and name.key ~= "Player1" then
			table.insert(leaderboard.wins, {name.key, numberFormat(name.value)})
		end
	end
	for _, name in pairs(RatioLeaderboard:GetSortedAsync(false, 50):GetCurrentPage()) do
		if name.key ~= "Player" and name.key ~= "Player1" then
			table.insert(leaderboard.ratio, {name.key, name.value})
		end
	end
	for _, name in pairs(LevelLeaderboard:GetSortedAsync(false, 50):GetCurrentPage()) do
		if name.key ~= "Player" and name.key ~= "Player1" then
			table.insert(leaderboard.level, {name.key, numberFormat(name.value)})
		end
	end
	for _, player in pairs(game.Players:GetChildren()) do
		if player.Client.IsLoaded.Value and player.Client.ServerLoaded.Value then
			require(player.Client).Game:UpdateLeaderboard(leaderboard)
		end
	end
	if InternalData:GetAsync("Streaming") then
		game.Workspace.Stream.Twitch.Background.Visible = true
	else
		game.Workspace.Stream.Twitch.Background.Visible = false
	end
	wait(1*60)
end
