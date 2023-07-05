

zUI:RegisterComponent("zUnitframes", function ()
	zUI.zUnitframes = CreateFrame("Frame", "zUnitframes", UIParent);
	--setfenv(0, zUI:GetEnvironment())
	--local _G = getfenv(0)

	--local C = zUI_config

	for _, v in pairs({ PlayerFrame, TargetFrame, PartyMemberFrame1 }) do
        v:SetUserPlaced(true) v:SetMovable(true) v:EnableMouse(true)
        v:SetScript('OnDragStart', function() if IsShiftKeyDown() then this:StartMoving() end end)
        v:SetScript('OnDragStop',  function() this:StopMovingOrSizing() end)
        v:RegisterForDrag'LeftButton'
    end

	function zHealthBar_OnValueChanged(value, smooth)
		if (this == PlayerFrameHealthBar ) then 
			if (C.unitframes.playerclasscolor == "1") then
				this:SetStatusBarColor(UnitColor("player"));
				--return --should not run original function after this since return.
			else
				this:SetStatusBarColor(0,1,0);
				--return
			end

		elseif (this == TargetFrameHealthBar ) then 
			--if ( UnitIsTapped("target") and not UnitIsTappedByPlayer("target") ) then
			-- Gray if npc is tapped by other player
			--	this:SetStatusBarColor(0.5, 0.5, 0.5);
			--else -- Standard by class etc if not
				this:SetStatusBarColor(UnitColor("target"));	
			--end
		end
	end

	function _G.TargetFrame_OnShow() end           -- REMOVE TARGETING SOUND
	function _G.TargetFrame_OnHide() CloseDropDownMenus() end

	function zTargetFrame_OnUpdate()
		--MH3Blizz:PowerUpdate();

		-- Set back color of health bar
		--TargetofTarget_Update();

		--if ( UnitIsTapped("target") and not UnitIsTappedByPlayer("target") ) then
			-- Gray if npc is tapped by other player
		--	this.healthbar:SetStatusBarColor(0.5, 0.5, 0.5);
		--else -- Standard by class etc if not
		--zPrint(this:GetName())
			this.healthbar:SetStatusBarColor(UnitColor(this.healthbar.unit));	
		--end
	end

	function zTargetFrame_CheckClassification()
		local classification = UnitClassification("target");

		if (C.global.darkmode == "1") then
			if (C.unitframes.compactmode == "1") then 
				UnitFramesImproved_SetTexture(TargetFrameTexture, "DarkCompactUI"); -- DARK COMPACT FRAMES
			else 
				UnitFramesImproved_SetTexture(TargetFrameTexture, "darkUI"); -- DARK EXTENDED FRAMES
			end
		else
			if (C.unitframes.compactmode == "1") then 
				UnitFramesImproved_SetTexture(TargetFrameTexture, "compactUI"); -- LIGHT COMPACT FRAMES
			else 
				UnitFramesImproved_SetTexture(TargetFrameTexture, "UI"); -- LIGHT EXTENDED FRAMES
			end
		end
		return
	end
	-- helper function, maybe move to API
	function UnitFramesImproved_SetTexture(frame, type)
		local classification = UnitClassification("target");
		if ( classification == "worldboss" ) then
			frame:SetTexture("Interface\\Addons\\zUI\\img\\unitframe\\" .. type .. "-TargetingFrame-Elite");
		elseif ( classification == "rareelite"  ) then
			frame:SetTexture("Interface\\Addons\\zUI\\img\\unitframe\\" .. type .. "-TargetingFrame-Rare-Elite");
		elseif ( classification == "elite"  ) then
			frame:SetTexture("Interface\\Addons\\zUI\\img\\unitframe\\" .. type .. "-TargetingFrame-Elite");
		elseif ( classification == "rare"  ) then
			frame:SetTexture("Interface\\Addons\\zUI\\img\\unitframe\\" .. type .. "-TargetingFrame-Rare");
		else
			frame:SetTexture("Interface\\Addons\\zUI\\img\\unitframe\\" .. type .. "-TargetingFrame");
		end
	end

	function zPetFrame_OnUpdate(elapsed)
		if (C.unitframes.improvedpet == "1") then
			PetFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetofTargetFrame"); -- no need to set texture every frame?
			PetFrameHappiness:Hide()

			local happiness, damagePercentage, loyaltyRate = GetPetHappiness()
			local pp = UnitPowerType'pet'
			local _, class = UnitClass("player")

			if(pp == 2) then
				this.manabar:SetStatusBarColor(1,0.4,0) -- Better color for pet energy bar
			else
				this.manabar:SetStatusBarColor(0,0,1)
			end
			if class == 'HUNTER' then
				if (happiness == 3) then
					this.healthbar:SetStatusBarColor(0,1,0)
				elseif (happiness == 2) then
					this.healthbar:SetStatusBarColor(1,1,0)
				else 
					this.healthbar:SetStatusBarColor(1,0,0)
				end
			end
		end
		--CombatFeedback_OnUpdate(elapsed); -- gets fired in function before it? 

		if(C.unitframes.hidepettext == "1") then
			PetFrame.healthbar.TextString:Hide();
			PetFrame.manabar.TextString:Hide();
		end
	end

	function zTextStatusBar_UpdateTextString(textStatusBar)	
		if ( not textStatusBar ) then
			textStatusBar = this;
		end
		local string = textStatusBar.TextString;
		if(string) then
			local value = textStatusBar:GetValue();
			local valueMin, valueMax = textStatusBar:GetMinMaxValues();
			local pp = UnitPowerType'player'
    		local v  = math.floor(textStatusBar:GetValue())
    		local min, max = textStatusBar:GetMinMaxValues()
			local percent = math.floor(v/max*100)
			local _, class = UnitClass("player")
			if (C.unitframes.coloredtext == "1") then
				if  textStatusBar:GetName() == 'PlayerFrameManaBar' or textStatusBar:GetName() == 'TargetFrameManaBar' then
					if class == 'ROGUE' or (class == 'DRUID' and pp == 3) then
						string:SetTextColor(250/255, 240/255, 200/255)
					elseif class == 'WARRIOR' or (class == 'DRUID' and pp == 1) then
						string:SetTextColor(250/255, 108/255, 108/255)
					else
						string:SetTextColor(.6, .65, 1)
					end
				elseif textStatusBar:GetName() == 'PlayerFrameHealthBar' then
					zGradient(v, string, min, max)
				end
			end
			if ( valueMax > 0 ) then
				textStatusBar:Show();
				if ( value == 0 and textStatusBar.zeroText ) then
					string:SetText(textStatusBar.zeroText);
					textStatusBar.isZero = 1;
					string:Show();
				else
					textStatusBar.isZero = nil;
						if (C.unitframes.percentages == "1") then
							string:SetText(true_format(v)..'/'..true_format(max).. ' \226\128\148 ' ..percent..'%')
						else
							string:SetText(true_format(v)..'/'..true_format(max))
						end
					if ( GetCVar("statusBarText") == "1" and textStatusBar.textLockable ) then
						string:Show();
					elseif ( textStatusBar.lockShow > 0 ) then
						string:Show();
					else
						string:Hide();
					end
				end
			else
				textStatusBar:Hide();
			end
		end
		return -- should not run original function.
	end

	function Initial_UnitframesLayout()
		zUI.zUnitframes.Style_PlayerFrame();
		zUI.zUnitframes.Style_TargetFrame(TargetFrame);
		zUI.zUnitframes.Style_PetFrame();

		--Flat Healthbar texture if set in config
		if (C.unitframes.healthtexture == "1") then
			UnitFramesImproved_HealthBarTexture(ZUI_FLAT_TEXTURE);
		end
		if (C.unitframes.classportraits == "1") then
			UnitFramesImproved_ClassPortraits();
		end
		
		if(C.unitframes.compactmode == "1") then
			PlayerName:SetPoint("CENTER", PlayerFrameHealthBar, "Center", C.unitframes.nametextx + 3, C.unitframes.nametexty + 6);
			TargetName:SetPoint("CENTER", TargetFrameHealthBar, "Center", -C.unitframes.nametextx + 3, C.unitframes.nametexty + 6); 
		else
			PlayerName:SetPoint("CENTER", PlayerFrameHealthBar, "Center", C.unitframes.nametextx + 3, C.unitframes.nametexty + 1); -- y = +6
			TargetName:SetPoint("CENTER", TargetFrameHealthBar, "Center", -C.unitframes.nametextx + 3, C.unitframes.nametexty + 1); 
		end

		TargetofTargetName:SetPoint("BOTTOMLEFT", 42, -2);
		

		if(C.unitframes.nameoutline == "1") then
			PlayerName:SetFont("Fonts\\FRIZQT__.TTF", C.unitframes.namefontsize, "OUTLINE");
			TargetName:SetFont("Fonts\\FRIZQT__.TTF", C.unitframes.namefontsize, "OUTLINE");
			TargetofTargetName:SetFont("Fonts\\FRIZQT__.TTF", C.unitframes.namefontsize - 1, 'OUTLINE');
			PetName:SetFont("Fonts\\FRIZQT__.TTF", C.unitframes.namefontsize - 1, "OUTLINE");

			PlayerFrameHealthBarText:SetFont(STANDARD_TEXT_FONT, C.unitframes.valuefontsize, 'OUTLINE'); 
			PlayerFrameManaBarText:SetFont(STANDARD_TEXT_FONT, C.unitframes.valuefontsize, 'OUTLINE');
			--if class == 'DRUID' then
			--	emtext:SetFont(STANDARD_TEXT_FONT, C.unitframes.valuefontsize, 'OUTLINE')
			--end
			PetFrameHealthBarText:SetFont(STANDARD_TEXT_FONT, C.unitframes.valuefontsize - 2, 'OUTLINE');
			PetFrameManaBarText:SetFont(STANDARD_TEXT_FONT, C.unitframes.valuefontsize - 2, 'OUTLINE');
		else
			PlayerName:SetFont("Fonts\\FRIZQT__.TTF", C.unitframes.namefontsize);
			TargetName:SetFont("Fonts\\FRIZQT__.TTF", C.unitframes.namefontsize);
			TargetofTargetName:SetFont("Fonts\\FRIZQT__.TTF", C.unitframes.namefontsize - 1);
			PetName:SetFont("Fonts\\FRIZQT__.TTF", C.unitframes.namefontsize - 1);

			PlayerFrameHealthBarText:SetFont(STANDARD_TEXT_FONT, C.unitframes.valuefontsize);
			PlayerFrameManaBarText:SetFont(STANDARD_TEXT_FONT, C.unitframes.valuefontsize);
			--if class == 'DRUID' then
			--	emtext:SetFont(STANDARD_TEXT_FONT, C.unitframes.valuefontsize);
			--end
			PetFrameHealthBarText:SetFont(STANDARD_TEXT_FONT, C.unitframes.valuefontsize - 2);
			PetFrameManaBarText:SetFont(STANDARD_TEXT_FONT, C.unitframes.valuefontsize - 2);
		end

		PlayerFrameHealthBarText:SetJustifyV'MIDDLE'
		PlayerFrameManaBarText:SetJustifyV'MIDDLE'
		PetFrameHealthBarText:SetJustifyV'MIDDLE'
		PetFrameManaBarText:SetJustifyV'MIDDLE'
	end

	function zUI.zUnitframes.Style_PlayerFrame()
		if (C.unitframes.compactmode == "0") then
			if (C.global.darkmode == "0") then
				PlayerFrameTexture:SetTexture("Interface\\Addons\\zUI\\img\\unitframe\\UI-TargetingFrame");
			else
				PlayerFrameTexture:SetTexture("Interface\\Addons\\zUI\\img\\unitframe\\darkUI-TargetingFrame");
			end
			PlayerFrameHealthBar:SetWidth(119);
			PlayerFrameHealthBar:SetHeight(29);
			PlayerFrameHealthBar:SetPoint("TOPLEFT",106,-22);
			PlayerFrameHealthBarText:SetPoint("CENTER",50,6);
			PlayerFrameManaBar:SetPoint("TOPLEFT",106,-51);
			PlayerFrameManaBarText:SetPoint("CENTER",50,-8);
		else
			if (C.global.darkmode == "0") then
				PlayerFrameTexture:SetTexture("Interface\\Addons\\zUI\\img\\unitframe\\compactUI-TargetingFrame");
			else
				PlayerFrameTexture:SetTexture("Interface\\Addons\\zUI\\img\\unitframe\\DarkCompactUI-TargetingFrame");
			end
			PlayerFrameBackground:SetPoint("TOPLEFT",106,-24);
			PlayerFrameBackground:SetHeight(30);
			PlayerFrameHealthBar:SetHeight(20);
			PlayerFrameHealthBar:SetPoint("TOPLEFT",106,-22);
			PlayerFrameHealthBarText:SetPoint("CENTER",50,16);
			PlayerFrameManaBar:SetPoint("TOPLEFT",106,-42);
			PlayerFrameManaBarText:SetPoint("CENTER",50,3);
		end
		if (C.unitframes.statusglow == "1") then
			PlayerStatusTexture:SetTexture("Interface\\Addons\\zUI\\img\\unitframe\\UI-Player-Status");	
		else
			PlayerStatusTexture:SetTexture(nil);
		end	
	end

	function zUI.zUnitframes.Style_TargetFrame(unit)
		local classification = UnitClassification("target");
		--if (GetCVar("ufiCompactMode") == "1") then
		TargetDeadText:SetText()
		if (C.unitframes.compactmode == "1") then 
			TargetFrameBackground:SetHeight(30);
			TargetFrameHealthBar:SetHeight(20);
			TargetFrameHealthBar:SetPoint("TOPLEFT",6,-22);
			TargetFrameManaBar:ClearAllPoints()
			TargetFrameManaBar:SetPoint("TOPRIGHT",-106,-42);
			TargetDeadText:SetPoint("CENTER",-50,4);
			TargetFrameNameBackground:Hide();
		else
			--if (classification == "minus") then -- ROFL, "minus" came in Patch 5.0.4 , been here for ages...
			
			TargetFrameHealthBar:SetHeight(29);
			TargetFrameHealthBar:SetPoint("TOPLEFT",6,-22);
			TargetFrameManaBar:SetPoint("TOPLEFT",6,-51);
			TargetDeadText:SetPoint("CENTER",-50,6);
			TargetFrameNameBackground:Hide();
			
			TargetFrameHealthBar:SetWidth(119);
			TargetFrameHealthBar.lockColor = true;
		end
	end

	function zUI.zUnitframes.Style_PetFrame()
		if (C.unitframes.improvedpet == "1") then
			PetFrameTexture:SetTexCoord(1, 0, 0, 1)
			PetFrameTexture:ClearAllPoints()
			PetFrameTexture:SetPoint("BOTTOMRIGHT", PlayerFrame, "BOTTOMRIGHT", -104, -28)--HERE -102, -29 -- -2, +1
			PetPortrait:ClearAllPoints() 
			PetPortrait:SetPoint("BOTTOMRIGHT", PetFrame, "BOTTOMRIGHT", -86, 8)
			PetAttackModeTexture:ClearAllPoints() 
			PetAttackModeTexture:SetPoint("BOTTOMRIGHT", PetFrame, "BOTTOMRIGHT", -46, -22)
			PetFrameHealthBar:ClearAllPoints()
			PetFrameHealthBar:SetWidth(45)
			PetFrameHealthBar:SetPoint("BOTTOMRIGHT", PetFrame, "BOTTOMRIGHT", -125, 27)
			PetFrameHealthBarText:ClearAllPoints()
			PetFrameHealthBarText:SetPoint("BOTTOMRIGHT", PetFrame, "BOTTOMRIGHT", -125, 27)
			PetFrameManaBar:ClearAllPoints()
			PetFrameManaBar:SetWidth(45)
			PetFrameManaBar:SetPoint("BOTTOMRIGHT", PetFrame, "BOTTOMRIGHT", -125, 18)
			PetFrameManaBarText:ClearAllPoints()
			PetFrameManaBarText:SetPoint("BOTTOMRIGHT", PetFrame, "BOTTOMRIGHT", -125, 17)
			PetName:ClearAllPoints()
			PetName:SetPoint("BOTTOMRIGHT", PetFrame, "BOTTOMRIGHT", -125, 6)
		end
	end

	--Sets the texture for the StatusBars
	function UnitFramesImproved_HealthBarTexture(NAME_TEXTURE)
		PlayerFrameHealthBar:SetStatusBarTexture(NAME_TEXTURE)
		PlayerFrameManaBar:SetStatusBarTexture(NAME_TEXTURE)
		TargetFrameHealthBar:SetStatusBarTexture(NAME_TEXTURE)
		TargetFrameManaBar:SetStatusBarTexture(NAME_TEXTURE)
		PetFrameHealthBar:SetStatusBarTexture(NAME_TEXTURE)
		PetFrameManaBar:SetStatusBarTexture(NAME_TEXTURE)
		TargetofTargetHealthBar:SetStatusBarTexture(NAME_TEXTURE)
		TargetofTargetManaBar:SetStatusBarTexture(NAME_TEXTURE)
		--PartyMemberFrame1HealthBar:SetStatusBarTexture(NAME_TEXTURE);
		--PartyMemberFrame1ManaBar:SetStatusBarTexture(NAME_TEXTURE);
		--Add party frames
	end

	function UnitFramesImproved_ClassPortraits()
		if (C.unitframes.classportraits == "1") then
			local function log(msg) DEFAULT_CHAT_FRAME:AddMessage(msg) end -- alias for convenience
			local ClassPortraits = CreateFrame("Frame", "zClassPortraits", UIParent);
			local iconPath="Interface\\Addons\\zUI\\img\\UI-CLASSES-CIRCLES.tga"

			--local CLASS_BUTTONS = { ["HUNTER"] = {0,0.25,0.25,0.5}, ["WARRIOR"] = {0,0.25,0,0.25}, ["ROGUE"] = {0.5,0.75,0,0.25}, 
			--						["MAGE"] = {0.25,0.5,0,0.25}, ["PRIEST"] = {0.50,0.75,0.25,0.5}, ["WARLOCK"] = {0.75,1,0.25,0.5}, 
			--						["DRUID"] = {0.75,1,0,0.25}, ["SHAMAN"] = {0.25,0.50,0.25,0.5}, ["PALADIN"] = {0,0.25,0.5,0.75} }
			-- copied from TBC Client 2.4.3
			local CLASS_BUTTONS = { ["HUNTER"] = {0,0.25,0.25,0.5}, ["WARRIOR"] = {0,0.25,0,0.25}, ["ROGUE"] = {0.49609375,0.7421875,0,0.25}, 
									["MAGE"] = {0.25,0.49609375,0,0.25}, ["PRIEST"] = {0.49609375,0.7421875,0.25,0.5}, ["WARLOCK"] = {0.7421875,0.98828125,0.25,0.5}, 
									["DRUID"] = {0.7421875,0.98828125,0,0.25}, ["SHAMAN"] = {0.25,0.49609375,0.25,0.5}, ["PALADIN"] = {0,0.25,0.5,0.75} }

			local partyFrames = {
				[1] = PartyMemberFrame1,
				[2] = PartyMemberFrame2,
				[3] = PartyMemberFrame3,
				[4] = PartyMemberFrame4,
			}
			
			hooksecurefunc("SetPortraitTexture", function()
			--ClassPortraits:SetScript("OnEvent", function()
				if(this == PlayerFrame) then
					if PlayerFrame.portrait~=nil then
						local _, class = UnitClass("player")
						local iconCoords = CLASS_BUTTONS[class]
						PlayerFrame.portrait:SetTexture(iconPath)
						PlayerFrame.portrait:SetTexCoord(unpack(iconCoords))
					end
					return
				end
				for i=1, GetNumPartyMembers() do
					if this == partyFrames[i] and partyFrames[i].portrait~=nil then
						local _, class = UnitClass("party"..i)
						if not CLASS_BUTTONS[class] then return end
						partyFrames[i].portrait:SetTexture(iconPath, true)
						partyFrames[i].portrait:SetTexCoord(unpack(CLASS_BUTTONS[class]))
					end
				end
				if(this == TargetFrame) then
					if(UnitName("target")~=nil and UnitIsPlayer("target") ~= nil and TargetFrame.portrait~=nil) then
						local _, class = UnitClass("target")
						--SetPortraitToTexture(TargetFrame.portrait,iconPath)
						TargetFrame.portrait:SetTexture(iconPath)
						TargetFrame.portrait:SetTexCoord(unpack(CLASS_BUTTONS[class]))
					elseif(UnitName("target")~=nil) then
						TargetFrame.portrait:SetTexCoord(0,1,0,1)
					end
					return
				end
				if(this == TargetofTargetFrame) then
					if(UnitName("targettarget")~=nil and UnitIsPlayer("targettarget") ~= nil and TargetofTargetFrame.portrait~=nil) then
						local _, class = UnitClass("targettarget")
						TargetofTargetFrame.portrait:SetTexture(iconPath)
						TargetofTargetFrame.portrait:SetTexCoord(unpack(CLASS_BUTTONS[class]))
					elseif(UnitName("targettarget")~=nil) then
						TargetofTargetFrame.portrait:SetTexCoord(0,1,0,1)
					end
					return
				end
			end, true)
		end
	end

	hooksecurefunc("HealthBar_OnValueChanged",zHealthBar_OnValueChanged,true); -- can be after orig..
	--hooksecurefunc("TargetFrame_OnUpdate",zTargetFrame_OnUpdate,true); --run after default. --worried about this, YES IT WAS A BAD IDEA
	hooksecurefunc("TargetFrame_CheckFaction",zTargetFrame_OnUpdate,true); --run after default. 
	hooksecurefunc("TargetFrame_CheckClassification",zTargetFrame_CheckClassification,true);
	hooksecurefunc("PetFrame_OnUpdate",zPetFrame_OnUpdate,true); --run after default.
	hooksecurefunc("TextStatusBar_UpdateTextString",zTextStatusBar_UpdateTextString, true);

	Initial_UnitframesLayout();


	-----------------------------------==[[ TargetFrame Health ]]==------------------------------------------>

	-- Create frame and fontstrings

    zUI.MobHealth = CreateFrame("Frame", "zMobHealthFrame", TargetFrame)

    htext = zUI.MobHealth:CreateFontString("zTargetHealthText", "ARTWORK")
    htext:SetFontObject(GameFontNormalSmall)
    htext:SetHeight(32)
	
    --htext:SetPoint("TOP", TargetFrameHealthBar, "BOTTOM", MH3BlizzConfig.healthX-2, MH3BlizzConfig.healthY+22)
	--zTargetHealthText:SetPoint('CENTER', TargetFrameHealthBar, 0, -9) -- -2
    htext:SetTextColor(1, 1, 1, 1)

    ptext = zUI.MobHealth:CreateFontString("zTargetPowerText", "ARTWORK")
    ptext:SetFontObject(GameFontNormalSmall)
    ptext:SetHeight(32)
    --ptext:SetPoint("TOP", TargetFrameManaBar, "BOTTOM", MH3BlizzConfig.powerX-2, MH3BlizzConfig.powerY+22)
	--zTargetPowerText:SetPoint('CENTER', TargetFrameManaBar, 0, -1) -- 1
    ptext:SetTextColor(1, 1, 1, 1)

	if(C.unitframes.compactmode == "1") then
		zTargetHealthText:SetPoint('CENTER', TargetFrameHealthBar, 0, -2) -- -2
		zTargetPowerText:SetPoint('CENTER', TargetFrameManaBar, 0, 1) -- 1
	else
		zTargetHealthText:SetPoint('CENTER', TargetFrameHealthBar, 0, -8) -- -2
		zTargetPowerText:SetPoint('CENTER', TargetFrameManaBar, 0, -1) -- 1
	end

	for _, v in pairs ({zTargetHealthText, zTargetPowerText}) do
		if (C.unitframes.nameoutline == "1") then
			v:SetFont(STANDARD_TEXT_FONT, C.unitframes.valuefontsize, 'OUTLINE')
		else
			v:SetFont(STANDARD_TEXT_FONT, C.unitframes.valuefontsize)
		end
		v:SetShadowOffset(0, 0)
		v:SetJustifyV'MIDDLE'
		if uStatus == 0 and uBoth == 0 then
            v:ClearAllPoints()
            v:SetPoint('CENTER', TargetFrame, v:GetName() == 'zTargetPowerText' and -26 or -75, -3) -- -3
        end
	end
    --        v:SetShadowOffset(0, 0)
    --        v:SetJustifyV'MIDDLE'
    --        if uStatus == 0 and uBoth == 0 then
    --            v:ClearAllPoints()
    --            v:SetPoint('CENTER', TargetFrame, v:GetName() == 'zTargetPowerText' and -26 or -75, -3) -- -3
    --        end
    --    end
	--	zTargetHealthText:ClearAllPoints()
	--	zTargetHealthText:SetPoint('CENTER', TargetFrameHealthBar, 0, -2)
	--
	--	zTargetPowerText:ClearAllPoints()
	--	zTargetPowerText:SetPoint('CENTER', TargetFrameManaBar, 0, 1)
	--
	zMobHealthFrame:RegisterEvent("UNIT_HEALTH");
	zMobHealthFrame:RegisterEvent("UNIT_MANA");
	zMobHealthFrame:RegisterEvent("PLAYER_TARGET_CHANGED");

	zMobHealthFrame:SetScript("OnEvent", function()
	
		if (event == "UNIT_HEALTH") then
			if arg1 == "target" then zUI.MobHealth:HealthUpdate() end
			--zPrint("HealthUpdate!");
		elseif (event == "UNIT_MANA") then
			if arg1 == "target" then zUI.MobHealth:PowerUpdate() end
			--zPrint("ManaUpdate!");
		elseif (event == "PLAYER_TARGET_CHANGED") then
			--zPrint("TargetChanged!");
			zUI.MobHealth:HealthUpdate();
			zUI.MobHealth:PowerUpdate();
		end
	end)

	local uStatus = 1
	local uBoth = 1
	local uValue = 1

	function zUI.MobHealth:HealthUpdate()
		local v, max = UnitHealth("target"), UnitHealthMax("target");

		if (MobHealth3 or MobHealthFrame) then
			v, max  = MobHealth3:GetUnitHealth("target", UnitHealth("target"), UnitHealthMax("target"))
		end

        local percent = math.floor(v/max*100)
        local string  = zTargetHealthText
        --Initialize()

        --if MH3BlizzConfig.healthAbs then
            if max == 100 then
                -- Do nothing!
            else
                v = math.floor(v)
            end
        --end
		-- FOR COLOR CHANGING HP 
        if (C.unitframes.coloredtext == "1") then
			zGradient(v, string, 0, max)
		end
        if uBoth == 1 then
            if max == 100 then
                string:SetText(percent..'%')
            else
				if (C.unitframes.percentages == "1") then
					string:SetText(true_format(v)..'/'..true_format(max)..'  - '..percent..'%') -- — 
				else
					string:SetText(true_format(v)..'/'..true_format(max))
				end
            end
			--string:ClearAllPoints();
            --string:SetPoint('RIGHT', -8, 6)
			--string:SetPoint('RIGHT', TargetFrame,-8, 6)
        elseif uValue  == 1 and uBoth == 0 then
            --local logic = MH3BlizzConfig.healthPerc and v <= 100 and percent == v
            local logic = v <= 100 and percent == v
            local t = logic and true_format(v)..'%' or true_format(v)
            string:SetText(t)
        else
            string:SetText(percent..'%')
        end
    end

	function zUI.MobHealth:PowerUpdate()
	
        local _, class = UnitClass'target'
		local pp	   = UnitPowerType'target'
        local v, max   = UnitMana'target', UnitManaMax'target'
        local percent  = math.floor(v/max*100)
        local string   = zTargetPowerText
        --Initialize()

        if max == 0 or cur == 0 or percent == 0 then string:SetText() return end
        --if MH3BlizzConfig.powerAbs then v = math.floor(v) end
        v = math.floor(v)
		-- FOR COLOR CHANGING MP
		if (C.unitframes.coloredtext == "1") then
            if class == 'ROGUE' or (class == 'DRUID' and pp == 3) then
                string:SetTextColor(250/255, 240/255, 200/255)
            elseif class == 'WARRIOR' or (class == 'DRUID' and pp == 1) then
                string:SetTextColor(250/255, 108/255, 108/255)
            else
                string:SetTextColor(.6, .65, 1)
            end
		end
        if uBoth == 1 then
            if max == 100 then
                string:SetText(percent..'%')
            else
				if (C.unitframes.percentages == "1") then
					string:SetText(true_format(v)..'/'..true_format(max)..'  - '..percent..'%')
				else
					string:SetText(true_format(v)..'/'..true_format(max))
				end
            end
			--string:ClearAllPoints();
            string:SetPoint('RIGHT', -8, 0) -- -8
        elseif uValue  == 1 and uBoth == 0 then
            --local logic = MH3BlizzConfig.powerPerc and v <= 100 and percent == v and class ~= 'ROGUE'
            local logic = v <= 100 and percent == v and class ~= 'ROGUE'
            local t = logic and true_format(v)..'%' or true_format(v)
            string:SetText(t)
        else
            string:SetText(percent..'%')
        end
    end

	local f = CreateFrame'Frame'

    f:RegisterEvent'CVAR_UPDATE' 
	f:RegisterEvent'PLAYER_ENTERING_WORLD' 
	f:RegisterEvent'ADDON_LOADED'
	
    f:SetScript('OnEvent', function()
		
        if arg1 == 'STATUS_BAR_TEXT' or event == 'PLAYER_ENTERING_WORLD' then
			if (MobHealth3BlizzardHealthText or MobHealth3BlizzardPowerText) then
				MobHealth3BlizzardHealthText:Hide();
				MobHealth3BlizzardPowerText:Hide();
			end

			if (C.unitframes.forceshowtext == "1") then
				zTargetHealthText:Show() zTargetPowerText:Show()
				PlayerFrameHealthBarText:Show() PlayerFrameManaBarText:Show()
				
				PlayerFrameHealthBar:SetScript('OnLeave', function() PlayerFrameHealthBarText:Show() end)
				PlayerFrameManaBar:SetScript('OnLeave', function() PlayerFrameManaBarText:Show() end)

				PlayerFrameHealthBar:SetScript('OnEvent', function() PlayerFrameHealthBarText:Show() end)
				PlayerFrameManaBar:SetScript('OnEvent', function() PlayerFrameManaBarText:Show() end)
			else
				if GetCVar'statusBarText' == '0' then
				    zTargetHealthText:Hide() zTargetPowerText:Hide()
				    TargetFrameHealthBar:SetScript('OnEnter', function() zTargetHealthText:Show() end)
				    TargetFrameHealthBar:SetScript('OnLeave', function() zTargetHealthText:Hide() end)
				    TargetFrameManaBar:SetScript('OnEnter', function() zTargetPowerText:Show() end)
				    TargetFrameManaBar:SetScript('OnLeave', function() zTargetPowerText:Hide() end)
					--Initialize();
				else
				    zTargetHealthText:Show() zTargetPowerText:Show()
					--Initialize();
				end
			end
        elseif(event == "ADDON_LOADED") then
			--zPrint(arg1);
			if (arg1 == "MobHealth") then
				if (MobHealth3BlizzardHealthText or MobHealth3BlizzardPowerText) then
					MobHealth3BlizzardHealthText:Hide();
					MobHealth3BlizzardPowerText:Hide();
				end
			end

		end
		
    end)

	--- added,
	hooksecurefunc("PlayerFrame_UpdatePvPStatus", function() --todo move to correct place.
		local factionGroup, factionName = UnitFactionGroup("player");
		if ( UnitIsPVPFreeForAll("player") ) then
			PlaySound("igPVPUpdate");
			PlayerPVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
			PlayerPVPIcon:Show();

			-- Setup newbie tooltip
			PlayerPVPIconHitArea.tooltipTitle = PVPFFA;
			PlayerPVPIconHitArea.tooltipText = NEWBIE_TOOLTIP_PVPFFA;
			PlayerPVPIconHitArea:Show();
		elseif ( factionGroup and UnitIsPVP("player") ) then
			PlaySound("igPVPUpdate");
			-- TODO move these textures in to zUI folder!
			PlayerPVPIcon:SetTexture("Interface\\Addons\\UnitFramesImproved_Vanilla\\Textures\\UI-PVP-"..factionGroup);
			--PlayerPVPIcon:SetVertexColor(0.8,0.8,0.8,1);
			PlayerPVPIcon:Show();

			-- Setup newbie tooltip
			PlayerPVPIconHitArea.tooltipTitle = factionName;
			PlayerPVPIconHitArea.tooltipText = getglobal("NEWBIE_TOOLTIP_"..strupper(factionGroup));
			PlayerPVPIconHitArea:Show();
		else
			PlayerPVPIcon:Hide();
			PlayerPVPIconHitArea:Hide();
		end
	end,true)

	hooksecurefunc("TargetFrame_CheckFaction", function()
		local factionGroup = UnitFactionGroup("target");
		if ( UnitIsPVPFreeForAll("target") ) then
			TargetPVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA");
			TargetPVPIcon:Show();
		elseif ( factionGroup and UnitIsPVP("target") ) then
			TargetPVPIcon:SetTexture("Interface\\Addons\\UnitFramesImproved_Vanilla\\Textures\\UI-PVP-"..factionGroup);
			TargetPVPIcon:Show();
		else
			TargetPVPIcon:Hide();
		end
	end,true)

end)