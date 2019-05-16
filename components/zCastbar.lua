zUI:RegisterComponent("zCastbar", function ()
	--local font = C.castbar.use_unitfonts == "1" and zUI.font_unit or zUI.font_default
	--local font_size = C.castbar.use_unitfonts == "1" and C.global.font_unit_size or C.global.font_size
	local font = STANDARD_TEXT_FONT
	local font_size = "10"
	local default_border = C.appearance.border.default
	if C.appearance.border.unitframes ~= "-1" then
		default_border = C.appearance.border.unitframes
	end

	local function CreateCastbar(name, parent, unitstr, unitname)
		local cb = CreateFrame("Frame", name, parent or UIParent)

		--CreateBackdrop(cb, default_border)
		
		--cb:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
		--			edgeFile = "Interface/Tooltips/UI-Tooltip-Border", tile = true, 
		--			tileSize = 16, edgeSize = 8, insets = { left = 4, right = 4, top = 4, bottom = 4 }})
		zSkin(cb, 0); -- square
		zSkinColor(cb, 0.4, 0.4, 0.4);

		--cb:SetHeight(C.global.font_size * 1.5)
		cb:SetHeight(C.global.font_size + 2)
		--cb:SetHeight(C.global.font_size)
		cb:SetFrameStrata("MEDIUM")

		cb.unitstr = unitstr
		cb.unitname = unitname

		-- statusbar
		cb.bar = CreateFrame("StatusBar", nil, cb)

		if (C.castbar.flat_texture == "1") then
			--this.healthbar:SetStatusBarTexture(ZUI_FLAT_TEXTURE);
			cb.bar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8")
		else
			--this.healthbar:SetStatusBarTexture();
			cb.bar:SetStatusBarTexture(ZUI_ORIG_TEXTURE)
		end
		--C.castbar, "flat_texture"
		
		cb.bar:ClearAllPoints()
		cb.bar:SetAllPoints(cb)
		cb.bar:SetMinMaxValues(0, 100)
		cb.bar:SetValue(20)
		cb.bar:SetFrameStrata("LOW")
		--local r,g,b,a = strsplit(",", C.appearance.castbar.castbarcolor)
		--cb.bar:SetStatusBarColor(r,g,b,a)
		--cb.bar:SetStatusBarColor(1,0.4,0.1,.95) -- nice orange = 1,0.4,0.2,0.85,  blue = 0,0.56,1,.8
		cb.bar:SetStatusBarColor(1,1,0,1) -- yellow

		cb.bar.bg = cb.bar:CreateTexture(nil, "BACKGROUND")
		cb.bar.bg:SetTexture(0,0,0,.8)
		cb.bar.bg:ClearAllPoints()
		cb.bar.bg:SetAllPoints(cb)
		--cb.bar.bg:SetPoint("CENTER", cb.bar, "CENTER", 0, 0)
		--this.healthbar.bgtarget:SetWidth(this.healthbar:GetWidth() + 5)
		--this.healthbar.bgtarget:SetHeight(this.healthbar:GetHeight() + 5)

		-- text left
		cb.bar.left = cb.bar:CreateFontString("Status", "DIALOG", "GameFontNormal")
		cb.bar.left:ClearAllPoints()
		cb.bar.left:SetPoint("TOPLEFT", cb.bar, "TOPLEFT", 3, 0)
		cb.bar.left:SetPoint("BOTTOMRIGHT", cb.bar, "BOTTOMRIGHT", -3, 0)
		cb.bar.left:SetNonSpaceWrap(false)
		cb.bar.left:SetFontObject(GameFontNormal)
		cb.bar.left:SetTextColor(1,1,1,1)
		cb.bar.left:SetFont(font, font_size, "OUTLINE")
		cb.bar.left:SetText("left")
		cb.bar.left:SetJustifyH("left")

		-- text right
		cb.bar.right = cb.bar:CreateFontString("Status", "DIALOG", "GameFontNormal")
		cb.bar.right:ClearAllPoints()
		cb.bar.right:SetPoint("TOPLEFT", cb.bar, "TOPLEFT", 3, 0)
		cb.bar.right:SetPoint("BOTTOMRIGHT", cb.bar, "BOTTOMRIGHT", -3, 0)
		cb.bar.right:SetNonSpaceWrap(false)
		cb.bar.right:SetFontObject(GameFontNormal)
		cb.bar.right:SetTextColor(1,1,1,1)
		cb.bar.right:SetFont(font, font_size, "OUTLINE")
		cb.bar.right:SetText("right")
		cb.bar.right:SetJustifyH("right")

		cb:SetScript("OnUpdate", function()
			-- FOR MOVING HELP BOX
			--if this.drag and this.drag:IsShown() then
			--	this:SetAlpha(1)
			--	return
			--end

			if not UnitExists(this.unitstr) then
				this:SetAlpha(0)
			end

			if this.fadeout and this:GetAlpha() > 0 then
				if this:GetAlpha() == 0 then
					this.fadeout = nil
				end
				this:SetAlpha(this:GetAlpha()-0.05)
			end

			local name = this.unitstr and UnitName(this.unitstr) or this.unitname
			if not name then return end

			local cast, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(name)
			if not cast then
				-- scan for channel spells if no cast was found
				cast, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitChannelInfo(name)
			end

			if cast then
				local duration = endTime - startTime
				local max = duration / 1000
				local cur = GetTime() - startTime / 1000
				local channel = UnitChannelInfo(name)

				this:SetAlpha(1)

				if this.endTime ~= endTime then
					this.bar:SetStatusBarColor(strsplit(",", C.appearance.castbar[(channel and "channelcolor" or "castbarcolor")]))
					
					this.bar:SetMinMaxValues(0, duration / 1000)
					this.bar.left:SetText(cast)
					this.fadeout = nil
					this.endTime = endTime
				end

				if channel then
					cur = max + startTime/1000 - GetTime()
				end

				cur = cur > max and max or cur
				cur = cur < 0 and 0 or cur

				this.bar:SetValue(cur)

				if this.delay and this.delay > 0 then
					local delay = "|cffffaaaa" .. (channel and "-" or "+") .. round(this.delay,1) .. " |r "
					this.bar.right:SetText(delay .. string.format("%.1f",cur) .. " / " .. round(max,1))
				else
					this.bar.right:SetText(string.format("%.1f",cur) .. " / " .. round(max,1))
				end

				this.fadeout = nil
			else
				this.bar:SetMinMaxValues(1,100)
				this.bar:SetValue(100)
				this.fadeout = 1
				this.delay = 0
			end
		end)

		-- register for spell delay
		cb:RegisterEvent("SPELLCAST_DELAYED")  -- CASTBAR_EVENT_CAST_DELAY -- for tbc compat
		cb:RegisterEvent("SPELLCAST_CHANNEL_UPDATE") -- CASTBAR_EVENT_CHANNEL_DELAY -- for tbc compat
		cb:SetScript("OnEvent", function()

			if not UnitIsUnit(this.unitstr, "player") then return end

			if event == ("SPELLCAST_DELAYED") then	-- CASTBAR_EVENT_CAST_DELAY -- for tbc compat
				this.delay = ( this.delay or 0 ) + arg1/1000
			elseif event == ("SPELLCAST_CHANNEL_UPDATE") then	-- CASTBAR_EVENT_CHANNEL_DELAY -- for tbc compat
				this.delay = ( this.delay or 0 ) + this.bar:GetValue() - arg1/1000
			end
		end)

		cb:SetAlpha(0)
		return cb
	end

	zUI.castbar = CreateFrame("Frame", "zCastBar", UIParent)

	-- hide blizzard
	if C.castbar.player.hide_blizz == "1" then
		CastingBarFrame:UnregisterAllEvents()
		CastingBarFrame:Hide()
	end

	-- [[ zPlayerCastbar ]] --
	if C.castbar.player.hide_zUI == "0" then
		zUI.castbar.player = CreateCastbar("zPlayerCastbar", UIParent, "player")
		-- WIDTH player castbar
		local width = C.castbar.player.width ~= "-1" and C.castbar.player.width or 160
		
		if (C.castbar.player.above == "1") then
			-- Over 
			zUI.castbar.player:SetPoint('TOPLEFT', PlayerFrame, 60, 15)
		else
			-- Under
			zUI.castbar.player:SetPoint('BOTTOMLEFT', PlayerFrame, 60, -30);
		end

		zUI.castbar.player:SetWidth(width)
		
		if C.castbar.player.height ~= "-1" then
			zUI.castbar.player:SetHeight(C.castbar.player.height)
		end

		UpdateMovable(zUI.castbar.player)
	end

	-- [[ zTargetCastbar ]] --
	if C.castbar.target.hide_zUI == "0" then
		zUI.castbar.target = CreateCastbar("zTargetCastbar", UIParent, "target")

		-- WIDTH target castbar
		local width = C.castbar.target.width ~= "-1" and C.castbar.target.width or 160
		-- TODO: make cast bar movable and user placed
	
		if (C.castbar.target.above == "1") then
			-- Over 
			zUI.castbar.target:SetPoint('TOPRIGHT', TargetFrame, -60, 15)
		else
			-- Under
			zUI.castbar.target:SetPoint('BOTTOMRIGHT', TargetFrame, -60, -30);
		end
		
		zUI.castbar.target:SetWidth(width)

		if C.castbar.target.height ~= "-1" then
			zUI.castbar.target:SetHeight(C.castbar.target.height)
		end

		UpdateMovable(zUI.castbar.target)
	end
end)
