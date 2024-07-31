zUI:RegisterSkin("Actionbuttons", function () 
	
	local cr,cg,cb,ca = zUI.api.GetStringColor(C.skin.dark)

	for i = 1, 24 do
		local bu = _G['BonusActionButton'..i]
		if  bu then
			if (C.actionbars.squarebuttons == "1") then
				zStyle_Button(bu,0,0,1) --square borders.
			else
				zStyle_Button(bu, 0) 
			end
			zStyle_ButtonElements(bu)
			--bu:SetCheckedTexture''
			if (C.global.darkmode == "1") then 
				zSkinColor(bu,cr,cg,cb,ca);
			else
				zSkinColor(bu,0.7,0.7,0.7,1);
			end
		end
	end
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
			
			if (C.actionbars.squarebuttons == "1") then
				zStyle_Button(v,0,0,1) --square borders.
			else
				zStyle_Button(v, 0) 
			end
			zStyle_ButtonElements(v)
			if (C.global.darkmode == "1") then
				--zSkinColor(v,0.1,0.1,0.1,1);
				zSkinColor(v,cr,cg,cb,ca);
			else
				zSkinColor(v,0.7,0.7,0.7,1);
			end
		end
		--[[
		for _, v in pairs(
			{
				_G['MultiBarBottomLeftButton1'],
				_G['MultiBarBottomLeftButton12'],
				--_G['MultiBarBottomRightButton6']
				_G['MultiBarRightButton12']
			}
		) do
			v:SetFrameStrata'LOW'
		end
		]]
		_G['MultiBarBottomLeftButton1']:SetFrameStrata'LOW';

		if (C.actionbars.bfa_style == "1") then 
			_G['MultiBarBottomRightButton6']:SetFrameStrata'LOW' 
		else
			_G['MultiBarBottomLeftButton12']:SetFrameStrata'LOW' 
			_G['MultiBarRightButton12']:SetFrameStrata'LOW' 
		end

		for _, v in pairs(
			{
				_G['ActionButton'..i..'NormalTexture'],
				_G['MultiBarLeftButton'..i..'NormalTexture'],
				_G['MultiBarRightButton'..i..'NormalTexture'],
				_G['MultiBarBottomLeftButton'..i..'NormalTexture'],
				_G['MultiBarBottomRightButton'..i..'NormalTexture'],
				_G['BonusActionButton'..i..'NormalTexture']
				--_G['PetActionButton'..i..'NormalTexture']
				--_G['BonusActionButton'..i..'NormalTexture']
			}
		) do
			v:SetAlpha(0)
		end

		for _, v in pairs(
			{
				_G['ActionButton'..i..'Cooldown'],
				_G['MultiBarLeftButton'..i..'Cooldown'],
				_G['MultiBarRightButton'..i..'Cooldown'],
				_G['MultiBarBottomLeftButton'..i..'Cooldown'],
				_G['MultiBarBottomRightButton'..i..'Cooldown'],
				_G['BonusActionButton'..i..'Cooldown']
			}
		) do 
			if (C.actionbars.cooldown_background == "0") then
				v:SetFrameLevel(4)
			end
			v.zCooldownType = "NOGCD"
			v.zTextSize = 20; -- TODO: Make config for size
		end
	end

	for i = 1, 10 do
		local a = _G['PetActionButton'..i..'AutoCast']
		a:SetScale(1) a:SetFrameLevel(3)

		local a = _G['PetActionButton'..i..'AutoCastable']
		a:SetWidth(50) a:SetHeight(50)

		for _, v in pairs(
			{
				_G['ShapeshiftButton'..i],
				--_G['PetActionButton'..i]
			}
		) do
			zStyle_Button(v)
			if (C.global.darkmode == "1") then
				--zSkinColor(v,0.2,0.2,0.2,1);
				zSkinColor(v,cr,cg,cb,ca);
			else
				zSkinColor(v,0.7,0.7,0.7,1);
			end
		end

		for _, v in pairs(
			{
				--_G['ShapeshiftButton'..i],
				_G['PetActionButton'..i]
			}
		) do
			--v:SetFrameLevel("MEDIUM")
			v:SetFrameStrata'LOW' -- LOW --possibly causing stance background image to be superior..
			zStyle_Button(v)
			if (C.global.darkmode == "1") then
				--zSkinColor(v,0.2,0.2,0.2,1);
				zSkinColor(v,cr,cg,cb,ca);
			else
				zSkinColor(v,0.7,0.7,0.7,1);
			end
		end
	end
end)