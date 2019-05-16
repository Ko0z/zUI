zUI:RegisterComponent("zMapPin", function ()

    local H     = {}
    local pins  = {}
    local focus

    H.WorldMapButton_OnClick = WorldMapButton_OnClick
    H.WorldMapFrame_Update   = WorldMapFrame_Update

    StaticPopupDialogs['MAP_PIN_NOTE'] = {
		text        = 'Add a Note',
        button2     = CLOSE,
        timeout     = 0,
        hasEditBox  = 1,    maxLetters   = 1024,    editBoxWidth = 350,
        whileDead   = true, hideOnEscape = true,
        OnShow      = function()
            (this.icon or _G[this:GetName()..'AlertIcon']):Hide()
            local editBox   = this.editBox or _G[this:GetName()..'EditBox']
            local pin       = focus

            this:SetFrameStrata'FULLSCREEN'
            WorldMapFrame:SetFrameStrata'DIALOG'

            editBox:SetText(pin.note and pin.note or '')
            editBox:SetFocus()

            local b2 = this.button2 or _G[this:GetName()..'Button2']
            b2:ClearAllPoints()
            b2:SetPoint('TOP', editBox, 'BOTTOM', 0, -6)
            b2:SetWidth(150)
        end,
        OnHide      = function()
            local editBox   = this.editBox or _G[this:GetName()..'EditBox']
            local t         = editBox:GetText()
            local pin       = focus

            pin.note        = t
            focus           = nil

            this:SetFrameStrata'DIALOG'
            WorldMapFrame:SetFrameStrata'FULLSCREEN'
        end,
    }

    local AddPin = function(bu, z)
        local width     = WorldMapDetailFrame:GetWidth()
        local height    = WorldMapDetailFrame:GetHeight()
        local x,  y     = WorldMapDetailFrame:GetCenter()
        local cx, cy    = GetCursorPosition()
        local scale     = WorldMapDetailFrame:GetEffectiveScale()
        local faction   = UnitFactionGroup'player'

        x = ((cx/scale) - (x - width/2))/width
        y = ((y + height/2) - (cy/scale))/height

        if  x >= 0 and y >= 0 and x <= 1 and y <= 1 then
            local p = CreateFrame('Button', z..'pin'..'_'..x, bu)
            p:SetWidth(32) p:SetHeight(32)
            p:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
            p:SetPoint('CENTER', bu, 'TOPLEFT', x*width + 8, -y*height + 8)
            tinsert(pins, p)

            local t = p:CreateTexture(nil, 'BACKGROUND')
            t:SetAllPoints()
            t:SetTexture(
                faction == 'Alliance'
                and [[Interface\WorldStateFrame\AllianceFlag]]
                or  [[Interface\WorldStateFrame\HordeFlag]]
            )
			
            p:SetScript('OnClick', function()
                if arg1  == 'RightButton' then
                    focus = p
                    StaticPopup_Show'MAP_PIN_NOTE'
                else
                    p:Hide() p.disable = true p.note = nil
                end
            end)

            p:SetScript('OnEnter', function()
                GameTooltip:SetOwner(p, 'ANCHOR_RIGHT')
                GameTooltip:AddLine(format('Pin: %.0f / %.0f', x*100, y*100))
                if p.note and p.note ~= '' then GameTooltip:AddLine('note: '..p.note) end
                GameTooltip:Show()
            end)

            p:SetScript('OnLeave', function()
                GameTooltip:Hide()
            end)
        end
    end

	--hooksecurefunc("WorldMapButton_OnClick", function()
			
	--end,true)

    local OnClick = function(mB, bu)
        if  IsShiftKeyDown() then
            if not bu then bu = this end
            local z = GetMapInfo()
			if z then AddPin(bu, z) end
        else
            H.WorldMapButton_OnClick(mB, bu)
        end
    end

    local Update = function()
        H.WorldMapFrame_Update()
        local  z = GetMapInfo()
        for i, v in pairs(pins) do
            if z and not v.disable then
                local n = v:GetName()
                if string.find(n, z) then v:Show()
                else v:Hide() end
            end
        end
    end

    --WorldMapButton_OnClick  = OnClick
    --WorldMapFrame_Update    = Update

	hooksecurefunc("WorldMapButton_OnClick",OnClick,false);
	hooksecurefunc("WorldMapFrame_Update",Update,false);
    --
end)