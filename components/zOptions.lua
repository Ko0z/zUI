-- Option frame system credits to Shagu, pfUI
zUI:RegisterComponent("zOptions", function ()

ZUI_MINIMAPBUTTON_LINE1 = "Click to toggle Options"
ZUI_MINIMAPBUTTON_LINE2 = "Right-click and drag"

zUI.MinimapButtonFrame = CreateFrame("frame", "zMiniMapButtonFrame", Minimap);
zMiniMapButtonFrame:EnableMouse(true);
zMiniMapButtonFrame:SetFrameStrata("LOW");
zMiniMapButtonFrame:SetWidth(32);
zMiniMapButtonFrame:SetHeight(32);
zMiniMapButtonFrame:SetPoint("TOPLEFT", Minimap, "RIGHT", 2, 0);
zMiniMapButtonFrame:RegisterEvent("VARIABLES_LOADED");

zMiniMapButtonFrame.Button = CreateFrame("Button", "zMiniMapButton", zMiniMapButtonFrame);
zMiniMapButton:SetAllPoints(zMiniMapButtonFrame);

--zMiniMapButton:SetNormalTexture("Interface\\AddOns\\zUI\\img\\minibutton\\zUIMapButton3");
zMiniMapButton:SetNormalTexture("Interface\\AddOns\\zUI\\img\\zUIMapButton-Up3");
zMiniMapButton:SetPushedTexture("Interface\\AddOns\\zUI\\img\\zUIMapButton-Down");
zMiniMapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight");

zMiniMapButtonFrame:SetScript("OnEvent", function()
	if(event == "VARIABLES_LOADED") then
		zMiniMapButton:RegisterForClicks("LeftButtonDown", "RightButtonDown");
		zMiniMapButton:RegisterForDrag("RightButton");
		zMiniMapButton.dragStart = false;
		zUI_Button_UpdatePosition();
		--zUI.MinimapButton_Init();
	end
end)
zMiniMapButton:SetScript("OnDragStart", function()	zMiniMapButton.dragStart = true;  end)
zMiniMapButton:SetScript("OnDragStop", function()	zMiniMapButton.dragStart = false; end)
zMiniMapButton:SetScript("OnUpdate", function()	
	if (zMiniMapButton.dragStart == true) then
		zUI_Button_BeingDragged();
	end
end)

zMiniMapButton:SetScript("OnClick", function()
	if arg1=="LeftButton" then
		if zUI.gui:IsShown() then
			zUI.gui:Hide()
		else
			zUI.gui:Show()
		end
    end
end)

zMiniMapButton:SetScript("OnEnter", function()
	GameTooltip:SetOwner(this, "ANCHOR_LEFT");
    GameTooltip:AddLine(ZUI_MINIMAPBUTTON_LINE1);
    GameTooltip:AddLine(ZUI_MINIMAPBUTTON_LINE2);
    GameTooltip:Show();
end)

zMiniMapButton:SetScript("OnLeave", function()
	GameTooltip:Hide();
end)

-------------------------------------------------------------------
function zUI_Button_UpdatePosition()
	zMiniMapButtonFrame:SetPoint(
		"TOPLEFT",
		"Minimap",
		"TOPLEFT",
		54 - (78 * cos(zUI_config.minimap.button_pos)), 
		(78 * sin(zUI_config.minimap.button_pos)) - 55
	);
end

function zUI_Button_BeingDragged()
	
    local x,y = GetCursorPosition() 
    local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom() 
	
    x = xmin-x/UIParent:GetScale()+70 
    y = y/UIParent:GetScale()-ymin-70 

    zUI_Button_SetPosition(math.deg(math.atan2(y,x)));
end

function zUI_Button_SetPosition(v)
    if(v < 0) then
        v = v + 360;
    end
    zUI_config.minimap.button_pos = v;
    zUI_Button_UpdatePosition();
end

if (C.minimap.button_hide == "1") then
	zMiniMapButtonFrame:Hide();
end
-------------------------------------------------------------------


	local Reload, U, PrepareDropDownButton, CreateConfig, CreateTabFrame, CreateArea, CreateGUIEntry, EntryUpdate
	
	StaticPopupDialogs["CHANGES_RELOAD"] = {
		text = "Reload UI for changes to take effect.",
		button1 = "Reload UI",
		button2 = "Ignore",
		OnAccept = function()
			
			ReloadUI();
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true
	}

	do
		function Reload()
			--CreateQuestionDialog("Some settings need to reload the UI to take effect.\nDo you want to reload now?", function()
			--	zUI.gui.settingChanged = nil
			--	ReloadUI()
			--end)
			StaticPopup_Show("CHANGES_RELOAD");
		end
		
		U = setmetatable({}, { __index = function(tab,key)
			  local ufunc
			  if zUI[key] and zUI[key].UpdateConfig then
					ufunc = function() return zUI[key]:UpdateConfig() end
			  elseif zUI.uf and zUI.uf[key] and zUI.uf[key].UpdateConfig then
					ufunc = function() return zUI.uf[key]:UpdateConfig() end
			  end
			  if ufunc then
					rawset(tab,key,ufunc)
					return ufunc
			  end
		end})

		function PrepareDropDownButton(index)
			if index > _G.UIDROPDOWNMENU_MAXBUTTONS then
				for i=1,3 do
					local name = "DropDownList" .. i .. "Button" .. index
					local parent = _G["DropDownList" .. i]
					_G.UIDROPDOWNMENU_MAXBUTTONS = index
					_G[name] = CreateFrame("Button", name, parent, "UIDropDownMenuButtonTemplate")
					_G[name]:SetID(index)
				end
			end
		end

		function EntryUpdate()
			if MouseIsOver(this) and not this.over then
				this.tex:Show()
				this.over = true
			elseif not MouseIsOver(this) and this.over then
				this.tex:Hide()
				this.over = nil
			end
		end

		function CreateConfig(ufunc, caption, category, config, widget, values, skip, named, type)
			-- this object placement
			if this.objectCount == nil then
				this.objectCount = 0
			elseif not skip then
				this.objectCount = this.objectCount + 1
				this.lineCount = 1
			end

			if skip then
				if this.lineCount == nil then
					this.lineCount = 1
				end

				if skip then
					this.lineCount = this.lineCount + 1
				end
			end

			if not caption then return end

			-- basic frame
			local frame = CreateFrame("Frame", nil, this)
			frame:SetWidth(this.parent:GetRight()-this.parent:GetLeft()-20)
			frame:SetHeight(22)
			frame:SetPoint("TOPLEFT", this, "TOPLEFT", 5, (this.objectCount*-23)-5)

			-- populate search index
			--if caption and this and this.GetParent and widget ~= "button" and widget ~= "header" then
			--	local id = tostring(frame)
			--
			--	searchDB[id] = searchDB[id] or { }
			--	searchDB[id][0] = caption
			--	searchDB[id][-1] = frame
			--
			--	-- scrollchild scrollframe  Area        Area        Btton
			--	-- this        .parent      :GetParent():GetParent().button
			--	-- this        .parent      :GetParent().button
			--	local scrollframe = this.parent
			--	while scrollframe.GetParent and scrollframe:GetParent() and scrollframe:GetParent().button do
			--		table.insert(searchDB[id], scrollframe:GetParent().button)
			--		scrollframe = scrollframe:GetParent()
			--	end
			--end

			if not widget or (widget and widget ~= "button") then

				if widget ~= "header" then
					frame:SetScript("OnUpdate", EntryUpdate)
					frame.tex = frame:CreateTexture(nil, "BACKGROUND")
					frame.tex:SetTexture(1,1,1,.05)
					frame.tex:SetAllPoints()
					frame.tex:Hide()
				end

				if not ufunc and widget ~= "header" and C.gui.reloadmarker == "1" then
					caption = caption .. " [|cffffaaaa!|r]"
				end

				-- caption
				frame.caption = frame:CreateFontString("Status", "LOW", "GameFontWhite")
				frame.caption:SetFont(STANDARD_TEXT_FONT, C.global.font_size)
				frame.caption:SetPoint("LEFT", frame, "LEFT", 3, 1)
				frame.caption:SetJustifyH("LEFT")
				frame.caption:SetText(caption)
			end

			if category == "CVAR" then
				category = {}
				category[config] = tostring(GetCVar(config))
				ufunc = function()
					SetCVar(this:GetParent().config, this:GetParent().category[config])
				end
			end

			--if category == "GVAR" then
			--	category = {}
			--	category[config] = tostring(_G[config] or 0)
			--
			--	local U = ufunc
			--
			--	ufunc = function()
			--		UIOptionsFrame_Load()
			--		_G[config] = this:GetChecked() and 1 or nil
			--		UIOptionsFrame_Save()
			--		if U then
			--			U()
			--		end
			--	end
			--end

			--if category == "UVAR" then
			--	category = {}
			--	category[config] = _G[config]
			--
			--	local U = ufunc
			--
			--	ufunc = function()
			--		_G[config] = this:GetChecked() and "1" or "0"
			--		if U then
			--			U()
			--		end
			--	end
			--end

			frame.category = category
			frame.config = config

			if widget == "color" then
				-- color picker
				frame.color = CreateFrame("Button", nil, frame)
				frame.color:SetWidth(24)
				frame.color:SetHeight(15)
				--CreateBackdrop(frame.color)
				zSkin(frame.color,0);
				zSkinColor(frame.color,0.3,0.3,0.3,1);
				frame.color:SetPoint("RIGHT" , -5, 0)
				frame.color.prev = frame.color:CreateTexture("OVERLAY")
				frame.color.prev:SetAllPoints(frame.color)

				local cr, cg, cb, ca = strsplit(",", category[config])
				if not cr or not cg or not cb or not ca then
					cr, cg, cb, ca = 1, 1, 1, 1
				end
				frame.color.prev:SetTexture(cr,cg,cb,ca)

				frame.color:SetScript("OnClick", function()
					local cr, cg, cb, ca = strsplit(",", category[config])
					if not cr or not cg or not cb or not ca then
					cr, cg, cb, ca = 1, 1, 1, 1
					end
					local preview = this.prev

					function ColorPickerFrame.func()
						local r,g,b = ColorPickerFrame:GetColorRGB()
						local a = 1 - OpacitySliderFrame:GetValue()

						r = round(r, 1)
						g = round(g, 1)
						b = round(b, 1)
						a = round(a, 1)

						preview:SetTexture(r,g,b,a)

						if not this:GetParent():IsShown() then
							category[config] = r .. "," .. g .. "," .. b .. "," .. a
							if ufunc then ufunc() else zUI.gui.settingChanged = true end
						end
					end

					function ColorPickerFrame.cancelFunc()
						preview:SetTexture(cr,cg,cb,ca)
					end

					ColorPickerFrame.opacityFunc = ColorPickerFrame.func
					ColorPickerFrame.element = this
					ColorPickerFrame.opacity = 1 - ca
					ColorPickerFrame.hasOpacity = 1
					ColorPickerFrame:SetColorRGB(cr,cg,cb)
					ColorPickerFrame:SetFrameStrata("DIALOG")
					ShowUIPanel(ColorPickerFrame)
				end)

				-- hide shadows on wrong stratas
				--if frame.color.backdrop_shadow then
				--	frame.color.backdrop_shadow:Hide()
				--end
			end

			if widget == "warning" then
				CreateBackdrop(frame, nil, true)
				frame:SetBackdropBorderColor(1,.5,.5)
				frame:SetHeight(50)
				frame:SetPoint("TOPLEFT", 25, this.objectCount * -35)
				this.objectCount = this.objectCount + 2
				frame.caption:SetJustifyH("CENTER")
				frame.caption:SetJustifyV("CENTER")
			end

			if widget == "header" then
				frame:SetBackdrop(nil)
				frame:SetHeight(40)
				this.objectCount = this.objectCount + 1
				frame.caption:SetJustifyH("LEFT")
				frame.caption:SetJustifyV("BOTTOM")
				frame.caption:SetTextColor(1,0.82,0,1) -- .2,1,.8,1
				frame.caption:SetAllPoints(frame)
			end

			-- use text widget (default)
			if not widget or widget == "text" then
				-- input field
				frame.input = CreateFrame("EditBox", nil, frame)
				CreateBackdrop(frame.input, nil, true)
				
				frame.input:SetTextInsets(5, 5, 5, 5)
				frame.input:SetTextColor(1,0.82,0,1) -- .2,1,.8,1 
				frame.input:SetJustifyH("RIGHT")

				frame.input:SetWidth(100)
				frame.input:SetHeight(18)
				frame.input:SetPoint("RIGHT" , -3, 0)
				frame.input:SetFontObject(GameFontNormal)
				frame.input:SetAutoFocus(false)
				frame.input:SetText(category[config])
				frame.input:SetScript("OnEscapePressed", function(self)
					this:ClearFocus()
				end)

				frame.input:SetScript("OnTextChanged", function(self)
					if ( type and type ~= "number" ) or tonumber(this:GetText()) then
					if this:GetText() ~= this:GetParent().category[this:GetParent().config] then
						this:GetParent().category[this:GetParent().config] = this:GetText()
						if ufunc then ufunc() else zUI.gui.settingChanged = true end
					end
					this:SetTextColor(1,0.82,0,1) -- .2,1,.8,1
					else
					this:SetTextColor(1,.3,.3,1)
					end
				end)

				-- hide shadows on wrong stratas
				if frame.input.backdrop_shadow then
					frame.input.backdrop_shadow:Hide()
				end
			end

			-- use button widget
			if widget == "button" then
				frame.button = CreateFrame("Button", "zButton", frame, "UIPanelButtonTemplate")
				CreateBackdrop(frame.button, nil, true)
				SkinButton(frame.button)
				frame.button:SetWidth(100)
				frame.button:SetHeight(20)
				frame.button:SetPoint("TOPRIGHT", -(this.lineCount-1) * 105, -5)
				frame.button:SetText(caption)
				frame.button:SetTextColor(1,1,1,1)
				frame.button:SetScript("OnClick", values)

				-- hide shadows on wrong stratas
				if frame.button.backdrop_shadow then
					frame.button.backdrop_shadow:Hide()
				end
			end

			-- use checkbox widget
			if widget == "checkbox" then
				-- input field
				frame.input = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
				--frame.input:SetNormalTexture("")
				--frame.input:SetPushedTexture("")
				--frame.input:SetHighlightTexture("")
				--CreateBackdrop(frame.input, nil, true)
				frame.input:SetWidth(24)
				frame.input:SetHeight(24) -- 14
				frame.input:SetPoint("RIGHT" , -5, 0)
				frame.input:SetScript("OnClick", function ()
					if this:GetChecked() then
					this:GetParent().category[this:GetParent().config] = "1"
					else
					this:GetParent().category[this:GetParent().config] = "0"
					end

					if ufunc then ufunc() else zUI.gui.settingChanged = true end
				end)

				if category[config] == "1" then frame.input:SetChecked() end

				-- hide shadows on wrong stratas
				if frame.input.backdrop_shadow then
					frame.input.backdrop_shadow:Hide()
				end
			end

			-- use dropdown widget
			--if widget == "dropdown" and values then
			--	if not zUI.gui.ddc then zUI.gui.ddc = 1 else zUI.gui.ddc = zUI.gui.ddc + 1 end
			--	local name = zUI.gui.ddc
			--	if named then name = named end
			--
			--	frame.input = CreateFrame("Frame", "zUIDropDownMenu" .. name, frame, "UIDropDownMenuTemplate")
			--	frame.input:ClearAllPoints()
			--	frame.input:SetPoint("RIGHT", 16, -3)
			--
			--	UIDropDownMenu_SetWidth(160, frame.input)
			--	UIDropDownMenu_SetButtonWidth(160, frame.input)
			--	UIDropDownMenu_JustifyText("RIGHT", frame.input)
			--	UIDropDownMenu_Initialize(frame.input, function()
			--		local info = {}
			--		frame.input.values = _G.type(values)=="function" and values() or values
			--		for i, k in pairs(frame.input.values) do
			--		-- create new dropdown buttons when we reach the limit
			--		PrepareDropDownButton(i)
			--
			--		-- get human readable
			--		local value, text = strsplit(":", k)
			--		text = text or value
			--
			--		info.text = text
			--		info.checked = false
			--		info.func = function()
			--			UIDropDownMenu_SetSelectedID(frame.input, this:GetID(), 0)
			--			UIDropDownMenu_SetText(this:GetText(), frame.input)
			--			if category[config] ~= value then
			--			category[config] = value
			--			if ufunc then ufunc() else zUI.gui.settingChanged = true end
			--			end
			--		end
			--
			--		UIDropDownMenu_AddButton(info)
			--		if category[config] == value then
			--			frame.input.current = i
			--		end
			--		end
			--	end)
			--	UIDropDownMenu_SetSelectedID(frame.input, frame.input.current)
			--
			--	SkinDropDown(frame.input)
			--	frame.input.backdrop:Hide()
			--	frame.input.button.icon:SetParent(frame.input.button.backdrop)
			--
			--	-- hide shadows on wrong stratas
			--	if frame.input.backdrop_shadow then
			--		frame.input.backdrop_shadow:Hide()
			--		frame.input.button.backdrop_shadow:Hide()
			--	end
			--end

			-- use list widget
			--if widget == "list" then
			--	if not zUI.gui.ddc then zUI.gui.ddc = 1 else zUI.gui.ddc = zUI.gui.ddc + 1 end
			--	local name = zUI.gui.ddc
			--	if named then name = named end
			--
			--	frame.input = CreateFrame("Frame", "zUIDropDownMenu" .. name, frame, "UIDropDownMenuTemplate")
			--	frame.input:ClearAllPoints()
			--	frame.input:SetPoint("RIGHT" , -22, -3)
			--	frame.category = category
			--	frame.config = config
			--
			--	frame.input.Refresh = function()
			--		local function CreateValues()
			--		for i, val in pairs({strsplit("#", category[config])}) do
			--			-- create new dropdown buttons when we reach the limit
			--			PrepareDropDownButton(i)
			--
			--			UIDropDownMenu_AddButton({
			--			["text"] = val,
			--			["checked"] = false,
			--			["func"] = function()
			--				UIDropDownMenu_SetSelectedID(frame.input, this:GetID(), 0)
			--			end
			--			})
			--		end
			--		end
			--
			--		UIDropDownMenu_Initialize(frame.input, CreateValues)
			--		UIDropDownMenu_SetText("", frame.input)
			--	end
			--
			--	frame.input:Refresh()
			--
			--	UIDropDownMenu_SetWidth(160, frame.input)
			--	UIDropDownMenu_SetButtonWidth(160, frame.input)
			--	UIDropDownMenu_JustifyText("RIGHT", frame.input)
			--	UIDropDownMenu_SetSelectedID(frame.input, frame.input.current)
			--
			--	SkinDropDown(frame.input)
			--	frame.input.backdrop:Hide()
			--	frame.input.button.icon:SetParent(frame.input.button.backdrop)
			--
			--	frame.add = CreateFrame("Button", "zUIDropDownMenu" .. name .. "Add", frame, "UIPanelButtonTemplate")
			--	SkinButton(frame.add)
			--	frame.add:SetWidth(18)
			--	frame.add:SetHeight(18)
			--	frame.add:SetPoint("RIGHT", -21, 0)
			--	frame.add:GetFontString():SetPoint("CENTER", 1, 0)
			--	frame.add:SetText("+")
			--	frame.add:SetTextColor(.5,1,.5,1)
			--	frame.add:SetScript("OnClick", function()
			--		CreateQuestionDialog(T["New entry:"], function()
			--			category[config] = category[config] .. "#" .. this:GetParent().input:GetText()
			--		end, false, true)
			--	end)
			--
			--	frame.del = CreateFrame("Button", "zUIDropDownMenu" .. name .. "Del", frame, "UIPanelButtonTemplate")
			--	SkinButton(frame.del)
			--	frame.del:SetWidth(18)
			--	frame.del:SetHeight(18)
			--	frame.del:SetPoint("RIGHT", -2, 0)
			--	frame.del:GetFontString():SetPoint("CENTER", 1, 0)
			--	frame.del:SetText("-")
			--	frame.del:SetTextColor(1,.5,.5,1)
			--	frame.del:SetScript("OnClick", function()
			--		local sel = UIDropDownMenu_GetSelectedID(frame.input)
			--		local newconf = ""
			--		for id, val in pairs({strsplit("#", category[config])}) do
			--		if id ~= sel then newconf = newconf .. "#" .. val end
			--		end
			--		category[config] = newconf
			--		frame.input:Refresh()
			--	end)
			--
			--	-- hide shadows on wrong stratas
			--	if frame.input.backdrop_shadow then
			--		frame.input.backdrop_shadow:Hide()
			--		frame.input.button.backdrop_shadow:Hide()
			--		frame.add.backdrop_shadow:Hide()
			--		frame.del.backdrop_shadow:Hide()
			--	end
			--	end

			return frame
		end

		local TabFrameOnClick = function()
			if this.area:IsShown() then
				return
			else
			-- hide all others
				for id, name in pairs(this.parent) do
					if type(name) == "table" and name.area and id ~= "parent" then
						name.area:Hide()
					end
				end
				this.area:Show()
			end
		end

		local width, height = 130, 20

		function CreateTabFrame(parent, title)
			if not parent.area.count then parent.area.count = 0 end

			local f = CreateFrame("Button", nil, parent.area)
			f:SetPoint("TOPLEFT", parent.area, "TOPLEFT", 0, -parent.area.count*height)
			f:SetPoint("BOTTOMRIGHT", parent.area, "TOPLEFT", width, -(parent.area.count+1)*height)
			f.parent = parent

			f:SetScript("OnMouseDown", TabFrameOnMouseDown)
			f:SetScript("OnClick", TabFrameOnClick)

			-- background
			f.bg = f:CreateTexture(nil, "BACKGROUND")
			f.bg:SetAllPoints()

			-- text
			f.text = f:CreateFontString(nil, "LOW", "GameFontWhite")
			--f.text:SetFont(zUI.font_default, C.global.font_size)
			f.text:SetFont(STANDARD_TEXT_FONT, C.global.font_size)
			f.text:SetAllPoints()
			f.text:SetText(title)

			-- U element count
			parent.area.count = parent.area.count + 1
			
			return f
		end

		function CreateArea(parent, title, func)
			-- create drawarea
			local f = CreateFrame("Frame", nil, parent.area)
			f:SetPoint("TOPLEFT", parent.area, "TOPLEFT", width, 0)
			f:SetPoint("BOTTOMRIGHT", parent.area, "BOTTOMRIGHT", 0, 0)

			if not parent.firstarea then
				parent.firstarea = true
			else
				f:Hide()
			end

			f.button = parent[title]

			f.bg = f:CreateTexture(nil, "BACKGROUND")
			f.bg:SetTexture(1,1,1,.05)
			f.bg:SetAllPoints()

			f:SetScript("OnShow", function()
				this.indexed = true
				this.button.text:SetTextColor(1,0.82,0,1) 
				this.button.bg:SetTexture(1,1,1,.05)
			end)

			f:SetScript("OnHide", function()
				this.button.text:SetTextColor(1,1,1,1)
				this.button.bg:SetTexture(0,0,0,0)
			end)

			-- are we a frame with contents?
			if func then
				f.scroll = CreateScrollFrame(nil, f)
				SetAllPointsOffset(f.scroll, f, 2)
				f.scroll.content = CreateScrollChild(nil, f.scroll)
				f.scroll.content.parent = f.scroll
				f.scroll.content:SetScript("OnShow", function()
					if not this.setup then
						func()
						this.setup = true
					end
				end)
			end
			return f
		end

		function CreateGUIEntry(parent, title, populate)
			-- create main menu if not yet exists
			if not zUI.gui.frames[parent] then
				zUI.gui.frames[parent] = CreateTabFrame(zUI.gui.frames, parent)
				if title then
					zUI.gui.frames[parent].area = CreateArea(zUI.gui.frames, parent, nil)
				else
					-- populate area when no submenus are given
					zUI.gui.frames[parent].area = CreateArea(zUI.gui.frames, parent, populate)
					return
				end
			end

			-- create submenus when title was given
			if title and not zUI.gui.frames[parent][title] then
				zUI.gui.frames[parent][title] = CreateTabFrame(zUI.gui.frames[parent], title)
				zUI.gui.frames[parent][title].area = CreateArea(zUI.gui.frames[parent], title, populate)
			end
		end
	end

	do -- GUI Frame
		-- main frame
		zUI.gui = CreateFrame("Frame", "zOptionsGUI", UIParent)
		zUI.gui:SetMovable(true)
		zUI.gui:EnableMouse(true)
		zUI.gui:SetWidth(620)
		zUI.gui:SetHeight(480)
		zUI.gui:SetFrameStrata("DIALOG")
		zUI.gui:SetPoint("CENTER", 0, 0)
		zUI.gui:Hide()
		
		zUI.gui:SetBackdrop({bgFile     = [[Interface\ChatFrame\ChatFrameBackground]],
								tiled      = false,
								insets     = {left = 1, right = 1, top = 1, bottom = 1}})
		zUI.gui:SetBackdropColor(0, 0, 0, 0.96)
		zUI.gui:SetMovable(true)
		zUI.gui:SetUserPlaced(true)
		zUI.gui:RegisterForDrag'LeftButton' 
		zUI.gui:EnableMouse(true)
		zUI.gui:SetScript("OnMouseDown",function() this:StartMoving() end)
		zUI.gui:SetScript("OnMouseUp",function() this:StopMovingOrSizing() end)
		
		tinsert(UISpecialFrames, "zOptionsGUI")
		
		zStyle_Button(zUI.gui) --square borders.
		zUI.gui.Reload = Reload

		zUI.gui.x = CreateFrame('Button', 'ufi_optionsCloseButton', zUI.gui, 'UIPanelCloseButton')
		zUI.gui.x:SetWidth(24)
		zUI.gui.x:SetHeight(24)
		zUI.gui.x:SetPoint('TOPRIGHT', 4, 4)
		zUI.gui.x:SetScript('OnClick', function() zUI.gui:Hide() end)

		zUI.gui:SetScript("OnShow",function()
			zUI.gui.settingChanged = zUI.gui.delaySettingChanged
			zUI.gui.delaySettingChanged = nil

			-- exit keybind mode
			if zUI.zKeybind and zUI.zKeybind:IsShown() then
				zUI.zKeybind:Hide()
			end
		end)

		zUI.gui:SetScript("OnHide",function()
			if ColorPickerFrame and ColorPickerFrame:IsShown() then
				ColorPickerFrame:Hide()
			end

			if zUI.gui.settingChanged then
				zUI.gui:Reload()
			end
			zUI.gui:Hide()
		end)

		-- decorations
		zUI.gui.title = zUI.gui:CreateFontString("Status", "LOW", "GameFontNormal")
		zUI.gui.title:SetFontObject(GameFontWhite)
		zUI.gui.title:SetPoint("TOPLEFT", zUI.gui, "TOPLEFT", 8, -8)
		zUI.gui.title:SetJustifyH("LEFT")
		zUI.gui.title:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
		zUI.gui.title:SetText("|cffffd200z|cff808080UI")

		zUI.gui.version = zUI.gui:CreateFontString("Status", "LOW", "GameFontNormal")
		zUI.gui.version:SetFontObject(NumberFontNormal)
		zUI.gui.version:SetPoint("LEFT", zUI.gui.title, "RIGHT", 0, 0)
		zUI.gui.version:SetJustifyH("LEFT")
		zUI.gui.version:SetFont("Fonts\\ARIALN.TTF", 12)
		zUI.gui.version:SetText("|cff555555[|r" .. zUI.version.string.. "|cff555555]|r")

		-- root layer
		zUI.gui.frames = {}
		zUI.gui.frames.area = CreateFrame("Frame", nil, zUI.gui)
		zUI.gui.frames.area:SetPoint("TOPLEFT", 7, -25)
		zUI.gui.frames.area:SetPoint("BOTTOMRIGHT", -7, 37)
		
		zStyle_Button(zUI.gui.frames.area)
		zSkinColor(zUI.gui.frames.area,0.2,0.2,0.2,1);
		-- hoverbind
		zUI.gui.hoverbind = CreateFrame("Button", nil, zUI.gui, "UIPanelButtonTemplate")
		zUI.gui.hoverbind:SetPoint("LEFT", zUI.gui.frames.area, "BOTTOMRIGHT", -108, -18)
		zUI.gui.hoverbind:SetWidth(110)
		zUI.gui.hoverbind:SetHeight(25)
		zUI.gui.hoverbind:SetText("Keybind")
		zUI.gui.hoverbind:SetScript("OnClick", function()
		  if zUI.zKeybind then zUI.zKeybind:Show() end
		end)
	end

	do -- Generate Config UI
		CreateGUIEntry("About", nil, function()

			local currentURL = "";
			StaticPopupDialogs['URL_GITLAB_COPY_DIALOG'] = {                              -- COPY BOX
				text            = 'URL',
				button2         = CLOSE,
				timeout         = 0,
				hasEditBox      = 1,
				maxLetters      = 1024,
				hasWideEditBox	= 1,
				whileDead       = true,
				hideOnEscape    = true,
				OnShow = function()
					(this.icon or getglobal(this:GetName()..'AlertIcon')):Hide()

					local editBox = this.editBox or getglobal(this:GetName()..'WideEditBox')
					editBox:SetText(currentURL)
					editBox:SetWidth(240)
					editBox:SetFocus()
					editBox:HighlightText(0)

					local button2 = this.button2 or getglobal(this:GetName()..'Button2')
					button2:ClearAllPoints()
					button2:SetPoint('TOP', editBox, 'BOTTOM', 0, 10)
					button2:SetWidth(150)
					currentURL = nil
				end,
			}

			this.logo = this:CreateTexture(nil, 'OVERLAY', nil, 7)

            local faction = UnitFactionGroup("player");
			if(faction) then
				this.logo:SetTexture("Interface\\AddOns\\zUI\\img\\"..faction.."-Logo")
			else
				this.logo:SetTexture("Interface\\AddOns\\zUI\\img\\Horde-Logo")
			end
			this.logo:SetWidth(128)
			this.logo:SetHeight(128)
			this.logo:SetPoint('TOPLEFT', 150, 0)

			this.welcome = this:CreateFontString("Status", "LOW", "GameFontWhite")
			this.welcome:SetFont(STANDARD_TEXT_FONT, C.global.font_size)
			this.welcome:SetPoint("TOPLEFT", 140, -160)
			this.welcome:SetWidth(200)
			this.welcome:SetJustifyH("LEFT")
			this.welcome:SetText("Thank you for trying |cffffd200z|cff808080UI")

			this.bugs = this:CreateFontString("Status", "LOW", "GameFontWhite")
			this.bugs:SetFont(STANDARD_TEXT_FONT, C.global.font_size)
			this.bugs:SetPoint("TOPLEFT", 80, -180)
			this.bugs:SetWidth(300)
			this.bugs:SetJustifyH("LEFT")
			this.bugs:SetText("If you find any bugs, please report them to the addon issues section on the github page.")
			
			local gitlab = CreateFrame("Button", nil, this, "UIPanelButtonTemplate")
			gitlab:SetPoint("TOPLEFT", 160, -225)
			gitlab:SetWidth(100)
			gitlab:SetHeight(20)
			gitlab:SetText("Github")
			gitlab:SetScript("OnClick", function()
				currentURL = "https://github.com/Ko0z/zui"
				StaticPopup_Show("URL_GITLAB_COPY_DIALOG")
			end)

		end)

		CreateGUIEntry("General", nil, function()
			CreateConfig(nil, T["Auto Hide Micro Menu"], C.global, "microbuttons_auto_hide", "checkbox")
			CreateConfig(nil, T["Show Endcaps (Gryphons)"], C.actionbars, "endcap", "checkbox")
			CreateConfig(nil, T["Enable Global Dark Mode"], C.global, "darkmode", "checkbox")
			CreateConfig(nil, T["Hide Shapeshift Buttons"], C.global, "hide_shapeshift_frame", "checkbox")
			
			CreateConfig(nil, T["Quality of Life"], nil, nil, "header")
			CreateConfig(nil, T["Auto Dismount"], C.quality, "auto_dismount", "checkbox")
			CreateConfig(nil, T["Auto Stance-Switch"], C.quality, "auto_stance", "checkbox")
			CreateConfig(nil, T["Retarget Feign Death"], C.quality, "feign_death", "checkbox")

			CreateConfig(nil, T["Swingtimer"], nil, nil, "header")
			CreateConfig(nil, T["Hide Swingtimer"], C.quality.swingtimer, "disable", "checkbox")
			CreateConfig(nil, T["Swingtimer for all classes"], C.quality.swingtimer, "enable_for_all", "checkbox")
			CreateConfig(nil, T["Swingtimer Color"], C.swingtimer, "color", "color")
		end)
		
		CreateGUIEntry("Actionbars", nil, function()
			CreateConfig(nil, T["Enable BFA-Style"], C.actionbars, "bfa_style", "checkbox")
			CreateConfig(nil, T["Enable Square Style"], C.actionbars, "squarebuttons", "checkbox")
			CreateConfig(nil, T["Swap pet and shapeshift actionbars"], C.actionbars, "swap_pet_shapeshift_actionbar", "checkbox")
			CreateConfig(nil, T["Hotkey Text Color"], C.hotkeys, "color", "color")
			CreateConfig(nil, T["Use Blizzard Hotkey Font"], C.hotkeys, "blizzard_font", "checkbox")
			CreateConfig(nil, T["Action Button Border Color"], C.skin, "dark", "color")
		end)

		CreateGUIEntry("Unitframes", nil, function()
			CreateConfig(nil, T["Compact Unitframes"], C.unitframes, "compactmode", "checkbox")
			CreateConfig(nil, T["Class Portraits"], C.unitframes, "classportraits", "checkbox")
			CreateConfig(nil, T["Show Status Glow Effect"], C.unitframes, "statusglow", "checkbox")
			CreateConfig(nil, T["Improved Pet Frame"], C.unitframes, "improvedpet", "checkbox")
			CreateConfig(nil, T["Hide Pet Happiness Icon (Shown by hp bar color)"], C.unitframes, "hide_pet_happiness_icon", "checkbox")

			CreateConfig(nil, T["Text"], nil, nil, "header")
			CreateConfig(nil, T["Show Percentage"], C.unitframes, "percentages", "checkbox")
			CreateConfig(nil, T["Format HP/MP-Text (1000 = 1k)"], C.unitframes, "trueformat", "checkbox")
			CreateConfig(nil, T["Gradient Colored HP-Text"], C.unitframes, "coloredtext", "checkbox")
			CreateConfig(nil, T["Text Outlines"], C.unitframes, "nameoutline", "checkbox")
			CreateConfig(nil, T["Hide Pet Text"], C.unitframes, "hidepettext", "checkbox")

			CreateConfig(nil, T["Statusbars"], nil, nil, "header")
			CreateConfig(nil, T["Flat Textures"], C.unitframes, "healthtexture", "checkbox")
			CreateConfig(nil, T["Player Class Colored Healthbar"], C.unitframes, "playerclasscolor", "checkbox")
			CreateConfig(nil, T["NPC Class Colored Healthbar"], C.unitframes, "npcclasscolor", "checkbox")

		end)

		CreateGUIEntry("Castbar", nil, function()
			CreateConfig(nil, T["Hide Blizz Castbar"], C.castbar.player, "hide_blizz", "checkbox")
			CreateConfig(nil, T["Castbar Color"], C.appearance.castbar, "castbarcolor", "color")
			CreateConfig(nil, T["Castbar Channel Color"], C.appearance.castbar, "channelcolor", "color")
			CreateConfig(nil, T["Flat Castbar Textures"], C.castbar, "flat_texture", "checkbox")
			
			CreateConfig(nil, T["Player Castbar"], nil, nil, "header")
			CreateConfig(nil, T["Hide Player Castbar"], C.castbar.player, "hide_zUI", "checkbox")
			CreateConfig(nil, T["Player Castbar Above"], C.castbar.player, "above", "checkbox")

			CreateConfig(nil, T["Target Castbar"], nil, nil, "header")
			CreateConfig(nil, T["Hide Target Castbar"], C.castbar.target, "hide_zUI", "checkbox")
			CreateConfig(nil, T["Target Castbar Above"], C.castbar.target, "above", "checkbox")

		end)

		CreateGUIEntry("Nameplates", nil, function()
			
			CreateConfig(nil, T["Font Size"], C.nameplates, "font_size", "text")
			CreateConfig(nil, T["Name X Offset"], C.nameplates, "name_x_offset", "text")
			CreateConfig(nil, T["Name Y Offset"], C.nameplates, "name_y_offset", "text")
			CreateConfig(nil, T["Combo Point Y Offset"], C.nameplates, "combo_y_offset", "text")
			CreateConfig(nil, T["Debuffs"], C.nameplates, "showdebuffs", "checkbox")
			CreateConfig(nil, T["Castbars"], C.nameplates, "showcastbar", "checkbox")
			CreateConfig(nil, T["Castbar Color"], C.nameplates, "castbarcolor", "color")
			CreateConfig(nil, T["Spell Names"], C.nameplates, "spellname", "checkbox")
			CreateConfig(nil, T["Clickthrough"], C.nameplates, "clickthrough", "checkbox")
			CreateConfig(nil, T["Combopoints"], C.nameplates, "cpdisplay", "checkbox")
			CreateConfig(nil, T["Class Colored Friendly Bars"], C.nameplates, "friendclassc", "checkbox")
			CreateConfig(nil, T["Class Colored Hostile Bars"], C.nameplates, "enemyclassc", "checkbox")
			CreateConfig(nil, T["Flat Health Textures"], C.nameplates, "flat_health_textures", "checkbox")
			CreateConfig(nil, T["Flat Castbar Textures"], C.nameplates, "flat_cast_textures", "checkbox")
		end)

		CreateGUIEntry("Buffs & Debuffs", nil, function()
			CreateConfig(nil, T["Show Player Debuffs"], C.aura, "player", "checkbox")
			CreateConfig(nil, T["Debuffs On Top"], C.aura, "above", "checkbox")
			CreateConfig(nil, T["Show Timers"], C.aura, "timers", "checkbox")
		end)
		
		CreateGUIEntry("Cooldowns", nil, function()
			CreateConfig(nil, T["Timer Low Color"], C.appearance.cd, "lowcolor", "color")
			CreateConfig(nil, T["Timer Normal Color"], C.appearance.cd, "normalcolor", "color")
			CreateConfig(nil, T["Timer Minute Color"], C.appearance.cd, "minutecolor", "color")
			CreateConfig(nil, T["Timer Hour Color"], C.appearance.cd, "hourcolor", "color")
			CreateConfig(nil, T["Timer Day Color"], C.appearance.cd, "daycolor", "color")
			CreateConfig(nil, T["Show Cooldown Background Timer"], C.actionbars, "cooldown_background", "checkbox")
		end)

		CreateGUIEntry("Map", nil, function()
			CreateConfig(nil, T["Minimap"], nil, nil, "header")
			CreateConfig(nil, T["Square Minimap"], C.minimap, "square", "checkbox")
			CreateConfig(nil, T["Hide Minimap Button"], C.minimap, "button_hide", "checkbox")
		end)

        CreateGUIEntry("Skins", nil, function()
			CreateConfig(nil, T["Bags"], C.skins, "bags", "checkbox")
			CreateConfig(nil, T["Paperdoll"], C.skins, "paperdoll", "checkbox")
			CreateConfig(nil, T["Inspect - Currently Broken on Turtle WoW"], C.skins, "inspect", "checkbox")
			CreateConfig(nil, T["Bank"], C.skins, "bank", "checkbox")
			CreateConfig(nil, T["Auction"], C.skins, "auction", "checkbox")
			CreateConfig(nil, T["Aura"], C.skins, "aura", "checkbox")
			CreateConfig(nil, T["Crafting"], C.skins, "crafting", "checkbox")
			CreateConfig(nil, T["Macro"], C.skins, "macro", "checkbox")
			CreateConfig(nil, T["Mail"], C.skins, "mail", "checkbox")
			CreateConfig(nil, T["Merchant"], C.skins, "merchant", "checkbox")
			CreateConfig(nil, T["Spellbook"], C.skins, "spellbook", "checkbox")
			CreateConfig(nil, T["Talents"], C.skins, "talents", "checkbox")
			CreateConfig(nil, T["Trade"], C.skins, "trade", "checkbox")
			CreateConfig(nil, T["Quest"], C.skins, "quest", "checkbox")
			CreateConfig(nil, T["Action Buttons"], C.skins, "action_buttons", "checkbox")
			CreateConfig(nil, T["Honor"], C.skins, "honor", "checkbox")
			CreateConfig(nil, T["Reputation"], C.skins, "reputation", "checkbox")
			CreateConfig(nil, T["Skills"], C.skins, "skills", "checkbox")
			CreateConfig(nil, T["Taxi"], C.skins, "taxi", "checkbox")
			CreateConfig(nil, T["Tabard"], C.skins, "tabard", "checkbox")
			CreateConfig(nil, T["Raid Info"], C.skins, "raidinfo", "checkbox")
			CreateConfig(nil, T["Social"], C.skins, "social", "checkbox")
			CreateConfig(nil, T["Guild"], C.skins, "guild", "checkbox")
			CreateConfig(nil, T["Wardrobe"], C.skins, "wardrobe", "checkbox")
			CreateConfig(nil, T["Tooltip"], C.skins, "tooltip", "checkbox")
		end)

		CreateGUIEntry(T["Components"], nil, function()
			table.sort(zUI.components)
			for i,c in pairs(zUI.components) do
				if c ~= "zOptions" then
					-- create disabled entry if not existing and display
					zUI:UpdateConfig("disabled", nil, c, "0")
					CreateConfig(nil, T["Disable Component"] .. " " .. c, C.disabled, c, "checkbox")
				end
			end
		end)
	end
end)