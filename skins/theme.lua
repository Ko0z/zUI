-- Credist to Modernist, modUI
zUI:RegisterSkin("Theme", function () --modui inspired
	
	local faction = UnitFactionGroup("player");

	ZUI_COLOURELEMENTS_FOR_UI = {}
	ZUI_COLOURELEMENTS_BORDER_FOR_UI = {}

	if (C.global.darkmode == "1") then
		local zTOOLTIP_DEFAULT_COLOR = { r = 0, g = 0, b = 0 };
		local zTOOLTIP_DEFAULT_BACKGROUND_COLOR = { r = 0.0, g = 0.0, b = 0.0 };
	
		ItemRefTooltip:SetBackdropColor(zTOOLTIP_DEFAULT_BACKGROUND_COLOR.r, zTOOLTIP_DEFAULT_BACKGROUND_COLOR.g, zTOOLTIP_DEFAULT_BACKGROUND_COLOR.b);
		
		hooksecurefunc("GameTooltip_OnLoad", function()
			this:SetBackdropColor(zTOOLTIP_DEFAULT_BACKGROUND_COLOR.r, zTOOLTIP_DEFAULT_BACKGROUND_COLOR.g, zTOOLTIP_DEFAULT_BACKGROUND_COLOR.b,1);
		end,true)
		
		hooksecurefunc("GameTooltip_OnShow", function()
			this:SetBackdropColor(zTOOLTIP_DEFAULT_BACKGROUND_COLOR.r, zTOOLTIP_DEFAULT_BACKGROUND_COLOR.g, zTOOLTIP_DEFAULT_BACKGROUND_COLOR.b,1);
		end,true)

		hooksecurefunc("GameTooltip_OnHide", function()
			this:SetBackdropColor(zTOOLTIP_DEFAULT_BACKGROUND_COLOR.r, zTOOLTIP_DEFAULT_BACKGROUND_COLOR.g, zTOOLTIP_DEFAULT_BACKGROUND_COLOR.b,1);
		end,true)
	end

	UIOptionsFrame:SetScript("OnShow", function() -- Move to style?
		-- default events
		UIOptionsFrame_Load();
		MultiActionBar_Update();
		MultiActionBar_ShowAllGrids();
		Disable_BagButtons();
		UpdateMicroButtons();
		
		-- customize
		UIOptionsBlackground:Hide() -- removes black sideos for UIOptions (Interface)
		--BlackoutWorld:Hide(); -- removes black sideos for map

		UIOptionsFrame:SetMovable(true)
		UIOptionsFrame:EnableMouse(true)
		UIOptionsFrame:SetScale(.8)
		UIOptionsFrame:SetScript("OnMouseDown",function()
			UIOptionsFrame:StartMoving()
		end)

		UIOptionsFrame:SetScript("OnMouseUp",function()
			UIOptionsFrame:StopMovingOrSizing()
		end)
	end)

	for _, v in pairs({
            -- MINIMAP CLUSTER
		--MinimapBorder,

		MiniMapMailBorder,
		MiniMapTrackingBorder,
		MiniMapMeetingStoneBorder,
		MiniMapMailBorder,
		MiniMapBattlefieldBorder,
		
			-- UNIT & CASTBAR
		--PlayerFrameTexture,
		--TargetFrameTexture,
		PetFrameTexture,
		PartyMemberFrame1Texture,
		PartyMemberFrame2Texture,
		PartyMemberFrame3Texture,
		PartyMemberFrame4Texture,
		PartyMemberFrame1PetFrameTexture,
		PartyMemberFrame2PetFrameTexture,
		PartyMemberFrame3PetFrameTexture,
		PartyMemberFrame4PetFrameTexture,
		TargetofTargetTexture,
		CastingBarBorder,
			-- MAIN MENU BAR
		MainMenuBarTexture0,
		MainMenuBarTexture1,
		MainMenuBarTexture2,
		MainMenuBarTexture3,
		MainMenuMaxLevelBar0,
		MainMenuMaxLevelBar1,
		MainMenuMaxLevelBar2,
		MainMenuMaxLevelBar3,
		MainMenuXPBarTextureLeftCap,
		MainMenuXPBarTextureRightCap,
		MainMenuXPBarTextureMid,
		BonusActionBarTexture0,
		BonusActionBarTexture1,
		ReputationWatchBarTexture0,
		ReputationWatchBarTexture1,
		ReputationWatchBarTexture2,
		ReputationWatchBarTexture3,
		ReputationXPBarTexture0,
		ReputationXPBarTexture1,
		ReputationXPBarTexture2,
		ReputationXPBarTexture3,
		ShapeshiftBarLeft,
		ShapeshiftBarMiddle,
		ShapeshiftBarRight,
		SlidingActionBarTexture0,
		SlidingActionBarTexture1,
		MainMenuBarLeftEndCap,
		MainMenuBarRightEndCap,
		ExhaustionTick:GetNormalTexture(),
	}) do table.insert(ZUI_COLOURELEMENTS_FOR_UI, v) end


	if (C.actionbars.endcap == "0") then
		MainMenuBarLeftEndCap:Hide();
		MainMenuBarRightEndCap:Hide();
	end

	if (zActionBarArtSmallLeft ~= nil) then
		for _, v in pairs({
			zActionBarArtSmallLeft,
			zActionBarArtSmallRight,
			zActionBarArtLargeLeft,
			zActionBarArtLargeRight,
		}) do table.insert(ZUI_COLOURELEMENTS_FOR_UI, v) end
	end
	
	if (zActionBarTexture1) then
		for _, v in pairs({
			zActionBarTexture1,
			zActionBarTexture2,
			zActionBarTexture3,
			zActionBarTexture4,
			zActionBarEndCapLeft,
			zActionBarEndCapRight,
		}) do table.insert(ZUI_COLOURELEMENTS_FOR_UI, v) end
	end

	-- BAGS
    for i = 1, 12 do
        local bagName = 'ContainerFrame'..i
        local _, a, b, _, c, _, d = _G[bagName]:GetRegions()
        for _, v in pairs({a, b, c, d}) do table.insert(ZUI_COLOURELEMENTS_FOR_UI, v) end
    end

	-- BANK
    local _, a = BankFrame:GetRegions()
    for _, v in pairs({a}) do table.insert(ZUI_COLOURELEMENTS_FOR_UI, v) end

	-- LETTER
    local _, a, b, c, d = ItemTextFrame:GetRegions()
    for _, v in pairs({a, b, c, d, e}) do
        table.insert(ZUI_COLOURELEMENTS_FOR_UI, v)
    end
	hooksecurefunc("ItemTextFrame_OnEvent", function()
		ItemTextPageText:SetTextColor(0.04, 0.04, 0.04, 1);
	end, true)
	
	-- HELP
    local a, b, c, d, e, f, g = HelpFrame:GetRegions()
    for _, v in pairs({a, b, c, d, e, f, g}) do
        table.insert(ZUI_COLOURELEMENTS_FOR_UI, v)
    end

	--------------------------------------------------------------------------->
	-- PAPERDOLL
    local a, b, c, d, _, e = PaperDollFrame:GetRegions()
    for _, v in pairs({a, b, c, d, e}) do
        table.insert(ZUI_COLOURELEMENTS_FOR_UI, v)
    end

	-- REPUTATION
    table.insert(ZUI_COLOURELEMENTS_BORDER_FOR_UI, ReputationDetailFrame)
    local a, b, c, d = ReputationFrame:GetRegions()
    for _, v in pairs({a, b, c, d}) do
        table.insert(ZUI_COLOURELEMENTS_FOR_UI, v)
    end
    for i = 1, 15 do
        local a, b = _G['ReputationBar'..i]:GetRegions()
        for _, v in pairs({a, b}) do
            table.insert(ZUI_COLOURELEMENTS_FOR_UI, v)
        end
    end

	-- SKILL
    local a, b, c, d = SkillFrame:GetRegions()
    for _, v in pairs({a, b, c ,d}) do
        table.insert(ZUI_COLOURELEMENTS_FOR_UI, v)
    end
    for _, v in pairs({ReputationDetailCorner, ReputationDetailDivider}) do
        table.insert(ZUI_COLOURELEMENTS_FOR_UI, v)
    end

	-- HONOR
    local a, b, c, d = HonorFrame:GetRegions()
    for _, v in pairs({a, b, c, d}) do
        table.insert(ZUI_COLOURELEMENTS_FOR_UI, v)
    end
	--------------------------------------------------------------------------->

	-- MERCHANT
    local _, a, b, c, d, _, _, _, e, f, g, h, j, k = MerchantFrame:GetRegions()
    for _, v in pairs({a, b, c ,d, e, f, g, h, j, k}) do
        table.insert(ZUI_COLOURELEMENTS_FOR_UI, v)
    end
	table.insert(ZUI_COLOURELEMENTS_FOR_UI, MerchantBuyBackItemNameFrame)

	-- MAIL
    local _, a, b, c, d = OpenMailFrame:GetRegions()
    for _, v in pairs({a, b, c, d}) do
        table.insert(ZUI_COLOURELEMENTS_FOR_UI, v)
    end
	local _, a, b, c, d = MailFrame:GetRegions()
    for _, v in pairs({a, b, c, d}) do
        table.insert(ZUI_COLOURELEMENTS_FOR_UI, v)
    end

	MailFrame.Material = MailFrame:CreateTexture(nil, 'OVERLAY', nil, 7)
	if(faction) then
		MailFrame.Material:SetTexture("Interface\\AddOns\\zUI\\img\\QuestBG_" .. faction)
	else
		MailFrame.Material:SetTexture("Interface\\AddOns\\zUI\\img\\QuestBG_Horde")
	end
	MailFrame.Material:SetWidth(551) MailFrame.Material:SetHeight(450)
	MailFrame.Material:SetPoint('TOPLEFT', MailFrame, 23, -74)
	MailFrame.Material:SetVertexColor(.9, .9, .9)

	SendMailPackageButton:SetScript('OnShow', function()
		if MailFrame.Material:IsShown() then MailFrame.Material:Hide() end
	end)
	SendMailPackageButton:SetScript('OnHide', function()
		if MailFrame:IsShown() then MailFrame.Material:Show() end
	end)

	-- BREATH TIMER, EXHAUSTION etc... (MirrorTimer)
    for i = 1, MIRRORTIMER_NUMTIMERS do
        local m = _G['MirrorTimer'..i]
        local _, _, a = m:GetRegions()
        table.insert(ZUI_COLOURELEMENTS_FOR_UI, a)
    end

	-- POPUP
    for i = 1, 4 do
        local f = _G['StaticPopup'..i]
        table.insert(ZUI_COLOURELEMENTS_BORDER_FOR_UI, f)
    end

	-- QUEST
    for _, v in pairs({
        QuestFrameGreetingPanel,
        QuestFrameDetailPanel,
        QuestFrameProgressPanel,
        QuestFrameRewardPanel,
        GossipFrameGreetingPanel}) do
        local a, b, c, d = v:GetRegions()
        for _, j in pairs({a, b, c, d}) do table.insert(ZUI_COLOURELEMENTS_FOR_UI, j) end
	
        v.Material = v:CreateTexture(nil, 'OVERLAY', nil, 7)
		if(faction) then
			v.Material:SetTexture("Interface\\AddOns\\zUI\\img\\QuestBG_" .. faction)
		else
			v.Material:SetTexture("Interface\\AddOns\\zUI\\img\\QuestBG_Horde")
		end
        v.Material:SetWidth(511)
        v.Material:SetHeight(418)
        v.Material:SetPoint('TOPLEFT', v, 24, -82)
        v.Material:SetVertexColor(.9, .9, .9)
	
        if v == GossipFrameGreetingPanel or v == QuestFrameGreetingPanel then
            v.Corner = v:CreateTexture(nil, 'OVERLAY', nil, 7)
            v.Corner:SetTexture[[Interface\QuestFrame\UI-Quest-BotLeftPatch]]
            v.Corner:SetWidth(132)
            v.Corner:SetHeight(64)
            v.Corner:SetPoint('BOTTOMLEFT', v, 21, 68)
            table.insert(ZUI_COLOURELEMENTS_FOR_UI, v.Corner)
        end
    end

	-- QUEST LOG
    local _, _, a, b, c, d = QuestLogFrame:GetRegions()
    for _, v in pairs({a, b, c, d}) do
        table.insert(ZUI_COLOURELEMENTS_FOR_UI, v)
    end

    local qlMaterial = QuestLogDetailScrollFrame.Material or QuestLogDetailScrollFrame:CreateTexture(nil, "BACKGROUND")
    local qlTexture = "Interface\\AddOns\\zUI\\img\\QuestBG_"

    -- zUI QuestLog texture transparency size: x-211, y-103
    -- See SetPoint() below. Shorten height by 2px
    local qlFrameX = QuestLogDetailScrollChildFrame:GetWidth() + 211
    local qlFrameY = QuestLogDetailScrollChildFrame:GetHeight() + 101

    qlMaterial:SetTexture(qlTexture .. (faction or "Horde"))
    qlMaterial:SetWidth(qlFrameX)
    qlMaterial:SetHeight(qlFrameY)
    qlMaterial:SetPoint("TOPLEFT", 0, 2) -- offset 2px for better alignment
    qlMaterial:SetVertexColor(.9, .9, .9)

        -- QUEST TIMER
    table.insert(ZUI_COLOURELEMENTS_BORDER_FOR_UI, QuestTimerFrame)
    table.insert(ZUI_COLOURELEMENTS_FOR_UI, QuestTimerHeader)

	-- RAIDINFO
    local _, _, a = RaidInfoFrame:GetRegions()
    for _, v in pairs({a}) do
        table.insert(ZUI_COLOURELEMENTS_FOR_UI, v)
    end

	    -- SOCIAL
    local _, a, b, c, d = FriendsFrame:GetRegions()
    for _, v in pairs({a, b, c, d}) do
        table.insert(ZUI_COLOURELEMENTS_FOR_UI, v)
    end

    local a = ({GuildMemberDetailFrame:GetRegions()})
    table.insert(ZUI_COLOURELEMENTS_FOR_UI, a[20])
    table.insert(ZUI_COLOURELEMENTS_BORDER_FOR_UI, GuildMemberDetailFrame)
    table.insert(ZUI_COLOURELEMENTS_FOR_UI, GuildMemberDetailCorner)

	    -- SPELLBOOK
    local _, a, b, c, d = SpellBookFrame:GetRegions()
    for _, v in pairs({a, b, c, d}) do
        table.insert(ZUI_COLOURELEMENTS_FOR_UI, v)
    end

	-- TODO once again find that texture... Found an old blizzard test image lol, 
	SpellBookFrame.Material = SpellBookFrame:CreateTexture(nil, 'OVERLAY', nil, 7)
	if(faction) then
		SpellBookFrame.Material:SetTexture("Interface\\AddOns\\zUI\\img\\QuestBG_" .. faction)
	else
		SpellBookFrame.Material:SetTexture("Interface\\AddOns\\zUI\\img\\QuestBG_Horde")
	end
    SpellBookFrame.Material:SetWidth(544) -- 300
    SpellBookFrame.Material:SetHeight(445) -- 336
    SpellBookFrame.Material:SetPoint('TOPLEFT', SpellBookFrame, 22, -74)
    SpellBookFrame.Material:SetVertexColor(.9, .9, .9)

	-- TABARD
    local _, a, b, c, d = TabardFrame:GetRegions()
    for _, v in pairs({a, b, c, d, e}) do
        table.insert(ZUI_COLOURELEMENTS_FOR_UI, v)
    end

	-- TAXI
    local _, a, b, c, d = TaxiFrame:GetRegions()
    for _, v in pairs({a, b, c, d}) do
        table.insert(ZUI_COLOURELEMENTS_FOR_UI, v)
    end

	-- TRADE
    local _, _, a, b, c, d = TradeFrame:GetRegions()
    for _, v in pairs({a, b, c, d, e}) do
        table.insert(ZUI_COLOURELEMENTS_FOR_UI, v)
    end

	-- WARDROBE
    local _, a, b, c, d = DressUpFrame:GetRegions()
    for _, v in pairs({a, b, c, d, e}) do
        table.insert(ZUI_COLOURELEMENTS_FOR_UI, v)
    end

	-- WORLDMAP
    local _, a, b, c, d, e, _, _, f, g, h, j, k = WorldMapFrame:GetRegions()
    for _, v in pairs({a, b, c, d, e, f, g, h, j, k}) do
        table.insert(ZUI_COLOURELEMENTS_FOR_UI, v)
    end

	    -- COLOUR PICKER
    table.insert(ZUI_COLOURELEMENTS_BORDER_FOR_UI, ColorPickerFrame)
    table.insert(ZUI_COLOURELEMENTS_FOR_UI, ColorPickerFrameHeader)


        -- MENU
    table.insert(ZUI_COLOURELEMENTS_BORDER_FOR_UI, GameMenuFrame)
    table.insert(ZUI_COLOURELEMENTS_FOR_UI, GameMenuFrameHeader)


        -- GRAPHICS MENU
    table.insert(ZUI_COLOURELEMENTS_BORDER_FOR_UI, OptionsFrame)
    table.insert(ZUI_COLOURELEMENTS_FOR_UI, OptionsFrameHeader)


        -- SOUND MENU
    table.insert(ZUI_COLOURELEMENTS_BORDER_FOR_UI, SoundOptionsFrame)
    table.insert(ZUI_COLOURELEMENTS_FOR_UI, SoundOptionsFrameHeader)


	     -- ADDONS
    local f = CreateFrame'Frame'
    f:RegisterEvent'ADDON_LOADED'
    f:SetScript('OnEvent', function()
      
        if arg1 == 'Blizzard_AuctionUI' then            -- AUCTION
            local _, a, b, c, d, e, f = AuctionFrame:GetRegions()
            for _, v in pairs({a, b, c, d, e, f}) do
                table.insert(ZUI_COLOURELEMENTS_FOR_UI, v)
				v:SetVertexColor(0.4, 0.4, 0.4);
            end
            local a, b = AuctionDressUpFrame:GetRegions()
            local _, _, _, c = AuctionDressUpFrameCloseButton:GetRegions()
            for _, v in pairs({a, b, c}) do table.insert(ZUI_COLOURELEMENTS_FOR_UI, v) v:SetVertexColor(0.4, 0.4, 0.4); end
            for i = 1, 15 do
                local a = _G['AuctionFilterButton'..i]:GetNormalTexture()
                table.insert(ZUI_COLOURELEMENTS_FOR_UI, a)
				a:SetVertexColor(0.4, 0.4, 0.4);
            end
        elseif arg1 == 'Blizzard_CraftUI' then          -- CRAFT
            local _, a, b, c, d = CraftFrame:GetRegions()
            for _, v in pairs({a, b, c, d}) do
                table.insert(ZUI_COLOURELEMENTS_FOR_UI, v)
				v:SetVertexColor(0.4, 0.4, 0.4);
            end
        elseif arg1 == 'Blizzard_InspectUI' then        -- INSPECT
            local a, b, c, d = InspectPaperDollFrame:GetRegions()
            for _, v in pairs({a, b, c, d}) do
                table.insert(ZUI_COLOURELEMENTS_FOR_UI, v)
				v:SetVertexColor(0.4, 0.4, 0.4);
            end
            local a, b, c, d = InspectHonorFrame:GetRegions()
            for _, v in pairs({a, b, c, d}) do
                table.insert(ZUI_COLOURELEMENTS_FOR_UI, v)
				v:SetVertexColor(0.4, 0.4, 0.4);
            end
        elseif arg1 == 'Blizzard_MacroUI' then          -- MACRO
            local _, a, b, c, d = MacroFrame:GetRegions()
            for _, v in pairs({a, b, c, d}) do
                table.insert(ZUI_COLOURELEMENTS_FOR_UI, v)
				v:SetVertexColor(0.4, 0.4, 0.4);
            end
            local a, b, c, d = MacroPopupFrame:GetRegions()
            for _, v in pairs({a, b, c, d}) do
                table.insert(ZUI_COLOURELEMENTS_FOR_UI, v)
				v:SetVertexColor(0.4, 0.4, 0.4);
            end
        elseif arg1 == 'Blizzard_RaidUI' then
            local _, a = ReadyCheckFrame:GetRegions()   -- READYCHECK
            table.insert(ZUI_COLOURELEMENTS_FOR_UI, a)
			a:SetVertexColor(0.4, 0.4, 0.4);
        elseif arg1 == 'Blizzard_TalentUI' then         -- TALENTS
            local _, a, b, c, d = TalentFrame:GetRegions()
            for _, v in pairs({a, b, c, d}) do
                table.insert(ZUI_COLOURELEMENTS_FOR_UI, v)
				v:SetVertexColor(0.4, 0.4, 0.4);
            end
        elseif arg1 == 'Blizzard_TradeSkillUI' then     -- TRADESKILL
            local _, a, b, c, d = TradeSkillFrame:GetRegions()
            for _, v in pairs({a, b, c, d}) do
                table.insert(ZUI_COLOURELEMENTS_FOR_UI, v)
				v:SetVertexColor(0.4, 0.4, 0.4);
            end
        elseif arg1 == 'Blizzard_TrainerUI' then        -- TRAINER
            local _, a, b, c, d = ClassTrainerFrame:GetRegions()
            for _, v in pairs({a, b, c, d}) do
                table.insert(ZUI_COLOURELEMENTS_FOR_UI, v)
				v:SetVertexColor(0.4, 0.4, 0.4);
            end
        end
    end)

	-- Execute
	for _, v in pairs(ZUI_COLOURELEMENTS_FOR_UI) do
		if (C.global.darkmode == "1") then v:SetVertexColor(0.4, 0.4, 0.4); end
    end
	for _, v in pairs(ZUI_COLOURELEMENTS_BORDER_FOR_UI) do
		if (C.global.darkmode == "1") then v:SetBackdropBorderColor(0.4, 0.4, 0.4); end
    end
end)

