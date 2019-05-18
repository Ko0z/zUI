zUI:RegisterComponent("zAura", function ()

--for i = 6, 12 do
--    local f = CreateFrame('Button', 'TargetFrameBuff'..i, TargetFrame, 'TargetBuffButtonTemplate')
--    f:SetID(i)
--    f:Hide()
--    zSkin(f, 1)      -- first 6 are skinned in skin/button/target.lua
--    zSkinColor(f, .7, .7, .7)
--    if i == 6 then
--        f:SetPoint('TOPLEFT', TargetFrameBuff1, 'BOTTOMLEFT', 0, -2)
--    else
--        f:SetPoint('LEFT', _G['TargetFrameBuff'..(i - 1)], 'RIGHT', 3, 0)
--    end
--end
--

local debuffSize = 18; -- TODO make config for this
local targetaura    = true; --always show 16 

-----------------------------==[[ TargetofTarget Stuff ]]==-------------------------->
local OnUpdate = function()
    for i = 1, 4 do
        local f     = 'TargetofTargetFrameDebuff'..i
        local d     = _G[f..'Border']
        local icon  = _G[f..'Icon']
        if  d then
            local r, g, b = d:GetVertexColor()
            --if  skin.enable then
            zSkinColor(_G[f], r*1.5, g*1.5, b*1.5)
            --end
            d:SetAlpha(0)
            icon:SetTexCoord(.1, .9, .1, .9)
        end
    end

end

local OnEvent = function()
	for i = 2, 4 do
	    local bu    = _G['TargetofTargetFrameDebuff'..i]
	    local bu1   = _G['TargetofTargetFrameDebuff1']
	    bu:ClearAllPoints()
	    if      i == 2 then
	        bu:SetPoint('LEFT',     _G['TargetofTargetFrameDebuff1'], 'RIGHT', 4, 0)
	    elseif  i == 3 then
	        bu:SetPoint('TOPLEFT',  _G['TargetofTargetFrameDebuff1'], 'BOTTOMLEFT', 0, -4)
	    else
	        bu:SetPoint('LEFT',     _G['TargetofTargetFrameDebuff3'], 'RIGHT', 4, 0)
	    end
	end

	--for i = 1, 5  do zStyle_Button(_G['TargetFrameBuff'..i], 1) end
	--for i = 1, 16 do zStyle_Button(_G['TargetFrameDebuff'..i], 1) end
	--for i = 1, 4  do zStyle_Button(_G['TargetofTargetFrameDebuff'..i], 0) end
	for i = 1, 4  do zStyle_Button(_G['TargetofTargetFrameDebuff'..i], 0) end


end

--TargetDebuffButton_Update = AddAllTargetBuffs

--TargetFrame:SetScript('OnEnter', OnEnter)
--TargetFrame:SetScript('OnLeave', OnLeave)

local e = CreateFrame('Frame', 'zToT', TargetofTargetTextureFrame)
e:RegisterEvent'PLAYER_LOGIN'
e:SetScript('OnEvent',  OnEvent)
e:SetScript('OnUpdate', OnUpdate)

-------------------------------==[[ PlayerFrame Buff & Debuffs ]]==-------------------------->

if (C.aura.player == "1") then

--local function DebuffOnUpdate()
--	if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + .4 end
--	local timeleft = GetPlayerBuffTimeLeft(GetPlayerBuff(PLAYER_BUFF_START_ID+this.id,"HARMFUL"))
--	CooldownFrame_SetTimer(this.cd, GetTime(), timeleft, 1)
--end

--local function DebuffOnEnter()
--	GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT");
--	GameTooltip:SetPlayerBuff(GetPlayerBuff(this.id - 1,"HARMFUL"));
--end

--local function DebuffOnLeave()
--	GameTooltip:Hide()
--end

--local function DebuffOnClick()
--	if this:GetParent().label == "player" then
--		CancelPlayerBuff(GetPlayerBuff(PLAYER_BUFF_START_ID+this.id,"HARMFUL"))
--	end
--end

zUI.PlayerDebuffs = {};
for i = 1, 16 do
	--if (i == 1) then 
	--	zUI.PlayerDebuffs[i] = CreateFrame('Button', 'zPlayerFrameDebuff'..i, PlayerFrame);
	--	zUI.PlayerDebuffs[i]:SetPoint("TOPLEFT", PlayerFrame, "BOTTOMLEFT", 5, 106);
	--elseif ((i > 1 and i < 9) or (i > 9)) then 
	--	zUI.PlayerDebuffs[i] = CreateFrame('Button', 'zPlayerFrameDebuff'..i, zUI.PlayerDebuffs[i - 1]);
	--	zUI.PlayerDebuffs[i]:SetPoint("LEFT", 'zPlayerFrameDebuff'..i - 1, "RIGHT", 4, 0);
	--elseif (i == 9) then
	--	zUI.PlayerDebuffs[i] = CreateFrame('Button', 'zPlayerFrameDebuff'..i, zUI.PlayerDebuffs[1]);
	--	zUI.PlayerDebuffs[i]:SetPoint("TOPLEFT", 'zPlayerFrameDebuff1', "BOTTOMLEFT", 0, debuffSize * 2 + 4);
	--end
	if (i == 1) then 
		zUI.PlayerDebuffs[i] = CreateFrame('Button', 'zPlayerFrameDebuff'..i, PlayerFrame);
		zUI.PlayerDebuffs[i]:SetPoint("TOPRIGHT", PlayerFrame, "BOTTOMRIGHT", -5, 106);
	elseif ((i > 1 and i < 9) or (i > 9)) then 
		zUI.PlayerDebuffs[i] = CreateFrame('Button', 'zPlayerFrameDebuff'..i, zUI.PlayerDebuffs[i - 1]);
		zUI.PlayerDebuffs[i]:SetPoint("RIGHT", 'zPlayerFrameDebuff'..i - 1, "LEFT", -4, 0);
	elseif (i == 9) then
		zUI.PlayerDebuffs[i] = CreateFrame('Button', 'zPlayerFrameDebuff'..i, zUI.PlayerDebuffs[1]);
		zUI.PlayerDebuffs[i]:SetPoint("TOPRIGHT", 'zPlayerFrameDebuff1', "BOTTOMRIGHT", 0, debuffSize * 2 + 4);
	end


	zUI.PlayerDebuffs[i].Count = zUI.PlayerDebuffs[i]:CreateFontString("zPlayerFrameDebuff"..i.."Count", "OVERLAY", "NumberFontNormalSmall");
	zUI.PlayerDebuffs[i].Count:SetPoint("BOTTOMRIGHT", zUI.PlayerDebuffs[i], -1, 0);
	zUI.PlayerDebuffs[i].Icon = zUI.PlayerDebuffs[i]:CreateTexture("zPlayerFrameDebuff"..i.."Icon", "ARTWORK");
	zUI.PlayerDebuffs[i].Icon:SetTexCoord(.1, .9, .1, .9);
	zUI.PlayerDebuffs[i].Icon:SetAllPoints();
	zUI.PlayerDebuffs[i].Cooldown = CreateFrame("Model", "zPlayerFrameDebuff"..i.."Cooldown", zUI.PlayerDebuffs[i]);
	zUI.PlayerDebuffs[i].Cooldown.zTextSize = 12;
	zUI.PlayerDebuffs[i].id = i;
	zUI.PlayerDebuffs[i]:SetWidth(debuffSize); 
	zUI.PlayerDebuffs[i]:SetHeight(debuffSize);
	--zUI.PlayerDebuffs[i]:SetNormalTexture(nil);

	-- TEST
	zUI.PlayerDebuffs[i].Icon:SetTexture("Interface\\Icons\\Ability_Gouge");
	zSkin(zUI.PlayerDebuffs[i], 0);
	zSkinColor(zUI.PlayerDebuffs[i], 0, 1, 0);
	----
	
	--zUI.PlayerDebuffs[i]:RegisterEvent("PLAYER_AURAS_CHANGED");
	--zUI.PlayerDebuffs[i]:SetScript("OnUpdate", DebuffOnUpdate);
	if (C.aura.timers == "1") then
		zUI.PlayerDebuffs[i]:SetScript("OnUpdate", function(...)
			if ( this.tick or 1) > GetTime() then return else this.tick = GetTime() + .4 end
			local timeleft = GetPlayerBuffTimeLeft(GetPlayerBuff(this.id - 1,"HARMFUL"))
			CooldownFrame_SetTimer(this.Cooldown, GetTime(), timeleft, 1)
		end)
	end
	zUI.PlayerDebuffs[i]:SetScript("OnEnter", function() 
		GameTooltip:SetOwner(this, "ANCHOR_TOPRIGHT");
		GameTooltip:SetPlayerBuff(GetPlayerBuff(this.id-1,"HARMFUL"));
	end)
	zUI.PlayerDebuffs[i]:SetScript("OnLeave", function() 
		GameTooltip:Hide(); 
	end)
end

function zPlayerDebuffs_Event()
	for i = 1, 16 do
        local icon, stack, dtype = UnitDebuff('player', i)
        local bu = zUI.PlayerDebuffs[i]
        if  bu and icon then
            local count = _G["zPlayerFrameDebuff"..i.."Count"];
            local texture = _G["zPlayerFrameDebuff"..i.."Icon"];
            local colour    = DebuffTypeColor[dtype] or DebuffTypeColor["none"]

            if  stack > 1 then
                count:SetText(stack)
                count:Show()
            else
                count:Hide()
            end

            texture:SetTexture(icon)
			--texture:SetTexCoord(.1, .9, .1, .9)

            --bu.bo:SetBackdropBorderColor(colour.r, colour.g, colour.b)
            --if  skin.enable then
            zSkinColor(bu, colour.r*1.4, colour.g*1.4, colour.b*1.4)
            --end

            bu.id       = i
            --numDebuffs   = i
			--numDebuffs = numDebuffs + 1;
            bu:Show()
        else
            if  bu then 
                bu:Hide() 
            end
        end
    end
end

local f = CreateFrame('Frame', 'zPlayerDebuffs')
f:RegisterEvent("PLAYER_ENTERING_WORLD");
f:RegisterEvent("PLAYER_AURAS_CHANGED");
f:SetScript('OnEvent',  zPlayerDebuffs_Event);
--f:SetScript('OnUpdate', zPlayerDebuffs_Update);
end

-------------------------------==[[ TargetFrame Buff & Debuffs ]]==-------------------------->

local anchor = function(num)
    if num and  num > 5 then return '6' end
    return '1'
end

local function AddAllTargetBuffs()
    local numBuffs, numDebuffs = 0, 0

    --for i = 1, 16 do
    --    local bu    = _G['TargetFrameBuff'..i]
    --    local icon  = UnitBuff('target', i)
    --    if  bu and icon then
    --        _G['TargetFrameBuff'..i..'Icon']:SetTexture(icon)
    --        bu.id   = i
    --        numBuff = i
    --        bu:Show()
    --        if  i > 5 then
    --            if not targetaura and not TargetFrame.onEntered then bu:Hide() end
    --        end
    --    else
    --        if bu then bu:Hide() end
    --    end
    --end

	for i=1, MAX_TARGET_BUFFS do
		local bu    = _G['TargetFrameBuff'..i]
        local icon  = UnitBuff('target', i)
        if  bu and icon then
            _G['TargetFrameBuff'..i..'Icon']:SetTexture(icon)
            bu.id   = i
            --numBuff = i
			numBuffs = numBuffs + 1; 
            bu:Show()
            --if  i > 5 then
            --    if not targetaura and not TargetFrame.onEntered then bu:Hide() end
            --end
        else
            if bu then bu:Hide() end
        end
	end

    for i = 1, 16 do
        local icon, stack, dtype = UnitDebuff('target', i)
        local bu = _G['TargetFrameDebuff'..i]
        if  bu and icon then
            local count     = _G['TargetFrameDebuff'..i..'Count']
            local border    = _G['TargetFrameDebuff'..i..'Border']
            local colour    = DebuffTypeColor[dtype] or DebuffTypeColor['none']

			-----=={{ DEBUFF TIMER }}==----->	TODO: Fix text when theres count as well as timer on...
			--bu.cd = bu.cd or CreateFrame("Model", nil, bu, "CooldownFrameTemplate")
			--bu.cd.zCooldownType = "ALL"
			--local name, rank, texture, stacks, dtype, duration, timeleft = libdebuff:UnitDebuff("target", i)
			--if duration and timeleft then
			--	bu.cd:SetAlpha(0)
			--	CooldownFrame_SetTimer(bu.cd, GetTime() + timeleft - duration, duration, 1)
			--
			--	if  stack > 1 then
			--		count:SetPoint("BOTTOMRIGHT", 0, -4);
			--		--textFrame.text:SetFont(STANDARD_TEXT_FONT, 22, "OUTLINE")
			--		count:SetFont("Fonts\\ARIALN.TTF", 10, "OUTLINE");
			--		count:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			--	end
			--end
			-------------------------------->

			zSkin(bu,0);

            if  stack > 1 then
				count:ClearAllPoints();
				count:SetPoint("BOTTOM",bu, 1, -5);
				count:SetJustifyH("CENTER");
				count:SetFont("Fonts\\ARIALN.TTF", 10, "OUTLINE");
				--count:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                count:SetText(stack)
                count:Show()
            else
                count:Hide()
            end

			border:SetAlpha(0)
            border:Hide()

            _G['TargetFrameDebuff'..i..'Icon']:SetTexture(icon)
			_G['TargetFrameDebuff'..i..'Icon']:SetTexCoord(.1, .9, .1, .9)

            --bu.bo:SetBackdropBorderColor(colour.r, colour.g, colour.b)
            --if  skin.enable then
            zSkinColor(bu, colour.r*1.4, colour.g*1.4, colour.b*1.4)
            --end

            bu.id       = i
            --numDebuffs   = i
			numDebuffs = numDebuffs + 1;
            bu:Show()
        else
            if  bu then 
                bu:Hide() 
            end
        end
    end

    --if ( UnitIsFriend("player", "target") ) then
	--	TargetFrameBuff1:SetPoint("TOPLEFT", "TargetFrame", "BOTTOMLEFT", 5, 32);
	--	TargetFrameDebuff1:SetPoint("TOPLEFT", "TargetFrameBuff1", "BOTTOMLEFT", 2, -4);
	--else
	--	TargetFrameDebuff1:SetPoint("TOPLEFT", "TargetFrame", "BOTTOMLEFT", 5, 32);
	--	if ( targetofTarget ) then
	--		if ( numDebuffs < 5 ) then
	--			TargetFrameBuff1:SetPoint("TOPLEFT", "TargetFrameDebuff6", "BOTTOMLEFT", 2, -4);
	--		elseif ( numDebuffs >= 5 and numDebuffs < 10  ) then
	--			TargetFrameBuff1:SetPoint("TOPLEFT", "TargetFrameDebuff6", "BOTTOMLEFT", 2, -4);
	--		elseif (  numDebuffs >= 10 ) then
	--			TargetFrameBuff1:SetPoint("TOPLEFT", "TargetFrameDebuff11", "BOTTOMLEFT", 2, -4);
	--		end
	--	else
	--		TargetFrameBuff1:SetPoint("TOPLEFT", "TargetFrameDebuff7", "BOTTOMLEFT", 2, -4);
	--	end
	--end
	----------------------==[[ Anchor ABOVE Frame 8 + 8 ]]==------------------------>

	if (C.aura.above == "1") then
		TargetFrameDebuff1:ClearAllPoints();
		TargetFrameDebuff1:SetPoint("TOPLEFT", "TargetFrame", "BOTTOMLEFT", 5, 106);

		for i = 2, 8 do
			local bu = _G['TargetFrameDebuff'..i]
			bu:ClearAllPoints();
			local z = i - 1;
			bu:SetPoint("LEFT", _G['TargetFrameDebuff'..z], "RIGHT", 4, 0);
		end

		TargetFrameDebuff9:SetPoint("TOPLEFT", TargetFrameDebuff1, "BOTTOMLEFT", 0, 40);

		for i = 10, 16 do
			local bu = _G['TargetFrameDebuff'..i]
			bu:ClearAllPoints();
			local z = i - 1;
			bu:SetPoint("LEFT", _G['TargetFrameDebuff'..z], "RIGHT", 4, 0);
		end


	end
    --if  UnitIsFriend('player', 'target') then
    --    if  not var.auras then
    --        --TargetFrameBuff1:ClearAllPoints()
    --        --TargetFrameBuff1:SetPoint('TOPLEFT', TargetFrame, 'BOTTOMLEFT', 7, 32)
    --        --TargetFrameBuff6:ClearAllPoints()
    --        --TargetFrameBuff6:SetPoint('TOPLEFT', _G['TargetFrameBuff1'], 'BOTTOMLEFT', 0, -4)
    --        TargetFrameDebuff1:ClearAllPoints()
    --        TargetFrameDebuff1:SetPoint('TOPLEFT', _G['TargetFrameBuff'..anchor(b)], 'BOTTOMLEFT', 0, -4)
    --    else
    --        --TargetFrameBuff1:ClearAllPoints()
    --        --TargetFrameBuff1:SetPoint('BOTTOMLEFT', TargetFrame, 'TOPLEFT', 7, -20)
    --        --TargetFrameBuff6:ClearAllPoints()
    --        --TargetFrameBuff6:SetPoint('BOTTOMLEFT', _G['TargetFrameBuff1'], 'TOPLEFT', 0, 5)
    --        TargetFrameDebuff1:ClearAllPoints()
    --        TargetFrameDebuff1:SetPoint('BOTTOMLEFT', _G['TargetFrameBuff'..anchor(b)], 'TOPLEFT', 0, 5)
    --    end
    --else
    --    if  not var.auras then
    --        TargetFrameDebuff1:ClearAllPoints()
    --        TargetFrameDebuff1:SetPoint('TOPLEFT', TargetFrame, 'BOTTOMLEFT', 7, 32)
    --        --TargetFrameBuff1:ClearAllPoints()
    --        --TargetFrameBuff1:SetPoint('TOPLEFT', _G['TargetFrameDebuff'..anchor(d)], 'BOTTOMLEFT', 0, -4)
    --    else
    --        TargetFrameDebuff1:ClearAllPoints()
    --        TargetFrameDebuff1:SetPoint('BOTTOMLEFT', TargetFrame, 'TOPLEFT', 7, -20)
    --        --TargetFrameBuff1:ClearAllPoints()
    --        --TargetFrameBuff1:SetPoint('BOTTOMLEFT', _G['TargetFrameDebuff'..anchor(d)], 'TOPLEFT', 2, 5)
    --    end
    --end

	--local targetofTarget = TargetofTargetFrame:IsShown();
	--
	---- set the wrap point for the rows of de/buffs.
	--if ( targetofTarget ) then
	--	debuffWrap = 5;
	--else
	--	debuffWrap = 6;
	--end
	--
	---- and shrinks the debuffs if they begin to overlap the TargetFrame
	--if ( ( targetofTarget and ( numBuffs == 5 ) ) or ( numDebuffs >= debuffWrap ) ) then
	--	debuffSize = 14; 
	--	debuffFrameSize = 20;
	--else
	--	debuffSize = 18;
	--	debuffFrameSize = 24;
	--end
	
	
	-- resize Debuffs
	for i=1, 16 do
		button = _G["TargetFrameDebuff"..i]
		debuffFrame = _G["TargetFrameDebuff"..i.."Border"];
		if ( debuffFrame ) then
			debuffFrame:Hide();
			--debuffFrame:SetWidth(debuffSize);
			--debuffFrame:SetHeight(debuffSize);
		end
		button:SetWidth(debuffSize);
		button:SetHeight(debuffSize);

		-- FOR TESTING
		--button:Show();
		--_G['TargetFrameDebuff'..i..'Icon']:SetTexture("Interface\\Icons\\Ability_Gouge");
		--_G['TargetFrameDebuff'..i..'Icon']:SetTexCoord(.1, .9, .1, .9)
		--zSkin(button,0);
		--zSkinColor(button,1,0,0);
	end

	---- Reset anchors for debuff wrapping
	--_G["TargetFrameDebuff"..debuffWrap]:ClearAllPoints();
	--_G["TargetFrameDebuff"..debuffWrap]:SetPoint("LEFT", _G["TargetFrameDebuff"..(debuffWrap - 1)], "RIGHT", 4, 1);
	--_G["TargetFrameDebuff"..(debuffWrap + 1)]:ClearAllPoints();
	--_G["TargetFrameDebuff"..(debuffWrap + 1)]:SetPoint("TOPLEFT", "TargetFrameDebuff1", "BOTTOMLEFT", 1, -3);
	--_G["TargetFrameDebuff"..(debuffWrap + 2)]:ClearAllPoints();
	--_G["TargetFrameDebuff"..(debuffWrap + 2)]:SetPoint("LEFT", _G["TargetFrameDebuff"..(debuffWrap + 1)], "RIGHT", 4, 1);


end

hooksecurefunc("TargetDebuffButton_Update", AddAllTargetBuffs,true)

if (C.aura.timers == "1") then
	local f = CreateFrame('Frame', 'zTargetDebuffs')
	--f:RegisterEvent("PLAYER_ENTERING_WORLD");
	--f:RegisterEvent("PLAYER_AURAS_CHANGED");
	f:SetScript('OnUpdate',  function()
		for i = 1, 16 do
			local icon, stack, dtype = UnitDebuff('target', i)
			local bu = _G['TargetFrameDebuff'..i]
			if  bu and icon then
				--local count     = _G['TargetFrameDebuff'..i..'Count']
				--local border    = _G['TargetFrameDebuff'..i..'Border']
				--local colour    = DebuffTypeColor[dtype] or DebuffTypeColor['none']

				-----=={{ DEBUFF TIMER }}==----->	TODO: Fix text when theres count as well as timer on...
				bu.cd = bu.cd or CreateFrame("Model", nil, bu, "CooldownFrameTemplate")
				bu.cd.zCooldownType = "ALL"
				bu.cd.zTextSize = 12; -- TODO: make config for size
				local name, rank, texture, stacks, dtype, duration, timeleft = libdebuff:UnitDebuff("target", i)
				if duration and timeleft then
					bu.cd:SetAlpha(0)
					CooldownFrame_SetTimer(bu.cd, GetTime() + timeleft - duration, duration, 1)

					--if  stack > 1 then
					--	count:SetPoint("BOTTOMRIGHT", 0, -4);
					--	--textFrame.text:SetFont(STANDARD_TEXT_FONT, 22, "OUTLINE")
					--	count:SetFont("Fonts\\ARIALN.TTF", 10, "OUTLINE");
					--	count:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
					--end
				end
			end
		end
	end);
end
end)