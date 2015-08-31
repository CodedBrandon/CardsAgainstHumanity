while not game:IsLoaded() do wait(1) end
game.StarterGui:SetCoreGuiEnabled("All", false)

local Player = game.Players.LocalPlayer
game.Workspace:WaitForChild(Player.Name):WaitForChild("Humanoid").WalkSpeed = 0
local GUI = script.Parent.Game
local Cards = require(game.Workspace.Cards)

local userInput = game:GetService("UserInputService")
--local adService = game.AdService
local debris = game.Debris
local isOnMobile = false
wait(2) -- Latency Catch

if userInput.TouchEnabled then
	Player.Client.MobileUser.Value = true
	isOnMobile = true
	userInput.ModalEnabled = true
	Player.Client.Table.Changed:connect(function()
		if Player.Client.Table.Value then
			userInput.ModalEnabled = true
		else
			userInput.ModalEnabled = false
		end
	end)
end

local numberFormat = require(game.Workspace.NumberFormat)

do -- White Card Handler
	local function setCard(card)
		local gameTable = Player.Client.Table.Value
		if gameTable then
			if Player.Client.Game.Card1.Value == "" then
				Player.Client.Game.Card1.Value = card
				return true
			elseif
				Player.Client.Game.Card2.Value == "" and
				gameTable.DoubleBlack.Value
			then
				Player.Client.Game.Card2.Value = card
				return true
			end
			return false
		end
	end
	local blankFocus = nil
	for _, card in pairs(GUI.Screen.Cards:GetChildren()) do
		if card.Name == "Card" then
			card.MouseButton1Down:connect(function()
				if
					not Player.Client.Game.IsKing.Value
					and Player.Client.Table.Value
					and Player.Client.Table.Value.IsChoosing.Value
				then
					if card.Text == "Blank Card" then
						blankFocus = card
						card.Text = ""
						local blank = GUI.Screen.Cards.BlankCard
						blank.Size = card.Size
						blank.Position = card.Position
						blank.Visible = true
						blank:CaptureFocus()
					else
						if setCard(card.Text) then
							if math.random(1, Player.Client.BlankChance.Value) == 1 then
								card.Text = "Blank Card"
							else
								card.Text = Cards.White[math.random(1, #Cards.White)]
							end
							Player.Client.Sounds.Pop:Play()
						end
					end
				end
			end)
		end
	end
	GUI.Screen.Cards.BlankCard.FocusLost:connect(function(entered)
		if
			not Player.Client.Game.IsKing.Value
			and Player.Client.Table.Value
			and Player.Client.Table.Value.IsChoosing.Value
		then
			if entered then
				setCard(game.Workspace.Filter:InvokeServer(GUI.Screen.Cards.BlankCard.Text))
				blankFocus.Text = Cards.White[math.random(1, #Cards.White)]
				Player.Client.Sounds.Pop:Play()
			else
				blankFocus.Text = "Blank Card"
			end
			GUI.Screen.Cards.BlankCard.Text = ""
			GUI.Screen.Cards.BlankCard.Visible = false
		end
	end)
	
	script.Parent.GetSize.OnClientInvoke = function()
		return math.floor(GUI.Screen.BlackCard.AbsoluteSize.X)
	end
end

do -- Chat Handler
	chatTimer = 15
	local clickMessage = "Click here or press \"/\" to chat."
	GUI.Screen.Chat.SendChat.Text = clickMessage
	GUI.Screen.Chat.SendChat.Focused:connect(function()
		if GUI.Screen.Chat.SendChat.Text == clickMessage then
			GUI.Screen.Chat.SendChat.Text = ""
		end
	end)
	GUI.Screen.Chat.SendChat.FocusLost:connect(function(entered)
		if Player.Client.Table.Value and
			GUI.Screen.Chat.SendChat.Text ~= "" and
			GUI.Screen.Chat.SendChat.Text ~= clickMessage
		then
			if GUI.Screen.Chat.SendChat.Text:sub(1,1) == "/" then
				local chat = GUI.Screen.Chat.SendChat.Text:sub(2, #GUI.Screen.Chat.SendChat.Text)
				local args = {}
				local currentArg = ""
				for char in string.gmatch(chat.." ", ".") do
					if char ~= " " then
						currentArg = currentArg..tostring(char)
					elseif char == " " then
						table.insert(args, currentArg)
						currentArg = ""
					end
				end
				local chatReturn, returnedColor = require(Player.Client).Game:HandleCommand(args)
				if chatReturn ~= "" then
					require(Player.Client).Game:PushChat(chatReturn, returnedColor, true)
				end
			else
				Player.Client.Table.Value.SendChat:InvokeServer(
					string.format("(%s) %s", Player.Name, GUI.Screen.Chat.SendChat.Text),
					Player.Client.Settings.ChatColor.Value,
					(Player.Client.Effects.Bold.Value > 0)
				)
			end
		end
		GUI.Screen.Chat.SendChat.Text = clickMessage
	end)
	GUI.SendGlobalChat.Text = clickMessage
	GUI.SendGlobalChat.Focused:connect(function()
		if GUI.SendGlobalChat.Text == clickMessage then
			GUI.SendGlobalChat.Text = ""
		end
		chatTimer = 15
	end)
	GUI.SendGlobalChat.FocusLost:connect(function(entered)
		if entered and
			GUI.SendGlobalChat.Text ~= "" and
			GUI.SendGlobalChat.Text ~= clickMessage
		then
			if GUI.SendGlobalChat.Text:sub(1,1) == "/" then
				local chat = GUI.SendGlobalChat.Text:sub(2, #GUI.SendGlobalChat.Text)
				local args = {}
				local currentArg = ""
				for char in string.gmatch(chat.." ", ".") do
					if char ~= " " then
						currentArg = currentArg..tostring(char)
					elseif char == " " then
						table.insert(args, currentArg)
						currentArg = ""
					end
				end
				local chatReturn, returnedColor = require(Player.Client).Game:HandleCommand(args)
				if chatReturn ~= "" then
					require(Player.Client).Game:PushGlobalChat(chatReturn, returnedColor, true)
				end
			else
				game.Workspace.Chat.Color.Value = Player.Client.Settings.ChatColor.Value
				game.Workspace.Chat.Bold.Value = (Player.Client.Effects.Bold.Value > 0)
				game.Workspace.Chat.Value = string.format("(%s) %s", Player.Name, GUI.SendGlobalChat.Text)
			end
			GUI.SendGlobalChat.Text = clickMessage
		elseif GUI.SendGlobalChat.Text == "" then
			GUI.SendGlobalChat.Text = clickMessage
		end
		chatTimer = 15
	end)
	game.Workspace.Chat.Changed:connect(function()
		chatTimer = 15
		require(Player.Client).Game:PushGlobalChat(
			game.Workspace.Chat.Value,
			game.Workspace.Chat.Color.Value,
			game.Workspace.Chat.Bold.Value
		)
	end)
	
	Player:GetMouse().KeyDown:connect(function(key)
		if key == "/"then
			if Player.Client.Table.Value then
				GUI.Screen.Chat.SendChat:CaptureFocus()
				chatTimer = 15
			else
				GUI.SendGlobalChat:CaptureFocus()
			end
		end
	end)
	chatViewer = coroutine.create(function()
		while true do
			if chatTimer > 0 then
				GUI.GlobalChat:TweenSize(
					UDim2.new(0, 500, 0, 250),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Sine,
					0.25, true
				)
				chatTimer = chatTimer - 0.25
			else
				GUI.GlobalChat:TweenSize(
					UDim2.new(0, 0, 0, 250),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Sine,
					0.25, true
				)
			end
			wait(0.25)
		end
	end)
end

do -- Menu Board Handler
	local menuBoard = script.Parent:WaitForChild("MenuBoard")
	menuBoard:WaitForChild("Menu")
	local isProcessing = false
	local function process(creditCheck)
		isProcessing = true
		menuBoard.Menu.Size = menuBoard.Menu.Size
			+ UDim2.new(0, 0, 0, -menuBoard.Process.AbsoluteSize.Y)
		menuBoard.Menu.ScrollingEnabled = false
		menuBoard.Process.Visible = true
		menuBoard.Process.Bar:TweenSize(
			UDim2.new(1, 20, 1, 20),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Sine,
			2, false
		)
		wait(2)
		local function reset()
			menuBoard.Process.Visible = false
			menuBoard.Process.Display.Text = "PROCESSING"
			menuBoard.Process.Display.Shadow.Text = "PROCESSING"
			menuBoard.Process.Bar.Size = UDim2.new(0, 0, 1, 20)
			menuBoard.Menu.Size = menuBoard.Menu.Size
				+ UDim2.new(0, 0, 0, menuBoard.Process.AbsoluteSize.Y)
			menuBoard.Menu.ScrollingEnabled = true
			isProcessing = false
		end
		if Player.Client.Credits.Value >= creditCheck then
			menuBoard.Process.Display.Text = "ACCEPTED"
			menuBoard.Process.Display.Shadow.Text = "ACCEPTED"
			Player.Client.Sounds.Purchase:Play()
			wait(Player.Client.Sounds.Purchase.TimeLength)
			reset()
			return true
		else
			menuBoard.Process.Display.Text = "DECLINED"
			menuBoard.Process.Display.Shadow.Text = "DECLINED"
			Player.Client.Sounds.Decline:Play()
			wait(Player.Client.Sounds.Decline.TimeLength)
			reset()
			return false
		end
	end
	menuBoard.Menu.WhiteWhip.Purchase.MouseButton1Down:connect(function()
		Player.Client.Sounds.Pop:Play()
		if not isProcessing and process(3) then
			Player.Client.Credits.Value = Player.Client.Credits.Value - 3
			script.Drinks["White Whip"]:Clone().Parent = script.Parent.Parent.Backpack
		end
	end)
	menuBoard.Menu.BlankBuzz.Purchase.MouseButton1Down:connect(function()
		Player.Client.Sounds.Pop:Play()
		if not isProcessing and process(12) then
			Player.Client.Credits.Value = Player.Client.Credits.Value - 12
			script.Drinks["Blank Buzz"]:Clone().Parent = script.Parent.Parent.Backpack
		end
	end)
	menuBoard.Menu.MoneyMaker.Purchase.MouseButton1Down:connect(function()
		Player.Client.Sounds.Pop:Play()
		if not isProcessing and process(18) then
			Player.Client.Credits.Value = Player.Client.Credits.Value - 18
			script.Drinks["Money Maker"]:Clone().Parent = script.Parent.Parent.Backpack
		end
	end)
	menuBoard.Menu.ExplosiveExperience.Purchase.MouseButton1Down:connect(function()
		Player.Client.Sounds.Pop:Play()
		if Player.Client.Passes.DrinksAround.Value and not isProcessing and process(16) then
			Player.Client.Credits.Value = Player.Client.Credits.Value - 16
			script.Drinks["Explosive Experience"]:Clone().Parent = script.Parent.Parent.Backpack
		end
	end)
	menuBoard.Menu.BoldBlast.Purchase.MouseButton1Down:connect(function()
		Player.Client.Sounds.Pop:Play()
		if not isProcessing and process(3) then
			Player.Client.Credits.Value = Player.Client.Credits.Value - 3
			script.Drinks["Bold Blast"]:Clone().Parent = script.Parent.Parent.Backpack
		end
	end)
	menuBoard.Menu.GlimmeringGlow.Purchase.MouseButton1Down:connect(function()
		Player.Client.Sounds.Pop:Play()
		if not isProcessing and process(3) then
			Player.Client.Credits.Value = Player.Client.Credits.Value - 3
			script.Drinks["Glimmering Glow"]:Clone().Parent = script.Parent.Parent.Backpack
		end
	end)
	menuBoard.Menu.FireflyFeat.Purchase.MouseButton1Down:connect(function()
		Player.Client.Sounds.Pop:Play()
		if Player.Client.Passes.DrinksAround.Value and not isProcessing and process(4) then
			Player.Client.Credits.Value = Player.Client.Credits.Value - 4
			script.Drinks["Firefly Feat"]:Clone().Parent = script.Parent.Parent.Backpack
		end
	end)
	for _, menuItem in pairs(menuBoard.Menu:GetChildren()) do
		menuItem.MouseEnter:connect(function()
			menuItem.Purchase.Credits.Visible = true
			if menuItem.Exclusive.Value then
				menuItem.Purchase.Text = "EXCLUSIVE"
			end
		end)
		menuItem.MouseLeave:connect(function()
			menuItem.Purchase.Credits.Visible = false
			menuItem.Purchase.Text = "Purchase"
		end)
	end
end

do -- Tips
	local mouse = Player:GetMouse()
	local tracker = script.Parent.Mouse.Target
	mouse.Move:connect(function()
		tracker.Position = UDim2.new(0, mouse.X, 0, mouse.Y)
	end)
	local function findGuiTip(gui)
		for _, item in pairs(gui:GetChildren()) do
			findGuiTip(item)
			if item:IsA("GuiBase") then
				local function showTip()
					if
						item:FindFirstChild("Tip")
						and item.Tip:IsA("StringValue")
						and Player.Client.ServerLoaded.Value
					then
						tracker.Display.Text = item.Tip.Value
					end
				end
				item.MouseEnter:connect(showTip)
				item.MouseMoved:connect(showTip)
				item.MouseLeave:connect(function()
					if not item.Parent:FindFirstChild("Tip")
						and not item.Parent.Parent:FindFirstChild("Tip")
					then
						tracker.Display.Text = ""
					end
				end)
			end
		end
	end
	if not isOnMobile then findGuiTip(GUI) end
end

do -- Leaderboard
	local leaderGui = GUI.Parent:WaitForChild("Leaderboard").Stats
	local function hideAll()
		leaderGui.Wins.Visible = false
		leaderGui.Ratio.Visible = false
		leaderGui.Level.Visible = false
	end
	leaderGui.Switch.MouseButton1Down:connect(function()
		if leaderGui.Switch.Text:lower() == "wins" then
			hideAll()
			leaderGui.Ratio.Visible = true
			leaderGui.Switch.Text = "RATIO"
		elseif leaderGui.Switch.Text:lower() == "ratio" then
			hideAll()
			leaderGui.Level.Visible = true
			leaderGui.Switch.Text = "LEVEL"
		elseif leaderGui.Switch.Text:lower() == "level" then
			hideAll()
			leaderGui.Wins.Visible = true
			leaderGui.Switch.Text = "WINS"
		end
		Player.Client.Sounds.Pop:Play()
	end)
end

do -- Credits Updater
	Player.Client.Credits.Changed:connect(function(value)
		if value < 0 then
			Player.Client.Credits.Value = 0
		else
			GUI.Credits.Value.Text = numberFormat(value)
		end
	end)
end

do -- Menu Visibility Handler
	local menuDebounce = true
	local function setMenuItems(visible)
		for _, guiItem in pairs(GUI.Menu:GetChildren()) do
			guiItem.Visible = visible
		end	
	end
	local menuOpen = false
	GUI.Menu.Visible = true
	local function toggleMenu()
		if menuDebounce then
		  menuDebounce = false
			Player.Client.Sounds.Pop:Play()
			if menuOpen then
				setMenuItems(false)
				GUI.Menu:TweenSizeAndPosition(
					UDim2.new(
						GUI.MenuButton.Size.X.Scale,
						GUI.MenuButton.Size.X.Offset,
						GUI.MenuButton.Size.Y.Scale,
						GUI.MenuButton.Size.Y.Offset
					),
					UDim2.new(
						GUI.MenuButton.Position.X.Scale,
						GUI.MenuButton.Position.X.Offset,
						GUI.MenuButton.Position.Y.Scale,
						GUI.MenuButton.Position.Y.Offset
					),
					Enum.EasingDirection.In,
					Enum.EasingStyle.Back,
					Player.Client.Sounds.Pop.TimeLength,
					false
				)
				wait(Player.Client.Sounds.Pop.TimeLength)
				menuOpen = false
			else
				GUI.Menu:TweenSizeAndPosition(
					UDim2.new(0, 500, 0, 400),
					UDim2.new(0.5, -250, 0.5, -200),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Back,
					Player.Client.Sounds.Pop.TimeLength,
					false
				)
				wait(Player.Client.Sounds.Pop.TimeLength)
				setMenuItems(true)
				menuOpen = true
			end
			wait(0.25)
		  menuDebounce = true
		end
	end
	GUI.MenuButton.MouseButton1Down:connect(toggleMenu)
	Player:GetMouse().KeyDown:connect(function(key)
		if key == "m" then
			toggleMenu()
		end
	end)
end

do -- Game Credits
	local viewPort = script.Parent:WaitForChild("GameCredits").ViewPort
	wait(1)
	local debounce = true
	viewPort.View.MouseButton1Down:connect(function()
		if debounce then
			debounce = false
			viewPort.View.Visible = false
			viewPort:TweenSizeAndPosition(
				UDim2.new(1, 0, 1, 0),
				UDim2.new(0, 0, 0, 0),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Back,
				0.5, false
			)
			wait(0.5)
			viewPort.Credits.Visible = true
			wait(5)
			viewPort:TweenSizeAndPosition(
				UDim2.new(0.6, 0, 0.2, 0),
				UDim2.new(0.2, 0, 0.4, 0),
				Enum.EasingDirection.In,
				Enum.EasingStyle.Quart,
				0.5, false
			)
			viewPort.Credits.Visible = false
			wait(0.5)
			viewPort.View.Visible = true
			debounce = true
		end
	end)
end

do -- Player List Helper
	if isOnMobile then
		Player:GetMouse().Button1Down:connect(function()
			GUI.Players.Details.Visible = false
		end)
	else
		GUI.Players.ViewTracker.MouseLeave:connect(function()
			GUI.Players.Details.Visible = false
		end)
	end
	local listOpen = true
	GUI.Players.Title.MouseButton1Down:connect(function()
		GUI.Players.Details.Visible = false
		if listOpen then
			GUI.Players.List.Visible = false
			GUI.Players:TweenSize(
				UDim2.new(0, 175, 0, 43),
				Enum.EasingDirection.In,
				Enum.EasingStyle.Quad,
				0.2, true, function()
					listOpen = false
				end
			)
		else
			GUI.Players:TweenSize(
				UDim2.new(0, 175, 0, 200),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Quad,
				0.2, true, function()
					GUI.Players.List.Visible = true
					listOpen = true
				end
			)
		end
	end)
end

do -- Game Menu
	local menu = GUI.Menu
	do -- Handle Menu Buttons
		local debounce = true
		menu.Open.Purchase.MouseButton1Down:connect(function()
			if debounce then
				debounce = false
				menu.Main.Menus:TweenPosition(
					UDim2.new(-1, 0, 0, 0),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Sine,
					0.25, true, function() debounce = true end
				)
				menu.Main.Menus.Stats.ExperienceBar.Visible = false
				Player.Client.Sounds.Pop:Play()
			end
		end)
		menu.Open.Stats.MouseButton1Down:connect(function()
			if debounce then
				debounce = false
				menu.Main.Menus:TweenPosition(
					UDim2.new(0, 0, 0, 0),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Sine,
					0.25, true, function()
						local expBar = menu.Main.Menus.Stats.ExperienceBar
						if not expBar.Visible then
							expBar.Size = UDim2.new(0, 0, 0, 5)
							expBar.Visible = true
							expBar:TweenSize(
								UDim2.new(0.9, 0, 0, 5),
								Enum.EasingDirection.Out,
								Enum.EasingStyle.Linear,
								0.25, true
							)
						end
						debounce = true
					end
				)
				Player.Client.Sounds.Pop:Play()
			end
		end)
		menu.Open.Settings.MouseButton1Down:connect(function()
			if debounce then
				debounce = false
				menu.Main.Menus:TweenPosition(
					UDim2.new(-2, 0, 0, 0),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Sine,
					0.25, true, function() debounce = true end
				)
				menu.Main.Menus.Stats.ExperienceBar.Visible = false
				Player.Client.Sounds.Pop:Play()
			end
		end)
	end
	do -- Purchase Menu
		local purchaseGui = menu.Main.Menus.Purchase
		
		do -- Handle Pages
			local onPage = 1
			local pages = 2
			purchaseGui.Open.Page.Text = string.format("Page %s of %s", onPage, pages)
			
			local forward = false
			purchaseGui.Open.CycleForward.MouseButton1Down:connect(function()
				Player.Client.Sounds.Pop:Play()
				forward = true
				while forward and onPage < pages do
					purchaseGui.Purchase:TweenPosition(
						UDim2.new(purchaseGui.Purchase.Position.X.Scale - 1, 0, 0, 0),
						Enum.EasingDirection.Out,
						Enum.EasingStyle.Quad,
						0.2, true
					)
					onPage = onPage + 1
					purchaseGui.Open.Page.Text = string.format("Page %s of %s", onPage, pages)
					wait(0.2)
				end
			end)
			purchaseGui.Open.CycleForward.MouseButton1Up:connect(function()
				forward = false
			end)
			
			local backward = false
			purchaseGui.Open.CycleBackward.MouseButton1Down:connect(function()
				Player.Client.Sounds.Pop:Play()
				forward = true
				while forward and onPage > 1 do
					purchaseGui.Purchase:TweenPosition(
						UDim2.new(purchaseGui.Purchase.Position.X.Scale + 1, 0, 0, 0),
						Enum.EasingDirection.Out,
						Enum.EasingStyle.Quad,
						0.2, true
					)
					onPage = onPage - 1
					purchaseGui.Open.Page.Text = string.format("Page %s of %s", onPage, pages)
					wait(0.2)
				end
			end)
			purchaseGui.Open.CycleBackward.MouseButton1Up:connect(function()
				backward = false
			end)
		end
		
		do -- Handle MarketPlace
			local MarketPlace = game.MarketplaceService
			local Prices = {
				Products = {
					Fifty = "10R$",
					OneHundred = "20R$",
					FiveHundred = "100R$",
					OneThousand = "200R$",
					FiveThousand = "1,000R$",
					TenThousand = "2,000R$",
					FiftyThousand = "10,000R$"
				},
				GamePasses = {
					BlankStart = "75R$",
					IncreasedOdds = "150R$",
					RollingWealth = "250R$",
					Experienced = "275R$",
					DrinksAround = "50R$",
					ColorSpectrum = "20R$",
					Donator = "10R$"
				}
			}
			for _, product in pairs(purchaseGui.Purchase.DevProducts:GetChildren()) do
				local function showPrice()
					for _, product in pairs(purchaseGui.Purchase.DevProducts:GetChildren()) do
						product.Purchase.Text = "Purchase"
					end
					product.Purchase.Text = Prices.Products[product.Name]
				end
				product.Purchase.MouseEnter:connect(showPrice)
				product.Purchase.MouseMoved:connect(showPrice)
				product.Purchase.MouseLeave:connect(function()
					for _, product in pairs(purchaseGui.Purchase.DevProducts:GetChildren()) do
						product.Purchase.Text = "Purchase"
					end
				end)
			end
			for _, gamepass in pairs(purchaseGui.Purchase.GamePasses:GetChildren()) do
				local function showPrice()
					for _, gamepass in pairs(purchaseGui.Purchase.GamePasses:GetChildren()) do
						gamepass.Purchase.Text = "Purchase"
						gamepass.Details.Visible = false
					end
					gamepass.Purchase.Text = Prices.GamePasses[gamepass.Name]
					gamepass.Details.Visible = true
				end
				gamepass.Purchase.MouseEnter:connect(showPrice)
				gamepass.Purchase.MouseMoved:connect(showPrice)
				gamepass.Purchase.MouseLeave:connect(function()
					for _, gamepass in pairs(purchaseGui.Purchase.GamePasses:GetChildren()) do
						gamepass.Purchase.Text = "Purchase"
						gamepass.Details.Visible = false
					end
				end)
			end
			local MarketId = require(game.workspace.MarketId)
			do -- Dev Products
				local currency = Enum.CurrencyType.Tix
				local products = purchaseGui.Purchase.DevProducts
				products.Fifty.Purchase.MouseButton1Down:connect(function()
					MarketPlace:PromptProductPurchase(
						Player,
						MarketId.FiftyCredits,
						false, currency
					)
				end)
				products.OneHundred.Purchase.MouseButton1Down:connect(function()
					MarketPlace:PromptProductPurchase(
						Player,
						MarketId.OneHundredCredits,
						false, currency
					)
				end)
				products.FiveHundred.Purchase.MouseButton1Down:connect(function()
					MarketPlace:PromptProductPurchase(
						Player,
						MarketId.FiveHundredCredits,
						false, currency
					)
				end)
				products.OneThousand.Purchase.MouseButton1Down:connect(function()
					MarketPlace:PromptProductPurchase(
						Player,
						MarketId.OneThousandCredits,
						false, currency
					)
				end)
				products.FiveThousand.Purchase.MouseButton1Down:connect(function()
					MarketPlace:PromptProductPurchase(
						Player,
						MarketId.FiveThousandCredits,
						false, currency
					)
				end)
				products.TenThousand.Purchase.MouseButton1Down:connect(function()
					MarketPlace:PromptProductPurchase(
						Player,
						MarketId.TenThousandCredits,
						false, currency
					)
				end)
				products.FiftyThousand.Purchase.MouseButton1Down:connect(function()
					MarketPlace:PromptProductPurchase(
						Player,
						MarketId.FiftyThousandCredits,
						false, currency
					)
				end)
			end
			do -- Gamepasses
				local gamepasses = purchaseGui.Purchase.GamePasses
				gamepasses.BlankStart.Purchase.MouseButton1Down:connect(function()
					MarketPlace:PromptPurchase(
						Player,
						MarketId.BlankStart
					)
				end)
				gamepasses.ColorSpectrum.Purchase.MouseButton1Down:connect(function()
					MarketPlace:PromptPurchase(
						Player,
						MarketId.ColorSpectrum
					)
				end)
				gamepasses.Donator.Purchase.MouseButton1Down:connect(function()
					MarketPlace:PromptPurchase(
						Player,
						MarketId.Donator
					)
				end)
				gamepasses.DrinksAround.Purchase.MouseButton1Down:connect(function()
					MarketPlace:PromptPurchase(
						Player,
						MarketId.DrinksAround
					)
				end)
				gamepasses.Experienced.Purchase.MouseButton1Down:connect(function()
					MarketPlace:PromptPurchase(
						Player,
						MarketId.Experienced
					)
				end)
				gamepasses.IncreasedOdds.Purchase.MouseButton1Down:connect(function()
					MarketPlace:PromptPurchase(
						Player,
						MarketId.IncreasedOdds
					)
				end)
				gamepasses.RollingWealth.Purchase.MouseButton1Down:connect(function()
					MarketPlace:PromptPurchase(
						Player,
						MarketId.RollingWealth
					)
				end)
			end
		end
		
	end
	do -- Stats Menu
		local statsGui = menu.Main.Menus.Stats
		local stats = Player.Client.Stats
		local function updateRatio(wins, loses)
			local ratio
			if wins == 0 and loses == 0 then
				ratio = "0"
			elseif loses == 0 then
				ratio = tostring(wins)
			else
				ratio = tostring(math.floor((wins/loses)*100)/100)
			end
			statsGui.Ratio.Value.Text = ratio
			Player.Client.Ratio.Value = ratio*100
		end
		stats.GamesWon.Changed:connect(function(wins)
			if wins < 0 then
				stats.GamesWon.Value = 0
			else
				statsGui.GamesWon.Value.Text = numberFormat(wins)
				updateRatio(wins, stats.GamesLost.Value)
			end
		end)
		stats.GamesLost.Changed:connect(function(loses)
			if loses < 0 then
				stats.GamesLost.Value = 0
			else
				statsGui.GamesLost.Value.Text = numberFormat(loses)
				updateRatio(stats.GamesWon.Value, loses)
			end
		end)
		stats.Level.Changed:connect(function(level)
			if level < 0 then
				stats.Level.Value = 0
			else
				statsGui.Level.Value.Text = numberFormat(level)
			end
		end)
		stats.Experience.Changed:connect(function(experience)
			local levelExp = math.ceil(stats.Level.Value ^ 2 * 1.5 + 50)
			if levelExp > experience then
				wait()
				statsGui.Experience.Value.Text = string.format("%s/%s", numberFormat(experience), numberFormat(levelExp))
				statsGui.ExperienceBar.Meter:TweenSize(
					UDim2.new((experience/levelExp), 0, 1, 0),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Linear,
					0.25, true
				)
				statsGui.ExperiencePercent.Value.Text = tostring(math.floor((experience / levelExp)*100)).."%"
			elseif experience >= levelExp then
				statsGui.ExperienceBar.Meter.Size = UDim2.new(0, 0, 1, 0)
				stats.Level.Value = stats.Level.Value + 1
				stats.Experience.Value = experience - levelExp
				require(Player.Client).Game:PushGlobalChat("You Leveled Up!", Player.Client.Settings.ChatColor.Value, true)
				Player.Client.Sounds.Extra.Level:Play()
			end
		end)
		statsGui.Reset.Confirm.MouseButton1Down:connect(function()
			game.MarketplaceService:PromptProductPurchase(
				Player,
				require(game.workspace.MarketId).ResetStats
			)
		end)
	end
	do -- Settings Menu
		local settingsGui = menu.Main.Menus.Settings
		do -- Mute Music
			local function toggleMute()
				Player.Client.Settings.MuteMusic.Value = not Player.Client.Settings.MuteMusic.Value
				Player.Client.Sounds.Pop:Play()
			end
			settingsGui.MuteMusic.Switch.MouseButton1Down:connect(toggleMute)
			settingsGui.MuteMusic.Switch.Button.MouseButton1Down:connect(toggleMute)
			Player.Client.Settings.MuteMusic.Changed:connect(function(muteValue)
				if muteValue then
					settingsGui.MuteMusic.Switch.Button:TweenPosition(
						UDim2.new(0.5, 0, -0.5, 0),
						Enum.EasingDirection.Out,
						Enum.EasingStyle.Quad,
						0.1, true, function()
							settingsGui.MuteMusic.Switch.Button.Text = "YES"
						end
					)
				else
					settingsGui.MuteMusic.Switch.Button:TweenPosition(
						UDim2.new(0, -8, -0.5, 0),
						Enum.EasingDirection.Out,
						Enum.EasingStyle.Quad,
						0.1, true, function()
							settingsGui.MuteMusic.Switch.Button.Text = "NO"
						end
					)
				end
			end)
		end
		do -- Mute Sounds
			local function toggleMute()
				Player.Client.Settings.MuteSounds.Value = not Player.Client.Settings.MuteSounds.Value
				Player.Client.Sounds.Pop:Play()
			end
			settingsGui.MuteSounds.Switch.MouseButton1Down:connect(toggleMute)
			settingsGui.MuteSounds.Switch.Button.MouseButton1Down:connect(toggleMute)
			Player.Client.Settings.MuteSounds.Changed:connect(function(muteValue)
				if muteValue then
					settingsGui.MuteSounds.Switch.Button:TweenPosition(
						UDim2.new(0.5, 0, -0.5, 0),
						Enum.EasingDirection.Out,
						Enum.EasingStyle.Quad,
						0.1, true, function()
							settingsGui.MuteSounds.Switch.Button.Text = "YES"
						end
					)
				else
					settingsGui.MuteSounds.Switch.Button:TweenPosition(
						UDim2.new(0, -8, -0.5, 0),
						Enum.EasingDirection.Out,
						Enum.EasingStyle.Quad,
						0.1, true, function()
							settingsGui.MuteSounds.Switch.Button.Text = "NO"
						end
					)
				end
			end)
		end
		do -- Show Names
			local function toggle()
				Player.Client.Settings.ShowNames.Value = not Player.Client.Settings.ShowNames.Value
				Player.Client.Sounds.Pop:Play()
			end
			settingsGui.ShowNames.Switch.MouseButton1Down:connect(toggle)
			settingsGui.ShowNames.Switch.Button.MouseButton1Down:connect(toggle)
			Player.Client.Settings.ShowNames.Changed:connect(function(value)
				if value then
					settingsGui.ShowNames.Switch.Button:TweenPosition(
						UDim2.new(0.5, 0, -0.5, 0),
						Enum.EasingDirection.Out,
						Enum.EasingStyle.Quad,
						0.1, true, function()
							settingsGui.ShowNames.Switch.Button.Text = "YES"
						end
					)
				else
					settingsGui.ShowNames.Switch.Button:TweenPosition(
						UDim2.new(0, -8, -0.5, 0),
						Enum.EasingDirection.Out,
						Enum.EasingStyle.Quad,
						0.1, true, function()
							settingsGui.ShowNames.Switch.Button.Text = "NO"
						end
					)
				end
			end)
		end
		do -- Enable Tips
			local function toggle()
				if not isOnMobile then
					Player.Client.Settings.EnableTips.Value = not Player.Client.Settings.EnableTips.Value
					Player.Client.Sounds.Pop:Play()
				end
			end
			settingsGui.EnableTips.Switch.MouseButton1Down:connect(toggle)
			settingsGui.EnableTips.Switch.Button.MouseButton1Down:connect(toggle)
			Player.Client.Settings.EnableTips.Changed:connect(function(value)
				if not isOnMobile then
					settingsGui.EnableTips.Switch.Visible = true
					settingsGui.EnableTips.LockFeature.Visible = false
					if value then
						settingsGui.EnableTips.Switch.Button:TweenPosition(
							UDim2.new(0.5, 0, -0.5, 0),
							Enum.EasingDirection.Out,
							Enum.EasingStyle.Quad,
							0.1, true, function()
								settingsGui.EnableTips.Switch.Button.Text = "YES"
							end
						)
					else
						settingsGui.EnableTips.Switch.Button:TweenPosition(
							UDim2.new(0, -8, -0.5, 0),
							Enum.EasingDirection.Out,
							Enum.EasingStyle.Quad,
							0.1, true, function()
								settingsGui.EnableTips.Switch.Button.Text = "NO"
							end
						)
					end
					GUI.Parent.Mouse.Target.Visible = value
				else
					settingsGui.EnableTips.Switch.Visible = false
					settingsGui.EnableTips.LockFeature.Visible = true
				end
			end)
			if isOnMobile then
				settingsGui.EnableTips.Switch.Visible = false
				settingsGui.EnableTips.LockFeature.Visible = true
				GUI.Parent.Mouse.Target.Visible = false
			end
		end
		do -- Chat Color
			Player.Client.Settings.ChatColor.Changed:connect(function(color)
				settingsGui.ChatColor.Title.TextColor3 = color
				Player.TeamColor = BrickColor.new(color)
				
				settingsGui.ChatColor.Red.ColorChanger.BackgroundColor3 = Color3.new(color.r, 0, 0)
				settingsGui.ChatColor.Green.ColorChanger.BackgroundColor3 = Color3.new(0, color.g, 0)
				settingsGui.ChatColor.Blue.ColorChanger.BackgroundColor3 = Color3.new(0, 0, color.b)
				
				settingsGui.ChatColor.Red.ColorChanger.Text = math.floor(color.r * 255)
				settingsGui.ChatColor.Green.ColorChanger.Text = math.floor(color.g * 255)
				settingsGui.ChatColor.Blue.ColorChanger.Text = math.floor(color.b * 255)
			end)
			Player.Client.Passes.ColorSpectrum.Changed:connect(function(active)
				for _, gui in pairs(settingsGui.ChatColor:GetChildren()) do
					if gui.Name ~= "Tip" then
						if gui.Name ~= "Lock" then
							gui.Visible = active
						else
							gui.Visible = not active
						end
					end
				end
			end)
			settingsGui.ChatColor.Red.ColorChanger.FocusLost:connect(function()
				local input = settingsGui.ChatColor.Red.ColorChanger.Text
				if tonumber(input) then
					input = tonumber(input)
					if input >= 0 and input <= 255 then
						local currentColor = Player.Client.Settings.ChatColor.Value
						local newColor = Color3.new(input/255, currentColor.g, currentColor.b)
						Player.Client.Settings.ChatColor.Value = newColor
						return true
					end
				end
				settingsGui.ChatColor.Red.ColorChanger.Text = math.floor(Player.Client.Settings.ChatColor.Value.r*255)
				return false
			end)
			settingsGui.ChatColor.Green.ColorChanger.FocusLost:connect(function()
				local input = settingsGui.ChatColor.Green.ColorChanger.Text
				if tonumber(input) then
					input = tonumber(input)
					if input >= 0 and input <= 255 then
						local currentColor = Player.Client.Settings.ChatColor.Value
						local newColor = Color3.new(currentColor.r, input/255, currentColor.b)
						Player.Client.Settings.ChatColor.Value = newColor
						return true
					end
				end
				settingsGui.ChatColor.Green.ColorChanger.Text = math.floor(Player.Client.Settings.ChatColor.Value.g*255)
				return false
			end)
			settingsGui.ChatColor.Blue.ColorChanger.FocusLost:connect(function()
				local input = settingsGui.ChatColor.Blue.ColorChanger.Text
				if tonumber(input) then
					input = tonumber(input)
					if input >= 0 and input <= 255 then
						local currentColor = Player.Client.Settings.ChatColor.Value
						local newColor = Color3.new(currentColor.r, currentColor.g, input/255)
						Player.Client.Settings.ChatColor.Value = newColor
						return true
					end
				end
				settingsGui.ChatColor.Blue.ColorChanger.Text = math.floor(Player.Client.Settings.ChatColor.Value.b*255)
				return false
			end)
			settingsGui.ChatColor.Title.MouseButton1Down:connect(function()
				Player.Client.Settings.ChatColor.Value = Color3.new(1, 1, 1)
			end)
		end
		do -- Twitter Codes
			local redeemMessage, codeGui = "Redeem a Twitter Code", settingsGui.TwitterCodes
			codeGui.Redeem.Focused:connect(function()
				if codeGui.Redeem.Text == redeemMessage then
					codeGui.Redeem.Text = ""
				end
			end)
			codeGui.Redeem.FocusLost:connect(function(entered)
				if entered then
					codeGui.Redeem.Active = false
					local code = codeGui.Redeem.Text:lower()
					local codes = {
						AlphaIsFun = function()
							Player.Client.Credits.Value = Player.Client.Credits.Value + 50
						end
					}
					local redeemed, returnMessage, returnColor = false, "", Color3.new(1,1,1)
					for redeemable, invoke in pairs(codes) do
						if code == redeemable:lower() then
							if not Player.Client.Redeem[redeemable].Value then
								if Player.Client.Redeem[redeemable].Avaliable.Value then
									invoke()
									Player.Client.Redeem[redeemable].Value = true
									returnMessage, returnColor = "Code Redeemed!", Color3.new(0, 1, 0)
								else
									returnMessage, returnColor = "Code Not Avaliable!", Color3.new(1, 0, 0)
								end
							else
								returnMessage, returnColor = "Code Already Redeemed!", Color3.new(1, 0, 0)
							end
						else
							returnMessage, returnColor = "Not A Code!", Color3.new(1, 0, 0)
						end
					end
					codeGui.Redeem.Text = returnMessage
					codeGui.Redeem.TextColor3 = returnColor
					wait(3)
					codeGui.Redeem.Text = redeemMessage
					codeGui.Redeem.TextColor3 = Color3.new(1,1,1)
					codeGui.Redeem.Active = true
				elseif codeGui.Redeem.Text == "" then
					codeGui.Redeem.Text = redeemMessage
				end
			end)
			codeGui.Redeem.Text = redeemMessage
		end
	end
end

do -- Effects
	local handlingBold = false
	Player.Client.Effects.Bold.Changed:connect(function(value)
		if value < 0 then
			Player.Client.Effects.Bold.Value = 0
		end
		if not handlingBold then
			handlingBold = true
			while Player.Client.Effects.Bold.Value > 0 do
				wait(1)
				Player.Client.Effects.Bold.Value = Player.Client.Effects.Bold.Value - 1
			end
			handlingBold = false
		end
	end)
	local handlingGlow = false
	local lastValue = 0
	local light = script.Light:Clone()
	light.Parent = game.Workspace:WaitForChild(Player.Name).Torso
	Player.Client.Effects.Glow.Changed:connect(function(value)
		if value < 0 then
			Player.Client.Effects.Glow.Value = 0
		end
		if lastValue == 0 then
			light.Color = Color3.new(
				math.random(0, 255)/255,
				math.random(0, 255)/255,
				math.random(0, 255)/255
			)
		end
		light.Enabled = (value > 0)
		lastValue = value
		if not handlingGlow then
			handlingGlow = true
			while Player.Client.Effects.Glow.Value > 0 do
				wait(1)
				Player.Client.Effects.Glow.Value = Player.Client.Effects.Glow.Value - 1
			end
			handlingGlow = false
		end
	end)
	local handlingMoney = false
	Player.Client.Effects.Money.Changed:connect(function(value)
		if value < 0 then
			Player.Client.Effects.Money.Value = 0
		end
		if not handlingMoney then
			handlingMoney = true
			local multiplier = Player.Client.Passes.CreditMultiplier
			multiplier.Value = multiplier.Value + 1
			while Player.Client.Effects.Money.Value > 0 do
				Player.Client.Effects.Money.Value = Player.Client.Effects.Money.Value - 1
				wait(1)
			end
			multiplier.Value = multiplier.Value - 1
			handlingMoney = false
		end
	end)
	local handlingXP = false
	Player.Client.Effects.EXP.Changed:connect(function(value)
		if value < 0 then
			Player.Client.Effects.EXP.Value = 0
		end
		if not handlingXP then
			handlingXP = true
			local multiplier = Player.Client.Passes.ExperienceMultiplier
			multiplier.Value = multiplier.Value + 1
			while Player.Client.Effects.EXP.Value > 0 do
				Player.Client.Effects.EXP.Value = Player.Client.Effects.EXP.Value - 1
				wait(1)
			end
			multiplier.Value = multiplier.Value - 1
			handlingXP = false
		end
	end)
	local handlingFirefly = false
	Player.Client.Effects.Firefly.Changed:connect(function(value)
		if value < 0 then
			Player.Client.Effects.Firefly.Value = 0
		end
		if not handlingFirefly then
			handlingFirefly = true
			while Player.Client.Effects.Firefly.Value > 0 do
				Player.Client.Effects.Firefly.Value = Player.Client.Effects.Firefly.Value - 1
				local playerInstance = game.Workspace:FindFirstChild(Player.Name)
				if playerInstance then
					local firefly = playerInstance.Head:Clone()
					for _, child in pairs(firefly:GetChildren()) do
						child:Destroy()
					end
					firefly.Name = "Firefly"
					firefly.Size = Vector3.new(1, 1, 1)
					do
						firefly.BackSurface = Enum.SurfaceType.SmoothNoOutlines
						firefly.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
						firefly.FrontSurface = Enum.SurfaceType.SmoothNoOutlines
						firefly.LeftSurface = Enum.SurfaceType.SmoothNoOutlines
						firefly.RightSurface = Enum.SurfaceType.SmoothNoOutlines
						firefly.TopSurface = Enum.SurfaceType.SmoothNoOutlines
						firefly.Material = Enum.Material.SmoothPlastic
					end
					firefly.BrickColor = BrickColor.Yellow()
					firefly.Transparency = 0.25
					firefly.CanCollide = false
					firefly.CFrame = playerInstance.Head.CFrame
					firefly.Parent = game.Workspace
					
					local positionSetter = Instance.new("BodyPosition", firefly)
					positionSetter.position = playerInstance.Head.Position
					positionSetter.D = 2250
					
					firefly.Touched:connect(function(part)
						positionSetter.position = firefly.Position + Vector3.new(
							math.random(-4, 4),
							math.random(-1, 3),
							math.random(-4, 4)
						)
					end)
					
					local rotationSetter = Instance.new("BodyAngularVelocity", firefly)
					rotationSetter.angularvelocity = Vector3.new(0.3, 0.4, 0.5)
					
					local light = Instance.new("PointLight", firefly)
					light.Brightness = 2
					light.Color = BrickColor.Yellow().Color
					light.Range = 8
					
					debris:AddItem(firefly, 4)
				end
				wait(1)
			end
			handlingFirefly = false
		end
	end)
end

do -- Scroll Arrows
	local menuBoard = GUI.Parent.MenuBoard
	menuBoard.ScrollUp.MouseButton1Down:connect(function()
		if menuBoard.Menu.CanvasPosition.y > 1 then
			menuBoard.Menu.CanvasPosition = Vector2.new(0, menuBoard.Menu.CanvasPosition.y - 120)
		end
	end)
	menuBoard.ScrollDown.MouseButton1Down:connect(function()
		if menuBoard.Menu.CanvasPosition.y < 300 then
			menuBoard.Menu.CanvasPosition = Vector2.new(0, menuBoard.Menu.CanvasPosition.y + 120)
		end
	end)
	local noobScreen = GUI.Parent.NoobScreen
	noobScreen.ScrollUp.MouseButton1Down:connect(function()
		if noobScreen.Menu.CanvasPosition.y > 1 then
			noobScreen.Menu.CanvasPosition = Vector2.new(0, noobScreen.Menu.CanvasPosition.y - 100)
		end
	end)
	noobScreen.ScrollDown.MouseButton1Down:connect(function()
		if noobScreen.Menu.CanvasPosition.y < 1240 then
			noobScreen.Menu.CanvasPosition = Vector2.new(0, noobScreen.Menu.CanvasPosition.y + 100)
		end
	end)
end

do -- Background Music
	local sounds = Player.Client.Sounds
	local stopMusic = false
	local currentSong = nil
	function backgroundMusic()
		if currentSong then currentSong:Stop() end
		local songs = {}
		for _, song in pairs(sounds.Music:GetChildren()) do
			table.insert(songs, song.Name)
		end
		local songIterator = math.random(1, #songs)
		while not stopMusic do
			for _, song in pairs(sounds.Music:GetChildren()) do
				song:Stop()
				song.TimePosition = 0
			end
			if not songs[songIterator] then songIterator = 1 end
			sounds.Music[songs[songIterator]]:Play()
			currentSong = sounds.Music[songs[songIterator]]
			songIterator = songIterator + 1
			repeat wait(1) until not currentSong.IsPlaying or currentSong.TimePosition > 119 or stopMusic
		end
	end
	Player.Client.Settings.MuteMusic.Changed:connect(function(muted)
		if muted then
			sounds.Extra.Intro.Volume = 0
			sounds.Extra.Level.Volume = 0
			for _, music in pairs(sounds.Music:GetChildren()) do
				music.Volume = 0
			end
			stopMusic = true
		else
			sounds.Extra.Intro.Volume = 1
			sounds.Extra.Level.Volume = 0.5
			for _, music in pairs(sounds.Music:GetChildren()) do
				music.Volume = 0.2
			end
			stopMusic = false
			backgroundMusic()
		end
	end)
	Player.Client.Settings.MuteSounds.Changed:connect(function(muted)
		if muted then
			sounds.Pop.Volume = 0
			sounds.Purchase.Volume = 0
			sounds.Energize.Volume = 0
			sounds.Decline.Volume = 0
			sounds.Drink.Volume = 0
		else
			sounds.Pop.Volume = 0.5
			sounds.Purchase.Volume = 0.5
			sounds.Energize.Volume = 0.5
			sounds.Decline.Volume = 0.5
			sounds.Drink.Volume = 0.5
		end
	end)
end

do -- Wrap up
	local human = nil
	local disableReset, errorMsg = pcall(function()
		human = game.Workspace:WaitForChild(Player.Name).Humanoid
		if isOnMobile then
			GUI.Screen.Leave.MouseButton1Down:connect(function()
				human.Jump = true
			end)
			GUI.Screen.Leave.Visible = true
		end
		Player.Client.ShowBackpack.Changed:connect(function(show)
			game.StarterGui:SetCoreGuiEnabled("Backpack", show)
			if not show then
				human:UnequipTools()
			end
		end)
		human.Name = "Human"
	end)
	if not disableReset then
		error("Error: "..errorMsg)
	end
	Player.Client.IsLoaded.Value = true
	repeat wait() until not GUI:FindFirstChild("Intro")
	game.StarterGui:SetCoreGuiEnabled("Backpack", true)
	if isOnMobile then
		userInput.ModalEnabled = false
	end
	if human then human.WalkSpeed = 18 end
	GUI.Parent.Painting.Image.MouseButton1Down:connect(function()
		GUI.Parent.Painting.Image.ImageTransparency = 0.75
		wait(3)
		GUI.Parent.Painting.Image.ImageTransparency = 0
	end)
	GUI.Parent.Book.Activate.MouseButton1Down:connect(function()
		GUI.Parent.CommandsList.Enabled = not GUI.Parent.CommandsList.Enabled
		wait(30)
		GUI.Parent.CommandsList.Enabled = false
	end)
	coroutine.resume(chatViewer)
	backgroundMusic()
end
