zUI:RegisterComponent("zMap", function ()

	local fake_ipairs = lua51 and loadstring([[local tmp = {}; return function(...)
	for k in pairs(tmp) do
		tmp[k] = nil
	end
	for i = 1, select('#', ...) do
		tmp[i] = select(i, ...)
	end
	return ipairs(tmp)
	end]])() or loadstring([[local tmp = {}; return function(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20)
	for k in pairs(tmp) do
		tmp[k] = nil
	end
	tmp[1] = a1 tmp[2] = a2 tmp[3] = a3 tmp[4] = a4 tmp[5] = a5 tmp[6] = a6 tmp[7] = a7 tmp[8] = a8 tmp[9] = a9 tmp[10] = a10 tmp[11] = a11 
	tmp[12] = a12 tmp[13] = a13 tmp[14] = a14 tmp[15] = a15 tmp[16] = a16 tmp[17] = a17 tmp[18] = a18 tmp[19] = a19 tmp[20] = a20 tmp.n = 20
	while tmp[tmp.n] == nil do
		tmp.n = tmp.n - 1
	end
	return ipairs(tmp)
	end]])()

	function _G.ToggleWorldMap()
		if WorldMapFrame:IsShown() then
			WorldMapFrame:Hide()
		else
			WorldMapFrame:Show()
			table.insert(UISpecialFrames, "WorldMapFrame")
		end
	end

	if not C.position[WorldMapFrame:GetName()] then
		C.position[WorldMapFrame:GetName()] = { alpha = 1.0, scale = 0.7 }
	end
	local c_position = C.position[WorldMapFrame:GetName()]

	local zMapLoader = CreateFrame("Frame", nil, UIParent)
	zMapLoader:RegisterEvent("PLAYER_ENTERING_WORLD")
	zMapLoader:SetScript("OnEvent", function()
		-- do not load if other map addon is loaded
		if Cartographer then return end
		if METAMAP_TITLE then return end

		zUI.zMap = CreateFrame("Frame");

		if not zUI.zMap.playerModel then
			for _,v in fake_ipairs(WorldMapFrame:GetChildren()) do
				if v:GetFrameType() == "Model" and not v:GetName() then
					zUI.zMap.playerModel = v
					break
				end
			end
		end

		zUI.zMap.playerModel:SetModelScale(1)


		UIPanelWindows["WorldMapFrame"] = { area = "center" }

		WorldMapFrame:SetScript("OnShow", function()
			-- default events
			UpdateMicroButtons()
			PlaySound("igQuestLogOpen")
			CloseDropDownMenus()
			SetMapToCurrentZone()
			WorldMapFrame_PingPlayerPosition()
			--LoadMovable(this)
	  
			if zUI_config["position"][this:GetName()] then
				if zUI_config["position"][this:GetName()]["scale"] then
					this:SetScale(zUI_config["position"][this:GetName()].scale)
					if(zUI_config["position"][this:GetName()]["scale"] < 0.5) then
						zUI.zMap.playerModel:SetModelScale(2)
					end
				end
		
				if zUI_config["position"][this:GetName()]["xpos"] then
					this:ClearAllPoints()
					this:SetPoint("CENTER",UIParent, "BOTTOMLEFT",zUI_config["position"][this:GetName()].xpos, zUI_config["position"][this:GetName()].ypos);
				--this:SetPoint(zUI_config["position"][this:GetName()].point)
				end
			end

			-- customize
			this:SetMovable(true)
			this:EnableMouse(true)
			this:EnableKeyboard(false)
			this:EnableMouseWheel(1)
		end)

		WorldMapFrame:SetScript("OnMouseWheel", function()
			if IsShiftKeyDown() then
				c_position.alpha = zUI.api.clamp(WorldMapFrame:GetAlpha() + arg1/10, 0.1, 1.0)
				WorldMapFrame:SetAlpha(c_position.alpha)
			end

			local up = (arg1 == 1)

			if IsControlKeyDown() then
				--local scale = WorldMapFrame:GetScale()
				--if up then
				--	scale = scale + 0.1
				--	if scale > 1 then
				--		scale = 1
				--	end
				--else
				--	scale = scale - 0.1
				--	if scale < 0.2 then
				--		scale = 0.2
				--	end
				--end
				--WorldMapFrame:SetScale(scale)
			
				c_position.scale = zUI.api.clamp(WorldMapFrame:GetScale() + arg1/10, 0.1, 2.0)
				WorldMapFrame:SetScale(c_position.scale)
		  
				local zscale,x,y=WorldMapFrame:GetEffectiveScale(),GetCursorPosition();
				--zPrint("Cursor: " .. x .. ", " .. y);
				WorldMapFrame:ClearAllPoints()
				WorldMapFrame:SetPoint("CENTER",UIParent, "BOTTOMLEFT",x/c_position.scale,y/c_position.scale);

				if not C.position[WorldMapFrame:GetName()] then
					C.position[WorldMapFrame:GetName()] = {}
				end

				local point, relativeTo, relativePoint, xOfs, yOfs = this:GetPoint()
				--zPrint("GetPoint: " .. xOfs .. ", " .. yOfs);
				C.position[WorldMapFrame:GetName()]["xpos"] = xOfs;
				C.position[WorldMapFrame:GetName()]["ypos"] = yOfs;
				C.position[WorldMapFrame:GetName()]["scale"] = c_position.scale;

				if(c_position.scale < 0.5) and not (zUI.zMap.playerModel:GetModelScale() == 2) then
					zUI.zMap.playerModel:SetModelScale(2)
				elseif (c_position.scale > 0.5) and not (zUI.zMap.playerModel:GetModelScale() == 1) then
					zUI.zMap.playerModel:SetModelScale(1)
				end

				--zPrint("Setting Point")
			end
		end)

		WorldMapFrame:SetScript("OnMouseDown",function()
			WorldMapFrame:StartMoving()
		end)

		WorldMapFrame:SetScript("OnMouseUp",function()
			WorldMapFrame:StopMovingOrSizing()
		
			if not C.position[WorldMapFrame:GetName()] then
				C.position[WorldMapFrame:GetName()] = {}
			end
			local x,y = this:GetCenter()
			--zPrint("OnMouseUp: " .. x .. ", " .. y);
			C.position[WorldMapFrame:GetName()]["xpos"] = x;
			C.position[WorldMapFrame:GetName()]["ypos"] = y;
			this:SetPoint("CENTER",UIParent, "BOTTOMLEFT",x,y);
		end)

		WorldMapFrame:ClearAllPoints()
		WorldMapFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
		WorldMapFrame:SetWidth(WorldMapButton:GetWidth() + 15)
		WorldMapFrame:SetHeight(WorldMapButton:GetHeight() + 55)
		WorldMapFrameCloseButton:SetPoint("TOPRIGHT", WorldMapFrame, "TOPRIGHT", 0, 0)

		local zBACKDROP = {
			bgFile     = [[Interface\ChatFrame\ChatFrameBackground]],
			tiled      = false,
			insets     = {left = -7, right = -7, top = -7, bottom = -7} -- -3
		}

		-- use default inset if nothing is given
		local f = WorldMapFrame;
		local border = 4
		--if not border then
		--	border = tonumber(zUI_config.appearance.border.default)
		--end

		--local br, bg, bb, ba = zUI.api.GetStringColor(zUI_config.appearance.border.background)
		local br, bg, bb, ba = 0,0,0,0.95;
		local er, eg, eb, ea = zUI.api.GetStringColor(zUI_config.appearance.border.color)

		if transp and transp < tonumber(ba) then ba = transp end

		-- increase clickable area if available
		if f.SetHitRectInsets then
			f:SetHitRectInsets(-border,-border,-border,-border)
		end

		-- use new backdrop behaviour
		if not f.backdrop then
			f:SetBackdrop(nil)

			local backdrop = zBACKDROP
			local b = CreateFrame("Frame", nil, f)
			if tonumber(border) > 1 then
				local border = tonumber(border) - 1
				backdrop.insets = {left = 10, right = 8, top = 9, bottom = 8}
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
		--b:SetBackdropBorderColor(1, 0, 0 , 1)
	
		zSkin(b,9);
		if (C.global.darkmode == "1") then 
			zSkinColor(b,0.4,0.4,0.4,1);
		else
			zSkinColor(b,0.7,0.7,0.7,1);
		end
		--CreateBackdrop(WorldMapFrame)

		WorldMapFrame:SetAlpha(c_position.alpha)
		WorldMapFrame:SetScale(c_position.scale)
		--WorldMapFrame:SetScale(1)
		BlackoutWorld:Hide()

		WorldMapContinentDropDown:Hide();
		WorldMapZoneDropDown:Hide();
		WorldMapZoomOutButton:Hide();

		for i,v in ipairs({WorldMapFrame:GetRegions()}) do
			if v.SetTexture then
				v:SetTexture("")
			end
			if v.SetText then
				v:SetText("")
			end
		end

		-- info scale & opacity
		WorldMapButton.info = CreateFrame("Frame", "zWorldMapButtonInfo", WorldMapButton)

		WorldMapButton.info.scale = WorldMapButton.info:CreateFontString(nil, "OVERLAY")
		WorldMapButton.info.scale:SetPoint("TOPLEFT", WorldMapButton, "TOPLEFT", 66, -38)
		WorldMapButton.info.scale:SetFont(STANDARD_TEXT_FONT, 10)
		WorldMapButton.info.scale:SetShadowOffset(1, -1)
		WorldMapButton.info.scale:SetTextColor(0.95, 0.95, 0.95)
		WorldMapButton.info.scale:SetJustifyH("RIGHT")
	
		WorldMapButton.info.opacity = WorldMapButton.info:CreateFontString(nil, "OVERLAY")
		WorldMapButton.info.opacity:SetPoint("TOPLEFT", WorldMapButton, "TOPLEFT", 66, -54)
		WorldMapButton.info.opacity:SetFont(STANDARD_TEXT_FONT, 10)
		WorldMapButton.info.opacity:SetShadowOffset(1, -1)
		WorldMapButton.info.opacity:SetTextColor(0.95, 0.95, 0.95)
		WorldMapButton.info.opacity:SetJustifyH("RIGHT")

		WorldMapButton.info:SetScript("OnUpdate", function()
			if MouseIsOver(WorldMapButton) then
				WorldMapButton.info.scale:SetText("Ctrl+Scroll On Map To Scale");
				WorldMapButton.info.opacity:SetText("Shift+Scroll On Map To Modify Opacity");
			else
				WorldMapButton.info.scale:SetText("")
				WorldMapButton.info.opacity:SetText("")
			end
		end)

		-- coordinates ReputationWatchStatusBarText:SetFont(STANDARD_TEXT_FONT, 10,"OUTLINE")
		WorldMapButton.coords = CreateFrame("Frame", "zWorldMapButtonCoords", WorldMapButton)
		WorldMapButton.coords.text = WorldMapButton.coords:CreateFontString(nil, "OVERLAY")
		WorldMapButton.coords.text:SetPoint("TOP", WorldMapButton, "TOP", 10, 30)
		WorldMapButton.coords.text:SetFont(STANDARD_TEXT_FONT, 18, "OUTLINE")
		WorldMapButton.coords.text:SetTextColor(1, 1, 1)
		WorldMapButton.coords.text:SetJustifyH("RIGHT")
	
		WorldMapButton.coords:SetScript("OnUpdate", function()
			local width  = WorldMapButton:GetWidth()
			local height = WorldMapButton:GetHeight()
			local mx, my = WorldMapButton:GetCenter()
			local scale  = WorldMapButton:GetEffectiveScale()
			local x, y   = GetCursorPosition()
	
			mx = (( x / scale ) - ( mx - width / 2)) / width * 100
			my = (( my + height / 2 ) - ( y / scale )) / height * 100
	
			if MouseIsOver(WorldMapButton) then
				WorldMapButton.coords.text:SetText(string.format('%.1f / %.1f', mx, my))
			else
				WorldMapButton.coords.text:SetText("")
			end
		end)
	end)
end)