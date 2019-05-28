-- Credits to Shagu, Modernist
zUI.api = { }

-- load zUI environment
setfenv(1, zUI:GetEnvironment())

local TEXTURE  = [[Interface\\TargetingFrame\\UI-StatusBar]]

local BACKDROP = {
    bgFile     = [[Interface\ChatFrame\ChatFrameBackground]],
    tiled      = false,
    insets     = {left = -3, right = -3, top = -3, bottom = -3}
}
local SLOT     = {
    bgFile     = '',
    edgeFile   = [[Interface\Buttons\WHITE8x8]],
    edgeSize   = 3,
}
local BORDER   = {
    bgFile     = '',
    edgeFile   = [[Interface\Buttons\WHITE8x8]],
    edgeSize   = 1,
}

local sections  = {
    'TOPLEFT', 'TOPRIGHT',  'BOTTOMLEFT',   'BOTTOMRIGHT',
    'TOP',      'BOTTOM',   'LEFT',         'RIGHT'
}

local t = CreateFont'zhotkeys'
t:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE')

function zUI.api.true_format(v)            -- STATUS TEXT FORMATTING ie 1.5k, 2.3m
		if v > 1E7 then return (math.floor(v/1E6))..'m'
		elseif v > 1E6 then return (math.floor((v/1E6)*10)/10)..'m'
		elseif v > 1E4 then return (math.floor(v/1E3))..'k'
		elseif v > 1E3 and (C.unitframes.trueformat == "1") then return (math.floor((v/1E3)*10)/10)..'k'
		--elseif ( v > 1E3 and GetCVar("ufiTrueFormat") == "1" ) then return (math.floor((v/1E3)*10)/10)..'k'
		else return v 
		end
	end

function zUI.api.zGradient(v, f, min, max)
	if v < min or v > max then return end
	if (max - min) > 0 then
		v = (v - min)/(max - min)
	else
		v = 0
	end
	if v > .5 then
		r = (1 - v)*2
		g = 1
	else
		r = 1
		g = v*2
	end
	b = 0
	f:SetTextColor(r*1.5, g*1.5, b*1.5)
end

-- [ UnitColor ]
-- Gets the appropriate color and return it r.b.g
-- 'unit'       [string]           player, target etc..
function zUI.api.UnitColor(unit)
	local r, g, b;
	
	if ( ( not UnitIsPlayer(unit) ) and ( ( not UnitIsConnected(unit) ) or ( UnitIsDeadOrGhost(unit) ) ) ) then
		--Color it gray
		r, g, b = 0.5, 0.5, 0.5;
	elseif ( UnitIsPlayer(unit) ) then
		--if UnitFramesImprovedConfig.PlayerClassColor == 1 then
		if (C.unitframes.playerclasscolor == "1") then

			local localizedClass, englishClass = UnitClass(unit);
			local classColor = RAID_CLASS_COLORS[englishClass];

			if ( classColor ) then
				--if ( UnitClass(unit) == "Shaman" ) then -- Dont need to check specifically for Shaman anymore, set in RAID_CLASS_COLORS in zUI.
				--	r, g, b = 0, 0.44, 0.87;
				--else
				r, g, b = classColor.r, classColor.g, classColor.b;
				--end
			else
				if ( UnitIsFriend("player", unit) ) then
					r, g, b = 0.0, 1.0, 0.0;
				else
					r, g, b = 1.0, 0.0, 0.0;
				end
			end
		else
			r, g, b = TargetFrameNameBackground:GetVertexColor();
		end
	else
		if (C.unitframes.npcclasscolor == "1") then
			local localizedClass, englishClass = UnitClass(unit);
			
			if ( englishClass ~= nil ) then
				local classColor = RAID_CLASS_COLORS[englishClass];
				r, g, b = classColor.r, classColor.g, classColor.b;
			else
				r, g, b = TargetFrameNameBackground:GetVertexColor();
			end
		else
			r, g, b = TargetFrameNameBackground:GetVertexColor();
		end
	end
	return r, g, b;
end

--------------------------------==[[ SKINNING STUFF ]]==----------------------------------
function zUI.api.AddHighlight(button)
	button.enter = button:CreateTexture(nil, 'OVERLAY')
    button.enter:SetAllPoints()
    button.enter:SetTexture("Interface\\Buttons\\CheckButtonHilight")
    button.enter:SetTexCoord(.075, .95, .05, .95)
    button.enter:SetBlendMode'ADD'
    button.enter:SetAlpha(0)
end

function zUI.api.ToggleHighlight(button, show)
	if not button.enter then zUI.api.AddHighlight(button) end
    button.enter:SetAlpha(show and 1 or 0)
end

-- square	[bool]		enables square as to rounded borders.
function zUI.api.zStyle_Button(button, offset, hover, square)
	if not button then return end
	--local cr,cg,cb,ca = strsplit(",", C.skin.dark)
	local cr,cg,cb,ca = zUI.api.GetStringColor(C.skin.dark)

    button.HonEnter = button:GetScript'OnEnter'
    button.HonLeave = button:GetScript'OnLeave'

    button:SetScript('OnEnter', function() 
        if button.HonEnter then button:HonEnter() end
        if hover then zUI.api.ToggleHighlight(button, true) end 
    end)

    button:SetScript('OnLeave', function()
        if button.HonLeave then button:HonLeave() end
        if hover then zUI.api.ToggleHighlight(button, false) end 
    end)

    if (not IsSkinned(button)) then
        zSkin(button, offset and offset or 1,square)
        zSkinColor(button, cr, cg, cb)
    end
end

function zUI.api.zStyle_ButtonBorder(button)
	if button.bo then return end
    button.bo = CreateFrame('Frame', button:GetName()..'zBorder', button)
    button.bo:SetPoint('TOPLEFT', button, 1, -1)
    button.bo:SetPoint('BOTTOMRIGHT', button, -1, 1)
    button.bo:SetFrameLevel(button:GetFrameLevel() + 1)
    button.bo:SetBackdrop(BORDER)
    button.bo:SetBackdropBorderColor(0, 0, 0, 0)
end

function zUI.api.zStyle_Items(button)
	local name  = button:GetName()
    local count  = _G[name..'Count']
    local icon  = _G[name..'IconTexture']

	zStyle_Button(button)
    zStyle_ButtonBorder(button)

    --button:SetNormalTexture''
    --button:SetPushedTexture''
    --button:SetHighlightTexture''

    if count then
		count:ClearAllPoints()
		count:SetParent(button.bo)
		count:SetPoint('BOTTOM', button, 0, -1)
		count:SetShadowOffset(0, 0)
		count:SetJustifyH'CENTER'
		count:SetDrawLayer('OVERLAY', 7)
    end

    if icon then
        icon:SetTexCoord(.1, .9, .1, .9)
        icon:SetDrawLayer'ARTWORK'
    end
end

function zUI.api.zStyle_ButtonElements(button)
	if not button then return end
    local  bo = _G[button:GetName()..'Border']
    local  co = _G[button:GetName()..'Count']
    local  ic = _G[button:GetName()..'Icon'] or _G[button:GetName()..'IconTexture']
    local  cd = _G[button:GetName()..'Cooldown']

    for _, v in pairs({button.Border, button.FloatingBG}) do
        if v then v:SetAlpha(0) end
    end

    if  button.FloatingBG and not button.mod then
        button.mod = button:CreateTexture(nil, 'BACKGROUND')
        button.mod:SetAllPoints(button.FloatingBG)
        button.mod:SetBackdrop(SLOT)
        button.mod:SetBackdropColor(0, 0, 0)
    end

    if  bo then
        bo:Hide()
    end

    if  co then
        if button.bo then co:SetParent(button.bo) end
        co:ClearAllPoints()
        co:SetPoint('BOTTOM', button, 2, -1)
        co:SetFont(STANDARD_TEXT_FONT, 12, 'OUTLINE') -- TODO: make a setting for item count font size, color
        co:SetShadowOffset(0, 0)
        co:SetJustifyH'CENTER'
        co:SetDrawLayer('OVERLAY', 7)
    end

    if  cd then
        cd:ClearAllPoints()
        cd:SetAllPoints()
    end

    if  button.HotKey then
        button.HotKey:ClearAllPoints()
        button.HotKey:SetPoint('TOPRIGHT', button, -1, 2)
        NumberFontNormalSmallGray:SetFontObject'zhotkeys'
    end

    if  ic then
        ic:SetTexCoord(.1, .9, .1, .9)
        ic:SetDrawLayer'ARTWORK'
    end

    if  button.Name then
        button.Name:SetWidth(button:GetWidth() + 15)
        button.Name:SetFontObject'GameFontHighlight'
    end
end

function zUI.api.zStyle_Statusbar(f)
	if  f:GetObjectType() == 'StatusBar' then
        f:SetStatusBarTexture(TEXTURE)
    else
        f:SetTexture(TEXTURE)
    end
end

--------------------------==[[ Skinning stuff ]]==--------------------------
function zUI.api.IsSkinned(f)
	return f.borderTextures and true or false
end

function zUI.api.SkinInfo(f)
	return f.borderTextures, f.GetBorderColor
end

function zUI.api.zSkinColor(f, r, g, b, a)
	local   t = f.borderTextures
    if not  t then return end
    for  _, v in pairs(t) do
        v:SetVertexColor(r or 1, g or 1, b or 1, a or 1)
    end
end

function zUI.api.SkinDraw(f, layer, sublayer)
	local   t = f.borderTextures
    if not  t then return end
    for  _, v in pairs(t) do
        v:SetDrawLayer(layer or 'OVERLAY', sublayer or 0)
    end
end

function zUI.api.HideSkin(f)
	local   t = f.borderTextures
    if not  t then return end
    for  _, v in pairs(t) do v:Hide() end
end

function zUI.api.ShowSkin(f)
	local   t = f.borderTextures
	if not  t then return end
	for  _, v in pairs(t) do v:Show() end
end

function zUI.api.GetBorderColor()
	local red, green, blue  = this.TOPLEFT:GetVertexColor()
    local  c                = {r = red, g = green, b = blue}
    return c
end

function zUI.api.zSkin(f, offset, square, _type)
	--if not var.enable or type(f) ~= 'table' or not f.CreateTexture or f.borderTextures then return end
    if type(f) ~= 'table' or not f.CreateTexture or f.borderTextures then return end

    local t = {}

	-- for testing now
	_type = "z";
		
	--TODO TEMP
    if(square) then
		_type = "";
	end

	offset = offset or 0
	_type = _type or "";
	if square then square = "-square"; else square = ""; end
		
	for i = 1, 4 do
        local section = sections[i]
        local x = f:CreateTexture(nil, 'OVERLAY', nil, 1)
		x:SetTexture('Interface\\AddOns\\zUI\\img\\borders\\'.._type..'border-'..section..square..'.tga')
        t[sections[i]] = x
    end

	for i = 5, 8 do
		local section = sections[i]
        local x = f:CreateTexture(nil, 'OVERLAY', nil, 1)
		x:SetTexture('Interface\\AddOns\\zUI\\img\\borders\\'.._type..'border-'..section..'.tga');
		t[sections[i]] = x
	end

    t.TOPLEFT:SetWidth(8)       t.TOPLEFT:SetHeight(8)
    t.TOPLEFT:SetPoint('BOTTOMRIGHT', f, 'TOPLEFT', 4 + offset, -4 - offset)

    t.TOPRIGHT:SetWidth(8)      t.TOPRIGHT:SetHeight(8)
    t.TOPRIGHT:SetPoint('BOTTOMLEFT', f, 'TOPRIGHT', -4 - offset, -4 - offset)

    t.BOTTOMLEFT:SetWidth(8)    t.BOTTOMLEFT:SetHeight(8)
    t.BOTTOMLEFT:SetPoint('TOPRIGHT', f, 'BOTTOMLEFT', 4 + offset, 4 + offset)

    t.BOTTOMRIGHT:SetWidth(8)   t.BOTTOMRIGHT:SetHeight(8)
    t.BOTTOMRIGHT:SetPoint('TOPLEFT', f, 'BOTTOMRIGHT', -4 - offset, 4 + offset)

    t.TOP:SetHeight(8)
    t.TOP:SetPoint('TOPLEFT', t.TOPLEFT, 'TOPRIGHT', 0, 0)
    t.TOP:SetPoint('TOPRIGHT', t.TOPRIGHT, 'TOPLEFT', 0, 0)

    t.BOTTOM:SetHeight(8)
    t.BOTTOM:SetPoint('BOTTOMLEFT', t.BOTTOMLEFT, 'BOTTOMRIGHT', 0, 0)
    t.BOTTOM:SetPoint('BOTTOMRIGHT', t.BOTTOMRIGHT, 'BOTTOMLEFT', 0, 0)

    t.LEFT:SetWidth(8)
    t.LEFT:SetPoint('TOPLEFT', t.TOPLEFT, 'BOTTOMLEFT', 0, 0)
    t.LEFT:SetPoint('BOTTOMLEFT', t.BOTTOMLEFT, 'TOPLEFT', 0, 0)

    t.RIGHT:SetWidth(8)
    t.RIGHT:SetPoint('TOPRIGHT', t.TOPRIGHT, 'BOTTOMRIGHT', 0, 0)
    t.RIGHT:SetPoint('BOTTOMRIGHT', t.BOTTOMRIGHT, 'TOPRIGHT', 0, 0)

    f.borderTextures = t
    f.SetBorderColor = SetBorderColor
    f.GetBorderColor = GetBorderColor
end

-- [ hooksecurefunc ]
-- Hooks a global function and injects custom code
-- 'name'       [string]           name of the function that should be hooked
-- 'func'       [function]         function containing the custom code
-- 'append'     [bool]             optional variable, used to append custom
--                                 code instead of prepending it
function zUI.api.hooksecurefunc(name, func, append)
  if not _G[name] then return end

  zUI.hooks[tostring(func)] = {}
  zUI.hooks[tostring(func)]["old"] = _G[name]
  zUI.hooks[tostring(func)]["new"] = func

  if append then
    zUI.hooks[tostring(func)]["function"] = function(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
      zUI.hooks[tostring(func)]["old"](a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
      zUI.hooks[tostring(func)]["new"](a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
    end
  else
    zUI.hooks[tostring(func)]["function"] = function(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
      zUI.hooks[tostring(func)]["new"](a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
      zUI.hooks[tostring(func)]["old"](a1, a2, a3, a4, a5, a6, a7, a8, a9, a10)
    end
  end

  _G[name] = zUI.hooks[tostring(func)]["function"]
end

-- [ HookScript ]
-- Sets a function to be called automatically after the original function is called
-- 'f'          [frame]            the frame that should get a function hook
-- 'script'     [string]           the name of the function that should be hooked
-- 'func'       [function]         the function that should run after the original one
function zUI.api.HookScript(f, script, func)
	local prev = f:GetScript(script)
	f:SetScript(script, function()
		if prev then prev() end
		func()
	end)
end

-- [ Update Movable ]
-- Loads and update the configured position of the specified frame.
-- It also creates an entry in the movables table.
-- 'frame'      [frame]        the frame that should be updated.
-- 'init'       [bool]         treats the current position as initial data
function zUI.api.UpdateMovable(frame, init)
  local name = frame:GetName()

  if zUI_config.global.offscreen == "0" then
    frame:SetClampedToScreen(true)
  end

  if not zUI.movables[name] then
    zUI.movables[name] = frame
  end

  -- update position data
  if not frame.posdata or init then
    frame.posdata = { scale = frame:GetScale(), pos = {} }
    for i=1,frame:GetNumPoints() do
      frame.posdata.pos[i] = { frame:GetPoint(i) }
    end
  end

  if zUI_config["position"][frame:GetName()] then
    if zUI_config["position"][frame:GetName()]["scale"] then
      frame:SetScale(zUI_config["position"][frame:GetName()].scale)
    end

    if zUI_config["position"][frame:GetName()]["xpos"] then
      frame:ClearAllPoints()
      frame:SetPoint("TOPLEFT", zUI_config["position"][frame:GetName()].xpos, zUI_config["position"][frame:GetName()].ypos)
    end
  elseif frame.posdata and frame.posdata.pos[1] then
    frame:ClearAllPoints()
    frame:SetScale(frame.posdata.scale)

    for id, point in pairs(frame.posdata.pos) do
      frame:SetPoint(unpack(point))
    end
  end
end

function zUI.api.CreateScrollFrame(name, parent)
	local f = CreateFrame("ScrollFrame", name, parent)

	-- create slider
	f.slider = CreateFrame("Slider", nil, f)
	f.slider:SetOrientation('VERTICAL')
	f.slider:SetPoint("TOPLEFT", f, "TOPRIGHT", -7, 0)
	f.slider:SetPoint("BOTTOMRIGHT", 0, 0)
	--f.slider:SetThumbTexture("Interface\\AddOns\\zUI\\img\\col")
	f.slider:SetThumbTexture("Interface\\BUTTONS\\WHITE8X8")
	f.slider.thumb = f.slider:GetThumbTexture()
	f.slider.thumb:SetHeight(50)
	f.slider.thumb:SetTexture(1,0.82,0,.6) --.3,1,.8,.5 zUI , 0,0.56,1,.5 nice blue

	f.slider:SetScript("OnValueChanged", function()
		f:SetVerticalScroll(this:GetValue())
		f.UpdateScrollState()
	end)

	f.UpdateScrollState = function()
		f.slider:SetMinMaxValues(0, f:GetVerticalScrollRange())
		f.slider:SetValue(f:GetVerticalScroll())

		local m = f:GetHeight()+f:GetVerticalScrollRange()
		local v = f:GetHeight()
		local ratio = v / m

		if ratio < 1 then
			local size = math.floor(v * ratio)
			f.slider.thumb:SetHeight(size)
			f.slider:Show()
		else
			f.slider:Hide()
		end
	end

	f.Scroll = function(self, step)
		local step = step or 0

		local current = f:GetVerticalScroll()
		local max = f:GetVerticalScrollRange()
		local new = current - step

		if new >= max then
			f:SetVerticalScroll(max)
		elseif new <= 0 then
			f:SetVerticalScroll(0)
		else
			f:SetVerticalScroll(new)
		end

		f:UpdateScrollState()
	end

	f:EnableMouseWheel(1)
	f:SetScript("OnMouseWheel", function()
		this:Scroll(arg1*10)
	end)

	return f
end

function zUI.api.CreateScrollChild(name, parent)
	local f = CreateFrame("Frame", name, parent)

	-- dummy values required
	f:SetWidth(1)
	f:SetHeight(1)
	f:SetAllPoints(parent)
	
	parent:SetScrollChild(f)

	-- OnShow is fired too early, postpone to the first frame draw
	f:SetScript("OnUpdate", function()
		this:GetParent():Scroll()
		this:SetScript("OnUpdate", nil)
	end)

	return f
end

function zUI.api.SetAllPointsOffset(frame, parent, offset)
	frame:SetPoint("TOPLEFT", parent, "TOPLEFT", offset, -offset)
	frame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -offset, offset)
end

-- [ Create Backdrop ]
-- Creates a zUI compatible frame as backdrop element
-- 'f'          [frame]         the frame which should get a backdrop.
-- 'inset'      [int]           backdrop inset, defaults to border size.
-- 'legacy'     [bool]          use legacy backdrop instead of creating frames.
-- 'transp'     [number]        set default transparency
function zUI.api.CreateBackdrop(f, inset, legacy, transp, backdropSetting)
  -- exit if now frame was given
  if not f then return end

  -- use default inset if nothing is given
  local border = inset
  if not border then
    border = tonumber(zUI_config.appearance.border.default)
  end

  local br, bg, bb, ba = zUI.api.GetStringColor(zUI_config.appearance.border.background)
  local er, eg, eb, ea = zUI.api.GetStringColor(zUI_config.appearance.border.color)

  if transp and transp < tonumber(ba) then ba = transp end

  -- use legacy backdrop handling
  if legacy then
    local backdrop = zUI.backdrop
    if backdropSetting then backdrop = backdropSetting end
    f:SetBackdrop(backdrop)
    f:SetBackdropColor(br, bg, bb, ba)
    f:SetBackdropBorderColor(er, eg, eb , ea)
  else
    -- increase clickable area if available
    if f.SetHitRectInsets then
      f:SetHitRectInsets(-border,-border,-border,-border)
    end

    -- use new backdrop behaviour
    if not f.backdrop then
      f:SetBackdrop(nil)

      local backdrop = zUI.backdrop
      local b = CreateFrame("Frame", nil, f)
      if tonumber(border) > 1 then
        local border = tonumber(border) - 1
        backdrop.insets = {left = -1, right = -1, top = -1, bottom = -1}
        b:SetPoint("TOPLEFT", f, "TOPLEFT", -border, border)
        b:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", border, -border)
      else
        local border = tonumber(border)
        backdrop.insets = {left = 0, right = 0, top = 0, bottom = 0}
        b:SetPoint("TOPLEFT", f, "TOPLEFT", -border, border)
        b:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", border, -border)
      end

      local level = f:GetFrameLevel()
      if level < 1 then
        b:SetFrameLevel(level)
      else
        b:SetFrameLevel(level - 1)
      end

      f.backdrop = b
      b:SetBackdrop(backdrop)
    end

    local b = f.backdrop
    b:SetBackdropColor(br, bg, bb, ba)
    b:SetBackdropBorderColor(er, eg, eb , ea)
  end

  -- add shadow
  if not f.backdrop_shadow and zUI_config.appearance.border.shadow == "1" then
    local size = 8
    local inset = size-1
    local anchor = f.backdrop or f
    local intensity = tonumber(zUI_config.appearance.border.shadow_intensity)

    f.backdrop_shadow = CreateFrame("Frame", nil, anchor)
    f.backdrop_shadow:SetFrameStrata("BACKGROUND")
    f.backdrop_shadow:SetFrameLevel(1)

    f.backdrop_shadow:SetPoint("TOPLEFT", anchor, "TOPLEFT", -inset, inset)
    f.backdrop_shadow:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", inset, -inset)
    f.backdrop_shadow:SetBackdrop({
      edgeFile = "Interface\\AddOns\\zUI\\img\\glow2", edgeSize = size,
      insets = {left = 0, right = 0, top = 0, bottom = 0},
    })
    f.backdrop_shadow:SetBackdropBorderColor(0,0,0,intensity)
  end
end

-- [ Question Dialog ]
-- Creates a zUI infobox popup window:
-- 'text'       [string]        text that will be displayed.
-- 'time'       [number]        time in seconds till the popup will be faded
-- 'parent'     [frame]         frame which will be used as parent for the dialog (defaults to UIParent)
-- 'height'     [number]        manual height of the popup (defaults to 100)
function zUI.api.CreateInfoBox(text, time, parent, height)
  if not text then return end
  if not time then time = 5 end
  if not parent then parent = UIParent end
  if not height then height = 100 end

  local infobox = zInfoBox
  if not infobox then
    infobox = CreateFrame("Button", "zInfoBox", UIParent)
    infobox:Hide()

    infobox:SetScript("OnUpdate", function()
      local time = infobox.lastshow + infobox.duration - GetTime()
      --infobox.timeout:SetValue(time)

      if GetTime() > infobox.lastshow + infobox.duration then
        infobox:SetAlpha(infobox:GetAlpha()-0.05)

        if infobox:GetAlpha() <= 0.1 then
          infobox:Hide()
          infobox:SetAlpha(1)
        end
      elseif MouseIsOver(this) then
        this:SetAlpha(max(0.4, this:GetAlpha() - .1))
      else
        this:SetAlpha(min(1, this:GetAlpha() + .1))
      end
    end)

    infobox:SetScript("OnClick", function()
      this:Hide()
    end)

    infobox.text = infobox:CreateFontString("Status", "HIGH", "GameFontNormal")
    infobox.text:ClearAllPoints()
    infobox.text:SetFontObject(GameFontWhite)

    --infobox.timeout = CreateFrame("StatusBar", nil, infobox)
    --infobox.timeout:SetStatusBarTexture("Interface\\AddOns\\zUI\\img\\bar")
    --infobox.timeout:SetStatusBarColor(.3,1,.8,1)

    infobox:ClearAllPoints()
    infobox.text:SetAllPoints(infobox)
    infobox.text:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")

    --zUI.api.CreateBackdrop(infobox)
	
	infobox:SetBackdrop({bgFile     = [[Interface\ChatFrame\ChatFrameBackground]],
								tiled      = false,
								insets     = {left = 1, right = 1, top = 1, bottom = 1}})
	infobox:SetBackdropColor(0, 0, 0, 0.9)
	zStyle_Button(infobox)
    infobox:SetPoint("TOP", 0, -25)
	
   -- infobox.timeout:ClearAllPoints()
    --infobox.timeout:SetPoint("TOPLEFT", infobox, "TOPLEFT", 3, -3)
    --infobox.timeout:SetPoint("TOPRIGHT", infobox, "TOPRIGHT", -3, 3)
    --infobox.timeout:SetHeight(2)
  end

  infobox.text:SetText(text)
  --infobox.timeout:SetMinMaxValues(0, time)
  --infobox.timeout:SetValue(time)

  infobox.duration = time
  infobox.lastshow = GetTime()

  infobox:SetWidth(infobox.text:GetStringWidth() + 50)
  infobox:SetParent(parent)
  infobox:SetHeight(height)

  infobox:SetFrameStrata("FULLSCREEN_DIALOG")
  infobox:Show()
end

-- [ GetDefaultColors ]
-- Queries the zUI setting strings and extract its color codes
-- returns r,g,b,a
local color_cache = {}
function zUI.api.GetStringColor(colorstr)
  if not color_cache[colorstr] then
    local r, g, b, a = zUI.api.strsplit(",", colorstr)
    color_cache[colorstr] = { r, g, b, a }
  end
  return unpack(color_cache[colorstr])
end

-- [ strsplit ]
-- Splits a string using a delimiter.
-- 'delimiter'  [string]        characters that will be interpreted as delimiter
--                              characters (bytes) in the string.
-- 'subject'    [string]        String to split.
-- return:      [list]          a list of strings.
function zUI.api.strsplit(delimiter, subject)
	local delimiter, fields = delimiter or ":", {}
	local pattern = string.format("([^%s]+)", delimiter)
	string.gsub(subject, pattern, function(c) fields[table.getn(fields)+1] = c end)
	return unpack(fields)
end

-- [ GetCaptures ]
-- Returns the indexes of a given regex pattern
-- 'pat'        [string]         unformatted pattern
-- returns:     [numbers]        capture indexes
local capture_cache = {}
function zUI.api.GetCaptures(pat)
	local r = capture_cache
	if not r[pat] then
		for a, b, c, d, e in string.gfind(gsub(pat, "%((.+)%)", "%1"), gsub(pat, "%d%$", "%%(.-)$")) do
			r[pat] = { a, b, c, d, e}
		end
	end
	if not r[pat] then return nil, nil, nil, nil end
	return r[pat][1], r[pat][2], r[pat][3], r[pat][4], r[pat][5]
end

-- [ SanitizePattern ]
-- Sanitizes and convert patterns into gfind compatible ones.
-- 'pattern'    [string]         unformatted pattern
-- returns:     [string]         simplified gfind compatible pattern
local sanitize_cache = {}
function zUI.api.SanitizePattern(pattern, dbg)
	if not sanitize_cache[pattern] then
		local ret = pattern
		-- escape magic characters
		ret = gsub(ret, "([%+%-%*%(%)%?%[%]%^])", "%%%1")
		-- remove capture indexes
		ret = gsub(ret, "%d%$","")
		-- catch all characters
		ret = gsub(ret, "(%%%a)","%(%1+%)")
		-- convert all %s to .+
		ret = gsub(ret, "%%s%+",".+")
		-- set priority to numbers over strings
		ret = gsub(ret, "%(.%+%)%(%%d%+%)","%(.-%)%(%%d%+%)")
		-- cache it
		sanitize_cache[pattern] = ret
	end
	return sanitize_cache[pattern]
end

-- [ cmatch ]
-- Same as string.match but aware of capture indexes (up to 5)
-- 'str'        [string]         input string that should be matched
-- 'pat'        [string]         unformatted pattern
-- returns:     [strings]        matched string in capture order
function zUI.api.cmatch(str, pat)
	-- read capture indexes
	local a,b,c,d,e = GetCaptures(pat)
	local _, _, va, vb, vc, vd, ve = string.find(str, zUI.api.SanitizePattern(pat))

	-- put entries into the proper return values
	local ra, rb, rc, rd, re
	ra = e == "1" and ve or d == "1" and vd or c == "1" and vc or b == "1" and vb or va
	rb = e == "2" and ve or d == "2" and vd or c == "2" and vc or a == "2" and va or vb
	rc = e == "3" and ve or d == "3" and vd or a == "3" and va or b == "3" and vb or vc
	rd = e == "4" and ve or a == "4" and va or c == "4" and vc or b == "4" and vb or vd
	re = a == "5" and va or d == "5" and vd or c == "5" and vc or b == "5" and vb or ve

	return ra, rb, rc, rd, re
end

-- [ Bar Button Anchor ] --
-- 'button'  frame reference
-- 'basename'  name of button frame without index
-- 'buttonindex'  index number of button on bar
-- 'formfactor'  string formfactor in cols x rows
function zUI.api.BarButtonAnchor(button,basename,buttonindex,barsize,formfactor,iconsize,bordersize)
  assert(barsize > 0 and barsize <= NUM_ACTIONBAR_BUTTONS,"BarButtonAnchor: barsize "..tostring(barsize).." is invalid")
  local formfactor = zUI.api.BarLayoutFormfactor(formfactor)
  local parent = button:GetParent()
  local cols, rows = unpack(zGridmath[barsize][formfactor])
  if buttonindex == 1 then
    button._anchor = {"TOPLEFT", parent, "TOPLEFT", bordersize, -bordersize}
  else
    local col = buttonindex-((math.ceil(buttonindex/cols)-1)*cols)
    button._anchor = col==1 and {"TOP",getglobal(basename..(buttonindex-cols)),"BOTTOM",0,-(bordersize*3)} or {"LEFT",getglobal(basename..(buttonindex-1)),"RIGHT",(bordersize*3),0}
  end
  return button._anchor
end

-- [ Bar Layout Formfactor ] --
-- 'option'  string option as used in zUI_config.bars[bar].option
-- returns:  integer formfactor
local formfactors = {} -- we'll use memoization so we only compute once, then lookup.
setmetatable(formfactors, {__mode = "v"}) -- weak table so values not referenced are collected on next gc
function zUI.api.BarLayoutFormfactor(option)
  if formfactors[option] then
    return formfactors[option]
  else
    for barsize,_ in ipairs(zGridmath) do
      local options = zUI.api.BarLayoutOptions(barsize)
      for i,opt in ipairs(options) do
        if opt == option then
          formfactors[option] = i
          return formfactors[option]
        end
      end
    end
  end
end

-- [ Bar Layout Options ] --
-- 'barsize'  size of bar in number of buttons
-- returns:   array of options as strings for zUI.gui.bar
function zUI.api.BarLayoutOptions(barsize)
  assert(barsize > 0 and barsize <= NUM_ACTIONBAR_BUTTONS,"BarLayoutOptions: barsize "..tostring(barsize).." is invalid")
  local options = {}
  for i,layout in ipairs(zGridmath[barsize]) do
    options[i] = string.format("%d x %d",layout[1],layout[2])
  end
  return options
end

-- [ Bar Layout Size ] --
-- 'bar'  frame reference,
-- 'barsize'  integer number of buttons,
-- 'formfactor'  string formfactor in cols x rows,
-- 'visiblesize' integer buttons actually spawned
function zUI.api.BarLayoutSize(bar,barsize,formfactor,iconsize,bordersize,visiblesize)
  assert(barsize > 0 and barsize <= NUM_ACTIONBAR_BUTTONS,"BarLayoutSize: barsize "..tostring(barsize).." is invalid")
  local formfactor = zUI.api.BarLayoutFormfactor(formfactor)
  local cols, rows = unpack(zGridmath[barsize][formfactor])
  if (visiblesize) and (visiblesize < barsize) then
    cols = math.min(cols,visiblesize)
    rows = math.min(math.ceil(visiblesize/cols),visiblesize)
  end
  local width = (iconsize + bordersize*3) * cols - bordersize
  local height = (iconsize + bordersize*3) * rows - bordersize
  bar._size = {width,height}
  return bar._size
end

-- [ Save Movable ]
-- Save the positions of a Frame.
-- 'frame'      [frame]        the frame that should be saved.
function zUI.api.SaveMovable(frame)
	local _, _, _, xpos, ypos = frame:GetPoint()
	if not C.position[frame:GetName()] then
		C.position[frame:GetName()] = {}
	end

	C.position[frame:GetName()]["xpos"] = round(xpos)
	C.position[frame:GetName()]["ypos"] = round(ypos)
end

-- [ Load Movable ]
-- Loads the positions of a Frame.
-- 'frame'      [frame]        the frame that should be positioned.
function zUI.api.LoadMovable(frame)
  if zUI_config["position"][frame:GetName()] then
    if zUI_config["position"][frame:GetName()]["scale"] then
      frame:SetScale(zUI_config["position"][frame:GetName()].scale)
    end

    if zUI_config["position"][frame:GetName()]["xpos"] then
      frame:ClearAllPoints()
      frame:SetPoint("TOPLEFT", zUI_config["position"][frame:GetName()].xpos, zUI_config["position"][frame:GetName()].ypos)
    end
  end
end

function zUI.api.calc(arg1)
	if arg1=="" then 
		--Calc_OpenFrame()
		zUI.zCalculator.Calc_OpenFrame()
		zPrint("Open calc frame");
	else
		local x,y=string.find(arg1,"%p?%d*%p?%d*")
		num1 = string.sub(arg1,x,y)
		local h,k=string.find(arg1,"%a*",y+2)
		fun  = string.sub(arg1,h,k)
		local a,z=string.find(arg1,"%p?%d*%p?%d*",k+2)
		num2 = string.sub(arg1,a,z)

		if fun=="plus" then 
			zPrint(num1.." + "..num2.." = "..tonumber(num1)+tonumber(num2)) 
			CalcText = tonumber(num1)+tonumber(num2)
		elseif fun=="minus" then 
			zPrint(num1.." - "..num2.." = "..tonumber(num1)-tonumber(num2)) 
			CalcText = tonumber(num1)-tonumber(num2)
		elseif fun=="times" or fun=="*" then 
			zPrint(num1.." x "..num2.." = "..tonumber(num1)*tonumber(num2)) 
			CalcText = tonumber(num1)*tonumber(num2)
		elseif fun=="divided by" or fun=="divide" then 
			zPrint(num1.." / "..num2.." = "..tonumber(num1)/tonumber(num2)) 
			CalcText = tonumber(num1)/tonumber(num2)
		elseif fun=="caret" or fun=="power" then 
			zPrint(num1.." ^ "..num2.." = "..tonumber(num1)^tonumber(num2)) 
			CalcText = tonumber(num1)^tonumber(num2)
		elseif fun=="root"then 
			zPrint(num2.."th root of "..num1.." = "..tonumber(num1)^(1/tonumber(num2))) 
			CalcText = tonumber(num1)^(1/tonumber(num2))
		end
	end
end

-- [ round ]
-- Rounds a float number into specified places after comma.
-- 'input'      [float]         the number that should be rounded.
-- 'places'     [int]           amount of places after the comma.
-- returns:     [float]         rounded number.
function zUI.api.round(input, places)
	if not places then places = 0 end
	if type(input) == "number" and type(places) == "number" then
		local pow = 1
		for i = 1, places do pow = pow * 10 end
	return floor(input * pow + 0.5) / pow
	end
end

-- [ clamp ]
-- Clamps a number between given range.
-- 'x'          [number]        the number that should be clamped.
-- 'min'        [number]        minimum value.
-- 'max'        [number]        maximum value.
-- returns:     [number]        clamped value: 'x', 'min' or 'max' value itself.
function zUI.api.clamp(x, min, max)
  if type(x) == "number" and type(min) == "number" and type(max) == "number" then
    return x < min and min or x > max and max or x
  else
    return x
  end
end

-- [ Create Gold String ]
-- Transforms a amount of copper into a fully fledged gold string
-- 'money'      [int]           the amount of coppy (GetMoney())
-- return:      [string]        a colorized string which is split into
--                              gold,silver and copper values.
function zUI.api.CreateGoldString(money)
  if type(money) ~= "number" then return "-" end

  local gold = floor(money/ 100 / 100)
  local silver = floor(mod((money/100),100))
  local copper = floor(mod(money,100))

  local string = ""
  if gold > 0 then string = string .. "|cffffffff" .. gold .. "|cffffd700g" end
  if silver > 0 then string = string .. "|cffffffff " .. silver .. "|cffc7c7cfs" end
  string = string .. "|cffffffff " .. copper .. "|cffeda55fc"

  return string
end

local keymap = {
		["BonusActionButton"]         = "ACTIONBUTTON",
		["MultiBarBottomLeftButton"]  = "MULTIACTIONBAR1BUTTON",
		["MultiBarBottomRightButton"] = "MULTIACTIONBAR2BUTTON",
		["MultiBarRightButton"]       = "MULTIACTIONBAR3BUTTON",
		["MultiBarLeftButton"]        = "MULTIACTIONBAR4BUTTON",
		["ShapeshiftButton"]          = "SHAPESHIFTBUTTON",
		["PetActionButton"]           = "BONUSACTIONBUTTON",
	}

function zUI.api.zGetBinding(button_name)
	local found,_,buttontype,buttonindex = string.find(button_name,"^(%a+)(%d+)$")
	if found then
		if keymap[buttontype] then
			return string.format("%s%d",keymap[buttontype],buttonindex)
		elseif buttontype == "ActionButton" then
			return string.format("ACTIONBUTTON%d",buttonindex)
		else
			return nil
		end
	else
		return nil
	end
end

-- TODO: maybe merge zGetBindingText and zGetBinding...
function zUI.api.zGetBindingText(msg, mod, abbrev)
	local txt = GetBindingText(msg, mod, abbrev)
	if abbrev then
		txt = string.gsub(txt, _G[string.format("%s%s", mod, "BUTTON3")], "M3")
		txt = string.gsub(txt, _G[string.format("%s%s", mod, "BUTTON4")], "M4")
		txt = string.gsub(txt, _G[string.format("%s%s", mod, "BUTTON5")], "M5")
		txt = string.gsub(txt, _G[string.format("%s%s", mod, "MOUSEWHEELDOWN")], "MWD")
		txt = string.gsub(txt, _G[string.format("%s%s", mod, "MOUSEWHEELUP")], "MWU")
	end
	return txt
end

function zUI.api.SetupHotkeyString(parent)
	if (parent) then
		-- Create new frame to hold our hotkey string
		local f = CreateFrame("Frame", nil, parent);
		f.keybind = f:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmallGray");
		f:RegisterEvent("UPDATE_BINDINGS");
		SetAllPointsOffset(f.keybind, parent, 0, 0);
		if (zUI_config.hotkeys.blizzard_font == "0") then
			f.keybind:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE");
		end
		f.keybind:SetTextColor(unpack({ strsplit(",", C.hotkeys.color) }));
		f.keybind:SetJustifyH("RIGHT")
		f.keybind:SetJustifyV("TOP")
		f.keybind:SetNonSpaceWrap(false)
		f.parentName = parent:GetName();
		-- hide blizzard hotkey string
		if ( _G[f.parentName..'HotKey'] ) then _G[f.parentName..'HotKey']:Hide(); end
		--local hk = _G[f.parentName..'HotKey'] if (hk) then hk:Hide(); end
		f:SetScript("OnEvent", function()
			if (this.keybind) then
				local binding = zGetBinding(f.parentName);
				local t     = zGetBindingText(GetBindingKey(binding), 'KEY_', 1)
				this.keybind:SetText(t)
			end
		end)
	end
end

-- [ SendChatMessageWide ]
-- Sends a message to widest audience the player can broadcast to
-- 'msg'        [string]          the message to send
function zUI.api.SendChatMessageWide(msg)
	local channel = "SAY"
	if UnitInRaid("player") then
		if ( IsRaidLeader() or IsRaidOfficer() ) then
			channel = "RAID_WARNING"
		else
			channel = "RAID"
		end
	elseif UnitExists("party1") then
		channel = "PARTY"
	end
	SendChatMessage(msg,channel)
end

-- [ QueueFunction ]
-- Add functions to a FIFO queue for execution after a short delay.
-- '...'        [vararg]        function, [arguments]
local timer
function zUI.api.QueueFunction(a1,a2,a3,a4,a5,a6,a7,a8,a9)
	if not timer then
		timer = CreateFrame("Frame")
		timer.queue = {}
		timer.interval = TOOLTIP_UPDATE_TIME
		timer.DeQueue = function()
			local item = table.remove(timer.queue,1)
			if item then
				item[1](item[2],item[3],item[4],item[5],item[6],item[7],item[8],item[9])
			end
			if table.getn(timer.queue) == 0 then
				timer:Hide() -- no need to run the OnUpdate when the queue is empty
			end
		end
		timer:SetScript("OnUpdate",function()
			this.sinceLast = (this.sinceLast or 0) + arg1
			while (this.sinceLast > this.interval) do
				this.DeQueue()
				this.sinceLast = this.sinceLast - this.interval
			end
		end)
	end
	table.insert(timer.queue,{a1,a2,a3,a4,a5,a6,a7,a8,a9})
	timer:Show() -- start the OnUpdate
end

-- [ Wipe Table ]
-- Empties a table and returns it
-- 'src'      [table]         the table that should be emptied.
-- return:    [table]         the emptied table.
function zUI.api.wipe(src)
	-- notes: table.insert, table.remove will have undefined behavior
	-- when used on tables emptied this way because Lua removes nil
	-- entries from tables after an indeterminate time.
	-- Instead of table.insert(t,v) use t[table.getn(t)+1]=v as table.getn collapses nil entries.
	-- There are no issues with hash tables, t[k]=v where k is not a number behaves as expected.
	local mt = getmetatable(src) or {}
	if mt.__mode == nil or mt.__mode ~= "kv" then
		mt.__mode = "kv"
		src=setmetatable(src,mt)
	end
	for k in pairs(src) do
		src[k] = nil
	end
	return src
end

-- [ GroupInfoByName ]
-- Gets the unit id by name
-- 'name'       [string]          party or raid member
-- 'group'      [string]          "raid" or "party"
-- returns:     [table]           {name='name',unitId='unitId',Id=Id,lclass='lclass',class='class'}
do -- create a scope so we don't have to worry about upvalue collisions
  local party, raid, unitinfo = {}, {}, {}
  party[0] = "player" -- fake unit
  for i=1, MAX_PARTY_MEMBERS do
    party[i] = "party"..i
  end
  for i=1, MAX_RAID_MEMBERS do
    raid[i] = "raid"..i
  end
  function zUI.api.GroupInfoByName(name,group)
    unitinfo = zUI.api.wipe(unitinfo)
    if group == "party" then
      for i=0, MAX_PARTY_MEMBERS do
        local unitName = UnitName(party[i])
        if unitName == name then
          local lclass,class = UnitClass(party[i])
          if not (lclass and class) then
            lclass,class = _G.UNKNOWN, "UNKNOWN"
          end
          unitinfo.name,unitinfo.unitId,unitinfo.Id,unitinfo.lclass,unitinfo.class =
            unitName,party[i],i,lclass,class
          return unitinfo
        end
      end
    elseif group == "raid" then
      for i=1, MAX_RAID_MEMBERS do
        local unitName = UnitName(raid[i])
        if unitName == name then
          local lclass,class = UnitClass(raid[i])
          if not (lclass and class) then
            lclass,class = _G.UNKNOWN, "UNKNOWN"
          end
          unitinfo.name,unitinfo.unitId,unitinfo.Id,unitinfo.lclass,unitinfo.class =
            unitName,raid[i],i,lclass,class
          return unitinfo
        end
      end
    end
    -- fallback for GetMasterLootCandidate not updating immediately for leavers
    unitinfo.lclass,unitinfo.class = _G.UNKNOWN, "UNKNOWN"
    return unitinfo
  end
end

-- [ GetItemLinkByName ]
-- Returns an itemLink for the given itemname
-- 'name'       [string]         name of the item
-- returns:     [string]         entire itemLink for the given item
function zUI.api.GetItemLinkByName(name)
	for itemID = 1, 25818 do
		local itemName, hyperLink, itemQuality = GetItemInfo(itemID)
		if (itemName and itemName == name) then
			local _, _, _, hex = GetItemQualityColor(tonumber(itemQuality))
			return hex.. "|H"..hyperLink.."|h["..itemName.."]|h|r"
		end
	end
end

-- [ GetColoredTime ] --
-- 'remaining'   the time in seconds that should be converted
-- return        a colored string including a time unit (m/h/d)
function zUI.api.GetColoredTimeString(remaining)
	if not remaining then return "" end
	if remaining > 99 * 60 * 60 then
		local r,g,b,a = zUI.api.GetStringColor(C.appearance.cd.daycolor)
		return "|cff" .. string.format("%02x%02x%02x", r*255, g*255, b*255) .. round(remaining / 60 / 60 / 24) .. "|rd"
	elseif remaining > 99 * 60 then
		local r,g,b,a = zUI.api.GetStringColor(C.appearance.cd.hourcolor)
		return "|cff" .. string.format("%02x%02x%02x", r*255, g*255, b*255) .. round(remaining / 60 / 60) .. "|rh"
	elseif remaining > 99 then
		local r,g,b,a = zUI.api.GetStringColor(C.appearance.cd.minutecolor)
		return "|cff" .. string.format("%02x%02x%02x", r*255, g*255, b*255) .. round(remaining / 60) .. "|rm"
	elseif remaining <= 5 then
		local r,g,b,a = zUI.api.GetStringColor(C.appearance.cd.lowcolor)
		--return "|cff" .. string.format("%02x%02x%02x", r*255, g*255, b*255) .. string.format("%.1f", round(remaining,1))
		return "|cff" .. string.format("%02x%02x%02x", r*255, g*255, b*255) .. round(remaining)
	elseif remaining >= 0 then
		local r, g, b, a = zUI.api.GetStringColor(C.appearance.cd.normalcolor)
		return "|cff" .. string.format("%02x%02x%02x", r*255, g*255, b*255) .. round(remaining)
	else
		return ""
	end
end

zUI.api.gfind = string.gfind
