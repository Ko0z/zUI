-- Credits to Shagu
zUI:RegisterComponent("zTroubleSeeker", function ()
	-- mainly for debugging, checks for illegal function calls
	-- Credits to Shagu
	zTroubleSeeker = CreateFrame("Frame")
	zTroubleSeeker:RegisterEvent("ADDON_ACTION_BLOCKED") 
	zTroubleSeeker:RegisterEvent("ADDON_ACTION_FORBIDDEN")
	zTroubleSeeker:SetScript( "OnEvent", function() 
		if (event == ADDON_ACTION_BLOCKED) or (event == ADDON_ACTION_FORBIDDEN) then
			if (arg1) and (arg2) then
				local addonName = tostring(arg1);
				local fName = tostring(arg2);
				zPrint(fontRed .. "PROTECTED FUNCTION ATTEMPT BY: |r" .. addonName .. " function: " .. fName);
			elseif (arg1) then
				local addonName = tostring(arg1);
				zPrint(fontRed .. "PROTECTED FUNCTION ATTEMPT BY: |r" .. addonName);
			end
		end
	end)
end)