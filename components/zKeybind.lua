zUI:RegisterComponent("zKeybind", function ()
	
	-- Reload request after key bindings...
	-- Only becuase we might not want to keep the hooks we created
	-- to be able to bind the mouse buttons...
	-- Maybe it doesnt matter to keep the hooks and skip the reload?? I dont know...
	-- I say, reload to be safe.

	StaticPopupDialogs["KEYBIND_RELOAD"] = {
		text = "Reload UI to finalize key bindings.",
		button1 = "Reload UI",
		button2 = "Ignore",
		OnAccept = function()
			ReloadUI();
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true
	}

	local modifiers = {
		["ALT"]   = "ALT-",
		["CTRL"]  = "CTRL-",
		["SHIFT"] = "SHIFT-"
	}

	zUI.zKeybind = CreateFrame("Frame","zKeyBindingFrame",UIParent);
	zUI.zKeybind:Hide();
	zUI.zKeybind:RegisterEvent("PLAYER_REGEN_DISABLED");
	zUI.zKeybind:EnableMouse(true);
	local need_reload = false;

	zUI.zKeybind.edit = CreateFrame("Button", "zKeyBindingFrameEdit", zUI.zKeybind);
	zUI.zKeybind.edit:SetFrameStrata("BACKGROUND");
	zUI.zKeybind.edit:SetAllPoints(UIParent);

	zUI.zKeybind.edit.tex = zUI.zKeybind.edit:CreateTexture("zKeyBindShade", "BACKGROUND");
	zUI.zKeybind.edit.tex:SetAllPoints(zUI.zKeybind.edit);
	zUI.zKeybind.edit.tex:SetTexture(0,0,0,.5);

	zUI.zKeybind.edit:SetScript("OnClick", function()
		zUI.zKeybind:Hide()
	end)
	
	zUI.zKeybind:SetScript("OnShow", function()
		zUI.gui:Hide()
		zUI.zKeybind.edit:Show()
		
		MultiActionBar_ShowAllGrids();
		zUI.zKeybind:HookAll();
		
		local txt = T["|cffffd200Keybind Mode|r\n\nPlace the cursor over the button you want to bind and press a key.\n\nHit Escape or click on an empty space on the screen to exit."]
		CreateInfoBox(txt, 24,  zUI.zKeybind.edit)
	end)

	zUI.zKeybind:SetScript("OnHide",function()
		if ( ALWAYS_SHOW_MULTIBARS == "0" or ALWAYS_SHOW_MULTIBARS == 0 ) then
			MultiActionBar_HideAllGrids();
		end

		zUI.zKeybind.edit:Hide()
		-- RELOAD REQUEST
		-- Only to undo all the hooks we created in order to be able to bind the mouse buttons
		StaticPopup_Show("KEYBIND_RELOAD");
		--zUI.gui:Show()
	end)

	function zUI.zKeybind:HookScript(f, script, func)
		local oldScript = f:GetScript(script)
	
		f:SetScript(script, function()
			if(zUI.zKeybind:IsShown()) then
				func()
			else
				if oldScript then oldScript() end
			end
		end)
	end

	function zUI.zKeybind:HookAll()
		for i = 1, 12 do
			for _, v in pairs(
					{
					_G['ActionButton'..i],
					_G['MultiBarRightButton'..i],
					_G['MultiBarLeftButton'..i],
					_G['MultiBarBottomLeftButton'..i],
					_G['MultiBarBottomRightButton'..i],
				}
			) do
				v:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp", "Button4Up", "Button5Up");
				zUI.zKeybind:HookScript(v,'OnClick', function() zUI.zKeybind:ActionKeyClick(arg1) end)
			end
		end

		for i = 1, 10 do
			for _, v in pairs(
				{
					_G['ShapeshiftButton'..i],
					_G['PetActionButton'..i]
				}
			) do
				v:RegisterForClicks("LeftButtonUp", "RightButtonUp", "MiddleButtonUp", "Button4Up", "Button5Up");
				zUI.zKeybind:HookScript(v,'OnClick', function() zUI.zKeybind:ActionKeyClick(arg1) end)
			end
		end
	end

	function zUI.zKeybind:ActionKeyClick(key)
		if(key) then
			zUI.zKeybind:OnKeyUp(key)
			this:SetButtonState("NORMAL");
			this:SetChecked(0);
			--this:SetPushed(false);
		end
		return
	end

	zUI.zKeybind:EnableKeyboard(true)
	zUI.zKeybind:SetScript("OnKeyUp",function()
		zUI.zKeybind:OnKeyUp(arg1);
	end)	

	function zUI.zKeybind:OnKeyUp(keyCode)
		if modifiers[keyCode] then return end -- ignore single modifier keyup

		if ( keyCode == "LeftButton" or keyCode == "RightButton") then
			return -- Dont wanna bind over essential mouse buttons...
		elseif ( keyCode == "MiddleButton" ) then
			keyCode = "BUTTON3";
		elseif ( keyCode == "Button4" ) then
			keyCode = "BUTTON4"
		elseif ( keyCode == "Button5" ) then
			keyCode = "BUTTON5"
		end

		local need_save = false
		local frame = GetMouseFocus()
		local hovername = (frame and frame.GetName) and (frame:GetName()) or ""
		
		local binding = zGetBinding(hovername);

		if keyCode == "ESCAPE" and not binding then 
			zUI.zKeybind:Hide() 
			return 
		end


		if (binding) then
			if keyCode == "ESCAPE" then
				local key = (GetBindingKey(binding))
				if (key) then
					SetBinding(key)
					need_save = true
				end
			else
				if (SetBinding(zUI.zKeybind:GetPrefix()..keyCode,binding)) then
					need_save = true
				end
			end
		end
		-- if we set or cleared a binding save to the selected set
		if need_save then
			need_save = false
			SaveBindings(GetCurrentBindingSet())
		end
	end

	function zUI.zKeybind:GetPrefix()
		return string.format("%s%s%s",
			(IsAltKeyDown() and modifiers.ALT or ""),
			(IsControlKeyDown() and modifiers.CTRL or ""),
			(IsShiftKeyDown() and modifiers.SHIFT or ""))
	end

	zUI.zKeybind:SetScript("OnEvent",function()
		-- disable zKeybind so player gets back control of their keyboard to fight
		zUI.zKeybind:Hide()
	end)
end)

