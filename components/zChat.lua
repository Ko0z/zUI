--Credits to Modernist, modUI
zUI:RegisterComponent("zChat", function ()
	--_G = getfenv(0)
	local _, class = UnitClass'Player'
	--local colour = RAID_CLASS_COLORS[class]
	
	local zScroll = function()                       -- MOUSESCROLL CHAT
		if not arg1 then return end
		local f = this:GetParent()
		if arg1 > 0 then
			if IsShiftKeyDown() then f:ScrollToTop()
			else f:ScrollUp() end
		elseif arg1 < 0 then
			if IsShiftKeyDown() then f:ScrollToBottom()
		else f:ScrollDown() end
		end
	end

	local hideFrameForever = function (f)                -- HIDE JUNK
		f:SetScript('OnShow', function() f:Hide() end) f:Hide()
	end

	for i = 1, 7 do                                     -- INIT STYLE, SUBS etc
		local chat = _G['ChatFrame'..i]

		hideFrameForever(_G['ChatFrame'..i..'UpButton'])
		hideFrameForever(_G['ChatFrame'..i..'DownButton'])
		hideFrameForever(_G['ChatFrame'..i..'BottomButton'])

		local f = CreateFrame('Frame', nil, chat)
		f:EnableMouse(false)
		f:SetPoint('TOPLEFT', chat)
		f:SetPoint('BOTTOMRIGHT', chat)
		f:EnableMouseWheel(true)
		f:SetScript('OnMouseWheel', zScroll)
	end

	hideFrameForever(ChatFrameMenuButton);

	local addEditBox = function()
		local x = ({ChatFrameEditBox:GetRegions()})
		x[6]:SetAlpha(0) x[7]:SetAlpha(0) x[8]:SetAlpha(0)
		ChatFrameEditBox:SetAltArrowKeyMode(nil)
		ChatFrameEditBox:ClearAllPoints()
		if _G['modui_vars'].db['modEditBoxOrientation'] == 1 then -- todo look up
			ChatFrameEditBox:SetPoint('BOTTOMLEFT', ChatFrame1, 'TOPLEFT', -2, 18)
			ChatFrameEditBox:SetPoint('BOTTOMRIGHT', ChatFrame1, 'TOPRIGHT',  2, 18)
		else
			ChatFrameEditBox:SetPoint('TOPLEFT', ChatFrame1, 'BOTTOMLEFT', -2, -18)
			ChatFrameEditBox:SetPoint('TOPRIGHT', ChatFrame1, 'BOTTOMRIGHT',  2, -18)
		end
	end
	---------------------------------------------------------------------------------------------
	local _AddMessage   = ChatFrame1.AddMessage
    local blacklist     = {[ChatFrame2] = true,}
    --local _, class      = UnitClass'player'

    local currentURL
    local H = {}

	tlength = function(t)
        local count = 0
        if  t then
            for _ in pairs(t) do count = count + 1 end
        end
        return count
    end

--  keep channels between editbox use
    for _, v in pairs(
        {
            ChatTypeInfo.SAY,
            ChatTypeInfo.EMOTE,
            ChatTypeInfo.YELL,
            ChatTypeInfo.PARTY,
            ChatTypeInfo.GUILD,
            ChatTypeInfo.OFFICER,
            ChatTypeInfo.RAID,
            ChatTypeInfo.RAID_WARNING,
            ChatTypeInfo.BATTLEGROUND,
            ChatTypeInfo.WHISPER,
            ChatTypeInfo.CHANNEL
        }
    ) do
        v.sticky = 1
    end
    --H.ChatFrame_OnHyperlinkShow  = ChatFrame_OnHyperlinkShow

    CHAT_GUILD_GET                  = '|Hchannel:Guild|hg|h %s:\32'         -- GUILD            'g'
    CHAT_OFFICER_GET                = '|Hchannel:o|ho|h %s:\32'             -- OFFICER          'o'
    CHAT_RAID_GET                   = '|Hchannel:raid|hr|h %s:\32'          -- RAID             'r'
    CHAT_RAID_WARNING_GET           = 'rw %s:\32'                           -- RAID W           'rw'
    CHAT_RAID_LEADER_GET            = '|Hchannel:raid|hrl|h %s:\32'         -- RAID L           'rl'
    CHAT_BATTLEGROUND_GET           = '|Hchannel:Battleground|hbg|h %s:\32' -- BG               'bg'
    CHAT_BATTLEGROUND_LEADER_GET    = '|Hchannel:Battleground|hbl|h %s:\32' -- BG L             'bl'
    CHAT_PARTY_GET                  = '|Hchannel:party|hp|h %s:\32'         -- PARTY            'p'
    CHAT_PARTY_GUIDE_GET            = '|Hchannel:party|hdg|h %s:\32'        -- DUNGEONGUIDE     'dg'
    CHAT_MONSTER_PARTY_GET          = '|Hchannel:raid|hr|h %s:\32'          -- RAID             'r'

    local URL       = '|cff0ce27b%s|r' -- color
    local URL_LINK  = '|Hurl:%s|h'..URL..'|h'                               -- URL PATHS

    local chatevents = {
        CHAT_MSG_BG_SYSTEM_ALLIANCE = {
            ['The Alliance Flag was picked up by (.+)!']                        = '+ Alliance Flag — |cffff7d00%1|r.',
            ['The Alliance Flag was dropped by (.+)!']                          = '- Alliance Flag — |cffff7d00%1|r.',
            ['The Alliance Flag was returned to its base by (.+)!']             = '%1 returned Alliance Flag.'
        },
        CHAT_MSG_BG_SYSTEM_HORDE = {
            ['The Horde flag was picked up by (.+)!']                           = '+ Horde Flag — |cffff7d00%1|r.',
            ['The Horde flag was dropped by (.+)!']                             = '- Horde Flag — |cffff7d00%1|r.',
            ['The Horde flag was returned to its base by (.+)!']                = '%1 returned Horde Flag.'
        },
        CHAT_MSG_COMBAT_FACTION_CHANGE = {
            ['Reputation with (.+) increased by (.+).']                         = '+ %2 %1 rep.',
            ['You are now (.+) with (.+).']                                     = '%2 standing is now %1.',
        },
        CHAT_MSG_COMBAT_XP_GAIN = {
            ['(.+) dies, you gain (.+) experience. %(%+(.+)exp Rested bonus%)'] = '+ %2 (+%3) xp from %1.',
            ['(.+) dies, you gain (.+) experience.']                            = '+ %2 xp from %1.',
            ['You gain (.+) experience.']                                       = '+ %1 xp.',
        },
        CHAT_MSG_CURRENCY = {
            ['You receive currency: (.+)%.']                                    = '+ %1.',
            ['You\'ve lost (.+)%.']                                             = '- %1.',
        },
        CHAT_MSG_LOOT = {
            ['You receive item: (.+)%.']                                        = '+ %1.',
            ['You receive loot: (.+)%.']                                        = '+ %1.',
            ['You create: (.+)%.']                                              = '+ %1.',
            ['You are refunded: (.+)%.']                                        = '+ %1.',
            ['You have selected (.+) for: (.+)']                                = 'Selected %1 for %2.',
            ['Received item: (.+)%.']                                           = '+ %1.',
            ['(.+) receives item: (.+)%.']                                      = '+ %2 for %1.',
            ['(.+) receives loot: (.+)%.']                                      = '+ %2 for %1.',
            ['(.+) creates: (.+)%.']                                            = '+ %2 for %1.',
        },
        CHAT_MSG_SKILL = {
            ['Your skill in (.+) has increased to (.+).']                       = '%1 lvl %2.'
        },
        CHAT_MSG_SYSTEM = {
            ['Received (.+), (.+).']                                            = '+ %1, %2.',
            ['Received (.+).']                                                  = '+ %1.',
            ['Received (.+) of item: (.+).']                                    = '+ %2x%1.',
            -- ['(.+) completed.']                                              = '- Quest |cfff86256%1|r.',
            ['Quest accepted: (.+)']                                            = '+ Quest |cfff86256%1|r.',
            ['Received item: (.+)%.']                                           = '+ %1.',
            ['Experience gained: (.+).']                                        = '+ %1 xp.',
            ['(.+) has come online.']                                           = '|cff40fb40%1|r logged on.',
            ['(.+) has gone offline.']                                          = '|cff40fb40%1|r logged off.',
            ['You are now Busy: in combat']                                     = '+ Combat.',
            ['You are no longer marked Busy.']                                  = '- Combat.',
            ['Discovered (.+): (.+) experience gained']                         = '+ %2 xp, found %1.',
            ['You are now (.+) with (.+).']                                     = '+ %2 faction, now %1.',
            ['Quest Accepted (.+)']                                             = '+ quest |cfff86256%1|r.',
            ['You are now Away: AFK']                                           = '+ AFK.',
            ['You are no longer Away.']                                         = '- AFK.',
            ['You are no longer rested.']                                       = '- Rested.',
            ['You don\'t meet the requirements for that quest.']                = '|cffff000!|r Quest requirements not met.',
            ['No player named \'(.+)\' is currently playing.']                  = 'No such player, \'|cffff7d00%1|r\'.',
            ['(.+) has joined the party.']                                      = '+ Party Member |cffff7d00%1|r.',
            ['(.+) has joined the raid group']                                  = '+ Raider |cffff7d00%1|r.',
            ['(.+) has left the raid group']                                    = '- Raider |cffff7d00%1|r.',
        },
        CHAT_MSG_TRADESKILLS = {
            ['(.+) creates (.+).']                                              = '%1 |cffffff00->|r %2.',
        },
    }

        --  url types
    local URL_PATTERNS = {      --  pinched from PhanxChat, sorry phanx
        --  X://Y url               https://github.com/Phanx/PhanxChat/blob/master/Modules/LinkURLs.lua
        '^(%a[%w%.+-]+://%S+)',
        '%f[%S](%a[%w%.+-]+://%S+)',
        --  www.X.Y url
        '^(www%.[-%w_%%]+%.%S+)',
        '%f[%S](www%.[-%w_%%]+%.%S+)',
        --  X.Y.Z/WWWWW url with path
        '^([-%w_%%%.]+[-%w_%%]%.(%a%a+)/%S+)',
        '%f[%S]([-%w_%%%.]+[-%w_%%]%.(%a%a+)/%S+)',
        --  X.Y.Z url
        '^([-%w_%%%.]+[-%w_%%]%.(%a%a+))',
        '%f[%S]([-%w_%%%.]+[-%w_%%]%.(%a%a+))',
        --  X@Y.Z email
        '(%S+@[-%w_%%%.]+%.(%a%a+))',
        --  X.Y.Z:WWWW/VVVVV url with port and path
        '^([-%w_%%%.]+[-%w_%%]%.(%a%a+):[0-6]?%d?%d?%d?%d/%S+)',
        '%f[%S]([-%w_%%%.]+[-%w_%%]%.(%a%a+):[0-6]?%d?%d?%d?%d/%S+)',
        --  X.Y.Z:WWWW url with port
        '^([-%w_%%%.]+[-%w_%%]%.(%a%a+):[0-6]?%d?%d?%d?%d)%f[%D]',
        '%f[%S]([-%w_%%%.]+[-%w_%%]%.(%a%a+):[0-6]?%d?%d?%d?%d)%f[%D]',
        --  XXX.YYY.ZZZ.WWW:VVVV/UUUUU IPv4 address with port and path
        '^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d/%S+)',
        '%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d/%S+)',
        --  XXX.YYY.ZZZ.WWW:VVVV IPv4 address with port (IP of ts server for example)
        '^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d)%f[%D]',
        '%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d:[0-6]?%d?%d?%d?%d)%f[%D]',
        --  XXX.YYY.ZZZ.WWW/VVVVV IPv4 address with path
        '^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%/%S+)',
        '%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%/%S+)',
        --  XXX.YYY.ZZZ.WWW IPv4 address
        '^([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%)%f[%D]',
        '%f[%S]([0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%.[0-2]?%d?%d%)%f[%D]',
    }

    TLDS = {
        AC = true, AD = true, AE = true, AERO = true, AF = true, AG = true, AI = true, AL = true, AM = true, AN = true, AO = true, AQ = true, AR = true, ARPA = true, AS = true, ASIA = true, AT = true, AU = true, AW = true, AX = true, AZ = true, BA = true, BB = true, BD = true, BE = true, BF = true, BG = true, BH = true, BI = true, BIZ = true, BJ = true, BM = true, BN = true, BO = true, BR = true, BS = true, BT = true, BV = true, BW = true, BY = true, BZ = true, CA = true, CAT = true, CC = true, CD = true, CF = true, CG = true, CH = true, CI = true, CK = true, CL = true, CM = true, CN = true, CO = true, COM = true, COOP = true, CR = true, CU = true, CV = true, CX = true, CY = true, CZ = true, DE = true, DJ = true, DK = true, DM = true, DO = true, DZ = true, EC = true, EDU = true, EE = true, EG = true, ER = true, ES = true, ET = true, EU = true, FI = true, FJ = true, FK = true, FM = true, FO = true, FR = true, GA = true, GB = true, GD = true, GE = true, GF = true, GG = true, GH = true, GI = true, GL = true, GM = true, GN = true, GOV = true, GP = true, GQ = true, GR = true, GS = true, GT = true, GU = true, GW = true, GY = true, HK = true, HM = true, HN = true, HR = true, HT = true, HU = true, ID = true, IE = true, IL = true, IM = true, IN = true, INFO = true, INT = true, IO = true, IQ = true, IR = true, IS = true, IT = true, JE = true, JM = true, JO = true, JOBS = true, JP = true, KE = true, KG = true, KH = true, KI = true, KM = true, KN = true, KP = true, KR = true, KW = true, KY = true, KZ = true, LA = true, LB = true, LC = true, LI = true, LK = true, LR = true, LS = true, LT = true, LU = true, LV = true, LY = true, MA = true, MC = true, MD = true, ME = true, MG = true, MH = true, MIL = true, MK = true, ML = true, MM = true, MN = true, MO = true, MOBI = true, MP = true, MQ = true, MR = true, MS = true, MT = true, MU = true, MUSEUM = true, MV = true, MW = true, MX = true, MY = true, MZ = true, NA = true, NAME = true, NC = true, NE = true, NET = true, NF = true, NG = true, NI = true, NL = true, NO = true, NP = true, NR = true, NU = true, NZ = true, OM = true, ORG = true, PA = true, PE = true, PF = true, PG = true, PH = true, PK = true, PL = true, PM = true, PN = true, PR = true, PRO = true, PS = true, PT = true, PW = true, PY = true, QA = true, RE = true, RO = true, RS = true, RU = true, RW = true, SA = true, SB = true, SC = true, SD = true, SE = true, SG = true, SH = true, SI = true, SJ = true, SK = true, SL = true, SM = true, SN = true, SO = true, SR = true, ST = true, SU = true, SV = true, SY = true, SZ = true, TC = true, TD = true, TEL = true, TF = true, TG = true, TH = true, TJ = true, TK = true, TL = true, TM = true, TN = true, TO = true, TP = true, TR = true, TRAVEL = true, TT = true, TV = true, TW = true, TZ = true, UA = true, UG = true, UK = true, UM = true, US = true, UY = true, UZ = true, VA = true, VC = true, VE = true, VG = true, VI = true, VN = true, VU = true, WF = true, WS = true, YE = true, YT = true, YU = true, ZA = true, ZM = true, ZW = true,
    }

    StaticPopupDialogs['URL_COPY_DIALOG'] = {                              -- COPY BOX
		text            = 'URL',
        button2         = CLOSE,
        timeout         = 0,
        hasEditBox      = 1,
		hasWideEditBox	= 1,
        maxLetters      = 1024,
        editBoxWidth    = 350,
        whileDead       = true,
        hideOnEscape    = true,
        OnShow = function()
            (this.icon or getglobal(this:GetName()..'AlertIcon')):Hide()

            --local editBox = this.editBox or _G[this:GetName()..'EditBox']
			--local editBox = this.editBox or getglobal(this:GetName()..'EditBox')
			local editBox = this.editBox or getglobal(this:GetName()..'WideEditBox')
            editBox:SetText(currentURL)
            editBox:SetFocus()
            editBox:HighlightText(0)

            local button2 = this.button2 or getglobal(this:GetName()..'Button2')
            button2:ClearAllPoints()
            button2:SetPoint('TOP', editBox, 'BOTTOM', 0, 10)
            button2:SetWidth(150)
            currentURL = nil
        end,
    }

    local modURL = function(url, tld)
        if  tld then
    		return TLDS[strupper(tld)] and string.format(URL_LINK, url, url) or url
    	else
    		return string.format(URL_LINK, url, url)
    	end
    end
	--[[
	hooksecurefunc("ChatFrame_OnHyperlinkShow", function(link, text, button)
		if  strsub(link, 1, 4) == 'url:' then
    		currentURL = strsub(link, 5)
    		StaticPopup_Show'URL_COPY_DIALOG'
            return
        end
	end)
	]]
	H.ChatFrame_OnHyperlinkShow  = ChatFrame_OnHyperlinkShow
	
	function _G.ChatFrame_OnHyperlinkShow(link, text, button)	--obviosuly hooksecurefunc is not working as I want it here...
	--function zChatFrame_OnHyperlinkShow(link, text, button)
		if  strsub(link, 1, 4) == 'url:' then
    		currentURL = strsub(link, 5)
    		StaticPopup_Show'URL_COPY_DIALOG'
            return
        end
        H.ChatFrame_OnHyperlinkShow(link, text, button)
	end

	--hooksecurefunc("ChatFrame_OnHyperlinkShow", _G.ChatFrame_OnHyperlinkShow);
	
    --ChatFrame_OnHyperlinkShow = function(link, text, button)
    --    if  strsub(link, 1, 4) == 'url:' then
    --		currentURL = strsub(link, 5)
    --		StaticPopup_Show'URL_COPY_DIALOG'
    --        return
    --    end
    --    H.ChatFrame_OnHyperlinkShow(link, text, button)
    --end
	
    local AddMessage = function(f, t, r, g, b, id)
        if t == nil then return _AddMessage(f, t, r, g, b, id) end
        local colour    = RAID_CLASS_COLORS[class].colourStr

        --       strip item link brackets
        --if  var.ilink then
        --    t = gsub(t, '|H(.-)|h%[(.-)%]|h', '|H%1|h%2|h')
        --end
        --      format text
        --if  var.tformat then
        if  (zUI_config.chat.tformat == "1") then
            --   swap strings
            t = gsub(t, '%[(%d+)%. .+%].+(|Hplayer.+)', '[%1]%2') -- GLOBAL CHANNELS      '1'
            t = gsub(t, 'Guild Message of the Day:', 'GMOTD —')  -- GMOTD
            for _, v in pairs(chatevents) do
                for k, j in pairs(v) do
                    if  string.find(t, k)then
                        -- print(k, 'is a match.')
                        t = gsub(t, k, j)
                    end
                end
            end
            --   timestamp
            --if  var.tstamps then 
            if  (zUI_config.chat.tstamps == "1") then 
                --local d = gsub(date'%I.%M'..string.lower(date'%p'), '0*(%d+)', '%1', 1) -- Change to 24H here.
				local d = gsub(date"%H:%M", '0*(%d+)', '%1', 1) -- Change to 24H here.
                t = string.format('|cffffc800%s|r %s', d, t)
            end
        end
       --       urls
        for i = 1, tlength(URL_PATTERNS) do
            if string.find(t, URL_PATTERNS[i]) then
                local new = gsub(t, URL_PATTERNS[i], modURL)
                if t ~= new then t = new break end
            end
        end
        return _AddMessage(f, t, r, g, b, id)
    end

    --local PLAYER_LOGIN = function()
        for i = 1, 7 do
            if not blacklist[chat] then getglobal('ChatFrame'..i).AddMessage = AddMessage end

        end
    --end
	  
	 -- getglobal(this:GetName().."NormalTexture");
	  --_G[this:GetName()..'Icon']
    --local e = CreateFrame'Frame'
    --e:RegisterEvent'PLAYER_LOGIN'
    --e:SetScript('OnEvent', PLAYER_LOGIN)

end)
