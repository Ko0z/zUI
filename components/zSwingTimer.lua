-- Credits to EinBaum, SP_SwingTimer
zUI:RegisterComponent("zSwingTimer", function ()

	local _, class = UnitClass("player")
	if (C.quality.swingtimer.disable == "0" and class == "WARRIOR" or class == "SHAMAN" or class == "PALADIN" or class == "HUNTER" or C.quality.swingtimer.enable_for_all == "1") then

	zUI.swingtimer = CreateFrame("Frame", "SP_ST_Frame", UIParent)
	--SP_ST_Frame:SetPoint("CENTER",200,10)
	SP_ST_Frame:SetPoint("CENTER",0,0)
	SP_ST_Frame:SetBackdrop({bgFile = "Interface/DialogFrame/UI-DialogBox-Background"})
	SP_ST_Frame:SetWidth(200);
	SP_ST_Frame:SetHeight(10);
	SP_ST_Frame:Hide();
	zSkin(SP_ST_Frame, 0);
	zSkinColor(SP_ST_Frame, 0.4, 0.4, 0.4);

	zUI.swingtimer.t = zUI.swingtimer:CreateTexture("SP_ST_FrameTime","ARTWORK")
	SP_ST_FrameTime:SetPoint("CENTER",0,0)
	SP_ST_FrameTime:SetWidth(200);
	SP_ST_FrameTime:SetHeight(10);
	--SP_ST_FrameTime:SetTexture("Interface\\Addons\\zUI\\img\\ActionBarArtSmallLeft")
	--zUI.zBars.ActionBarArtSmall.left:SetWidth(512);
	--zUI.zBars.ActionBarArtSmall.left:SetHeight(128);

	local defaults = {
		x = 0,
		y = -150,
		w = 200,
		h = 10,
		b = 2,
		a = 1,
		s = 1,
		style = 0
	}

	local combatSpells = {
		["Heroic Strike"] = 1,
		["Cleave"] = 1,
		["Slam"] = 1,
		["Raptor Strike"] = 1,
		["Maul"] = 1,
	}

	local combatStrings = {
		SPELLLOGSELFOTHER,			-- Your %s hits %s for %d.
		SPELLLOGCRITSELFOTHER,		-- Your %s crits %s for %d.
		SPELLDODGEDSELFOTHER,		-- Your %s was dodged by %s.
		SPELLPARRIEDSELFOTHER,		-- Your %s is parried by %s.
		SPELLMISSSELFOTHER,			-- Your %s missed %s.
		SPELLBLOCKEDSELFOTHER,		-- Your %s was blocked by %s.
		SPELLDEFLECTEDSELFOTHER,	-- Your %s was deflected by %s.
		SPELLEVADEDSELFOTHER,		-- Your %s was evaded by %s.
		SPELLIMMUNESELFOTHER,		-- Your %s failed. %s is immune.
		SPELLLOGABSORBSELFOTHER,	-- Your %s is absorbed by %s.
		SPELLREFLECTSELFOTHER,		-- Your %s is reflected back by %s.
		SPELLRESISTSELFOTHER		-- Your %s was resisted by %s.
	}
	for index in combatStrings do
		for _, pattern in {"%%s", "%%d"} do
			combatStrings[index] = gsub(combatStrings[index], pattern, "(.*)")
		end
	end

	local name = UnitName("player")
	local _, CLASS = UnitClass("player")
	local weapon = nil
	local combat = false
	local oldWpnSpd, currentWpnSpd = 0.0
	local r, g, b, a;
	st_timer = 0.0

	zUI.swingtimer:RegisterEvent("PLAYER_ENTERING_WORLD")
	zUI.swingtimer:RegisterEvent("PLAYER_REGEN_ENABLED")
	zUI.swingtimer:RegisterEvent("PLAYER_REGEN_DISABLED")
	zUI.swingtimer:RegisterEvent("UNIT_INVENTORY_CHANGED")
	zUI.swingtimer:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
	zUI.swingtimer:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
	zUI.swingtimer:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
	zUI.swingtimer:RegisterEvent("CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES")
	--zUI.swingtimer:RegisterEvent("CHAT_MSG_SPELL_BREAK_AURA")
	zUI.swingtimer:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")
	zUI.swingtimer:RegisterEvent("CHAT_MSG_SPELL_AURA_GONE_SELF")
	zUI.swingtimer:RegisterEvent("UNIT_AURA")

	--function zUI.swingtimer:zUI.swingtimer:UpdateDisplay()
	function zUI.swingtimer:UpdateDisplay()
		local style = SP_ST_GS["style"]
		if (st_timer <= 0) then
			if style == 2 or style == 4 or style == 6 then
				--nothing
			else
				SP_ST_FrameTime:Hide()
			end

			if (not combat) then
				SP_ST_Frame:Hide()
			end
		else
			SP_ST_FrameTime:Show()
			local width = SP_ST_GS["w"]
			local size = (st_timer / zUI.swingtimer:GetWeaponSpeed()) * width
			if style == 2 or style == 4 or style == 6 then
				size = width - size
			end
			if (size > width) then
				size = width
				SP_ST_FrameTime:SetTexture(1, 0.8, 0.8, 1)
				--SP_ST_FrameTime:SetTexture(0, 1, 0, 1)
				--
			else
				--SP_ST_FrameTime:SetTexture(1, 1, 1, 1)
				SP_ST_FrameTime:SetTexture(r, g, b, 1)
				--SP_ST_FrameTime:SetTexture(strsplit(",", C.quality.swingtimer.color));
				--this.healthbar.castbar:SetStatusBarColor(strsplit(",", C.nameplates.castbarcolor));
			end
			SP_ST_FrameTime:SetWidth(size)
		end
	end

	--local function TestShow()
	--	zUI.swingtimer:ResetTimer()
	--end

	function zUI.swingtimer:ResetTimer()
		st_timer = zUI.swingtimer:GetWeaponSpeed()
		SP_ST_Frame:Show()
	end

	function zUI.swingtimer:UpdateWeapon()
		weapon = GetInventoryItemLink("player", GetInventorySlotInfo("MainHandSlot"))
	end

	function zUI.swingtimer:ShouldResetTimer()
		local percentTime = st_timer / zUI.swingtimer:GetWeaponSpeed()
		--zPrint(tostring(percentTime))
		return (percentTime < 0.04)
	end

	function zUI.swingtimer:AuraResetTimer()
		currentWpnSpd = UnitAttackSpeed("player")
		if(currentWpnSpd ~= oldWpnSpd) then 
			if (st_timer > 0) then
				st_timer = st_timer - (oldWpnSpd - currentWpnSpd);
			end
			oldWpnSpd = currentWpnSpd
		end
	end

	function zUI.swingtimer:GetWeaponSpeed()
		--local speedMH, speedOH = UnitAttackSpeed("player")
		currentWpnSpd = UnitAttackSpeed("player")
		if(currentWpnSpd ~= oldWpnSpd) then 
			oldWpnSpd = currentWpnSpd
		end
		return currentWpnSpd
	end

	function zUI.swingtimer:UpdateAppearance()
		SP_ST_Frame:ClearAllPoints()
		SP_ST_Frame:SetPoint("CENTER", "UIParent", "CENTER", SP_ST_GS["x"], SP_ST_GS["y"])

		SP_ST_FrameTime:ClearAllPoints()
		local style = SP_ST_GS["style"]
		if style == 1 or style == 2 then
			SP_ST_FrameTime:SetPoint("LEFT", "SP_ST_Frame", "LEFT")
		elseif style == 3 or style == 4 then
			SP_ST_FrameTime:SetPoint("RIGHT", "SP_ST_Frame", "RIGHT")
		else
			SP_ST_FrameTime:SetPoint("CENTER", "SP_ST_Frame", "CENTER")
		end

		SP_ST_Frame:SetWidth(SP_ST_GS["w"])
		SP_ST_Frame:SetHeight(SP_ST_GS["h"])
		SP_ST_FrameTime:SetWidth(SP_ST_GS["w"])
		SP_ST_FrameTime:SetHeight(SP_ST_GS["h"] - SP_ST_GS["b"])

		SP_ST_Frame:SetAlpha(SP_ST_GS["a"])
		SP_ST_Frame:SetScale(SP_ST_GS["s"])
	end

	function zUI.swingtimer:UpdateSettings()
		if not SP_ST_GS then SP_ST_GS = {} end
		for option, value in defaults do
			if SP_ST_GS[option] == nil then
				SP_ST_GS[option] = value
			end
		end
	end

	--local function zUI.swingtimer:SplitString(s,t)
	--	local l = {n=0}
	--	local f = function (s)
	--		l.n = l.n + 1
	--		l[l.n] = s
	--	end
	--	local p = "%s*(.-)%s*"..t.."%s*"
	--	s = string.gsub(s,"^%s+","")
	--	s = string.gsub(s,"%s+$","")
	--	s = string.gsub(s,p,f)
	--	l.n = l.n + 1
	--	l[l.n] = string.gsub(s,"(%s%s*)$","")
	--	return l
	--end

	zUI.swingtimer:SetScript("OnEvent", function()
		if (event == "PLAYER_REGEN_ENABLED") then
			combat = false
			zUI.swingtimer:UpdateDisplay()
		elseif (event == "PLAYER_ENTERING_WORLD") then
			zUI.swingtimer:UpdateSettings()
			zUI.swingtimer:UpdateWeapon()
			zUI.swingtimer:UpdateAppearance()
			zUI.swingtimer:UnregisterEvent("PLAYER_ENTERING_WORLD")
			r, g, b = strsplit(",", C.swingtimer.color)
		elseif (event == "PLAYER_REGEN_DISABLED") then
			combat = true
		elseif (event == "UNIT_INVENTORY_CHANGED") then
			if (arg1 == "player") then
				local oldWep = weapon
				zUI.swingtimer:UpdateWeapon()
				if (combat and oldWep ~= weapon) then
					zUI.swingtimer:ResetTimer()
				end
			end
		elseif (event == "CHAT_MSG_COMBAT_SELF_MISSES") then
			if (zUI.swingtimer:ShouldResetTimer()) then
				zUI.swingtimer:ResetTimer()
			end
		elseif (event == "CHAT_MSG_COMBAT_SELF_HITS") then
			if (string.find(arg1, "You hit") or string.find(arg1, "You crit")) then
				if (zUI.swingtimer:ShouldResetTimer()) then
					zUI.swingtimer:ResetTimer()
				end
			end
		elseif (event == "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS") then
			zUI.swingtimer:AuraResetTimer()
		elseif (event == "CHAT_MSG_SPELL_AURA_GONE_SELF") then
			zUI.swingtimer:AuraResetTimer()
		elseif (event == "CHAT_MSG_SPELL_SELF_DAMAGE") then
			for _, str in combatStrings do
				local _, _, spell = strfind(arg1, str)
				if spell and combatSpells[spell] then
					zUI.swingtimer:ResetTimer()
					break
				end
			end
		elseif (event == "CHAT_MSG_COMBAT_CREATURE_VS_SELF_MISSES") then
			if (string.find(arg1, ".* attacks. You parry.")) then

				local minimum = zUI.swingtimer:GetWeaponSpeed() * 0.20
				if (st_timer > minimum) then
					local reduct = zUI.swingtimer:GetWeaponSpeed() * 0.40
					local newTimer = st_timer - reduct
					if (newTimer < minimum) then
						st_timer = minimum
					else
						st_timer = newTimer
					end
				end
			end
		end
	end)

	zUI.swingtimer:SetScript("OnUpdate", function()
		if (st_timer > 0) then
			st_timer = st_timer - arg1
			if (st_timer < 0) then
				st_timer = 0
			end
		end
		zUI.swingtimer:UpdateDisplay()
	end)

	end
end)