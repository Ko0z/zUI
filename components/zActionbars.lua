zUI:RegisterComponent("zActionbars", function () 
	
	UIPARENT_MANAGED_FRAME_POSITIONS["CastingBarFrame"] = {baseY = 70, bottomEither = 50, pet = 50, reputation = 19}; -- {baseY = 60, bottomEither = 40, pet = 40, reputation = 9};

	zUI.zBars = CreateFrame("Frame", nil, UIParent);
	-- BFA
	local function LoadActionBarBFA()
		----------------------==[ zUI.zBars.ActionBarArtSmall-Frame ]==----------------------------------------------->
		zUI.zBars.ActionBarArtSmall = CreateFrame("Frame","zActionBarArtSmall",MainMenuBar)
		zUI.zBars.ActionBarArtSmall:SetFrameStrata("MEDIUM")
		zUI.zBars.ActionBarArtSmall:SetWidth(1024)
		zUI.zBars.ActionBarArtSmall:SetHeight(128)
		zUI.zBars.ActionBarArtSmall:SetPoint("Bottom",-237,-11)
		-- Due to the texture being 1024x128 I had to split it in two too support Vanilla (max 512)
		-- Left split of the art.
		zUI.zBars.ActionBarArtSmall.left = zUI.zBars.ActionBarArtSmall:CreateTexture("zActionBarArtSmallLeft","BACKGROUND")
		zUI.zBars.ActionBarArtSmall.left:SetPoint("BOTTOMLEFT", zUI.zBars.ActionBarArtSmall, "BOTTOMLEFT", 0, 0);
		zUI.zBars.ActionBarArtSmall.left:SetWidth(512);
		zUI.zBars.ActionBarArtSmall.left:SetHeight(128);
		-- Right split of the art.
		zUI.zBars.ActionBarArtSmall.right = zUI.zBars.ActionBarArtSmall:CreateTexture("zActionBarArtSmallRight","BACKGROUND")
		zUI.zBars.ActionBarArtSmall.right:SetPoint("BOTTOMLEFT", zUI.zBars.ActionBarArtSmall, "BOTTOMLEFT", 512, 0);
		zUI.zBars.ActionBarArtSmall.right:SetWidth(512);
		zUI.zBars.ActionBarArtSmall.right:SetHeight(128);
		zUI.zBars.ActionBarArtSmall:Hide();
		----------------------==[ zUI.zBars.ActionBarArtLarge-Frame ]==---------------------------------------------->
		zUI.zBars.ActionBarArtLarge = CreateFrame("Frame","zActionBarArtLarge",MainMenuBar)
		zUI.zBars.ActionBarArtLarge:SetFrameStrata("MEDIUM")
		zUI.zBars.ActionBarArtLarge:SetWidth(1024)
		zUI.zBars.ActionBarArtLarge:SetHeight(128)
		zUI.zBars.ActionBarArtLarge:SetPoint("Bottom",-111,-11)
		-- Due to the texture being 1024x128 I had to split it in two too support Vanilla (max 512)
		-- Left split of the art.
		zUI.zBars.ActionBarArtLarge.left = zUI.zBars.ActionBarArtLarge:CreateTexture("zActionBarArtLargeLeft","BACKGROUND")
		zUI.zBars.ActionBarArtLarge.left:SetPoint("BOTTOMLEFT", zUI.zBars.ActionBarArtLarge, "BOTTOMLEFT", 0, 0);
		zUI.zBars.ActionBarArtLarge.left:SetWidth(512);
		zUI.zBars.ActionBarArtLarge.left:SetHeight(128);
		-- Right split of the art.
		zUI.zBars.ActionBarArtLarge.right = zUI.zBars.ActionBarArtLarge:CreateTexture("zActionBarArtLargeRight","BACKGROUND")
		zUI.zBars.ActionBarArtLarge.right:SetPoint("BOTTOMLEFT", zUI.zBars.ActionBarArtLarge, "BOTTOMLEFT", 512, 0);
		zUI.zBars.ActionBarArtLarge.right:SetWidth(512);
		zUI.zBars.ActionBarArtLarge.right:SetHeight(128);
		
		if (C.actionbars.endcap == "1") then
			zUI.zBars.ActionBarArtSmall.left:SetTexture("Interface\\Addons\\zUI\\img\\ActionBarArtSmallLeft")
			zUI.zBars.ActionBarArtSmall.right:SetTexture("Interface\\Addons\\zUI\\img\\ActionBarArtSmallRight")
			zUI.zBars.ActionBarArtLarge.left:SetTexture("Interface\\Addons\\zUI\\img\\ActionBarArtLargeLeft")
			zUI.zBars.ActionBarArtLarge.right:SetTexture("Interface\\Addons\\zUI\\img\\ActionBarArtLargeRight")
		else
			zUI.zBars.ActionBarArtSmall.left:SetTexture("Interface\\Addons\\zUI\\img\\ActionBarArtSmallLeftNoGryph")
			zUI.zBars.ActionBarArtSmall.right:SetTexture("Interface\\Addons\\zUI\\img\\ActionBarArtSmallRightNoGryph")
			zUI.zBars.ActionBarArtLarge.left:SetTexture("Interface\\Addons\\zUI\\img\\ActionBarArtLargeLeftNoGryph")
			zUI.zBars.ActionBarArtLarge.right:SetTexture("Interface\\Addons\\zUI\\img\\ActionBarArtLargeRightNoGryph")
		end

		zUI.zBars.ActionBarArtLarge:Hide();
		----------------------==[ XPBarBackground-Frame ]==------------------------------------------------->
		zUI.zBars.xpbg = CreateFrame("Frame", nil, MainMenuBar)
		zUI.zBars.xpbg:SetFrameStrata("BACKGROUND")
		zUI.zBars.xpbg:SetWidth(798)
		zUI.zBars.xpbg:SetHeight(10)
		zUI.zBars.xpbg:SetPoint("Bottom",-111,-11)
		-- xp backdrop 
		zUI.zBars.xpbg.t = zUI.zBars.xpbg:CreateTexture(nil,"BACKGROUND")
		--zUI.zBars.xpbg.t:SetTexture("Interface/ChatFrame/ChatFrameBackground")
		zUI.zBars.xpbg.t:SetAllPoints(zUI.zBars.xpbg)
		zUI.zBars.xpbg.t:SetTexture(0,0,0,0.75);
		--zUI.zBars.xpbg:Hide();

			-----------------------==[[ ExhaustionTick_Update ]]==---------------------------------------BFA------->
		function zExhaustionTick_Update()
			local playerCurrXP = UnitXP("player");
			local playerMaxXP = UnitXPMax("player");
			local exhaustionThreshold = GetXPExhaustion();
			local exhaustionStateID, exhaustionStateName, exhaustionStateMultiplier;
			exhaustionStateID, exhaustionStateName, exhaustionStateMultiplier = GetRestState();
			if (exhaustionStateID and exhaustionStateID >= 3) then
				ExhaustionTick:SetPoint("CENTER", "MainMenuExpBar", "RIGHT", 0, 0);
			end

			if (not exhaustionThreshold) then
				ExhaustionTick:Hide();
				ExhaustionLevelFillBar:Hide();
			else
				local exhaustionTickSet = max(((playerCurrXP + exhaustionThreshold) / playerMaxXP) * MainMenuExpBar:GetWidth(), 0);
					--local exhaustionTotalXP = playerCurrXP + (exhaustionMaxXP - exhaustionCurrXP);
					--local exhaustionTickSet = (exhaustionTotalXP / playerMaxXP) * MainMenuExpBar:GetWidth();
				ExhaustionTick:ClearAllPoints();
				if (exhaustionTickSet > MainMenuExpBar:GetWidth() or MainMenuBarMaxLevelBar:IsShown()) then
					ExhaustionTick:Hide();
					ExhaustionLevelFillBar:Hide();
					-- Saving this code in case we want to always leave the exhaustion tick onscreen
						--ExhaustionTick:SetPoint("CENTER", "MainMenuExpBar", "RIGHT", 0, 0);
						--ExhaustionLevelFillBar:SetPoint("TOPRIGHT", "MainMenuExpBar", "TOPRIGHT", 0, 0);
				else
					ExhaustionTick:Show();
					ExhaustionTick:SetPoint("CENTER", "MainMenuExpBar", "LEFT", exhaustionTickSet, 0);
					ExhaustionLevelFillBar:Show();
					ExhaustionLevelFillBar:SetPoint("TOPRIGHT", "MainMenuExpBar", "TOPLEFT", exhaustionTickSet, 0);
				end
			end
			-- Hide exhaustion tick if player is max level and the reputation watch bar is shown
			if ( UnitLevel("player") == MAX_PLAYER_LEVEL and ReputationWatchBar:IsShown() ) then
				ExhaustionTick:Hide();
			end
		
			local exhaustionStateID = GetRestState();
			if (exhaustionStateID == 1) then
				MainMenuExpBar:SetStatusBarColor(0.0, 0.39, 0.88, 1.0);
				ExhaustionLevelFillBar:SetVertexColor(0.0, 0.39, 0.88, 0.15);
				ExhaustionTickHighlight:SetVertexColor(0.0, 0.39, 0.88);
			elseif (exhaustionStateID == 2) then
				MainMenuExpBar:SetStatusBarColor(0.58, 0.0, 0.55, 1.0);
				ExhaustionLevelFillBar:SetVertexColor(0.58, 0.0, 0.55, 0.15);
				ExhaustionTickHighlight:SetVertexColor(0.58, 0.0, 0.55);
			end

			if ( ReputationWatchBar:IsShown() and not MainMenuExpBar:IsShown() ) then
				ExhaustionTick:Hide();
			end
		end

		--------------------==[ DELETE AND DISABLE FRAMES ]==-----------------------------------
		local function null()
			-- I do nothing (for a reason)
		end

		--efficiant way to remove frames (does not work on textures)
		local function Kill(frame)
			if type(frame) == 'table' and frame.SetScript then
				frame:UnregisterAllEvents()
				frame:SetScript('OnEvent',nil)
				frame:SetScript('OnUpdate',nil)
				frame:SetScript('OnHide',nil)
				frame:Hide()
				frame.SetScript = null
				frame.RegisterEvent = null
				frame.RegisterAllEvents = null
				frame.Show = null
			end
		end
		--Kill(ReputationWatchBar)
		--Kill(HonorWatchBar)
		Kill(MainMenuBarMaxLevelBar) --Fixed visual bug when unequipping artifact weapon at max level
		--disable "Show as Experience Bar" checkbox
		--ReputationDetailMainScreenCheckBox:Disable()
		--ReputationDetailMainScreenCheckBoxText:SetTextColor(.5,.5,.5)
		--------------------==[ XP BAR ]==------------------------------------------------------------------>

		for i = 0, 3 do --for loop, hides MainMenuXPBarDiv (0-3)
		   _G["MainMenuXPBarTexture" .. i]:Hide()
		end

		MainMenuExpBar:SetFrameStrata("LOW")
		ReputationWatchStatusBar:SetFrameStrata("LOW")
		ExhaustionTick:SetFrameStrata("HIGH")

		MainMenuBarExpText:ClearAllPoints()
		MainMenuBarExpText:SetPoint("CENTER",MainMenuExpBar,0,1)
		MainMenuBarOverlayFrame:SetFrameStrata("MEDIUM") --changes xp bar text strata

		--------------------==[ ACTIONBARS/BUTTONS POSITIONING AND SCALING ]==-----------------------------------
		--Only needs to be run once:
		local function Initial_ActionBarLayoutBFA()
			
			MainMenuBarLeftEndCap:Hide()
			MainMenuBarRightEndCap:Hide()
			
			--reposition bottom left actionbuttons
			MultiBarBottomLeftButton1:SetPoint("BOTTOMLEFT",MultiBarBottomLeft,0,-6)

			--reposition bottom right actionbar
			MultiBarBottomRight:SetPoint("LEFT",MultiBarBottomLeft,"RIGHT",43,-6)

			--reposition second half of top right bar, underneath
			MultiBarBottomRightButton7:SetPoint("LEFT",MultiBarBottomRight,0,-48)

			--reposition right bottom
			MultiBarLeftButton1:SetPoint("TOPRIGHT",MultiBarLeft,41,11)

			--reposition pet actionbuttons
			SlidingActionBarTexture0:SetPoint("TOPLEFT",PetActionBarFrame,1,-5) -- pet bar texture (displayed when bottom left bar is hidden)
			PetActionButton1:ClearAllPoints()
			PetActionButton1:SetPoint("TOP",PetActionBarFrame,"LEFT",51,4)

			-- Named ShapeshiftBarFrame in Vanilla!!
			ShapeshiftBarLeft:SetPoint("BOTTOMLEFT",ShapeshiftBarFrame,0,-5) --stance bar texture for when Bottom Left Bar is hidden
			ShapeshiftButton1:ClearAllPoints()
			--end
		end
		local f=CreateFrame("Frame")
		f:RegisterEvent("PLAYER_LOGIN")
		f:SetScript("OnEvent", Initial_ActionBarLayoutBFA)

		----------------==[ BFA Style ]==------------------------------------->
		local longBar = nil;
		local function ActivateLongBar()
			zUI.zBars.ActionBarArtLarge:Show()
			zUI.zBars.ActionBarArtSmall:Hide()
			longBar = true;
			--arrows and page number
			ActionBarUpButton:SetPoint("CENTER",MainMenuBarArtFrame,"TOPLEFT",521,-23)
			ActionBarDownButton:SetPoint("CENTER",MainMenuBarArtFrame,"TOPLEFT",521,-42)
			MainMenuBarPageNumber:SetPoint("CENTER",MainMenuBarArtFrame,28,-5)
			--exp bar sizing and positioning
			MainMenuExpBar_Update();
			MainMenuExpBar:ClearAllPoints()
			MainMenuExpBar:SetWidth(798); MainMenuExpBar:SetHeight(10); 
			MainMenuExpBar:SetPoint("BOTTOM",UIParent,0,0)
			ReputationWatchStatusBar:SetWidth(798); ReputationWatchStatusBar:SetHeight(10); 
			--reposition ALL actionbars (right bars not affected)
			MainMenuBar:SetPoint("BOTTOM",UIParent,110,11)
			--xp bar background (the one I made)
			zUI.zBars.xpbg:SetWidth(798); zUI.zBars.xpbg:SetHeight(10); 
			zUI.zBars.xpbg:SetPoint("BOTTOM",MainMenuBar,-111,-11)

			if ExhaustionTick:IsShown() then
				zExhaustionTick_Update();
			end
		end

		function ActivateShortBar()
			zUI.zBars.ActionBarArtLarge:Hide()
			zUI.zBars.ActionBarArtSmall:Show()
			longBar = false;
			--arrows and page number
			ActionBarUpButton:SetPoint("CENTER",MainMenuBarArtFrame,"TOPLEFT",521,-23)
			ActionBarDownButton:SetPoint("CENTER",MainMenuBarArtFrame,"TOPLEFT",521,-42)
			MainMenuBarPageNumber:SetPoint("CENTER",MainMenuBarArtFrame,27,-5)
			--exp bar sizing and positioning
			MainMenuExpBar_Update();
			MainMenuExpBar:ClearAllPoints()
			MainMenuExpBar:SetWidth(542); MainMenuExpBar:SetHeight(10); 
			MainMenuExpBar:SetPoint("BOTTOM",UIParent,0,0)
			ReputationWatchStatusBar:SetWidth(542); ReputationWatchStatusBar:SetHeight(10);
			--reposition ALL actionbars (right bars not affected)
			MainMenuBar:SetPoint("BOTTOM",UIParent,237,11)
			--xp bar background (the one I made)
			zUI.zBars.xpbg:SetWidth(542); zUI.zBars.xpbg:SetHeight(10); 
			zUI.zBars.xpbg:SetPoint("BOTTOM",MainMenuBar,-237,-11)

			if ExhaustionTick:IsShown() then
				zExhaustionTick_Update();
			end
		end

		local function Update_ActionBarsBFA()
			--Bottom Left Bar:
			if MultiBarBottomLeft:IsShown() then
				PetActionButton1:SetPoint("TOP",PetActionBarFrame,"LEFT",51,4)
				--StanceButton1:SetPoint("LEFT",StanceBarFrame,2,-4)
				ShapeshiftButton1:SetPoint("LEFT",ShapeshiftBarFrame,2,-4)
			else
				PetActionButton1:SetPoint("TOP",PetActionBarFrame,"LEFT",51,7)
				--StanceButton1:SetPoint("LEFT",StanceBarFrame,12,-2)
				ShapeshiftButton1:SetPoint("LEFT",ShapeshiftBarFrame,12,-2)
			end
			--Right Bar:
			if MultiBarRight:IsShown() then
				--do
			else
			end
			--Right Bar 2:
			if MultiBarLeft:IsShown() then
				--make MultiBarRight smaller (original size)
				MultiBarLeft:SetScale(.795)
				MultiBarRight:SetScale(.795)
				--MultiBarRightButton1:SetPoint("TOPRIGHT",MultiBarRight,-2,534)
				MultiBarRightButton1:SetPoint("TOPRIGHT",MultiBarRight,-44,11)
			else
				--make MultiBarRight bigger and vertically more centered, maybe also move objective frame
				MultiBarLeft:SetScale(1)
				MultiBarRight:SetScale(1)
				MultiBarRightButton1:SetPoint("TOPRIGHT",MultiBarRight,-2,64)
			end
			if MultiBarBottomRight:IsShown() then
				ActivateLongBar()
			else
				ActivateShortBar()
			end
		end

		--UIParent_ManageFramePositions(); -- better to hook??

		HookScript(MultiBarBottomLeft,'OnShow', Update_ActionBarsBFA)
		HookScript(MultiBarBottomLeft,'OnHide', Update_ActionBarsBFA)
		HookScript(MultiBarBottomRight,'OnShow', Update_ActionBarsBFA)
		HookScript(MultiBarBottomRight,'OnHide', Update_ActionBarsBFA)
		HookScript(MultiBarRight,'OnShow', Update_ActionBarsBFA)
		HookScript(MultiBarRight,'OnHide', Update_ActionBarsBFA)
		HookScript(MultiBarLeft,'OnShow', Update_ActionBarsBFA)
		HookScript(MultiBarLeft,'OnHide', Update_ActionBarsBFA)
	
		local f=CreateFrame("Frame")
		f:RegisterEvent("PLAYER_LOGIN") --Required to check bar visibility on load
		f:SetScript("OnEvent", function()
			Update_ActionBarsBFA();
			f:UnregisterEvent("PLAYER_LOGIN"); --only run once, well feels good man to be safe. MODIFIED
		end)

		hooksecurefunc("ReputationWatchBar_Update", function()
			if (MultiBarBottomRight:IsShown()) then
				-- if XP bar is shown split them up evenly or hide or whateva. TODO
				ReputationWatchBar:ClearAllPoints()
				ReputationWatchStatusBar:SetWidth(798); ReputationWatchStatusBar:SetHeight(10);
				ReputationWatchStatusBar:SetFrameStrata("LOW")
				ReputationWatchBar:SetPoint("BOTTOM",UIParent,0,0)
				ReputationWatchStatusBarText:SetFont(STANDARD_TEXT_FONT, 10,"OUTLINE")
				ReputationXPBarTexture0:Hide();
				ReputationXPBarTexture1:Hide();
				ReputationXPBarTexture2:Hide();
				ReputationXPBarTexture3:Hide();
			else
				ReputationWatchBar:ClearAllPoints()
				ReputationWatchStatusBar:SetWidth(542); ReputationWatchStatusBar:SetHeight(10); 
				ReputationWatchStatusBar:SetFrameStrata("LOW")
				ReputationWatchBar:SetPoint("BOTTOM",UIParent,0,0)
				ReputationWatchStatusBarText:SetFont(STANDARD_TEXT_FONT, 10,"OUTLINE")
				ReputationXPBarTexture0:Hide();
				ReputationXPBarTexture1:Hide();
				ReputationXPBarTexture2:Hide();
				ReputationXPBarTexture3:Hide();
			end
		end, true)
	end
	
	-- Elite
	local function Initial_ActionLayout()
		ReputationWatchStatusBar:SetFrameStrata("LOW")
		MainMenuExpBar:SetFrameStrata("LOW")
		--MainMenuBarExpText:SetFrameLevel(4);
		MainMenuBarOverlayFrame:SetFrameStrata("MEDIUM")
		PetActionBarFrame:SetFrameLevel(MultiBarRight:GetFrameLevel() - 1)

		MainMenuBarLeftEndCap:Hide()
		MainMenuBarRightEndCap:Hide()

		MultiBarLeft:ClearAllPoints();
		MultiBarLeft:SetPoint("BOTTOMRIGHT", -7, 98);
		-- since the MultiBarRight always gonna be horisontal in this layout, we can form it initially.
		for i = 1, 12 do
			local bu = _G['MultiBarRightButton'..i]
			bu:ClearAllPoints()
			if i == 1 then
				--if (MultiBarBottomLeft:IsShown()) then
					bu:SetFrameStrata'LOW'
					--bu:SetPoint('LEFT', MultiBarRightButton12, 'RIGHT', 12, 0)
					bu:SetPoint('LEFT', MultiBarBottomLeftButton12, 'RIGHT', 6, 0)
				--else
					--bu:SetPoint('LEFT', MultiBarBottomLeftButton12, 'RIGHT', 6, 0)
				--end
			else
				local previous = _G['MultiBarRightButton'..i - 1]
				bu:SetPoint('LEFT', previous, 'RIGHT', 6, 0)
			end
		end
		--Debug positions
		--local point, relativeTo, relativePoint, xOfs, yOfs = ShapeshiftButton1:GetPoint()
		--DEFAULT_CHAT_FRAME:AddMessage(point)
		--DEFAULT_CHAT_FRAME:AddMessage(relativeTo:GetName())
		--DEFAULT_CHAT_FRAME:AddMessage(relativePoint)
		--DEFAULT_CHAT_FRAME:AddMessage(xOfs)
		--DEFAULT_CHAT_FRAME:AddMessage(yOfs)
	end
	--function zUI:zExperiment_OnLoad()
	local function LoadActionBarElite()
		--DEFAULT_CHAT_FRAME:AddMessage("<zExperiment> Loaded!")

		for i = 0, 3 do --for loop, hides MainMenuBarTexture (0-3)
		   _G["MainMenuBarTexture" .. i]:Hide()
		end
		
		local faction = "HUMAN";
		local capFaction = "DWARF";
		 
		zUI.zBars.zActionBarArt = CreateFrame("Frame","zActionBarArt",MainMenuBar)
		zUI.zBars.zActionBarArt:SetAllPoints(MainMenuBar);

		zUI.zBars.zActionBarArt.one = zUI.zBars.zActionBarArt:CreateTexture("zActionBarTexture1","ARTWORK") -- offset 4 ->
		zActionBarTexture1:SetTexture("Interface/MainMenuBar/UI-MainMenuBar-".. faction);
		zActionBarTexture1:SetPoint("BOTTOM", -380, 0);
		zActionBarTexture1:SetWidth(256);
		zActionBarTexture1:SetHeight(43);
		zActionBarTexture1:SetTexCoord(0,1.0,0.83203125,1.0);
		
		zUI.zBars.zActionBarArt.two = zUI.zBars.zActionBarArt:CreateTexture("zActionBarTexture2","ARTWORK")
		zActionBarTexture2:SetTexture("Interface/MainMenuBar/UI-MainMenuBar-".. faction);
		zActionBarTexture2:SetPoint("RIGHT",zActionBarTexture1,"RIGHT",256,0)
		zActionBarTexture2:SetWidth(256);
		zActionBarTexture2:SetHeight(43);
		zActionBarTexture2:SetTexCoord(0,1.0,0.58203125,0.75);
		
		zUI.zBars.zActionBarArt.three = zUI.zBars.zActionBarArt:CreateTexture("zActionBarTexture3","ARTWORK")
		zActionBarTexture3:SetTexture("Interface/MainMenuBar/UI-MainMenuBar-".. faction);
		zActionBarTexture3:SetPoint("RIGHT",zActionBarTexture2,"RIGHT",248,0)
		zActionBarTexture3:SetWidth(256);
		zActionBarTexture3:SetHeight(43);
		zActionBarTexture3:SetTexCoord(1.0,0,0.58203125,0.75);

		zUI.zBars.zActionBarArt.four = zUI.zBars.zActionBarArt:CreateTexture("zActionBarTexture4","ARTWORK")	-- offset 4 <-
		zActionBarTexture4:SetTexture("Interface/MainMenuBar/UI-MainMenuBar-".. faction);
		zActionBarTexture4:SetPoint("RIGHT",zActionBarTexture3,"RIGHT",256,0)
		zActionBarTexture4:SetWidth(256);
		zActionBarTexture4:SetHeight(43);
		zActionBarTexture4:SetTexCoord(1.0,0,0.83203125,1.0);

		-----------------------==[ Gryph or Lion ]==-----------------------------------------------
		zUI.zBars.zActionBarArt.left = zUI.zBars.zActionBarArt:CreateTexture("zActionBarEndCapLeft","OVERLAY")
		zActionBarEndCapLeft:SetTexture("Interface/MainMenuBar/UI-MainMenuBar-EndCap-" .. capFaction);
		zActionBarEndCapLeft:SetPoint("BOTTOM", -540, 0);
		zActionBarEndCapLeft:SetWidth(128);
		zActionBarEndCapLeft:SetHeight(128);
		zUI.zBars.zActionBarArt.right = zUI.zBars.zActionBarArt:CreateTexture("zActionBarEndCapRight","OVERLAY")
		zActionBarEndCapRight:SetTexture("Interface/MainMenuBar/UI-MainMenuBar-EndCap-" .. capFaction);
		zActionBarEndCapRight:SetPoint("BOTTOM", 540, 0);
		zActionBarEndCapRight:SetWidth(128);
		zActionBarEndCapRight:SetHeight(128);
		zActionBarEndCapRight:SetTexCoord(1.0,0,0,1.0);
		
		if(C.actionbars.endcap == "0") then
			zActionBarEndCapLeft:Hide()
			zActionBarEndCapRight:Hide()
		end
		-----------------------==[ ActionBarUpButton and Down ]==-----------------------------------------------
		ActionBarUpButton:ClearAllPoints();
		ActionBarUpButton:SetPoint("BOTTOMLEFT",zActionBarEndCapRight,"BOTTOMLEFT",24,13)
		ActionBarDownButton:ClearAllPoints();
		ActionBarDownButton:SetPoint("BOTTOMLEFT",zActionBarEndCapRight,"BOTTOMLEFT",24,-5)
		MainMenuBarPageNumber:ClearAllPoints();
		MainMenuBarPageNumber:SetPoint("BOTTOMLEFT",zActionBarEndCapRight,"BOTTOMLEFT",50,16)
		---------------------------------------------------------------------------------------------------------
		MainMenuBarLeftEndCap:Hide();
		MainMenuBarRightEndCap:Hide();

		Initial_ActionLayout();

		local function Update_ActionLayout()
			--------------------==[ LARGE-MODE ]==--------------------------
			if (MultiBarBottomRight:IsShown()) then 
				zActionBarTexture3:Show();
				zActionBarTexture4:Show();
				MultiBarBottomRightButton1:ClearAllPoints();
				MultiBarBottomRightButton1:SetPoint("BOTTOMRIGHT",ActionButton12,"BOTTOMRIGHT",42,0)
				MultiBarRightButton1:SetPoint('LEFT', MultiBarBottomLeftButton12, 'RIGHT', 6, 0) --reset original pos
				ActionButton1:SetPoint("BOTTOMLEFT",12,4)
				BonusActionButton1:SetPoint("BOTTOMLEFT",7,4) --here
				BonusActionBarTexture0:SetPoint("TOPLEFT",2,0);
				zActionBarTexture1:SetPoint("BOTTOM", -380, 0);
				zActionBarEndCapLeft:SetPoint("BOTTOM", -540, 0);
				zActionBarEndCapRight:SetPoint("BOTTOM", 540, 0);
				--PETACTIONBAR_XPOS = 36; --292
				
				ShapeshiftButton1:SetPoint("BOTTOMLEFT",ShapeshiftBarFrame,"BOTTOMLEFT",11,3)
				ShapeshiftBarLeft:SetPoint("BOTTOMLEFT",ShapeshiftBarFrame,"BOTTOMLEFT",0,0) --orig

				if (PetActionBarFrame:IsShown()) then 
					SlidingActionBarTexture0:Show();
					SlidingActionBarTexture1:Show();
				end
				---------------------==[ LEFT & RIGHT ]==--------------------------
				if (SHOW_MULTI_ACTIONBAR_1) and (SHOW_MULTI_ACTIONBAR_3) then
					MultiBarBottomLeftButton1:SetPoint('BOTTOMLEFT', MultiBarBottomLeft, 'BOTTOMLEFT', 0, 0); --reset original pos
					PetActionButton1:SetPoint("BOTTOMLEFT",PetActionBarFrame,"BOTTOMLEFT",36,2) --reset original pos
					SlidingActionBarTexture0:SetPoint("TOPLEFT",PetActionBarFrame,"TOPLEFT",0,0) --reset original pos
					SlidingActionBarTexture0:Hide();
					SlidingActionBarTexture1:Hide();
				---------------------==[ LEFT ONLY ]==--------------------------
				elseif (SHOW_MULTI_ACTIONBAR_1) then
					if (PetActionBarFrame:IsShown()) then
						MultiBarBottomLeftButton1:SetPoint('BOTTOMLEFT', MultiBarBottomLeft, 'BOTTOMLEFT', 504, 0); --modified pos
						PetActionButton1:SetPoint("BOTTOMLEFT",PetActionBarFrame,"BOTTOMLEFT",36,-41) --modified pos
						SlidingActionBarTexture0:SetPoint("TOPLEFT",PetActionBarFrame,"TOPLEFT",0,-43) --modified pos
					else
						MultiBarBottomLeftButton1:SetPoint('BOTTOMLEFT', MultiBarBottomLeft, 'BOTTOMLEFT', 0, 0); --reset original pos
					end
				---------------------==[ RIGHT ONLY OR NONE ]==--------------------------
				else
					MultiBarBottomLeftButton1:SetPoint('BOTTOMLEFT', MultiBarBottomLeft, 'BOTTOMLEFT', 0, 0); --reset original pos
					PetActionButton1:SetPoint("BOTTOMLEFT",PetActionBarFrame,"BOTTOMLEFT",36,2) --reset original pos
					SlidingActionBarTexture0:SetPoint("TOPLEFT",PetActionBarFrame,"TOPLEFT",0,0) --reset original pos
				end

			else	-----------------==[ SMALL-MODE ]==--------------------------
				zActionBarTexture3:Hide();
				zActionBarTexture4:Hide();
				zActionBarTexture1:SetPoint("BOTTOM", -128, 0);
				zActionBarEndCapLeft:SetPoint("BOTTOM", -288, 0);
				zActionBarEndCapRight:SetPoint("BOTTOM", 288, 0);
				ActionButton1:SetPoint("BOTTOMLEFT",264,4);
				BonusActionButton1:SetPoint("BOTTOMLEFT",259,4);--here
				BonusActionBarTexture0:SetPoint("TOPLEFT",254,0);
				MultiBarBottomLeftButton1:SetPoint('BOTTOMLEFT', MultiBarBottomLeft, 'BOTTOMLEFT', 0, 0); --reset original pos
				-- pet
				--PETACTIONBAR_XPOS = 292; --36
				
				if (SHOW_MULTI_ACTIONBAR_1) and (SHOW_MULTI_ACTIONBAR_3) then
					MultiBarRightButton1:SetPoint('LEFT', MultiBarBottomLeftButton1, 'LEFT', 0, 42)
					PetActionButton1:SetPoint("BOTTOMLEFT",PetActionBarFrame,"BOTTOMLEFT",292,43) --modified pos
					--SlidingActionBarTexture0:SetPoint("TOPLEFT",PetActionBarFrame,"TOPLEFT",0,41) --modified pos
					ShapeshiftButton1:SetPoint("BOTTOMLEFT",ShapeshiftBarFrame,"BOTTOMLEFT",266,42) --orig small
					--ShapeshiftBarLeft:SetPoint("BOTTOMLEFT",ShapeshiftBarFrame,"BOTTOMLEFT",255,39) --orig small
					SlidingActionBarTexture0:Hide();
					SlidingActionBarTexture1:Hide();
				elseif (SHOW_MULTI_ACTIONBAR_3) then
					MultiBarRightButton1:SetPoint('LEFT', MultiBarBottomLeftButton1, 'LEFT', 0, 0)
					PetActionButton1:SetPoint("BOTTOMLEFT",PetActionBarFrame,"BOTTOMLEFT",292,44) --modified pos
					--SlidingActionBarTexture0:SetPoint("TOPLEFT",PetActionBarFrame,"TOPLEFT",0,41) --modified pos
					ShapeshiftButton1:SetPoint("BOTTOMLEFT",ShapeshiftBarFrame,"BOTTOMLEFT",266,45) --orig small
					ShapeshiftBarLeft:SetPoint("BOTTOMLEFT",ShapeshiftBarFrame,"BOTTOMLEFT",255,42) --orig small
					SlidingActionBarTexture0:Hide();
					SlidingActionBarTexture1:Hide();
				elseif(SHOW_MULTI_ACTIONBAR_1) then
					PetActionButton1:SetPoint("BOTTOMLEFT",PetActionBarFrame,"BOTTOMLEFT",292,2) --reset original pos
					--SlidingActionBarTexture0:SetPoint("TOPLEFT",PetActionBarFrame,"TOPLEFT",0,0) --reset original pos
					ShapeshiftButton1:SetPoint("BOTTOMLEFT",ShapeshiftBarFrame,"BOTTOMLEFT",266,0) --orig small
					--ShapeshiftBarLeft:SetPoint("BOTTOMLEFT",ShapeshiftBarFrame,"BOTTOMLEFT",255,0) --orig small
					SlidingActionBarTexture0:Hide();
					SlidingActionBarTexture1:Hide();
				else
					PetActionButton1:SetPoint("BOTTOMLEFT",PetActionBarFrame,"BOTTOMLEFT",292,2) --reset original pos
					SlidingActionBarTexture0:SetPoint("TOPLEFT",PetActionBarFrame,"TOPLEFT",256,-1) --reset original pos
					SlidingActionBarTexture0:Show();
					SlidingActionBarTexture1:Show();
					ShapeshiftButton1:SetPoint("BOTTOMLEFT",ShapeshiftBarFrame,"BOTTOMLEFT",266,3) --orig small
					ShapeshiftBarLeft:SetPoint("BOTTOMLEFT",ShapeshiftBarFrame,"BOTTOMLEFT",255,0) --orig small
				end
			end
		end

		hooksecurefunc("UIParent_ManageFramePositions",Update_ActionLayout,true);

		hooksecurefunc("ReputationWatchBar_Update", function()
			if (MultiBarBottomRight:IsShown()) then
				ReputationWatchStatusBar:SetWidth(1024);
				MainMenuMaxLevelBar0:Show();
				MainMenuMaxLevelBar3:Show();
			else
				ReputationWatchStatusBar:SetWidth(512); --ReputationWatchStatusBar:SetHeight(10); --needs further hand holding..
				if(MainMenuExpBar:IsShown()) then
					ReputationWatchBarTexture2:Hide()
					ReputationWatchBarTexture3:Hide()
				else
					ReputationXPBarTexture2:Hide();
					ReputationXPBarTexture3:Hide();
				end
				MainMenuMaxLevelBar0:Hide();
				MainMenuMaxLevelBar3:Hide();
			end
		end, true)

		hooksecurefunc("MainMenuExpBar_Update", function()
			if (MultiBarBottomRight:IsShown()) then
				MainMenuExpBar:SetWidth(1024);
				MainMenuXPBarTexture0:Show()
				MainMenuXPBarTexture3:Show()
			else
				MainMenuExpBar:SetWidth(512); --ReputationWatchStatusBar:SetHeight(10); --needs further hand holding..
				MainMenuXPBarTexture0:Hide();
				MainMenuXPBarTexture3:Hide();
			end
		end, true)

	end

	----------------------==[ MicroMenuArt-Frame ]==---------------------------------------------------->

	zUI.zBars.mma = CreateFrame("Frame", nil, UIParent)
	zUI.zBars.mma:SetFrameStrata("MEDIUM")
	zUI.zBars.mma:SetWidth(512)
	zUI.zBars.mma:SetHeight(128)
	zUI.zBars.mma:SetPoint("BOTTOMRIGHT",0,0)
	zUI.zBars.mma.t = zUI.zBars.mma:CreateTexture(nil,"BACKGROUND")
	zUI.zBars.mma.t:SetTexture("Interface\\Addons\\zUI\\img\\MicroMenuArt8Slot")
	zUI.zBars.mma.t:SetAllPoints(zUI.zBars.mma)
	if (C.global.darkmode == "1") then zUI.zBars.mma.t:SetVertexColor(0.2, 0.2, 0.2) end

	if (C.global.microbuttons_auto_hide == "1") then
		zUI.zBars.Enter = CreateFrame("Frame", "MicroEnter", UIParent);
		MicroEnter:SetFrameStrata("MEDIUM")
		MicroEnter:SetPoint("BOTTOMRIGHT", UIParent, 0, 0);
		MicroEnter:SetWidth(200);
		MicroEnter:SetHeight(70);
		--MicroEnter.tex = MicroEnter:CreateTexture(nil,"ARTWORK");
		--MicroEnter.tex:SetAllPoints(MicroEnter);
		--MicroEnter.tex:SetTexture(0,1,0,0.6);
		MicroEnter:EnableMouse(true);
		MicroEnter:SetScript("OnEnter", function() 
			--zPrint("Enter");
			zUI.zBars.mma:SetPoint("BOTTOMRIGHT",0,0)
			MicroLeave:Show();
		end)

		zUI.zBars.Leave = CreateFrame("Frame", "MicroLeave", UIParent);
		MicroLeave:SetFrameStrata("BACKGROUND");
		MicroLeave:SetAllPoints(UIParent);
		--MicroLeave.tex = MicroLeave:CreateTexture(nil,"ARTWORK");
		--MicroLeave.tex:SetAllPoints(MicroLeave);
		--MicroLeave.tex:SetTexture(1,0,0,0.6);
		MicroLeave:EnableMouse(true);
		MicroLeave:SetScript("OnEnter", function() 
			--zPrint("Leave");
			zUI.zBars.mma:SetPoint("BOTTOMRIGHT",196,0)
			this:Hide();
		end)
		MicroLeave:Hide();
		zUI.zBars.mma:SetPoint("BOTTOMRIGHT",196,0);
	end

	--------------------==[ MICRO MENU MOVEMENT, POSITIONING AND SIZING ]==----------------------------------

	function MoveMicroButtonsToBottomRight()
		CharacterMicroButton:SetScale(0.9);
		SpellbookMicroButton:SetScale(0.9);
		TalentMicroButton:SetScale(0.9);
		QuestLogMicroButton:SetScale(0.9);
		SocialsMicroButton:SetScale(0.9);
		WorldMapMicroButton:SetScale(0.9);
		MainMenuMicroButton:SetScale(0.9);
		HelpMicroButton:SetScale(0.9);
		CharacterMicroButton:ClearAllPoints();
		CharacterMicroButton:SetPoint("BOTTOMRIGHT",zUI.zBars.mma,-192,1)
		MainMenuBarBackpackButton:SetPoint("BOTTOMRIGHT",zUI.zBars.mma,-7,52)
		MainMenuBarBackpackButton:SetScale(.76)
		CharacterBag0Slot:SetScale(.76);
		CharacterBag1Slot:SetScale(.76);
		CharacterBag2Slot:SetScale(.76);
		CharacterBag3Slot:SetScale(.76);
		MainMenuBarPerformanceBarFrame:ClearAllPoints();
		MainMenuBarPerformanceBarFrame:SetWidth(12);
		MainMenuBarPerformanceBarFrame:SetHeight(44);
		MainMenuBarPerformanceBarFrame:SetPoint("TOPLEFT",HelpMicroButton,"TOPLEFT",22,-13)
		MainMenuBarPerformanceBarFrame:SetFrameStrata"HIGH"

		for _, v in pairs({MainMenuBarPerformanceBarFrame:GetRegions()}) do
			v:ClearAllPoints();
			v:SetWidth(12);
			v:SetHeight(44);
			v:SetPoint("TOPLEFT",HelpMicroButton,"TOPLEFT",22,-13)
		end

		MainMenuBarPerformanceBarFrameButton:ClearAllPoints();
		MainMenuBarPerformanceBarFrameButton:SetWidth(14);
		MainMenuBarPerformanceBarFrameButton:SetHeight(44);
		MainMenuBarPerformanceBarFrameButton:SetPoint("TOPLEFT",HelpMicroButton,"TOPLEFT",20,-13)
		KeyRingButton:SetScale(0.9);
	end

	local f=CreateFrame("Frame")
	f:RegisterEvent("PLAYER_ENTERING_WORLD")
	f:SetScript("OnEvent", function()
		MoveMicroButtonsToBottomRight();
		f:UnregisterEvent("PLAYER_ENTERING_WORLD"); 
	end)

	-- Only for testing purpose what happens when player gets to lvl 10 and the microbutton talent icon appears.
	--function zUpdateTalentButton()
	--	if ( UnitLevel("player") < 10 ) then
	--		TalentMicroButton:Hide();
	--		QuestLogMicroButton:SetPoint("BOTTOMLEFT", "TalentMicroButton", "BOTTOMLEFT", 0, 0);
	--	else	
	--		TalentMicroButton:Show();
	--		QuestLogMicroButton:SetPoint("BOTTOMLEFT", "TalentMicroButton", "BOTTOMRIGHT", -2, 0);
	--	end
	--end
	
	--------------------==[ BLIZZARD TEXTURES ]==-----------------------------------
	--hide Blizzard art textures
	for i = 0, 3 do --for loop, hides MainMenuBarTexture (0-3)
	   _G["MainMenuBarTexture" .. i]:Hide()
	end

	if (C.actionbars.bfa_style == "1") then
		LoadActionBarBFA();
	else
		LoadActionBarElite();
	end

end)