zUI:RegisterSkin("Bag", function () --modui inspired
	
	local orig = {}

	zStyle_Button(MainMenuBarBackpackButton)
    zStyle_ButtonElements(MainMenuBarBackpackButton)

    for i = 0, 3 do
        local bu = _G['CharacterBag'..i..'Slot']
        zStyle_Button(bu)
        zStyle_ButtonElements(bu)
    end

    for i = 1, 12 do                    -- BAG
        for k = 1, MAX_CONTAINER_ITEMS do
            local bu = _G['ContainerFrame'..i..'Item'..k]
            local cd = _G['ContainerFrame'..i..'Item'..k..'Cooldown']
			cd.zCooldownType = "NOGCD"
            zStyle_Items(bu)
			zStyle_ButtonElements(bu)
			--zSkinColor(bu,1,0,0,1); --Color in zBag script instead.
            --cd:SetFrameLevel(bu:GetFrameLevel() + 1) 
            cd:SetFrameStrata'HIGH'
        end
    end

	local modBag = function()
        for i = 1, 12 do
            local f = _G['ContainerFrame'..i]
            local id = f:GetID()
            local name = f:GetName()
            for i = 1, MAX_CONTAINER_ITEMS do
                local bu = _G[name..'Item'..i]
                local link = GetContainerItemLink(id, bu:GetID())
                zSkinColor(bu, .3, .3, .3)
                if bu and bu:IsShown() and link then
                    local _, _, istring         = string.find(link, '|H(.+)|h')
                    local n, _, q, _, _, type   = GetItemInfo(istring)
                    if n and strfind(n, 'Mark of Honor') then
                        zSkinColor(bu, .98, .95, .0)
                    elseif  type == 'Quest' then
                        zSkinColor(bu, 1, .33, .0)
                    elseif q and q > 1 then
                    	local r, g, b = GetItemQualityColor(q)
                    	zSkinColor(bu, r, g, b)
                    end
                end
            end
        end
    end

	local f = CreateFrame("Frame");
	f:RegisterEvent("BAG_UPDATE");
	f:SetScript("OnEvent", modBag);

	hooksecurefunc("ContainerFrame_OnShow", modBag, true);

	---------------------==[[ PAPERDOLL ]]==---------------------------->
	local items = {                 
    	[0] = 'Ammo', 'Head', 'Neck', 'Shoulder',
    	'Shirt', 'Chest', 'Waist', 'Legs', 'Feet',
    	'Wrist', 'Hands', 'Finger0', 'Finger1',
    	'Trinket0', 'Trinket1',
    	'Back', 'MainHand', 'SecondaryHand', 'Ranged', 'Tabard',}
    for i,v in pairs(items) do
        local bu =  _G['Character'..v..'Slot']
        zSkin(bu, 1)
        zSkinColor(bu, .3, .3, .3)
        bu:SetNormalTexture''
    end

    local modpD = function()
        for i,v in pairs(items) do
            local bu =  _G['Character'..v..'Slot']
            local q = GetInventoryItemQuality('player', i)
            if q and q > 1 then
                local r, g, b = GetItemQualityColor(q)
                zSkinColor(bu, r, g, b)
            else
                zSkinColor(bu, .3, .3, .3)
            end
        end
    end

    local pD = CreateFrame'Frame'
    pD:SetParent(CharacterFrame)
    pD:SetScript('OnShow', modpD)
    pD:SetScript('OnEvent', modpD)
    pD:RegisterEvent'UNIT_INVENTORY_CHANGED'

	---------------------==[[ Inspect ]]==---------------------------->
	

    local items = {
    	'Head', 'Neck', 'Shoulder',
    	'Shirt', 'Chest', 'Waist', 'Legs', 'Feet',
    	'Wrist', 'Hands', 'Finger0', 'Finger1',
    	'Trinket0', 'Trinket1',
    	'Back', 'MainHand', 'SecondaryHand', 'Ranged', 'Tabard',}

    local modI = function()
        for i, v in pairs(items) do
            local bu =  _G['Inspect'..v..'Slot']
            if bu then
                zSkin(bu, 1)
                zSkinColor(bu, .3, .3, .3)
                bu:SetNormalTexture''
            end
        end
    end

    local colourI = function()
        for i, v in pairs(items) do
            local bu =  _G['Inspect'..v..'Slot']
            local link = GetInventoryItemLink("target", i)
            zSkinColor(bu, .3, .3, .3)
            if link then
                local _, _, istring = string.find(link, '|H(.+)|h')
                local _, _, q = GetItemInfo(istring)
                if q and q > 1 then
                    local r, g, b = GetItemQualityColor(q)
                    zSkinColor(bu, r, g, b)
                else
                    zSkinColor(bu, .3, .3, .3)
                end
            end
        end
    end

    local mI = CreateFrame'Frame'
    mI:SetScript('OnEvent', function()
        if arg1 == 'Blizzard_InspectUI' then
            modI() colourI()
            orig.InspectPaperDollItemSlotButton_Update = InspectPaperDollItemSlotButton_Update
            function InspectPaperDollItemSlotButton_Update(button)
                orig.InspectPaperDollItemSlotButton_Update(button)
                colourI()
            end
        end
    end)
    mI:RegisterEvent'ADDON_LOADED'

	---------------------==[[ Bank ]]==---------------------------->
	--local orig = {}

    for i = 1, 28 do                    
        local bu = _G['BankFrameItem'..i]
        if bu then
            zSkin(bu, 1)
            zSkinColor(bu, .3, .3, .3)
        end
    end

    for i = 1, 7 do                     -- BANK BAG
        local bu = _G['BankFrameBag'..i]
        if bu then
            zSkin(bu, 1)
            zSkinColor(bu, .3, .3, .3)
        end
    end

    local modBank = function()
        for i = 1, 28 do
            local bu = _G['BankFrameItem'..i]
		    local link = GetContainerItemLink(-1, i)
            if bu then
            zSkinColor(bu, .3, .3, .3)
                if link then
                    local _, _, istring = string.find(link, '|H(.+)|h')
                    local _, _, q = GetItemInfo(istring)
                    if q and q > 1 then
                        local r, g, b = GetItemQualityColor(q)
                        zSkinColor(bu, r, g, b)
                    end
                end
            end
        end
    end

    local cF = CreateFrame'Frame'
    cF:SetParent(BankFrame)
    cF:SetScript('OnShow', modBank)
    cF:SetScript('OnEvent', modBank)
    cF:RegisterEvent'PLAYERBANKSLOTS_CHANGED'

	---------------------==[[ Auction ]]==---------------------------->
	local f = CreateFrame'Frame'
    f:RegisterEvent'ADDON_LOADED'
    f:SetScript('OnEvent', function()
        if event == 'Blizzard_AuctionUI' then
            -- browse buttons
            for i = 1, 8 do
                local bu = _G['BrowseButton'..i..'Item']
                local c  = _G['BrowseButton'..i..'Item'..'Count']
                zSkin(bu, 2)
                zSkinColor(bu, .7, .7, .7)
                bu:SetNormalTexture''
                c:SetDrawLayer'OVERLAY'
            end
            for i = 1, 9 do
                for _, v in pairs({_G['BidButton'..i..'Item'], _G['AuctionsButton'..i..'Item']}) do
                    zSkin(v, 2)
                    zSkinColor(v, .7, .7, .7)
                    v:SetNormalTexture''
                end
                for _, v in pairs({_G['BidButton'..i..'ItemCount'], _G['AuctionsButton'..i..'ItemCount']}) do
                    v:SetDrawLayer'OVERLAY'
                end
            end
            local bu = _G['AuctionsItemButton']
            local c  = _G['AuctionsItemButton'..'Count']
            zSkin(bu, 2)
            zSkinColor(bu, .7, .7, .7)
            c:SetDrawLayer'OVERLAY'
        end
    end)
	---------------------==[[ Aura ]]==---------------------------->
	--local orig = {}

    orig.BuffButton_Update           = BuffButton_Update
    orig.BuffButtons_UpdatePositions = BuffButtons_UpdatePositions

    for i = 0, 23 do                    -- AURA
        local bu = _G['BuffButton'..i]
        local ic = _G['BuffButton'..i..'Icon']
        local du = _G['BuffButton'..i..'Duration']
        bu:SetNormalTexture''
        ic:SetTexCoord(.1, .9, .1, .9)
        zSkin(bu, .25)
		if(C.global.darkmode == "1") then
			zSkinColor(bu, .7, .7, .7)
		--else
			--zSkinColor(bu, .7, .7, .7)
		end
        du:ClearAllPoints() du:SetPoint('CENTER', bu, 'BOTTOM', 2, -9)
    end

    for i = 1, 2 do
        local bu = _G['TempEnchant'..i]
        local ic = _G['TempEnchant'..i..'Icon']
        local bo = _G['TempEnchant'..i..'Border']
        local du = _G['TempEnchant'..i..'Duration']
        bu:SetNormalTexture''
        ic:SetTexCoord(.1, .9, .1, .9)
        bo:SetTexture''
        zSkin(bu, 1)
        zSkinColor(bu, 1, 0, 1)
        du:SetJustifyH'LEFT'
        du:ClearAllPoints() du:SetPoint('CENTER', bu, 'BOTTOM', 2, -9)
    end

    function BuffButton_Update()
        orig.BuffButton_Update()
        local name = this:GetName()
        local d = _G[name..'Border']
        if  d then
            local r, g, b = d:GetVertexColor()
            zSkinColor(this, r*1.5, g*1.5, b*1.5)
            d:SetAlpha(0)
        end
    end

    function BuffButtons_UpdatePositions()
        if SHOW_BUFF_DURATIONS == '1' then
            BuffButton8:SetPoint('TOP', TempEnchant1, 'BOTTOM', 0, -25)
            BuffButton16:SetPoint('TOPRIGHT', TemporaryEnchantFrame, "TOPRIGHT", 0, -120)
        else
            BuffButton8:SetPoint('TOP', TempEnchant1, 'BOTTOM', 0, -5)
            BuffButton16:SetPoint('TOPRIGHT', TemporaryEnchantFrame, 0, -70)
        end
    end

	---------------------==[[ Craft ]]==---------------------------->
	local f = CreateFrame'Frame'
    f:RegisterEvent'ADDON_LOADED'
    f:SetScript('OnEvent', function()
        if arg1 == 'Blizzard_TradeSkillUI' then
            local bu = _G['TradeSkillSkillIcon']

            _G['TradeSkillDetailHeaderLeft']:Hide()

            if  bu then
                zSkin(bu)
                zSkinColor(bu, .7, .7, .7)
            end

            for i = 1, MAX_TRADE_SKILL_REAGENTS do
                local r  = _G['TradeSkillReagent'..i]
	            local ri = _G['TradeSkillReagent'..i..'IconTexture']
                local rc = _G['TradeSkillReagent'..i..'Count']

                if r then
                    if not ri.f then -- new frame for us to reparent to
				        ri.f = CreateFrame('Frame', nil, r)
				        ri.f:SetFrameLevel(r:GetFrameLevel() + 1)
				        ri.f:SetPoint('TOPLEFT', ri)
				        ri.f:SetPoint('BOTTOMRIGHT', ri)
                        ri.f:EnableMouse(false)
                        zSkin(ri.f)
                        zSkinColor(ri.f, .7, .7, .7)
			        end

                    ri:SetParent(ri.f)
                    ri:SetPoint('TOPLEFT', r, 1, -1)
                    ri:SetPoint('BOTTOMRIGHT', r, -107, 1)
                    ri:SetDrawLayer'ARTWORK'

                    rc:SetParent(ri.f)
                    rc:SetDrawLayer'OVERLAY'
                end
            end
        elseif arg1 == 'Blizzard_CraftUI' then
            local bu = _G['CraftIcon']

            _G['CraftDetailHeaderLeft']:Hide()

            if bu then
                zSkin(bu, 1)
                zSkinColor(bu, .7, .7, .7)
            end

            for i = 1, MAX_CRAFT_REAGENTS do
                local r  = _G['CraftReagent'..i]
	            local ri = _G['CraftReagent'..i..'IconTexture']
                local rc = _G['CraftReagent'..i..'Count']

                if r then
                    if not ri.f then -- new frame for us to reparent to
				        ri.f = CreateFrame('Frame', nil, r)
				        ri.f:SetFrameLevel(r:GetFrameLevel() + 1)
				        ri.f:SetPoint('TOPLEFT', ri)
				        ri.f:SetPoint('BOTTOMRIGHT', ri)
                        ri.f:EnableMouse(false)
                        zSkin(ri.f, 2)
                        zSkinColor(ri.f, .3, .3, .3)
			        end

                    ri:SetParent(ri.f)
                    ri:SetPoint('TOPLEFT', r, 1, -1)
                    ri:SetPoint('BOTTOMRIGHT', r, -107, 1)
                    ri:SetDrawLayer'ARTWORK'

                    rc:SetParent(ri.f)
                    rc:SetDrawLayer'OVERLAY'
                end
            end
        end
    end)

	---------------------==[[ Macro ]]==---------------------------->
	local f = CreateFrame'Frame'
    f:RegisterEvent'ADDON_LOADED'
    f:SetScript('OnEvent', function()
        if arg1 == 'Blizzard_MacroUI' then
            for i = 1, 18 do
                local bu = _G['MacroButton'..i]
                local ic = _G['MacroButton'..i..'Icon']
                local _, slot = bu:GetRegions()
                zSkin(bu)
                zSkinColor(bu, .7, .7, .7)
                ic:SetTexCoord(.1, .9, .1, .9)
                slot:SetWidth(60) slot:SetHeight(60)
            end

            local bu = _G['MacroFrameSelectedMacroButton']
            local ic = _G['MacroFrameSelectedMacroButtonIcon']
            local bg = _G['MacroFrameSelectedMacroBackground']
            if  bu then
                local _, slot = bu:GetRegions()
                zSkin(bu, -.5)
                zSkinColor(bu, .7, .7, .7)
                ic:SetTexCoord(.1, .9, .1, .9)
                slot:SetWidth(60) slot:SetHeight(60)
                bg:SetAlpha(0)
            end

            for i = 1, 20 do
                local bu = _G['MacroPopupButton'..i]
                local ic = _G['MacroPopupButton'..i..'Icon']
                if bu then
                    local _, slot = bu:GetRegions()
                    zSkin(bu, -.5)
                    zSkinColor(bu, .7, .7, .7)
                    ic:SetTexCoord(.1, .9, .1, .9)
                    slot:SetWidth(60) slot:SetHeight(60)
                    bg:SetAlpha(0)
                end
            end
            this:UnregisterEvent(event)
        end
    end)
	
	---------------------==[[ Mail ]]==---------------------------->
	local slot = SendMailPackageButton:GetRegions()
    slot:ClearAllPoints()
    slot:SetPoint('TOPLEFT', SendMailPackageButton)
    slot:SetPoint('BOTTOMRIGHT', SendMailPackageButton)

    zSkin(SendMailPackageButton, 1)
    zSkinColor(SendMailPackageButton, .7, .7, .7)

    zSkin(OpenMailMoneyButton, 1)
    zSkinColor(OpenMailMoneyButton, .7, .7, .7)

    zSkin(OpenMailPackageButton, 1)
    zSkinColor(OpenMailPackageButton, .7, .7, .7)

    for i = 1, 7 do
        local bu = _G['MailItem'..i]
        local tx = _G['MailItem'..i..'ButtonIcon']
        local ic = bu:GetRegions()
        if  bu then
            local f = CreateFrame('Frame', nil, bu)
            f:SetPoint('TOPLEFT', ic, 0, 0) f:SetPoint('BOTTOMRIGHT', ic, 0, 6)
            zSkin(f, 1)
            zSkinColor(f, .7, .7, .7)
            tx:SetPoint('TOPLEFT', f)
            tx:SetPoint('BOTTOMRIGHT', f)
        end
    end
	
	---------------------==[[ Merchant ]]==---------------------------->
	for i = 1, 12 do                            -- ITEMS
        local bu   = _G['MerchantItem'..i..'ItemButton']
        local slot = _G['MerchantItem'..i..'SlotTexture']
        if bu then
            zSkin(bu, 1)
            zSkinColor(bu, .7, .7, .7)
            slot:Hide()
        end
    end

    local r  = _G['MerchantRepairItemButton']   -- REPAIR
    if r then
        zSkin(r, 1)
        zSkinColor(r, .7, .7, .7)
    end

    local a  = _G['MerchantRepairAllButton']
    if a then
        zSkin(a, 1)
        zSkinColor(a, .7, .7, .7)
    end

	---------------------==[[ Spellbook ]]==---------------------------->
	for i = 1, 4 do
        local bu = _G['SpellBookSkillLineTab'..i]
        if bu then
            zSkin(bu)
            zSkinColor(bu, .7, .7, .7)
            SkinDraw(bu, 'OVERLAY')

        end
    end

    for i = 1, 12 do
        local bu = _G['SpellButton'..i]
        local ic = _G['SpellButton'..i..'IconTexture']
        if bu then
            zSkin(bu)
            zSkinColor(bu, .7, .7, .7)
            SkinDraw(bu, 'OVERLAY')
            ic:SetTexCoord(.1, .9, .1, .9)
        end
    end

	---------------------==[[ Talents ]]==---------------------------->
	--local orig = {}

    local f = CreateFrame'Frame'
    f:RegisterEvent'ADDON_LOADED'
    f:SetScript('OnEvent', function()
        if arg1 == 'Blizzard_TalentUI' then
            orig.TalentFrame_Update = TalentFrame_Update

            for i = 1, 20 do
                local bu = _G['TalentFrameTalent'..i]
                local sl = _G['TalentFrameTalent'..i..'Slot']
                local rb = _G['TalentFrameTalent'..i..'RankBorder']
                zSkin(bu, 1)
                zSkinColor(bu, .7, .7, .7)
                sl:SetAlpha(0)
                rb:SetPoint('TOP', bu, 'BOTTOM', 0, 8)
            end

            function TalentFrame_Update()
                orig.TalentFrame_Update()
                for i = 1, 20 do
                    local bu = _G['TalentFrameTalent'..i]
                    local sl = _G['TalentFrameTalent'..i..'Slot']
                    local r, g, b = sl:GetVertexColor()
                    if  decimal_round(r, 1) ~= .5 then
                        zSkinColor(bu, r, g, b)
                    else
                        zSkinColor(bu, .7, .7, .7)
                    end
                end
            end
        end
    end)

	---------------------==[[ Target ]]==---------------------------->
	for i = 1, 5 do
        local bu = _G['TargetFrameBuff'..i]
        zSkin(bu, 1)
		if(C.global.darkmode == "1") then
			zSkinColor(bu, .3, .3, .3)
		--else
			--zSkinColor(bu, .7, .7, .7)
		end
        --zSkinColor(bu, .3, .3, .3)
    end
	--
    --for i = 1, 16 do
    --    local bu = _G['TargetFrameDebuff'..i]
    --    zSkin(bu, 1)
    --    zSkinColor(bu, 1, 0, 0)
    --end

    --for i = 1, 4 do
    --    local bu = _G['TargetofTargetFrameDebuff'..i]
    --    zSkin(bu, 0)
    --    zSkinColor(bu, 1, 0, 0)
    --end

	-- TODO search for TargetofTargetFrameDebuff change distance from eachother...

	---------------------==[[ Trade ]]==---------------------------->
	local modI = function(bu)
        if not bu.skinned then
            zSkin(bu, 1)
            zSkinColor(bu, .7, .7, .7)
            bu.skinned = true
        end
    end

    local f = CreateFrame'Frame'
    f:SetScript('OnEvent', function()
        for i = 1, 7 do
            local p = _G['TradePlayerItem'..i..'ItemButton']
            local t = _G['TradeRecipientItem'..i..'ItemButton']
            modI(p) modI(t)
        end
    end)
    f:RegisterEvent'TRADE_SHOW' f:RegisterEvent'TRADE_UPDATE'

	---------------------==[[ Quest ]]==---------------------------->
	for i = 1, 10 do                            -- QUEST LOG
        local bu = _G['QuestLogItem'..i]
        local ic = _G['QuestLogItem'..i..'IconTexture']
        if bu then
            local f = CreateFrame('Frame', nil, bu)
            f:SetAllPoints(ic)
            zSkin(f, 1)
            zSkinColor(f, .7, .7, .7)
        end
    end

    for i = 1, 6 do                             -- QUEST DETAIL
        local bu = _G['QuestDetailItem'..i]
        local ic = _G['QuestDetailItem'..i..'IconTexture']
        if bu then
            local f = CreateFrame('Frame', nil, bu)
            f:SetAllPoints(ic)
            zSkin(f, 1)
            zSkinColor(f, .7, .7, .7)
        end
    end

    for i = 1, 6 do                             -- QUEST PROGRESS
        local bu = _G['QuestProgressItem'..i]
        local ic = _G['QuestProgressItem'..i..'IconTexture']
        if bu then
            local f = CreateFrame('Frame', nil, bu)
            f:SetAllPoints(ic)
            zSkin(f, 1)
            zSkinColor(f, .7, .7, .7)
        end
    end

    for i = 1, 6 do                             -- QUEST REWARD
        local bu = _G['QuestRewardItem'..i]
        local ic = _G['QuestRewardItem'..i..'IconTexture']
        if bu then
            local f = CreateFrame('Frame', nil, bu)
            f:SetAllPoints(ic)
            zSkin(f, 1)
            zSkinColor(f, .7, .7, .7)
        end
    end

    local sk  = _G['QuestInfoSkillPointFrame']  -- SKILL POINT
    local ski = _G['QuestInfoSkillPointFrameIconTexture']
    if sk then
        local f = CreateFrame('Frame', nil, sk)
        f:SetAllPoints(ski)
        zSkin(f, 1)
        zSkinColor(f, .7, .7, .7)
    end

    local sp  = _G['QuestInfoRewardSpell']     -- SPELL POINT
    local spi = _G['QuestInfoRewardSpellIconTexture']
    if sp then
    	local f = CreateFrame('Frame', nil, sp)
    	f:SetAllPoints(spi)
        zSkin(f, 1)
        zSkinColor(f, .7, .7, .7)
    end

    local t  = _G['QuestInfoTalentFrame']      -- TALENT POINT
    local ti = _G['QuestInfoTalentFrameIconTexture']
    if t then
        local f = CreateFrame('Frame', nil, t)
        f:SetAllPoints(ti)
        zSkin(f, 1)
        zSkinColor(f, .7, .7, .7)
    end
end)