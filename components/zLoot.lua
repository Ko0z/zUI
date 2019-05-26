-- Many credits to Shagu, pfUI
zUI:RegisterComponent("zLoot", function ()
	zUI.loot = CreateFrame("Frame", "zLootFrame", UIParent);
	zUI.loot:Hide();
	zUI.loot:SetFrameStrata("DIALOG");
	--zUI.loot:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp");
	zUI.loot:EnableMouse(true)
    zUI.loot:SetScript("OnMouseDown",function()
	--zUI.loot:SetScript("OnClick", function()
		-- nothing
	end)

	zUI.loot:RegisterEvent("LOOT_OPENED");
	zUI.loot:RegisterEvent("LOOT_CLOSED");
	zUI.loot:RegisterEvent("LOOT_SLOT_CLEARED");
	zUI.loot:RegisterEvent("OPEN_MASTER_LOOT_LIST");
	zUI.loot:RegisterEvent("UPDATE_MASTER_LOOT_LIST");
	zUI.loot:RegisterEvent("LOOT_BIND_CONFIRM");

	zUI.loot:SetWidth(160+C.appearance.border.default*2);

	zUI.loot.backdrop = zUI.loot:CreateTexture(nil, "BACKGROUND")
	zUI.loot.backdrop:SetTexture(0,0,0,.9)
	zUI.loot.backdrop:ClearAllPoints()
	zUI.loot.backdrop:SetAllPoints(zUI.loot)

	if (C.loot.mousecursor == "0") then
		zUI.loot:SetHeight(160+C.appearance.border.default*2);
		zUI.loot:SetPoint("TOP", UIParent, "CENTER", 0, 0);
		UpdateMovable(zUI.loot);
	end

	zUI.loot.unitbuttons = {
		["PF_BANKLOOTER"] = {T["Set Banker"],"bankLooter"},
		["PF_DISENCHANTLOOTER"] = {T["Set Disenchanter"],"disenchantLooter"},
	}
	zUI.loot.me = (UnitName("player"))
	zUI.loot.index_to_name = {}
	zUI.loot.name_to_index = {}
	zUI.loot.classes_in_raid = {}
	zUI.loot.players_in_class = {}
	zUI.loot.randoms = {}
	zUI.loot.rollers = {}
	zUI.loot.rollers_sorted = {}
	zUI.loot.info = {}
	local info = zUI.loot.info

	function zUI.loot.RaidRoll(candidates)
		if type(candidates) ~= "table" then return end
		local slot = zUI.loot.selectedSlot or 0
		local to = table.getn(candidates)
		if to >= 1 then
			local _,_,_,quality = GetLootSlotInfo(slot)
			if quality >= tonumber(C.loot.rollannouncequal) then
				SendChatMessageWide(T["Random Rolling"].." "..GetLootSlotLink(slot))
				if C.loot.rollannounce == "1" then
					local k,names = 1, ""
					for i=1,to do
						names = (k==1) and (i..":"..zUI.loot.index_to_name[candidates[i]]) or (names..", "..i..":"..zUI.loot.index_to_name[candidates[i]])
						-- fit the maximum names in a single 255 char message (15)
						if i == to or k == 15 then
							QueueFunction(SendChatMessageWide,names)
							names = ""
						end
						k = k<15 and k+1 or 1
					end
				end
			end
			zUI.loot:RegisterEvent("CHAT_MSG_SYSTEM")
			zUI.loot.randomRolling = true
			QueueFunction(RandomRoll,"1",tostring(to))
		end
	end

	function zUI.loot.RequestRolls()
		local slot = zUI.loot.selectedSlot or 0
		local rollers = wipe(zUI.loot.rollers)
		local rollers_sorted = wipe(zUI.loot.rollers_sorted)
		SendChatMessageWide(T["Roll for"].. " " .. GetLootSlotLink(slot))
		zUI.loot:RegisterEvent("CHAT_MSG_SYSTEM")
		zUI.loot.monitorRolling = true
		UIDropDownMenu_Refresh(GroupLootDropDown)
	end

	function zUI.loot:BuildSpecialRecipientsMenu(level)
		local slot = zUI.loot.selectedSlot or 0
		if level == 1 then
			if zUI.loot.my_index or zUI.loot.disenchanter_index or zUI.loot.banker_index then
				info = wipe(info)
				info.text = T["Special Recipient"]
				info.textR = NORMAL_FONT_COLOR.r
				info.textG = NORMAL_FONT_COLOR.g
				info.textB = NORMAL_FONT_COLOR.b
				info.textHeight = 12
				info.hasArrow = 1
				info.notCheckable = 1
				info.value = "PFRECIPIENTS"
				info.func = nil
				UIDropDownMenu_AddButton(info)
			end
		elseif level == 2 then
			if UIDROPDOWNMENU_MENU_VALUE == "PFRECIPIENTS" then
				if (zUI.loot.my_index) then
					info = wipe(info)
					info.text = T["Self"]
					info.textHeight = 12
					info.value = zUI.loot.my_index
					info.func = GroupLootDropDown_GiveLoot
					UIDropDownMenu_AddButton(info,UIDROPDOWNMENU_MENU_LEVEL)
				end
				if (zUI.loot.disenchanter_index) then
					info = wipe(info)
					info.text = T["Disenchanter"]
					info.textHeight = 12
					info.value = zUI.loot.disenchanter_index
					info.func = GroupLootDropDown_GiveLoot
					UIDropDownMenu_AddButton(info,UIDROPDOWNMENU_MENU_LEVEL)
				end
				if (zUI.loot.banker_index) then
					info = wipe(info)
					info.text = T["Banker"]
					info.textHeight = 12
					info.value = zUI.loot.banker_index
					info.func = GroupLootDropDown_GiveLoot
					UIDropDownMenu_AddButton(info,UIDROPDOWNMENU_MENU_LEVEL)
				end
			end
		end
	end

	function zUI.loot.ClearRolls()
		wipe(zUI.loot.rollers)
		wipe(zUI.loot.rollers_sorted)
		zUI.loot.monitorRolling = nil
		UIDropDownMenu_Refresh(GroupLootDropDown)
	end

	function zUI.loot.CallTieRoll(rollers)
		if type(rollers) ~= "table" then return end
		local highroll
		local ties = {}
		local num_rollers = table.getn(rollers)
		for i=1,num_rollers do
			if rollers[i].value ~= "disabled" then
				if highroll == nil then
					highroll = rollers[i].roll
					table.insert(ties,rollers[i])
				elseif rollers[i].roll == highroll then
					table.insert(ties,rollers[i])
				end
			end
		end
		local num_ties = table.getn(ties)
		if num_ties > 1 then
			local names = ""
			for i=1, num_ties do
				names = i==1 and (names..ties[i].who) or (names..", "..ties[i].who)
			end
			zUI.loot:ClearRolls()
			SendChatMessageWide(names.." "..T["Reroll"])
			zUI.loot:RegisterEvent("CHAT_MSG_SYSTEM")
			zUI.loot.monitorRolling = true
		end
		UIDropDownMenu_Refresh(GroupLootDropDown)
	end

	function zUI.loot:BuildSpecialRollsMenu(level)
		local slot = zUI.loot.selectedSlot or 0
		if level == 1 then
			info = wipe(info)
			info.text = T["Random"]
			info.textR = NORMAL_FONT_COLOR.r
			info.textG = NORMAL_FONT_COLOR.g
			info.textB = NORMAL_FONT_COLOR.b
			info.value = "PFRANDOM"
			info.textHeight = 12
			info.notCheckable = 1
			info.arg1 = zUI.loot.randoms
			info.func = zUI.loot.RaidRoll
			UIDropDownMenu_AddButton(info)

			info = wipe(info)
			info.text = T["Request Rolls"]
			info.textR = NORMAL_FONT_COLOR.r
			info.textG = NORMAL_FONT_COLOR.g
			info.textB = NORMAL_FONT_COLOR.b
			info.value = "PFROLLS"
			info.textHeight = 12
			info.hasArrow = 1
			info.notCheckable = 1
			info.func = zUI.loot.RequestRolls
			UIDropDownMenu_AddButton(info)
		elseif level == 2 then
			if UIDROPDOWNMENU_MENU_VALUE == "PFROLLS" then
				info = wipe(info)
				info.text = T["Clear Rolls"]
				info.textR = NORMAL_FONT_COLOR.r
				info.textG = NORMAL_FONT_COLOR.g
				info.textB = NORMAL_FONT_COLOR.b
				info.value = "PFCLEARROLLS"
				info.notCheckable = 1
				info.func = zUI.loot.ClearRolls
				UIDropDownMenu_AddButton(info,UIDROPDOWNMENU_MENU_LEVEL)

				info = wipe(info)
				info.text = T["Reroll Ties"]
				info.textR = NORMAL_FONT_COLOR.r
				info.textG = NORMAL_FONT_COLOR.g
				info.textB = NORMAL_FONT_COLOR.b
				info.value = "PFTIEROLL"
				info.notCheckable = 1
				info.arg1 = zUI.loot.rollers_sorted
				info.func = zUI.loot.CallTieRoll
				UIDropDownMenu_AddButton(info,UIDROPDOWNMENU_MENU_LEVEL)
				for _,roller in ipairs(zUI.loot.rollers_sorted) do
					info = wipe(info)
					info.text = string.format("%02d - %s",roller.roll,roller.who)
					info.textHeight = 12
					if roller.value == "disabled" then
						info.disabled = 1
						info.value = "disabled"
					else
						info.value = roller.value
						info.func = GroupLootDropDown_GiveLoot
					end
					info.notCheckable = 1
					UIDropDownMenu_AddButton(info,UIDROPDOWNMENU_MENU_LEVEL)
				end
			end
		end
	end

	function zUI.loot:BuildRaidMenu(level)
		local slot = zUI.loot.selectedSlot or 0
		local index_to_name = wipe(zUI.loot.index_to_name)
		local name_to_index = wipe(zUI.loot.name_to_index)
		local classes_in_raid = wipe(zUI.loot.classes_in_raid) -- [global class]=localized class for display
		local players_in_class = wipe(zUI.loot.players_in_class)
		local randoms = wipe(zUI.loot.randoms)
		zUI.loot.my_index = false
		zUI.loot.disenchanter_index = false
		zUI.loot.banker_index = false
		local disenchantLooter = zUI.loot.disenchantLooter or ""
		local bankLooter = zUI.loot.bankLooter or ""
		for i = 1, MAX_RAID_MEMBERS do -- masterlootcandidate index does not correspond with unit id index
			local candidate = GetMasterLootCandidate(i)
			if (candidate) then
				index_to_name[i] = candidate
				name_to_index[candidate] = i
				randoms[table.getn(randoms)+1]=i
				if candidate == zUI.loot.me then
					zUI.loot.my_index = i
				end
				if candidate == disenchantLooter then
					zUI.loot.disenchanter_index = i
				end
				if candidate == bankLooter then
					zUI.loot.banker_index = i
				end
				local unit = GroupInfoByName(candidate,"raid")
				classes_in_raid[unit.class] = unit.lclass
				if players_in_class[unit.class] == nil then players_in_class[unit.class] = {} end
				table.insert(players_in_class[unit.class],candidate)
			end
		end
		if level == 1 then -- classes
				info = wipe(info)
				info.text = GIVE_LOOT
				info.textHeight = 12
				info.notCheckable = 1
				info.isTitle = 1
				UIDropDownMenu_AddButton(info)
				zUI.loot:BuildSpecialRollsMenu(UIDROPDOWNMENU_MENU_LEVEL)
				zUI.loot:BuildSpecialRecipientsMenu(UIDROPDOWNMENU_MENU_LEVEL)
				for order, class in ipairs(CLASS_SORT_ORDER) do
					local lclass = classes_in_raid[class]
					if (lclass) then
						info = wipe(info)
						info.text = lclass
						info.textR = RAID_CLASS_COLORS[class].r
						info.textG = RAID_CLASS_COLORS[class].g
						info.textB = RAID_CLASS_COLORS[class].b
						info.textHeight = 12
						info.hasArrow = 1
						info.notCheckable = 1
						info.value = class
						info.func = nil
						UIDropDownMenu_AddButton(info)
					end
				end
		elseif level == 2 then -- players
			zUI.loot:BuildSpecialRollsMenu(UIDROPDOWNMENU_MENU_LEVEL)
			zUI.loot:BuildSpecialRecipientsMenu(UIDROPDOWNMENU_MENU_LEVEL)
			local players = players_in_class[UIDROPDOWNMENU_MENU_VALUE]
			if (players) and next(players) then
				table.sort(players)
				for _, candidate in ipairs(players) do
					info = wipe(info)
					info.text = candidate
					info.textR = RAID_CLASS_COLORS[UIDROPDOWNMENU_MENU_VALUE].r
					info.textG = RAID_CLASS_COLORS[UIDROPDOWNMENU_MENU_VALUE].g
					info.textB = RAID_CLASS_COLORS[UIDROPDOWNMENU_MENU_VALUE].b
					info.textHeight = 12
					info.value = name_to_index[candidate]
					info.func = GroupLootDropDown_GiveLoot
					UIDropDownMenu_AddButton(info,UIDROPDOWNMENU_MENU_LEVEL)
				end
			end
		end
	end

	function zUI.loot:BuildPartyMenu(level)
		local slot = zUI.loot.selectedSlot or 0
		if level == 1 then
			for i=1, MAX_PARTY_MEMBERS+1, 1 do
				local candidate = GetMasterLootCandidate(i)
				if (candidate) then
					info = wipe(info)
					local unit = GroupInfoByName(candidate,"party")
					info.text = candidate
					info.textR = RAID_CLASS_COLORS[unit.class].r
					info.textG = RAID_CLASS_COLORS[unit.class].g
					info.textB = RAID_CLASS_COLORS[unit.class].b
					info.textHeight = 12
					info.value = i
					info.func = GroupLootDropDown_GiveLoot
					UIDropDownMenu_AddButton(info)
				end
			end
		end
	end

	function zUI.loot:InitGroupDropDown()
		local inRaid = UnitInRaid("player")
		if UIDROPDOWNMENU_MENU_LEVEL == 1 then
			if ( inRaid ) then
			zUI.loot:BuildRaidMenu(UIDROPDOWNMENU_MENU_LEVEL)
			else
			zUI.loot:BuildPartyMenu(UIDROPDOWNMENU_MENU_LEVEL)
			end
		elseif UIDROPDOWNMENU_MENU_LEVEL == 2 and (inRaid) then
			zUI.loot:BuildRaidMenu(UIDROPDOWNMENU_MENU_LEVEL)
		end
	end

	function zUI.loot:AddMasterLootMenus()
		for index,value in ipairs(UnitPopupMenus["SELF"]) do
			if value == "LOOT_PROMOTE" then
				table.insert(UnitPopupMenus["SELF"],index+1,"PF_BANKLOOTER")
				table.insert(UnitPopupMenus["SELF"],index+1,"PF_DISENCHANTLOOTER")
			end
		end
		for index,value in ipairs(UnitPopupMenus["PARTY"]) do
			if value == "LOOT_PROMOTE" then
				table.insert(UnitPopupMenus["PARTY"],index+1,"PF_BANKLOOTER")
				table.insert(UnitPopupMenus["PARTY"],index+1,"PF_DISENCHANTLOOTER")
			end
		end
		for index,value in ipairs(UnitPopupMenus["PLAYER"]) do
			if value == "RAID_TARGET_ICON" then
				table.insert(UnitPopupMenus["PLAYER"],index+1,"PF_BANKLOOTER")
				table.insert(UnitPopupMenus["PLAYER"],index+1,"PF_DISENCHANTLOOTER")
			end
		end
		for index,value in ipairs(UnitPopupMenus["RAID"]) do
			if value == "RAID_REMOVE" then
				table.insert(UnitPopupMenus["RAID"],index+1,"PF_BANKLOOTER")
				table.insert(UnitPopupMenus["RAID"],index+1,"PF_DISENCHANTLOOTER")
			end
		end
	end

	function zUI.loot:RemoveMasterlootMenus()
		for index = table.getn(UnitPopupMenus["SELF"]),1,-1 do
			if UnitPopupMenus["SELF"][index] == "PF_BANKLOOTER" or UnitPopupMenus["SELF"][index] == "PF_DISENCHANTLOOTER" then
				table.remove(UnitPopupMenus["SELF"],index,value)
			end
		end
		for index = table.getn(UnitPopupMenus["PARTY"]),1,-1 do
			if UnitPopupMenus["PARTY"][index] == "PF_BANKLOOTER" or UnitPopupMenus["PARTY"][index] == "PF_DISENCHANTLOOTER" then
				table.remove(UnitPopupMenus["PARTY"],index,value)
			end
		end
		for index = table.getn(UnitPopupMenus["PLAYER"]),1,-1 do
			if UnitPopupMenus["PLAYER"][index] == "PF_BANKLOOTER" or UnitPopupMenus["PLAYER"][index] == "PF_DISENCHANTLOOTER" then
				table.remove(UnitPopupMenus["PLAYER"],index,value)
			end
		end
		for index = table.getn(UnitPopupMenus["RAID"]),1,-1 do
			if UnitPopupMenus["RAID"][index] == "PF_BANKLOOTER" or UnitPopupMenus["RAID"][index] == "PF_DISENCHANTLOOTER" then
				table.remove(UnitPopupMenus["RAID"],index,value)
			end
		end
	end

	if C.loot.advancedloot == "1" then
		UIDropDownMenu_Initialize(GroupLootDropDown, zUI.loot.InitGroupDropDown, "MENU")
		for button, data in pairs(zUI.loot.unitbuttons) do
			UnitPopupButtons[button] = { text = data[1], dist = 0}
		end
		zUI.loot:RemoveMasterlootMenus() -- remove then add to ensure no duplicate menus
		zUI.loot:AddMasterLootMenus()
		hooksecurefunc("UnitPopup_OnClick",function()
			local dropdownFrame = _G[UIDROPDOWNMENU_INIT_MENU]
			if not dropdownFrame then return end
			local button = this.value
			local unit = dropdownFrame.unit
			local name = dropdownFrame.name
			if button and zUI.loot.unitbuttons[button] then
				if name then
					-- resolves to zUI.loot.bankLooter|disenchantLooter = name
					zUI.loot[zUI.loot.unitbuttons[button][2]] = name
				end
			end
		end)
		hooksecurefunc("UnitPopup_HideButtons",function()
			local dropdownFrame = _G[UIDROPDOWNMENU_INIT_MENU]
			local unit = dropdownFrame.unit
			local name = dropdownFrame.name
			for index,value in pairs(UnitPopupMenus[dropdownFrame.which]) do
				if zUI.loot.unitbuttons[value] then
				  local method, lootmasterID = GetLootMethod()
				  if not ((method == "master" and lootmasterID == 0) or IsRaidLeader()) then
						UnitPopupShown[index] = 0
				  end
				  if (unit) and UnitIsPlayer(unit) and not (UnitInRaid(unit) or (UnitInParty(unit) and UnitExists("party1"))) then
						UnitPopupShown[index] = 0
				  end
				end
			end
		end,true)
	else
		zUI.loot:RemoveMasterlootMenus()
		UIDropDownMenu_Initialize(GroupLootDropDown, GroupLootDropDown_Initialize, "MENU")
	end

	----------------------------------==[[ ACTUAL LOOT FRAME ]]==---------------------------------------->
	zUI.loot.slots = {}
	function zUI.loot:UpdateLootFrame()
		if C.loot.mousecursor == "1" then
			zUI.loot:SetClampedToScreen(true)
		else
			zUI.loot:SetClampedToScreen(false)
		end
		local maxrarity, maxwidth = 0, 0

		--local items = GetNumLootItems()
		local items = zUI.loot.numLootItems
	
		if(items > 0) then
			local real = 0
			for i=1, items do
				local texture, item, quantity, quality = GetLootSlotInfo(i)
				if texture then real = real + 1 end
			end

			local slotid = 1
			--for id=0 ,GetNumLootItems() do
			for id=0 ,items do
				if GetLootSlotInfo(id) then
					local slot = zUI.loot.slots[slotid] or zUI.loot:CreateSlot(slotid)
					local texture, item, quantity, quality = GetLootSlotInfo(id)
					local color = ITEM_QUALITY_COLORS[quality]

					if(LootSlotIsCoin(id)) then
						item = string.gsub(string.gsub(item,"\n", ", "), ", $", "")
					end

					if(quantity > 1) then
						slot.count:SetText(quantity)
						slot.count:Show()
					else
						slot.count:Hide()
					end

					if(quality > 1) then
						--slot.rarity:SetVertexColor(color.r, color.g, color.b)
						--slot.ficon.backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
						zSkinColor(slot.ficon, color.r, color.g, color.b);
						zSkinColor(slot, color.r, color.g, color.b);
						--slot.rarity:Show()
					else
						--slot.ficon.backdrop:SetBackdropBorderColor(.3,.3,.3)
						zSkinColor(slot.ficon, 0.4, 0.4, 0.4);
						zSkinColor(slot, 0.4, 0.4, 0.4);
						--slot.rarity:Hide()
					end

					slot.quality = quality
					slot.name:SetText(item)
					slot.name:SetTextColor(color.r, color.g, color.b)
					slot.icon:SetTexture(texture)

					maxrarity = math.max(maxrarity, quality)
					maxwidth = math.max(maxwidth, slot.name:GetStringWidth())

					slot:SetID(id)
					if slot.SetSlot then
						slot:SetSlot(id)
					end

					slot:Enable()
					slot:Show()
					slotid = slotid + 1
				end

				--for i=real+1, GetNumLootItems() do
				for i=real+1, items do
					if zUI.loot.slots[i] then
						zUI.loot.slots[i]:Hide()
					end
				end
			end
			local color = ITEM_QUALITY_COLORS[maxrarity]
			zSkin(zUI.loot, 0); -- square
			if maxrarity <= 1 then
				zSkinColor(zUI.loot, 0.4, 0.4, 0.4);
			else
				--zSkinColor(zUI.loot, color.r-0.1, color.g-0.1, color.b-0.1);
				zSkinColor(zUI.loot, color.r, color.g, color.b);
			end
			zUI.loot:SetHeight(math.max((real*26)+2*C.appearance.border.default), 20)
			zUI.loot:SetWidth(maxwidth + 26 + 8*C.appearance.border.default )
		end
	end

	local function AutoBind(arg1)
		if GetNumPartyMembers() == 0 and GetNumRaidMembers() == 0 then
			local dialog = StaticPopup_FindVisible("LOOT_BIND",arg1)
			if dialog then
				_G[dialog:GetName().."Button1"]:Click()
			end
		end
	end

	function zUI.loot:CreateSlot(id)
		--local frame = CreateFrame(LOOT_BUTTON_FRAME_TYPE, 'zLootButton'..id, zUI.loot)
		local frame = CreateFrame("LootButton", 'zLootButton'..id, zUI.loot)
		frame:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
		frame:SetPoint("LEFT", C.appearance.border.default*2, 0)
		frame:SetPoint("RIGHT", -C.appearance.border.default*2, 0)
		--frame:SetHeight(22)
		frame:SetHeight(20)
		--frame:SetPoint("TOP", zUI.loot, "TOP", 4, (-C.appearance.border.default*2+22)-(id*22))
		frame:SetPoint("TOP", zUI.loot, "TOP", 4, (-C.appearance.border.default*2+26)-(id*26))

		zStyle_Button(frame, 0);
		--zSkin(zUI.loot, 0); -- square

		frame:SetScript("OnClick", function()
			if ( IsControlKeyDown() ) then
				DressUpItemLink(GetLootSlotLink(this:GetID()))
			elseif ( IsShiftKeyDown() ) then
				if ( ChatFrameEditBox:IsVisible() ) then
					ChatFrameEditBox:Insert(GetLootSlotLink(this:GetID()))
				end
			end

			StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")

			zUI.loot.selectedLootButton = this:GetName()
			zUI.loot.selectedSlot = this:GetID()
			zUI.loot.selectedQuality = this.quality
			zUI.loot.selectedItemName = this.name:GetText()
			LootFrame.selectedSlot = zUI.loot.selectedSlot
			LootFrame.selectedQuality = zUI.loot.selectedQuality
			LootFrame.selectedItemName = zUI.loot.selectedItemName

			LootSlot(this:GetID())
		end)

		frame:SetScript("OnEnter", function()
			if ( LootSlotIsItem(this:GetID()) ) then
				GameTooltip:SetOwner(this, "ANCHOR_RIGHT",10,-24)
				GameTooltip:SetLootItem(this:GetID())
				CursorUpdate()
			end
			if this.hover then
				this.hover:Show()
			end
		end)

		frame:SetScript("OnLeave", function()
			GameTooltip:Hide()
			ResetCursor()
			if this.hover then
				this.hover:Hide()
			end
		end)

		-- No need to run that code every frame..
		--if C.loot.autoresize == "1" then
		--	frame:SetScript("OnUpdate", function()
		--		zUI.loot:UpdateLootFrame()
		--	end)
		--end

		frame.ficon = CreateFrame("Frame", "zLootButtonIcon", frame)
		frame.ficon:SetHeight(frame:GetHeight() - 2*C.appearance.border.default + 6)
		frame.ficon:SetWidth(frame:GetHeight() - 2*C.appearance.border.default + 6)
		frame.ficon:ClearAllPoints()
		frame.ficon:SetPoint("RIGHT", frame)
		zSkin(frame.ficon, 0); -- square
		--CreateBackdrop(frame.ficon) -- TODO

		frame.icon = frame.ficon:CreateTexture(nil, "ARTWORK")
		frame.icon:SetTexCoord(.07, .93, .07, .93)
		frame.icon:SetAllPoints(frame.ficon)

		frame.count = frame.ficon:CreateFontString(nil, "OVERLAY")
		frame.count:ClearAllPoints()
		frame.count:SetJustifyH"RIGHT"
		frame.count:SetPoint("BOTTOMRIGHT", frame.ficon, 2, 2)
		--frame.count:SetFont(zUI.font_default, C.global.font_size, "OUTLINE")
		frame.count:SetFont(STANDARD_TEXT_FONT, C.global.font_size, "OUTLINE")
		frame.count:SetText(1)

		frame.name = frame:CreateFontString(nil, "OVERLAY")
		frame.name:SetJustifyH("LEFT")
		frame.name:ClearAllPoints()
		frame.name:SetAllPoints(frame)
		frame.name:SetNonSpaceWrap(true)
		--frame.name:SetFont(zUI.font_default, C.global.font_size, "OUTLINE")
		--frame.name:SetFont(STANDARD_TEXT_FONT, C.global.font_size, "OUTLINE")
		frame.name:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")

		--frame.rarity = frame:CreateTexture(nil, "ARTWORK")
		--frame.rarity:SetTexture"Interface\\AddOns\\zUI\\img\\bar"
		--frame.rarity:SetPoint("LEFT", frame.ficon, "RIGHT", 0, 0)
		--frame.rarity:SetPoint("RIGHT", frame)
		--frame.rarity:SetAlpha(.15)
		--frame.rarity:SetAllPoints(frame)

		frame.hover = frame:CreateTexture(nil, "ARTWORK")
		frame.hover:SetTexture"Interface\\AddOns\\zUI\\img\\bar"
		frame.hover:SetPoint("LEFT", frame.ficon, "RIGHT", 0, 0)
		frame.hover:SetPoint("RIGHT", frame)
		frame.hover:SetAlpha(.15)
		frame.hover:SetAllPoints(frame)
		frame.hover:Hide()

		zUI.loot.slots[id] = frame
		return frame
	end

	zUI.loot:SetScript("OnHide", function()
		StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
		CloseLoot()
	end)

	zUI.loot:SetScript("OnEvent", function()
		if event == "OPEN_MASTER_LOOT_LIST" then
			ToggleDropDownMenu(1, nil, GroupLootDropDown, zUI.loot.slots[zUI.loot.selectedSlot], 0, 0)
		end

		if event == "UPDATE_MASTER_LOOT_LIST" then
			UIDropDownMenu_Refresh(GroupLootDropDown)
		end

		if event == "LOOT_OPENED" then
			ShowUIPanel(this)

			if(not this:IsShown()) then
				CloseLoot(not autoLoot)
			end

			if C.loot.mousecursor == "1" then
				local x, y = GetCursorPosition()
				x = x / this:GetEffectiveScale()
				y = y / this:GetEffectiveScale()

				this:ClearAllPoints()
				this:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", x-40, y+20)
			end

			this.numLootItems = GetNumLootItems(); -- added
			--this.numLootToShow = this.numLootItems;
			zUI.loot:UpdateLootFrame()
		end

		if event == "LOOT_SLOT_CLEARED" then
			if (not this:IsVisible()) then return; end

			local numberz = GetNumLootItems();

			--zUI.loot.slots[arg1]:Hide() -- is it this thats causing problems?
			zUI.loot.slots[arg1]:Hide() -- is it this thats causing problems?
			--for _, v in pairs(this.slots) do
			--	v:Hide()
			--end

			--this.numLootToShow = this.numLootToShow - 1;

			if C.loot.autoresize == "1" then
				zUI.loot:UpdateLootFrame();
			end
		end

		if event == "LOOT_CLOSED" then
			StaticPopup_Hide("LOOT_BIND")
			HideUIPanel(this)
			if DropDownList1:IsShown() then CloseDropDownMenus() end
			for _, v in pairs(this.slots) do
				v:Hide()
			end
		end

		if event == "CHAT_MSG_SYSTEM" then
			-- random rolling, check for our own roll
			if zUI.loot.randomRolling ~= nil then
				local who, roll, from, to = cmatch(arg1, RANDOM_ROLL_RESULT)
				if (who) and  who == zUI.loot.me then
					local winner = tonumber(roll)
					GiveMasterLoot(zUI.loot.selectedSlot, zUI.loot.randoms[winner])
				end
				zUI.loot.randomRolling = nil
			end
			-- collecting rolls from raid, discard duplicates and 'cheating'
			if zUI.loot.monitorRolling ~= nil then
				local who, roll, from, to = cmatch(arg1, RANDOM_ROLL_RESULT)
				if (who) and not zUI.loot.rollers[who] then
					if tonumber(from)==1 and tonumber(to)==100 then
						if zUI.loot.name_to_index[who] ~= nil then
							zUI.loot.rollers[who] = {roll=tonumber(roll),value=zUI.loot.name_to_index[who]}
						else -- not an eligible candidate for that item
							zUI.loot.rollers[who] = {roll=tonumber(roll),value="disabled"}
						end
						zUI.loot.rollers_sorted[table.getn(zUI.loot.rollers_sorted)+1]={who=who,roll=tonumber(roll),value=zUI.loot.rollers[who].value}
					end
				end
				table.sort(zUI.loot.rollers_sorted,function(a,b)
					return a.roll > b.roll
				end)
				QueueFunction(UIDropDownMenu_Refresh,GroupLootDropDown)
			end
		end

		if C.loot.autopickup == "1" and event == "LOOT_BIND_CONFIRM" then
			QueueFunction(AutoBind,arg1)
		end
	end)

	-- Disable blizz loot frame
	LootFrame:UnregisterAllEvents()
	-- Hide loot frame on "Esc"
	table.insert(UISpecialFrames, "zLootFrame")

	function _G.GroupLootDropDown_GiveLoot()
		if ( zUI.loot.selectedQuality >= MASTER_LOOT_THREHOLD ) then
			local dialog = StaticPopup_Show("CONFIRM_LOOT_DISTRIBUTION", ITEM_QUALITY_COLORS[zUI.loot.selectedQuality].hex..zUI.loot.selectedItemName..FONT_COLOR_CODE_CLOSE, this:GetText())
			if ( dialog ) then
				dialog.data = this.value
			end
		else
			GiveMasterLoot(zUI.loot.selectedSlot, this.value)
		end
		CloseDropDownMenus()
	end

	StaticPopupDialogs["CONFIRM_LOOT_DISTRIBUTION"].OnAccept = function(data)
		GiveMasterLoot(zUI.loot.selectedSlot, data)
	end
end)