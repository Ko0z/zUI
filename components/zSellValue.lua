-- Credits to Shagu, pfUI
zUI:RegisterComponent("zSellValue", function () 
	zUI.sellvalue = CreateFrame( "Frame" , "zGameTooltip", GameTooltip )

	zUI.sellvalue:SetScript("OnHide", function()
		GameTooltip.itemLink = nil
		GameTooltip.itemCount = nil
	end)

	zUI.sellvalue:SetScript("OnShow", function()
		if GameTooltip.itemLink then
			local _, _, itemID = string.find(GameTooltip.itemLink, "item:(%d+):%d+:%d+:%d+")
			local itemID = tonumber(itemID)
			local count = GameTooltip.itemCount or 1

			if zSellData[itemID] then
				local _, _, sell, buy = strfind(zSellData[itemID], "(.*),(.*)")
				sell = tonumber(sell)
				buy = tonumber(buy)

				if not MerchantFrame:IsShown() then
					if sell > 0 then SetTooltipMoney(GameTooltip, sell * count) end
				end

				if IsShiftKeyDown() or C.tooltip.vendor.showalways == "1" then
					GameTooltip:AddLine(" ")

					if count > 1 then
						GameTooltip:AddDoubleLine(T["Sell"] .. ":", CreateGoldString(sell) .. "|cff555555  //  " .. CreateGoldString(sell*count), 1, 1, 1);
					else
						GameTooltip:AddDoubleLine(T["Sell"] .. ":", CreateGoldString(sell * count), 1, 1, 1);
					end

					if count > 1 then
						GameTooltip:AddDoubleLine(T["Buy"] .. ":", CreateGoldString(buy) .. "|cff555555  //  " .. CreateGoldString(buy*count), 1, 1, 1);
					else
						GameTooltip:AddDoubleLine(T["Buy"] .. ":", CreateGoldString(buy), 1, 1, 1);
					end
				end
				GameTooltip:Show()
			end
		end
	end)

	local zHookSetBagItem = GameTooltip.SetBagItem
	function GameTooltip.SetBagItem(self, container, slot)
		GameTooltip.itemLink = GetContainerItemLink(container, slot)
		local _
		_, GameTooltip.itemCount = GetContainerItemInfo(container, slot)
		return zHookSetBagItem(self, container, slot)
	end

	local zHookSetQuestLogItem = GameTooltip.SetQuestLogItem
	function GameTooltip.SetQuestLogItem(self, itemType, index)
		GameTooltip.itemLink = GetQuestLogItemLink(itemType, index)
		if not GameTooltip.itemLink then return end
		return zHookSetQuestLogItem(self, itemType, index)
	end

	local zHookSetQuestItem = GameTooltip.SetQuestItem
	function GameTooltip.SetQuestItem(self, itemType, index)
		GameTooltip.itemLink = GetQuestItemLink(itemType, index)
		return zHookSetQuestItem(self, itemType, index)
	end

	local zHookSetLootItem = GameTooltip.SetLootItem
	function GameTooltip.SetLootItem(self, slot)
		GameTooltip.itemLink = GetLootSlotLink(slot)
		zHookSetLootItem(self, slot)
	end

	local zHookSetInboxItem = GameTooltip.SetInboxItem
	function GameTooltip.SetInboxItem(self, mailID, attachmentIndex)
		local itemName, itemTexture, inboxItemCount, inboxItemQuality = GetInboxItem(mailID)
		GameTooltip.itemLink = GetItemLinkByName(itemName)
		return zHookSetInboxItem(self, mailID, attachmentIndex)
	end

	local zHookSetInventoryItem = GameTooltip.SetInventoryItem
	function GameTooltip.SetInventoryItem(self, unit, slot)
		GameTooltip.itemLink = GetInventoryItemLink(unit, slot)
		return zHookSetInventoryItem(self, unit, slot)
	end

	local zHookSetLootRollItem = GameTooltip.SetLootRollItem
	function GameTooltip.SetLootRollItem(self, id)
		GameTooltip.itemLink = GetLootRollItemLink(id)
		return zHookSetLootRollItem(self, id)
	end

	local zHookSetLootRollItem = GameTooltip.SetLootRollItem
	function GameTooltip.SetLootRollItem(self, id)
		GameTooltip.itemLink = GetLootRollItemLink(id)
		return zHookSetLootRollItem(self, id)
	end

	local zHookSetMerchantItem = GameTooltip.SetMerchantItem
	function GameTooltip.SetMerchantItem(self, merchantIndex)
		GameTooltip.itemLink = GetMerchantItemLink(merchantIndex)
		return zHookSetMerchantItem(self, merchantIndex)
	end

	local zHookSetCraftItem = GameTooltip.SetCraftItem
	function GameTooltip.SetCraftItem(self, skill, slot)
		GameTooltip.itemLink = GetCraftReagentItemLink(skill, slot)
		return zHookSetCraftItem(self, skill, slot)
	end

	local zHookSetCraftSpell = GameTooltip.SetCraftSpell
	function GameTooltip.SetCraftSpell(self, slot)
		GameTooltip.itemLink = GetCraftItemLink(slot)
		return zHookSetCraftSpell(self, slot)
	end

	local zHookSetTradeSkillItem = GameTooltip.SetTradeSkillItem
	function GameTooltip.SetTradeSkillItem(self, skillIndex, reagentIndex)
		if reagentIndex then
			GameTooltip.itemLink = GetTradeSkillReagentItemLink(skillIndex, reagentIndex)
		else
			GameTooltip.itemLink = GetTradeSkillItemLink(skillIndex)
		end
		return zHookSetTradeSkillItem(self, skillIndex, reagentIndex)
	end

	local zHookSetAuctionSellItem = GameTooltip.SetAuctionSellItem
	function GameTooltip.SetAuctionSellItem(self)
		local itemName, _, itemCount = GetAuctionSellItemInfo()
		GameTooltip.itemCount = itemCount
		GameTooltip.itemLink = GetItemLinkByName(itemName)
		return zHookSetAuctionSellItem(self)
	end

	local zHookSetTradePlayerItem = GameTooltip.SetTradePlayerItem
	function GameTooltip.SetTradePlayerItem(self, index)
		GameTooltip.itemLink = GetTradePlayerItemLink(index)
		return zHookSetTradePlayerItem(self, index)
	end

	local zHookSetTradeTargetItem = GameTooltip.SetTradeTargetItem
	function GameTooltip.SetTradeTargetItem(self, index)
		GameTooltip.itemLink = GetTradeTargetItemLink(index)
		return zHookSetTradeTargetItem(self, index)
	end

end)