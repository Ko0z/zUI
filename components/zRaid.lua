-- many Credits to Modernist, modUI
zUI:RegisterComponent("zRaid", function () 
-- these were originally based on luna's raidframes
-- credits to rhena, modernist

    --local sb = [[Interface\AddOns\modui\statusbar\texture\sb.tga]]

--local sb = "Interface\\TargetingFrame\\UI-StatusBar"

local sb = "Interface\\AddOns\\zUI\\img\\bar"
local bg = {bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],}
local f  = CreateFrame'Frame'
local xx = 4
local bu = {}
local a_offset, y_offset = 0, 0
local cursed = {}

local decurse = {
    ['MAGE']    = {'Remove Lesser Curse'},
    ['DRUID']   = {'Abolish Poison', 'Remove Curse'},
    --['DRUID']   = 'Remove Curse',
    ['PALADIN'] = {'Cleanse'},
    ['PRIEST']  = {'Abolish Disease', 'Dispel Magic'},
    --['PRIEST']  = {'Dispel Magic'},
    --['SHAMAN']  = 'Cleanse Toxins',
    --['SHAMAN']  = 'Cleane Spirit',
	['SHAMAN']  = {'Cure Poision', 'Cure Disease'}
    --['SHAMAN']  = {'Cure Disease'}
}

local roster = {
    [1] = {}, [2] = {}, [3] = {}, [4] = {},
    [5] = {}, [6] = {}, [7] = {}, [8] = {},
}

local showdebuffs = true                   -- TOGGLE DEBUFF ICONS
local left2right  = true                    -- SET GROWTH DIRECTION

local HealComm = nil;
if IsAddOnLoaded'HealComm' then HealComm = AceLibrary'HealComm-1.0' end -- if the user doesnt have mobhealth return.
	
local cache = function(num)
    if num < 1 then
        for i = 1,  8 do _G['modraid_grp'..i]:Hide() end
        for i = 1, 40 do _G['modraid'..i]:Hide() end
    elseif RAID_SUBGROUP_LISTS then
        for i = 1,  8 do roster[i] = {} end
        for i = 1,  8 do
            for j = 1, 5 do
                if RAID_SUBGROUP_LISTS[i][j] then
                    roster[i][j] = 'raid'..RAID_SUBGROUP_LISTS[i][j]
                else
                    roster[i][j] = nil
                end
			end
            table.sort(roster[i], function(a, b) return a < b end)
        end
    end
end

local format = function(index)
    for i = 1, 8 do
        local header = _G['modraid_grp'..i]
        if getn(roster[i]) > 0 then
            header:Show() header.text:SetText('[ '..i..' ]')
        else
            header:Hide()
        end
        for j, v in pairs(roster[i]) do
            local raid = bu[index]
            raid.unit = v
            if raid.unit then
                raid:Show()
            end
            index = index + 1
        end
    end
    for i = index, 40 do bu[index]:Hide() end
end

local arrange = function(index)
    for i = 1, 8 do
        local header = _G['modraid_grp'..i]
        for j = 1, getn(roster[i]) do
            local raid = bu[index]
            if j == 1 then
                raid:ClearAllPoints()
                raid:SetPoint('TOP', header, 'BOTTOM', 0, -10)
            else
                raid:ClearAllPoints()
                raid:SetPoint('TOP', bu[index - 1], 'BOTTOM', 0, -10)
            end
            index = index + 1
        end
    end
end

local rosterupdate = function()
    local index = 1
    cache(GetNumRaidMembers())
    format(index)
    arrange(index)
end

--local buffs = function(bu)
--    local v = PROCESSBUFFSgetBuffs(UnitName(bu.unit))[1]
--    if v and v.icon then
--        bu.aura:Show()
--        bu.aura.icon:SetTexture(v.icon)
--        zSkinColor(bu.aura, v.border.r, v.border.g, v.border.b)
--    else
--        bu.aura:Hide()
--        bu.aura.icon:SetTexture''
--    end
--end

local debuffs = function(arg1)
	-- nil	-	raid2

    if this.unit ~= arg1 or not this.unit then return end

	--button = button:GetName();
	--local debuff,  debuffType, debuffStack, debuffColor, unitStatus, statusColor;
	--local debuffTotal = 0;
	--this.hasDispellable = nil;
	--
	--for i=1, MAX_PARTY_DEBUFFS do
	--MAX_TARGET_DEBUFFS = 16

	--	local debuffBorder = getglobal(button.."Debuff"..i.."Border");
	--	local debuffIcon = getglobal(button.."Debuff"..i.."Icon");
	--
	--	if ( unit == "party"..i ) then
	--		unitStatus = getglobal(button.."Status");
	--	end
	--	if ( showBuffs == 1 ) then
	--		debuff = UnitBuff(unit, i, SHOW_CASTABLE_BUFFS);
	--		debuffBorder:Show();
	--	elseif ( showBuffs == 0 ) then
	--		debuff, debuffStack, debuffType = UnitDebuff(unit, i);
	--		debuffBorder:Show();
	--	else
	--		debuff, debuffStack, debuffType = UnitDebuff(unit, i, SHOW_DISPELLABLE_DEBUFFS);
	--		debuffBorder:Show();
	--	end
	--	
	--	if ( debuff ) then
	--		debuffIcon:SetTexture(debuff);
	--		if ( debuffType ) then
	--			debuffColor = DebuffTypeColor[debuffType];
	--			statusColor = DebuffTypeColor[debuffType];
	--			this.hasDispellable = 1;
	--			debuffTotal = debuffTotal + 1;
	--		else
	--			debuffColor = DebuffTypeColor["none"];
	--		end
	--		debuffBorder:SetVertexColor(debuffColor.r, debuffColor.g, debuffColor.b);
	--		getglobal(button.."Debuff"..i):Show();
	--	else
	--		getglobal(button.."Debuff"..i):Hide();
	--	end
	--end
	---- Reset unitStatus overlay graphic timer
	--if ( this.numDebuffs ) then
	--	if ( debuffTotal >= this.numDebuffs ) then
	--		this.debuffCountdown = 30;
	--	end
	--end
	--if ( unitStatus and statusColor ) then
	--	unitStatus:SetVertexColor(statusColor.r, statusColor.g, statusColor.b);
	--end

    local _, _, dtype = UnitDebuff(this.unit, 1, 1) -- only returns the ones that the player can dispel
    local lastfound = 1

    if dtype then
        local colour = DebuffTypeColor[dtype]
        zSkinColor(this, colour.r, colour.g, colour.b)
        tinsert(cursed, this.unit)
		--table.insert
    else
        zSkinColor(this, .1, .1, .1)
        if cursed[this.unit] then tremove(cursed, this.unit) end
    end

    for i = 1, 2 do
        local texture, _, dtype = UnitDebuff(this.unit, i)
        if  texture and showdebuffs then
            local colour = DebuffTypeColor[dtype] or DebuffTypeColor['none']
            this.debuffs[i]:SetTexture(texture)
            this.debuffs[i]:Show()
            this.debuffs[i].border:SetVertexColor(colour.r, colour.g, colour.b)
            this.debuffs[i].border:Show()
        else
            this.debuffs[i]:SetTexture''
            this.debuffs[i]:Hide()
            this.debuffs[i].border:Hide()
        end
    end
end

local Decurse = function(unit)
    local class  = UnitClass'player'

	--CastSpellByName("Remove Lesser Curse", unit);

    --local target
    ---- target player
    ---- castspellbyname
    ---- retarget og. target if exists
    --if  UnitExists'target' then
    --    target = UnitName'target'   -- might need to be id instead
    --end
	class = string.upper(class);
	for i, v in pairs(decurse) do
		if(i == class) then
			for j, k in pairs(decurse[i]) do
				CastSpellByName(k, unit);
			end
		end
		
		--if(v == class) then
		--	--CastSpellByName(class, unit)
		--end
	end

    --if decurse[class] then CastSpellByName(decurse[class], unit) end

    --if  target ~= nil then
    --    TargetUnitByName(target)  -- target by name?
    --    target  = nil
    --end
end

local raidicon = function(bu)
    bu.ric:Hide() bu.name:Show()
    --if bu.flag:IsShown() or bu.healv:IsShown() or bu.rez:IsShown() then bu.name:Hide() return end
    if UnitExists(bu.unit) then
        local i = GetRaidTargetIndex(bu.unit)
        if i then
            SetRaidTargetIconTexture(bu.ric, i)
            bu.ric:Show() --bu.name:Hide()
        end
    end
end

local range = function(bu, time, seen, r, g, b)
    if time and seen < 3 then
        bu.hp:SetStatusBarColor(r, g, b)
    else
        bu.hp:SetStatusBarColor(r*.375, g*.375, b*.375)
        bu.name:SetTextColor(1, .1, .1)
    end
end

local heals = function(bu)
    local name = UnitName(bu.unit)
    local heal = HealComm:getHeal(name)
    local rez  = HealComm:UnitisResurrecting(name)
    local v, max = UnitHealth(bu.unit), UnitHealthMax(bu.unit)
    local bu_w, bu_h = bu.hp:GetWidth(), bu.hp:GetHeight()
    local hp_w, hp_h = bu_w*(v/max), bu_h*(v/max)
    if rez then bu.rez:Show() else bu.rez:Hide() end
    if heal > 0 and v < max and not UnitIsDeadOrGhost(bu.unit) then
        local w = bu_w*(heal/max)
    	if (hp_w + w) > bu_w then w = bu_w - hp_w end
    	bu.heal:Show()
    	bu.heal:SetWidth(w)
    	bu.heal:SetHeight(bu_h)
    	bu.heal:ClearAllPoints()
    	bu.heal:SetPoint('TOPLEFT', bu.hp, hp_w, 0)
    else
        bu.heal:Hide()
    end
end

--local vheals = function(bu)
--    local v = PROCESSCASTINGgetHeal(UnitName(this.unit))
--    bu.healv:Hide()
--    if v then
--        if GetTime() < v.timeEnd then
--            local y = -4
--            if v.crit == 1 then
--                bu.healv:SetFont(STANDARD_TEXT_FONT, 16, 'MONOCHROMEOUTLINE')
--                y = 0
--            else
--                bu.healv:SetFont(STANDARD_TEXT_FONT, 12, 'MONOCHROMEOUTLINE')
--                y = y + v.y
--                if y + v.y < y + 8 then v.y = v.y + .5 end
--            end
--            bu.healv:SetPoint('CENTER', bu, -1, y)
--            if (v.timeEnd - GetTime()) < .6 then
--                bu.healv:SetAlpha(mod((v.timeEnd - GetTime()), 1))
--            else
--                bu.healv:SetAlpha(.6)
--            end
--            bu.healv:SetText('+ '..v.amount..(v.crit == 1 and '!' or ''))
--            bu.healv:Show()
--        end
--    end
--end

local status = function(bu)
    bu.name:SetShadowColor(0, 0, 0)
    if not UnitIsConnected(this.unit) then
        bu.hp:SetStatusBarColor(.7, .7, .7)
        bu.hp:SetMinMaxValues(0, 1)
        bu.hp:SetValue(1)
        bu.name:SetTextColor(.1, .1, .1)
    elseif UnitIsDead(this.unit) then
        bu.name:SetTextColor(1, 0, 0)
    elseif UnitIsGhost(this.unit) then
        bu.name:SetShadowColor(.15, .15, .15)
        bu.name:SetTextColor(.5, .5, .5)
    else
        local _, class = UnitClass(this.unit)
        local colour   = class and RAID_CLASS_COLORS[class] or {r = .2, g = .2, b = .2}
        bu.name:SetTextColor(colour.r, colour.g, colour.b)
    end

	--bu.name:SetTextColor(1, 1, 1)
	--bu.name:SetText("HALLLLO")
end

local GetRange = function(unit)
	--assert(unit, "No unit passed")
	if(not unit) then 

	elseif CheckInteractDistance(unit, 4) then
		return GetTime()
	end
end

local raidupdate = function()
    if this:IsShown() then
        if not UnitExists(this.unit) then this:Hide() return end
        --local grid           = _G['modui_vars'].db['modGridSize']
        --local grid           = 1
        local now            = GetTime()
        local hp, mana, name = this.hp, this.mana, this.name
        local power          = UnitPowerType(this.unit)
        --local _, time        = f.proximity:GetUnitRange(this.unit)
		local time			 = GetRange(this.unit)
        local seen           = now - (time or 100)
        local r, g, b        = name:GetTextColor()

        hp:SetMinMaxValues(0, UnitHealthMax(this.unit))
        hp:SetValue(UnitHealth(this.unit))

        mana:SetMinMaxValues(0, UnitManaMax(this.unit))
        mana:SetValue(UnitMana(this.unit))
        mana:SetStatusBarColor((power == 1 or power == 3) and 1 or 0,
                                power == 1 and 0 or power == 3 and 1 or 0,
                                power == 1 and 0 or power == 3 and 0 or 1)
		
        name:SetText(string.sub(UnitName(this.unit), 1, 6));
		--hp:Hide()

		--name:SetText("BULL")
		--name:Show()
        --buffs(this)
        raidicon(this)
        range(this, time, seen, r, g, b)
		if(HealComm ~= nil) then
			heals(this)
		end
        --vheals(this)
        status(this)

        if power ~= 0 and UnitMana(this.unit) < 1 then
            hp:SetPoint('BOTTOMRIGHT', this)
            mana:Hide()
        else
            hp:SetPoint('BOTTOMRIGHT', this, 0, 8)
            mana:Show()
        end
    end
end

-------------[[ Remove eye candy ]]----------------
local display = function(t, y, a)
    Minimap.raid:Show()
    local time = GetTime()
    if a + a_offset < a + .6 then
        a = a + a_offset
        a_offset = a_offset + .005
        Minimap.raid:SetAlpha(a)
    end
    if y + y_offset < y + 12 then
        y = y + y_offset
        y_offset = y_offset + 2
        Minimap.raid:SetPoint('TOP', Minimap, 'BOTTOM', 2, -y)
    end
    if Minimap.raid:GetAlpha() == 1 and y_offset == 12 then this:SetScript('OnUpdate', nil) end
end
------------------------------------------------------

local flag = function(t, index)
    for i = 1, 8 do
        for j = 1, getn(roster[i]) do
            local raid = bu[index]
            if t == UnitName(raid.unit) then raid.flag:Show() break end
            index = index + 1
        end
    end
end

local unflag = function(t, index)
    for i = 1, 8 do
        for j = 1, getn(roster[i]) do
            local raid = bu[index]
            if t == UnitName(raid.unit) then raid.flag:Hide() end
            index = index + 1
        end
    end
end

local clearflag = function()
    for i = 1, 40 do _G['modraid'..i].flag:Hide() end
end

local ToggleTank = function(unit)
    if  this.tank:IsShown() then
        this.tank:Hide()
    else
        this.tank:Show()
    end
end

local CreateUnits = function()
    for i = 1, 8 do
        local header = CreateFrame('Button', 'modraid_grp'..i, UIParent)
        header:SetWidth(32) header:SetHeight(12)
        header:SetMovable(true) header:SetUserPlaced(true)
        header:RegisterForDrag'LeftButton' header:EnableMouse(true)
		header:SetClampedToScreen(true)
        header:Hide()

        header.text = header:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
        header.text:SetPoint('CENTER', header)
        header.text:SetJustifyH'CENTER'
        header.text:SetText'group'

        if i == 1 then
            if left2right then
                --header:SetPoint('TOPLEFT', Minimap, 'BOTTOMLEFT', -138, -50)
                header:SetPoint('LEFT', 20, 20)
            else
                header:SetPoint('TOPRIGHT', Minimap, 'BOTTOMRIGHT', -53, -50)
            end
        elseif i == (xx + 1) then
            header:SetPoint('TOPLEFT',  _G['modraid_grp'..(i - xx)], 'BOTTOMLEFT', 0, -180)
        else
            -- changed: might be an issue w/ logic?
            header:SetPoint(left2right and 'LEFT' or 'RIGHT', _G['modraid_grp'..(i - 1)], left2right and 'RIGHT' or 'LEFT', showdebuffs and (left2right and 44 or -44) or (left2right and 32 or -32), 0)
        end

        header:SetScript('OnDragStart', function() this:StartMoving() end)
        header:SetScript('OnDragStop',  function() this:StopMovingOrSizing() end)
    end

    for i = 1, 40 do
        --local db = _G['modui_vars'].db
		-- raid
			--['modGridSize']           = 1,
			--['mod40yd']               = 1,
			--['modRaidX']              = 53,
			--['modRaidY']              = 53,
			--['modRaidLeft2Right']     = 1,


        bu[i] = CreateFrame('Button', 'modraid'..i, UIParent)
        bu[i]:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
        --bu[i]:SetWidth(db['modRaidX'] and db['modRaidX'] or 53)
        --bu[i]:SetHeight(db['modRaidY'] and db['modRaidY'] or 24)
        bu[i]:SetWidth(53)
        bu[i]:SetHeight(24)
    	bu[i]:SetResizable(true)
        bu[i]:SetBackdrop(bg)
        bu[i]:SetBackdropColor(0, 0, 0, 1)
        bu[i]:SetFrameLevel(0)
        bu[i]:Hide()

        zSkin(bu[i])
        zSkinColor(bu[i], .1, .1, .1)

        bu[i].hp = CreateFrame('StatusBar', nil, bu[i])
        bu[i].hp:SetFrameLevel(0)
        bu[i].hp:SetMinMaxValues(0, 100)
        bu[i].hp:SetValue(100)
        bu[i].hp:SetStatusBarTexture(sb)
        bu[i].hp:SetStatusBarColor(0, 1, 0)
        --bu[i].hp:SetPoint('TOPLEFT', bu[i], 1, -1)
        --bu[i].hp:SetPoint('BOTTOMRIGHT', bu[i], -1, 8)
        bu[i].hp:SetPoint('TOPLEFT', bu[i], 0, 0)
        bu[i].hp:SetPoint('BOTTOMRIGHT', bu[i], 0, 0)

        bu[i].mana = CreateFrame('StatusBar', nil, bu[i])
        bu[i].mana:SetHeight(6)
        bu[i].mana:SetFrameLevel(0)
        bu[i].mana:SetMinMaxValues(0, 100)
        bu[i].mana:SetValue(100)
        bu[i].mana:SetStatusBarTexture(sb)
        bu[i].mana:SetPoint('TOPLEFT', bu[i].hp, 'BOTTOMLEFT', 0, 0)
        bu[i].mana:SetPoint('TOPRIGHT', bu[i].hp, 'BOTTOMRIGHT', 0, 0)

        bu[i].name = bu[i]:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
        bu[i].name:SetPoint('TOP', bu[i], 0, -3)
        bu[i].name:SetJustifyH'CENTER'
		--bu[i].name:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE");

		--bu[i].nametext = bu[i]:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightLarge')
        --bu[i].nametext:SetPoint('TOP', bu[i], 0, -3)
        --bu[i].nametext:SetJustifyH'CENTER'
		--bu[i].nametext:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE");
		--bu[i].nametext:SetText("HALL");

        bu[i].heal = CreateFrame('StatusBar', nil, bu[i].hp)
        bu[i].heal:SetWidth(1) bu[i].heal:SetHeight(16)
        bu[i].heal:SetFrameLevel(0)
        bu[i].heal:SetMinMaxValues(0, 1)
        bu[i].heal:SetValue(1)
        bu[i].heal:SetStatusBarTexture(sb)
        bu[i].heal:SetStatusBarColor(0, 1, 0, .7)

        bu[i].healv = bu[i]:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
        bu[i].healv:SetTextColor(0, .6, 0, .6)
        bu[i].healv:SetPoint('CENTER', bu[i], 0, -4)

        bu[i].ric = bu[i]:CreateTexture(nil, 'OVERLAY')
        bu[i].ric:SetWidth(17) bu[i].ric:SetHeight(17)
        bu[i].ric:SetTexture[[Interface\TargetingFrame\UI-RaidTargetingIcons]]
        bu[i].ric:SetPoint('CENTER', bu[i])

        bu[i].rez = bu[i]:CreateTexture(nil, 'OVERLAY', nil, 7)
        bu[i].rez:SetWidth(24) bu[i].rez:SetHeight(24)
        bu[i].rez:SetTexture[[Interface\AddOns\modui\raid\texture\Raid-Icon-Rez.tga]]
        bu[i].rez:SetPoint('CENTER', bu[i])
        bu[i].rez:Hide()

        bu[i].flag = bu[i]:CreateTexture(nil, 'OVERLAY', nil, 7)
        bu[i].flag:SetWidth(24) bu[i].flag:SetHeight(24)
        bu[i].flag:SetTexture('Interface\\WorldStateFrame\\'..(UnitFactionGroup'player' == 'Alliance' and 'Horde' or 'Alliance')..'Flag')
        bu[i].flag:SetPoint('CENTER', bu[i])
        bu[i].flag:Hide()

        bu[i].tank = bu[i].hp:CreateTexture(nil, 'OVERLAY', nil, 7)
        bu[i].tank:SetWidth(16) bu[i].tank:SetHeight(16)
        bu[i].tank:SetTexture[[Interface\AddOns\modui\raid\texture\Tank.tga]]
        bu[i].tank:SetPoint('CENTER', bu[i], 'BOTTOM', 0, 1)
        bu[i].tank:Hide()

        bu[i].aura = CreateFrame('Button', nil, bu[i])
        bu[i].aura:SetWidth(19) bu[i].aura:SetHeight(19)
        bu[i].aura:SetPoint('CENTER', bu[i], 'BOTTOM', 0, 6)
        bu[i].aura:SetFrameLevel(2)
        bu[i].aura:EnableMouse(false)
        bu[i].aura:Hide()

        bu[i].aura.icon = bu[i].aura:CreateTexture(nil, 'BACKGROUND', 0, -7)
        bu[i].aura.icon:SetAllPoints()
        bu[i].aura.icon:SetAlpha(.7)

        zSkin(bu[i].aura, 4)
        zSkinColor(bu[i].aura, .7, .7, .7)

        bu[i].debuffs = {}

        for j = 1, 2 do
            bu[i].debuffs[j] = bu[i]:CreateTexture(nil, 'BACKGROUND')
            bu[i].debuffs[j]:SetWidth(10) bu[i].debuffs[j]:SetHeight(10)
            bu[i].debuffs[j]:Hide()

            bu[i].debuffs[j].border = bu[i]:CreateTexture(nil, 'ARTWORK')
            bu[i].debuffs[j].border:SetWidth(12) bu[i].debuffs[j].border:SetHeight(12)
            bu[i].debuffs[j].border:SetPoint('CENTER', bu[i].debuffs[j])
            bu[i].debuffs[j].border:SetTexture[[Interface\Buttons\UI-Debuff-Overlays]]
            bu[i].debuffs[j].border:SetTexCoord(.296875, .5703125, 0, .515625)
            bu[i].debuffs[j].border:Hide()

            if j == 1 then
                bu[i].debuffs[j]:SetPoint('TOPLEFT', bu[i], 'TOPRIGHT', 5, -2)
            else
                bu[i].debuffs[j]:SetPoint('TOP', bu[i].debuffs[1], 'BOTTOM', 0, -1)
            end
        end

        bu[i]:RegisterEvent'UNIT_AURA'     -- init
        bu[i]:SetScript('OnEvent',  function() debuffs(arg1) end)

        bu[i]:SetScript('OnClick',  function()
            if  arg1 == 'RightButton' then
				--Decurse(this.unit);
				
				local isCursed;
				for i, v in pairs(cursed) do
				    if v == this.unit then
					isCursed = true;
					end
				end

                --if cursed[this.unit] then
                if isCursed then
                    Decurse(this.unit)
                else
                    ToggleTank(this.unit)
                end
            else
                if  CursorHasItem() then
                    DropItemOnUnit(this.unit)
                elseif SpellIsTargeting() then
                    SpellTargetUnit(this.unit)
                else
                    TargetUnit(this.unit)
                end
            end
        end)
        bu[i]:SetScript('OnEnter',  function() UnitFrame_OnEnter() GameTooltipStatusBar:Hide() end)
        bu[i]:SetScript('OnLeave',  UnitFrame_OnLeave)
        bu[i]:SetScript('OnUpdate', raidupdate)
    end
end

Minimap.raid = CreateFrame('Button', 'modMinimap_RaidSpawn', Minimap)
Minimap.raid:SetWidth(20) Minimap.raid:SetHeight(100)
Minimap.raid:SetPoint('TOP', Minimap, 'BOTTOM')
Minimap.raid:Hide()

Minimap.raid.text = Minimap.raid:CreateFontString(nil, 'OVERLAY')
Minimap.raid.text:SetFont(STANDARD_TEXT_FONT, 24, 'OUTLINE')
Minimap.raid.text:SetPoint('CENTER', Minimap.raid)
Minimap.raid.text:SetText'+'
Minimap.raid.text:SetTextColor(1, 1, 0)

Minimap.raid:SetScript('OnEnter', function()
    GameTooltip:SetOwner(this, 'ANCHOR_TOPRIGHT', -30, -60)
    GameTooltip:SetText'Click to show/hide Raid Frames'
    Minimap.raid.text:SetTextColor(0,0.56,1)
    GameTooltip:Show()
end)

Minimap.raid:SetScript('OnLeave', function()
    Minimap.raid.text:SetTextColor(1, 1, 0)
    GameTooltip:Hide()
end)

Minimap.raid:SetScript('OnClick', function()
    local t = this.text:GetText()
    if t == '+' then
        this.text:SetText'-'
        rosterupdate()
    elseif t == '-' then
        this.text:SetText'+'
        for i = 1,  8 do _G['modraid_grp'..i]:Hide() end
        for i = 1, 40 do bu[i]:Hide() end
    end
end)

f:RegisterEvent'VARIABLES_LOADED'
f:RegisterEvent'PLAYER_LOGIN'
f:RegisterEvent'PLAYER_ENTERING_WORLD'
f:RegisterEvent'CHAT_MSG_SYSTEM'  f:RegisterEvent'RAID_ROSTER_UPDATE'
f:RegisterEvent'CHAT_MSG_BG_SYSTEM_ALLIANCE' f:RegisterEvent'CHAT_MSG_BG_SYSTEM_HORDE'
f:SetScript('OnEvent', function()
    if event == 'VARIABLES_LOADED' then
        if not MODUI_RAID_XY then
            MODUI_RAID_XY = {'TOP', Minimap, 'BOTTOM', 2, -70}
        end
    elseif event == 'PLAYER_LOGIN' then
        CreateUnits()
    elseif (event == 'PLAYER_ENTERING_WORLD' and UnitInRaid'player')
    or (event == 'CHAT_MSG_SYSTEM' and string.find(arg1, 'You have joined a raid group')) then
		-- Show raid rooster
        local t, y, a = GetTime() + 60, -20, 0.5
        --local y = -20
        --local a = .5
        Minimap.raid.text:SetText'-'
        f.reset = true
        f:SetScript('OnUpdate', function() display(t, y, a) end)
		rosterupdate();
        f:UnregisterEvent'PLAYER_ENTERING_WORLD'
    elseif event == 'RAID_ROSTER_UPDATE' then
        if Minimap.raid.text:GetText() == '-' then rosterupdate() end
        if GetNumRaidMembers() < 1 or not UnitInRaid'player' then
            for i = 1, 8 do _G['modraid_grp'..i]:Hide() end
            Minimap.raid:Hide() f.reset = true
        end
    elseif event == 'CHAT_MSG_BG_SYSTEM_ALLIANCE' or event == 'CHAT_MSG_BG_SYSTEM_HORDE' then
        local s = arg1
        local index = 1
        if string.find(s, 'The Alliance Flag was picked up')
        or string.find(s, '+ Alliance Flag') then
            local t = gsub(s, 'The Alliance Flag was picked up by (.+)!', '%1')
            clearflag() flag(t, index)
        elseif string.find(s, 'The Horde flag was picked up')
        or string.find(s, '+ Horde Flag') then
            local t = gsub(s, 'The Horde flag was picked up by (.+)!', '%1')
            clearflag() flag(t, index)
        elseif string.find(s, 'The Alliance Flag was dropped') then
            local t = gsub(s, 'The Alliance Flag was dropped by (.+)!', '%1')
            unflag(t, index)
        elseif string.find(s, '- Alliance Flag') then
            local t = gsub(s, '- Alliance Flag — (.+).', '%1')
            unflag(t, index)
        elseif string.find(s, 'captured the Alliance flag!') then
            local t = gsub(s, '(.+) captured the Alliance flag!', '%1')
            unflag(t, index)
        elseif string.find(s, 'The Horde flag was dropped') then
            local t = gsub(s, 'The Horde flag was dropped by (.+)!', '%1')
            unflag(t, index)
        elseif string.find(s, '- Horde Flag') then
            local t = gsub(s, '- Horde Flag — (.+).', '%1')
            unflag(t, index)
        elseif string.find(s, 'captured the Horde flag!') then
            local t = gsub(s, '(.+) captured the Horde flag!', '%1')
            unflag(t, index)
        end
    end
end)

end)