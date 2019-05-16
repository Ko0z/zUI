zUI:RegisterSkin("ChatBalloon", function () --modui inspired
    
    local num, time
    local e = CreateFrame'Frame'

    local BACKDROP = {  
        bgFile      = [[Interface\Tooltips\UI-Tooltip-Background]],
        edgeFile    = nil,
        edgeSize    = 0,
        insets      = {
            left    = 2, 
            right   = 2, 
            top     = 2, 
            bottom  = 2
        },
    }

    local events = {    
        CHAT_MSG_SAY            = 'chatBubbles',
        CHAT_MSG_YELL           = 'chatBubbles',
        CHAT_MSG_PARTY          = 'chatBubblesParty',
        CHAT_MSG_PARTY_LEADER   = 'chatBubblesParty',
        CHAT_MSG_MONSTER_SAY    = 'chatBubbles',
        CHAT_MSG_MONSTER_YELL   = 'chatBubbles',
        CHAT_MSG_MONSTER_PARTY  = 'chatBubblesParty',
    }


    local FormatBubble = function(f)
        for _, v in pairs(
            {
                f:GetRegions()
            }
        ) do
            if  v:GetObjectType() == 'Texture' then
                v:SetDrawLayer'OVERLAY'
                if  v:GetTexture() == [[Interface\Tooltips\ChatBubble-Background]]
                or  v:GetTexture() == [[Interface\Tooltips\ChatBubble-Backdrop]] then
                    v:SetTexture''
                end
            elseif  v:GetObjectType() == 'FontString' then
                f.text = v
            end
        end
    end

    local AddBorder = function(f)
        FormatBubble(f)
        if not f.skinned then
            zSkin(f, 1)
            zSkinColor(f, .7, .7, .7)

            f:SetBackdrop(BACKDROP)
            f:SetBackdropColor(0, 0, 0, .8)

            f.text:SetFont(STANDARD_TEXT_FONT, 13)

            f.skinned = true
        end
    end

    local isBalloon = function(f)
        if f:GetName() or not f:GetRegions() then return end
        return f:GetRegions():GetTexture() == [[Interface\Tooltips\ChatBubble-Background]]
    end

    local OnUpdate = function()
        if math.ceil(GetTime()) == time + 1 then e:SetScript('OnUpdate', nil) end
        local newnum =  WorldFrame:GetNumChildren()
        if newnum ~= num then
            local  f = {WorldFrame:GetChildren()}
            for _, v in pairs(f) do
               if isBalloon(v) then AddBorder(v) end
            end
            num = newnum
        end
    end

    local OnEvent = function()
        num  = 0
        time = math.ceil(GetTime())
        e:SetScript('OnUpdate', OnUpdate)
    end


    for i, _ in pairs(events) do e:RegisterEvent(i) end
    e:SetScript('OnEvent', OnEvent)
end)
    --
