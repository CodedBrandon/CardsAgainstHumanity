local Cards = require(game.Workspace.Cards)

local Client = {
	GUI = {
		Interface = (function() return script.Parent:WaitForChild("PlayerGui").Game.Screen end)(),
		SetBlackCard = function(self, blackcard)
			local blackcard = blackcard or "Black Card"
			self.Interface.BlackCard.Text = blackcard
		end,
		SetTimer = function(self, percent, overralTime)
			self.Interface.Time.Display.Text = "Time Left | "..percent
			self.Interface.Time.Meter:TweenSize(
				UDim2.new(1 - (percent / overralTime), 0, 1, 0),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Linear,
				1, true
			)
		end,
		ResetTimer = function(self)
			self.Interface.Time.Display.Text = "Time"
			self.Interface.Time.Meter.Size = UDim2.new(0, 0, 1, 0)
		end,
		ResetChat = function(self)
			for _, chat in pairs(self.Interface.Chat:GetChildren()) do
				if chat:IsA("TextLabel") then
					chat.Text = ""
					chat.Player.Text = ""
				end
			end
		end,
		SetStatus = function(self, status)
			self.Interface.Status.Text = status or ""
		end,
		SetCardKing = function(self, king)
			local king = king or ""
			self.Interface.CardKing.Text = king
		end,
		SetKingCards = function(self, cards)
			local size = self.Interface.Parent.Parent.GetSize:InvokeClient(script.Parent) or 220
			for x = 1, #cards do
				if cards[x] then
					local card = self.Interface.KingCards.CardTemplate:Clone()
					card.Parent = self.Interface.KingCards
					card.Text = cards[x].card1
					card.PlayedBy.Value = cards[x].player
					card.Name = "Card"
					card.Size = UDim2.new(
						0,
						size,
						1,
						-self.Interface.KingCards.ScrollBarThickness
					)
					card.Position = UDim2.new(
						0,
						(x-1)*size,
						0,
						0
					)
					card.Visible = true
					self.Interface.KingCards.CanvasSize = UDim2.new(
						0,
						(x-1)*size,
						0,
						0
					)
					if script.Game.IsKing.Value then
						card.MouseButton1Down:connect(function()
							print("King submisison")
							if script.Table.Value and not script.Table.Value.KingChose.Value then
								script.Table.Value.SendKingsSelection:Invoke(cards[x].player)
								script.Sounds.Pop:Play()
							end
						end)
					end
				end
			end
			self.Interface.Cards.Visible = false
			self.Interface.KingCards.Visible = true
		end,
		SetKingDoubleCards = function(self, cardSets)
			local size = self.Interface.Parent.Parent.GetSize:InvokeClient(script.Parent)*2 or 220
			for x = 1, #cardSets do
				if cardSets[x] then
					local card = self.Interface.KingDoubleCards.CardTemplate:Clone()
					card.Parent = self.Interface.KingDoubleCards
					card.Card1.Text = cardSets[x].card1
					card.Card2.Text = cardSets[x].card2
					card.PlayedBy.Value = cardSets[x].player
					card.Name = "Card"
					card.Size = UDim2.new(
						0,
						size,
						1,
						-self.Interface.KingDoubleCards.ScrollBarThickness
					)
					card.Position = UDim2.new(
						0,
						(x-1)*size,
						0,
						0
					)
					card.Visible = true
					self.Interface.KingDoubleCards.CanvasSize = UDim2.new(
						0,
						(x-1)*size,
						0,
						0
					)
					if script.Game.IsKing.Value then
						local function submit()
							print("King submission")
							if script.Table.Value and not script.Table.Value.KingChose.Value then
								script.Table.Value.SendKingsSelection:Invoke(cardSets[x].player)
								script.Sounds.Pop:Play()
							end
						end
						card.MouseButton1Down:connect(submit)
						card.Card1.MouseButton1Down:connect(submit)
						card.Card2.MouseButton1Down:connect(submit)
					end
				end
			end
			self.Interface.Cards.Visible = false
			self.Interface.KingDoubleCards.Visible = true
		end,
		ResetKingCards = function(self)
			self.Interface.KingDoubleCards.Visible = false
			self.Interface.KingCards.Visible = false
			for _, card in pairs(self.Interface.KingDoubleCards:GetChildren()) do
				if card.Name ~= "CardTemplate" then
					card:Destroy()
				end
			end
			for _, card in pairs(self.Interface.KingCards:GetChildren()) do
				if card.Name ~= "CardTemplate" then
					card:Destroy()
				end
			end
			self.Interface.Cards.Visible = true
		end,
		RandomizeCards = function(self, starterBlank)
			for _, card in pairs(self.Interface.Cards:GetChildren()) do
				if card.Name == "Card" then
					card.Text = Cards.White[math.random(1, #Cards.White)]
				end
			end
			if starterBlank then
				local cardTable = {}
				for _, card in pairs(self.Interface.Cards:GetChildren()) do
					if card.Name == "Card" then
						table.insert(cardTable, card)
					end
				end
				local blankIndex = math.random(1, #cardTable)
				if cardTable[blankIndex] then
					cardTable[blankIndex].Text = "Blank Card"
				end
			end
		end,
		ReplaceCard = function(self, cardText)
			local cards = self.Interface.Cards:GetChildren()
			for x = 1, 3 do
				local randomReplace = math.random(1, #cards)
				for id, card in pairs(cards) do
					if id == randomReplace and card.Text ~= "Blank Card" and card.Text ~= cardText then
						card.Text = cardText
						return
					end
				end
			end
			for _, card in pairs(cards) do
				if card.Text ~= "Blank Card" and card.Text ~= cardText then
					card.Text = cardText
					return
				end
			end
		end,
		ShowWinner = function(self, winnerName)
			if script.Table.Value then
				if script.Table.Value.DoubleBlack.Value then
					for _, card in pairs(self.Interface.KingDoubleCards:GetChildren()) do
						if card.PlayedBy.Value == winnerName then
							card.Card1.Font = Enum.Font.SourceSansBold
							card.Card2.Font = Enum.Font.SourceSansBold
							break
						end
					end
				else
					for _, card in pairs(self.Interface.KingCards:GetChildren()) do
						if card.PlayedBy.Value == winnerName then
							card.Font = Enum.Font.SourceSansBold
							break
						end
					end
				end
			end
		end,
		ShowNames = function(self)
			if script.Table.Value then
				if script.Table.Value.DoubleBlack.Value then
					for _, card in pairs(self.Interface.KingDoubleCards:GetChildren()) do
						card.Player.Text = card.PlayedBy.Value
					end
				else
					for _, card in pairs(self.Interface.KingCards:GetChildren()) do
						card.Player.Text = card.PlayedBy.Value
					end
				end
			end
		end
	},
	Game = {
		GUI = script.Parent.PlayerGui.Game,
		PlayerPath = "http://www.roblox.com/thumbs/avatar.ashx?x=150&y=200&format=png&username=",
		JoinTable = function(self)
			for _, gui in pairs(self.GUI:GetChildren()) do
				if gui.Name == "Screen" then
					gui.Visible = true
				else
					gui.Visible = false
				end
			end
			
		end,
		LeaveTable = function(self)
			for _, gui in pairs(self.GUI:GetChildren()) do
				if gui.Name == "Screen" then
					gui.Visible = false
				else
					gui.Visible = true
				end
			end
			script.Game.Card1.Value = ""
			script.Game.Card2.Value = ""
			script.Game.IsKing.Value = false
		end,
		ShowJoinTable = function(self, seats)
			local seatGui = self.GUI.Parent.Seats
			for _, seat in pairs(seats) do
				local seatButton = seatGui.SeatTemplate:Clone()
				seatButton.Name = "Seat"
				seatButton.Adornee = seat
				seatButton.Join.Visible = true
				seatButton.Join.MouseButton1Down:connect(function()
					
					self:CloseJoinTable()
				end)
				seatButton.Parent = seatGui
			end
		end,
		CloseJoinTable = function(self)
			for _, seat in pairs(self.GUI.Parent.Seats:GetChildren()) do
				if seat.Name == "Seat" then
					seat:Destroy()
				end
			end
		end,
		LoadBar = function(self, progress, final)
			self.GUI.Intro.Display.Bar.Progress:TweenSize(
				UDim2.new(progress/final, 0, 1, 0),
				Enum.EasingDirection.Out,
				Enum.EasingStyle.Linear,
				0.1, true
			)
		end,
		PlayIntro = function(self)
			local intro = self.GUI.Intro
			if intro.Visible then
				intro.Display.Changed:connect(function(property)
					if property == "Text" then
						intro.Display.Shadow.Text = intro.Display.Text
					end
				end)
				intro.Display.Bar:TweenSizeAndPosition(
					UDim2.new(0, 0, 0, 5),
					UDim2.new(0.5, 0, 1, 0),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Quad,
					1
				)
				--wait(1)
				for x = 0, 1.05, 0.05 do
					intro.Display.TextTransparency = x
					intro.Version.TextTransparency = x * 1.25
					intro.Display.Bar.Progress.Transparency = x * 3
					intro.Display.Shadow.TextTransparency = x
					wait(0.05)
				end
				script.Sounds.Extra.Intro:Play()
				intro.Display.Position = UDim2.new(0, 0, 0.5, 150)
				intro.DBS:TweenPosition(
					UDim2.new(0.5, -250, 0.5, -300),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Quad,
					1.5
				)
				intro.Display.Text = "Dark Bolt Studios"
				for x = 1, -0.05, -0.05 do
					intro.DBS.ImageTransparency = x
					intro.Display.TextTransparency = x
					intro.Display.Shadow.TextTransparency = x
					wait(0.05)
				end
				wait(1)
				for x = 0, 1.05, 0.05 do
					intro.Display.TextTransparency = x
					intro.Display.Shadow.TextTransparency = x
					wait(0.05)
				end
				intro.Display.Text = "Presents"
				for x = 1, -0.05, -0.05 do
					intro.Display.TextTransparency = x
					intro.Display.Shadow.TextTransparency = x
					wait(0.05)
				end
				wait(1)
				for x = 0, 1.05, 0.05 do
					intro.DBS.ImageTransparency = x
					intro.Display.TextTransparency = x
					intro.Display.Shadow.TextTransparency = x
					wait(0.05)
				end
				intro.LeftFrame:TweenSizeAndPosition(
					UDim2.new(0, 50, 1, 0),
					UDim2.new(0.5, -50, 0, 0),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Quad,
					1
				)
				intro.RightFrame:TweenSizeAndPosition(
					UDim2.new(0, 50, 1, 0),
					UDim2.new(0.5, 0, 0, 0),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Quad,
					1
				)
				for x = 1, -0.05, -0.05 do
					intro.LeftFrame.Transparency = x
					intro.RightFrame.Transparency = x
					wait(0.05)
				end
				intro.LeftFrame:TweenPosition(
					UDim2.new(0, -50, 0, 0),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Quad,
					1
				)
				intro.RightFrame:TweenPosition(
					UDim2.new(1, 0, 0, 0),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Quad,
					1
				)
				intro.CenterScreen:TweenSizeAndPosition(
					UDim2.new(1, 0, 1, 0),
					UDim2.new(0, 0, 0, 0),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Quad,
					1
				)
				intro.Display.TextColor3 = Color3.new(0, 0, 0)
				intro.Display.Text = "The Game for Horrible People"
				intro.Display.FontSize = Enum.FontSize.Size36
				wait(1)
				for x = 1, -0.05, -0.05 do
					intro.Display.TextTransparency = x
					wait(0.05)
				end
				wait(1.5)
				for x = 0, 1.05, 0.05 do
					intro.Display.TextTransparency = x
					intro.CenterScreen.Logo.ImageTransparency = x
					wait(0.025)
				end
				intro:TweenPosition(
					UDim2.new(1, 50, 0, 0),
					Enum.EasingDirection.Out,
					Enum.EasingStyle.Quad,
					1
				)
			end
			return true
		end,
		PushGlobalChat = function(self, chat, color, bold)
			local bold = bold or false
			for x = 1, 9 do
				self.GUI.GlobalChat["Chat"..x].Text = self.GUI.GlobalChat["Chat"..x+1].Text
				self.GUI.GlobalChat["Chat"..x].TextColor3 = self.GUI.GlobalChat["Chat"..x+1].TextColor3
				self.GUI.GlobalChat["Chat"..x].Font = self.GUI.GlobalChat["Chat"..x+1].Font
			end
			self.GUI.GlobalChat.Chat10.Text = chat
			self.GUI.GlobalChat.Chat10.TextColor3 = color
			if bold then
				self.GUI.GlobalChat.Chat10.Font = Enum.Font.SourceSansBold
			else
				self.GUI.GlobalChat.Chat10.Font = Enum.Font.SourceSans
			end
		end,
		PushChat = function(self, chat, color, bold)
			local bold = bold or false
			local gui = self.GUI.Screen.Chat
			for x = 1, 8 do
				gui["Chat"..x].Text = gui["Chat"..x+1].Text
				gui["Chat"..x].TextColor3 = gui["Chat"..x+1].TextColor3
				gui["Chat"..x].Font = gui["Chat"..x+1].Font
			end
			gui.Chat9.Text = chat
			gui.Chat9.TextColor3 = color
			if bold then
				gui.Chat9.Font = Enum.Font.SourceSansBold
			else
				gui.Chat9.Font = Enum.Font.SourceSans
			end
		end,
		HandleCommand = function(self, args)
			local args = args or {}
			local chatReturn, returnColor = "Invalid Command", Color3.new(225/255, 0, 0)
			local function figurePlayers(input)
				local returnItems = {}
				if input == "all" then
					for _, player in pairs(game.Players:GetChildren()) do
						table.insert(returnItems, player)
					end
				elseif input == "me" then
					table.insert(returnItems, script.Parent)
				elseif input == "random" then
					local randomId = math.random(1, #game.Players:GetChildren())
					for id, player in pairs(game.Players:GetChildren()) do
						if id == randomId then
							table.insert(returnItems, player)
							break
						end
					end
				else
					for _, player in pairs(game.Players:GetChildren()) do
						if input == player.Name:sub(1, #input):lower() then
							table.insert(returnItems, player)
							break
						end
					end
				end
				return returnItems
			end
			local function figureEndStatement(playerList)
				if #playerList > 1 then
					return #playerList.." players!"
				else
					return "one player!"
				end
			end
			if script.Admin.Value then
				if args[1] and args[1] == "give" then
					if args[2] then
						local givePlayers = figurePlayers(args[2])
						if args[3] and type(tonumber(args[3])) == "number" then
							local amount = tonumber(args[3])
							if args[4] then
								if args[4] == "credits" then
									for _, player in pairs(givePlayers) do
										player.Client.Credits.Value = player.Client.Credits.Value + amount
									end
									chatReturn = "Given "..amount.." credits to "..figureEndStatement(givePlayers)
									returnColor = Color3.new(200/255, 200/255, 200/255)
								elseif args[4] == "wins" then
									for _, player in pairs(givePlayers) do
										player.Client.Stats.GamesWon.Value = player.Client.Stats.GamesWon.Value + amount
									end
									chatReturn = "Given "..amount.." wins to "..figureEndStatement(givePlayers)
									returnColor = Color3.new(200/255, 200/255, 200/255)
								elseif args[4] == "loses" then
									for _, player in pairs(givePlayers) do
										player.Client.Stats.GamesLost.Value = player.Client.Stats.GamesLost.Value + amount
									end
									chatReturn = "Given "..amount.." loses to "..figureEndStatement(givePlayers)
									returnColor = Color3.new(200/255, 200/255, 200/255)
								else
									chatReturn = "/give [player] [amount] [type]"
									returnColor = Color3.new(225/255, 0, 0)
								end
							else
								chatReturn = "/give [player] [amount] [type]"
								returnColor = Color3.new(225/255, 0, 0)
							end
						else
							chatReturn = "/give [player] [amount] [type]"
							returnColor = Color3.new(225/255, 0, 0)
						end
					else
						chatReturn = "/give [player] [amount] [type]"
						returnColor = Color3.new(225/255, 0, 0)
					end
				elseif args[1] and args[1] == "set" then
					if args[2] then
						local setPlayers = figurePlayers(args[2])
						if args[4] and type(tonumber(args[4])) == "number" then
							local amount = tonumber(args[4])
							if args[3] then
								if args[3] == "credits" then
									for _, player in pairs(setPlayers) do
										player.Client.Credits.Value =  amount
									end
									chatReturn = "Set credits to "..amount.." for "..figureEndStatement(setPlayers)
									returnColor = Color3.new(200/255, 200/255, 200/255)
								elseif args[3] == "wins" then
									for _, player in pairs(setPlayers) do
										player.Client.Stats.GamesWon.Value = amount
									end
									chatReturn = "Set wins to "..amount.." for "..figureEndStatement(setPlayers)
									returnColor = Color3.new(200/255, 200/255, 200/255)
								elseif args[3] == "loses" then
									for _, player in pairs(setPlayers) do
										player.Client.Stats.GamesLost.Value = amount
									end
									chatReturn = "Set loses to "..amount.." for "..figureEndStatement(setPlayers)
									returnColor = Color3.new(200/255, 200/255, 200/255)
								else
									chatReturn = "/set [player] [type] [amount]"
									returnColor = Color3.new(225/255, 0, 0)
								end
							else
								chatReturn = "/set [player] [type] [amount]"
								returnColor = Color3.new(225/255, 0, 0)
							end
						else
							chatReturn = "/set [player] [type] [amount]"
							returnColor = Color3.new(225/255, 0, 0)
						end
					else
						chatReturn = "/set [player] [type] [amount]"
						returnColor = Color3.new(225/255, 0, 0)
					end
				elseif args[1] and args[1] == "remove" then
					if args[2] then
						local removePlayers = figurePlayers(args[2])
						if args[3] and type(tonumber(args[3])) == "number" then
							local amount = tonumber(args[3])
							if args[4] then
								if args[4] == "credits" then
									for _, player in pairs(removePlayers) do
										player.Client.Credits.Value = player.Client.Credits.Value - amount
									end
									chatReturn = "Removed "..amount.." credits from "..figureEndStatement(removePlayers)
									returnColor = Color3.new(200/255, 200/255, 200/255)
								elseif args[4] == "wins" then
									for _, player in pairs(removePlayers) do
										player.Client.Stats.GamesWon.Value = player.Client.Stats.GamesWon.Value - amount
									end
									chatReturn = "Removed "..amount.." wins from "..figureEndStatement(removePlayers)
									returnColor = Color3.new(200/255, 200/255, 200/255)
								elseif args[4] == "loses" then
									for _, player in pairs(removePlayers) do
										player.Client.Stats.GamesLost.Value = player.Client.Stats.GamesLost.Value - amount
									end
									chatReturn = "Removed "..amount.." loses from "..figureEndStatement(removePlayers)
									returnColor = Color3.new(200/255, 200/255, 200/255)
								else
									chatReturn = "/remove [player] [amount] [type]"
									returnColor = Color3.new(225/255, 0, 0)
								end
							else
								chatReturn = "/remove [player] [amount] [type]"
								returnColor = Color3.new(225/255, 0, 0)
							end
						else
							chatReturn = "/remove [player] [amount] [type]"
							returnColor = Color3.new(225/255, 0, 0)
						end
					else
						chatReturn = "/remove [player] [amount] [type]"
						returnColor = Color3.new(225/255, 0, 0)
					end
				elseif args[1] and args[1] == "effect" then
					if args[2] then
						local effecting = figurePlayers(args[2])
						if args[4] and tonumber(args[4]) then
							local effectTime = tonumber(args[4])
							if args[3] then
								if args[3] == "bold" then
									for _, player in pairs(effecting) do
										player.Client.Effects.Bold.Value = player.Client.Effects.Bold.Value + effectTime
									end
									chatReturn = "Bold Effect added for "..effectTime.."s to "..figureEndStatement(effecting)
									returnColor = Color3.new(0/255, 180/255, 0/255)
								elseif args[3] == "glow" then
									for _, player in pairs(effecting) do
										player.Client.Effects.Glow.Value = player.Client.Effects.Glow.Value + effectTime
									end
									chatReturn = "Glow Effect added for "..effectTime.."s to "..figureEndStatement(effecting)
									returnColor = Color3.new(0/255, 180/255, 0/255)
								elseif args[3] == "money" then
									for _, player in pairs(effecting) do
										player.Client.Effects.Money.Value = player.Client.Effects.Money.Value + effectTime
									end
									chatReturn = "Money Effect added for "..effectTime.."s to "..figureEndStatement(effecting)
									returnColor = Color3.new(0/255, 180/255, 0/255)
								elseif args[3] == "exp" or args[3] == "experience" then
									for _, player in pairs(effecting) do
										player.Client.Effects.EXP.Value = player.Client.Effects.EXP.Value + effectTime
									end
									chatReturn = "EXP Effect added for "..effectTime.."s to "..figureEndStatement(effecting)
									returnColor = Color3.new(0/255, 180/255, 0/255)
								elseif args[3] == "firefly" then
									for _, player in pairs(effecting) do
										player.Client.Effects.Firefly.Value = player.Client.Effects.Firefly.Value + effectTime
									end
									chatReturn = "Firefly Effect added for "..effectTime.."s to "..figureEndStatement(effecting)
									returnColor = Color3.new(0/255, 180/255, 0/255)
								else
									chatReturn = "/effect [player] [effect] [time]"
									returnColor = Color3.new(225/255, 0, 0)
								end
							else
								chatReturn = "/effect [player] [effect] [time]"
								returnColor = Color3.new(225/255, 0, 0)
							end
						else
							chatReturn = "/effect [player] [effect] [time]"
							returnColor = Color3.new(225/255, 0, 0)
						end
					else
						chatReturn = "/effect [player] [effect] [time]"
						returnColor = Color3.new(225/255, 0, 0)
					end
				elseif args[1] and args[1] == "implode" then
					if args[2] then
						local affect = figurePlayers(args[2])
						for _, player in pairs(affect) do
							local body = game.Workspace:FindFirstChild(player.Name)
							if body then
								local explosion = Instance.new("Explosion")
								explosion.BlastPressure = 0
								explosion.BlastRadius = 8
								explosion.Position = body.Torso.Position
								explosion.Parent = game.Workspace
							end
						end
						chatReturn = "Imploded "..figureEndStatement(affect)
						returnColor = Color3.new(250/255, 175/255, 0)
					else
						chatReturn = "/implode [player]"
						returnColor = Color3.new(1, 0, 0)
					end
				elseif args[1] and args[1] == "stream" then
					if args[2] then
						if args[2] == "live" or args[2] == "on" or args[2] == "true" then
							game.Workspace.Streaming.Value = true
							game.Workspace.Stream.Twitch.Background.Visible = true
							chatReturn, returnColor = "Stream is Live!", Color3.new(100/255, 65/255, 165/255)
						elseif args[2] == "off" or args[2] == "false" then
							game.Workspace.Streaming.Value = false
							game.Workspace.Stream.Twitch.Background.Visible = false
							chatReturn, returnColor = "No Longer Live!", Color3.new(100/255, 65/255, 165/255)
						else
							chatReturn, returnColor = "/stream [live]", Color3.new(1, 0, 0)
						end
					else
						chatReturn, returnColor = "/stream [live]", Color3.new(1, 0, 0)
					end
				end
			end
			if script.Moderator.Value then
				if args[1] and args[1] == "kick" then
					if args[2] then
						local kicking = figurePlayers(args[2])
						for _, player in pairs(kicking) do
							if not player.Client.Moderator.Value and not player.Client.Admin.Value then
								player:Kick("Kicked by a Moderator")
							end
						end
					else
						chatReturn = "/kick [player]"
					end
				end
			end
			do -- Non-Admin Commands
				if args[1] and args[1] == "music" then
					local music = "Your music is currently muted!"
					for _, song in pairs(script.Sounds.Music:GetChildren()) do
						if song.IsPlaying then
							music = "Currently Playing '"..song.Name.."' by "..song.Author.Value
						end
					end
					chatReturn, returnColor = music, Color3.new(0, 150/255, 200/255)
				elseif args[1] and (args[1] == "msg" or args[1] == "message" or args[1] == "w") then
					if args[2] then
						local msgPlayer = nil
						for _, player in pairs(game.Players:GetChildren()) do
							if args[2]:lower() == player.Name:sub(1, #args[2]):lower() then
								msgPlayer = player
								break
							end
						end
						if msgPlayer then
							if msgPlayer ~= script.Parent then
								if args[3] then
									local sendChat = ""
									for x = 3, #args do
										sendChat = sendChat..args[x].." "
									end
									if msgPlayer.Client.Table.Value then
										require(msgPlayer.Client).Game:PushChat(
											string.format("From (%s) %s", script.Parent.Name, sendChat),
											script.Settings.ChatColor.Value,
											(script.Effects.Bold.Value > 0)
										)
									else
										require(msgPlayer.Client).Game:PushGlobalChat(
											string.format("From (%s) %s", script.Parent.Name, sendChat),
											script.Settings.ChatColor.Value,
											(script.Effects.Bold.Value > 0)
										)
									end
									if script.Table.Value then
										self:PushChat(
											string.format("To (%s) %s", msgPlayer.Name, sendChat),
											msgPlayer.Client.Settings.ChatColor.Value,
											(msgPlayer.Client.Effects.Bold.Value > 0)
										)
									else
										self:PushGlobalChat(
											string.format("To (%s) %s", msgPlayer.Name, sendChat),
											msgPlayer.Client.Settings.ChatColor.Value,
											(msgPlayer.Client.Effects.Bold.Value > 0)
										)
									end
									chatReturn = ""
								else
									chatReturn, returnColor = "Nothing to say?", Color3.new(1, 0, 0)
								end
							else
								chatReturn, returnColor = "Can't cant message youself!", Color3.new(1, 0, 0)
							end
						else
							chatReturn, returnColor = "Couldn't figure out who to Message!", Color3.new(1, 0, 0)
						end
					else
						chatReturn, returnColor = "Couldn't figure out who to Message!", Color3.new(1, 0, 0)
					end
				elseif args[1] and args[1] == "clear" then
					if script.Table.Value then
						for x = 1, 9 do
							self:PushChat("", Color3.new(0,0,0), false)
						end
					else
						for x = 1, 10 do
							self:PushGlobalChat("", Color3.new(0,0,0), false)
						end
					end
					chatReturn = ""
				end
			end
			return chatReturn, returnColor
		end,
		ShowStreak = function(self, streak, earnings)
			local streakMaster = coroutine.wrap(function()
				self.GUI.Streak.Display.Value.Text = streak
				self.GUI.Streak.Earnings.Value.Text = earnings
				self.GUI.Streak.Visible = true
				repeat wait(1) until not self.GUI:FindFirstChild("Intro")
				wait(2)
				self.GUI.Streak:TweenPosition(
					UDim2.new(0.5, -175, 1, 10),
					Enum.EasingDirection.In,
					Enum.EasingStyle.Back,
					2, false, function()
						self.GUI.Streak:Destroy()
					end
				)
			end)
			streakMaster()
		end,
		UpdateLeaderboard = function(self, leaderboard)
			wait()
			local leaderGui = self.GUI.Parent.Leaderboard.Stats
			do -- Clear All
				for _, item in pairs(leaderGui.Wins:GetChildren()) do
					if item.Name == "Name" then
						item:Destroy()
					end
				end
				for _, item in pairs(leaderGui.Ratio:GetChildren()) do
					if item.Name == "Name" then
						item:Destroy()
					end
				end
				for _, item in pairs(leaderGui.Level:GetChildren()) do
					if item.Name == "Name" then
						item:Destroy()
					end
				end
			end
			do -- Wins
				local posIterator = 0
				local numIterator = 1
				for _, leaderStat in pairs(leaderboard.wins) do
					local name = leaderGui.Wins.NameTemplate:Clone()
					name.Name = "Name"
					name.Parent = leaderGui.Wins
					name.Text = leaderStat[1]
					name.Number.Text = numIterator
					name.Stat.Text = leaderStat[2]
					name.Position = UDim2.new(0, name.Position.X.Offset, 0, posIterator)
					leaderGui.Wins.CanvasSize = UDim2.new(0, 0, 0, posIterator)
					name.Visible = true
					numIterator = numIterator + 1
					posIterator = posIterator + 40
				end
			end
			do -- Ratio
				local posIterator = 0
				local numIterator = 1
				for _, leaderStat in pairs(leaderboard.ratio) do
					local name = leaderGui.Ratio.NameTemplate:Clone()
					name.Name = "Name"
					name.Parent = leaderGui.Ratio
					name.Text = leaderStat[1]
					name.Number.Text = numIterator
					do
						local ratio = leaderStat[2]
						if tonumber(ratio) then
							name.Stat.Text = tonumber(ratio)/100
						else
							name.Stat.Text = 0
						end
					end
					name.Position = UDim2.new(0, name.Position.X.Offset, 0, posIterator)
					leaderGui.Ratio.CanvasSize = UDim2.new(0, 0, 0, posIterator)
					name.Visible = true
					numIterator = numIterator + 1
					posIterator = posIterator + 40
				end
			end
			do -- Level
				local posIterator = 0
				local numIterator = 1
				for _, leaderStat in pairs(leaderboard.level) do
					local name = leaderGui.Level.NameTemplate:Clone()
					name.Name = "Name"
					name.Parent = leaderGui.Level
					name.Text = leaderStat[1]
					name.Number.Text = numIterator
					name.Stat.Text = leaderStat[2]
					name.Position = UDim2.new(0, name.Position.X.Offset, 0, posIterator)
					leaderGui.Level.CanvasSize = UDim2.new(0, 0, 0, posIterator)
					name.Visible = true
					numIterator = numIterator + 1
					posIterator = posIterator + 40
				end
			end
		end,
		UpdatePlayers = function(self)
			local playerList = self.GUI.Players
			for _, listedPlayer in pairs(playerList.List:GetChildren()) do
				if listedPlayer.Name == "Player" then
					listedPlayer:Destroy()
				end
			end
			for id, player in pairs(game.Players:GetChildren()) do
				local listing = playerList.List.NameTemplate:Clone()
				listing.Name = "Player"
				listing.Text = player.Name
				listing.Position = UDim2.new(0, 0, 0, (id-1)*listing.Size.Y.Offset)
				listing.Visible = true
				listing.Parent = playerList.List
				playerList.List.CanvasSize = UDim2.new(0, 0, 0, (id-1)*listing.Size.Y.Offset)
				listing.MouseButton1Down:connect(function()
					local details = playerList.Details
					
					details.PlayerName.Text = player.Name
					details.PlayerName.Shadow.Text = player.Name
					
					details.PlayerLevel.Text = "Level "..player.Client.Stats.Level.Value
					details.PlayerLevel.Shadow.Text = "Level "..player.Client.Stats.Level.Value
					
					details.PlayerDisplay.Text = player.Client.Display.Value:upper()
					details.PlayerDisplay.Shadow.Text = player.Client.Display.Value:upper()
					
					details.PlayerRender.Image = self.PlayerPath..player.Name
					
					local bc = "NBC"
					local color = Color3.new(1, 1, 1)
					if player.MembershipType == Enum.MembershipType.BuildersClub then
						bc = "BC"
						color = Color3.new(0, 163/255, 217/255)
					elseif player.MembershipType == Enum.MembershipType.TurboBuildersClub then
						bc = "TBC"
						color = Color3.new(229/255, 133/255, 18/255)
					elseif player.MembershipType == Enum.MembershipType.OutrageousBuildersClub then
						bc = "OBC"
						color = Color3.new(217/255, 0, 0)
					end
					details.BuildersClub.Text = bc
					details.BuildersClub.Shadow.Text = bc
					details.BuildersClub.TextColor3 = color
					
					details.Visible = true
				end)
			end
		end
	}
}

return Client
