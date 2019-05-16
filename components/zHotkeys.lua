zUI:RegisterComponent("zHotkeys", function ()

	for i = 1, 12 do
		for k, v in pairs(
				{
				_G['ActionButton'..i],
				_G['MultiBarRightButton'..i],
				_G['MultiBarLeftButton'..i],
				_G['MultiBarBottomLeftButton'..i],
				_G['MultiBarBottomRightButton'..i],
			}
		) do
			SetupHotkeyString(v);
		end
	end

	for i = 1, 24 do
		local v = _G['BonusActionButton'..i]
		SetupHotkeyString(v);
	end

	for i = 1, 10 do
		for _, v in pairs(
			{
				_G['ShapeshiftButton'..i],
				_G['PetActionButton'..i]
			}
		) do
			SetupHotkeyString(v);
		end
	end
end)