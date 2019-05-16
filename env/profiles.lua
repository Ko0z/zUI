local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
	
	-- zUI
	zUI_profiles["zUI"] = {
		["global"] = {
			["darkmode"] = "1",
		},

		["actionbars"] = {
			["darkmode"] = "1",
			["bfa_style"] = "1",
			["squarebuttons"] = "0",
		},

		["unitframes"] = {
			["darkmode"] = "1",
			["improvedpet"] = "1",
			["classportraits"] = "0",
			["compactmode"] = "0",
		},
	}

end)