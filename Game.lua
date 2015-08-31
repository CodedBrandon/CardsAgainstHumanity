local gameTable = script.Parent
local Cards = require(game.Workspace.Cards)
local pointsService = game.PointsService

local players = {}
local playerMin = 3

local kingLeft = false
local winner = ""

local gameStatus = ""
local gameTime = nil
local continueGame = false
local blackcard = "Black Card"

local cardList = {}
local cardKing = ""
local kingChoosing = false

do -- Game Internal Values
	function setStatus(status, showKing)
		local status = status or ""
		local showKing = showKing or true
		gameStatus = status
		for _, player in pairs(players) do
			if showKing or not player.Client.Game.IsKing.Value then
				require(player.Client).GUI:SetStatus(status)
			end
		end
	end  
	
	function setKingStatus(status)
		for _, player in pairs(players) do
			if player.Client.Game.IsKing.Value then
				require(player.Client).GUI:SetStatus(status)
				break
			end
		end
	end
	
	function setBlackCard(blackCard, showToKing)
		local showToKing = showToKing or true
		local blackCard = blackCard or "Black Card"
		blackcard = blackCard
		for _, player in pairs(players) do
			if not player.Client.Game.IsKing.Value or showToKing then
				require(player.Client).GUI:SetBlackCard(blackCard)
			end
		end
	end
	
	local kingIterator = 1
	function setNextCardKing()
		pcall(function()
			local king
			if players[kingIterator] then
				king = players[kingIterator]
			else
				king = players[1]
				kingIterator = 1
			end
			kingIterator = kingIterator + 1
			cardKing = "The Card King is "..king.Name
			king.Client.Game.IsKing.Value = true
			for _, player in pairs(players) do
				if player.Client.Game.IsKing.Value then
					require(player.Client).GUI:SetCardKing("You are the Card King")
				else
					require(player.Client).GUI:SetCardKing(cardKing)
				end
			end
		end)
	end
	
	function resetGameValues()
		kingLeft = false
		winner = ""
		cardKing = ""
		continueGame = false
		cardList = {}
		setStatus()
		setBlackCard()
		script.KingChose.Value = false
		script.DoubleBlack.Value = false
		for _, player in pairs(players) do
			player.Client.Game.Card1.Value = ""
			player.Client.Game.Card2.Value = ""
			player.Client.Game.IsKing.Value = false
			local client = require(player.Client)
			client.GUI:ResetTimer()
			client.GUI:ResetKingCards()
			client.GUI:SetCardKing()
		end
	end
end

do -- Handle Game Calls
	script.SendChat.OnServerInvoke = function(player, chat, color, bold)
		for _, attendee in pairs(players) do
			require(attendee.Client).Game:PushChat(chat, color, bold)
		end
	end
	script.SendKingsSelection.OnInvoke = function(winningPlayer)
		print("The King chose "..winningPlayer)
		script.KingChose.Value = true
		winner = winningPlayer
	end
end

do -- Handle Table Seats
	for _, seat in pairs(gameTable.Seats:GetChildren()) do
		seat.Changed:connect(function()
			if seat.Occupant then -- Register if the player joined or left the table
				seat.Player.Value = tostring(seat.Occupant.Parent.Name)
				local player = game.Players:FindFirstChild(seat.Player.Value)
				player.Client.Table.Value = script
				player.Client.ShowBackpack.Value = false
				local client = require(player.Client) do
					client.Game:JoinTable()
					client.GUI:SetStatus(gameStatus)
					client.GUI:SetBlackCard(blackcard)
					client.GUI:SetCardKing(cardKing)
					if gameTime then
						client.GUI:SetTimer(gameTime, 60)
					else
						client.GUI:ResetTimer()
					end
					if kingChoosing then
						if script.DoubleBlack.Value then
							client.GUI:SetKingDoubleCards(cardList)
						else
							client.GUI:SetKingCards(cardList)
						end
					end
				end
			else
				local player = game.Players:FindFirstChild(seat.Player.Value)
				if player then
					kingLeft = player.Client.Game.IsKing.Value
					player.Client.Table.Value = nil
					player.Client.Game.Card1.Value = ""
					player.Client.Game.Card2.Value = ""
					player.Client.Game.IsKing.Value = false
					player.Client.ShowBackpack.Value = true
					local client = require(player.Client) do
						client.Game:LeaveTable()
						client.GUI:SetStatus()
						client.GUI:SetBlackCard()
						client.GUI:ResetTimer()
						client.GUI:ResetKingCards()
						client.GUI:SetCardKing()
						client.GUI:ResetChat()
					end
				end
			end
			
			local list = {} -- Update players list
			for _, seat in pairs(gameTable.Seats:GetChildren()) do
				if seat.Occupant then
					table.insert(list, game.Players:FindFirstChild(seat.Occupant.Parent.Name))
				end
			end
			players = list
		end)
		seat.Anchored = false
		do -- Weld Seat
			local seatWeld = Instance.new("Weld", seat)
			seatWeld.Part0 = seat
			seatWeld.Part1 = game.Workspace.SeatAnchor
			seatWeld.Name = "Weld"
		end
	end
end

gameTable.TouchJoin.Click.MouseHoverEnter:connect(function(Player)
	if
		not Player.Client.Table.Value
		and not Player.Client.MobileUser.Value
		and Player.Client.IsLoaded.Value
	then
		--require(Player.Client).Game:ShowJoinTable(gameTable.Seats:GetChildren())
	end
end)

gameTable.TouchJoin.Click.MouseHoverLeave:connect(function(Player)
	if not Player.Client.Table.Value then
		--require(Player.Client).Game:CloseJoinTable()
	end
end)

local function playerLoop(invoke)
	for _, player in pairs(players) do
		invoke(player)
	end
end

while true do -- Game Loop
	repeat -- Check Player Count
		wait(1)
		setStatus(string.format("Waiting for Players | %s of %s", #players, playerMin))
	until not (#players < playerMin)
	
	do -- Setup Game
		setStatus("Starting New Game")
		wait(5)
		setStatus("Selecting a Black Card")
		wait(1)
		if math.random(1, 8) == 1 then
			script.DoubleBlack.Value = true
			setBlackCard(Cards.DoubleBlack[math.random(1, #Cards.DoubleBlack)])
		else
			script.DoubleBlack.Value = false
			setBlackCard(Cards.Black[math.random(1, #Cards.Black)])
		end
		setStatus("Selecting a Card King")
		wait(1)
		setNextCardKing()
	end
	
	script.IsChoosing.Value = true
	if script.DoubleBlack.Value then
		setStatus("Choose two white cards", false)
	else
		setStatus("Choose a white card", false)
	end
	setKingStatus("You're the Card King, please wait!")
	for x = 60, 0, -1 do -- Choose White Card
		playerLoop(function(player)
			local client = require(player.Client)
			client.GUI:SetTimer(x, 60)
		end)
		wait(1)
		do -- Check Player Submissions
			local allSubmitted = true
			for _, player in pairs(players) do
				if
					(player.Client.Game.Card1.Value == ""
					or (player.Client.Game.Card2.Value == "" and script.DoubleBlack.Value))
					and not player.Client.Game.IsKing.Value
				then
					allSubmitted = false
					break
				end
			end
			if allSubmitted  and not kingLeft then
				if script.DoubleBlack.Value then
					setStatus("Everyone has played their White Cards")
				else
					setStatus("Everyone has played their White Card")
				end
				continueGame = true
				wait(3)
				if not kingLeft then break end
			end
		end
		if kingLeft then
			setStatus("The Card King left the Table")
			wait(3)
			break
		end
	end
	script.IsChoosing.Value = false
	
	if not continueGame and not kingLeft then
		local playerSubmissions = {}
		for _, player in pairs(players) do
			if not player.Client.Game.IsKing.Value then
				if script.DoubleBlack.Value and player.Client.Game.Card2.Value ~= "" then
					table.insert(playerSubmissions, player)
				elseif not script.DoubleBlack.Value and player.Client.Game.Card1.Value ~= "" then
					table.insert(playerSubmissions, player)
				end
			end
		end
		if #playerSubmissions >= 1 then
			continueGame = true
			if script.DoubleBlack.Value then
				setStatus("Enough players submitted White Cards")
			else
				setStatus("Enough players submitted a White Card")
			end
			wait(3)
		else
			if script.DoubleBlack.Value then
				setStatus("Not enough players submitted White Cards")
			else
				setStatus("Not enough players submitted a White Card")
			end
			wait(3)
		end
	end
	
	if continueGame and not kingLeft then -- Kings Selection
		playerLoop(function(player)
			if not player.Client.Game.IsKing.Value then
				if script.DoubleBlack.Value and player.Client.Game.Card2.Value ~= "" then
					table.insert(cardList, {
						card1 = player.Client.Game.Card1.Value,
						card2 = player.Client.Game.Card2.Value,
						player = player.Name
					})
				elseif player.Client.Game.Card1.Value ~= "" then
					table.insert(cardList, {
						card1 = player.Client.Game.Card1.Value,
						player = player.Name
					})
				end
			end
		end)
		wait()
		playerLoop(function(player)
			local client = require(player.Client)
			client.GUI:ResetTimer()
			if script.DoubleBlack.Value then
				client.GUI:SetKingDoubleCards(cardList)
			else
				client.GUI:SetKingCards(cardList)
			end
		end)
		wait()
		setStatus("The Card King is Choosing", false)
		if script.DoubleBlack.Value then
			setKingStatus("Choose the best White Cards")
		else
			setKingStatus("Choose the best White Card")
		end
		kingChoosing = true
		for x = 60, 0, -1 do
			if not kingLeft then
				playerLoop(function(player)
					require(player.Client).GUI:SetTimer(x, 60)
				end)
				if script.KingChose.Value then
					setStatus(winner.." won the Game")
					for _, player in pairs(players) do
						require(player.Client).GUI:ShowWinner(winner)
						if player.Client.Settings.ShowNames.Value then
							require(player.Client).GUI:ShowNames()
						end
						if player.Name == winner then
							player.Client.Credits.Value = player.Client.Credits.Value 
								+ (1 * player.Client.Passes.CreditMultiplier.Value)
								
							player.Client.Stats.Experience.Value = player.Client.Stats.Experience.Value 
								+ (math.random(30, 60) * player.Client.Passes.ExperienceMultiplier.Value)
								
							player.Client.Stats.GamesWon.Value = player.Client.Stats.GamesWon.Value + 1
							
							pointsService:AwardPoints(player.userId, 1)
							
						elseif player.Client.Game.IsKing.Value then
							player.Client.Stats.Experience.Value = player.Client.Stats.Experience.Value 
								+ (math.random(5, 10) * player.Client.Passes.ExperienceMultiplier.Value)
								
							player.Client.Stats.KingRounds.Value = player.Client.Stats.KingRounds.Value + 1
							
						elseif player.Name ~= winner then
							player.Client.Stats.Experience.Value = player.Client.Stats.Experience.Value 
								+ (math.random(1, 2) * player.Client.Passes.ExperienceMultiplier.Value)
								
							player.Client.Stats.GamesLost.Value = player.Client.Stats.GamesLost.Value + 1
							
						end
						
					end
					wait(5)
					break
				end
				wait(1)
			else
				setStatus("The Card King left the Table")
				wait(3)
				break
			end
		end
		kingChoosing = false
		if not script.KingChose.Value and not kingLeft then
			setStatus("The Card King didn't choose a card")
			wait(3)
		end
	end

	resetGameValues()
end
