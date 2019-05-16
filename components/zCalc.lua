BINDING_HEADER_XCALC = "xcalc"
BINDING_NAME_XC_TOGGLEWINDOW = "Toggle xcalc"
BINDING_HEADER_XCALC_AUTOMATIC = "xcalc (automatic)"
BINDING_NAME_XC_NUMLOCK = "Numlock"
BINDING_NAME_XC_CLEAR = "Clear"
BINDING_NAME_XC_DIV = "Divide"
BINDING_NAME_XC_MUL = "Multiply"
BINDING_NAME_XC_SUB = "Subtract"
BINDING_NAME_XC_ADD = "Add"
BINDING_NAME_XC_EQ = "Equals"
BINDING_NAME_XC_0 = "Digit 0"
BINDING_NAME_XC_1 = "Digit 1"
BINDING_NAME_XC_2 = "Digit 2"
BINDING_NAME_XC_3 = "Digit 3"
BINDING_NAME_XC_4 = "Digit 4"
BINDING_NAME_XC_5 = "Digit 5"
BINDING_NAME_XC_6 = "Digit 6"
BINDING_NAME_XC_7 = "Digit 7"
BINDING_NAME_XC_8 = "Digit 8"
BINDING_NAME_XC_9 = "Digit 9"
BINDING_NAME_XC_DEC = "Decimal"
BINDING_NAME_XC_BACKSPACE = "Backspace"
--BINDING_NAME_XC_ESC = "Escape"

zUI:RegisterComponent("zCalculator", function ()
	--zUI.xcalc = { }
	zUI.xcalc = CreateFrame("Frame", "zCalculator", UIParent);

	-- Sudo General Namespaces and globals
	zUI.xcalc.events = {}
	Xcalc_Settings = {}
	zUI.xcalc.BindingMap = {}

	zUI.xcalc.NumberDisplay = "0"
	zUI.xcalc.RunningTotal = ""
	zUI.xcalc.PreviousKeyType = "none"
	zUI.xcalc.PreviousOP = ""

	zUI.xcalc.ConsoleLastAns = "0"
	zUI.xcalc.MemoryIndicator = ""
	zUI.xcalc.MemoryIndicatorON = "M"
	zUI.xcalc.MemoryNumber = "0"
	zUI.xcalc.MemorySet = "0"

	if (IsMacClient()) then
		zUI.xcalc.BindingMap.NUMLOCK_MAC = "XC_NUMLOCK"
		zUI.xcalc.BindingMap.BACKSPACE_MAC = "XC_BACKSPACE"
		zUI.xcalc.BindingMap.ENTER_MAC = "XC_EQ"
	else
		zUI.xcalc.BindingMap.NUMLOCK = "XC_NUMLOCK"
		zUI.xcalc.BindingMap.BACKSPACE = "XC_BACKSPACE"
		--zUI.xcalc.BindingMap.BUTTON4 = "XC_BACKSPACE"
		zUI.xcalc.BindingMap.ENTER = "XC_EQ"
	end
	zUI.xcalc.BindingMap.HOME = "XC_CLEAR"
	zUI.xcalc.BindingMap.NUMPADDIVIDE = "XC_DIV"
	zUI.xcalc.BindingMap.NUMPADMULTIPLY = "XC_MUL"
	zUI.xcalc.BindingMap.NUMPADMINUS = "XC_SUB"
	zUI.xcalc.BindingMap.NUMPADPLUS = "XC_ADD"
	zUI.xcalc.BindingMap.NUMPAD0 = "XC_0"
	zUI.xcalc.BindingMap.NUMPAD1 = "XC_1"
	zUI.xcalc.BindingMap.NUMPAD2 = "XC_2"
	zUI.xcalc.BindingMap.NUMPAD3 = "XC_3"
	zUI.xcalc.BindingMap.NUMPAD4 = "XC_4"
	zUI.xcalc.BindingMap.NUMPAD5 = "XC_5"
	zUI.xcalc.BindingMap.NUMPAD6 = "XC_6"
	zUI.xcalc.BindingMap.NUMPAD7 = "XC_7"
	zUI.xcalc.BindingMap.NUMPAD8 = "XC_8"
	zUI.xcalc.BindingMap.NUMPAD9 = "XC_9"
	zUI.xcalc.BindingMap.NUMPADDECIMAL = "XC_DEC"
	--zUI.xcalc.BindingMap.ESCAPE = "XC_ESC"

	local overrideOn
	
    zUI.xcalc:RegisterEvent("PLAYER_REGEN_ENABLED")
    zUI.xcalc:RegisterEvent("PLAYER_REGEN_DISABLED")
    zUI.xcalc:SetScript("OnEvent", function()
		if event == "PLAYER_REGEN_DISABLED" then
			--zPrint("Calc Regen disabled.")
			if Xcalc_Settings.Binding and Xcalc_Settings.Binding == 1 and overrideOn then 
				zUI.xcalc.unbind() -- unconditionally remove our overrides on combat, we don' want to be hogging keys when someone's jumped.
			end
		elseif event == "PLAYER_REGEN_ENABLED" then
			--zPrint("Calc Regen enabled.")
			if zUI.xcalc_window and Xcalc_Settings.Binding and Xcalc_Settings.Binding == 1 then
				if zUI.xcalc_window:IsShown() and not overrideOn then
					zUI.xcalc.rebind()
				elseif not xcalc_window:IsShown() and overrideOn then
					zUI.xcalc.unbind()
				end
			end
		end
	end)
	
	-- Processes for binding and unbinding numberpad keys to Xcalc
	function zUI.xcalc.rebind()
		--if (Xcalc_Settings.Binding == 1) and not InCombatLockdown() then
		
		if (C.calculator.bindings == "1") then
			for key,value in pairs(zUI.xcalc.BindingMap) do
				--zPrint("Bound Key: " .. key)
				--SetOverrideBinding(frame,false,key,value)
				SetBinding(key,value)
			end
			overrideOn = true
		end
	end

	function zUI.xcalc.unbind()
		if (C.calculator.bindings == "1") then
			--ClearOverrideBindings(frame)
			--for key,value in pairs(zUI.xcalc.BindingMap) do
				--SetOverrideBinding(frame,false,key,value)
			--	SetBinding(key)
			--end
			LoadBindings(2);
			--zPrint("UNBOUND ")
			overrideOn = nil
		end
	end
	
	-- Handle Key Inputs
	function zUI.xcalc.buttoninput(key)
		if ( key == "CL" ) then
			zUI.xcalc.clear()
		elseif ( key == "CE") then
			zUI.xcalc.ce()
		elseif ( key == "PM" ) then
			zUI.xcalc.plusminus()
		elseif ( key == "GOLD" ) then
			zUI.xcalc.stategold()
		elseif ( key == "SILVER" ) then
			zUI.xcalc.statesilver()
		elseif ( key == "COPPER" ) then
			zUI.xcalc.statecopper()
		elseif ( key == "MC" ) then
			zUI.xcalc.mc()
		elseif ( key == "MA" ) then
			zUI.xcalc.ma()
		elseif ( key == "MS" ) then
			zUI.xcalc.ms()
		elseif ( key == "MR" ) then
			zUI.xcalc.mr()
		elseif ( key == "BS" ) then
			zUI.xcalc.backspace()
		elseif (key == "=" or key == "/" or key == "*" or key == "-" or key == "-" or key == "+" or key == "^") then
			zUI.xcalc.funckey(key)
		else
			zUI.xcalc.numkey(key)
		end
	end

	-- Button Clear
	function zUI.xcalc.clear()
		zUI.xcalc.RunningTotal = ""
		zUI.xcalc.PreviousKeyType = "none"
		zUI.xcalc.PreviousOP = ""
		zUI.xcalc.display("0")
	end

	-- Button CE
	function zUI.xcalc.ce()
		zUI.xcalc.display("0")
	end

	-- Button Backspace
	function zUI.xcalc.backspace()
		local currText = zUI.xcalc.NumberDisplay
		if (currText == "0") then
			return
		else
			local length = string.len(currText)-1
			if (length < 0) then
				length = 0
			end
			currText = string.sub(currText,0,length)
			if (string.len(currText) < 1) then
				zUI.xcalc.display("0")
			else
				zUI.xcalc.display(currText)
			end
		end
	end

	-- Button Plus Minus Key
	function zUI.xcalc.plusminus()
		local currText = zUI.xcalc.NumberDisplay
		if (currText ~= "0") then
			if (string.find(currText, "-")) then
				currText = string.sub(currText, 2)
			else
				--currText = ("-%s"):format(currText)
				currText = string.format("-%s",currText)
			end
		end
		zUI.xcalc.PreviousKeyType = "state"
		zUI.xcalc.display(currText)
	end

	-- Button Gold (state)
	function zUI.xcalc.stategold()
		local currText = zUI.xcalc.NumberDisplay
		if (string.find(currText, "[csg]") == nil) then
			--currText = ("%sg"):format(currText)
			currText = string.format("%sg",currText)
		end
		zUI.xcalc.PreviousKeyType = "state"
		zUI.xcalc.display(currText)
	end

	-- Button Silver (state)
	function zUI.xcalc.statesilver()
		local currText = zUI.xcalc.NumberDisplay
		if (string.find(currText, "[cs]") == nil) then
			--currText = ("%ss"):format(currText)
			currText = string.format("%ss",currText)
		end
		zUI.xcalc.PreviousKeyType = "state"
		zUI.xcalc.display(currText)
	end

	-- Button Copper (state)
	function zUI.xcalc.statecopper()
		local currText = zUI.xcalc.NumberDisplay
		if (string.find(currText, "c") == nil) then
			--currText = ("%sc"):format(currText)
			currText = string.format("%sc",currText)
		end
		zUI.xcalc.PreviousKeyType = "state"
		zUI.xcalc.display(currText)
	end

	-- Button Memory Clear
	function zUI.xcalc.mc()
		zUI.xcalc.MemoryNumber = "0"
		zUI.xcalc.display(zUI.xcalc.NumberDisplay, "0")
	end

	-- Button Memory Add
	function zUI.xcalc.ma()
		--local temp = zUI.xcalc.parse(("%s+%s"):format(zUI.xcalc.MemoryNumber,zUI.xcalc.NumberDisplay))
		local temp = zUI.xcalc.parse(string.format("%s+%s",zUI.xcalc.MemoryNumber,zUI.xcalc.NumberDisplay))
		zUI.xcalc.MemoryNumber = zUI.xcalc.xcalculate(temp)
		zUI.xcalc.display("0","1")
		zUI.xcalc.clear()
	end

	-- Button Memory Store
	function zUI.xcalc.ms()
		zUI.xcalc.MemoryNumber = zUI.xcalc.parse(zUI.xcalc.NumberDisplay)
		zUI.xcalc.display("0","1")
		zUI.xcalc.clear()
	end

	-- Button Memory Recall
	function zUI.xcalc.mr()
		zUI.xcalc.display(zUI.xcalc.MemoryNumber)
	end

	-- Sets up the function keys ie, + - * / =
	function zUI.xcalc.funckey(key)
		local currText = zUI.xcalc.NumberDisplay
		if ( IsShiftKeyDown() and key == "=" ) then
			ChatFrame_OpenChat("")
			return
		end
		if (zUI.xcalc.PreviousKeyType=="none" or zUI.xcalc.PreviousKeyType=="num" or zUI.xcalc.PreviousKeyType=="state") then
				if (key == "/" or key == "*" or key == "-" or key == "-" or key == "+" or key == "^") then
					
					if (zUI.xcalc.PreviousOP~="" and zUI.xcalc.PreviousOP ~= "=") then
						--local temp = zUI.xcalc.parse(("%s%s%s"):format(zUI.xcalc.RunningTotal,zUI.xcalc.PreviousOP,currText))
						local temp = zUI.xcalc.parse(string.format("%s%s%s",zUI.xcalc.RunningTotal,zUI.xcalc.PreviousOP,currText))
						currText = zUI.xcalc.xcalculate(temp)
					end
					zUI.xcalc.RunningTotal = currText
					zUI.xcalc.PreviousOP = key
				elseif (key == "=") then
					if zUI.xcalc.PreviousOP ~= "=" and	zUI.xcalc.PreviousOP ~= "" then
						--local temp = zUI.xcalc.parse(("%s%s%s"):format(zUI.xcalc.RunningTotal,zUI.xcalc.PreviousOP,currText))
						local temp = zUI.xcalc.parse(string.format("%s%s%s",zUI.xcalc.RunningTotal,zUI.xcalc.PreviousOP,currText))
						currText = zUI.xcalc.xcalculate(temp)
						zUI.xcalc.RunningTotal = currText
						zUI.xcalc.PreviousOP="="
					end
				end
				
		else -- must be a func key, a second+ time
			if (key == "/" or key == "*" or key == "-" or key == "-" or key == "+" or key == "^") then
				zUI.xcalc.PreviousOP=key
			else
				zUI.xcalc.PreviousOP=""
			end 
		end
		zUI.xcalc.PreviousKeyType = "func"
		zUI.xcalc.display(currText)
	end

	-- Manage Number Inputs
	function zUI.xcalc.numkey(key)
		local currText = zUI.xcalc.NumberDisplay
	
		if (zUI.xcalc.PreviousKeyType=="none" or zUI.xcalc.PreviousKeyType=="num" or zUI.xcalc.PreviousKeyType=="state")then
			if (key == ".") then
				if (string.find(currText, "[csg%.]") == nil) then
					--currText = ("%s."):format(currText)
					currText = string.format("%s.",currText)
				end
			else
				if (currText == "0") then
					currText = ""
				end	
				--zPrint(key)
				--currText = ("%s%s"):format(currText,key)
				currText = string.format("%s%s",currText,key)
			end
		else
			if (key == ".") then
				currText = "0."
			else
				currText = key
			end
		end

		zUI.xcalc.PreviousKeyType = "num"
		zUI.xcalc.display(currText)
	end

	-- Send the number display to an open chatbox
	function zUI.xcalc.numberdisplay_click(frame,button,down)
		--if ( button == "LeftMouseButton" ) then
			if IsShiftKeyDown() and ChatFrameEditBox:IsVisible() then
				ChatFrameEditBox:Insert(zUI.xcalc.NumberDisplay)
			elseif IsShiftKeyDown() then
				ChatFrame_OpenChat(tostring(zUI.xcalc.NumberDisplay));
				--ChatFrameEditBox:Insert(zUI.xcalc.NumberDisplay)
			end
			--if ( IsShiftKeyDown() ) then
			--	local activeEdit = ChatEdit_GetActiveWindow()
			--	if (activeEdit) then
			--		activeEdit:Insert(zUI.xcalc.NumberDisplay)
			--	end
			--end
		--end
	end

	-- Tooltip hint for linking result to chat
	function zUI.xcalc.numberdisplay_enter(frame)
		GameTooltip:SetOwner(frame,"ANCHOR_TOP")	
		GameTooltip:SetText("Shift-click inserts to an open chat")
		GameTooltip:Show()
	end

	--[[----------------------------------------------------------------------------------- 
		Where the Calculations occur
		On a side note, Simple is easier, getting into complex if/then/elseif/else statements
		to perform math functions may introduce unexpected results... maybe.
	----------------------------------------------------------------------------------- ]]
	function zUI.xcalc.xcalculate(expression)
		local tempvar = "QCExpVal"

		_G[tempvar] = nil
		--RunScript(("%s=(%s)"):format(tempvar,expression))
		RunScript(string.format("%s=(%s)",tempvar,expression))
		local result = _G[tempvar]

		return result
	end

	-- This function parses the input for the money functions
	function zUI.xcalc.parse(expression)
		local ismoney = false

		local newexpression = expression

		newexpression = string.gsub(newexpression, "ans", zUI.xcalc.ConsoleLastAns)

		-- g s c
		newexpression = string.gsub(newexpression, "%d+g%d+s%d+c", function (a)
				ismoney = true
				return zUI.xcalc.FromGSC(a)
			end )

		-- g s
		newexpression = string.gsub(newexpression, "%d+g%d+s", function (a)
				ismoney = true
				return zUI.xcalc.FromGSC(a)
			end )


		-- g	 c
		newexpression = string.gsub(newexpression, "%d+g%d+c", function (a)
				ismoney = true
				return zUI.xcalc.FromGSC(a)
			end )

		-- g		 allows #.#
		newexpression = string.gsub(newexpression, "%d+%.?%d*g", function (a)
				ismoney = true
				return zUI.xcalc.FromGSC(a)
			end )

		--	 s c
		newexpression = string.gsub(newexpression, "%d+s%d+c", function (a)
				ismoney = true
				return zUI.xcalc.FromGSC(a)
			end )

		--	 s		 allows #.#
		newexpression = string.gsub(newexpression, "%d+%.?%d*s", function (a)
				ismoney = true
				return zUI.xcalc.FromGSC(a)
			end )

		--	 c
		newexpression = string.gsub(newexpression, "%d+c", function (a)
				ismoney = true
				return zUI.xcalc.FromGSC(a)
			end )


		if (ismoney) then
			--newexpression = ("xcalc.ToGSC(%s)"):format(newexpression)
			newexpression = string.format("zUI.xcalc.ToGSC(%s)",newexpression)
		end

		return newexpression
	end

	-- The following two functions do the to and from gold calculations
	function zUI.xcalc.ToGSC(decimal, std)
		local gold = 0
		local silver = 0
		local copper = 0
		
		if (std == "gold") then
			copper = math.mod(decimal, .01)
			decimal = decimal - copper
			copper = copper * 10000

			silver = math.mod(decimal, 1)
			decimal = decimal - silver
			silver = silver * 100

			gold = decimal
		elseif (std == "silver") then
			copper = math.mod(decimal, 1)
			decimal = decimal - copper
			copper = copper * 100

			silver = math.mod(decimal, 100)
			decimal = decimal - silver

			gold = decimal / 100
		else
			copper = math.mod(decimal, 100)
			decimal = decimal - copper
			
			silver = math.mod(decimal, 10000)
			decimal = decimal - silver
			silver = silver / 100

			gold = decimal / 10000
		end

		local temp = ""

		
		if (gold > 0) then
			--temp = ("%s%sg"):format(temp,gold)
			temp = string.format("%s%sg",temp,gold)
		end
		if (silver > 0 or (gold > 0 and copper > 0)) then
			--temp = ("%s%ss"):format(temp,silver)
			temp = string.format("%s%ss",temp,silver)
		end
		if (copper > 0) then
			--temp = ("%s%sc"):format(temp,copper)
			if(copper ~= math.floor(copper)) then
				copper = round(copper,tonumber(C.calculator.copperdecimals));
			end
			--zPrint(tostring(copper) .. " Copper")
			temp = string.format("%s%sc",temp,copper)
			
		end

		return temp
	end

	function zUI.xcalc.FromGSC(gold, silver, copper)
		if (gold == nil) then
			return ""
		end

		local total = 0

		if (type(gold) == "string" and (not silver or type(silver) == "nil") and (not copper or type(copper) == "nil")) then
			local temp = gold
		
			local golds,golde = string.find(temp, "%d*%.?%d*g")
			if (golds == nil) then
				gold = 0
			else
				gold = string.sub(temp, golds, golde - 1)
			end
	
			local silvers,silvere = string.find(temp, "%d*%.?%d*s")
			if (silvers == nil) then
				silver = 0
			else
				silver = string.sub(temp, silvers, silvere - 1)
			end

			local coppers,coppere = string.find(temp, "%d*c")
			if (coppers == nil) then
				copper = 0
			else
				copper = string.sub(temp, coppers, coppere - 1)
			end
		end

		total = total + copper
		total = total + (silver * 100)
		total = total + (gold * 10000)

		--return ("%s"):format(total)
		return string.format("%s", total)
	end
	-------------------------==[[ GUI ]]==----------------------------

	-- Display Main calculator Window
	function zUI.xcalc.windowdisplay()
		if (xcalc_window == nil) then
			zUI.xcalc.windowframe()
			xcalc_window:Show()
		elseif (xcalc_window:IsVisible()) then
			xcalc_window:Hide()
		else
			xcalc_window:Show()
			zUI.xcalc.clear()
		end
	end

	function zUI.xcalc.display(displaynumber, memoryset)
		if ( displaynumber == nil or displaynumber == "" ) then
			displaynumber = "0"
		elseif ( memoryset == "1" ) then
			xcalc_memorydisplay:SetText ( zUI.xcalc.MemoryIndicatorON )
		elseif ( memoryset == "0" ) then
			xcalc_memorydisplay:SetText( zUI.xcalc.MemoryIndicator )
		end
		zUI.xcalc.NumberDisplay = displaynumber
		local floatNumber = tonumber(displaynumber)
		--zPrint(tostring(floatNumber))
		--if(not tonumber(displaynumber) and floatNumber == math.floor(floatNumber)) then
		--if(not tostring(floatNumber) or floatNumber ~= math.floor(floatNumber)) then
		if(not floatNumber) then
			-- money
			xcalc_numberdisplay:SetText( displaynumber )
		else
			if(floatNumber ~= math.floor(floatNumber)) then
				-- float
				xcalc_numberdisplay:SetText( round(displaynumber,tonumber(C.calculator.decimals)))
			else
				-- Integer
				xcalc_numberdisplay:SetText( displaynumber )
			end
		end
		--elseif(floatNumber ~= math.floor(floatNumber)) then
		--	zPrint("Float!!")
		--	xcalc_numberdisplay:SetText( round(displaynumber,2) )
		--else
		--	zPrint("Integer!!")
		--	xcalc_numberdisplay:SetText( displaynumber )
		--end
	end

	--function zUI.xcalc.OnShow()
	--	zPrint("REBIND THAT SUCKER!")
	--	zUI.xcalc.rebind()
	--end

	-- Draw the main window
	function zUI.xcalc.windowframe()
		-- Main Window Frame (container) and title bar
		local frame = CreateFrame("Frame","xcalc_window",UIParent)
		
		frame:SetFrameStrata("HIGH")
		frame:EnableMouse(true)
		frame:EnableKeyboard(true)
		frame:SetMovable(true)
		frame:SetClampedToScreen(true)
		frame:SetHeight(264)
		frame:SetWidth(167) -- 11
		frame:SetScript("OnMouseDown", function() frame:StartMoving() end)
		frame:SetScript("OnMouseUp", function() frame:StopMovingOrSizing() end)
		--frame:SetScript("OnShow", zUI.xcalc.OnShow)
		frame:SetScript("OnShow", function() zUI.xcalc.rebind() end)
		frame:SetScript("OnHide", function() zUI.xcalc.unbind() end)
		frame:SetBackdrop({bgFile = "Interface/DialogFrame/UI-DialogBox-Background"})
			--edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
			--tile = true, tileSize = 32, edgeSize = 32,
			--insets = { left = 11, right = 12, top = 12, bottom = 11 }})
		frame:SetPoint("CENTER",0,0)
		--frame:SetTexture(0,0,0,1)
		zSkin(frame)
		zSkinColor(frame,0.4,0.4,0.4)

		local frametexture = frame:CreateTexture(nil, "BACKGROUND")
		frametexture:SetTexture(0.03,0.03,0.03,0.9);
		frametexture:ClearAllPoints()
		frametexture:SetPoint("CENTER", frame, "CENTER", 0, 0)
		frametexture:SetHeight(frame:GetHeight())
		frametexture:SetWidth(frame:GetWidth())
		--frame.edgeFile:SetVertexColor(0.4,0.4,0.4,1)
		--local titletexture = frame:CreateTexture("xcalc_window_titletexture")
		--titletexture:SetHeight(32)
		--titletexture:SetWidth(160)
		--titletexture:SetTexture("Interface/DialogFrame/UI-DialogBox-Header")
		--titletexture:SetTexCoord(0.2, 0.8, 0, 0.6)
		--titletexture:SetPoint("TOP",0,15)
		--titletexture:SetFrameStrata("DIALOG")
		--titletexture:SetVertexColor(0.4,0.4,0.4,1)

		local titlefont = frame:CreateFontString("xcalc_windowtest_titlefont")
		titlefont:SetHeight(0)
		titlefont:SetWidth(140)
		titlefont:SetFont(STANDARD_TEXT_FONT,12)
		titlefont:SetPoint("TOPLEFT",-30,-4)
		titlefont:SetTextColor(1,0.8196079,0)
		titlefont:SetText("zCalculator")
		-- Number Display box
		local numberdisplaybackground = frame:CreateTexture("xcalc_numberdisplaybackground")
		numberdisplaybackground:SetHeight(24)
		numberdisplaybackground:SetWidth(156) --167
		numberdisplaybackground:SetTexture(0,0,0,0.75);
		--numberdisplaybackground:SetTexture("interface/chatframe/ui-chatinputborder")
		numberdisplaybackground:SetPoint("TOPLEFT",6,-36)
		numberdisplaybackground:SetVertexColor(0.4,0.4,0.4,1)


		local numberdisplayborder = CreateFrame("StatusBar", nil, frame)
		--this.healthbar.castbar = CreateFrame("StatusBar", nil, this.healthbar)
		--this.healthbar.castbar.icon.bg:SetTexture(0,0,0,0.90)
		numberdisplayborder:ClearAllPoints()
		numberdisplayborder:SetPoint("CENTER", numberdisplaybackground, "CENTER", 0, 0)
		numberdisplayborder:SetWidth(numberdisplaybackground:GetWidth() +1)
		numberdisplayborder:SetHeight(numberdisplaybackground:GetHeight() +1)

		zSkin(numberdisplayborder); -- square
		zSkinColor(numberdisplayborder, 0.3, 0.3, 0.3);

		--local numberdisplay = frame:CreateFontString("xcalc_numberdisplay",nil,"NumberFont_OutlineThick_Mono_Small")
		local numberdisplay = frame:CreateFontString("xcalc_numberdisplay",nil,"GameFontHighlight")
		numberdisplay:SetHeight(24)
		numberdisplay:SetWidth(150)
		numberdisplay:SetJustifyH("RIGHT")
		numberdisplay:SetPoint("TOPLEFT",8,-36)
		numberdisplay:SetText(zUI.xcalc.NumberDisplay)
		local numberdisplayclickoverlay = CreateFrame("Button","xcalc_numberdisplayclickoverlay",frame)
		numberdisplayclickoverlay:SetAllPoints(numberdisplay)
		numberdisplayclickoverlay:Show()
		numberdisplayclickoverlay:EnableMouse(true)
		numberdisplayclickoverlay:SetScript("OnClick",zUI.xcalc.numberdisplay_click)
		--numberdisplayclickoverlay:SetScript("OnEnter",zUI.xcalc.numberdisplay_enter)
		--numberdisplayclickoverlay:SetScript("OnLeave",GameTooltip_Hide)
		-- Memory Display
		local memorydisplay = frame:CreateFontString("xcalc_memorydisplay","GameFontNormal")
		memorydisplay:SetWidth(29)
		memorydisplay:SetHeight(29)
		memorydisplay:SetFont(STANDARD_TEXT_FONT,12)
		memorydisplay:SetPoint("TOPLEFT",6,-70)
		-- memorydisplay:SetText("M")
		-- ExitButton
		local exitbutton = CreateFrame("Button", "xcalc_exitbutton",frame,"UIPanelCloseButton")
		exitbutton:SetPoint("TOPRIGHT",4,4)
		exitbutton:SetWidth(24)
		exitbutton:SetHeight(24)
		exitbutton:SetScript("OnClick", function() zUI.xcalc.windowdisplay() end)

		-- Main calculator buttons
		zUI.xcalc.button(28,28,70,-70,"<<","BS")
		zUI.xcalc.button(28,28,102,-70,"CE","CE")
		zUI.xcalc.button(28,28,134,-70,"C","CL")
		zUI.xcalc.button(60,28,102,-230,"=","=")
		zUI.xcalc.button(28,28,38,-70,"^","^")
		zUI.xcalc.button(28,28,102,-198,"+/-","PM")
		zUI.xcalc.button(28,28,134,-198,"+","+")
		zUI.xcalc.button(28,28,134,-166,"-","-")
		zUI.xcalc.button(28,28,134,-134,"*","*")
		zUI.xcalc.button(28,28,134,-102,"/","/")
		zUI.xcalc.button(28,28,70,-230,"c","COPPER")
		zUI.xcalc.button(28,28,38,-230,"s","SILVER")
		zUI.xcalc.button(28,28,6,-230,"g","GOLD")
		zUI.xcalc.button(28,28,70,-198,".",".")
		zUI.xcalc.button(28,28,38,-198,"0","0")
		zUI.xcalc.button(28,28,38,-166,"1","1")
		zUI.xcalc.button(28,28,70,-166,"2","2")
		zUI.xcalc.button(28,28,102,-166,"3","3")
		zUI.xcalc.button(28,28,38,-134,"4","4")
		zUI.xcalc.button(28,28,70,-134,"5","5")
		zUI.xcalc.button(28,28,102,-134,"6","6")
		zUI.xcalc.button(28,28,38,-102,"7","7")
		zUI.xcalc.button(28,28,70,-102,"8","8")
		zUI.xcalc.button(28,28,102,-102,"9","9")
		zUI.xcalc.button(28,28,6,-198,"MA","MA")
		zUI.xcalc.button(28,28,6,-166,"MS","MS")
		zUI.xcalc.button(28,28,6,-134,"MR","MR")
		zUI.xcalc.button(28,28,6,-102,"MC","MC")

		-- Option show button
		--local optionbutton = CreateFrame("Button", "xcalc_optionwindow_button",frame,"UIPanelButtonTemplate")
		--optionbutton:SetWidth(70)
		--optionbutton:SetHeight(25)
		--optionbutton:SetPoint("BOTTOMRIGHT",-15,15)
		--optionbutton:SetText("Options")
		--optionbutton:SetScript("OnClick", function() zUI.xcalc.optiondisplay() end)
		zUI.xcalc.rebind()
		tinsert(UISpecialFrames,"xcalc_window") -- close the frame when Escape is pressed
	end

	function zUI.xcalc.button(width, height, x, y, text, cmd)
		local button = CreateFrame("Button", "zUI.xcalc." .. text, xcalc_window ,"UIPanelButtonTemplate")
		--local button = CreateFrame("Button", "zUI.xcalc." .. text, xcalc_window)
		button:SetWidth(width)
		button:SetHeight(height)
		button:SetPoint("TOPLEFT",x,y)
		button:SetText(text)
		button:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background"})
		button:SetBackdropColor(1,0,0,1)
		--button:SetNormalTexture("Interface\\BUTTONS\\WHITE8X8")
		button:SetNormalTexture("")
		button:SetScript("OnClick", function() zUI.xcalc.buttoninput(cmd) end)
		-- On mouse over , change skincolor 
		zSkin(button, 0); -- square
		zSkinColor(button, 0.4, 0.4, 0.4);
		zUI.xcalc.buttons = zUI.xcalc.buttons or {}
		tinsert(zUI.xcalc.buttons,button)
	end

	--function zUI.xcalc.minimap_init()
	--	if (Xcalc_Settings.Minimapdisplay == 1) then
	--		local frame = CreateFrame("Button","xcalc_minimap_button",Minimap)
	--		frame:SetWidth(34)
	--		frame:SetHeight(34)
	--		frame:SetFrameStrata("LOW")
	--		frame:SetToplevel(1)
	--		frame:SetNormalTexture("Interface\\AddOns\\zUI.xcalc\\xcalc_ButtonRoundNormal.tga")
	--		frame:SetPushedTexture("Interface\\AddOns\\zUI.xcalc\\xcalc_ButtonRoundPushed.tga")
	--		frame:SetHighlightTexture("Interface/Minimap/UI-Minimap-ZoomButton-Highlight")
	--		frame:RegisterForClicks("AnyUp")
	--		frame:SetScript("OnClick", function(self, button, down)
	--			if (button == "LeftButton") then
	--				zUI.xcalc.windowdisplay()
	--			elseif (button == "RightButton") then
	--				zUI.xcalc.optiondisplay()
	--			end
	--		end)
	--		frame:SetScript("OnEnter", function() zUI.xcalc.tooltip("minimap") end)
	--		frame:SetScript("OnLeave", function() zUI.xcalc.tooltip("hide") end)
	--		zUI.xcalc.minimapbutton_updateposition()
	--		frame:Show()
	--	end
	--end

	-- Minimap button Position
	--function zUI.xcalc.minimapbutton_updateposition()
	--	xcalc_minimap_button:SetPoint("TOPLEFT", "Minimap", "TOPLEFT",
	--	54 - (78 * cos(Xcalc_Settings.Minimappos)),
	--	(78 * sin(Xcalc_Settings.Minimappos)) - 55)
	--end

	-- Tooltip display
	--function zUI.xcalc.tooltip(mouseover)
	--	if ( mouseover == "minimap" ) then
	--		GameTooltip:SetOwner(xcalc_minimap_button , "ANCHOR_BOTTOMLEFT")
	--		GameTooltip:SetText("Show/Hide zUI.xcalc")
	--	else
	--		GameTooltip : Hide ()
	--	end
	--end

	-- Function for handeling Binding checkbox
	--function zUI.xcalc.options_binding()
	--	if (xcalc_options_bindcheckbox:GetChecked() == 1) then
	--		Xcalc_Settings.Binding = 1
	--	else
	--		zUI.xcalc.unbind()
	--		Xcalc_Settings.Binding = 0
	--	end
	--end

	-- Function for Handeling Minimap Display checkbox
	--function zUI.xcalc.options_minimapdisplay()
	--	if (xcalc_options_minimapcheckbox:GetChecked() == 1) then
	--		Xcalc_Settings.Minimapdisplay = 1
	--		if (xcalc_minimap_button == nil) then
	--			zUI.xcalc.minimap_init()
	--		else
	--			xcalc_minimap_button:Show()
	--		end
	--	else
	--		Xcalc_Settings.Minimapdisplay = 0
	--		xcalc_minimap_button:Hide()
	--	end
	--end

	-- Function for managing options slider
	--function zUI.xcalc.options_minimapslidercontrol()
	--	if (Xcalc_Settings.Minimapdisplay == 1) then
	--		Xcalc_Settings.Minimappos = xcalc_options_minimapslider:GetValue()
	--		zUI.xcalc.minimapbutton_updateposition()
	--	else
	--		xcalc_options_minimapslider:SetValue(Xcalc_Settings.Minimappos)
	--		return
	--	end
	--end

	-- Draw the Option window
	--function zUI.xcalc.optionframe()
	--	-- Options window Frame
	--	local frame = CreateFrame("Frame","xcalc_optionwindow",UIParent)
	--	frame:SetFrameStrata("HIGH")
	--	frame:EnableMouse(true)
	--	frame:SetClampedToScreen(true)
	--	frame:SetWidth(220)
	--	frame:SetHeight(200)
	--	frame:SetBackdrop({bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
	--		edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
	--		tile = true, tileSize = 32, edgeSize = 32,
	--		insets = { left = 11, right = 12, top = 12, bottom = 11 }})
	--	frame:SetPoint("CENTER",230,0)
	--	local titletexture = frame:CreateTexture("xcalc_optionwindow_titletexture")
	--	titletexture:SetHeight(32)
	--	titletexture:SetWidth(160)
	--	titletexture:SetTexture("Interface/DialogFrame/UI-DialogBox-Header")
	--	titletexture:SetTexCoord(0.2, 0.8, 0, 0.6)
	--	titletexture:SetPoint("TOP",0,5)
	--	local titlefont = frame:CreateFontString("xcalc_optionwindow_titlefont")
	--	titlefont:SetHeight(0)
	--	titlefont:SetWidth(140)
	--	titlefont:SetFont(STANDARD_TEXT_FONT,12)
	--	titlefont:SetPoint("TOP",0,-4)
	--	titlefont:SetTextColor(1,0.8196079,0)
	--	titlefont:SetText("zUI.xcalc Options")
	--	-- Options Okay Button
	--	local okaybutton = CreateFrame("Button", "xcalc_optionokaybutton",frame,"UIPanelButtonTemplate")
	--	okaybutton:SetWidth(70)
	--	okaybutton:SetHeight(29)
	--	okaybutton:SetPoint("BOTTOM",0,20)
	--	okaybutton:SetText("Okay")
	--	okaybutton:SetScript("OnClick", function() zUI.xcalc.optiondisplay() end)
	--	-- Binding Check box
	--	local bindingcheckbox = CreateFrame("CheckButton","xcalc_options_bindcheckbox",frame,"OptionsCheckButtonTemplate")
	--	bindingcheckbox:SetPoint("TOPLEFT",15,-40)
	--	bindingcheckbox:SetChecked(Xcalc_Settings.Binding)
	--	bindingcheckbox:SetScript("OnClick", function() zUI.xcalc.options_binding() end)
	--	local bindingcheckboxtext = frame:CreateFontString("xcalc_options_bindcheckboxtext")
	--	bindingcheckboxtext:SetWidth(200)
	--	bindingcheckboxtext:SetHeight(0)
	--	bindingcheckboxtext:SetFont(STANDARD_TEXT_FONT,10)
	--	bindingcheckboxtext:SetTextColor(1,0.8196079,0)
	--	bindingcheckboxtext:SetJustifyH("LEFT")
	--	bindingcheckboxtext:SetText("Use Automatic Key Bindings")
	--	bindingcheckboxtext:SetPoint("LEFT","xcalc_options_bindcheckbox",30,0)
	--	-- Display Minimap Check Box
	--	local minimapcheckbox = CreateFrame("CheckButton","xcalc_options_minimapcheckbox",frame,"OptionsCheckButtonTemplate")
	--	minimapcheckbox:SetPoint("TOPLEFT",15,-70)
	--	minimapcheckbox:SetChecked(Xcalc_Settings.Minimapdisplay)
	--	minimapcheckbox:SetScript("OnClick", function() zUI.xcalc.options_minimapdisplay() end)
	--	local minimapcheckboxtext = minimapcheckbox:CreateFontString("xcalc_options_minimapcheckboxtext")
	--	minimapcheckboxtext:SetWidth(200)
	--	minimapcheckboxtext:SetHeight(0)
	--	minimapcheckboxtext:SetFont(STANDARD_TEXT_FONT,10)
	--	minimapcheckboxtext:SetTextColor(1,0.8196079,0)
	--	minimapcheckboxtext:SetJustifyH("LEFT")
	--	minimapcheckboxtext:SetText("Display Minimap Icon")
	--	minimapcheckboxtext:SetPoint("LEFT","xcalc_options_minimapcheckbox",30,0)
	--	-- Minimap Position Slider
	--	local minimapslider = CreateFrame("Slider","xcalc_options_minimapslider",frame,"OptionsSliderTemplate")
	--	minimapslider:SetWidth(180)
	--	minimapslider:SetHeight(16)
	--	minimapslider:SetMinMaxValues(0, 360)
	--	minimapslider:SetValueStep(1)
	--	minimapslider:SetScript("OnValueChanged", function() zUI.xcalc.options_minimapslidercontrol() end)
	--	xcalc_options_minimapsliderHigh:SetText()
	--	xcalc_options_minimapsliderLow:SetText()
	--	xcalc_options_minimapsliderText:SetText("Minimap Button Position")
	--	minimapslider:SetPoint("TOPLEFT",15,-120)
	--	minimapslider:SetValue(Xcalc_Settings.Minimappos)
	--end

	-- Display options window
	--function zUI.xcalc.optiondisplay()
	--	if (xcalc_optionwindow == nil) then
	--		zUI.xcalc.optionframe()
	--		xcalc_optionwindow:Show()
	--	elseif (xcalc_optionwindow:IsVisible()) then
	--		xcalc_optionwindow:Hide()
	--	else
	--		xcalc_optionwindow:Show()
	--	end
	--end
	
end)


SLASH_CALC1 = "/calc"
function SlashCmdList.CALC( msg, editbox )
	--zUI.zCalculator.calc(msg);
	--zUI.api.calc(msg);
	zUI.xcalc.windowdisplay()
end

