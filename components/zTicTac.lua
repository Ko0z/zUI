-- I wanted it to be possible for a player to go around and send TicTacToe invites without disturbing players that dont have the addon. 
-- Only other players that have zTicTacToe would ever know they have been invited to a game.

zUI:RegisterComponent("zTicTac", function ()
	--[[
	--Game messages
	1: TopLeft 
	2: TopCenter
	3: TopRight
	4: MiddleLeft
	5: MiddleCenter
	6: MiddleRight
	7: BottomLeft
	8: BottomCenter
	9: BottomRight

	c: ChallengeRequest -- Not implemeted
	a: Challenge Accepted
	d: Challenge Declined
	x: Forfeit/Closed window
	b: Busy in game already.

	<: ping -- Not implemeted
	>: pong -- Not implemeted

	z: Message Recieved
	--]]
	local SimpleComm_oldChatFrame_OnEvent = nil;
	local zOpponentName = "_";
	local gameMaster = nil;
	local gameStarted = false;
	local myTurn = false;
	local pendingRequest = false;
	local lastMessage = "";
	local zTicTac = "";
	local myName = UnitName("player")

	local firstLaunch = true;
	local _, class = UnitClass'player'
	
	zChannelInit = CreateFrame("Frame")
	zChannelInit:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE") -- Seems to put Custom Game Chat at first available spot. DOESNT take general /1 or trade /2.
	-- See ( Note1 ): events tested that dont do the job as we want it.
	-- Couldn't find a better way of joining this game channel..
	-- I absolutely didn't want this addon to snatch the place of General chat /1, or trade /2.
	-- I also wanted the player to automatically leave the channel when logging out, and JoinTemporaryChannel was not implemented until 2.3.0 so...
	-- Also becuase of if a player used this addon, then logged out and disabled it then logged back in without it, they would still join this channel.
	-- If someone for some reason reads this and know a better way, please feel free to contact me. [github.com/Ko0z or gitlab.com/Ko0zi]
	zChannelInit:SetScript( "OnEvent", function() 
		-- If already in 10 channels, print NO FREE SLOT FOR CHANNEL.
		--[[ TODO:
		if ( GetNumDisplayChannels() > 0 ) then
		function AceComm:CHAT_MSG_SYSTEM(text)
			if text ~= _G.ERR_TOO_MANY_CHAT_CHANNELS then 
				DO SOMETHING
			end
		end
		_G.StaticPopupDialogs["ACECOMM_TOO_MANY_CHANNELS"] = {
			text = text,
			button1 = _G.CLOSE,
			timeout = 0,
			whileDead = 1,
			hideOnEscape = 1,
		}
		_G.StaticPopup_Show("ACECOMM_TOO_MANY_CHANNELS")
		]]
		-- If name of channel is taken and password protected (god forbid), begin loop until find one free. a nasty person couldnt occupy infinite number of possible channel names lol ;)
		if ( event == "CHAT_MSG_CHANNEL_NOTICE" ) then
			--JoinTemporaryChannel("zTicTac"); -- Better option. If someone uses this addon and then disables it (duuh) they dont automatically join it again. seems to have been Introduced in Patch 2.3.0.. :(
			local id = GetChannelName("zTicTac") 
			if (id == 0) then -- if not in channel try to join.
				JoinChannelByName("zTicTac");
				ChatFrame_RemoveChannel(ChatFrame1, "zTicTac"); -- Just hides messages in ChatFrame1
				zPrint("Runs Join!"); --debug msg
			else
				zPrint("Already Joined zTicTac."); --debug msg
			end
			zChannelInit:UnregisterEvent("CHAT_MSG_CHANNEL_NOTICE"); --only run once
		end
	end)

	hooksecurefunc("ChatFrame_OnEvent", function() -- Worried for nasty taint problems but seems fine..
	--NOTES: event=CHAT_MSG_CHANNEL; arg1=chat message; arg2=author; arg3=language; arg4=channel name with number; arg8=channel number; arg9=channel name without number
	--TODO: check if on zTicTac ignore list
		if (arg9 == "zTicTac") then --To prevent same messages getting recieved multiple times we only listen on ChatFrame1 and discard all other.
			if (this:GetName() == "ChatFrame1") then
				if (arg2 == zOpponentName) then
					zUI.zGameHandler(event)
					return
				elseif (arg1 == myName) then -- Incoming challenge request.
					local cName = arg2; -- Challenger name.
					zUI.zGameChallengeRequest(cName); -- If not already in game, show popup game challenge request
					return
				else zPrint("No Match: " .. arg1); return end
			else return end
		end
	end)
	-- Currently if you are in combat and try to log out, you leave channel but dont rejoin.. maybe look for err_msg and rejoin based on that.
	hooksecurefunc("Logout", function() -- 1: I really want the player to leave the channel upon logout or exit.
		LeaveChannelByName("zTicTac");
	end)

	hooksecurefunc("Quit", function() -- 2: If the player gets DC they will still try to connect to the channel with or without this addon activated next login...
		LeaveChannelByName("zTicTac");
	end)

	hooksecurefunc("CancelLogout", function() -- 3: I dont know how to solve that, guess it's not end off the world but still..
		JoinChannelByName("zTicTac");
	end)
	
	-- add dropdown menu button to invite players to Tic-Tac-Toe games
	UnitPopupButtons["TTT_INV"] = { text = "Game Invite", dist = 0 }
	for index,value in ipairs(UnitPopupMenus["PLAYER"]) do
		if value == "RAID_TARGET_ICON" then
			table.insert(UnitPopupMenus["PLAYER"], index+1, "TTT_INV")
		end
	end
	
	hooksecurefunc("UnitPopup_OnClick", function(self) -- Send game invite
		if this.value == "TTT_INV" then
			local dropdownFrame = getglobal(UIDROPDOWNMENU_INIT_MENU);
			local name = dropdownFrame.name; -- get name of player.
			local id = GetChannelName("zTicTac") 
			if (id ~= 0) then -- if not in channel try to join.
				SendChatMessage(name, "CHANNEL", nil, id);
				zOpponentName = name;
				pendingRequest = true;
				--gameMaster = true;
				zPrint("Invited " .. name .. " to a game of Tic-Tac-Toe.");
			end -- add else join the channel and send invite...
		end
	end)
	-- add dropdown menu button to invite players to Tic-Tac-Toe games
	UnitPopupButtons["TTT_GINV"] = { text = "Game Invite", dist = 0 }
	for index,value in ipairs(UnitPopupMenus["FRIEND"]) do
		if value == "GUILD_LEAVE" then
			table.insert(UnitPopupMenus["FRIEND"], index+1, "TTT_GINV")
		end
	end

	hooksecurefunc("UnitPopup_OnClick", function(self)	-- Send game invite
		if this.value == "TTT_GINV" then
			local dropdownFrame = getglobal(UIDROPDOWNMENU_INIT_MENU);
			local name = dropdownFrame.name; -- get name of player.
			local id = GetChannelName("zTicTac") 
			if (id ~= 0) then -- if not in channel try to join.
				SendChatMessage(name, "CHANNEL", nil, id);
				zOpponentName = name;
				pendingRequest = true;
				--gameMaster = true;
				zPrint("Invited " .. name .. " to a game of Tic-Tac-Toe.");
			end -- add else join the channel and send invite...
		end
	end)
	
	zUI.zTicTac = CreateFrame("Frame", nil, UIParent);
    zUI.zTicTac:SetWidth(140) 
	zUI.zTicTac:SetHeight(140)
    zUI.zTicTac:SetPoint('CENTER', UIParent)
    zUI.zTicTac:SetBackdrop({bgFile   = [[Interface\Tooltips\UI-Tooltip-Background]],
							edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
							tile = true, tileSize = 16, edgeSize = 24,
							insets   = {left = 4, right = 4, top = 4, bottom = 4}});
    zUI.zTicTac:SetBackdropColor(0, 0, 0, 0);
    zUI.zTicTac:SetBackdropBorderColor(.2, .2, .2, 1);
	-- Send message on close window press so that opponent dont wait in vain.
	zUI.zTicTac:SetScript('OnHide', function() 
		if (firstLaunch == true) then 
			firstLaunch = false; 
			return 
		end;
		if ( zOpponentName == "_" ) then -- do nothing
		else
			local index = GetChannelName("zTicTac") 
			if (index~=0) then 
				SendChatMessage("x", "CHANNEL", nil, index); 
			end 
		end
		gameStarted = false;
		gameMaster = false;
		zOpponentName = "_";
		--pendingRequest = false;
		zUI.zRestoreGame();
	end)

	zUI.zTicTac.bgTex = zUI.zTicTac:CreateTexture(nil,"BACKGROUND");
	zUI.zTicTac.bgTex:SetTexture("Interface\\Addons\\zUI\\img\\zTicTacBG");
	zUI.zTicTac.bgTex:SetPoint("CENTER", zUI.zTicTac, "CENTER", 0, 0);
	zUI.zTicTac.bgTex:SetWidth(128);
	zUI.zTicTac.bgTex:SetHeight(128);

    zUI.zTicTac:SetMovable(true); zUI.zTicTac:SetUserPlaced(true);
    zUI.zTicTac:RegisterForDrag'LeftButton' zUI.zTicTac:EnableMouse(true);
    zUI.zTicTac:SetScript('OnDragStart', function() zUI.zTicTac:StartMoving() end);
    zUI.zTicTac:SetScript('OnDragStop', function() zUI.zTicTac:StopMovingOrSizing() end);
    zUI.zTicTac:Hide();

	------------==( Game Button Setup )==---------------------------
	-- 'b'          [element]       the button.
	-- 'pointX'     [int]			x position we want.
	-- 'pointY'     [int]			y position we want.
	-- 'msgToSend'  [string]        game message we want to send on button press.
	-- 'reference'	[string]		optional arg, name of parent we want as reference when positioning.

	function zUI.SetupGameButton(b, pointX, pointY, msgToSend, reference)
		if reference then b:SetPoint('CENTER',reference,'CENTER', pointX, pointY); else b:SetPoint('CENTER', pointX, pointY) end
		b:SetWidth(32); b:SetHeight(32); b:SetAlpha(0.4); b.state = "";
		b:SetNormalTexture("");
		b:SetHighlightTexture("Interface\\Addons\\zUI\\img\\zTicTacHL");
		b:SetScript('OnClick', function() 
		if (myTurn == false) then zPrint("Not your turn!") return end
		if (gameMaster == true) then 
			b:SetDisabledTexture("Interface\\Addons\\zUI\\img\\zTicTacX");
			b.state = "x"
		else
			b:SetDisabledTexture("Interface\\Addons\\zUI\\img\\zTicTacO");
			b.state = "o"
		end
		b:SetAlpha(1); b:Disable();
		local index = GetChannelName("zTicTac") -- It finds zTicTac channel index.
		if (index ~= 0) then 
			SendChatMessage(msgToSend, "CHANNEL", nil, index); 
			zUI.zCheckWinCondition();
			myTurn = false;
		end
	end)
	end

	zUI.zTicTac.one = CreateFrame("Button", "zTicTacButton1", zUI.zTicTac); --Upper Left Button 1
	zUI.SetupGameButton(zUI.zTicTac.one,-36,33,"1");
	zUI.zTicTac.two = CreateFrame("Button", "zTicTacButton2", zUI.zTicTac); --Upper Center Button 2
	zUI.SetupGameButton(zUI.zTicTac.two,37,0,"2","zTicTacButton1");
	zUI.zTicTac.three = CreateFrame("Button", "zTicTacButton3", zUI.zTicTac); --Upper Right Button 3
	zUI.SetupGameButton(zUI.zTicTac.three,35,0,"3","zTicTacButton2");
	zUI.zTicTac.four = CreateFrame("Button", "zTicTacButton4", zUI.zTicTac); -- Middle Left Button 4
	zUI.SetupGameButton(zUI.zTicTac.four,-36,-2,"4");
	zUI.zTicTac.five = CreateFrame("Button", "zTicTacButton5", zUI.zTicTac); --Middle Center Button 5
	zUI.SetupGameButton(zUI.zTicTac.five,37,0,"5","zTicTacButton4");
	zUI.zTicTac.six = CreateFrame("Button", "zTicTacButton6", zUI.zTicTac); --Middle Right Button 6
	zUI.SetupGameButton(zUI.zTicTac.six,35,0,"6","zTicTacButton5");
	zUI.zTicTac.seven = CreateFrame("Button", "zTicTacButton7", zUI.zTicTac); --Bottom Left Button 7
	zUI.SetupGameButton(zUI.zTicTac.seven,-36,-37,"7");
	zUI.zTicTac.eight = CreateFrame("Button", "zTicTacButton8", zUI.zTicTac); --Bottom Center Button 8
	zUI.SetupGameButton(zUI.zTicTac.eight,37,0,"8","zTicTacButton7");
	zUI.zTicTac.nine = CreateFrame("Button", "zTicTacButton9", zUI.zTicTac); --Bottom Right Button 9
	zUI.SetupGameButton(zUI.zTicTac.nine,35,0,"9","zTicTacButton8");
	-----------------------------------------------------------------------------------------------
	zUI.zTicTac.x = CreateFrame('Button', 'zTicTacCloseButton', zUI.zTicTac, 'UIPanelCloseButton')
    zUI.zTicTac.x:SetPoint('TOPRIGHT', -3, 18)
    zUI.zTicTac.x:SetScript('OnClick', function() zUI.zTicTac:Hide() end)

	zUI.zTicTac.header = zUI.zTicTac:CreateTexture(nil, 'ARTWORK')
    zUI.zTicTac.header:SetWidth(256) zUI.zTicTac.header:SetHeight(64)
    zUI.zTicTac.header:SetPoint('TOP', zUI.zTicTac, 0, 22)
    zUI.zTicTac.header:SetTexture[[Interface\DialogFrame\UI-DialogBox-Header]]
    zUI.zTicTac.header:SetVertexColor(.3, .3, .3)

	zUI.zTicTac.header.t = zUI.zTicTac:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    zUI.zTicTac.header.t:SetPoint('TOP', zUI.zTicTac.header, 0, -14)
    zUI.zTicTac.header.t:SetText'Tic-Tac-Toe'

	local gameTable = {zUI.zTicTac.one, zUI.zTicTac.two, zUI.zTicTac.three, zUI.zTicTac.four, zUI.zTicTac.five, zUI.zTicTac.six, zUI.zTicTac.seven, zUI.zTicTac.eight, zUI.zTicTac.nine }
	----------------------------==[ TESTING]==-----------------------------------------------------
	
	-----------------------------------------------------------------------------------------------
	function zUI.zGameHandler(event)
		--TODO GAME LOGIC
		zPrint("Game Handler Called.");
		
		if arg1 == "a" then  --OPPONENT ACCEPTED MY CHALLENGE
			myTurn = true;
			gameMaster = true;
			gameStarted = true;
			pendingRequest = false;
			zUI.zTicTac:Show()
			return
		end

		if arg1 == "d" then  --OPPONENT DECLINED MY CHALLENGE
			zPrint("Opponent declined your game invite.")
			pendingRequest = false;
			zOpponentName = "_";
			return
		end

		if arg1 == "b" then
			zPrint("Opponent already in game.") -- OPPONENT IS BUSY
			pendingRequest = false;
			zOpponentName = "_";
			return 
		end

		if arg1 == "x" then	-- OPPONENT LEFT THE GAME
			zOpponentName = "_";
			--gameStarted = false;
			zPrint("Opponent left the game.")
			return 
		end

		if myTurn == true then zPrint("Possible Cheater") return end

		for index, v in ipairs(gameTable) do
			if (arg1 == tostring(index)) then 
				if (v:IsEnabled() == 0) then zPrint("Possible cheat attempt from opponent!"); return end --is DISABLED ALREADY possible cheat attempt.
				if (gameMaster == false) then 
					v:SetDisabledTexture("Interface\\Addons\\zUI\\img\\zTicTacX");
					v.state = "x"
					v:SetAlpha(1); 
					v:Disable(); 
					break
				else
					v:SetDisabledTexture("Interface\\Addons\\zUI\\img\\zTicTacO");
					v.state = "o"
					v:SetAlpha(1); 
					v:Disable();
					break
				end 
			end
		end
		
		zUI.zCheckWinCondition();
		--Is Game Finished?
		--Who Won??

		myTurn = true;
	end

	  --[[			EVERY WIN CONDITION: (Becuase why not :D)
    +-----------------+		+-----------------+		+-----------------+		+--|--------------+
  --|--X--|--X--|--X--|--	|  1  |  2  |  3  |		|  1  |  2  |  3  |		|  X  |  2  |  3  |
    |-----+-----+-----|		|-----+-----+-----|		|-----+-----+-----|		|--|--+-----+-----|
    |  4  |  5  |  6  |	  --|--X--|--X--|--X--|--	|  4  |  5  |  6  |		|  X  |  5  |  6  |
    |-----+-----+-----|		|-----+-----+-----|		|-----+-----+-----|		|--|--+-----+-----|
    |  7  |  8  |  9  |		|  7  |  8  |  9  |	  --|--X--|--X--|--X--|--	|  X  |  8  |  9  |
    +-----------------+		+-----------------+		+-----------------+		+--|--------------+

	+--------|--------+		+--------------|--+		\-----------------+		+-----------------/
    |  1  |  X  |  3  |		|  1  |  2  |  X  |		|  X  |  2  |  3  |		|  1  |  2  |  X  |
    |-----+--|--+-----|		|-----+-----+--|--|		|-----\-----+-----|		|-----+-----/-----|
    |  4  |  X  |  6  |		|  4  |  5  |  X  |		|  4  |  X  |  6  |		|  4  |  X  |  6  |
    |-----+--|--+-----|		|-----+-----+--|--|		|-----+-----\-----|		|-----/-----+-----|
    |  7  |  X  |  9  |		|  7  |  8  |  X  |		|  7  |  8  |  X  |		|  X  |  8  |  9  |
    +--------|--------+		+--------------|--+		+-----------------\		/-----------------+
  ]]
	function zUI.zCheckWinCondition()
		--for i = 0,8,1 do
		--end
		-- theres prolly a better way of doing this..
		if ( zTicTacButton1.state == 'o' and zTicTacButton2.state == 'o' and zTicTacButton3.state == 'o' ) then
			zPrint("O Wins!");
		elseif ( zTicTacButton1.state == 'x' and zTicTacButton2.state == 'x' and zTicTacButton3.state == 'x' ) then
			zPrint("X Wins!");
		elseif ( zTicTacButton4.state == 'o' and zTicTacButton5.state == 'o' and zTicTacButton6.state == 'o' ) then
			zPrint("Game Ended!");
		elseif ( zTicTacButton4.state == 'x' and zTicTacButton5.state == 'x' and zTicTacButton6.state == 'x' ) then
			zPrint("X Wins!");
		elseif ( zTicTacButton7.state == 'o' and zTicTacButton8.state == 'o' and zTicTacButton9.state == 'o' ) then
			zPrint("Game Ended!");
		elseif ( zTicTacButton7.state == 'x' and zTicTacButton8.state == 'x' and zTicTacButton9.state == 'x' ) then
			zPrint("X Wins!");

		elseif ( zTicTacButton1.state == 'o' and zTicTacButton4.state == 'o' and zTicTacButton7.state == 'o' ) then
			zPrint("Game Ended!");
		elseif ( zTicTacButton1.state == 'x' and zTicTacButton4.state == 'x' and zTicTacButton7.state == 'x' ) then
			zPrint("X Wins!");
		elseif ( zTicTacButton2.state == 'o' and zTicTacButton5.state == 'o' and zTicTacButton8.state == 'o' ) then
			zPrint("Game Ended!");
		elseif ( zTicTacButton2.state == 'x' and zTicTacButton5.state == 'x' and zTicTacButton8.state == 'x' ) then
			zPrint("X Wins!");
		elseif ( zTicTacButton3.state == 'o' and zTicTacButton6.state == 'o' and zTicTacButton9.state == 'o' ) then
			zPrint("Game Ended!");
		elseif ( zTicTacButton3.state == 'x' and zTicTacButton6.state == 'x' and zTicTacButton9.state == 'x' ) then
			zPrint("X Wins!");

		elseif ( zTicTacButton1.state == 'o' and zTicTacButton5.state == 'o' and zTicTacButton9.state == 'o' ) then
			zPrint("Game Ended!");
		elseif ( zTicTacButton1.state == 'x' and zTicTacButton5.state == 'x' and zTicTacButton9.state == 'x' ) then
			zPrint("X Wins!");
		else 
			for index, v in ipairs(gameTable) do
				if ( v:IsEnabled() ) then -- also set button:state to neutral
					zPrint("Game is still in progress!");
					return
				end
				zPrint("DRAW!");
				-- TODO: Nice WIN, DRAW or looser image
				-- Game Finished? 
			end
		end

	end

	function zUI.zRestoreGame()
		for index, v in ipairs(gameTable) do
			v:SetAlpha(0.4); v:Enable(); v.state = "" -- also set button:state to neutral
		end
		-- Send restored game message if rematch?.
		zPrint("Restore Game Called.");
	end

	function zUI.zSendRestoredGameMsg()
		local index = GetChannelName("zTicTac") -- It finds zTicTac channel index.
		if (index~=0) then 
			SendChatMessage("r", "CHANNEL", nil, index); 
		end
	end

	function zUI.zSendChallengeRequest()
		local index = GetChannelName("zTicTac") -- It finds zTicTac channel index.
		if (index~=0) then 
			SendChatMessage("c", "CHANNEL", nil, index); 
		end
	end
	-- Incoming Game Challenge Request
	function zUI.zGameChallengeRequest(opponent)
		
		--zOpponentName = arg2;
		-- TODO CHECK IF ON BANLIST!!

		--PENDING GAME REQUEST or GAME ALREADY STARTED?
		if (gameStarted == true) or (pendingRequest == true) then
			local index = GetChannelName("zTicTac") -- It finds zTicTac channel index.
			if (index~=0) then 
				SendChatMessage("b", "CHANNEL", nil, index); 
				zPrint("Incoming TicTacToe Request by: " .. opponent .. " was DENIED");
			end
			return
		end

		pendingRequest = true;
		zUI.ChallengeRequestFrame(opponent, 15);
	end
	
	-- [ Game Challenge Request Frame ]
-- Creates a challenge request popup window:
-- 'name'       [string]        name of the opponent will be displayed.
-- 'time'       [number]        time in seconds till the popup will be faded
	function zUI.ChallengeRequestFrame(name, time)
		if not name then return end
		if not time then time = 5 end

		local infobox = zChallengeBox
		if not infobox then
			infobox = CreateFrame("Button", "zChallengeBox", UIParent)
			infobox:Hide()

			infobox:SetScript("OnUpdate", function()
				local time = infobox.lastshow + infobox.duration - GetTime()
				--infobox.timeout:SetValue(time)
				if GetTime() > infobox.lastshow + infobox.duration then
				infobox:SetAlpha(infobox:GetAlpha()-0.05)

				if infobox:GetAlpha() <= 0.1 then
					-- IF ACCEPTED SHOULD NOT RUN THIS!
					if gameStarted == false then
						local index = GetChannelName("zTicTac") -- It finds zTicTac channel index.
						if (index~=0) then 
							SendChatMessage("d", "CHANNEL", nil, index); 
						end
					end
					pendingRequest = false;

					infobox:Hide()
					infobox:SetAlpha(1)
				end
				elseif MouseIsOver(this) then
				--this:SetAlpha(max(0.4, this:GetAlpha() - .1))
				else
				this:SetAlpha(min(1, this:GetAlpha() + .1))
				end
			end)
			
			--infobox:SetScript("OnClick", function()
			 -- this:Hide()
			--end)

			infobox.text = infobox:CreateFontString("Status", "HIGH", "GameFontNormal")
			infobox.text:ClearAllPoints()
			infobox.text:SetFontObject(GameFontWhite)

			infobox:ClearAllPoints()
			infobox.text:SetAllPoints(infobox)
			infobox.text:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")

			infobox:SetBackdrop({bgFile   = [[Interface\Tooltips\UI-Tooltip-Background]],
							edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
							tile = true, tileSize = 16, edgeSize = 24,
							insets   = {left = 4, right = 4, top = 4, bottom = 4}});
			infobox:SetBackdropColor(0, 0, 0, 1);
			infobox:SetBackdropBorderColor(.2, .2, .2, 1);
			-- HEADER
			infobox.header = infobox:CreateTexture(nil, 'ARTWORK')
			infobox.header:SetWidth(256) infobox.header:SetHeight(64)
			infobox.header:SetPoint('TOP', infobox, 0, 22)
			infobox.header:SetTexture[[Interface\DialogFrame\UI-DialogBox-Header]]
			infobox.header:SetVertexColor(.3, .3, .3)
			infobox.header.t = infobox:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
			infobox.header.t:SetPoint('TOP', infobox.header, 0, -14)
			infobox.header.t:SetText'Game Request'
			-- ACCEPT BUTTON
			infobox.accept = CreateFrame('Button', 'zAccept', infobox, 'UIPanelButtonTemplate')
			infobox.accept:SetWidth(60) 
			infobox.accept:SetHeight(20)
			infobox.accept:SetText('Accept');
			infobox.accept:SetFont(STANDARD_TEXT_FONT, 10)
			infobox.accept:SetPoint('BOTTOM', infobox, -50, 12)
			infobox.accept:SetScript('OnClick', function() 
				local index = GetChannelName("zTicTac") -- It finds zTicTac channel index.
					if (index~=0) then 
						SendChatMessage("a", "CHANNEL", nil, index); 
					end
				gameMaster = false;
				zOpponentName = name;
				infobox:Hide();
				gameStarted = true;
				pendingRequest = false;
				zUI.zTicTac:Show();
			end)
			-- ADD button: PUT ON BAN LIST.
			-- ADD display opponent name along with little image displaying status. 
			-- Green = Active, Yellow = No Response in x Seconds, Red = Opponent Left.

			-- DECLINE BUTTON
			infobox.decline = CreateFrame('Button', 'zDecline', infobox, 'UIPanelButtonTemplate')
			infobox.decline:SetWidth(60) 
			infobox.decline:SetHeight(20)
			infobox.decline:SetText('Decline');
			infobox.decline:SetFont(STANDARD_TEXT_FONT, 10)
			infobox.decline:SetPoint('BOTTOM', infobox, 50, 12)
			infobox.decline:SetScript('OnClick', function() 
				local index = GetChannelName("zTicTac") -- It finds zTicTac channel index.
				if (index~=0) then 
					SendChatMessage("d", "CHANNEL", nil, index); 
				end
				pendingRequest = false;
				infobox:Hide()
			end)

			infobox:SetHeight(100)
			infobox:SetPoint("TOP", 0, -25)
		end
		-- IF FRAME ALREADY EXIST
		infobox.text:SetText("Tic-Tac-Toe game request from: ".. name)
		infobox.duration = time
		infobox.lastshow = GetTime()
		infobox:SetWidth(infobox.text:GetStringWidth() + 50)
		infobox:SetFrameStrata("FULLSCREEN_DIALOG")
		infobox:Show()
	end
end)
