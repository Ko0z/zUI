zUI:RegisterComponent("zRoll", function ()
	local font = STANDARD_TEXT_FONT
	local font_size = C.global.font_size
	
	zUI.roll = CreateFrame("Frame", "zLootRoll", UIParent)
	zUI.roll.frames = {}

	zUI.roll.LOOT_ROLL_GREED = string.gsub(string.gsub(LOOT_ROLL_GREED, "%%s|Hitem:%%d:%%d:%%d:%%d|h%[%%s%]|h%%s", "(.+)"), "%%s", "(.+)")
	zUI.roll.LOOT_ROLL_NEED = string.gsub(string.gsub(LOOT_ROLL_NEED, "%%s|Hitem:%%d:%%d:%%d:%%d|h%[%%s%]|h%%s", "(.+)"), "%%s", "(.+)")
	zUI.roll.LOOT_ROLL_PASSED = string.gsub(string.gsub(LOOT_ROLL_PASSED, "%%s|Hitem:%%d:%%d:%%d:%%d|h%[%%s%]|h%%s", "(.+)"), "%%s", "(.+)")

	local _, _, everyone, _ = strfind(LOOT_ROLL_ALL_PASSED, zUI.roll.LOOT_ROLL_PASSED);
	zUI.roll.blacklist = { YOU, everyone }

	zUI.roll.cache = {}

	zUI.roll.scan = CreateFrame("Frame", "zLootRollMonitor", UIParent)
	zUI.roll.scan:RegisterEvent("CHAT_MSG_LOOT")
	zUI.roll.scan:SetScript("OnEvent", function()
		local _, _, player, item = strfind(arg1, zUI.roll.LOOT_ROLL_GREED);
		if player and item then
			zUI.roll:AddCache(item, player, "GREED")
			return
		end

		local _, _, player, item = strfind(arg1, zUI.roll.LOOT_ROLL_NEED);
		if player and item then
			zUI.roll:AddCache(item, player, "NEED")
			return
		end

		local _, _, player, item = strfind(arg1, zUI.roll.LOOT_ROLL_PASSED);
		if player and item then
			zUI.roll:AddCache(item, player, "PASS")
			return
		end
	end)

	function zUI.roll:AddCache(hyperlink, name, roll)
		-- skip invalid names
		for _, invalid in pairs(zUI.roll.blacklist) do
			if name == invalid then return end
		end

		local _, _, itemLink = string.find(hyperlink, "(item:%d+:%d+:%d+:%d+)");
		local itemName = GetItemInfo(itemLink)

		-- delete obsolete tables
		if zUI.roll.cache[itemName] and zUI.roll.cache[itemName]["TIMESTAMP"] < GetTime() - 60 then
			zUI.roll.cache[itemName] = nil
		end

		-- initialize itemtable
		if not zUI.roll.cache[itemName] then
			zUI.roll.cache[itemName] = { ["GREED"] = {}, ["NEED"] = {}, ["PASS"] = {}, ["TIMESTAMP"] = GetTime() }
		end

		-- ignore already listed names
		for _, existing in pairs(zUI.roll.cache[itemName][roll]) do
			if name == existing then return end
		end

		table.insert(zUI.roll.cache[itemName][roll], name)

		for id=1,4 do
			if zUI.roll.frames[id]:IsVisible() and zUI.roll.frames[id].itemname == itemName then
			local count_greed = zUI.roll.cache[itemName] and table.getn(zUI.roll.cache[itemName]["GREED"]) or 0
			local count_need  = zUI.roll.cache[itemName] and table.getn(zUI.roll.cache[itemName]["NEED"]) or 0
			local count_pass  = zUI.roll.cache[itemName] and table.getn(zUI.roll.cache[itemName]["PASS"]) or 0

			zUI.roll.frames[id].greed.count:SetText(count_greed > 0 and count_greed or "")
			zUI.roll.frames[id].need.count:SetText(count_need > 0 and count_need or "")
			zUI.roll.frames[id].pass.count:SetText(count_pass > 0 and count_pass or "")
			end
		end
	end

	function zUI.roll:CreateLootRoll(id)
		local size = 24
		local border = tonumber(C.appearance.border.default)
		local esize = size - border*2
		local f = CreateFrame("Frame", "zLootRollFrame" .. id, UIParent)

		--CreateBackdrop(f, nil, nil, .8) -- todo
		f.backdrop = f:CreateTexture(nil, "BACKGROUND")
		f.backdrop:SetTexture(0,0,0,.9)
		f.backdrop:ClearAllPoints()
		f.backdrop:SetAllPoints(f)

		zSkin(f, 0); -- square
		--zSkinColor(f, 0.4, 0.4, 0.4);

		--f.backdrop:SetFrameStrata("BACKGROUND")
		f.hasItem = 1

		f:SetWidth(350)
		f:SetHeight(size)

		f.icon = CreateFrame("Button", "zLootRollFrame" .. id .. "Icon", f)
		CreateBackdrop(f.icon, nil, true) -- todo
		
		f.icon:SetPoint("LEFT", border, 0)
		f.icon:SetWidth(esize)
		f.icon:SetHeight(esize)

		zStyle_Button(f.icon, -1);
		--zSkinColor(f.icon,0.2,0.2,0.2,1);

		f.icon.tex = f.icon:CreateTexture("OVERLAY")
		f.icon.tex:SetTexCoord(.08, .92, .08, .92)
		f.icon.tex:SetAllPoints(f.icon)

		f.icon:SetScript("OnEnter", function()
			GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
			GameTooltip:SetLootRollItem(this:GetParent().rollID)
			CursorUpdate()
		end)

		f.icon:SetScript("OnClick", function()
			if IsControlKeyDown() then
			DressUpItemLink(GetLootRollItemLink(this:GetParent().rollID))
			elseif IsShiftKeyDown() then
				if ChatFrameEditBox:IsVisible() then
					ChatFrameEditBox:Insert(GetLootRollItemLink(this:GetParent().rollID));
				end
			end
		end)

		f.need = CreateFrame("Button", "zLootRollFrame" .. id .. "Need", f)
		f.need:SetPoint("LEFT", f.icon, "RIGHT", border*3, -1)
		f.need:SetWidth(esize)
		f.need:SetHeight(esize)
		f.need:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Up")
		f.need:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Highlight")
		-- todo nice border around dice icon

		f.need.count = f.need:CreateFontString("NEED")
		f.need.count:SetPoint("CENTER", f.need, "CENTER", 0, 0)
		f.need.count:SetJustifyH("CENTER")
		f.need.count:SetFont(font, font_size, "OUTLINE")

		f.need:SetScript("OnClick", function()
			RollOnLoot(this:GetParent().rollID, 1)
		end)
		f.need:SetScript("OnEnter", function()
			GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
			GameTooltip:SetText("|cff33ffcc" .. NEED)
			if f.itemname and zUI.roll.cache[f.itemname] then
				for _, player in pairs(zUI.roll.cache[f.itemname]["NEED"]) do
					GameTooltip:AddLine(player)
				end
			end
			GameTooltip:Show()
		end)
		f.need:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)

		f.greed = CreateFrame("Button", "zLootRollFrame" .. id .. "Greed", f)
		f.greed:SetPoint("LEFT", f.icon, "RIGHT", border*5+esize, -2)
		f.greed:SetWidth(esize)
		f.greed:SetHeight(esize)
		f.greed:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Coin-Up")
		f.greed:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Coin-Highlight")
		-- todo nice border around greed coin icon
		f.greed.count = f.greed:CreateFontString("GREED")
		f.greed.count:SetPoint("CENTER", f.greed, "CENTER", 0, 1)
		f.greed.count:SetJustifyH("CENTER")
		f.greed.count:SetFont(font, font_size, "OUTLINE")

		f.greed:SetScript("OnClick", function()
			RollOnLoot(this:GetParent().rollID, 2)
		end)
		f.greed:SetScript("OnEnter", function()
			GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
			GameTooltip:SetText("|cff33ffcc" .. GREED)
			if f.itemname and zUI.roll.cache[f.itemname] then
				for _, player in pairs(zUI.roll.cache[f.itemname]["GREED"]) do
					GameTooltip:AddLine(player)
				end
			end
			GameTooltip:Show()
		end)
		f.greed:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)

		f.pass = CreateFrame("Button", "zLootRollFrame" .. id .. "Pass", f)
		f.pass:SetPoint("LEFT", f.icon, "RIGHT", border*7+esize*2, 0)
		f.pass:SetWidth(esize)
		f.pass:SetHeight(esize)
		f.pass:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
		f.pass:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Coin-Highlight")
		-- todo make nice border around pass button
		f.pass.count = f.pass:CreateFontString("PASS")
		f.pass.count:SetPoint("CENTER", f.pass, "CENTER", 0, -1)
		f.pass.count:SetJustifyH("CENTER")
		f.pass.count:SetFont(font, font_size, "OUTLINE")

		f.pass:SetScript("OnClick", function()
			RollOnLoot(this:GetParent().rollID, 0)
		end)
		f.pass:SetScript("OnEnter", function()
			GameTooltip:SetOwner(this, "ANCHOR_RIGHT")
			GameTooltip:SetText("|cff33ffcc" .. PASS)
			if f.itemname and zUI.roll.cache[f.itemname] then
				for _, player in pairs(zUI.roll.cache[f.itemname]["PASS"]) do
					GameTooltip:AddLine(player)
				end
			end
			GameTooltip:Show()
		end)
		f.pass:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)

		f.boe = CreateFrame("Frame", "zLootRollFrame" .. id .. "BOE", f)
		f.boe:SetPoint("LEFT", f.icon, "RIGHT", border*9+esize*3, 0)
		f.boe:SetWidth(esize*2)
		f.boe:SetHeight(esize)
		f.boe.text = f.boe:CreateFontString("BOE")
		f.boe.text:SetAllPoints(f.boe)
		f.boe.text:SetJustifyH("LEFT")
		f.boe.text:SetFont(font, font_size, "OUTLINE") 
		-- todo make nice border 
		f.name = CreateFrame("Frame", "zLootRollFrame" .. id .. "Name", f)
		--f.name:SetPoint("LEFT", f.icon, "RIGHT", border*11+esize*4, 0)
		f.name:SetPoint("LEFT", f.icon, "RIGHT", border*11+esize*4+11, 0)
		f.name:SetPoint("RIGHT", f, "RIGHT", border*2, 0)
		f.name:SetHeight(esize)
		f.name.text = f.name:CreateFontString("NAME")
		f.name.text:SetAllPoints(f.name)
		f.name.text:SetJustifyH("LEFT")
		f.name.text:SetFont(font, font_size, "OUTLINE") 

		f.time = CreateFrame("Frame", "zLootRollFrame" .. id .. "Time", f)
		f.time:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
		f.time:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 0, 0)
		f.time:SetFrameStrata("LOW")
		f.time.bar = CreateFrame("StatusBar", "zLootRollFrame" .. id .. "TimeBar", f.time)
		f.time.bar:SetAllPoints(f.time)
		f.time.bar:SetStatusBarTexture("Interface\\BUTTONS\\WHITE8X8") -- todo change image
		f.time.bar:SetMinMaxValues(0, 100)
		local r, g, b, a = strsplit(",", C.appearance.border.color)
		f.time.bar:SetStatusBarColor(r, g, b)
		f.time.bar:SetValue(20)
		f.time.bar:SetScript("OnUpdate", function()
			if not this:GetParent():GetParent().rollID then return end
			local left = GetLootRollTimeLeft(this:GetParent():GetParent().rollID)
			local min, max = this:GetMinMaxValues()
			if left < min or left > max then left = min end
			this:SetValue(left)
		end)

		return f
	end

  zUI.roll:RegisterEvent("CANCEL_LOOT_ROLL")
  zUI.roll:SetScript("OnEvent", function()
    for i=1,4 do
      if zUI.roll.frames[i].rollID == arg1 then
        zUI.roll.frames[i]:Hide()
      end
    end
  end)

  function _G.GroupLootFrame_OpenNewFrame(id, rollTime)
    -- clear cache if possible
    local visible = nil
    for i=1,4 do
      visible = visible or zUI.roll.frames[i]:IsVisible()
    end
    if not visible then zUI.roll.cache = {} end

    -- setup roll frames
    for i=1,4 do
      if not zUI.roll.frames[i]:IsVisible() then
        zUI.roll.frames[i].rollID = id
        zUI.roll.frames[i].rollTime = rollTime
        zUI.roll:UpdateLootRoll(i)
        return
      end
    end
  end

	function zUI.roll:UpdateLootRoll(id)
		local texture, name, count, quality, bop = GetLootRollItemInfo(zUI.roll.frames[id].rollID);
		local color = ITEM_QUALITY_COLORS[quality]

		zUI.roll.frames[id].itemname = name

		local count_greed = zUI.roll.cache[name] and table.getn(zUI.roll.cache[name]["GREED"]) or 0
		local count_need  = zUI.roll.cache[name] and table.getn(zUI.roll.cache[name]["NEED"]) or 0
		local count_pass  = zUI.roll.cache[name] and table.getn(zUI.roll.cache[name]["PASS"]) or 0

		zUI.roll.frames[id].greed.count:SetText(count_greed > 0 and count_greed or "")
		zUI.roll.frames[id].need.count:SetText(count_need > 0 and count_need or "")
		zUI.roll.frames[id].pass.count:SetText(count_pass > 0 and count_pass or "")

		zUI.roll.frames[id].name.text:SetText(name)
		zUI.roll.frames[id].name.text:SetTextColor(color.r, color.g, color.b, 1)
		zUI.roll.frames[id].icon.tex:SetTexture(texture)

		--zUI.roll.frames[id].backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
		zSkinColor(zUI.roll.frames[id], color.r, color.g, color.b);
		zSkinColor(zUI.roll.frames[id].icon, color.r, color.g, color.b,1);

		zUI.roll.frames[id].time.bar:SetMinMaxValues(0, zUI.roll.frames[id].rollTime)

		if C.loot.raritytimer == "1" then
			zUI.roll.frames[id].time.bar:SetStatusBarColor(color.r, color.g, color.b, 1) -- 0.7
		end

		if bop then
			--zUI.roll.frames[id].boe.text:SetText("BoP")
			--zUI.roll.frames[id].boe.text:SetText("|cffd00000BoP|r - ")
			zUI.roll.frames[id].boe.text:SetText("|cffbb0000BoP|r - ")
			--zUI.roll.frames[id].boe.text:SetTextColor(1,.3,.3,1)
		else
			--zUI.roll.frames[id].boe.text:SetText("BoE")
			zUI.roll.frames[id].boe.text:SetText("|cff4cff00BoE|r - ")
			--zUI.roll.frames[id].boe.text:SetTextColor(.3,1,.3,1)
		end

		zUI.roll.frames[id]:Show()
	end

	for i=1,4 do
		if not zUI.roll.frames[i] then
			zUI.roll.frames[i] = zUI.roll:CreateLootRoll(i)
			zUI.roll.frames[i]:SetPoint("CENTER", 0, -i*35)
			UpdateMovable(zUI.roll.frames[i])
			zUI.roll.frames[i]:Hide()
		end
	end
end)
