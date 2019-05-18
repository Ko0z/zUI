zUI:RegisterComponent("zCooldowns", function ()
	--[[
		basic.lua
			A featureless version of OmniCC,  
			Doesn't require saved variables or main.lua to function, but has no options
		
		To use it, change the file listings in !OmniCC.toc to only the name of this file.
		You can also remove the saved variables line.
	--]]
	
	--returns the formatted time with the appropiate scale and color
	--local function GetFormattedTime(secs)
	--	if secs >= 86400 then
	--		return floor(secs / 86400 + 0.5) .. "d", mod(secs, 86400)
	--	elseif secs >= 3600 then
	--		return floor(secs / 3600 + 0.5) .. "h", mod(secs, 3600)
	--	elseif secs >= 180 then
	--		return floor(secs / 60 + 0.5) .. "m", mod(secs, 60)
	--	elseif secs >= 60 then
	--		return format("%d:%02d", floor(secs / 60), mod(secs, 60)), secs - floor(secs)
	--	end
	--	return floor(secs + 0.5), secs - floor(secs)
	--end

	local function GetFormattedTime(secs)
		if secs >= 86400 then
			return floor(secs / 86400 + 0.5) .. "d", mod(secs, 86400)
		elseif secs >= 3600 then
			return floor(secs / 3600 + 0.5) .. "h", mod(secs, 3600)
		elseif secs >= 60 then
			return floor(secs / 60 + 0.5) .. "m", mod(secs, 60)
		--elseif secs >= 60 then
			--return format("%d:%02d", floor(secs / 60), mod(secs, 60)), secs - floor(secs)
		end
		return floor(secs + 0.5), secs - floor(secs)
	end

	--OnUpdate Function
	local function Text_OnUpdate()
		if this.timeToNextUpdate <= 0 or not this.icon:IsVisible() then
			local remain = this.duration - (GetTime() - this.start)

			if floor(remain + 0.5) > 0 and this.icon:IsVisible() then
				local text, toNextUpdate = GetFormattedTime(remain)
				this.text:SetText(text)
				this.timeToNextUpdate = toNextUpdate
			else
				this:Hide()
			end
		else
			this.timeToNextUpdate = this.timeToNextUpdate - arg1
		end
	end

	--Constructor
	local function CreateCooldownCount(cooldown, start, duration)
		local textFrame = CreateFrame("Frame", nil, cooldown:GetParent())
		cooldown.textFrame = textFrame
	
		textFrame:SetAllPoints(cooldown:GetParent())
		textFrame:SetFrameLevel(cooldown.textFrame:GetFrameLevel() + 2) --changed from +1
	
		textFrame.text = cooldown.textFrame:CreateFontString(nil, "OVERLAY")
		textFrame.text:SetFont(STANDARD_TEXT_FONT, 22, "OUTLINE")
		textFrame.text:SetTextColor(1, 1, 0.2)
		textFrame.text:SetPoint("CENTER", cooldown.textFrame, "CENTER", 0, -1)
	
		textFrame.icon = 
			--standard action button icon, $parentIcon
			getglobal(cooldown:GetParent():GetName() .. "Icon") or 
			--standard item button icon,  $parentIconTexture
			getglobal(cooldown:GetParent():GetName() .. "IconTexture") or 
			--discord action button, $parent_Icon
			getglobal(cooldown:GetParent():GetName() .. "_Icon")
	
		if textFrame.icon then
			textFrame:SetScript("OnUpdate", Text_OnUpdate)
		end	
		textFrame:Hide()
	
		return textFrame
	end

	--Function Hooks
	local function SetTimer(cooldownFrame, start, duration, enable)
		if start > 0 and duration > 3 and enable > 0 then
			local cooldownCount = cooldownFrame.textFrame or CreateCooldownCount(cooldownFrame, start, duration)	
			cooldownCount.start = start
			cooldownCount.duration = duration
			cooldownCount.timeToNextUpdate = 0
			cooldownCount:Show()
		elseif cooldownFrame.textFrame then
			cooldownFrame.textFrame:Hide()
		end
	end
	--hooksecurefunc("CooldownFrame_SetTimer", SetTimer);

	--------------------==[[ Newer ]]==-------------------->

	local function zCooldownOnUpdate()
		if not this:GetParent() then this:Hide()  end

		-- avoid to set cooldowns on invalid frames
		--if this:GetParent() and this:GetParent():GetName() and _G[this:GetParent():GetName() .. "Cooldown"] then
		--	if not _G[this:GetParent():GetName() .. "Cooldown"]:IsShown() then
		--		zPrint(this:GetParent():GetName() .. "Cooldown")
		--		--this:Hide()
		--	end
		--end

		if not this.next then this.next = GetTime() + .1 end
		if this.next > GetTime() then return end
		this.next = GetTime() + .1

		-- fix own alpha value (should be inherited, but somehow isn't always)
		this:SetAlpha(this:GetParent():GetAlpha())

		local remaining = this.duration - (GetTime() - this.start)
		if remaining >= 0 then
			this.text:SetText(GetColoredTimeString(remaining))
		else
			this:Hide()
		end
	end

	local function zCreateCoolDown(cooldown, start, duration, size)
		if (size == nil) then size = 14; end
		cooldown.cd = CreateFrame("Frame", "zCooldownFrame", cooldown:GetParent())
		--local parents = cooldown:GetParent()
		--zPrint("Parent: " .. parents:GetName())
		cooldown.cd:SetAllPoints(cooldown:GetParent())
		cooldown.cd:SetFrameLevel(cooldown:GetFrameLevel() + 2)

		cooldown.cd.text = cooldown.cd:CreateFontString("zCooldownFrameText", "OVERLAY")
		
		if (size > 12) then
			cooldown.cd.text:SetFont(STANDARD_TEXT_FONT, size, "OUTLINE")
		else
			cooldown.cd.text:SetFont("Fonts\\ARIALN.TTF", size, "OUTLINE")
		end
		cooldown.cd.text:SetPoint("CENTER", cooldown.cd, "CENTER", 0, 0)

		cooldown.cd:SetScript("OnUpdate", zCooldownOnUpdate)
	end

	-- hook
	hooksecurefunc("CooldownFrame_SetTimer", function(this, start, duration, enable)
		-- abort on unknown frames
		--if C.appearance.cd.foreign == "0" and not this.zCooldownType then
		--	return
		--end

		-- realign cooldown frames
		local parent = this.GetParent and this:GetParent()
		if parent and parent:GetWidth() / 36 > 0 then
			this:SetScale(parent:GetWidth() / 36)
			this:SetPoint("TOPLEFT", parent, "TOPLEFT", -1, 1)
			this:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 1, -1)
		end

		-- don't draw global cooldowns
		if this.zCooldownType == "NOGCD" and duration < tonumber(C.appearance.cd.threshold) then
			return
		end

		-- print time as text on cooldown frames
		if start > 0 and duration > 0 and enable > 0 then
			if( not this.cd ) then
				--if (this.zTextSize) then
				--zPrint(this:GetName());	
				zCreateCoolDown(this, start, duration, this.zTextSize);
				--else
				--	zCreateCoolDown(this, start, duration);
				--end
			end
			this.cd.start = start
			this.cd.duration = duration
			this.cd:Show()
		elseif(this.cd) then
			this.cd:Hide();
		end
	end)

end)
