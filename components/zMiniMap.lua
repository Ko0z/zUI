zUI:RegisterComponent("zMiniMap", function () 

--zUI.zMiniMap = CreateFrame("Frame", nil, UIParent);
--zUI.zMiniMap:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE") -- register events to listen to

--zUI.zMiniMap:SetScript( "OnEvent", function() 
	-- do something
--end)

GameTimeFrame:Hide()
if (C.global.darkmode == "1") then
	MinimapBorder:SetTexture("Interface\\Addons\\zUI\\img\\MiniMapDark.tga");
else
	MinimapBorder:SetTexture("Interface\\Addons\\zUI\\img\\MiniMapLight.tga");
end

MinimapBorderTop:SetTexture("Interface\\Addons\\zUI\\img\\MiniMapZoneFlag.tga");
MinimapBorderTop:SetWidth(256);
MinimapBorderTop:SetTexCoord(1, 0, 0, 1)
MinimapBorderTop:ClearAllPoints()
MinimapBorderTop:SetPoint('TOP', Minimap, 0, 23)

if not C.position["zMinimapSquared"] then
	C.position["zMinimapSquared"] = { alpha = 1.0, scale = 1.0 }
end
local minimap_settings = C.position["zMinimapSquared"];

local modZoom = function()
    if not arg1 then return end

	if (arg1 > 0 and Minimap:GetZoom() < 5) then
        Minimap:SetZoom(Minimap:GetZoom() + 1)
    elseif arg1 < 0 and Minimap:GetZoom() > 0 then
        Minimap:SetZoom(Minimap:GetZoom() - 1)
    end
end

local f = CreateFrame('Frame', nil, Minimap)
f:EnableMouse(false)
f:SetPoint('TOPLEFT', Minimap)
f:SetPoint('BOTTOMRIGHT', Minimap)
f:EnableMouseWheel(true)
f:SetScript('OnMouseWheel', modZoom)

for _, v in pairs({
    --MinimapBorderTop,
    MinimapToggleButton,
    MinimapZoomIn,
	MinimapZoomOut
}) do
    v:Hide()
end

MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetPoint('TOPRIGHT', 0, -10)

MinimapZoneText:ClearAllPoints()
MinimapZoneText:SetPoint('TOP', Minimap, 0, 17)
MinimapZoneText:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE')

zUI.zClock = CreateFrame("Frame", nil, UIParent); -- MonkeyClock inspired
zClockText = zUI.zClock:CreateFontString("zClockText", "BACKGROUND");
zClockText:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE');
--TODO: let user set clock text color.
--zClockText:SetTextColor(1,0.8196079,0); -- yellow wow default
zClockText:SetTextColor(1,1,1);

zClockText:SetPoint('BOTTOM', Minimap, -2, -8)
local zdeltaTime = 6;

--zClockText:SetText("1:11"); --test
zUI.zClock:SetScript("OnUpdate", function()
	local elapsed = arg1;
	zdeltaTime = zdeltaTime + elapsed;

	if(zdeltaTime >= 6.0) then -- updates only every 6 seconds, I dont care for exact time atm
		--zClockText:SetText(zClock_GetTimeText());
		zClockText:SetText(date("%H:%M"));	--options needed
		zdeltaTime = 0;
	end
	
end)
--[[ date returns
%a	abbreviated weekday name (e.g., Wed)
%A	full weekday name (e.g., Wednesday)
%b	abbreviated month name (e.g., Sep)
%B	full month name (e.g., September)
%c	date and time (e.g., 09/16/98 23:48:10)
%d	day of the month (16) [01-31]
%H	hour, using a 24-hour clock (23) [00-23]
%I	hour, using a 12-hour clock (11) [01-12]
%M	minute (48) [00-59]
%m	month (09) [01-12]
%p	either "am" or "pm" (pm)
%S	second (10) [00-61]
%w	weekday (3) [0-6 = Sunday-Saturday]
%x	date (e.g., 09/16/98)
%X	time (e.g., 23:48:10)
%Y	full year (1998)
%y	two-digit year (98) [00-99]
%%	the character `%´
]]
-- This function returns the time in a human readable string
function zClock_GetTimeText()
	local iHour, iMinute = GetGameTime() -- server time..
	local time = date("%I:%M %p"); -- local time with AM or PM
	--local bPM
	
	-- offset the local time from server time
	--iHour --= iHour + MonkeyClockVars.hourOffset.value
	--iMinute --= iMinute + MonkeyClockVars.minuteOffset.value
	
	-- fix up the hours and mins
	if (iMinute > 59) then
		iMinute = iMinute - 60
		iHour = iHour + 1
	elseif (iMinute < 0) then
		iMinute = 60 + iMinute
		iHour = iHour - 1
	end
	if (iHour > 23) then
		iHour = iHour - 24
	elseif (iHour < 0) then
		iHour = 24 + iHour
	end
	
	-- format the return string according to config settings
	--if (MonkeyClockVars.use24) then
	return format(TIME_TWENTYFOURHOURS, iHour, iMinute)
	--[[
	else
		if (iHour >= 12) then
			bPM = 1
			iHour = iHour - 12
		else
			bPM = 0
		end
		if (iHour == 0) then
			iHour = 12
		end
		if (bPM == 1) then
			return format(TIME_TWELVEHOURPM, iHour, iMinute)
		else
			return format(TIME_TWELVEHOURAM, iHour, iMinute)
		end
	end
	]]
end
--zUI.zClock:SetScript("OnShow", function(self)
--	zdeltaTime = 0;
--end)

--SetFont("Fonts\\ARIALN.TTF", 10)

--MinimapZoneText:SetText("How Many Letters Can We Show Here");
--GameTimeFrame:SetScale(.76)
--GameTimeFrame:ClearAllPoints() GameTimeFrame:SetPoint('BOTTOM', 12, 10)
if (C.minimap.square == "1") then
	MinimapBorder:SetTexture(nil);

	zUI.squaredminimap = CreateFrame("Frame", "zMinimapSquared", UIParent);
	if (zUI_config["position"]["zMinimapSquared"]) then
		
		if zUI_config["position"]["zMinimapSquared"]["scale"] then
			zUI.squaredminimap:SetScale(zUI_config["position"]["zMinimapSquared"].scale)
		end
		if zUI_config["position"]["zMinimapSquared"]["xpos"] then
			zUI.squaredminimap:ClearAllPoints()
			zUI.squaredminimap:SetPoint("CENTER",UIParent, "BOTTOMLEFT",zUI_config["position"]["zMinimapSquared"].xpos, zUI_config["position"]["zMinimapSquared"].ypos);
			--zUI.squaredminimap:SetPoint("CENTER",UIParent, "TOPRIGHT",zUI_config["position"]["zMinimapSquared"].xpos, zUI_config["position"]["zMinimapSquared"].ypos);
			--zUI.squaredminimap:SetPoint("BOTTOMLEFT",UIParent,"TOPRIGHT", 0,0);
			--local x,y = zUI.squaredminimap:GetCenter()
		end
	--else
		--zUI.squaredminimap:SetPoint("CENTER", UIParent, -10, -10);
		--zUI.squaredminimap:SetPoint("CENTER", MinimapCluster,"TOP", 9, -92);
	end
	zUI.squaredminimap:SetPoint("TOPRIGHT", UIParent, -10, -10);
	zUI.squaredminimap:SetMovable(true);
	zUI.squaredminimap:EnableMouse(true);
	zUI.squaredminimap:EnableMouseWheel(true);
	zUI.squaredminimap:SetUserPlaced(true);
	zUI.squaredminimap:SetClampedToScreen(true);
	zUI.squaredminimap:SetScript("OnDragStart", function() if IsShiftKeyDown() then this:StartMoving(); end end);
	zUI.squaredminimap:SetScript('OnMouseWheel', modZoom)
    zUI.squaredminimap:SetScript("OnDragStop",  function() 
		this:StopMovingOrSizing(); 

		if not C.position["zMinimapSquared"] then
			C.position["zMinimapSquared"] = {}
		end
		local x,y = this:GetCenter()
		C.position["zMinimapSquared"]["xpos"] = x;
		C.position["zMinimapSquared"]["ypos"] = y;
		this:SetPoint("CENTER",UIParent, "BOTTOMLEFT",x,y);
	end);
    zUI.squaredminimap:RegisterForDrag("LeftButton");
	--zUI.squaredminimap:SetWidth(C.minimap.width)
	zUI.squaredminimap:SetWidth(140);
	zUI.squaredminimap:SetHeight(140);
	zUI.squaredminimap:SetFrameStrata("BACKGROUND");
	zSkin(zUI.squaredminimap, 0);
	zSkinColor(zUI.squaredminimap, 0.3,0.3,0.3);
	--zUI.squaredminimap.backdrop = zUI.loot:CreateTexture(nil, "BACKGROUND")
	--zUI.loot.backdrop:SetTexture(0,0,0,.9)
	--zUI.loot.backdrop:ClearAllPoints()
	--zUI.loot.backdrop:SetAllPoints(zUI.loot)

	Minimap:SetParent(zUI.squaredminimap);
	Minimap:SetPoint("CENTER", zUI.squaredminimap, "CENTER", 1, -1);
	Minimap:SetFrameLevel(1);
	Minimap:SetMaskTexture("Interface\\Addons\\zUI\\img\\minimap");
	
	zClockText:SetPoint('BOTTOM', Minimap, 0, 3);
	MinimapZoneText:SetPoint('TOP', Minimap, 0, -2);
	MinimapZoneText:SetDrawLayer("OVERLAY");
	MinimapZoneText:SetNonSpaceWrap(false);
	--MinimapZoneText:SetJustifyH("CENTER");
	MinimapZoneText:SetWidth(120);
	--MinimapZoneText:SetText("ZoneName")
	--MinimapZoneText:SetFrameLevel(2);
	MinimapBorderTop:Hide();
else
	Minimap:SetMaskTexture("Interface\\Addons\\zUI\\img\\RoundMask5");
	
end

--local f = CreateFrame('Frame', nil, Minimap)
--f:EnableMouse(false)
--f:SetPoint('TOPLEFT', Minimap)
--f:SetPoint('BOTTOMRIGHT', Minimap)
--f:EnableMouseWheel(true)
--f:SetScript('OnMouseWheel', modZoom)

--for _, v in pairs({ PlayerFrame, TargetFrame, PartyMemberFrame1 }) do
--    v:SetUserPlaced(true) v:SetMovable(true) v:EnableMouse(true)
--    v:SetScript('OnDragStart', function() if IsShiftKeyDown() then this:StartMoving() end end)
--    v:SetScript('OnDragStop',  function() this:StopMovingOrSizing() end)
--    v:RegisterForDrag'LeftButton'
--end

end)